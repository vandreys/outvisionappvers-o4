import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artist_model.dart';
import 'package:outvisionxr/services/artist_service.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/app_theme.dart';
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          t.gallery.tabArtists,
                          style: AppText.display(fontSize: Rsp.fs(context, 40)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.settings),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.bg2,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.tune_rounded,
                              size: 15, color: AppColors.fg),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bg2,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 13),
                        Icon(Icons.search, size: 14, color: AppColors.fg3),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: AppColors.fg),
                            decoration: InputDecoration(
                              hintText: t.gallery.search,
                              hintStyle: GoogleFonts.inter(
                                  fontSize: 12, color: AppColors.fg3),
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
                  return const Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5));
                }
                if (snapshot.hasError) return _buildError();
                if (snapshot.hasData) _loadingTimer?.cancel();

                final artists = (snapshot.data ?? [])
                    .where((a) =>
                        a.name.toLowerCase().contains(_query.toLowerCase()))
                    .toList();

                if (artists.isEmpty) {
                  return Center(
                    child: Text(t.gallery.noArtistFound,
                        style: AppText.caption()),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                      child: Text(
                        '${artists.length} ${artists.length == 1 ? 'ARTISTA' : 'ARTISTAS'}',
                        style: AppText.label(),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                        itemCount: artists.length,
                        itemBuilder: (context, index) =>
                            _buildArtistItem(artists[index]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(child: bottomNavBar(context, 2)),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.fg3),
          const SizedBox(height: 12),
          Text(t.ar.errorTitle, style: AppText.caption()),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(_startTimer),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.fg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(t.ar.tryAgain,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistItem(Artist artist) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRouter.artistDetails, arguments: artist),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(bottom: 20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 56,
                height: 56,
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
                            size: 24, color: AppColors.fg3),
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.fg,
                    ),
                  ),
                  if (artist.website.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      artist.website,
                      style: AppText.caption(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 16, color: AppColors.fg3),
          ],
        ),
      ),
    );
  }
}
