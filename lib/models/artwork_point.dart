import 'package:google_maps_flutter/google_maps_flutter.dart';
class ArtworkPoint{final String id,title;final double lat,lng,arrivalRadiusMeters,eyeLevelOffsetMeters;final String? androidGlbUrl,iosUsdzUrl;final bool faceUser;
const ArtworkPoint({required this.id,required this.title,required this.lat,required this.lng,this.arrivalRadiusMeters=20,this.androidGlbUrl,this.iosUsdzUrl,this.eyeLevelOffsetMeters=1.5,this.faceUser=true});
LatLng get latLng=>LatLng(lat,lng);
}