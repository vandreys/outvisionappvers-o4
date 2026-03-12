import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ArtworkService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getArtworkStream() {
    // Supondo que sua coleção de obras de arte se chame 'artworks'
    return _firestore.collection("artworks").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // É uma boa prática incluir o ID do documento junto com os dados
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}