import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:outvisionxr/models/artwork_model.dart';

class ArtworkService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Artwork>> getArtworkStream() {
    return _firestore
        .collection('artworks')
        .where('availability', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      debugPrint('🔥 Firestore snapshot: ${snapshot.docs.length} docs, fromCache=${snapshot.metadata.isFromCache}');
      final list = snapshot.docs
          .map((doc) => Artwork.fromFirestore(doc))
          .whereType<Artwork>()
          .toList();
      debugPrint('🎨 Obras parseadas: ${list.length}');
      return list;
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