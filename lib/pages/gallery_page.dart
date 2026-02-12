import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/services/artist_service.dart';
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
            t.gallery.title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey[600],
            indicatorWeight: 2,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 1.2,
            ),
            tabs: [
              Tab(text: t.gallery.tabArtwork),
              Tab(text: t.gallery.tabArtists),
            ],
          ),
        ),
        body: TabBarView(
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 42),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGEM / OBRA
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEBE7),
                  borderRadius: BorderRadius.circular(5),
                  image: const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/450x600'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // TEXTO
              Text(
                t.gallery.artworkTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.gallery.artworkArtist,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 18),

              // 🔘 BOTÃO "VER EXPOSIÇÃO"
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    // ação futura
                  },
                  child: Text(
                    t.gallery.viewExhibition,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
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
  ArtistsList({super.key});
  final ArtistService _artistService = ArtistService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _artistService.getArtistStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.error,
                size: 75,
              ),
              const SizedBox(height: 5.0),
            ]),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
              ],
            ),
          );
        }

        if (snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mood_bad,
                  size: 75,
                ),
                const SizedBox(height: 5.0),
              ],
            ),
          );
        }

        return ListView(
          children: snapshot.data!
              .map<Widget>((artistData) => _buildArtistListItem(artistData, context))
              .toList(),
        );
      },
    );
  }
}

Widget _buildArtistListItem(Map<String, dynamic> artistData, BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEBE7),
            borderRadius: BorderRadius.circular(5),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),

            leading: const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.black12,
              child: Icon(Icons.person, size: 18, color: Colors.black),
            ),

            // NOME DO ARTISTA (mesmo size do título da obra)
            title: Text(
              artistData["name"],
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            // NÚMERO DE OBRAS (mesmo size do artista na obra)
            subtitle: Text(
              '3 obras', // depois vem do JSON
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),

            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: Colors.black,
            ),
            onTap: () {},
          ),
        );
  }