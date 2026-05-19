

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/routes.dart';

class CropScreen extends StatefulWidget {
  const CropScreen({super.key});

  @override
  State<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  // Normalized corner positions (0-1)
  List<Offset> _corners = [
    const Offset(0.1, 0.08),
    const Offset(0.9, 0.05),
    const Offset(0.92, 0.92),
    const Offset(0.08, 0.95),
  ];

  int? _activeCorner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  const Spacer(),
                  Text('Adjust Crop', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Reset corners
                      setState(() {
                        _corners = [
                          const Offset(0.1, 0.08),
                          const Offset(0.9, 0.05),
                          const Offset(0.92, 0.92),
                          const Offset(0.08, 0.95),
                        ];
                      });
                    },
                    child: const Icon(Icons.refresh_rounded, color: Colors.white),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
            ),

            // ── Crop Area ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.biggest;

                    return GestureDetector(
                      onPanStart: (details) {
                        final pos = Offset(
                          details.localPosition.dx / size.width,
                          details.localPosition.dy / size.height,
                        );
                        // Find nearest corner
                        int nearest = 0;
                        double minDist = double.infinity;
                        for (int i = 0; i < 4; i++) {
                          final d = (pos - _corners[i]).distance;
                          if (d < minDist && d < 0.15) {
                            minDist = d;
                            nearest = i;
                          }
                        }
                        if (minDist < 0.15) {
                          setState(() => _activeCorner = nearest);
                        }
                      },
                      onPanUpdate: (details) {
                        if (_activeCorner == null) return;
                        setState(() {
                          _corners[_activeCorner!] = Offset(
                            (details.localPosition.dx / size.width).clamp(0.0, 1.0),
                            (details.localPosition.dy / size.height).clamp(0.0, 1.0),
                          );
                        });
                      },
                      onPanEnd: (_) => setState(() => _activeCorner = null),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Mock scanned image
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade800,
                                  Colors.grey.shade700,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.description_outlined, size: 80,
                                    color: Colors.white.withValues(alpha: 0.15),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Scanned Document',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Crop overlay
                          CustomPaint(
                            painter: _CropOverlayPainter(
                              corners: _corners,
                              activeCorner: _activeCorner,
                            ),
                          ),

                          // Corner handles
                          for (int i = 0; i < 4; i++)
                            Positioned(
                              left: _corners[i].dx * size.width - AppSizes.cropHandleSize / 2,
                              top: _corners[i].dy * size.height - AppSizes.cropHandleSize / 2,
                              child: _CropHandle(isActive: _activeCorner == i),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(duration: 400.ms).scaleXY(begin: 0.97),
            ),

            // ── Bottom Buttons ──
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  // Rotate
                  _actionButton(Icons.rotate_right_rounded, 'Rotate', () {}),
                  const Spacer(),
                  // Retake
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: const Text('Retake'),
                  ),
                  const SizedBox(width: AppSizes.sm),
                  // Confirm
                  FilledButton(
                    onPressed: () => context.push(Routes.enhancement),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: const Text('Confirm'),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _CropHandle extends StatelessWidget {
  const _CropHandle({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.cropHandleSize,
      height: AppSizes.cropHandleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primary : Colors.white,
        border: Border.all(
          color: isActive ? AppColors.primaryLight : AppColors.primary,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isActive ? 0.6 : 0.3),
            blurRadius: isActive ? 12 : 6,
          ),
        ],
      ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  _CropOverlayPainter({required this.corners, this.activeCorner});

  final List<Offset> corners;
  final int? activeCorner;

  @override
  void paint(Canvas canvas, Size size) {
    final points = corners
        .map((c) => Offset(c.dx * size.width, c.dy * size.height))
        .toList();

    // Semi-transparent overlay outside crop area
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final cropPath = Path()
      ..moveTo(points[0].dx, points[0].dy)
      ..lineTo(points[1].dx, points[1].dy)
      ..lineTo(points[2].dx, points[2].dy)
      ..lineTo(points[3].dx, points[3].dy)
      ..close();

    final overlayPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(fullRect),
      cropPath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: 0.5),
    );

    // Crop border
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(cropPath, borderPaint);

    // Grid lines (rule of thirds)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 0.5;

    for (int i = 1; i < 3; i++) {
      final t = i / 3;
      final left = Offset.lerp(points[0], points[3], t)!;
      final right = Offset.lerp(points[1], points[2], t)!;
      canvas.drawLine(left, right, gridPaint);

      final top = Offset.lerp(points[0], points[1], t)!;
      final bottom = Offset.lerp(points[3], points[2], t)!;
      canvas.drawLine(top, bottom, gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CropOverlayPainter oldDelegate) => true;
}
