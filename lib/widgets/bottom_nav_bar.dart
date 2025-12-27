import 'package:flutter/material.dart';
import 'package:outvisionxr/pages/gallery.dart';
import 'package:outvisionxr/pages/settings.dart';
import 'package:outvisionxr/widgets/nav_item.dart';
import 'package:outvisionxr/pages/maple_sample.dart'; // Importe seu mapa para o Explore

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
          "Explore", 
          currentIndex == 0, 
          currentIndex == 0 ? Colors.pinkAccent : Colors.grey, 
          () {
            if (currentIndex != 0) {
              // Versão segura para voltar ao mapa sem erro de rotas nomeadas
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MapSample()),
                (route) => false,
              );
            }
          },
        ),

        // Gallery - Index 1
        navItem(
          Icons.grid_view, 
          "Gallery", 
          currentIndex == 1, 
          currentIndex == 1 ? Colors.pinkAccent : Colors.grey, 
          () {
            if (currentIndex != 1) {
              Navigator.push(
                context,
                // CORREÇÃO AQUI: Mudamos de ArtistPage para GalleryPage
                MaterialPageRoute(builder: (context) => const GalleryPage()),
              );
            }
          },
        ),

        // Captured - Index 2
        navItem(
          Icons.photo_camera, 
          "Captured", 
          currentIndex == 2, 
          currentIndex == 2 ? Colors.pinkAccent : Colors.grey, 
          () {
            // Ação para Captured
          },
        ),

        // Settings - Index 3
        navItem(
          Icons.settings, 
          "Settings", 
          currentIndex == 3, 
          currentIndex == 3 ? Colors.pinkAccent : Colors.grey, 
          () {
            if (currentIndex != 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            }
          },
        ),
      ],
    ),
  );
}