import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../../core/utils/file_utils.dart';

/// File system operations for scan images.
class FileStorageService {
  /// Save captured image bytes to the original directory.
  Future<String> saveOriginalImage(
    String documentId,
    int pageOrder,
    Uint8List bytes,
  ) async {
    final docDir = await FileUtils.createDocumentDir(documentId);
    final path = FileUtils.originalPagePath(docDir, pageOrder);
    await File(path).writeAsBytes(bytes);
    return path;
  }

  /// Save processed image bytes.
  Future<String> saveProcessedImage(
    String documentId,
    int pageOrder,
    Uint8List bytes,
  ) async {
    final docDir = await FileUtils.createDocumentDir(documentId);
    final path = FileUtils.processedPagePath(docDir, pageOrder);
    await File(path).writeAsBytes(bytes);
    return path;
  }

  /// Save thumbnail bytes.
  Future<String> saveThumbnail(
    String documentId,
    int pageOrder,
    Uint8List bytes,
  ) async {
    final docDir = await FileUtils.createDocumentDir(documentId);
    final path = FileUtils.pageThumbnailPath(docDir, pageOrder);
    await File(path).writeAsBytes(bytes);
    return path;
  }

  /// Copy a file from source to document directory.
  Future<String> copyToOriginal(
    String sourcePath,
    String documentId,
    int pageOrder,
  ) async {
    final docDir = await FileUtils.createDocumentDir(documentId);
    final destPath = FileUtils.originalPagePath(docDir, pageOrder);
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  /// Delete all files for a document.
  Future<void> deleteDocumentFiles(String documentId) async {
    final scansDir = await FileUtils.scansDir;
    final docDir = Directory(p.join(scansDir.path, documentId));
    if (await docDir.exists()) {
      await docDir.delete(recursive: true);
    }
  }

  /// Get file size in bytes.
  Future<int> getFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) return file.length();
    return 0;
  }
}
