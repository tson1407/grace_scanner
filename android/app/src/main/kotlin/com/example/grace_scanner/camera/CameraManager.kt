package com.example.grace_scanner.camera

import android.app.Activity
import android.graphics.SurfaceTexture
import android.view.Surface
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.view.TextureRegistry
import java.io.File
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class CameraManager(
    private val activity: Activity,
    private val textureRegistry: TextureRegistry
) {
    private var cameraProvider: ProcessCameraProvider? = null
    private var camera: Camera? = null
    private var imageCapture: ImageCapture? = null
    private var preview: Preview? = null
    private var textureEntry: TextureRegistry.SurfaceTextureEntry? = null
    private var frameEventSink: EventChannel.EventSink? = null
    private val cameraExecutor: ExecutorService = Executors.newSingleThreadExecutor()

    fun setFrameEventSink(sink: EventChannel.EventSink?) {
        frameEventSink = sink
    }

    fun initialize(quality: String, facing: String, result: MethodChannel.Result) {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(activity)

        cameraProviderFuture.addListener({
            try {
                cameraProvider = cameraProviderFuture.get()

                val cameraSelector = when (facing) {
                    "front" -> CameraSelector.DEFAULT_FRONT_CAMERA
                    else -> CameraSelector.DEFAULT_BACK_CAMERA
                }

                // Build image capture use case
                imageCapture = ImageCapture.Builder()
                    .setCaptureMode(ImageCapture.CAPTURE_MODE_MAXIMIZE_QUALITY)
                    .setTargetAspectRatio(AspectRatio.RATIO_4_3)
                    .build()

                result.success(mapOf(
                    "success" to true,
                    "previewSize" to mapOf("width" to 1080.0, "height" to 1440.0)
                ))
            } catch (e: Exception) {
                result.error("INIT_FAILED", e.message, null)
            }
        }, ContextCompat.getMainExecutor(activity))
    }

    fun startPreview(result: MethodChannel.Result) {
        try {
            val provider = cameraProvider
            if (provider == null) {
                result.error("NOT_INITIALIZED", "Camera not initialized", null)
                return
            }

            // Create texture for Flutter rendering
            textureEntry = textureRegistry.createSurfaceTexture()
            val surfaceTexture: SurfaceTexture = textureEntry!!.surfaceTexture()
            surfaceTexture.setDefaultBufferSize(1080, 1440)

            // Build preview use case targeting our SurfaceTexture
            preview = Preview.Builder()
                .setTargetAspectRatio(AspectRatio.RATIO_4_3)
                .build()

            preview?.surfaceProvider = Preview.SurfaceProvider { request ->
                val surface = Surface(surfaceTexture)
                request.provideSurface(surface, cameraExecutor) { /* surface released */ }
            }

            // Unbind previous and bind new use cases
            provider.unbindAll()

            val cameraSelector = CameraSelector.DEFAULT_BACK_CAMERA

            camera = provider.bindToLifecycle(
                activity as LifecycleOwner,
                cameraSelector,
                preview,
                imageCapture
            )

            result.success(mapOf(
                "textureId" to textureEntry!!.id(),
                "success" to true
            ))
        } catch (e: Exception) {
            result.error("PREVIEW_FAILED", e.message, null)
        }
    }

    fun capture(outputPath: String, result: MethodChannel.Result) {
        val capture = imageCapture
        if (capture == null) {
            result.error("NOT_INITIALIZED", "ImageCapture not initialized", null)
            return
        }

        val file = File(outputPath)
        file.parentFile?.mkdirs()

        val outputOptions = ImageCapture.OutputFileOptions.Builder(file).build()

        capture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(activity),
            object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(output: ImageCapture.OutputFileResults) {
                    result.success(mapOf(
                        "path" to outputPath,
                        "width" to 0,  // Will be read from EXIF
                        "height" to 0,
                        "success" to true
                    ))
                }

                override fun onError(exception: ImageCaptureException) {
                    result.error("CAPTURE_FAILED", exception.message, null)
                }
            }
        )
    }

    fun setFlash(mode: String, result: MethodChannel.Result) {
        try {
            val flashMode = when (mode) {
                "on" -> ImageCapture.FLASH_MODE_ON
                "auto" -> ImageCapture.FLASH_MODE_AUTO
                else -> ImageCapture.FLASH_MODE_OFF
            }
            imageCapture?.flashMode = flashMode

            // Also set torch for continuous light
            camera?.cameraControl?.enableTorch(mode == "on")

            result.success(mapOf("success" to true))
        } catch (e: Exception) {
            result.error("FLASH_FAILED", e.message, null)
        }
    }

    fun setZoom(level: Double, result: MethodChannel.Result) {
        try {
            camera?.cameraControl?.setLinearZoom(level.toFloat())
            result.success(mapOf("success" to true))
        } catch (e: Exception) {
            result.error("ZOOM_FAILED", e.message, null)
        }
    }

    fun dispose() {
        try {
            cameraProvider?.unbindAll()
            textureEntry?.release()
            cameraExecutor.shutdown()
            camera = null
            preview = null
            imageCapture = null
            textureEntry = null
        } catch (_: Exception) {
            // Best-effort cleanup
        }
    }
}
