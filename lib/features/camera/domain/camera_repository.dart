import '../../../core/errors/result.dart';
import 'camera_state.dart';

/// Abstract camera interface — domain layer.
abstract class CameraRepository {
  /// Initialize the camera with given settings.
  Future<Result<CameraInitResult>> initialize({
    CameraQuality quality = CameraQuality.high,
    CameraFacing facing = CameraFacing.back,
  });

  /// Start the camera preview and return a texture ID for rendering.
  Future<Result<int>> startPreview();

  /// Capture a photo and save to the given path.
  Future<Result<CaptureResult>> capture(String outputPath);

  /// Set the flash mode.
  Future<Result<void>> setFlash(FlashMode mode);

  /// Set the zoom level (0.0 to 1.0).
  Future<Result<void>> setZoom(double level);

  /// Release camera resources.
  Future<void> dispose();
}
