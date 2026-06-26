import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:outvisionxr/widgets/shimmer_box.dart';
import 'package:outvisionxr/utils/language_provider.dart';
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
      _artworkStream =
          Provider.of<ArtworkService>(context, listen: false).getArtworkStream();
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
    _searchController
        .addListener(() => setState(() => _query = _searchController.text));
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.gallery.tabArtwork,
                    style: GoogleFonts.inter(
                      fontSize: Rsp.fs(context, 40),
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.6,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF14110E).withValues(alpha: 0.18),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 13),
                        const Icon(Icons.search, size: 14, color: AppColors.muted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.ink),
                            decoration: InputDecoration(
                              hintText: t.gallery.search,
                              hintStyle: GoogleFonts.inter(
                                  fontSize: 12, color: AppColors.muted),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const SizedBox(width: 13),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Artwork>>(
              stream: _artworkStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  if (_timedOut) return _buildError();
                  return _buildShimmerGrid();
                }
                if (snapshot.hasError) return _buildError();
                if (snapshot.hasData) _loadingTimer?.cancel();

                final artworks = (snapshot.data ?? []).where((a) {
                  final title = a.localizedTitle.toLowerCase();
                  final artist = (a.displayArtist).toLowerCase();
                  final q = _query.toLowerCase();
                  return title.contains(q) || artist.contains(q);
                }).toList();

                if (artworks.isEmpty) {
                  return Center(
                    child: Text(t.gallery.noArtworkFound,
                        style: AppText.caption()),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                      child: Text(
                        '${artworks.length} ${artworks.length == 1 ? t.gallery.artworkSingular : t.gallery.artworkPlural}'.toUpperCase(),
                        style: AppText.label(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: AppColors.hairline),
                    Expanded(
                      child: _buildEditorialGrid(artworks),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Rsp.isTablet(context)
          ? bottomNavBar(context, 1)
          : bottomNavBar(context, 1),
    );
  }

  Widget _buildShimmerGrid() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      children: const [
        // Two full-width shimmer items
        ShimmerBox(height: 300, borderRadius: BorderRadius.zero),
        SizedBox(height: 12),
        ShimmerBox(height: 22, width: 200, borderRadius: BorderRadius.zero),
        SizedBox(height: 26),
        ShimmerBox(height: 300, borderRadius: BorderRadius.zero),
        SizedBox(height: 12),
        ShimmerBox(height: 22, width: 200, borderRadius: BorderRadius.zero),
        SizedBox(height: 26),
        // 2-col grid shimmer
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ShimmerBox(height: 188, borderRadius: BorderRadius.zero),
              SizedBox(height: 8),
              ShimmerBox(height: 16, borderRadius: BorderRadius.zero),
            ])),
            SizedBox(width: 18),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ShimmerBox(height: 188, borderRadius: BorderRadius.zero),
              SizedBox(height: 8),
              ShimmerBox(height: 16, borderRadius: BorderRadius.zero),
            ])),
          ],
        ),
      ],
    );
  }

  Widget _buildEditorialGrid(List<Artwork> artworks) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      itemCount: artworks.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.hairline),
      itemBuilder: (_, i) => FadeSlideIn(
        index: i,
        child: _buildFeaturedItem(artworks[i]),
      ),
    );
  }

  Widget _buildFeaturedItem(Artwork artwork) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.artworkDetails,
        arguments: artwork.id,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    artwork.localizedTitle,
                    style: GoogleFonts.inter(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (artwork.year != null && artwork.year!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Text(
                    artwork.year!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ],
            ),
            if (artwork.displayArtist.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                artwork.displayArtist,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(t.ar.errorTitle, style: AppText.caption()),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(_startTimer),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.ink,
              child: Text(
                t.ar.tryAgain.toUpperCase(),
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
