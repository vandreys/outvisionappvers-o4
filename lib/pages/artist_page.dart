import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artist_model.dart';
import 'package:outvisionxr/utils/language_provider.dart';
import 'package:outvisionxr/services/artist_service.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:outvisionxr/widgets/shimmer_box.dart';
import 'package:provider/provider.dart';

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  Stream<List<Artist>>? _artistStream;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  Timer? _loadingTimer;
  bool _timedOut = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_artistStream == null) {
      _artistStream =
          Provider.of<ArtistService>(context, listen: false).getArtistStream();
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
                    t.gallery.tabArtists,
                    style: GoogleFonts.inter(
                      fontSize: Rsp.fs(context, 40),
                      fontWeight: FontWeight.w400,
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
            child: StreamBuilder<List<Artist>>(
              stream: _artistStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  if (_timedOut) return _buildError();
                  return _buildShimmerList();
                }
                if (snapshot.hasError) return _buildError();
                if (snapshot.hasData) _loadingTimer?.cancel();

                final artists = (snapshot.data ?? [])
                    .where((a) =>
                        a.name.toLowerCase().contains(_query.toLowerCase()))
                    .toList();

                if (artists.isEmpty) {
                  return Center(
                    child:
                        Text(t.gallery.noArtistFound, style: AppText.caption()),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: Text(
                        '${artists.length} ${artists.length == 1 ? t.gallery.artistSingular : t.gallery.artistPlural}'
                            .toUpperCase(),
                        style: AppText.label(),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                        itemCount: artists.length,
                        itemBuilder: (context, index) => FadeSlideIn(
                          index: index,
                          child: _buildArtistItem(artists[index], index),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Rsp.isTablet(context)
          ? bottomNavBar(context, 2)
          : bottomNavBar(context, 2),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      itemCount: 6,
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.hairline, width: 1)),
        ),
        child: const Row(
          children: [
            ShimmerBox(width: 32, height: 14, borderRadius: BorderRadius.zero),
            SizedBox(width: 12),
            Expanded(
              child: ShimmerBox(height: 25, borderRadius: BorderRadius.zero),
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppColors.ink,
              child: Text(
                t.ar.tryAgain.toUpperCase(),
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistItem(Artist artist, int index) {
    final indexLabel = (index + 1).toString().padLeft(2, '0');
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRouter.artistDetails,
          arguments: artist),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.hairline, width: 1)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                indexLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.faint,
                ),
              ),
            ),
            Expanded(
              child: Text(
                artist.name,
                style: GoogleFonts.inter(
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink,
                ),
              ),
            ),
            if (artist.website.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                artist.website.length > 20
                    ? '${artist.website.substring(0, 20)}…'
                    : artist.website,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
