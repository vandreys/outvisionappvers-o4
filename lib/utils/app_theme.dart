import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bg2 = Color(0xFFF6F6F6);
  static const Color fg = Color(0xFF0D0D0D);
  static Color get fg2 => const Color(0xFF0D0D0D).withValues(alpha: 0.68);
  static Color get fg3 => const Color(0xFF0D0D0D).withValues(alpha: 0.40);
  static Color get border => const Color(0xFF0D0D0D).withValues(alpha: 0.07);
  static const Color accent = Color(0xFFC1632F);
}

class AppText {
  static TextStyle eyebrow({Color? color}) => GoogleFonts.inter(
        fontSize: 9,
        letterSpacing: 2.0,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.fg3,
      );

  static TextStyle label({Color? color}) => GoogleFonts.inter(
        fontSize: 10,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.fg3,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        color: color ?? AppColors.fg2,
      );

  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 13,
        height: 1.75,
        color: color ?? AppColors.fg2,
        fontWeight: FontWeight.w300,
      );

  static TextStyle display({double fontSize = 22, Color? color}) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: color ?? AppColors.fg,
      );
}

class Rsp {
  static bool isTablet(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).shortestSide >= 600;

  static double fs(BuildContext ctx, double size) =>
      isTablet(ctx) ? size : size * 0.78;
}
