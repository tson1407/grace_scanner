import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables.dart';

part 'document_dao.g.dart';

@DriftAccessor(tables: [Documents, DocumentPages])
class DocumentDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentDaoMixin {
  DocumentDao(super.db);

  /// Get all documents ordered by most recently updated.
  Future<List<Document>> getAllDocuments() {
    return (select(documents)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }

  /// Watch all documents (reactive).
  Stream<List<Document>> watchAllDocuments() {
    return (select(documents)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
  }

  /// Get a single document by ID.
  Future<Document> getDocument(int id) {
    return (select(documents)..where((t) => t.id.equals(id))).getSingle();
  }

  /// Insert a new document and return its ID.
  Future<int> insertDocument(DocumentsCompanion doc) {
    return into(documents).insert(doc);
  }

  /// Update a document.
  Future<bool> updateDocument(DocumentsCompanion doc) {
    return (update(documents)..where((t) => t.id.equals(doc.id.value)))
        .write(doc)
        .then((rows) => rows > 0);
  }

  /// Delete a document and cascade-delete its pages.
  Future<void> deleteDocument(int id) async {
    await (delete(documentPages)..where((t) => t.documentId.equals(id))).go();
    await (delete(documents)..where((t) => t.id.equals(id))).go();
  }

  /// Search documents by title.
  Future<List<Document>> searchByTitle(String query) {
    return (select(documents)
          ..where((t) => t.title.like('%$query%'))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .get();
  }
}
