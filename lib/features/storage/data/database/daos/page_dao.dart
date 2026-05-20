import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'page_dao.g.dart';

@DriftAccessor(tables: [DocumentPages])
class PageDao extends DatabaseAccessor<AppDatabase> with _$PageDaoMixin {
  PageDao(super.db);

  /// Get all pages for a document ordered by page order.
  Future<List<DocumentPage>> getPages(int documentId) {
    return (select(documentPages)
          ..where((t) => t.documentId.equals(documentId))
          ..orderBy([(t) => OrderingTerm.asc(t.pageOrder)]))
        .get();
  }

  /// Watch pages for a document (reactive).
  Stream<List<DocumentPage>> watchPages(int documentId) {
    return (select(documentPages)
          ..where((t) => t.documentId.equals(documentId))
          ..orderBy([(t) => OrderingTerm.asc(t.pageOrder)]))
        .watch();
  }

  /// Insert a new page and return its ID.
  Future<int> insertPage(DocumentPagesCompanion page) {
    return into(documentPages).insert(page);
  }

  /// Update a page.
  Future<bool> updatePage(DocumentPagesCompanion page) {
    return (update(documentPages)..where((t) => t.id.equals(page.id.value)))
        .write(page)
        .then((rows) => rows > 0);
  }

  /// Delete a page.
  Future<int> deletePage(int id) {
    return (delete(documentPages)..where((t) => t.id.equals(id))).go();
  }

  /// Reorder pages — update page_order for each page ID.
  Future<void> reorderPages(List<int> pageIds) async {
    await transaction(() async {
      for (var i = 0; i < pageIds.length; i++) {
        await (update(documentPages)..where((t) => t.id.equals(pageIds[i])))
            .write(DocumentPagesCompanion(pageOrder: Value(i)));
      }
    });
  }

  /// Count pages for a document.
  Future<int> countPages(int documentId) async {
    final count = documentPages.id.count();
    final query = selectOnly(documentPages)
      ..addColumns([count])
      ..where(documentPages.documentId.equals(documentId));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }
}
