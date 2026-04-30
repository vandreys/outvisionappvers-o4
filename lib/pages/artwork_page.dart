import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:outvisionxr/widgets/shimmer_box.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArtworkPage extends StatefulWidget {
  const ArtworkPage({super.key});

  @override
  State<ArtworkPage> createState() => _ArtworkPageState();
}

class _ArtworkPageState extends State<ArtworkPage> {
  Stream<List<Artwork>>? _artworkStream;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _isGridView = true;
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
    _loadViewPref();
  }

  Future<void> _loadViewPref() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) setState(() => _isGridView = prefs.getBool('artwork_grid_view') ?? true);
  }

  Future<void> _toggleView() async {
    final next = !_isGridView;
    setState(() => _isGridView = next);
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('artwork_grid_view', next);
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
                          t.gallery.tabArtwork,
                          style: AppText.display(fontSize: Rsp.fs(context, 40)),
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleView,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.bg2,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            _isGridView
                                ? Icons.view_list_outlined
                                : Icons.grid_view_outlined,
                            size: 16,
                            color: AppColors.fg,
                          ),
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
            child: StreamBuilder<List<Artwork>>(
              stream: _artworkStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  if (_timedOut) return _buildError();
                  return _isGridView ? _buildShimmerGrid() : _buildShimmerList();
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
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
                      child: Text(
                        '${artworks.length} ${artworks.length == 1 ? 'OBRA' : 'OBRAS'}',
                        style: AppText.label(),
                      ),
                    ),
                    Expanded(
                      child: _isGridView
                          ? _buildGrid(artworks)
                          : _buildList(artworks),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(child: bottomNavBar(context, 1)),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ShimmerBox(borderRadius: BorderRadius.zero)),
          const SizedBox(height: 8),
          ShimmerBox(height: 14, borderRadius: BorderRadius.circular(3)),
          const SizedBox(height: 4),
          ShimmerBox(height: 11, width: 80, borderRadius: BorderRadius.circular(3)),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(
          children: [
            ShimmerBox(width: 68, height: 68, borderRadius: BorderRadius.circular(4)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 15, borderRadius: BorderRadius.circular(3)),
                  const SizedBox(height: 6),
                  ShimmerBox(height: 11, width: 120, borderRadius: BorderRadius.circular(3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Artwork> artworks) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
        childAspectRatio: 0.72,
      ),
      itemCount: artworks.length,
      itemBuilder: (context, index) => FadeSlideIn(
        index: index,
        child: _buildGridItem(artworks[index]),
      ),
    );
  }

  Widget _buildGridItem(Artwork artwork) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.artworkDetails,
        arguments: artwork.id,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: SizedBox.expand(
                child: artwork.imageUrl != null &&
                        artwork.imageUrl!.isNotEmpty
                    ? Image.network(
                        artwork.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) =>
                            progress == null ? child : const ShimmerBox(),
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.bg2),
                      )
                    : Container(color: AppColors.bg2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artwork.localizedTitle,
            style: AppText.display(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            [
              if (artwork.displayArtist.isNotEmpty) artwork.displayArtist,
              if (artwork.year != null && artwork.year!.isNotEmpty)
                artwork.year!,
            ].join(' · '),
            style: AppText.caption(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Artwork> artworks) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
      itemCount: artworks.length,
      itemBuilder: (context, index) => FadeSlideIn(
        index: index,
        child: _buildListItem(artworks[index]),
      ),
    );
  }

  Widget _buildListItem(Artwork artwork) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRouter.artworkDetails,
        arguments: artwork.id,
      ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.only(bottom: 18),
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 68,
                height: 68,
                child: artwork.imageUrl != null &&
                        artwork.imageUrl!.isNotEmpty
                    ? Image.network(
                        artwork.imageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) =>
                            progress == null ? child : const ShimmerBox(),
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.bg2),
                      )
                    : Container(color: AppColors.bg2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    artwork.localizedTitle,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.fg,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    artwork.displayArtist.isNotEmpty
                        ? artwork.displayArtist
                        : t.gallery.unknownArtist,
                    style: AppText.caption(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (artwork.year != null && artwork.year!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      artwork.year!,
                      style: AppText.caption(color: AppColors.accent),
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
              child: Text(
                t.ar.tryAgain,
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
}
