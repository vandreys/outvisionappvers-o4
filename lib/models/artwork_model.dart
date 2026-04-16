import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:outvisionxr/i18n/strings.g.dart';

class Artwork {
  final String id;
  final Map<String, dynamic> title;
  final String? artist;       // campo legado: 'artist' ou 'artist_id'
  final String? artistName;   // novo: 'artist_name' (denormalizado)
  final String? year;
  final String? description;
  final String? locationName;
  final String? imageUrl;
  final GeoPoint location;
  final double arrivalRadiusMeters;
  final String availability;

  // Campos de Realidade Aumentada
  final String? androidGlbUrl;
  final String? iosUsdzUrl;
  final double? eyeLevelOffsetMeters;
  final bool? faceUser;

  Artwork({
    required this.id,
    required this.title,
    this.artist,
    this.artistName,
    this.year,
    this.description,
    this.locationName,
    this.imageUrl,
    required this.location,
    this.arrivalRadiusMeters = 20.0,
    this.availability = 'active',
    this.androidGlbUrl,
    this.iosUsdzUrl,
    this.eyeLevelOffsetMeters,
    this.faceUser,
  });

  /// Nome do artista: prefere artist_name (novo schema), fallback para artist (legado)
  String get displayArtist => artistName ?? artist ?? '';

  /// Título localizado: suporte a i18n (Map) ou string simples
  String get localizedTitle {
    final currentLang = LocaleSettings.currentLocale.languageCode;
    return title[currentLang] ?? title['en'] ?? title['pt'] ?? 'Artwork';
  }

  static Artwork? fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      // --- Leitura de localização: 3 formatos suportados ---
      GeoPoint? location;

      // 1. Novo schema: latitude/longitude como doubles top-level
      final dynamic rawLat = data['latitude'];
      final dynamic rawLng = data['longitude'];
      if (rawLat is num && rawLng is num) {
        location = GeoPoint(rawLat.toDouble(), rawLng.toDouble());
      }

      // 2. GeoPoint direto no campo 'location'
      if (location == null && data['location'] is GeoPoint) {
        location = data['location'] as GeoPoint;
      }

      // 3. Map aninhado { latitude, longitude } ou { coordenadas: "-25.4, -49.2" }
      if (location == null && data['location'] is Map) {
        final locMap = data['location'] as Map;
        dynamic lat = locMap['latitude'] ?? locMap['lat'];
        dynamic lng = locMap['longitude'] ?? locMap['lng'];

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

      if (location == null) {
        assert(() {
          debugPrint('⚠️ Obra ignorada (${doc.id}): localização inválida.');
          return true;
        }());
        return null;
      }

      // --- Título: string simples ou Map i18n ---
      final dynamic titleData = data['title'];
      if (titleData == null) {
        assert(() {
          debugPrint('⚠️ Obra ignorada (${doc.id}): campo "title" ausente.');
          return true;
        }());
        return null;
      }
      final Map<String, dynamic> titleMap = titleData is Map
          ? Map<String, dynamic>.from(titleData)
          : {'pt': titleData.toString(), 'en': titleData.toString()};

      // --- Imagem: snake_case (novo) e camelCase (legado) ---
      final String? imageUrl =
          (data['image_url'] ?? data['imageUrl'] ?? data['ImageURL']) as String?;

      // --- URLs 3D: snake_case (novo) e camelCase (legado) ---
      final String? androidGlbUrl =
          (data['android_glb_url'] ?? data['androidGlbUrl']) as String?;
      final String? iosUsdzUrl =
          (data['ios_usdz_url'] ?? data['iosUsdzUrl']) as String?;

      // --- AR params: snake_case (novo) e camelCase (legado) ---
      final double? eyeLevel =
          ((data['eye_level_offset_meters'] ?? data['eyeLevelOffsetMeters']) as num?)
              ?.toDouble();
      final bool? faceUser =
          (data['face_user'] ?? data['faceUser']) as bool?;

      // artist: tenta string simples; ignora DocumentReference (usa artistName nesses casos)
      String? artist;
      final rawArtist = data['artist'];
      if (rawArtist is String && rawArtist.isNotEmpty) artist = rawArtist;

      return Artwork(
        id: doc.id,
        title: titleMap,
        artist: artist,
        artistName: data['artist_name'] as String?,
        year: (data['year'] ?? data['Year'])?.toString(),
        description: data['description'] as String?,
        locationName: data['location_name'] as String?,
        imageUrl: imageUrl?.isNotEmpty == true ? imageUrl : null,
        location: location,
        arrivalRadiusMeters:
            (data['arrival_radius_meters'] as num?)?.toDouble() ?? 20.0,
        availability: (data['availability'] is String) ? data['availability'] as String : 'active',
        androidGlbUrl: androidGlbUrl?.isNotEmpty == true ? androidGlbUrl : null,
        iosUsdzUrl: iosUsdzUrl?.isNotEmpty == true ? iosUsdzUrl : null,
        eyeLevelOffsetMeters: eyeLevel,
        faceUser: faceUser,
      );
    } catch (e) {
      assert(() {
        debugPrint('❌ Erro ao processar obra (${doc.id}): $e');
        return true;
      }());
      return null;
    }
  }
}
