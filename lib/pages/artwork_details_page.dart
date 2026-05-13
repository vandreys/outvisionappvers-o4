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
                      Text(description, style: AppText.body()),
                      const SizedBox(height: 28),
                      Divider(height: 1, color: AppColors.border),
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
                          return _buildArtistRow(artwork.displayArtist, artist, context);
                        },
                      ),
                      const SizedBox(height: 28),
                      Divider(height: 1, color: AppColors.border),
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

  Widget _buildSkeleton() {
    final heroH = Rsp.isTablet(context) ? 300.0 : 230.0;
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: ShimmerBox(height: heroH),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ShimmerBox(height: 10, width: 120, borderRadius: BorderRadius.circular(3)),
              const SizedBox(height: 10),
              ShimmerBox(height: 28, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 8),
              ShimmerBox(height: 28, width: 180, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 28),
              const Divider(height: 1),
              const SizedBox(height: 22),
              ShimmerBox(height: 13, borderRadius: BorderRadius.circular(3)),
              const SizedBox(height: 6),
              ShimmerBox(height: 13, borderRadius: BorderRadius.circular(3)),
              const SizedBox(height: 6),
              ShimmerBox(height: 13, width: 200, borderRadius: BorderRadius.circular(3)),
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
          height: Rsp.isTablet(context) ? 300 : 230,
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
          ? () => Navigator.pushNamed(context, AppRouter.artistDetails, arguments: artist)
          : null,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 52,
              height: 52,
              child: (artist != null && artist.artistPhoto.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: artist.artistPhoto,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ShimmerBox(),
                      errorWidget: (_, __, ___) => Container(color: AppColors.bg2),
                    )
                  : Container(
                      color: AppColors.bg2,
                      child: Icon(Icons.person_outline, size: 22, color: AppColors.fg3),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artistName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(t.gallery.participatingArtist, style: AppText.caption()),
              ],
            ),
          ),
          if (tappable)
            Icon(Icons.chevron_right, size: 16, color: AppColors.fg3),
        ],
      ),
    );
  }

  Widget _buildButtons(Artwork artwork, BuildContext context) {
    return Column(
      children: [
        _OfflineButton(artwork: artwork),
        const SizedBox(height: 12),
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
      height: 50,
      child: OutlinedButton(
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
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: _offline == true ? AppColors.accent : AppColors.border,
            width: 1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
                      color: AppColors.fg,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.fg),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _offline == true
                        ? t.gallery.makeAvailableOffline
                        : t.gallery.makeAvailableOffline,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _offline == true
                            ? AppColors.accent
                            : AppColors.fg),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _offline == true
                        ? Icons.check_circle_outline
                        : Icons.download_outlined,
                    size: 15,
                    color: _offline == true ? AppColors.accent : AppColors.fg,
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
