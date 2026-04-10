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
          final allDocs = snapshot.docs;
          final parsed = allDocs.map((doc) => Artwork.fromFirestore(doc)).toList();
          final valid = parsed.whereType<Artwork>().toList();
          final active = valid.where((a) => a.availability == 'active').toList();

          debugPrint('🔍 ArtworkService: ${allDocs.length} docs | ${valid.length} parseados | ${active.length} ativos');
          for (final a in valid) {
            debugPrint('   📍 ${a.id}: availability="${a.availability}"');
          }
          if (parsed.length != valid.length) {
            debugPrint('   ⚠️ ${parsed.length - valid.length} docs ignorados por erro de parse (localização/título ausente)');
          }

          return active;
        });
  }

  Future<Artwork?> getArtworkById(String id) async {
    final doc = await _firestore.collection("artworks").doc(id).get();
    if (doc.exists) {
      return Artwork.fromFirestore(doc);
    }
    return null;
  }
}
