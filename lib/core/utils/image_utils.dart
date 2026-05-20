import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Image compression and resize helpers.
class ImageUtils {
  ImageUtils._();

  static const int defaultJpegQuality = 85;
  static const int thumbnailSize = 256;

  /// Compress JPEG bytes to target quality.
  static Uint8List compressJpeg(Uint8List bytes, {int quality = defaultJpegQuality}) {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  /// Generate a thumbnail from image bytes.
  static Uint8List generateThumbnail(Uint8List bytes, {int size = thumbnailSize}) {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;
    final thumb = img.copyResize(image, width: size);
    return Uint8List.fromList(img.encodeJpg(thumb, quality: 80));
  }

  /// Generate thumbnail from file and save to path.
  static Future<void> generateThumbnailFile(String sourcePath, String destPath, {int size = thumbnailSize}) async {
    final bytes = await File(sourcePath).readAsBytes();
    final thumbBytes = generateThumbnail(bytes, size: size);
    await File(destPath).writeAsBytes(thumbBytes);
  }
}
