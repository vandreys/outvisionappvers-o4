import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ArtistService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getArtistStream() {
    return _firestore.collection("artists").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    });
  }
}
