import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/routes.dart';
import 'widgets/document_card.dart';
import 'widgets/empty_state.dart';

/// Mock document data for UI development.
class _MockDoc {
  final String id;
  final String title;
  final int pageCount;
  final String date;
  final Color color;

  const _MockDoc(this.id, this.title, this.pageCount, this.date, this.color);
}

const _mockDocs = [
  _MockDoc('1', 'Tax Return 2025', 4, 'May 18, 2026', AppColors.primary),
  _MockDoc('2', 'Rental Agreement', 12, 'May 15, 2026', AppColors.secondary),
  _MockDoc('3', 'Passport Copy', 1, 'May 10, 2026', AppColors.info),
  _MockDoc('4', 'Invoice #4821', 2, 'May 8, 2026', AppColors.warning),
  _MockDoc('5', 'Meeting Notes', 3, 'May 5, 2026', AppColors.error),
  _MockDoc('6', 'Business Card', 1, 'May 1, 2026', AppColors.primaryLight),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showEmptyState = false; // Toggle to demo empty state

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.md, AppSizes.md, 0,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    // Logo & Title
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text('ScanFlow', style: theme.textTheme.headlineMedium),
                    const Spacer(),
                    // Search
                    _HeaderIconButton(
                      icon: Icons.search_rounded,
                      onPressed: () {},
                    ),
                    const SizedBox(width: AppSizes.xs),
                    // Settings
                    _HeaderIconButton(
                      icon: Icons.settings_outlined,
                      onPressed: () => context.push(Routes.settings),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
              ),
            ),

            // ── Stats Bar ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.lg, AppSizes.md, AppSizes.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: _StatsBar(docCount: _showEmptyState ? 0 : _mockDocs.length),
              ),
            ),

            // ── Section Header ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text('Recent Documents', style: theme.textTheme.titleMedium),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _showEmptyState = !_showEmptyState),
                      child: Text(
                        _showEmptyState ? 'Show Docs' : 'Show Empty',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Content ──
            if (_showEmptyState)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  onScanPressed: () => context.push(Routes.camera),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                sliver: AnimationLimiter(
                  child: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSizes.sm,
                      crossAxisSpacing: AppSizes.sm,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = _mockDocs[index];
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          columnCount: 2,
                          duration: const Duration(milliseconds: 400),
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: DocumentCard(
                                title: doc.title,
                                pageCount: doc.pageCount,
                                date: doc.date,
                                thumbnailColor: doc.color,
                                onTap: () => context.push('/document/${doc.id}'),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _mockDocs.length,
                    ),
                  ),
                ),
              ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // ── FAB ──
      floatingActionButton: _ScanFab(
        onPressed: () => context.push(Routes.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ── Header Icon Button ──
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: AppSizes.iconMd),
        ),
      ),
    );
  }
}

// ── Stats Bar ──
class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.docCount});

  final int docCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkSurfaceVariant, AppColors.darkCard]
              : [AppColors.lightSurfaceVariant, AppColors.lightCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.description_outlined,
            value: '$docCount',
            label: 'Documents',
            color: AppColors.primary,
          ),
          _statDivider(context),
          _StatItem(
            icon: Icons.pages_outlined,
            value: '${docCount * 3}',
            label: 'Pages',
            color: AppColors.secondary,
          ),
          _statDivider(context),
          const _StatItem(
            icon: Icons.storage_outlined,
            value: '24 MB',
            label: 'Storage',
            color: AppColors.info,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05);
  }

  Widget _statDivider(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSizes.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: theme.textTheme.titleSmall),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Scan FAB ──
class _ScanFab extends StatelessWidget {
  const _ScanFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.scanButtonGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        key: const Key('fab_scan'),
        onPressed: onPressed,
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: const Icon(Icons.document_scanner_rounded, size: 28),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(begin: 1.0, end: 1.05, duration: 1500.ms, curve: Curves.easeInOut);
  }
}
