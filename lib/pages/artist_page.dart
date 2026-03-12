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
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _query = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: t.gallery.search,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              t.gallery.tabArtists,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: StreamBuilder(
              stream: _artistService.getArtistStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 75),
                        const SizedBox(height: 5),
                        Text(
                          t.ar.errorTitle,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final artists = snapshot.data!.where((artist) =>
                    artist["name"].toString().toLowerCase().contains(_query.toLowerCase())).toList();

                if (artists.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mood_bad, size: 75),
                        SizedBox(height: 5),
                        Text(
                          'Nenhum artista encontrado',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      return _buildArtistGridItem(artists[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: bottomNavBar(context, 2),
      ),
    );
  }

  Widget _buildArtistGridItem(Map<String, dynamic> artistData) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
          ),
          child: CircleAvatar(
            radius: 42,
            backgroundColor: Colors.grey[200],
            backgroundImage: artistData["imageUrl"] != null
                ? NetworkImage(artistData["imageUrl"])
                : null,
            child: artistData["imageUrl"] == null
                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          artistData["name"],
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}