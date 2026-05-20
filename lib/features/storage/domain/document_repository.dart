import '../../../core/errors/result.dart';
import 'document.dart';
import 'document_page.dart';

/// Abstract document repository interface — domain layer.
abstract class DocumentRepository {
  /// Get all documents ordered by most recently updated.
  Future<Result<List<Document>>> getAllDocuments();

  /// Get a single document by ID.
  Future<Result<Document>> getDocument(int id);

  /// Create a new document and return it with assigned ID.
  Future<Result<Document>> createDocument(String title);

  /// Update a document.
  Future<Result<Document>> updateDocument(Document document);

  /// Delete a document and all its pages.
  Future<Result<void>> deleteDocument(int id);

  /// Get all pages for a document.
  Future<Result<List<DocumentPage>>> getPages(int documentId);

  /// Add a page to a document.
  Future<Result<DocumentPage>> addPage(DocumentPage page);

  /// Update a page.
  Future<Result<DocumentPage>> updatePage(DocumentPage page);

  /// Delete a page.
  Future<Result<void>> deletePage(int pageId);

  /// Reorder pages within a document.
  Future<Result<void>> reorderPages(int documentId, List<int> pageIds);
}
