import 'package:cloud_firestore/cloud_firestore.dart';

class Artist {
  final String id;
  final String name;
  final Map<String, String> bioMap;
  final String artistPhoto;
  final String website;

  Artist({
    required this.id,
    required this.name,
    this.bioMap = const {'en': '', 'pt': '', 'es': ''},
    this.artistPhoto = '',
    this.website = '',
  });

  factory Artist.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    Map<String, String> bioMap = {'en': '', 'pt': '', 'es': ''};
    final rawBio = data['bio'] ?? data['text_about_artist'] ?? '';
    if (rawBio is String) {
      // Formato legado: string única — usa em todos os idiomas
      bioMap = {'en': rawBio, 'pt': rawBio, 'es': rawBio};
    } else if (rawBio is Map) {
      // Formato novo: mapa {en, pt, es}
      bioMap = {
        'en': (rawBio['en'] ?? '') as String,
        'pt': (rawBio['pt'] ?? '') as String,
        'es': (rawBio['es'] ?? '') as String,
      };
    }

    return Artist(
      id: doc.id,
      name: data['name'] as String? ?? '',
      bioMap: bioMap,
      artistPhoto: (data['artist_photo'] ?? '') as String,
      website: (data['website'] ?? '') as String,
    );
  }

  /// Retorna o bio no idioma solicitado, com fallback para EN e depois qualquer disponível.
  String getBio(String languageCode) {
    final text = bioMap[languageCode] ?? '';
    if (text.isNotEmpty) return text;
    final en = bioMap['en'] ?? '';
    if (en.isNotEmpty) return en;
    return bioMap.values.firstWhere((v) => v.isNotEmpty, orElse: () => '');
  }

  /// Acesso direto ao bio (usa EN como padrão) — mantém compatibilidade.
  String get bio => getBio('en');

  Map<String, dynamic> toMap() => {
        'name': name,
        'bio': bioMap,
        'text_about_artist': bio,
        'artist_photo': artistPhoto,
        'website': website,
      };
}
