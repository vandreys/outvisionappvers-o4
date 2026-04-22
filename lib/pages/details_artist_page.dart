import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artist_model.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:provider/provider.dart';

class DetailsArtistPage extends StatefulWidget {
  final Artist artist;

  const DetailsArtistPage({super.key, required this.artist});

  @override
  State<DetailsArtistPage> createState() => _DetailsArtistPageState();
}

class _DetailsArtistPageState extends State<DetailsArtistPage> {
  bool _bioExpanded = false;
  int _artworkIdx = 0;
  Stream<List<Artwork>>? _artworkStream;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _artworkStream ??=
        Provider.of<ArtworkService>(context, listen: false).getArtworkStream();
  }

  @override
  Widget build(BuildContext context) {
    final artist = widget.artist;
    final bio = artist.getBio(LocaleSettings.currentLocale.languageTag);
    final paras =
        bio.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    final bioPreview = paras.isNotEmpty ? paras.first : bio;
    final hasBioMore = paras.length > 1;

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
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Meta
                    Text(
                      [
                        if (artist.website.isNotEmpty) artist.website,
                      ].join(' · '),
                      style: AppText.caption(),
                    ),
                    const SizedBox(height: 10),
                    // Name
                    Text(artist.name, style: AppText.display(fontSize: Rsp.fs(context, 42))),
                    const SizedBox(height: 20),
                    // Bio
                    if (bio.isNotEmpty) ...[
                      _buildBio(bio, bioPreview, hasBioMore, paras),
                      const SizedBox(height: 32),
                      Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 28),
                    ],
                    // Artworks section
                    if (artworks.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(t.gallery.highlights,
                              style: AppText.display(fontSize: 22)),
                          const Spacer(),
                          Text(
                            '${_artworkIdx + 1}/${artworks.length}',
                            style: AppText.caption(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildArtworkCard(artworks, context),
                      if (artworks.length > 1) ...[
                        const SizedBox(height: 14),
                        _buildDotsNav(artworks.length),
                      ],
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
          height: Rsp.isTablet(context) ? 310 : 240,
          width: double.infinity,
          child: artist.artistPhoto.isNotEmpty
              ? Image.network(
                  artist.artistPhoto,
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
          height: 160,
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
        // Back button + badge
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GlassButton(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.chevron_left,
                      size: 22, color: Colors.white),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Text(
                    'Bienal de Curitiba',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      letterSpacing: 1.8,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBio(
      String bio, String preview, bool hasBioMore, List<String> paras) {
    final tablet = Rsp.isTablet(context);
    final bodyStyle = AppText.body().copyWith(
      fontSize: tablet ? 13 : 11.5,
      height: tablet ? 1.75 : 1.6,
    );
    if (!hasBioMore) {
      return Text(bio, style: bodyStyle);
    }
    if (!_bioExpanded) {
      return Text.rich(
        TextSpan(
          style: bodyStyle,
          children: [
            TextSpan(text: '$preview '),
            TextSpan(
              text: 'ler mais',
              style: GoogleFonts.inter(
                fontSize: tablet ? 13 : 11,
                fontWeight: FontWeight.w500,
                color: AppColors.accent,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => setState(() => _bioExpanded = true),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...paras.map((p) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(p, style: bodyStyle),
            )),
        GestureDetector(
          onTap: () => setState(() => _bioExpanded = false),
          child: Text(
            'menos ↑',
            style: GoogleFonts.inter(
              fontSize: tablet ? 12 : 11,
              fontWeight: FontWeight.w500,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArtworkCard(List<Artwork> artworks, BuildContext context) {
    final artwork = artworks[_artworkIdx];
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.artworkDetails,
        arguments: artwork.id,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      if (artwork.year != null) artwork.year!,
                      if (artwork.locationName != null) artwork.locationName!,
                    ].join(' · ').toUpperCase(),
                    style: AppText.label(color: AppColors.accent),
                  ),
                  const SizedBox(height: 6),
                  Text(artwork.localizedTitle,
                      style: AppText.display(fontSize: 20)),
                  const SizedBox(height: 4),
                  if (artwork.locationName != null)
                    Text(artwork.locationName!, style: AppText.caption()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDotsNav(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _navArrow(false, count),
        const SizedBox(width: 20),
        Row(
          children: List.generate(count, (i) {
            final active = i == _artworkIdx;
            return GestureDetector(
              onTap: () => setState(() => _artworkIdx = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                width: active ? 16 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: active ? AppColors.accent : AppColors.fg3,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(width: 20),
        _navArrow(true, count),
      ],
    );
  }

  Widget _navArrow(bool next, int count) {
    return GestureDetector(
      onTap: () => setState(() {
        _artworkIdx = next
            ? (_artworkIdx + 1) % count
            : (_artworkIdx - 1 + count) % count;
      }),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          next ? Icons.chevron_right : Icons.chevron_left,
          size: 18,
          color: AppColors.fg3,
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
        child: child,
      ),
    );
  }
}
