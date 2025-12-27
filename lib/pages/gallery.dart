import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Gallery',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.pinkAccent,
            labelColor: Colors.pinkAccent,
            unselectedLabelColor: Colors.grey,
            indicatorWeight: 3,
            labelStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            tabs: const [
              Tab(text: 'Artwork'),
              Tab(text: 'Artists'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ArtworksList(),
            ArtistsList(),
          ],
        ),
        bottomNavigationBar: bottomNavBar(context, 1),
      ),
    );
  }
}

// --- SUB-PÁGINA: LISTA DE OBRAS (ESTILO VERTICAL) ---
class ArtworksList extends StatelessWidget {
  const ArtworksList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 4, 
      itemBuilder: (context, index) {
        return Padding(
          // CORREÇÃO AQUI: De EdgeInsets.bottom para EdgeInsets.only
          padding: const EdgeInsets.only(bottom: 35.0), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 450,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/450x600'), 
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The Garden of Earthly Delights',
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Hieronymus Bosch',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.black, size: 26),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.camera_alt_outlined, color: Colors.black, size: 26),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- SUB-PÁGINA: LISTA DE ARTISTAS ---
class ArtistsList extends StatelessWidget {
  const ArtistsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          // CORREÇÃO AQUI: De EdgeInsets.bottom para EdgeInsets.only
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            leading: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              'Artist Name ${index + 1}',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Curitiba Biennial 2025'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
            onTap: () {},
          ),
        );
      },
    );
  }
}