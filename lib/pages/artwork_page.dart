import 'dart:async';

import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/responsive.dart';
import 'package:provider/provider.dart';

class ArtworkPage extends StatefulWidget {
  const ArtworkPage({super.key});

  @override
  State<ArtworkPage> createState() => _ArtworkPageState();
}

class _ArtworkPageState extends State<ArtworkPage> {
  Stream<List<Artwork>>? _artworkStream;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  Timer? _loadingTimer;
  bool _timedOut = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_artworkStream == null) {
      _artworkStream = Provider.of<ArtworkService>(context, listen: false).getArtworkStream();
      _startTimer();
    }
  }

  void _startTimer() {
    _loadingTimer?.cancel();
    _timedOut = false;
    _loadingTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) setState(() => _timedOut = true);
    });
  }

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
    _loadingTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildTimeout(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(t.ar.errorTitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(_startTimer),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            child: Text(t.ar.tryAgain, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              isDense: true,
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              t.gallery.tabArtwork,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Artwork>>(
              stream: _artworkStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  assert(() {
                    debugPrint("Erro Firebase (Obras): ${snapshot.error}");
                    return true;
                  }());
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

                if (snapshot.hasData) _loadingTimer?.cancel();

                if (snapshot.connectionState == ConnectionState.waiting) {
                  if (_timedOut) {
                    return _buildTimeout(context);
                  }
                  return const Center(child: CircularProgressIndicator());
                }

                final List<Artwork> data = snapshot.data ?? [];
                final artworks = data.where((artwork) {
                  final title = artwork.localizedTitle.toLowerCase();
                  final artist = (artwork.artist ?? '').toLowerCase();
                  final query = _query.toLowerCase();
                  return title.contains(query) || artist.contains(query);
                }).toList();

                if (artworks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.mood_bad, size: 75),
                        const SizedBox(height: 5),
                        Text(
                          t.gallery.noArtworkFound,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final tablet = R.isTablet(context);
                if (tablet) {
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 0,
                      childAspectRatio: 0.80,
                    ),
                    itemCount: artworks.length,
                    itemBuilder: (context, index) =>
                        _buildArtworkCard(artworks[index], context),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: artworks.length,
                  itemBuilder: (context, index) {
                    return _buildArtworkCard(artworks[index], context);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: bottomNavBar(context, 1),
      ),
    );
  }

  Widget _buildArtworkCard(Artwork artwork, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = constraints.maxWidth * 0.65;
        final imageUrl = artwork.imageUrl?.isNotEmpty == true ? artwork.imageUrl! : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGEM DA OBRA
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(imageHeight),
                      )
                    : _imagePlaceholder(imageHeight),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TÍTULO
                    Text(
                      artwork.localizedTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ARTISTA + ANO
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            artwork.displayArtist.isNotEmpty
                                ? artwork.displayArtist
                                : 'Artista desconhecido',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          ' • ${artwork.year ?? ''}',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // BOTÃO
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRouter.artworkDetails,
                            arguments: artwork.id,
                          );
                        },
                        child: Text(
                          t.gallery.viewExhibition,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _imagePlaceholder(double height) {
    return Container(
      height: height,
      width: double.infinity,
      color: const Color(0xFFEDEBE7),
      child: const Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }
}
