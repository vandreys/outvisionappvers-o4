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
import 'package:outvisionxr/widgets/artwork_proximity_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  LatLng? _currentPosition;
  Set<Marker> _markers = <Marker>{};
  StreamSubscription<Position>? _positionStream;

  bool _isLoading = true;
  String? _locationError;

  // Controle para ocultar o mapa ao abrir AR (evita conflito de GPU)
  bool _isArActive = false;

  // Gate / Obra ativa
  ArtworkPoint? _activeArtwork;
  bool _gateOpen = false;
  DateTime? _enteredRadiusAt;
  List<ArtworkPoint> _artworks = [];
  Map<String, dynamic>? _nearbyArtwork;

  // Config do gate
  static const int _minDwellSeconds = 3;
  static const double _entryRadiusMeters = 20;
  static const double _exitRadiusMeters = 25;

  @override
  void initState() {
    super.initState();

    _initLocationService();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Atualiza as obras e marcadores sempre que as dependências (como idioma) mudam
    _updateArtworksData();
  }

  void _updateArtworksData() {
    _artworks = [
      ArtworkPoint(
        id: 'obra_largo',
        title: t.map.artworkLargo,
        lat: -26.294514160515284,
        lng: -48.85139160184969,
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
    _updateMarkers();
  }

  Future<void> _initLocationService() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _locationError = t.map.locationServiceDisabled;
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
          _locationError = t.map.locationPermissionDenied;
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _locationError = t.map.locationPermissionPermanentlyDenied;
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
          _locationError = t.map.locationNotFound;
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
        _locationError = t.map.locationError;
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

        // OTIMIZAÇÃO: Atualizamos a variável sem setState para evitar rebuilds desnecessários do Mapa.
        _currentPosition = LatLng(position.latitude, position.longitude);

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
            _nearbyArtwork = {
              'id': nearest.id,
              'name': nearest.title,
              // 'imageUrl': '', // Futuramente você preencherá isso com dados do Firebase
            };
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
        _nearbyArtwork = null;
      });
    }
  }

  Future<void> _moveCameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 17.0));
  }

  void _updateMarkers() {
    // Recria o Set de marcadores para garantir que o Google Maps detecte a mudança
    setState(() {
      _markers = _artworks.map((artwork) {
      return Marker(
        markerId: MarkerId(artwork.id),
        position: LatLng(artwork.lat, artwork.lng),
        infoWindow: InfoWindow(title: artwork.title),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      );
      }).toSet();
    });
  }

  Future<void> _openArViewNow() async {
    if (_activeArtwork == null) return;

    // 1. Oculta o mapa para liberar recursos da GPU (SurfaceView)
    setState(() {
      _isArActive = true;
    });

    // Pequeno delay para garantir que o widget do mapa foi desmontado pelo Flutter
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ARExperiencePage(artwork: _activeArtwork!)),
    );

    // 2. Ao voltar, recria o controller e exibe o mapa novamente
    if (mounted) {
      _controller = Completer<GoogleMapController>();
      setState(() {
        _isArActive = false;
      });
    }
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
                          child: Text(t.ar.tryAgain),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    if (!_isArActive)
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
                    )
                    else
                      Container(color: const Color(0xFFE5E5E5)), // Placeholder visual enquanto navega

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

                    if (_nearbyArtwork != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ArtworkProximityCard(
                          artworkData: _nearbyArtwork!,
                          onClose: () {
                            setState(() => _nearbyArtwork = null);
                          },
                          onOpenAr: () {
                            _openArViewNow();
                            setState(() => _nearbyArtwork = null);
                          },
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