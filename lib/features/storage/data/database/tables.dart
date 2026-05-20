import 'package:drift/drift.dart';

/// Drift table definitions for the ScanFlow database.

class Documents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get pageCount => integer().withDefault(const Constant(0))();
  IntColumn get totalSizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get tags => text().withDefault(const Constant(''))(); // comma-separated
  IntColumn get createdAt => integer()(); // Unix epoch ms
  IntColumn get updatedAt => integer()(); // Unix epoch ms
}

class DocumentPages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get documentId => integer().references(Documents, #id)();
  IntColumn get pageOrder => integer()();
  TextColumn get originalImagePath => text()();
  TextColumn get processedImagePath => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  TextColumn get filterApplied => text().withDefault(const Constant('none'))();
  TextColumn get cropPoints => text().nullable()(); // JSON: [x1,y1,x2,y2,x3,y3,x4,y4]
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  IntColumn get sizeBytes => integer()();
  IntColumn get createdAt => integer()();
}

class OcrResults extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pageId => integer().references(DocumentPages, #id)();
  TextColumn get extractedText => text()();
  TextColumn get textBlocksJson => text()(); // JSON array of positioned text blocks
  TextColumn get language => text().withDefault(const Constant('en'))();
  IntColumn get processedAt => integer()();
}
