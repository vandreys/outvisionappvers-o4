import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bg        = Color(0xFFFFFFFF);
  static const Color ink       = Color(0xFF14110E);
  static const Color body      = Color(0xFF34302A);
  static const Color muted     = Color(0xFF8A847A);
  static const Color muted2    = Color(0xFF9A948A);
  static const Color faint     = Color(0xFFB6B0A6);
  static       Color hairline  = const Color(0xFF14110E).withValues(alpha: 0.12);

  // Aliases for backward compatibility
  static const Color fg        = Color(0xFF14110E);   // = ink
  static const Color fg2       = Color(0xFF34302A);   // = body
  static const Color fg3       = Color(0xFF9A948A);   // = muted2
  static       Color border    = const Color(0xFF14110E).withValues(alpha: 0.12); // = hairline
  static const Color bg2       = Color(0xFFF5F4F1);   // placeholder/shimmer bg
  static const Color accent    = Color(0xFF14110E);   // was orange; now ink
}

class AppText {
  // Eyebrow: Archivo 10 uppercase spaced — muted2
  static TextStyle eyebrow({Color? color}) => GoogleFonts.inter(
        fontSize: 10,
        letterSpacing: 2.0,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.muted2,
      );

  // Label: same as eyebrow, alias
  static TextStyle label({Color? color}) => GoogleFonts.inter(
        fontSize: 10,
        letterSpacing: 2.0,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.muted2,
      );

  // Caption: Archivo 11, muted
  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        color: color ?? AppColors.muted,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  // Body editorial: Spectral 16, 300, line-height 1.72, body color
  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        height: 1.72,
        color: color ?? AppColors.body,
        fontWeight: FontWeight.w300,
      );

  // Display: Spectral for big titles
  static TextStyle display({
    double fontSize = 22,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? AppColors.ink,
        height: 1.05,
      );
}

class Rsp {
  static bool isTablet(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).shortestSide >= 600;

  static double fs(BuildContext ctx, double size) =>
      isTablet(ctx) ? size : size * 0.78;
}
