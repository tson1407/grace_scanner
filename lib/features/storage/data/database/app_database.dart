import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/document_dao.dart';
import 'daos/page_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Documents, DocumentPages, OcrResults], daos: [DocumentDao, PageDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For testing — inject a custom executor.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // Create indices for common queries
          await customStatement(
              'CREATE INDEX idx_documents_updated ON documents(updated_at DESC)');
          await customStatement(
              'CREATE INDEX idx_pages_document ON document_pages(document_id, page_order)');
          await customStatement(
              'CREATE INDEX idx_ocr_page ON ocr_results(page_id)');
        },
        onUpgrade: (m, from, to) async {
          // Stepwise migrations when schema changes
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'scanflow.db'));
    return NativeDatabase.createInBackground(file);
  });
}
