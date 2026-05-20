/// Document entity — pure Dart, no package imports.
class Document {
  const Document({
    required this.id,
    required this.title,
    this.thumbnailPath,
    this.pageCount = 0,
    this.totalSizeBytes = 0,
    this.tags = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String? thumbnailPath;
  final int pageCount;
  final int totalSizeBytes;
  final String tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Document copyWith({
    int? id,
    String? title,
    String? thumbnailPath,
    int? pageCount,
    int? totalSizeBytes,
    String? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      pageCount: pageCount ?? this.pageCount,
      totalSizeBytes: totalSizeBytes ?? this.totalSizeBytes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
