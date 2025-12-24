import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';
import 'package:outvisionxr/widgets/rounded_square_button.dart'; 

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  LatLng? _currentPosition;
  final Set<Marker> _markers = <Marker>{};

  static const CameraPosition _fallbackLocation = CameraPosition(
    target: LatLng(-25.4268, -49.2721),
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _addBienalMarkers();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 17.0),
      );
    }
  }

  void _addBienalMarkers() {
    _markers.addAll([
      Marker(
        markerId: const MarkerId('obra_largo'),
        position: const LatLng(-25.4268, -49.2721),
        infoWindow: const InfoWindow(title: 'Obra AR: Largo da Ordem'),
        icon: BitmapDescriptor.defaultMarkerWithHue(300.0),
      ),
      Marker(
        markerId: const MarkerId('obra_mon'),
        position: const LatLng(-25.4361, -49.2703),
        infoWindow: const InfoWindow(title: 'Obra AR: MON'),
        icon: BitmapDescriptor.defaultMarkerWithHue(300.0),
      ),
      Marker(
        markerId: const MarkerId('obra_opera'),
        position: const LatLng(-25.4425, -49.2830),
        infoWindow: const InfoWindow(title: 'Obra AR: Ópera de Arame'),
        icon: BitmapDescriptor.defaultMarkerWithHue(300.0),
      ),
    ]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _currentPosition != null 
                ? CameraPosition(target: _currentPosition!, zoom: 17)
                : _fallbackLocation,
            onMapCreated: (controller) {
              _controller.complete(controller);
              controller.setMapStyle(_grayMapStyle);
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
          ),
          Positioned(
            top: 60,
            left: 20,
            child: roundedSquareButton(Icons.help_outline, Colors.black, (){}),
          ),
          Positioned(
            top: 60,
            right: 20,
            child: roundedSquareButton(Icons.navigation, Colors.black, (){}),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavBar(context),
    );
  }

  static final String _grayMapStyle = jsonEncode([
    {"featureType": "all", "stylers": [{"saturation": -100}, {"lightness": 40}, {"gamma": 0.5}]},
    {"featureType": "poi", "stylers": [{"visibility": "off"}]}
  ]);
}

