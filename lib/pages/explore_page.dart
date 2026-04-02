import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';
import 'package:outvisionxr/widgets/rounded_square_button.dart';
import 'package:outvisionxr/models/artwork_point.dart';
import 'package:outvisionxr/pages/ar/ar_experience_page.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/widgets/artwork_proximity_card.dart';
import 'package:outvisionxr/pages/settings_page.dart';
import 'package:provider/provider.dart';


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
  StreamSubscription<List<Artwork>>? _artworkSubscription;


  bool _isLoading = true;
  String? _locationError;

  // Controle para ocultar o mapa ao abrir AR (evita conflito de GPU)
  bool _isArActive = false;

  // Gate / Obra ativa
  ArtworkPoint? _activeArtwork;
  bool _gateOpen = false;
  DateTime? _enteredRadiusAt;
  List<ArtworkPoint> _artworkPoints = []; // Lista processada para o mapa
  List<Artwork> _rawArtworks = []; // Lista de models vinda do Service
  Map<String, dynamic>? _nearbyArtwork;

  // Config do gate
  static const int _minDwellSeconds = 3;
  static const double _entryRadiusMeters = 20;
  static const double _exitRadiusMeters = 25;

  @override
  void initState() {
    super.initState();

    _initLocationService();
    _listenToArtworks();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _artworkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Se já tivermos os dados, reprocessa para atualizar os títulos com o idioma atual
    if (_rawArtworks.isNotEmpty) {
      _processAndSetArtworks();
    }
  }

  void _listenToArtworks() {
    final artworkService = Provider.of<ArtworkService>(context, listen: false);
    _artworkSubscription = artworkService.getArtworkStream().listen((artworks) {
      if (!mounted) return;
      setState(() {
        _rawArtworks = artworks;
      });
      _processAndSetArtworks();
    }, onError: (error) {
      debugPrint("Erro ao buscar obras de arte: $error");
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro de conexão: $error"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }

  void _processAndSetArtworks() {
    // Converte o modelo Artwork para o modelo ArtworkPoint, usado pelo mapa/gate.
    // A lógica de localização do título agora está no modelo Artwork.
    final artworkPoints = _rawArtworks.map((artwork) {
      return ArtworkPoint(
        id: artwork.id,
        title: artwork.localizedTitle, // Usa o getter do modelo
        lat: artwork.location.latitude,
        lng: artwork.location.longitude,
        arrivalRadiusMeters: _entryRadiusMeters,
      );
    }).toList();

    setState(() => _artworkPoints = artworkPoints);
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

        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });

        // ✅ Atualiza gate
        _updateArrivalGate(position);
      },
    );
  }

  void _updateArrivalGate(Position p) {
    if (_artworkPoints.isEmpty) return;

    ArtworkPoint nearest = _artworkPoints.first;
    double minDist = double.infinity;

    for (final a in _artworkPoints) {
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
          // OTIMIZAÇÃO: Só chama setState se o gate ainda não estava aberto ou se a obra mudou
          if (_gateOpen && _activeArtwork?.id == nearest.id) return;

          Artwork? fullArtworkModel;
          try {
            fullArtworkModel = _rawArtworks.firstWhere((raw) => raw.id == nearest.id);
          } catch (e) {
            fullArtworkModel = null;
          }

          if (fullArtworkModel != null) {
            setState(() {
              _gateOpen = true;
              _activeArtwork = nearest;
              _nearbyArtwork = {
                'id': fullArtworkModel!.id,
                'name': nearest.title,
                'artist': fullArtworkModel.displayArtist,
                'imageUrl': fullArtworkModel.imageUrl ?? '',
              };
            });
          }
        }
      } else {
        _enteredRadiusAt = null;
      }
      return;
    }

    // Gate aberto: fecha com histerese
    if (minDist >= _exitRadiusMeters) {
      // OTIMIZAÇÃO: Só chama setState se o gate estava aberto
      if (!_gateOpen) return;

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
      _markers = _artworkPoints.map((artwork) {
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
    final point = _activeArtwork;
    if (point == null) return;

    // Busca o objeto Artwork completo (com URL do modelo 3D) na lista carregada
    Artwork? artworkModel;
    try {
      artworkModel = _rawArtworks.firstWhere((a) => a.id == point.id);
    } catch (_) {
      return; // Segurança: Se não encontrar a obra na lista, não abre
    }

    // 1. Oculta o mapa para liberar recursos da GPU (SurfaceView)
    setState(() {
      _isArActive = true;
    });

    // Pequeno delay para garantir que o widget do mapa foi desmontado pelo Flutter
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ARExperiencePage(artwork: artworkModel!)),
    );

    // 2. Ao voltar da experiência AR, reexibe o mapa e reseta o estado do gate.
    if (mounted) {
      _controller = Completer<GoogleMapController>();
      setState(() {
        _isArActive = false;
        _gateOpen = false;
        _activeArtwork = null;
        _enteredRadiusAt = null;
        _nearbyArtwork = null;
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
                      style: _grayMapStyle,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition!,
                        zoom: 17,
                      ),
                      onMapCreated: (controller) {
                        _controller.complete(controller);
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
                      child: roundedSquareButton(Icons.menu, Colors.black, () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              const begin = Offset(-1.0, 0.0);
                              const end = Offset.zero;        // Termina no centro
                              const curve = Curves.ease;

                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      }),
                    ),

                    Positioned(
                      top: 60,
                      right: 20,
                      child: roundedSquareButton(Icons.navigation, Colors.black, () {
                        if (_currentPosition != null) {
                          _moveCameraToPosition(_currentPosition!);
                        }
                      }),
                    ),

                    if (_nearbyArtwork != null)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ArtworkProximityCard(
                          artworkData: _nearbyArtwork!,
                          onClose: () {
                            // Reseta completamente o estado do gate para que ele possa ser reativado
                            setState(() {
                              _gateOpen = false;
                              _activeArtwork = null;
                              _enteredRadiusAt = null;
                              _nearbyArtwork = null;
                            });
                          },
                          onOpenAr: () {
                            _openArViewNow();
                          },
                        ),
                      ),
                  ],
                ),
      bottomNavigationBar: SafeArea(
        child: bottomNavBar(context, 0),
      ),
    );
  }

  static final String _grayMapStyle = jsonEncode([
    {"featureType": "all", "stylers": [{"saturation": -100}, {"lightness": 40}, {"gamma": 0.5}]},
    {"featureType": "poi", "stylers": [{"visibility": "off"}]},
  ]);
}

class UserLocationDot extends StatelessWidget {
  const UserLocationDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue.withAlpha(51), // aura azul
        ),
        child: Center(
          child: Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}