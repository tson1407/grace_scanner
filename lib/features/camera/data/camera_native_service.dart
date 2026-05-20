import 'package:flutter/services.dart';

import '../../../core/utils/logger.dart';
import '../domain/camera_state.dart';

/// Dart-side wrapper for native camera MethodChannel and EventChannel.
class CameraNativeService {
  CameraNativeService();

  static const _channel = MethodChannel('com.scanflow/camera');
  static const _streamChannel = EventChannel('com.scanflow/camera_stream');

  /// Initialize the camera.
  Future<Map<String, dynamic>?> initialize({
    String quality = 'high',
    String facing = 'back',
  }) async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'initialize',
        {'quality': quality, 'facing': facing},
      );
      return result;
    } on PlatformException catch (e) {
      AppLogger.error('Camera initialize failed', error: e);
      rethrow;
    }
  }

  /// Start camera preview and return texture ID.
  Future<Map<String, dynamic>?> startPreview() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'startPreview',
      );
      return result;
    } on PlatformException catch (e) {
      AppLogger.error('Camera startPreview failed', error: e);
      rethrow;
    }
  }

  /// Capture a photo.
  Future<Map<String, dynamic>?> capture(String outputPath) async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'capture',
        {'outputPath': outputPath},
      );
      return result;
    } on PlatformException catch (e) {
      AppLogger.error('Camera capture failed', error: e);
      rethrow;
    }
  }

  /// Set flash mode.
  Future<void> setFlash(FlashMode mode) async {
    try {
      await _channel.invokeMethod('setFlash', {
        'mode': mode.name,
      });
    } on PlatformException catch (e) {
      AppLogger.error('Camera setFlash failed', error: e);
      rethrow;
    }
  }

  /// Set zoom level.
  Future<void> setZoom(double level) async {
    try {
      await _channel.invokeMethod('setZoom', {
        'level': level,
      });
    } on PlatformException catch (e) {
      AppLogger.error('Camera setZoom failed', error: e);
      rethrow;
    }
  }

  /// Dispose camera resources.
  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('dispose');
    } on PlatformException catch (e) {
      AppLogger.error('Camera dispose failed', error: e);
    }
  }

  /// Stream of camera preview frames for edge detection.
  Stream<Map<dynamic, dynamic>> get frameStream {
    return _streamChannel.receiveBroadcastStream().map(
          (event) => event as Map<dynamic, dynamic>,
        );
  }
}
