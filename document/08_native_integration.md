# Native Integration Strategy

## Overview

Native code handles two critical subsystems where pure Dart/Flutter falls short:
1. **Camera** — Low-level camera control, frame streaming
2. **OpenCV** — Image processing, edge detection, perspective correction

## Communication Architecture

```
┌──────────────────────────────────────┐
│           Flutter (Dart)             │
│                                      │
│  CameraNativeService                 │
│  OpenCvNativeService                 │
│       │              │               │
│  MethodChannel   EventChannel        │
└───────┼──────────────┼───────────────┘
        │              │
┌───────┼──────────────┼───────────────┐
│       ▼              ▼    Android    │
│  CameraPlugin    CameraPlugin        │
│  OpenCvPlugin    (stream handler)    │
│       │                              │
│  CameraX         OpenCV JNI          │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│                  iOS                 │
│  CameraPlugin    CameraPlugin        │
│  OpenCvPlugin    (stream handler)    │
│       │                              │
│  AVFoundation    OpenCV (Obj-C++)    │
└──────────────────────────────────────┘
```

## Channel Definitions

### Camera Channels

**MethodChannel**: `com.scanflow/camera`

| Method | Direction | Args | Returns |
|---|---|---|---|
| `initialize` | Dart→Native | `{quality: String, facing: String}` | `{success: bool, previewSize: Map}` |
| `startPreview` | Dart→Native | `{textureId: int}` | `{success: bool}` |
| `capture` | Dart→Native | `{outputPath: String}` | `{path: String, width: int, height: int}` |
| `setFlash` | Dart→Native | `{mode: String}` | `{success: bool}` |
| `setZoom` | Dart→Native | `{level: double}` | `{success: bool}` |
| `dispose` | Dart→Native | none | `{success: bool}` |

**EventChannel**: `com.scanflow/camera_stream`

Streams preview frames for real-time edge detection:
```dart
// Frame data emitted ~10 FPS (throttled from 30 FPS)
{
  "width": 640,
  "height": 480,
  "bytes": Uint8List,         // YUV or JPEG bytes
  "rotation": 90,             // sensor rotation
  "timestamp": 1234567890
}
```

### OpenCV Channel

**MethodChannel**: `com.scanflow/opencv`

See `05_image_processing_pipeline.md` for method contracts.

## Android Implementation

### CameraX Setup

```kotlin
// CameraManager.kt
class CameraManager(private val context: Context) {
    private var camera: Camera? = null
    private var preview: Preview? = null
    private var imageCapture: ImageCapture? = null
    private var imageAnalysis: ImageAnalysis? = null

    fun initialize(quality: String, facing: String) {
        val cameraSelector = when (facing) {
            "front" -> CameraSelector.DEFAULT_FRONT_CAMERA
            else -> CameraSelector.DEFAULT_BACK_CAMERA
        }

        val qualityEnum = when (quality) {
            "high" -> Quality.HIGHEST
            "medium" -> Quality.HD
            else -> Quality.SD
        }

        // Bind use cases to lifecycle
        imageCapture = ImageCapture.Builder()
            .setCaptureMode(ImageCapture.CAPTURE_MODE_MAXIMIZE_QUALITY)
            .setTargetAspectRatio(AspectRatio.RATIO_4_3)
            .build()

        imageAnalysis = ImageAnalysis.Builder()
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .setOutputImageFormat(ImageAnalysis.OUTPUT_IMAGE_FORMAT_YUV_420_888)
            .build()
    }
}
```

### OpenCV JNI Bridge

```kotlin
// ImageProcessor.kt
class ImageProcessor {
    companion object {
        init {
            System.loadLibrary("opencv_java4")
        }
    }

    fun detectEdges(imagePath: String, previewScale: Double): Map<String, Any> {
        val mat = Imgcodecs.imread(imagePath)
        // ... OpenCV pipeline from 05_image_processing_pipeline.md
        mat.release()
        return mapOf("found" to true, "points" to points)
    }
}
```

## iOS Implementation

### AVFoundation Setup

```swift
// CameraManager.swift
class CameraManager: NSObject {
    private let session = AVCaptureSession()
    private var photoOutput = AVCapturePhotoOutput()
    private var videoOutput = AVCaptureVideoDataOutput()

    func initialize(quality: String, facing: String) {
        session.sessionPreset = quality == "high" ? .photo : .high

        guard let device = AVCaptureDevice.default(
            facing == "front" ? .front : .back,
            for: .video, position: .unspecified
        ) else { return }

        let input = try AVCaptureDeviceInput(device: device)
        session.addInput(input)
        session.addOutput(photoOutput)
        session.addOutput(videoOutput)
    }
}
```

### OpenCV Bridge (Obj-C++)

```objc
// ImageProcessor.mm
#import <opencv2/opencv.hpp>

@implementation ImageProcessor

- (NSDictionary *)detectEdges:(NSString *)imagePath previewScale:(double)scale {
    cv::Mat mat = cv::imread([imagePath UTF8String]);
    // ... OpenCV pipeline
    return @{@"found": @YES, @"points": pointsArray};
}

@end
```

## Texture Bridge (Camera Preview)

Use Flutter's `Texture` widget backed by a platform texture:

| Platform | Mechanism |
|---|---|
| Android | `SurfaceTexture` registered via `TextureRegistry` |
| iOS | `CVPixelBuffer` registered via `TextureRegistry` |

This gives zero-copy camera preview rendering in Flutter.

## Error Handling at Native Boundary

All native methods return structured results:

```kotlin
// Android
private fun wrapResult(block: () -> Map<String, Any>): Map<String, Any> {
    return try {
        block()
    } catch (e: Exception) {
        mapOf("success" to false, "error" to e.message)
    }
}
```

Dart side wraps into `Result<T>`:
```dart
Future<Result<EdgeDetectionResult>> detectEdges(String imagePath) async {
  try {
    final result = await _channel.invokeMapMethod('detectEdges', {...});
    if (result?['found'] == true) {
      return Success(EdgeDetectionResult.fromMap(result!));
    }
    return const Success(EdgeDetectionResult.notFound());
  } on PlatformException catch (e) {
    return Failure(AppError.native(e.message ?? 'Edge detection failed'));
  }
}
```

## Build Configuration

### Android (`build.gradle`)
```groovy
android {
    defaultConfig {
        minSdk = 24        // CameraX minimum
        ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86_64'
        }
    }
}

dependencies {
    implementation 'androidx.camera:camera-camera2:1.4.1'
    implementation 'androidx.camera:camera-lifecycle:1.4.1'
    implementation 'org.opencv:opencv-android:4.9.0'
}
```

### iOS (`Podfile`)
```ruby
pod 'OpenCV', '~> 4.9.0'
```

## Testing Native Code

| Layer | Tool | What to Test |
|---|---|---|
| Kotlin/Swift unit | JUnit/XCTest | Image processing logic, corner sorting |
| Channel integration | Flutter integration tests | Round-trip Dart↔Native calls |
| Device matrix | Firebase Test Lab / BrowserStack | OEM-specific camera behavior |
