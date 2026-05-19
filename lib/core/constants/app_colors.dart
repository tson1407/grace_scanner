import 'package:flutter/material.dart';

/// Curated color palette for ScanFlow.
/// Dark-first design with harmonious light mode counterpart.
class AppColors {
  AppColors._();

  // ── Brand ──
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9D97FF);
  static const Color primaryDark = Color(0xFF4A42E0);

  static const Color secondary = Color(0xFF00D9A6);
  static const Color secondaryLight = Color(0xFF5FFFCE);
  static const Color secondaryDark = Color(0xFF00A87E);

  // ── Dark Theme ──
  static const Color darkBg = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D27);
  static const Color darkSurfaceVariant = Color(0xFF242834);
  static const Color darkCard = Color(0xFF1E2230);
  static const Color darkBorder = Color(0xFF2E3344);

  static const Color darkTextPrimary = Color(0xFFF0F0F5);
  static const Color darkTextSecondary = Color(0xFF9CA3B4);
  static const Color darkTextTertiary = Color(0xFF5C6478);

  // ── Light Theme ──
  static const Color lightBg = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F1F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E5EE);

  static const Color lightTextPrimary = Color(0xFF1A1D27);
  static const Color lightTextSecondary = Color(0xFF5C6478);
  static const Color lightTextTertiary = Color(0xFF9CA3B4);

  // ── Semantic ──
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF60A5FA);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scanButtonGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
