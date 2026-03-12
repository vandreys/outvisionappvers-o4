import 'package:flutter/material.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/i18n/strings.g.dart';

class ArtworkDetailsPage extends StatefulWidget {
  final String artworkId;

  const ArtworkDetailsPage({super.key, required this.artworkId});

  @override
  State<ArtworkDetailsPage> createState() => _ArtworkDetailsPageState();
}

class _ArtworkDetailsPageState extends State<ArtworkDetailsPage> {
  final ArtworkService _artworkService = ArtworkService();
  late Future<Artwork?> _artworkFuture;

  @override
  void initState() {
    super.initState();
    _artworkFuture = _artworkService.getArtworkById(widget.artworkId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t.gallery.tabArtwork),
      ),
      body: FutureBuilder<Artwork?>(
        future: _artworkFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(child: Text(t.ar.genericError));
          }

          final artwork = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (artwork.imageUrl != null)
                  Image.network(
                    artwork.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    height: 300,
                  )
                else
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image_not_supported, size: 50)),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(artwork.localizedTitle, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(artwork.artist ?? 'Artista Desconhecido', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(artwork.year ?? '', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}