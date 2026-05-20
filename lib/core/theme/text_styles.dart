import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Standalone text style constants for use outside of theme context.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1 = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static TextStyle heading2 = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static TextStyle heading3 = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static TextStyle label = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
