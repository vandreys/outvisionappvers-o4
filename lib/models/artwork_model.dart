import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:outvisionxr/i18n/strings.g.dart';

class Artwork {
  final String id;
  final Map<String, dynamic> title;
  final String? artist;
  final String? year;
  final String? imageUrl;
  final GeoPoint location;
  
  // Campos de Realidade Aumentada
  final String? androidGlbUrl;
  final String? iosUsdzUrl;
  final double? eyeLevelOffsetMeters;
  final bool? faceUser;

  Artwork({
    required this.id,
    required this.title,
    this.artist,
    this.year,
    this.imageUrl,
    required this.location,
    this.androidGlbUrl,
    this.iosUsdzUrl,
    this.eyeLevelOffsetMeters,
    this.faceUser,
  });

  // Getter para o título localizado, simplifica o uso na UI
  String get localizedTitle {
    final currentLang = LocaleSettings.currentLocale.languageCode;
    // Fallback para 'en' e depois para um título genérico
    return title[currentLang] ?? title['en'] ?? 'Artwork';
  }

  // Factory constructor para criar uma instância de Artwork a partir de um documento do Firestore
  static Artwork? fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;

      if (data == null) {
        return null;
      }

      // --- CORREÇÃO: Tenta ler location como GeoPoint ou Map (latitude/longitude) ---
      GeoPoint? location;
      
      if (data['location'] is GeoPoint) {
        location = data['location'] as GeoPoint;
      } else if (data['location'] is Map) {
        // Suporte para dados importados como JSON simples (ex: {latitude: 10, longitude: 20})
        final locMap = data['location'] as Map;
        dynamic lat = locMap['latitude'] ?? locMap['lat'];
        dynamic lng = locMap['longitude'] ?? locMap['lng'];
        
        // Suporte para campo 'coordenadas' em string (ex: "-25.43, -49.28")
        if (lat == null || lng == null) {
          final coords = locMap['coordenadas'];
          if (coords is String) {
            final parts = coords.split(',');
            if (parts.length >= 2) {
              lat = double.tryParse(parts[0].trim());
              lng = double.tryParse(parts[1].trim());
            }
          }
        }
        
        if (lat is num && lng is num) {
          location = GeoPoint(lat.toDouble(), lng.toDouble());
        }
      }

      final dynamic titleData = data['title'];

      if (location == null) {
        debugPrint('⚠️ Obra ignorada (${doc.id}): Campo "location" inválido ou ausente. Recebido: ${data['location']}');
        return null;
      }
      
      if (titleData == null) {
        debugPrint('⚠️ Obra ignorada (${doc.id}): Campo "title" ausente.');
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
        artist: (data['artist'] ?? data['artist_id']) as String?,
        year: (data['year'] ?? data['Year'])?.toString(),
        imageUrl: (data['imageUrl'] ?? data['ImageURL']) as String?,
        location: location,
        androidGlbUrl: data['androidGlbUrl'] as String?,
        iosUsdzUrl: data['iosUsdzUrl'] as String?,
        eyeLevelOffsetMeters: (data['eyeLevelOffsetMeters'] as num?)?.toDouble(),
        faceUser: data['faceUser'] as bool?,
      );
    } catch (e) {
      debugPrint('❌ Erro ao processar obra (${doc.id}): $e');
      return null;
    }
  }
}