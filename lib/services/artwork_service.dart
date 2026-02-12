import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArtworkService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getArtworkStream() {
    return _firestore.collection("artworks").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    });
  }
}  