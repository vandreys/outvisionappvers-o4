import 'dart:async';
import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';

class ArtworkProximityCard extends StatefulWidget {
  final Map<String, dynamic> artworkData;
  final VoidCallback onOpenAr;
  final VoidCallback onClose;

  const ArtworkProximityCard({
    super.key,
    required this.artworkData,
    required this.onOpenAr,
    required this.onClose,
  });

  @override
  State<ArtworkProximityCard> createState() => _ArtworkProximityCardState();
}

class _ArtworkProximityCardState extends State<ArtworkProximityCard> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  List<String> get _images {
    final imgs = widget.artworkData['artworkImages'];
    if (imgs is List && imgs.isNotEmpty) {
      return List<String>.from(imgs.where((e) => e is String && e.isNotEmpty));
    }
    final url = widget.artworkData['imageUrl'] as String?;
    if (url != null && url.isNotEmpty) return [url];
    return [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (_images.length > 1) {
      _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted) return;
        final next = (_currentPage + 1) % _images.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String artworkName =
        widget.artworkData['name'] ?? context.t.map.arrivedTitle;
    final String? artistName = widget.artworkData['artist'];
    final images = _images;

    return Material(
      color: Colors.white,
      elevation: 12,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Carousel de imagens
          if (images.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (_, i) => Image.network(
                        images[i],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFEDEBE7),
                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                    if (images.length > 1)
                      Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentPage == i ? 16 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentPage == i ? Colors.white : Colors.white60,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.t.map.arrivedTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            artworkName,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (artistName != null && artistName.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              artistName,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child:
                            const Icon(Icons.close, size: 18, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: widget.onOpenAr,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: Text(context.t.map.openArButton),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
