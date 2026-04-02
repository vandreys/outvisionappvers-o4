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
      return snapshot.docs
          .map((doc) => Artwork.fromFirestore(doc))
          .whereType<Artwork>() // Filtra os nulos de forma elegante
          .toList();
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