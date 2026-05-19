import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/router/routes.dart';

class _Filter {
  final String name;
  final IconData icon;
  final List<Color> gradientColors;

  const _Filter(this.name, this.icon, this.gradientColors);
}

const _filters = [
  _Filter('Original', Icons.image_outlined, [Color(0xFF3B3F54), Color(0xFF4A4F68)]),
  _Filter('Grayscale', Icons.invert_colors, [Color(0xFF4A4A4A), Color(0xFF6A6A6A)]),
  _Filter('B&W', Icons.contrast, [Color(0xFF1A1A1A), Color(0xFF555555)]),
  _Filter('Sharpen', Icons.deblur, [Color(0xFF2D4A5E), Color(0xFF3D6A8E)]),
  _Filter('No Shadow', Icons.wb_sunny_outlined, [Color(0xFF4A3D2D), Color(0xFF6E5A3D)]),
];

class EnhancementScreen extends StatefulWidget {
  const EnhancementScreen({super.key});

  @override
  State<EnhancementScreen> createState() => _EnhancementScreenState();
}

class _EnhancementScreenState extends State<EnhancementScreen> {
  int _selectedFilter = 0;

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
                  Text(
                    'Enhance',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ).animate().fadeIn(duration: 300.ms),
            ),

            // ── Image Preview ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    gradient: LinearGradient(
                      colors: _filters[_selectedFilter].gradientColors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _filters[_selectedFilter].gradientColors.first.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _filters[_selectedFilter].name,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            const SizedBox(height: AppSizes.md),

            // ── Filter Selector ──
            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSizes.sm),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == index;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: AppSizes.filterThumbSize,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        gradient: LinearGradient(
                          colors: filter.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            filter.icon,
                            color: Colors.white.withValues(alpha: isSelected ? 1 : 0.6),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            filter.name,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: isSelected ? 1 : 0.6),
                              fontSize: 10,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate(target: isSelected ? 1 : 0)
                      .scaleXY(begin: 1.0, end: 1.08, duration: 200.ms);
                },
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

            // ── Bottom Bar ──
            Padding(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Row(
                children: [
                  // Add another page
                  OutlinedButton.icon(
                    onPressed: () => context.pushReplacement(Routes.camera),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Page'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Done
                  FilledButton.icon(
                    onPressed: () {
                      // Go back to home (simulate save)
                      context.go(Routes.home);
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Done'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg, vertical: AppSizes.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.15),
            ),
          ],
        ),
      ),
    );
  }
}
