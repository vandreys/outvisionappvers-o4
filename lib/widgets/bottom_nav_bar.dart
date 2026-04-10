import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/widgets/nav_item.dart';

Widget bottomNavBar(BuildContext context, int currentIndex) {
  return Container(
    height: 80,
    color: Colors.white,
    child: Row(
      children: [
        Expanded(
          child: navItem(
            Icons.location_on,
            context.t.bottomNav.explore,
            currentIndex == 0,
            currentIndex == 0 ? Colors.pinkAccent : Colors.grey,
            () {
              if (currentIndex != 0) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.explore,
                  (_) => false,
                );
              }
            },
          ),
        ),
        Expanded(
          child: navItem(
            Icons.grid_view,
            context.t.bottomNav.gallery,
            currentIndex == 1,
            currentIndex == 1 ? Colors.pinkAccent : Colors.grey,
            () {
              if (currentIndex != 1) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.artwork,
                  (_) => false,
                );
              }
            },
          ),
        ),
        Expanded(
          child: navItem(
            Icons.person,
            context.t.gallery.tabArtists,
            currentIndex == 2,
            currentIndex == 2 ? Colors.pinkAccent : Colors.grey,
            () {
              if (currentIndex != 2) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.artists,
                  (_) => false,
                );
              }
            },
          ),
        ),
      ],
    ),
  );
}
