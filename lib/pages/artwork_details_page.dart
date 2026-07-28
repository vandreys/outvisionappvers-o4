import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artist_model.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/services/artist_service.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/services/download_service.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:outvisionxr/utils/language_provider.dart';
import 'package:outvisionxr/widgets/shimmer_box.dart';
import 'package:provider/provider.dart';

class ArtworkDetailsPage extends StatefulWidget {
  final String artworkId;

  const ArtworkDetailsPage({super.key, required this.artworkId});

  @override
  State<ArtworkDetailsPage> createState() => _ArtworkDetailsPageState();
}

class _ArtworkDetailsPageState extends State<ArtworkDetailsPage>
    with SingleTickerProviderStateMixin {
  late Future<Artwork?> _artworkFuture;
  Stream<List<Artist>>? _artistStream;
  late final AnimationController _enterCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;
  bool _animStarted = false;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fadeAnim = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
  }

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
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

  void _triggerEnter() {
    if (!_animStarted) {
      _animStarted = true;
      _enterCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FutureBuilder<Artwork?>(
        future: _artworkFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildSkeleton();
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data == null) {
            return Center(child: Text(t.ar.genericError));
          }

          final artwork = snapshot.data!;
          _triggerEnter();
          final description = artwork.localizedDescription;

          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHero(artwork)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Eyebrow: OBRA · {ano}
                        Text(
                          [
                            'OBRA',
                            if (artwork.year != null && artwork.year!.isNotEmpty)
                              artwork.year!,
                          ].join(' · '),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0,
                            color: AppColors.muted2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Title
                        Text(
                          artwork.localizedTitle,
                          style: GoogleFonts.inter(
                            fontSize: Rsp.fs(context, 36),
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.4,
                            color: AppColors.ink,
                          ),
                        ),
                        // Artist as italic link
                        if (artwork.displayArtist.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          StreamBuilder<List<Artist>>(
                            stream: _artistStream,
                            builder: (context, artistSnap) {
                              final artist = artistSnap.data
                                  ?.where((a) => a.name == artwork.displayArtist)
                                  .firstOrNull;
                              return GestureDetector(
                                onTap: artist != null
                                    ? () => Navigator.pushNamed(
                                          context,
                                          AppRouter.artistDetails,
                                          arguments: artist,
                                        )
                                    : null,
                                child: Text(
                                  artwork.displayArtist,
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.muted,
                                    decoration: artist != null
                                        ? TextDecoration.underline
                                        : TextDecoration.none,
                                    decorationColor: AppColors.muted,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 26),
                        Divider(height: 1, color: AppColors.hairline),
                        // Metadata 2-col block
                        if ((artwork.locationName != null &&
                                artwork.locationName!.isNotEmpty))
                          _buildMetaBlock(artwork),
                        // Description
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(description, style: AppText.body()),
                          const SizedBox(height: 28),
                          Divider(height: 1, color: AppColors.hairline),
                          const SizedBox(height: 28),
                        ] else ...[
                          const SizedBox(height: 28),
                        ],
                        // Artist section
                        if (artwork.displayArtist.isNotEmpty) ...[
                          Text(t.gallery.artist, style: AppText.label()),
                          const SizedBox(height: 12),
                          StreamBuilder<List<Artist>>(
                            stream: _artistStream,
                            builder: (context, artistSnap) {
                              final artist = artistSnap.data
                                  ?.where((a) => a.name == artwork.displayArtist)
                                  .firstOrNull;
                              return _buildArtistRow(
                                  artwork.displayArtist, artist, context);
                            },
                          ),
                          const SizedBox(height: 28),
                          Divider(height: 1, color: AppColors.hairline),
                          const SizedBox(height: 24),
                        ],
                        // Buttons
                        _buildButtons(artwork, context),
                        const SizedBox(height: 48),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetaBlock(Artwork artwork) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: IntrinsicHeight(
        child: Row(
          children: [
            if (artwork.locationName != null &&
                artwork.locationName!.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOCAL',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                          color: AppColors.muted2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        artwork.locationName!,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    final heroH = Rsp.isTablet(context) ? 360.0 : 280.0;
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: ShimmerBox(height: heroH),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const ShimmerBox(height: 10, width: 120, borderRadius: BorderRadius.zero),
              const SizedBox(height: 12),
              const ShimmerBox(height: 36, borderRadius: BorderRadius.zero),
              const SizedBox(height: 8),
              const ShimmerBox(height: 28, width: 180, borderRadius: BorderRadius.zero),
              const SizedBox(height: 28),
              const Divider(height: 1),
              const SizedBox(height: 22),
              const ShimmerBox(height: 13, borderRadius: BorderRadius.zero),
              const SizedBox(height: 6),
              const ShimmerBox(height: 13, borderRadius: BorderRadius.zero),
              const SizedBox(height: 6),
              const ShimmerBox(height: 13, width: 200, borderRadius: BorderRadius.zero),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHero(Artwork artwork) {
    return Stack(
      children: [
        SizedBox(
          height: Rsp.isTablet(context) ? 360 : 430,
          width: double.infinity,
          child: artwork.imageUrl != null && artwork.imageUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: artwork.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const ShimmerBox(),
                  errorWidget: (_, __, ___) => Container(color: AppColors.bg2),
                )
              : Container(color: AppColors.bg2),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: _GlassCircleButton(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.chevron_left,
                  size: 22, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArtistRow(String artistName, Artist? artist, BuildContext context) {
    final tappable = artist != null;
    return GestureDetector(
      onTap: tappable
          ? () => Navigator.pushNamed(context, AppRouter.artistDetails,
                arguments: artist)
          : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artistName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(t.gallery.participatingArtist, style: AppText.caption()),
              ],
            ),
          ),
          if (tappable)
            const Icon(Icons.chevron_right, size: 16, color: AppColors.faint),
        ],
      ),
    );
  }

  Widget _buildButtons(Artwork artwork, BuildContext context) {
    return Column(
      children: [
        _OfflineButton(artwork: artwork),
        const SizedBox(height: 12),
        // Secondary: "COMO CHEGAR"
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.explore,
              (route) => false,
              arguments: artwork.id,
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: const Color(0xFF14110E).withValues(alpha: 0.30),
                width: 1,
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  t.gallery.showOnMap.toUpperCase(),
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                      letterSpacing: 1.0),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.location_on_outlined,
                    size: 15, color: AppColors.ink),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineButton extends StatefulWidget {
  final Artwork artwork;
  const _OfflineButton({required this.artwork});

  @override
  State<_OfflineButton> createState() => _OfflineButtonState();
}

class _OfflineButtonState extends State<_OfflineButton> {
  bool? _offline;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final dl = context.read<DownloadService>();
    final v = await dl.isOffline(widget.artwork.id);
    if (mounted) setState(() => _offline = v);
  }

  @override
  Widget build(BuildContext context) {
    final dl = context.watch<DownloadService>();
    final id = widget.artwork.id;
    final downloading = dl.isDownloading(id);
    final progress = dl.progressOf(id);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: downloading
            ? null
            : () async {
                if (_offline == true) {
                  await dl.remove(id);
                  if (mounted) setState(() => _offline = false);
                } else {
                  await dl.download(widget.artwork);
                  if (mounted) setState(() => _offline = true);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.ink.withValues(alpha: 0.6),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: downloading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      value: progress > 0 ? progress : null,
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1.0),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _offline == true
                        ? Icons.check_circle_outline
                        : Icons.view_in_ar_outlined,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _offline == true
                        ? t.gallery.makeAvailableOffline.toUpperCase()
                        : t.gallery.makeAvailableOffline.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1.0),
                  ),
                ],
              ),
      ),
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
