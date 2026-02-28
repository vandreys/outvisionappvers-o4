import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/services/artist_service.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  final ArtistService _artistService = ArtistService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          t.gallery.tabArtists.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _artistService.getArtistStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.error,
                  size: 75,
                ),
                const SizedBox(height: 5.0),
                Text(
                  t.ar.errorTitle, // Reutilizando string de erro existente
                  style: const TextStyle(color: Colors.grey),
                ),
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
                  Text(
                    "Nenhum artista encontrado", // Idealmente adicionar ao i18n
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) => _buildArtistListItem(snapshot.data![index], context),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: bottomNavBar(context, 2),
      ),
    );
  }

  Widget _buildArtistListItem(Map<String, dynamic> artistData, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        onTap: () {
          // Navegação futura para detalhes do artista
        },
      ),
    );
  }
}