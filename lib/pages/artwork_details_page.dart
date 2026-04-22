import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artist_model.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/services/artist_service.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/app_theme.dart';
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
  bool _descExpanded = false;

  static const int _descPreviewLength = 240;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_artistStream == null) {
      _artworkFuture = Provider.of<ArtworkService>(context, listen: false)
          .getArtworkById(widget.artworkId);
      _artistStream =
          Provider.of<ArtistService>(context, listen: false).getArtistStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder<Artwork?>(
        future: _artworkFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(strokeWidth: 1.5));
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null) {
            return Center(child: Text(t.ar.genericError));
          }

          final artwork = snapshot.data!;
          final description = artwork.description ?? '';
          final descIsTruncated = description.length > _descPreviewLength;
          final descText = (!_descExpanded && descIsTruncated)
              ? description.substring(0, _descPreviewLength)
              : description;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHero(artwork)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Location · year label in accent
                    Text(
                      [
                        if (artwork.locationName != null &&
                            artwork.locationName!.isNotEmpty)
                          artwork.locationName!,
                        if (artwork.year != null && artwork.year!.isNotEmpty)
                          artwork.year!,
                      ].join(' · ').toUpperCase(),
                      style: AppText.label(color: AppColors.accent),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(artwork.localizedTitle,
                        style: AppText.display(fontSize: Rsp.fs(context, 34))),
                    const SizedBox(height: 22),
                    Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 22),
                    // Description
                    if (description.isNotEmpty) ...[
                      Text.rich(
                        TextSpan(
                          style: AppText.body(),
                          children: [
                            TextSpan(text: descText),
                            if (!_descExpanded && descIsTruncated)
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _descExpanded = true),
                                  child: Text(
                                    ' ${t.gallery.bioMore}',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.accent,
                                      height: 1.75,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (_descExpanded) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _descExpanded = false),
                          child: Text(
                            'menos ↑',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 28),
                    ],
                    // Artist section
                    StreamBuilder<List<Artist>>(
                      stream: _artistStream,
                      builder: (context, artistSnap) {
                        if (!artistSnap.hasData) return const SizedBox.shrink();
                        final artist = artistSnap.data!
                            .where((a) => a.name == artwork.displayArtist)
                            .firstOrNull;
                        if (artist == null) return const SizedBox.shrink();
                        return _buildArtistRow(artist, context);
                      },
                    ),
                    const SizedBox(height: 28),
                    Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 24),
                    // Buttons
                    _buildButtons(artwork, context),
                    const SizedBox(height: 48),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHero(Artwork artwork) {
    return Stack(
      children: [
        SizedBox(
          height: Rsp.isTablet(context) ? 300 : 230,
          width: double.infinity,
          child: artwork.imageUrl != null && artwork.imageUrl!.isNotEmpty
              ? Image.network(
                  artwork.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: AppColors.bg2),
                )
              : Container(color: AppColors.bg2),
        ),
        // Gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 156,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [AppColors.bg, AppColors.bg.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
        // Back + share
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GlassCircleButton(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.chevron_left,
                      size: 22, color: Colors.white),
                ),
                _GlassCircleButton(
                  onTap: () {},
                  child: const Icon(Icons.ios_share,
                      size: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArtistRow(Artist artist, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.artistDetails,
        arguments: artist,
      ),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 52,
              height: 52,
              child: artist.artistPhoto.isNotEmpty
                  ? Image.network(
                      artist.artistPhoto,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.bg2),
                    )
                  : Container(
                      color: AppColors.bg2,
                      child: Icon(Icons.person_outline,
                          size: 22, color: AppColors.fg3),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text('Artista participante', style: AppText.caption()),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 16, color: AppColors.fg3),
        ],
      ),
    );
  }

  Widget _buildButtons(Artwork artwork, BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.explore,
              (route) => false,
              arguments: artwork.id,
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.border, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t.gallery.showOnMap,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.fg),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.location_on_outlined,
                    size: 15, color: AppColors.fg),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _GlassCircleButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Center(child: child),
      ),
    );
  }
}
