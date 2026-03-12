import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:outvisionxr/i18n/strings.g.dart';

class Artwork {
  final String id;
  final Map<String, dynamic> title;
  final String? artist;
  final String? year;
  final String? imageUrl;
  final GeoPoint location;

  Artwork({
    required this.id,
    required this.title,
    this.artist,
    this.year,
    this.imageUrl,
    required this.location,
  });

  // Getter para o título localizado, simplifica o uso na UI
  String get localizedTitle {
    final currentLang = LocaleSettings.currentLocale.languageCode;
    // Fallback para 'en' e depois para um título genérico
    return title[currentLang] ?? title['en'] ?? 'Artwork';
  }

  // Factory constructor para criar uma instância de Artwork a partir de um documento do Firestore
  static Artwork? fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      return null;
    }

    // Validação de campos essenciais para a funcionalidade do mapa/AR
    final GeoPoint? location = data['location'] as GeoPoint?;
    final dynamic titleData = data['title'];

    if (location == null || titleData == null) {
      // Ignora documentos com dados essenciais ausentes
      return null;
    }
    
    Map<String, dynamic> titleMap;
    if (titleData is Map) {
      titleMap = Map<String, dynamic>.from(titleData);
    } else {
      titleMap = {'en': titleData.toString()};
    }

    return Artwork(
      id: doc.id,
      title: titleMap,
      artist: data['artist'] as String?,
      year: data['year']?.toString(),
      imageUrl: data['imageUrl'] as String?,
      location: location,
    );
  }
}