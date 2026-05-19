import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/camera/presentation/camera_screen.dart';
import '../../features/ocr/presentation/ocr_result_screen.dart';
import '../../features/pdf/presentation/pdf_preview_screen.dart';
import '../../features/scanner/presentation/crop_screen.dart';
import '../../features/scanner/presentation/enhancement_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/storage/presentation/document_detail_screen.dart';
import '../../features/storage/presentation/home_screen.dart';
import 'routes.dart';

final appRouter = GoRouter(
  initialLocation: Routes.home,
  routes: [
    GoRoute(
      path: Routes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: Routes.camera,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: const CameraScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: Routes.crop,
      builder: (context, state) => const CropScreen(),
    ),
    GoRoute(
      path: Routes.enhancement,
      builder: (context, state) => const EnhancementScreen(),
    ),
    GoRoute(
      path: Routes.pdfPreview,
      builder: (context, state) => const PdfPreviewScreen(),
    ),
    GoRoute(
      path: Routes.documentDetail,
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DocumentDetailScreen(documentId: id);
      },
    ),
    GoRoute(
      path: Routes.ocrResult,
      builder: (context, state) => const OcrResultScreen(),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
