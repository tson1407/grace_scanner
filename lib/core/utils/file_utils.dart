import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// File path resolution and directory management.
class FileUtils {
  FileUtils._();

  static Future<Directory> get appDocumentsDir async =>
      getApplicationDocumentsDirectory();

  /// Base directory for all scans.
  static Future<Directory> get scansDir async {
    final docs = await appDocumentsDir;
    final dir = Directory(p.join(docs.path, 'scans'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Temp directory, cleared on app start.
  static Future<Directory> get tempCaptureDir async {
    final docs = await appDocumentsDir;
    final dir = Directory(p.join(docs.path, 'temp', 'capture_buffer'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Per-document directory with subdirs.
  static Future<String> createDocumentDir(String documentId) async {
    final scans = await scansDir;
    final base = p.join(scans.path, documentId);
    for (final sub in ['original', 'processed', 'thumbnails', 'exports']) {
      await Directory(p.join(base, sub)).create(recursive: true);
    }
    return base;
  }

  /// Original image path for a page.
  static String originalPagePath(String docDir, int pageOrder) =>
      p.join(docDir, 'original', 'page_${pageOrder.toString().padLeft(3, '0')}.jpg');

  /// Processed image path for a page.
  static String processedPagePath(String docDir, int pageOrder) =>
      p.join(docDir, 'processed', 'page_${pageOrder.toString().padLeft(3, '0')}.jpg');

  /// Thumbnail path for a page.
  static String pageThumbnailPath(String docDir, int pageOrder) =>
      p.join(docDir, 'thumbnails', 'page_${pageOrder.toString().padLeft(3, '0')}_thumb.jpg');

  /// Document thumbnail path.
  static String docThumbnailPath(String docDir) =>
      p.join(docDir, 'thumbnails', 'doc_thumb.jpg');

  /// PDF export path.
  static String pdfExportPath(String docDir) =>
      p.join(docDir, 'exports', 'document.pdf');

  /// Clear temp directory.
  static Future<void> clearTemp() async {
    final temp = await tempCaptureDir;
    if (await temp.exists()) {
      await temp.delete(recursive: true);
      await temp.create(recursive: true);
    }
  }
}
