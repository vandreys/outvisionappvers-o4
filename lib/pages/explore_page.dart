import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';
import 'package:outvisionxr/widgets/rounded_square_button.dart';
import 'package:outvisionxr/models/artwork_point.dart';
import 'package:outvisionxr/pages/ar/ar_experience_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  LatLng? _currentPosition;
  final Set<Marker> _markers = <Marker>{};
  StreamSubscription<Position>? _positionStream;

  bool _isLoading = true;
  String? _locationError;

  // Gate / Obra ativa
  ArtworkPoint? _activeArtwork;
  bool _gateOpen = false;
  DateTime? _enteredRadiusAt;
  late final List<ArtworkPoint> _artworks;

  // Config do gate
  static const int _minDwellSeconds = 3;
  static const double _entryRadiusMeters = 20;
  static const double _exitRadiusMeters = 25;

  @override
  void initState() {
    super.initState();

    _artworks = [
      ArtworkPoint(
        id: 'obra_largo',
        title: t.map.artworkLargo,
        lat: -25.42776745339319,
        lng: -49.2722254193995,
        arrivalRadiusMeters: _entryRadiusMeters,
      ),
      ArtworkPoint(
        id: 'obra_mon',
        title: t.map.artworkMon,
        lat: -25.431707398660244,
        lng: -49.28053248220991,
        arrivalRadiusMeters: _entryRadiusMeters,
      ),
      ArtworkPoint(
        id: 'obra_opera',
        title: t.map.artworkOpera,
        lat: -25.384375553058913,
        lng: -49.27629471973898,
        arrivalRadiusMeters: _entryRadiusMeters,
      ),
    ];

    _initLocationService();
    _addBienalMarkers();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initLocationService() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _locationError = 'Serviço de localização desativado.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _locationError = 'Permissão de localização negada.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _locationError = 'Permissão de localização negada permanentemente. Habilite nas configurações.';
        });
        return;
      }

      Position? pos;

      // 1) Tenta posição atual (com timeout)
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 8),
        );
      } catch (_) {
        // 2) Fallback: última posição conhecida
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _locationError = 'Não foi possível obter sua localização. Tente novamente.';
        });
        return;
      }

      if (!mounted) return;

      setState(() {
        _currentPosition = LatLng(pos!.latitude, pos.longitude);
        _isLoading = false;
        _locationError = null;
      });

      // Move a câmera UMA vez na inicialização
      await _moveCameraToPosition(_currentPosition!);

      // Tracking ON
      _startTracking();

      // Avalia gate já no primeiro ponto
      _updateArrivalGate(pos);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _locationError = 'Erro ao iniciar localização.';
      });
    }
  }

  void _startTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (!mounted) return;

        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        // ✅ Não move mais a câmera automaticamente (evita “grudar”)
        // _moveCameraToPosition(_currentPosition!);

        // ✅ Atualiza gate
        _updateArrivalGate(position);
      },
    );
  }

  void _updateArrivalGate(Position p) {
    if (_artworks.isEmpty) return;

    ArtworkPoint nearest = _artworks.first;
    double minDist = double.infinity;

    for (final a in _artworks) {
      final d = Geolocator.distanceBetween(p.latitude, p.longitude, a.lat, a.lng);
      if (d < minDist) {
        minDist = d;
        nearest = a;
      }
    }

    final now = DateTime.now();

    if (!_gateOpen) {
      if (minDist <= _entryRadiusMeters) {
        _enteredRadiusAt ??= now;
        final secondsInside = now.difference(_enteredRadiusAt!).inSeconds;

        if (secondsInside >= _minDwellSeconds) {
          setState(() {
            _gateOpen = true;
            _activeArtwork = nearest;
          });
        }
      } else {
        _enteredRadiusAt = null;
      }
      return;
    }

    // Gate aberto: fecha com histerese
    if (minDist >= _exitRadiusMeters) {
      setState(() {
        _gateOpen = false;
        _activeArtwork = null;
        _enteredRadiusAt = null;
      });
    }
  }

  Future<void> _moveCameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 17.0));
  }

  void _addBienalMarkers() {
    _markers.addAll([
      Marker(
        markerId: const MarkerId('obra_largo'),
        position: const LatLng(-25.42776745339319, -49.2722254193995),
        infoWindow: InfoWindow(title: t.map.artworkLargo),
        icon: BitmapDescriptor.defaultMarkerWithHue(300.0),
      ),
      Marker(
        markerId: const MarkerId('Primeira Obra'),
        position: const LatLng(-25.431707398660244, -49.28053248220991),
        infoWindow: InfoWindow(title: t.map.artworkMon),
        icon: BitmapDescriptor.defaultMarkerWithHue(300.0),
      ),
      Marker(
        markerId: const MarkerId('obra_opera'),
        position: const LatLng(-25.384375553058913, -49.27629471973898),
        infoWindow: InfoWindow(title: t.map.artworkOpera),
        icon: BitmapDescriptor.defaultMarkerWithHue(300.0),
      ),
    ]);
  }

  void _openArViewNow() {
    if (_activeArtwork == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ARExperiencePage(artwork: _activeArtwork!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.black),
                  const SizedBox(height: 20),
                  Text(
                    t.map.loadingGps,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : (_locationError != null)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _locationError!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
    
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _locationError = null;
                            });
                            _initLocationService();
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: 17,
                      ),
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
                      child: roundedSquareButton(Icons.help_outline, Colors.black, () {}),
                    ),

                    Positioned(
                      top: 60,
                      right: 20,
                      child: Column(
                        children: [
                          roundedSquareButton(Icons.add, Colors.black, () async {
                            final controller = await _controller.future;
                            controller.animateCamera(CameraUpdate.zoomIn());
                          }),
                          const SizedBox(height: 10),
                          roundedSquareButton(Icons.remove, Colors.black, () async {
                            final controller = await _controller.future;
                            controller.animateCamera(CameraUpdate.zoomOut());
                          }),
                          const SizedBox(height: 10),
                          roundedSquareButton(Icons.navigation, Colors.black, () {
                            if (_currentPosition != null) _moveCameraToPosition(_currentPosition!);
                          }),
                        ],
                      ),
                    ),

                    if (_gateOpen && _activeArtwork != null)
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 110,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'You arrived at the location of the artwork',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _activeArtwork!.title,
                                style: const TextStyle(
          
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  onPressed: _openArViewNow,
                                  child: const Text('OPEN AR VIEW NOW'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
      bottomNavigationBar: bottomNavBar(context, 0),
    );
  }

  static final String _grayMapStyle = jsonEncode([
    {"featureType": "all", "stylers": [{"saturation": -100}, {"lightness": 40}, {"gamma": 0.5}]},
    {"featureType": "poi", "stylers": [{"visibility": "off"}]},
  ]);
}