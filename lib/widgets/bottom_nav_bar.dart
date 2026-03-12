import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/pages/artist_page.dart';
import 'package:outvisionxr/pages/artwork_page.dart';
import 'package:outvisionxr/widgets/nav_item.dart';
import 'package:outvisionxr/pages/explore_page.dart'; // Importe seu mapa para o Explore

Widget bottomNavBar(BuildContext context, int currentIndex) {
  return Container(
    height: 80,
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Explore - Index 0
        navItem(
          Icons.location_on, 
          context.t.bottomNav.explore, 
          currentIndex == 0, 
          currentIndex == 0 ? Colors.pinkAccent : Colors.grey, 
          () {
            if (currentIndex != 0) {
              // Versão segura para voltar ao mapa sem erro de rotas nomeadas
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ExplorePage()),
                (route) => false,
              );
            }
          },
        ),

        // Gallery - Index 1
        navItem(
          Icons.grid_view, 
          context.t.bottomNav.gallery, 
          currentIndex == 1, 
          currentIndex == 1 ? Colors.pinkAccent : Colors.grey, 
          () {
            if (currentIndex != 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ArtworkPage()),
              );
            }
          },
        ),
        
        // Artists - Index 2
        navItem(
          Icons.person, 
          context.t.gallery.tabArtists, 
          currentIndex == 2, 
          currentIndex == 2 ? Colors.pinkAccent : Colors.grey, 
          () {
            if (currentIndex != 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ArtistsPage()),
              );
            }
          },
        ),
      ],
    ),
  );
}