import 'package:flutter/services.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/errors/result.dart';
import '../domain/camera_repository.dart';
import '../domain/camera_state.dart';
import 'camera_native_service.dart';

/// Implements [CameraRepository] using [CameraNativeService].
class CameraRepositoryImpl implements CameraRepository {
  CameraRepositoryImpl(this._nativeService);

  final CameraNativeService _nativeService;

  @override
  Future<Result<CameraInitResult>> initialize({
    CameraQuality quality = CameraQuality.high,
    CameraFacing facing = CameraFacing.back,
  }) async {
    try {
      final result = await _nativeService.initialize(
        quality: quality.name,
        facing: facing.name,
      );
      if (result == null) {
        return const Failure(CameraError('Camera initialization returned null'));
      }
      final previewSize = result['previewSize'] as Map?;
      return Success(CameraInitResult(
        previewWidth: (previewSize?['width'] as num?)?.toDouble() ?? 0,
        previewHeight: (previewSize?['height'] as num?)?.toDouble() ?? 0,
      ));
    } on PlatformException catch (e) {
      return Failure(CameraError(e.message ?? 'Camera init failed'));
    }
  }

  @override
  Future<Result<int>> startPreview() async {
    try {
      final result = await _nativeService.startPreview();
      final textureId = result?['textureId'] as int?;
      if (textureId == null) {
        return const Failure(CameraError('No texture ID returned'));
      }
      return Success(textureId);
    } on PlatformException catch (e) {
      return Failure(CameraError(e.message ?? 'Preview start failed'));
    }
  }

  @override
  Future<Result<CaptureResult>> capture(String outputPath) async {
    try {
      final result = await _nativeService.capture(outputPath);
      if (result == null) {
        return const Failure(CameraError('Capture returned null'));
      }
      return Success(CaptureResult(
        path: result['path'] as String? ?? outputPath,
        width: result['width'] as int? ?? 0,
        height: result['height'] as int? ?? 0,
      ));
    } on PlatformException catch (e) {
      return Failure(CameraError(e.message ?? 'Capture failed'));
    }
  }

  @override
  Future<Result<void>> setFlash(FlashMode mode) async {
    try {
      await _nativeService.setFlash(mode);
      return const Success(null);
    } on PlatformException catch (e) {
      return Failure(CameraError(e.message ?? 'Flash setting failed'));
    }
  }

  @override
  Future<Result<void>> setZoom(double level) async {
    try {
      await _nativeService.setZoom(level);
      return const Success(null);
    } on PlatformException catch (e) {
      return Failure(CameraError(e.message ?? 'Zoom setting failed'));
    }
  }

  @override
  Future<void> dispose() async {
    await _nativeService.dispose();
  }
}
