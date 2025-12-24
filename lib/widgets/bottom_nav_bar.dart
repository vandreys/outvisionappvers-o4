 import 'package:flutter/material.dart';
 // 1. IMPORTAÇÃO DA PÁGINA DE GALERIA
import 'package:outvisionxr/pages/gallery.dart';
import 'package:outvisionxr/widgets/nav_item.dart';
 
 Widget bottomNavBar(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          navItem(Icons.location_on, "Explore", true, Colors.pinkAccent, () {
            // Ação para Explore
          }),
          navItem(Icons.grid_view, "Gallery", false, Colors.grey, () {
            // NAVEGAÇÃO PARA A GALERIA
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ArtistPage()),
            );
          }),
          navItem(Icons.photo_camera, "Captured", false, Colors.grey, () {}),
          navItem(Icons.settings, "Settings", false, Colors.grey, () {}),
        ],
      ),
    );
  }
