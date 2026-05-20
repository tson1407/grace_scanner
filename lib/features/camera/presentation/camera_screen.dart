import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/routes.dart';
import '../domain/camera_state.dart';
import 'camera_controller_provider.dart';
import 'widgets/camera_widgets.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _edgeAnimController;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _edgeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _edgeAnimController.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      if (mounted) {
        ref.read(cameraControllerProvider.notifier).initializeCamera();
      }
    } else {
      setState(() => _permissionDenied = true);
    }
  }

  void _onCapture() {
    ref.read(cameraControllerProvider.notifier).capture();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Camera Preview ──
            _buildPreview(cameraState),

            // ── Edge Detection Overlay ──
            if (cameraState.status == CameraStatus.ready)
              AnimatedBuilder(
                animation: _edgeAnimController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: EdgeOverlayPainter(
                      progress: _edgeAnimController.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),

            // ── Top Bar ──
            Positioned(
              top: AppSizes.sm,
              left: AppSizes.md,
              right: AppSizes.md,
              child: Row(
                children: [
                  _circleButton(Icons.close_rounded, () => context.pop()),
                  const Spacer(),
                  FlashToggleButton(
                    mode: cameraState.flashMode,
                    onToggle: () {
                      ref
                          .read(cameraControllerProvider.notifier)
                          .toggleFlash();
                    },
                  ),
                  const SizedBox(width: AppSizes.sm),
                  _circleButton(Icons.grid_3x3_rounded, () {}),
                ],
              ).animate().fadeIn(duration: 400.ms),
            ),

            // ── Bottom Controls ──
            Positioned(
              bottom: AppSizes.xl,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Page counter
                  if (cameraState.capturedPages.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.md),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        borderRadius:
                            BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        '${cameraState.capturedPages.length} page${cameraState.capturedPages.length > 1 ? 's' : ''} captured',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ).animate().fadeIn().slideY(begin: 0.3),

                  // Controls row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Gallery import
                      _circleButton(Icons.photo_library_outlined, () {}),
                      // Capture
                      CaptureButton(
                        onPressed: cameraState.status == CameraStatus.ready
                            ? _onCapture
                            : () {},
                        isCapturing:
                            cameraState.status == CameraStatus.capturing,
                      ),
                      // Multi-page done
                      cameraState.capturedPages.isNotEmpty
                          ? _circleButton(
                              Icons.check_rounded,
                              () => context.push(Routes.pdfPreview),
                            )
                          : const SizedBox(width: 44),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                ],
              ),
            ),

            // ── Error overlay ──
            if (cameraState.status == CameraStatus.error)
              _buildErrorOverlay(cameraState.errorMessage),

            // ── Permission denied overlay ──
            if (_permissionDenied) _buildPermissionDenied(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(CameraState cameraState) {
    if (cameraState.textureId != null &&
        cameraState.status != CameraStatus.error) {
      return Texture(textureId: cameraState.textureId!);
    }

    // Placeholder while initializing
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: cameraState.status == CameraStatus.initializing
            ? const CircularProgressIndicator(color: Colors.white54)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    'Camera Preview',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorOverlay(String? message) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSizes.md),
            Text(
              message ?? 'Camera error',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            TextButton(
              onPressed: () {
                ref
                    .read(cameraControllerProvider.notifier)
                    .initializeCamera();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDenied() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_outlined,
                color: Colors.white54, size: 48),
            const SizedBox(height: AppSizes.md),
            const Text(
              'Camera access is required\nto scan documents.',
              style: TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.lg),
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.15),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
