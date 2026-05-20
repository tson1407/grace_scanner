import 'package:drift/drift.dart';

import '../../../core/errors/app_error.dart';
import '../../../core/errors/result.dart';
import '../domain/document.dart' as domain;
import '../domain/document_page.dart' as domain;
import '../domain/document_repository.dart';
import 'database/app_database.dart';
import 'database/daos/document_dao.dart';
import 'database/daos/page_dao.dart';

/// Implements [DocumentRepository] using Drift DAOs.
class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl(this._documentDao, this._pageDao);

  final DocumentDao _documentDao;
  final PageDao _pageDao;

  @override
  Future<Result<List<domain.Document>>> getAllDocuments() async {
    try {
      final rows = await _documentDao.getAllDocuments();
      return Success(rows.map(_mapDocument).toList());
    } catch (e) {
      return Failure(StorageError('Failed to load documents: $e'));
    }
  }

  @override
  Future<Result<domain.Document>> getDocument(int id) async {
    try {
      final row = await _documentDao.getDocument(id);
      return Success(_mapDocument(row));
    } catch (e) {
      return Failure(StorageError('Document not found: $e'));
    }
  }

  @override
  Future<Result<domain.Document>> createDocument(String title) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final id = await _documentDao.insertDocument(
        DocumentsCompanion.insert(
          title: title,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final row = await _documentDao.getDocument(id);
      return Success(_mapDocument(row));
    } catch (e) {
      return Failure(StorageError('Failed to create document: $e'));
    }
  }

  @override
  Future<Result<domain.Document>> updateDocument(domain.Document document) async {
    try {
      await _documentDao.updateDocument(
        DocumentsCompanion(
          id: Value(document.id),
          title: Value(document.title),
          thumbnailPath: Value(document.thumbnailPath),
          pageCount: Value(document.pageCount),
          totalSizeBytes: Value(document.totalSizeBytes),
          tags: Value(document.tags),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
      final row = await _documentDao.getDocument(document.id);
      return Success(_mapDocument(row));
    } catch (e) {
      return Failure(StorageError('Failed to update document: $e'));
    }
  }

  @override
  Future<Result<void>> deleteDocument(int id) async {
    try {
      await _documentDao.deleteDocument(id);
      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to delete document: $e'));
    }
  }

  @override
  Future<Result<List<domain.DocumentPage>>> getPages(int documentId) async {
    try {
      final rows = await _pageDao.getPages(documentId);
      return Success(rows.map(_mapPage).toList());
    } catch (e) {
      return Failure(StorageError('Failed to load pages: $e'));
    }
  }

  @override
  Future<Result<domain.DocumentPage>> addPage(domain.DocumentPage page) async {
    try {
      final id = await _pageDao.insertPage(
        DocumentPagesCompanion.insert(
          documentId: page.documentId,
          pageOrder: page.pageOrder,
          originalImagePath: page.originalImagePath,
          processedImagePath: Value(page.processedImagePath),
          thumbnailPath: Value(page.thumbnailPath),
          filterApplied: Value(page.filterApplied),
          cropPoints: Value(page.cropPoints),
          width: page.width,
          height: page.height,
          sizeBytes: page.sizeBytes,
          createdAt: page.createdAt.millisecondsSinceEpoch,
        ),
      );
      return Success(page.copyWith(id: id));
    } catch (e) {
      return Failure(StorageError('Failed to add page: $e'));
    }
  }

  @override
  Future<Result<domain.DocumentPage>> updatePage(domain.DocumentPage page) async {
    try {
      await _pageDao.updatePage(
        DocumentPagesCompanion(
          id: Value(page.id),
          processedImagePath: Value(page.processedImagePath),
          thumbnailPath: Value(page.thumbnailPath),
          filterApplied: Value(page.filterApplied),
          cropPoints: Value(page.cropPoints),
        ),
      );
      return Success(page);
    } catch (e) {
      return Failure(StorageError('Failed to update page: $e'));
    }
  }

  @override
  Future<Result<void>> deletePage(int pageId) async {
    try {
      await _pageDao.deletePage(pageId);
      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to delete page: $e'));
    }
  }

  @override
  Future<Result<void>> reorderPages(int documentId, List<int> pageIds) async {
    try {
      await _pageDao.reorderPages(pageIds);
      return const Success(null);
    } catch (e) {
      return Failure(StorageError('Failed to reorder pages: $e'));
    }
  }

  // ── Mappers ──

  domain.Document _mapDocument(Document row) {
    return domain.Document(
      id: row.id,
      title: row.title,
      thumbnailPath: row.thumbnailPath,
      pageCount: row.pageCount,
      totalSizeBytes: row.totalSizeBytes,
      tags: row.tags,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
    );
  }

  domain.DocumentPage _mapPage(DocumentPage row) {
    return domain.DocumentPage(
      id: row.id,
      documentId: row.documentId,
      pageOrder: row.pageOrder,
      originalImagePath: row.originalImagePath,
      processedImagePath: row.processedImagePath,
      thumbnailPath: row.thumbnailPath,
      filterApplied: row.filterApplied,
      cropPoints: row.cropPoints,
      width: row.width,
      height: row.height,
      sizeBytes: row.sizeBytes,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    );
  }
}
