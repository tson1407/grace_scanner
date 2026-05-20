/// DocumentPage entity — pure Dart, no package imports.
class DocumentPage {
  const DocumentPage({
    required this.id,
    required this.documentId,
    required this.pageOrder,
    required this.originalImagePath,
    this.processedImagePath,
    this.thumbnailPath,
    this.filterApplied = 'none',
    this.cropPoints,
    required this.width,
    required this.height,
    required this.sizeBytes,
    required this.createdAt,
  });

  final int id;
  final int documentId;
  final int pageOrder;
  final String originalImagePath;
  final String? processedImagePath;
  final String? thumbnailPath;
  final String filterApplied;
  final String? cropPoints; // JSON: [x1,y1,x2,y2,x3,y3,x4,y4]
  final int width;
  final int height;
  final int sizeBytes;
  final DateTime createdAt;

  DocumentPage copyWith({
    int? id,
    int? documentId,
    int? pageOrder,
    String? originalImagePath,
    String? processedImagePath,
    String? thumbnailPath,
    String? filterApplied,
    String? cropPoints,
    int? width,
    int? height,
    int? sizeBytes,
    DateTime? createdAt,
  }) {
    return DocumentPage(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      pageOrder: pageOrder ?? this.pageOrder,
      originalImagePath: originalImagePath ?? this.originalImagePath,
      processedImagePath: processedImagePath ?? this.processedImagePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      filterApplied: filterApplied ?? this.filterApplied,
      cropPoints: cropPoints ?? this.cropPoints,
      width: width ?? this.width,
      height: height ?? this.height,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
