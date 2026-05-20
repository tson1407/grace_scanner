import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/result.dart';
import '../../../core/utils/file_utils.dart';
import '../../../core/utils/logger.dart';
import '../data/camera_native_service.dart';
import '../data/camera_repository_impl.dart';
import '../domain/camera_repository.dart';
import '../domain/camera_state.dart';

/// Provider for the native camera service.
final cameraNativeServiceProvider = Provider<CameraNativeService>((ref) {
  return CameraNativeService();
});

/// Provider for the camera repository.
final cameraRepositoryProvider = Provider<CameraRepository>((ref) {
  return CameraRepositoryImpl(ref.read(cameraNativeServiceProvider));
});

/// Main camera state provider.
final cameraControllerProvider =
    AutoDisposeNotifierProvider<CameraControllerNotifier, CameraState>(
  CameraControllerNotifier.new,
);

class CameraControllerNotifier extends AutoDisposeNotifier<CameraState> {
  @override
  CameraState build() {
    ref.onDispose(_dispose);
    return const CameraState();
  }

  CameraRepository get _repo => ref.read(cameraRepositoryProvider);

  /// Initialize camera and start preview.
  Future<void> initializeCamera() async {
    state = state.copyWith(status: CameraStatus.initializing);

    final initResult = await _repo.initialize(
      quality: CameraQuality.high,
      facing: state.facing,
    );

    if (initResult is Failure<CameraInitResult>) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: initResult.error.message,
      );
      return;
    }

    final previewResult = await _repo.startPreview();
    if (previewResult is Success<int>) {
      state = state.copyWith(
        status: CameraStatus.ready,
        textureId: previewResult.data,
      );
    } else if (previewResult is Failure<int>) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: previewResult.error.message,
      );
    }
  }

  /// Capture a photo and add to the session.
  Future<CaptureResult?> capture() async {
    if (state.status != CameraStatus.ready) return null;

    state = state.copyWith(status: CameraStatus.capturing);

    final tempDir = await FileUtils.tempCaptureDir;
    final pageNum = state.capturedPages.length + 1;
    final outputPath =
        '${tempDir.path}/capture_${pageNum.toString().padLeft(3, '0')}.jpg';

    final result = await _repo.capture(outputPath);

    if (result is Success<CaptureResult>) {
      final pages = [...state.capturedPages, result.data];
      state = state.copyWith(
        status: CameraStatus.ready,
        capturedPages: pages,
      );
      return result.data;
    } else if (result is Failure<CaptureResult>) {
      state = state.copyWith(
        status: CameraStatus.ready,
        errorMessage: result.error.message,
      );
    }
    return null;
  }

  /// Toggle flash mode: off → on → auto → off.
  Future<void> toggleFlash() async {
    final nextMode = switch (state.flashMode) {
      FlashMode.off => FlashMode.on,
      FlashMode.on => FlashMode.auto,
      FlashMode.auto => FlashMode.off,
    };

    final result = await _repo.setFlash(nextMode);
    if (result is Success) {
      state = state.copyWith(flashMode: nextMode);
    }
  }

  /// Set a specific flash mode.
  Future<void> setFlash(FlashMode mode) async {
    final result = await _repo.setFlash(mode);
    if (result is Success) {
      state = state.copyWith(flashMode: mode);
    }
  }

  void _dispose() {
    _repo.dispose();
    AppLogger.debug('Camera resources disposed', tag: 'Camera');
  }
}
