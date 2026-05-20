import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/camera_state.dart';

/// Animated capture button with pulsing ring.
class CaptureButton extends StatelessWidget {
  const CaptureButton({
    super.key,
    required this.onPressed,
    this.isCapturing = false,
  });

  final VoidCallback onPressed;
  final bool isCapturing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isCapturing ? null : onPressed,
      child: SizedBox(
        width: AppSizes.captureButtonOuter,
        height: AppSizes.captureButtonOuter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulsing ring
            Container(
              width: AppSizes.captureButtonOuter,
              height: AppSizes.captureButtonOuter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1.0, end: 1.08, duration: 1200.ms),

            // Inner filled circle or spinner
            if (isCapturing)
              const SizedBox(
                width: AppSizes.captureButtonInner,
                height: AppSizes.captureButtonInner,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            else
              Container(
                width: AppSizes.captureButtonInner,
                height: AppSizes.captureButtonInner,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Flash toggle button — displays current mode, calls onToggle.
class FlashToggleButton extends StatelessWidget {
  const FlashToggleButton({
    super.key,
    required this.mode,
    required this.onToggle,
  });

  final FlashMode mode;
  final VoidCallback onToggle;

  static const _icons = {
    FlashMode.off: Icons.flash_off_rounded,
    FlashMode.on: Icons.flash_on_rounded,
    FlashMode.auto: Icons.flash_auto_rounded,
  };
  static const _labels = {
    FlashMode.off: 'Off',
    FlashMode.on: 'On',
    FlashMode.auto: 'Auto',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icons[mode], color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Text(
              _labels[mode] ?? 'Off',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mock edge overlay painted on camera preview.
class EdgeOverlayPainter extends CustomPainter {
  EdgeOverlayPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.7 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeJoin = StrokeJoin.round;

    // Simulated document contour
    final margin = size.width * 0.12;
    final path = Path()
      ..moveTo(margin, margin * 1.5)
      ..lineTo(size.width - margin, margin)
      ..lineTo(size.width - margin * 0.8, size.height - margin)
      ..lineTo(margin * 0.8, size.height - margin * 1.2)
      ..close();

    canvas.drawPath(path, paint);

    // Corner dots
    final dotPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    final corners = [
      Offset(margin, margin * 1.5),
      Offset(size.width - margin, margin),
      Offset(size.width - margin * 0.8, size.height - margin),
      Offset(margin * 0.8, size.height - margin * 1.2),
    ];

    for (final corner in corners) {
      canvas.drawCircle(corner, 6 * progress, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant EdgeOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
