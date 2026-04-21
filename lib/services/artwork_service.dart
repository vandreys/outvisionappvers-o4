import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:outvisionxr/models/artwork_model.dart';

class ArtworkService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Artwork>> getArtworkStream() {
    return _firestore
        .collection('artworks')
        .snapshots()
        .map((snapshot) {
          final parsed = <Artwork>[];
          for (final doc in snapshot.docs) {
            try {
              final artwork = Artwork.fromFirestore(doc);
              if (artwork != null) parsed.add(artwork);
            } catch (e) {
              debugPrint('ArtworkService: erro ao parsear doc ${doc.id}: $e');
            }
          }
          final active = parsed.where((a) => a.availability == 'active').toList();
          if (kDebugMode) {
            debugPrint('ArtworkService: ${snapshot.docs.length} docs | ${parsed.length} parseados | ${active.length} ativos');
          }
          return active;
        });
  }

  Future<Artwork?> getArtworkById(String id) async {
    try {
      final doc = await _firestore.collection('artworks').doc(id).get();
      if (doc.exists) return Artwork.fromFirestore(doc);
      return null;
    } catch (e) {
      debugPrint('ArtworkService.getArtworkById error: $e');
      return null;
    }
  }
}
