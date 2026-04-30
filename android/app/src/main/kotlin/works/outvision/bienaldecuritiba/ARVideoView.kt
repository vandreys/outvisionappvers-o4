package works.outvision.bienaldecuritiba

import android.app.Activity
import android.graphics.SurfaceTexture
import android.opengl.GLES11Ext
import android.opengl.GLES20
import android.opengl.GLSurfaceView
import android.opengl.Matrix
import android.view.Surface
import android.view.View
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import com.google.ar.core.*
import com.google.ar.core.exceptions.CameraNotAvailableException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

class ARVideoView(
    private val activity: Activity,
    viewId: Int,
    messenger: BinaryMessenger,
    params: Map<String, Any>
) : PlatformView, GLSurfaceView.Renderer {

    private val videoUrl: String = params["videoUrl"] as? String ?: ""

    private val glView = GLSurfaceView(activity).also {
        it.preserveEGLContextOnPause = true
        it.setEGLContextClientVersion(2)
        it.setRenderer(this)
        it.renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY
    }

    // ARCore
    private var session: Session? = null
    private var anchor: Anchor? = null
    @Volatile private var isSessionResumed = false

    // GL resource IDs
    private var camTexId   = 0
    private var videoTexId = 0
    private var bgProg     = 0
    private var quadProg   = 0
    private var quadVbo    = 0

    // Video SurfaceTexture — created on the GL thread
    private var videoST: SurfaceTexture? = null
    private val videoTransMat = FloatArray(16).also { Matrix.setIdentityM(it, 0) }

    // ExoPlayer — runs on main thread, renders into SurfaceTexture
    private var player: ExoPlayer? = null

    // EventChannel — notifies Flutter when camera is rendering
    private var eventSink: EventChannel.EventSink? = null
    private var readySent = false

    // Scratch matrices
    private val viewMat   = FloatArray(16)
    private val projMat   = FloatArray(16)
    private val anchorMat = FloatArray(16)
    private val vpMat     = FloatArray(16)
    private val mvpMat    = FloatArray(16)

    // Camera background: NDC quad corners → ARCore gives us correct UVs each frame
    private val NDC_QUAD  = floatArrayOf(-1f, -1f, 1f, -1f, -1f, 1f, 1f, 1f)
    private val camUvArr  = FloatArray(8)
    private val camUvBuf: FloatBuffer = ByteBuffer
        .allocateDirect(8 * 4).order(ByteOrder.nativeOrder()).asFloatBuffer()

    // Background positions in clip space (static)
    private val bgPosBuf: FloatBuffer = ByteBuffer
        .allocateDirect(12 * 4).order(ByteOrder.nativeOrder()).asFloatBuffer().also {
            it.put(floatArrayOf(-1f, -1f, 0f,  1f, -1f, 0f,  -1f, 1f, 0f,  1f, 1f, 0f))
            it.position(0)
        }

    init {
        EventChannel(messenger, "outvisionxr/ar_view_events_$viewId")
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    // Flush any error that occurred before Flutter subscribed
                    val pending = pendingError
                    if (pending != null) {
                        pendingError = null
                        sendEvent(if (pending.startsWith("error:")) pending else "error:$pending:")
                    }
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            })
        initSession()
        glView.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
            override fun onViewAttachedToWindow(v: View) {
                // Session must be resumed BEFORE glView.onResume() starts the GL thread.
                // Reversing this order causes AR_ERROR_SESSION_PAUSED on every frame.
                try {
                    session?.resume()
                    isSessionResumed = true
                } catch (e: CameraNotAvailableException) {
                    android.util.Log.e("ARVideoView", "Camera not available: $e")
                } catch (e: Exception) {
                    android.util.Log.e("ARVideoView", "Session resume failed: $e")
                }
                glView.onResume()
            }
            override fun onViewDetachedFromWindow(v: View) {
                glView.onPause()
                isSessionResumed = false
                session?.pause()
            }
        })
    }

    private fun initSession() {
        try {
            val availability = ArCoreApk.getInstance().checkAvailability(activity)
            if (availability == ArCoreApk.Availability.SUPPORTED_INSTALLED) {
                session = Session(activity).also { s ->
                    s.configure(Config(s).apply {
                        focusMode = Config.FocusMode.AUTO
                        updateMode = Config.UpdateMode.LATEST_CAMERA_IMAGE
                    })
                }
            } else {
                android.util.Log.w("ARVideoView", "ARCore availability: $availability")
            }
        } catch (e: Exception) {
            android.util.Log.e("ARVideoView", "ARCore init failed: $e")
        }
    }

    // ── GLSurfaceView.Renderer ─────────────────────────────────────────────

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        GLES20.glClearColor(0f, 0f, 0f, 1f)
        val ids = IntArray(1)

        // Camera OES texture — ARCore writes frames into this automatically
        GLES20.glGenTextures(1, ids, 0); camTexId = ids[0]
        bindOES(camTexId)
        session?.setCameraTextureName(camTexId)

        // Video OES texture — ExoPlayer writes via SurfaceTexture
        GLES20.glGenTextures(1, ids, 0); videoTexId = ids[0]
        bindOES(videoTexId)
        videoST = SurfaceTexture(videoTexId).also { st ->
            // Must set buffer size so ExoPlayer knows the render target dimensions
            st.setDefaultBufferSize(1920, 1080)
            startVideo(Surface(st))
        }

        bgProg   = buildProgram(VS_PASS, FS_OES)
        quadProg = buildProgram(VS_MVP,  FS_VIDEO)
        quadVbo  = buildQuadVbo(halfW = 1.0f, halfH = 9f / 16f) // 2 m wide, 16:9
    }

    override fun onSurfaceChanged(gl: GL10?, w: Int, h: Int) {
        GLES20.glViewport(0, 0, w, h)
        session?.setDisplayGeometry(Surface.ROTATION_0, w, h)
    }

    override fun onDrawFrame(gl: GL10?) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT or GLES20.GL_DEPTH_BUFFER_BIT)
        val sess = session?.takeIf { isSessionResumed } ?: return

        val frame = try { sess.update() } catch (e: Exception) { return }
        val camera = frame.camera

        // Draw camera feed as fullscreen background using ARCore's UV transform
        frame.transformCoordinates2d(
            Coordinates2d.OPENGL_NORMALIZED_DEVICE_COORDINATES, NDC_QUAD,
            Coordinates2d.TEXTURE_NORMALIZED, camUvArr)
        camUvBuf.put(camUvArr).position(0)
        drawBackground()

        if (!readySent) {
            readySent = true
            sendEvent("ready")
        }

        if (camera.trackingState != TrackingState.TRACKING) return

        // Plant anchor 1 m ahead on the horizontal plane at camera height.
        // Project the camera forward onto XZ to ignore phone tilt — keeps the
        // video vertical regardless of whether the phone points up or down.
        if (anchor == null) {
            val pose = camera.pose
            val fwd  = pose.rotateVector(floatArrayOf(0f, 0f, -1f))
            val horizLen = kotlin.math.sqrt(
                (fwd[0] * fwd[0] + fwd[2] * fwd[2]).toDouble()
            ).toFloat().coerceAtLeast(0.01f)
            anchor = sess.createAnchor(
                Pose.makeTranslation(
                    pose.tx() + fwd[0] / horizLen,
                    pose.ty(),
                    pose.tz() + fwd[2] / horizLen
                )
            )
        }

        val anc = anchor?.takeIf { it.trackingState == TrackingState.TRACKING } ?: return

        // Always latch the latest video frame — calling without a new frame is a no-op
        videoST?.updateTexImage()
        videoST?.getTransformMatrix(videoTransMat)

        // MVP: project anchor's world-space quad to clip space
        camera.getViewMatrix(viewMat, 0)
        camera.getProjectionMatrix(projMat, 0, 0.05f, 100f)
        anc.pose.toMatrix(anchorMat, 0)
        Matrix.multiplyMM(vpMat,  0, projMat, 0, viewMat,   0)
        Matrix.multiplyMM(mvpMat, 0, vpMat,   0, anchorMat, 0)

        drawVideoQuad()
    }

    // ── Draw calls ────────────────────────────────────────────────────────

    private fun drawBackground() {
        GLES20.glDisable(GLES20.GL_DEPTH_TEST)
        GLES20.glDepthMask(false)
        GLES20.glUseProgram(bgProg)

        val posLoc = GLES20.glGetAttribLocation(bgProg, "a_Position")
        val uvLoc  = GLES20.glGetAttribLocation(bgProg, "a_TexCoord")
        val texLoc = GLES20.glGetUniformLocation(bgProg, "u_Texture")

        GLES20.glVertexAttribPointer(posLoc, 3, GLES20.GL_FLOAT, false, 0, bgPosBuf)
        GLES20.glEnableVertexAttribArray(posLoc)
        GLES20.glVertexAttribPointer(uvLoc,  2, GLES20.GL_FLOAT, false, 0, camUvBuf)
        GLES20.glEnableVertexAttribArray(uvLoc)

        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, camTexId)
        GLES20.glUniform1i(texLoc, 0)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)

        GLES20.glDepthMask(true)
        GLES20.glEnable(GLES20.GL_DEPTH_TEST)
    }

    private fun drawVideoQuad() {
        GLES20.glEnable(GLES20.GL_BLEND)
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        GLES20.glUseProgram(quadProg)

        val posLoc    = GLES20.glGetAttribLocation(quadProg, "a_Position")
        val uvLoc     = GLES20.glGetAttribLocation(quadProg, "a_TexCoord")
        val mvpLoc    = GLES20.glGetUniformLocation(quadProg, "u_MVP")
        val texLoc    = GLES20.glGetUniformLocation(quadProg, "u_Texture")
        val transLoc  = GLES20.glGetUniformLocation(quadProg, "u_TexTransform")

        GLES20.glUniformMatrix4fv(mvpLoc,   1, false, mvpMat,       0)
        GLES20.glUniformMatrix4fv(transLoc, 1, false, videoTransMat, 0)

        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, quadVbo)
        // stride = 5 floats × 4 bytes = 20
        GLES20.glVertexAttribPointer(posLoc, 3, GLES20.GL_FLOAT, false, 20, 0)
        GLES20.glEnableVertexAttribArray(posLoc)
        GLES20.glVertexAttribPointer(uvLoc,  2, GLES20.GL_FLOAT, false, 20, 12)
        GLES20.glEnableVertexAttribArray(uvLoc)

        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, videoTexId)
        GLES20.glUniform1i(texLoc, 0)
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)

        GLES20.glDisable(GLES20.GL_BLEND)
        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0)
    }

    // ── GL utilities ──────────────────────────────────────────────────────

    private fun bindOES(texId: Int) {
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, texId)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
    }

    // Each vertex: x y z u v  (5 floats, 20 bytes stride)
    private fun buildQuadVbo(halfW: Float, halfH: Float): Int {
        val data = floatArrayOf(
            -halfW, -halfH, 0f,  0f, 0f,
             halfW, -halfH, 0f,  1f, 0f,
            -halfW,  halfH, 0f,  0f, 1f,
             halfW,  halfH, 0f,  1f, 1f
        )
        val ids = IntArray(1)
        GLES20.glGenBuffers(1, ids, 0)
        val buf = ByteBuffer.allocateDirect(data.size * 4).order(ByteOrder.nativeOrder())
            .asFloatBuffer().apply { put(data); position(0) }
        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, ids[0])
        GLES20.glBufferData(GLES20.GL_ARRAY_BUFFER, data.size * 4, buf, GLES20.GL_STATIC_DRAW)
        GLES20.glBindBuffer(GLES20.GL_ARRAY_BUFFER, 0)
        return ids[0]
    }

    private fun buildProgram(vert: String, frag: String): Int {
        fun compile(type: Int, src: String): Int {
            val sh = GLES20.glCreateShader(type)
            GLES20.glShaderSource(sh, src)
            GLES20.glCompileShader(sh)
            val ok = IntArray(1)
            GLES20.glGetShaderiv(sh, GLES20.GL_COMPILE_STATUS, ok, 0)
            if (ok[0] == 0)
                android.util.Log.e("ARVideoView", "Shader compile:\n${GLES20.glGetShaderInfoLog(sh)}")
            return sh
        }
        return GLES20.glCreateProgram().also { prog ->
            GLES20.glAttachShader(prog, compile(GLES20.GL_VERTEX_SHADER,   vert))
            GLES20.glAttachShader(prog, compile(GLES20.GL_FRAGMENT_SHADER, frag))
            GLES20.glLinkProgram(prog)
            val ok = IntArray(1)
            GLES20.glGetProgramiv(prog, GLES20.GL_LINK_STATUS, ok, 0)
            if (ok[0] == 0)
                android.util.Log.e("ARVideoView", "Program link:\n${GLES20.glGetProgramInfoLog(prog)}")
        }
    }

    private fun startVideo(surface: Surface) {
        if (videoUrl.isEmpty()) {
            android.util.Log.e("ARVideoView", "videoUrl is empty — no video to play")
            pendingError = "VIDEO_URL_EMPTY"
            return
        }
        activity.runOnUiThread {
            try {
                player = ExoPlayer.Builder(activity).build().also { exo ->
                    exo.setVideoSurface(surface)
                    exo.setMediaItem(MediaItem.fromUri(videoUrl))
                    exo.repeatMode = Player.REPEAT_MODE_ONE
                    exo.volume = 0f
                    exo.addListener(object : Player.Listener {
                        override fun onPlaybackStateChanged(state: Int) {
                            if (state == Player.STATE_READY) {
                                android.util.Log.d("ARVideoView", "ExoPlayer ready — playing")
                            }
                        }
                        override fun onPlayerError(error: PlaybackException) {
                            android.util.Log.e("ARVideoView", "ExoPlayer error: $error")
                            sendEvent("error:MEDIA_ERROR:${error.errorCode}/${error.message}")
                        }
                    })
                    exo.prepare()
                    exo.playWhenReady = true
                }
                android.util.Log.d("ARVideoView", "ExoPlayer prepare() called for: $videoUrl")
            } catch (e: Exception) {
                android.util.Log.e("ARVideoView", "ExoPlayer setup failed: $e")
                pendingError = "MEDIA_SETUP_FAILED: $e"
            }
        }
    }

    // Queues an event string; sends immediately if eventSink is ready
    private var pendingError: String? = null

    private fun sendEvent(msg: String) {
        activity.runOnUiThread {
            val sink = eventSink
            if (sink != null) {
                if (msg.startsWith("error:")) {
                    val parts = msg.removePrefix("error:").split(":", limit = 2)
                    sink.error(parts.getOrElse(0) { "ERROR" }, parts.getOrElse(1) { msg }, null)
                } else {
                    sink.success(msg)
                }
            } else {
                pendingError = msg
            }
        }
    }

    // ── PlatformView ──────────────────────────────────────────────────────

    override fun getView(): View = glView

    override fun dispose() {
        activity.runOnUiThread {
            player?.release(); player = null
        }
        glView.queueEvent {
            videoST?.release(); videoST = null
        }
        anchor?.detach()
        isSessionResumed = false
        session?.close(); session = null
    }

    // ── GLSL shaders ──────────────────────────────────────────────────────

    companion object {
        // Background: positions come in clip space, UVs from ARCore transform
        private const val VS_PASS = """
            attribute vec4 a_Position;
            attribute vec2 a_TexCoord;
            varying vec2 v_TexCoord;
            void main() {
                gl_Position = a_Position;
                v_TexCoord  = a_TexCoord;
            }
        """
        // Video quad: positions in anchor's local space, transformed to clip space by MVP
        private const val VS_MVP = """
            uniform mat4 u_MVP;
            attribute vec4 a_Position;
            attribute vec2 a_TexCoord;
            varying vec2 v_TexCoord;
            void main() {
                gl_Position = u_MVP * a_Position;
                v_TexCoord  = a_TexCoord;
            }
        """
        // Camera background: no transform needed (ARCore handles it)
        private const val FS_OES = """
            #extension GL_OES_EGL_image_external : require
            precision mediump float;
            uniform samplerExternalOES u_Texture;
            varying vec2 v_TexCoord;
            void main() {
                gl_FragColor = texture2D(u_Texture, v_TexCoord);
            }
        """
        // Video quad: applies SurfaceTexture.getTransformMatrix() to correct UVs
        private const val FS_VIDEO = """
            #extension GL_OES_EGL_image_external : require
            precision mediump float;
            uniform samplerExternalOES u_Texture;
            uniform mat4 u_TexTransform;
            varying vec2 v_TexCoord;
            void main() {
                vec2 uv = (u_TexTransform * vec4(v_TexCoord, 0.0, 1.0)).xy;
                gl_FragColor = texture2D(u_Texture, uv);
            }
        """
    }
}
