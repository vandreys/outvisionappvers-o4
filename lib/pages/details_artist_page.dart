import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artist_model.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/utils/responsive.dart';
import 'package:provider/provider.dart';

class DetailsArtistPage extends StatefulWidget {
  final Artist artist;

  const DetailsArtistPage({super.key, required this.artist});

  @override
  State<DetailsArtistPage> createState() => _DetailsArtistPageState();
}

class _DetailsArtistPageState extends State<DetailsArtistPage> {
  bool _bioExpanded = false;
  Stream<List<Artwork>>? _artworkStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _artworkStream ??= Provider.of<ArtworkService>(context, listen: false).getArtworkStream();
  }

  static const int _bioPreviewLength = 220;

  @override
  Widget build(BuildContext context) {
    final artist = widget.artist;
    final bio = artist.getBio(LocaleSettings.currentLocale.languageTag);
    final bioIsTruncated = bio.length > _bioPreviewLength;
    final bioText = (!_bioExpanded && bioIsTruncated)
        ? bio.substring(0, _bioPreviewLength)
        : bio;

    final tablet = R.isTablet(context);
    final hPad = R.hp(context);
    final avatarRadius = tablet ? 100.0 : 82.0;

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Foto circular
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: artist.artistPhoto.isNotEmpty
                      ? NetworkImage(artist.artistPhoto)
                      : null,
                  child: artist.artistPhoto.isEmpty
                      ? Icon(Icons.person, size: avatarRadius * 0.9, color: Colors.grey)
                      : null,
                ),

                const SizedBox(height: 24),

                // Nome
                Text(
                  artist.name,
                  style: TextStyle(
                    fontSize: R.titleFontSize(context, 28),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 24),

                // Bio com "more"
                if (bio.isNotEmpty) ...[
                  GestureDetector(
                    onTap: bioIsTruncated
                        ? () => setState(() => _bioExpanded = !_bioExpanded)
                        : null,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: R.bodyFontSize(context, 15),
                          height: 1.6,
                          color: Colors.grey[800],
                        ),
                        children: [
                          TextSpan(text: bioText),
                          if (!_bioExpanded && bioIsTruncated)
                            TextSpan(
                              text: t.gallery.bioMore,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(height: 1, color: Color(0xFFD8D8D8)),
                  const SizedBox(height: 32),
                ],

                // Highlights
                Text(
                  t.gallery.highlights,
                  style: TextStyle(
                    fontSize: R.titleFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                StreamBuilder<List<Artwork>>(
                  stream: _artworkStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();

                    final artworks = snapshot.data!
                        .where((a) => a.displayArtist == artist.name)
                        .toList();

                    if (artworks.isEmpty) return const SizedBox.shrink();

                    final crossAxisCount = tablet ? 3 : 2;
                    final highlights = artworks.take(tablet ? 6 : 4).toList();

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 28,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: highlights.length,
                      itemBuilder: (context, index) {
                        return _HighlightCard(artwork: highlights[index]);
                      },
                    );
                  },
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final Artwork artwork;

  const _HighlightCard({required this.artwork});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox.expand(
              child: (artwork.imageUrl != null && artwork.imageUrl!.isNotEmpty)
                  ? Image.network(
                      artwork.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[300]),
                    )
                  : Container(color: Colors.grey[300]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          artwork.localizedTitle,
          style: TextStyle(
            fontSize: R.bodyFontSize(context, 13),
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
