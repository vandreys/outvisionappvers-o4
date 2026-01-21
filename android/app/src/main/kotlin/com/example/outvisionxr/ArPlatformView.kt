package com.example.outvisionxr

import android.content.Context
import android.util.Log
import android.view.View
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
) : PlatformView, EventChannel.StreamHandler {

    private val TAG = "OutvisionXR-AR"

    // ─────────────────────────────────────────────
    // ARSceneView → SOMENTE câmera no init
    // ─────────────────────────────────────────────
    private val arSceneView = ARSceneView(
        context = context,
        sessionConfiguration = { _: Session, config: Config ->
            config.geospatialMode = Config.GeospatialMode.ENABLED
        }
    )

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

        // Resume seguro (evita crash de surface)
        arSceneView.post {
            Log.i(TAG, "Resuming ARSceneView after surface attach")
            callIfExists(arSceneView, "onResume")
            callIfExists(arSceneView, "resume")
        }

        Log.i(TAG, "init: viewId=$viewId lat=$lat lng=$lng asset=$androidGlbAsset")
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
    // DISPOSE (SEM destroy())
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

    // Pausa a view (compatível com variações de API)
    callIfExists(arSceneView, "onPause")
    callIfExists(arSceneView, "pause")
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

    private fun callIfExists(target: Any, methodName: String) {
        try {
            val method = target.javaClass.methods.firstOrNull {
                it.name == methodName && it.parameterTypes.isEmpty()
            }
            method?.invoke(target)
        } catch (_: Throwable) {}
    }
}
