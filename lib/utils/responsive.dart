import 'package:flutter/material.dart';

class R {
  static const double _tabletBreak = 600;
  static const double _maxContent = 720;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= _tabletBreak;

  /// Horizontal padding: 48 on tablet, 24 on phone
  static double hp(BuildContext context) => isTablet(context) ? 48.0 : 24.0;

  /// Wraps [child] in a centred max-width box on tablets; passthrough on phones
  static Widget constrain(BuildContext context, Widget child) {
    if (!isTablet(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContent),
        child: child,
      ),
    );
  }

  /// Bottom-sheet card: full-width on phone, centred pill on tablet
  static Widget bottomCard(BuildContext context, Widget child) {
    if (!isTablet(context)) return child;
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: child,
      ),
    );
  }

  static double titleFontSize(BuildContext context, double phone) =>
      isTablet(context) ? phone * 1.25 : phone;

  static double bodyFontSize(BuildContext context, double phone) =>
      isTablet(context) ? phone * 1.15 : phone;
}
