import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.onScanPressed});

  final VoidCallback? onScanPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.secondary.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                size: 56,
                color: AppColors.primary.withValues(alpha: 0.7),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1.0, end: 1.05, duration: 2000.ms)
                .then()
                .shimmer(duration: 1500.ms, color: AppColors.primary.withValues(alpha: 0.1)),

            const SizedBox(height: AppSizes.lg),

            Text(
              'No documents yet',
              style: theme.textTheme.headlineSmall,
            ),

            const SizedBox(height: AppSizes.sm),

            Text(
              'Tap the scan button to capture\nyour first document',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: AppSizes.xl),

            if (onScanPressed != null)
              FilledButton.icon(
                onPressed: onScanPressed,
                icon: const Icon(Icons.camera_alt_rounded),
                label: const Text('Start Scanning'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}
