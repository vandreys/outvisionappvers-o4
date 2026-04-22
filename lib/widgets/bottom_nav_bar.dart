import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/app_theme.dart';

Widget bottomNavBar(BuildContext context, int currentIndex) {
  return Container(
    height: 64,
    decoration: BoxDecoration(
      color: AppColors.bg,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      children: [
        _NavItem(
          index: 0,
          currentIndex: currentIndex,
          label: context.t.bottomNav.explore,
          icon: Icons.location_on_outlined,
          onTap: () {
            if (currentIndex != 0) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRouter.explore, (_) => false);
            }
          },
        ),
        _NavItem(
          index: 1,
          currentIndex: currentIndex,
          label: context.t.bottomNav.gallery,
          icon: Icons.grid_view_outlined,
          onTap: () {
            if (currentIndex != 1) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRouter.artwork, (_) => false);
            }
          },
        ),
        _NavItem(
          index: 2,
          currentIndex: currentIndex,
          label: context.t.gallery.tabArtists,
          icon: Icons.person_outline,
          onTap: () {
            if (currentIndex != 2) {
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRouter.artists, (_) => false);
            }
          },
        ),
      ],
    ),
  );
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    final color = isActive ? AppColors.fg : AppColors.fg3;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: color,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
