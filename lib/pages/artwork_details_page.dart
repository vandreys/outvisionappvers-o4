import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artist_model.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/services/artist_service.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/responsive.dart';
import 'package:provider/provider.dart';

class ArtworkDetailsPage extends StatefulWidget {
  final String artworkId;

  const ArtworkDetailsPage({super.key, required this.artworkId});

  @override
  State<ArtworkDetailsPage> createState() => _ArtworkDetailsPageState();
}

class _ArtworkDetailsPageState extends State<ArtworkDetailsPage> {
  late Future<Artwork?> _artworkFuture;
  Stream<List<Artist>>? _artistStream;
  Stream<List<Artwork>>? _artworkStream;
  bool _descExpanded = false;

  static const int _descPreviewLength = 220;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_artistStream == null) {
      _artworkFuture = Provider.of<ArtworkService>(context, listen: false).getArtworkById(widget.artworkId);
      _artistStream = Provider.of<ArtistService>(context, listen: false).getArtistStream();
      _artworkStream = Provider.of<ArtworkService>(context, listen: false).getArtworkStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tablet = R.isTablet(context);
    final hPad = R.hp(context);
    final imageHeight = tablet ? 360.0 : 260.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 30, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
          final description = artwork.description ?? '';
          final descIsTruncated = description.length > _descPreviewLength;
          final descText = (!_descExpanded && descIsTruncated)
              ? description.substring(0, _descPreviewLength)
              : description;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Imagem da obra
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: imageHeight,
                        width: double.infinity,
                        child: artwork.imageUrl != null
                            ? Image.network(
                                artwork.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Container(color: Colors.grey[300]),
                              )
                            : Container(color: Colors.grey[300]),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Subtítulo (locationName ou year)
                    if (artwork.locationName != null && artwork.locationName!.isNotEmpty)
                      Text(
                        artwork.locationName!,
                        style: TextStyle(
                          fontSize: R.bodyFontSize(context, 15),
                          color: Colors.grey[600],
                        ),
                      )
                    else if (artwork.year != null && artwork.year!.isNotEmpty)
                      Text(
                        artwork.year!,
                        style: TextStyle(
                          fontSize: R.bodyFontSize(context, 15),
                          color: Colors.grey[600],
                        ),
                      ),

                    const SizedBox(height: 6),

                    // Título
                    Text(
                      artwork.localizedTitle,
                      style: TextStyle(
                        fontSize: R.titleFontSize(context, 28),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFD8D8D8)),
                    const SizedBox(height: 24),

                    // Descrição com "more"
                    if (description.isNotEmpty) ...[
                      GestureDetector(
                        onTap: descIsTruncated
                            ? () => setState(() => _descExpanded = !_descExpanded)
                            : null,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: R.bodyFontSize(context, 15),
                              height: 1.6,
                              color: Colors.grey[800],
                            ),
                            children: [
                              TextSpan(text: descText),
                              if (!_descExpanded && descIsTruncated)
                                TextSpan(
                                  text: t.gallery.bioMore,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(height: 1, color: Color(0xFFD8D8D8)),
                      const SizedBox(height: 24),
                    ],

                    // Botão Ver no mapa
                    SizedBox(
                      width: double.infinity,
                      height: tablet ? 56 : 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.explore,
                            (route) => false,
                            arguments: artwork.id,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              t.gallery.showOnMap,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: R.bodyFontSize(context, 15),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.location_on_outlined,
                                color: Colors.black, size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Divider(height: 1, color: Color(0xFFD8D8D8)),
                    const SizedBox(height: 32),

                    // Seção Artista
                    Text(
                      t.gallery.artist,
                      style: TextStyle(
                        fontSize: R.titleFontSize(context, 20),
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    StreamBuilder<List<Artist>>(
                      stream: _artistStream,
                      builder: (context, artistSnapshot) {
                        if (!artistSnapshot.hasData) return const SizedBox.shrink();

                        final artistName = artwork.displayArtist;
                        final artist = artistSnapshot.data!
                            .where((a) => a.name == artistName)
                            .firstOrNull;

                        return StreamBuilder<List<Artwork>>(
                          stream: _artworkStream,
                          builder: (context, awSnapshot) {
                            final count = awSnapshot.data
                                    ?.where((a) => a.displayArtist == artistName)
                                    .length ??
                                0;

                            final photoUrl = artist?.artistPhoto ?? '';
                            final avatarRadius = tablet ? 38.0 : 30.0;

                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: avatarRadius,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: photoUrl.isNotEmpty
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  child: photoUrl.isEmpty
                                      ? Icon(Icons.person,
                                          size: avatarRadius, color: Colors.grey)
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        artistName,
                                        style: TextStyle(
                                          fontSize: R.bodyFontSize(context, 16),
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      if (count > 0)
                                        Text(
                                          '$count ${t.gallery.works}',
                                          style: TextStyle(
                                              fontSize: R.bodyFontSize(context, 13),
                                              color: Colors.grey[600]),
                                        ),
                                    ],
                                  ),
                                ),
                                if (artist != null)
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRouter.artistDetails,
                                      arguments: artist,
                                    ),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.chevron_right,
                                          color: Colors.white, size: 22),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
