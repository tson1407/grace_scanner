/// Camera state entities — pure Dart, no package imports.

enum CameraStatus { uninitialized, initializing, ready, capturing, error, disposed }

enum CameraFacing { back, front }

enum CameraQuality { high, medium, low }

enum FlashMode { off, on, auto }

/// Result of camera initialization.
class CameraInitResult {
  const CameraInitResult({
    required this.previewWidth,
    required this.previewHeight,
  });

  final double previewWidth;
  final double previewHeight;
}

/// Result of a photo capture.
class CaptureResult {
  const CaptureResult({
    required this.path,
    required this.width,
    required this.height,
  });

  final String path;
  final int width;
  final int height;
}

/// Full camera state for the provider.
class CameraState {
  const CameraState({
    this.status = CameraStatus.uninitialized,
    this.textureId,
    this.flashMode = FlashMode.off,
    this.facing = CameraFacing.back,
    this.capturedPages = const [],
    this.errorMessage,
  });

  final CameraStatus status;
  final int? textureId;
  final FlashMode flashMode;
  final CameraFacing facing;
  final List<CaptureResult> capturedPages;
  final String? errorMessage;

  CameraState copyWith({
    CameraStatus? status,
    int? textureId,
    FlashMode? flashMode,
    CameraFacing? facing,
    List<CaptureResult>? capturedPages,
    String? errorMessage,
  }) {
    return CameraState(
      status: status ?? this.status,
      textureId: textureId ?? this.textureId,
      flashMode: flashMode ?? this.flashMode,
      facing: facing ?? this.facing,
      capturedPages: capturedPages ?? this.capturedPages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
