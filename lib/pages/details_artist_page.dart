import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artist_model.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:outvisionxr/utils/language_provider.dart';
import 'package:outvisionxr/widgets/shimmer_box.dart';
import 'package:provider/provider.dart';

class DetailsArtistPage extends StatefulWidget {
  final Artist artist;

  const DetailsArtistPage({super.key, required this.artist});

  @override
  State<DetailsArtistPage> createState() => _DetailsArtistPageState();
}

class _DetailsArtistPageState extends State<DetailsArtistPage> {
  Stream<List<Artwork>>? _artworkStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _artworkStream ??=
        Provider.of<ArtworkService>(context, listen: false).getArtworkStream();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final artist = widget.artist;
    final bio = artist.getBio(LocaleSettings.currentLocale.languageTag);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: StreamBuilder<List<Artwork>>(
        stream: _artworkStream,
        builder: (context, snapshot) {
          final artworks = (snapshot.data ?? [])
              .where((a) => a.displayArtist == artist.name)
              .toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHero(artist)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Name
                    Text(
                      artist.name,
                      style: GoogleFonts.inter(
                        fontSize: Rsp.fs(context, 34),
                        fontWeight: FontWeight.w400,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Meta: website
                    if (artist.website.isNotEmpty)
                      Text(
                        artist.website,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Bio
                    if (bio.isNotEmpty) ...[
                      Text(
                        bio,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: AppColors.body,
                          height: 1.72,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Divider(height: 1, color: AppColors.hairline),
                      const SizedBox(height: 28),
                    ],
                    // Artworks section
                    if (artworks.isNotEmpty) ...[
                      Text(
                        t.gallery.highlights.toUpperCase(),
                        style: AppText.label(),
                      ),
                      Divider(height: 1, color: AppColors.hairline),
                      ...artworks.map((artwork) => _buildArtworkItem(artwork, context)),
                      const SizedBox(height: 28),
                    ],
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

  Widget _buildHero(Artist artist) {
    return Stack(
      children: [
        SizedBox(
          height: Rsp.isTablet(context) ? 310 : 360,
          width: double.infinity,
          child: artist.artistPhoto.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: artist.artistPhoto,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const ShimmerBox(),
                  errorWidget: (_, __, ___) => Container(color: AppColors.bg2),
                )
              : Container(color: AppColors.bg2),
        ),
        // Back button — no badge
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: _GlassButton(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.chevron_left,
                  size: 22, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArtworkItem(Artwork artwork, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.artworkDetails,
        arguments: artwork.id,
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.hairline, width: 1)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: artwork.imageUrl != null && artwork.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: artwork.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ShimmerBox(),
                      errorWidget: (_, __, ___) => Container(color: AppColors.bg2),
                    )
                  : Container(color: AppColors.bg2),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.localizedTitle,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (artwork.year != null) artwork.year!,
                      if (artwork.locationName != null) artwork.locationName!,
                    ].join(' · '),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.faint),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _GlassButton({required this.onTap, required this.child});

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
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Center(child: child),
      ),
    );
  }
}
