import 'package:flutter/material.dart';

class DetailsArtistPage extends StatelessWidget {
  final Map<String, dynamic> artistData;

  const DetailsArtistPage({super.key, required this.artistData});

  @override
  Widget build(BuildContext context) {
    // Extrai dados básicos que já temos
    final String name = artistData['name'] ?? 'Artista';
    final String? photoUrl = artistData['artist_photo'];
    final String? location = artistData['location_artist'];
    final String? bio = artistData['text_about_artist'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          name,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 80,
                backgroundColor: Colors.grey[200],
                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, size: 80, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (location != null) ...[
              const SizedBox(height: 8),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            if (bio != null) ...[
              Text(
                bio,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
