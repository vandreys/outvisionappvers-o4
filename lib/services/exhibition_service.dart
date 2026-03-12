import 'package:cloud_firestore/cloud_firestore.dart';

class ExhibitionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getExhibitionsStream() {
    return _firestore.collection('artworks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "title": data['title'] ?? '',
          "artist": data['artist'] ?? '',
          "year": data['year'] ?? '',
          "imageUrl": data['imageUrl'], // Pode ser null, a UI trata isso
          "location": data['location'] ?? '',
        };
      }).toList();
    });
  }
}