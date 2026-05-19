import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';


import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _analyticsEnabled = true;
  String _defaultQuality = 'High';
  String _defaultFilter = 'Original';
  bool _autoEdgeDetection = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // ── Scan Settings ──
          _SectionHeader(title: 'Scan Settings'),
          const SizedBox(height: AppSizes.sm),
          _SettingsCard(
            children: [
              _DropdownTile(
                icon: Icons.high_quality_outlined,
                title: 'Default Quality',
                value: _defaultQuality,
                options: const ['Low', 'Medium', 'High'],
                onChanged: (v) => setState(() => _defaultQuality = v),
              ),
              const Divider(height: 1),
              _DropdownTile(
                icon: Icons.filter_outlined,
                title: 'Default Filter',
                value: _defaultFilter,
                options: const ['Original', 'Grayscale', 'B&W', 'Sharpen'],
                onChanged: (v) => setState(() => _defaultFilter = v),
              ),
              const Divider(height: 1),
              _SwitchTile(
                icon: Icons.auto_fix_high_outlined,
                title: 'Auto Edge Detection',
                subtitle: 'Detect document edges in real-time',
                value: _autoEdgeDetection,
                onChanged: (v) => setState(() => _autoEdgeDetection = v),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.03),

          const SizedBox(height: AppSizes.lg),

          // ── Privacy ──
          _SectionHeader(title: 'Privacy'),
          const SizedBox(height: AppSizes.sm),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.analytics_outlined,
                title: 'Usage Analytics',
                subtitle: 'Help improve ScanFlow with anonymous data',
                value: _analyticsEnabled,
                onChanged: (v) => setState(() => _analyticsEnabled = v),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.03),

          const SizedBox(height: AppSizes.lg),

          // ── Storage ──
          _SectionHeader(title: 'Storage'),
          const SizedBox(height: AppSizes.sm),
          _SettingsCard(
            children: [
              _InfoTile(
                icon: Icons.storage_outlined,
                title: 'Storage Used',
                trailing: '24.3 MB',
              ),
              const Divider(height: 1),
              _ActionTile(
                icon: Icons.delete_sweep_outlined,
                title: 'Clear Cache',
                subtitle: 'Remove temporary files',
                onTap: () {},
              ),
            ],
          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.03),

          const SizedBox(height: AppSizes.lg),

          // ── About ──
          _SectionHeader(title: 'About'),
          const SizedBox(height: AppSizes.sm),
          _SettingsCard(
            children: [
              _InfoTile(
                icon: Icons.info_outline,
                title: 'Version',
                trailing: '1.0.0 (1)',
              ),
              const Divider(height: 1),
              _ActionTile(
                icon: Icons.description_outlined,
                title: 'Licenses',
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'ScanFlow',
                  applicationVersion: '1.0.0',
                ),
              ),
              const Divider(height: 1),
              _ActionTile(
                icon: Icons.star_outline,
                title: 'Rate App',
                onTap: () {},
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.03),

          const SizedBox(height: AppSizes.xxl),
        ],
      ),
    );
  }
}

// ── Section Header ──
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
    );
  }
}

// ── Settings Card Container ──
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

// ── Switch Tile ──
class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.labelSmall)
          : null,
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
    );
  }
}

// ── Dropdown Tile ──
class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: theme.textTheme.titleSmall),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        style: theme.textTheme.bodyMedium,
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
    );
  }
}

// ── Info Tile ──
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: theme.textTheme.titleSmall),
      trailing: Text(trailing, style: theme.textTheme.bodyMedium),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
    );
  }
}

// ── Action Tile ──
class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.labelSmall)
          : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
    );
  }
}
