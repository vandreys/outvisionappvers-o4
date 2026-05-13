import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:outvisionxr/models/artwork_model.dart';

class DownloadService extends ChangeNotifier {
  static const _prefKey = 'offline_artworks';

  final _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 30)));
  final Map<String, double> _progress = {}; // artworkId → 0.0–1.0
  final Set<String> _downloading = {};

  double progressOf(String artworkId) => _progress[artworkId] ?? 0.0;
  bool isDownloading(String artworkId) => _downloading.contains(artworkId);

  Future<Set<String>> offlineArtworkIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefKey)?.toSet() ?? {};
  }

  Future<bool> isOffline(String artworkId) async =>
      (await offlineArtworkIds()).contains(artworkId);

  Future<Directory> _artworkDir(String artworkId) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/offline/$artworkId');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<void> download(Artwork artwork) async {
    if (_downloading.contains(artwork.id)) return;
    _downloading.add(artwork.id);
    _progress[artwork.id] = 0.0;
    notifyListeners();

    try {
      final dir = await _artworkDir(artwork.id);
      final urls = _urlsToDownload(artwork);
      if (urls.isEmpty) {
        await _markOffline(artwork.id);
        return;
      }

      for (var i = 0; i < urls.length; i++) {
        final entry = urls[i];
        final dest = File('${dir.path}/${entry.key}');
        if (!dest.existsSync()) {
          await _dio.download(
            entry.value,
            dest.path,
            onReceiveProgress: (rcv, total) {
              if (total > 0) {
                final fileProgress = rcv / total;
                _progress[artwork.id] =
                    (i + fileProgress) / urls.length;
                notifyListeners();
              }
            },
          );
        }
      }
      _progress[artwork.id] = 1.0;
      await _markOffline(artwork.id);
    } catch (e) {
      debugPrint('DownloadService: erro ao baixar ${artwork.id}: $e');
      _progress.remove(artwork.id);
    } finally {
      _downloading.remove(artwork.id);
      notifyListeners();
    }
  }

  Future<void> remove(String artworkId) async {
    final dir = await _artworkDir(artworkId);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    await _unmarkOffline(artworkId);
    _progress.remove(artworkId);
    notifyListeners();
  }

  /// Retorna path local do modelo se disponível, senão null (usa URL remota).
  Future<String?> localModelPath(String artworkId, String ext) async {
    final dir = await _artworkDir(artworkId);
    final file = File('${dir.path}/model.$ext');
    return file.existsSync() ? file.path : null;
  }

  Future<String?> localVideoPath(String artworkId) async {
    final dir = await _artworkDir(artworkId);
    final file = File('${dir.path}/video.mp4');
    return file.existsSync() ? file.path : null;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<MapEntry<String, String>> _urlsToDownload(Artwork artwork) {
    final list = <MapEntry<String, String>>[];
    if (artwork.videoUrl != null) {
      list.add(MapEntry('video.mp4', artwork.videoUrl!));
    } else {
      if (Platform.isAndroid && artwork.androidGlbUrl != null) {
        list.add(MapEntry('model.glb', artwork.androidGlbUrl!));
      }
      if (Platform.isIOS && artwork.iosUsdzUrl != null) {
        list.add(MapEntry('model.usdz', artwork.iosUsdzUrl!));
      }
    }
    return list;
  }

  Future<void> _markOffline(String artworkId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_prefKey) ?? [];
    if (!ids.contains(artworkId)) {
      ids.add(artworkId);
      await prefs.setStringList(_prefKey, ids);
    }
    notifyListeners();
  }

  Future<void> _unmarkOffline(String artworkId) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_prefKey) ?? [];
    ids.remove(artworkId);
    await prefs.setStringList(_prefKey, ids);
    notifyListeners();
  }
}
