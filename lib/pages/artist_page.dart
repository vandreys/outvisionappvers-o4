import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artist_model.dart';
import 'package:outvisionxr/services/artist_service.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';
import 'package:outvisionxr/pages/details_artist_page.dart';

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
        titleSpacing: -10,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 30),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
          ),
          child: TextField(
            controller: _searchController,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.grey[800], size: 20),
              hintText: t.gallery.search,
              hintStyle: TextStyle(fontSize: 10, color: Colors.grey[700]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              isDense: true,
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
            child: StreamBuilder<List<Artist>>(
              stream: _artistService.getArtistStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 75),
                        const SizedBox(height: 5),
                        Text(t.ar.errorTitle, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final artists = (snapshot.data ?? [])
                    .where((a) => a.name.toLowerCase().contains(_query.toLowerCase()))
                    .toList();

                if (artists.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mood_bad, size: 75),
                        const SizedBox(height: 5),
                        Text(t.gallery.noArtistFound, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isTablet = constraints.maxWidth >= 600;

                    if (isTablet) {
                      const padding = 16.0;
                      const spacing = 12.0;
                      const crossAxisCount = 3;
                      final cellWidth = (constraints.maxWidth - padding * 2 - spacing * (crossAxisCount - 1)) / crossAxisCount;
                      final circleRadius = cellWidth * 0.43;
                      final cellHeight = circleRadius * 2 + 8 + 50.0;
                      final aspectRatio = cellWidth / cellHeight;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: padding),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: spacing,
                            mainAxisSpacing: 20,
                            childAspectRatio: aspectRatio,
                          ),
                          itemCount: artists.length,
                          itemBuilder: (context, index) => _buildArtistGridItem(artists[index], circleRadius),
                        ),
                      );
                    }

                    // Celular: valores originais
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 20,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: artists.length,
                        itemBuilder: (context, index) => _buildArtistGridItem(artists[index], 42),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(child: bottomNavBar(context, 2)),
    );
  }

  Widget _buildArtistGridItem(Artist artist, double circleRadius) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsArtistPage(artist: artist),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
            ),
            child: CircleAvatar(
              radius: circleRadius,
              backgroundColor: Colors.grey[200],
              backgroundImage: artist.artistPhoto.isNotEmpty
                  ? NetworkImage(artist.artistPhoto)
                  : null,
              child: artist.artistPhoto.isEmpty
                  ? Icon(Icons.person, size: circleRadius * 0.9, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artist.name,
            style: const TextStyle(fontSize: 13, color: Colors.black),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
