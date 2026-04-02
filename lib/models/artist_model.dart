import 'package:cloud_firestore/cloud_firestore.dart';

class Artist {
  final String id;
  final String name;
  final String bio;
  final String artistPhoto;
  final String location;
  final String website;

  const Artist({
    required this.id,
    required this.name,
    this.bio = '',
    this.artistPhoto = '',
    this.location = '',
    this.website = '',
  });

  factory Artist.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Artist(
      id: doc.id,
      name: data['name'] as String? ?? '',
      // Suporta campo novo 'bio' e campo legado 'text_about_artist'
      bio: (data['bio'] ?? data['text_about_artist'] ?? '') as String,
      artistPhoto: (data['artist_photo'] ?? '') as String,
      // Suporta campo novo 'location' e campo legado 'location_artist'
      location: (data['location'] ?? data['location_artist'] ?? '') as String,
      website: (data['website'] ?? '') as String,
    );
  }

  /// Converte para Map para compatibilidade com páginas que ainda usam Map<String, dynamic>
  Map<String, dynamic> toMap() => {
    'name': name,
    'bio': bio,
    'text_about_artist': bio,
    'artist_photo': artistPhoto,
    'location': location,
    'location_artist': location,
    'website': website,
  };
}
