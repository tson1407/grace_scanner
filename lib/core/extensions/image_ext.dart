import 'dart:typed_data';

/// Helpers for image byte data.
extension ImageDataExt on Uint8List {
  /// Returns human-readable file size.
  String get readableSize {
    final kb = lengthInBytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  bool get isValidJpeg =>
      length >= 2 && this[0] == 0xFF && this[1] == 0xD8;
}
