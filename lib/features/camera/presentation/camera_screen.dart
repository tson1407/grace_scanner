import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/routes.dart';
import 'widgets/camera_widgets.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _edgeAnimController;
  int _capturedPages = 0;

  @override
  void initState() {
    super.initState();
    _edgeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _edgeAnimController.dispose();
    super.dispose();
  }

  void _onCapture() {
    setState(() => _capturedPages++);
    // Simulate capture → navigate to crop
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) context.push(Routes.crop);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Camera Preview Placeholder ──
            Container(
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
                child: Column(
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
            ),

            // ── Edge Detection Overlay ──
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
                  const FlashToggle(),
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
                  if (_capturedPages > 0)
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSizes.md),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      ),
                      child: Text(
                        '$_capturedPages page${_capturedPages > 1 ? 's' : ''} captured',
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
                      CaptureButton(onPressed: _onCapture),
                      // Multi-page done
                      _capturedPages > 0
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
