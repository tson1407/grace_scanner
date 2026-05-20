package com.example.grace_scanner.camera

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class CameraPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var cameraManager: CameraManager? = null
    private var activity: Activity? = null
    private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding = binding
        methodChannel = MethodChannel(binding.binaryMessenger, "com.scanflow/camera")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "com.scanflow/camera_stream")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        flutterPluginBinding = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        val textureRegistry = flutterPluginBinding?.textureRegistry
        if (textureRegistry != null) {
            cameraManager = CameraManager(binding.activity, textureRegistry)
        }

        // Set up EventChannel stream handler
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                cameraManager?.setFrameEventSink(events)
            }
            override fun onCancel(arguments: Any?) {
                cameraManager?.setFrameEventSink(null)
            }
        })
    }

    override fun onDetachedFromActivity() {
        cameraManager?.dispose()
        cameraManager = null
        activity = null
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val manager = cameraManager
        if (manager == null) {
            result.error("NO_ACTIVITY", "Camera plugin not attached to activity", null)
            return
        }

        when (call.method) {
            "initialize" -> {
                val quality = call.argument<String>("quality") ?: "high"
                val facing = call.argument<String>("facing") ?: "back"
                manager.initialize(quality, facing, result)
            }
            "startPreview" -> {
                manager.startPreview(result)
            }
            "capture" -> {
                val outputPath = call.argument<String>("outputPath") ?: ""
                manager.capture(outputPath, result)
            }
            "setFlash" -> {
                val mode = call.argument<String>("mode") ?: "off"
                manager.setFlash(mode, result)
            }
            "setZoom" -> {
                val level = call.argument<Double>("level") ?: 1.0
                manager.setZoom(level, result)
            }
            "dispose" -> {
                manager.dispose()
                result.success(mapOf("success" to true))
            }
            else -> result.notImplemented()
        }
    }
}
