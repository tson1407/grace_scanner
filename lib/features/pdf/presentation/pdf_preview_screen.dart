import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/routes.dart';

class _MockPage {
  final int index;
  final Color color;
  _MockPage(this.index, this.color);
}

class PdfPreviewScreen extends StatefulWidget {
  const PdfPreviewScreen({super.key});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late List<_MockPage> _pages;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _pages = [
      _MockPage(1, AppColors.primary),
      _MockPage(2, AppColors.secondary),
      _MockPage(3, AppColors.info),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Rename'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Page info ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    '${_pages.length} pages',
                    style: theme.textTheme.labelMedium?.copyWith(color: AppColors.primary),
                  ),
                ),
                const Spacer(),
                Text(
                  'Drag to reorder',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ),

          // ── Reorderable Page List ──
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              itemCount: _pages.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  final item = _pages.removeAt(oldIndex);
                  _pages.insert(newIndex, item);
                });
              },
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final t = Curves.easeInOut.transform(animation.value);
                    return Material(
                      color: Colors.transparent,
                      elevation: 8 * t,
                      shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final page = _pages[index];

                return Container(
                  key: ValueKey(page.index),
                  margin: const EdgeInsets.only(bottom: AppSizes.sm),
                  child: Material(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.sm),
                      child: Row(
                        children: [
                          // Page thumbnail
                          Container(
                            width: 56,
                            height: 72,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                              gradient: LinearGradient(
                                colors: [
                                  page.color.withValues(alpha: 0.15),
                                  page.color.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.description_outlined,
                                size: 24,
                                color: page.color.withValues(alpha: 0.4),
                              ),
                            ),
                          ),

                          const SizedBox(width: AppSizes.md),

                          // Page info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Page ${index + 1}', style: theme.textTheme.titleSmall),
                                const SizedBox(height: 2),
                                Text('Scanned • Enhanced', style: theme.textTheme.labelSmall),
                              ],
                            ),
                          ),

                          // Delete button
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                            onPressed: () {
                              setState(() => _pages.removeAt(index));
                            },
                          ),

                          // Drag handle
                          const Icon(Icons.drag_handle_rounded, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.05);
              },
            ),
          ),

          // ── Bottom Action Bar ──
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  _ActionChip(
                    icon: Icons.print_outlined,
                    label: 'Print',
                    onTap: () {},
                  ),
                  const SizedBox(width: AppSizes.sm),
                  _ActionChip(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: () {},
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _isExporting
                        ? null
                        : () async {
                            final router = GoRouter.of(context);
                            setState(() => _isExporting = true);
                            await Future.delayed(const Duration(seconds: 1));
                            if (!mounted) return;
                            setState(() => _isExporting = false);
                            router.go(Routes.home);
                          },
                    icon: _isExporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: Text(_isExporting ? 'Exporting...' : 'Export PDF'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: AppSizes.xs),
              Text(label, style: theme.textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
