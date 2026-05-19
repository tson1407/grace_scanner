import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';


import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

const _mockOcrText = '''
INVOICE #4821

Date: May 8, 2026
Due: June 8, 2026

Bill To:
Acme Corporation
123 Business Ave, Suite 400
San Francisco, CA 94102

Description                Amount
──────────────────────────────
Consulting Services       \$2,500.00
Design Review             \$1,200.00
Implementation Support    \$3,800.00
──────────────────────────────
Subtotal                  \$7,500.00
Tax (8.5%)                  \$637.50
──────────────────────────────
Total                     \$8,137.50

Payment Terms: Net 30
''';

class OcrResultScreen extends StatefulWidget {
  const OcrResultScreen({super.key});

  @override
  State<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends State<OcrResultScreen> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extracted Text'),
        actions: [
          IconButton(
            icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded),
            tooltip: 'Copy all',
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: _mockOcrText));
              setState(() => _copied = true);
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) setState(() => _copied = false);
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Confidence badge ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    'High confidence • English',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideX(begin: -0.05),

            const SizedBox(height: AppSizes.md),

            // ── Copy feedback ──
            if (_copied)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.sm),
                margin: const EdgeInsets.only(bottom: AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: AppSizes.xs),
                    Text(
                      'Text copied to clipboard',
                      style: theme.textTheme.labelMedium?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: -0.2),

            // ── OCR Text ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: SelectableText(
                _mockOcrText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  height: 1.6,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05),

            const SizedBox(height: AppSizes.lg),

            // ── Actions ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.translate, size: 18),
                    label: const Text('Translate'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('Share Text'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),
          ],
        ),
      ),
    );
  }
}
