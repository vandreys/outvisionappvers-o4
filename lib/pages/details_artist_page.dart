import 'package:flutter/material.dart';
import 'package:outvisionxr/models/artist_model.dart';

class DetailsArtistPage extends StatelessWidget {
  final Artist artist;

  const DetailsArtistPage({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
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
          artist.name,
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
                backgroundImage: artist.artistPhoto.isNotEmpty
                    ? NetworkImage(artist.artistPhoto)
                    : null,
                child: artist.artistPhoto.isEmpty
                    ? const Icon(Icons.person, size: 80, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              artist.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (artist.location.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                artist.location,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            if (artist.bio.isNotEmpty)
              Text(
                artist.bio,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.justify,
              ),
          ],
        ),
      ),
    );
  }
}
