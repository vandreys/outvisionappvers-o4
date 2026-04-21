import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:outvisionxr/models/artist_model.dart';

class ArtistService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Artist>>? _cachedStream;

  Stream<List<Artist>> getArtistStream() {
    return _cachedStream ??= _firestore
        .collection('artists')
        .orderBy('name')
        .snapshots()
        .map<List<Artist>>((snapshot) =>
            snapshot.docs.map((doc) => Artist.fromFirestore(doc)).toList())
        .asBroadcastStream();
  }
}
