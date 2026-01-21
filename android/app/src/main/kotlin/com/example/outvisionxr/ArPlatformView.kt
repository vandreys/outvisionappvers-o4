package com.example.outvisionxr

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.util.Log
import android.view.View
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import com.google.ar.core.Anchor
import com.google.ar.core.Config
import com.google.ar.core.Earth
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView
import io.github.sceneview.ar.ARSceneView
import io.github.sceneview.ar.node.AnchorNode
import io.github.sceneview.math.Rotation
import io.github.sceneview.model.ModelInstance
import io.github.sceneview.node.ModelNode
import java.io.File
import java.io.FileOutputStream
import kotlin.math.atan2

class ArPlatformView(
    private val context: Context,
    messenger: BinaryMessenger,
    private val viewId: Int,
    private val args: Any?
) : PlatformView, EventChannel.StreamHandler, LifecycleOwner {

    private val TAG = "OutvisionXR-AR"

    // Lifecycle para o ARSceneView
    private val lifecycleRegistry = LifecycleRegistry(this)
    override val lifecycle: Lifecycle get() = lifecycleRegistry

    // Obtém Activity do Context
    private val activity: Activity? = context.findActivity()

    // ─────────────────────────────────────────────
    // ARSceneView → SOMENTE câmera no init
    // ─────────────────────────────────────────────
    private val arSceneView = ARSceneView(
        context = activity ?: context,
        sessionConfiguration = { _: Session, config: Config ->
            config.geospatialMode = Config.GeospatialMode.ENABLED
        }
    ).apply {
        lifecycle = this@ArPlatformView.lifecycle
    }

    private var eventSink: EventChannel.EventSink? = null
    private var lastStatus: String? = null

    // Params Flutter
    private val lat: Double
    private val lng: Double
    private val eye: Double
    private val faceUser: Boolean
    private val androidGlbAsset: String

    // Estado
    private var modelInstance: ModelInstance? = null
    private var modelNode: ModelNode? = null
    private var anchor: Anchor? = null
    private var anchorNode: AnchorNode? = null

    private var modelPlaced = false
    private var modelLoading = false

    init {
        val p = args as? Map<*, *>
        lat = (p?.get("lat") as? Number)?.toDouble() ?: 0.0
        lng = (p?.get("lng") as? Number)?.toDouble() ?: 0.0
        eye = (p?.get("eyeLevelOffsetMeters") as? Number)?.toDouble() ?: 1.5
        faceUser = (p?.get("faceUser") as? Boolean) ?: true
        androidGlbAsset = (p?.get("androidGlbAsset") as? String) ?: ""

        EventChannel(
            messenger,
            "outvisionxr/ar_view_events_$viewId"
        ).setStreamHandler(this)

        // Loop leve: só monitora estado da câmera / tracking
        arSceneView.onFrame = {
            tick()
        }

        // Inicia o lifecycle como CREATED
        lifecycleRegistry.currentState = Lifecycle.State.CREATED

        // Resume após surface attach
        arSceneView.post {
            Log.i(TAG, "Starting ARSceneView lifecycle")
            lifecycleRegistry.currentState = Lifecycle.State.STARTED
            lifecycleRegistry.currentState = Lifecycle.State.RESUMED
            Log.i(TAG, "ARSceneView lifecycle RESUMED")
        }

        Log.i(TAG, "init: viewId=$viewId lat=$lat lng=$lng asset=$androidGlbAsset activity=${activity != null}")
    }

    override fun getView(): View = arSceneView

    // ─────────────────────────────────────────────
    // EventChannel
    // ─────────────────────────────────────────────
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        emitStatus("localizing")
        Log.i(TAG, "AR started")
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    // ─────────────────────────────────────────────
    // DISPOSE
    // ─────────────────────────────────────────────
    override fun dispose() {
        Log.i(TAG, "dispose")

        // Para o loop
        arSceneView.onFrame = null
        eventSink = null

        // Tenta tirar da cena (se API existir, senão ignora)
        try { anchorNode?.let { arSceneView.removeChildNode(it) } } catch (_: Throwable) {}
        anchorNode = null
        modelNode = null
        modelInstance = null

        // Libera o anchor do ARCore
        try { anchor?.detach() } catch (_: Throwable) {}
        anchor = null

        // Encerra lifecycle
        lifecycleRegistry.currentState = Lifecycle.State.DESTROYED
    }

    // ─────────────────────────────────────────────
    // TICK → câmera → tracking → obra
    // ─────────────────────────────────────────────
    private fun tick() {
        val session = arSceneView.session ?: return
        val earth = session.earth ?: return

        if (
            earth.trackingState != TrackingState.TRACKING ||
            earth.earthState != Earth.EarthState.ENABLED
        ) {
            emitStatus("localizing")
            return
        }

        val pose = earth.cameraGeospatialPose
        val accuracyOk =
            pose.horizontalAccuracy <= 10.0 &&
            pose.orientationYawAccuracy <= 15.0

        if (!accuracyOk) {
            emitStatus("localizing")
            return
        }

        emitStatus("ready")

        if (!modelPlaced && !modelLoading) {
            modelLoading = true
            placeArtwork(earth, pose.altitude + eye)
        }

        if (faceUser && modelNode != null) {
            applyBillboard()
        }
    }

    // ─────────────────────────────────────────────
    // GERAR OBRA (APÓS CÂMERA ATIVA)
    // ─────────────────────────────────────────────
    private fun placeArtwork(earth: Earth, altitude: Double) {
        val cacheFile = try {
            copyFlutterAssetToCache(
                androidGlbAsset,
                "${viewId}_model.glb"
            )
        } catch (e: Exception) {
            emitError("Erro ao copiar GLB: ${e.message}")
            return
        }

        val uri = cacheFile.toURI().toString()
        Log.i(TAG, "Loading model AFTER camera tracking")

        arSceneView.modelLoader.loadModelInstanceAsync(uri) { instance ->
            if (instance == null) {
                emitError("Falha ao carregar modelo")
                return@loadModelInstanceAsync
            }

            modelInstance = instance
            modelNode = ModelNode(
                modelInstance = instance,
                autoAnimate = true,
                scaleToUnits = 1.0f
            )

            anchor = earth.createAnchor(
                lat, lng, altitude,
                0f, 0f, 0f, 1f
            )

            anchorNode = AnchorNode(arSceneView.engine, anchor!!)
            arSceneView.addChildNode(anchorNode!!)
            anchorNode!!.addChildNode(modelNode!!)

            modelPlaced = true
            Log.i(TAG, "Artwork placed")
        }
    }

    // ─────────────────────────────────────────────
    // BILLBOARD
    // ─────────────────────────────────────────────
    private fun applyBillboard() {
        val cam = arSceneView.cameraNode.position
        val obj = modelNode!!.position

        val dx = cam.x - obj.x
        val dz = cam.z - obj.z

        val yawRad = atan2(dx.toDouble(), dz.toDouble())
        val yawDeg = Math.toDegrees(yawRad).toFloat()

        modelNode!!.rotation = Rotation(0f, yawDeg, 0f)
    }

    // ─────────────────────────────────────────────
    // UTILS
    // ─────────────────────────────────────────────
    private fun copyFlutterAssetToCache(
        flutterAssetPath: String,
        outFileName: String
    ): File {
        val androidAssetPath = "flutter_assets/$flutterAssetPath"
        val outFile = File(context.cacheDir, outFileName)

        context.assets.open(androidAssetPath).use { input ->
            FileOutputStream(outFile).use { output ->
                input.copyTo(output)
            }
        }
        return outFile
    }

    private fun emitStatus(status: String) {
        if (lastStatus == status) return
        eventSink?.success(status)
        lastStatus = status
    }

    private fun emitError(message: String) {
        eventSink?.success(
            mapOf("status" to "error", "message" to message)
        )
        lastStatus = "error"
        Log.e(TAG, message)
    }

}

// Extension para obter Activity do Context
private fun Context.findActivity(): Activity? {
    var ctx = this
    while (ctx is ContextWrapper) {
        if (ctx is Activity) return ctx
        ctx = ctx.baseContext
    }
    return null
}
