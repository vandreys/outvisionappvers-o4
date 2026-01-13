package com.example.outvisionxr

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.widget.FrameLayout
import android.widget.TextView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.platform.PlatformView

class ArPlatformView(
    context: Context,
    messenger: BinaryMessenger,
    private val viewId: Int,
    private val args: Any?
) : PlatformView, EventChannel.StreamHandler {

    private val frameLayout: FrameLayout = FrameLayout(context)
    private var eventSink: EventChannel.EventSink? = null

    private val handler = Handler(Looper.getMainLooper())
    private var readyRunnable: Runnable? = null

    init {
        val tv = TextView(context)
        tv.text = "AR View Placeholder (Android)"
        frameLayout.addView(tv)

        // debug (opcional)
        val params = args as? Map<*, *>
        val artworkId = params?.get("artworkId") as? String
        println("AR params => artworkId=$artworkId")

        EventChannel(messenger, "outvisionxr/ar_view_events_$viewId").setStreamHandler(this)
    }

    override fun getView(): android.view.View = frameLayout

    override fun dispose() {
        readyRunnable?.let { handler.removeCallbacks(it) }
        readyRunnable = null
        eventSink = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events

        eventSink?.success("localizing")

        readyRunnable = Runnable { eventSink?.success("ready") }
        readyRunnable?.let { handler.postDelayed(it, 5000) }
    }

    override fun onCancel(arguments: Any?) {
        readyRunnable?.let { handler.removeCallbacks(it) }
        readyRunnable = null
        eventSink = null
    }
}