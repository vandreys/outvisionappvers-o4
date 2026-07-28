import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:outvisionxr/widgets/splash_loading.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';
import 'package:outvisionxr/widgets/rounded_square_button.dart';
import 'package:outvisionxr/models/artwork_point.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/utils/app_theme.dart';


class ExplorePage extends StatefulWidget {
  final String? initialArtworkId;
  const ExplorePage({super.key, this.initialArtworkId});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
  // Cache estático: persiste entre recriações do widget ao navegar
  static bool _hasInitialized = false;
  static LatLng? _cachedPosition;

  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  LatLng? _currentPosition;
  Set<Marker> _markers = <Marker>{};
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<List<Artwork>>? _artworkSubscription;


  bool _isLoading = true;
  String? _locationError;

  // Controle para ocultar o mapa ao abrir AR (evita conflito de GPU)
  bool _isArActive = false;

  // Gate / Obras dentro do raio
  final Set<String> _nearbyIds = <String>{};          // no raio, com dwell cumprido
  final Map<String, DateTime> _enteredRadiusAt = {};  // início da permanência, por obra
  final Set<String> _dismissedIds = <String>{};       // dispensadas até sair do raio
  String? _autoArtworkId;   // obra sugerida pelo gate
  bool _userPinned = false; // seleção veio de toque → o gate não sobrescreve

  List<ArtworkPoint> _artworkPoints = []; // Lista processada para o mapa
  List<Artwork> _rawArtworks = []; // Lista de models vinda do Service

  // Marcador selecionado por toque
  String? _selectedArtworkId;
  Map<String, dynamic>? _selectedArtworkData;

  bool _initialSelectionDone = false;

  // Config do gate
  static const int _minDwellSeconds = 3;
  static const double _entryRadiusMeters = 150;
  static const double _exitRadiusMeters = 155;
  // Margem mínima para trocar a obra sugerida. Sem ela, duas obras no mesmo
  // raio se revezam a cada leitura do GPS e o card fica alternando sozinho.
  static const double _switchMarginMeters = 30;

  @override
  void initState() {
    super.initState();

    // Se já inicializou antes e tem posição em cache, pula o loading
    if (_hasInitialized && _cachedPosition != null) {
      _isLoading = false;
      _currentPosition = _cachedPosition;
    }

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
      assert(() {
        debugPrint("Erro ao buscar obras de arte: $error");
        return true;
      }());
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.map.connectionError),
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

    // Seleciona a obra inicial vinda do botão "ver no mapa"
    if (!_initialSelectionDone && widget.initialArtworkId != null) {
      final point = artworkPoints.where((p) => p.id == widget.initialArtworkId).firstOrNull;
      if (point != null) {
        _initialSelectionDone = true;
        _onMarkerTapped(point);
        _controller.future.then((controller) {
          controller.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(point.lat, point.lng), 18.0,
          ));
        });
      }
    }
  }

  Future<BitmapDescriptor> _buildDiamondMarker(String? imageUrl, {bool isSelected = false}) async {
    const double size = 45;
    const double border = 3;
    const double radius = size / 2;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    const center = Offset(radius, radius);

    // Sombra
    canvas.drawCircle(center, radius, Paint()
      ..color = Colors.black26
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3));

    // Borda: preta se selecionado, cinza se não
    final borderColor = isSelected ? Colors.black : const Color(0xFFBBBBBB);
    canvas.drawCircle(center, radius, Paint()..color = borderColor);

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final imageProvider = NetworkImage(imageUrl);
        final imageStream = imageProvider.resolve(ImageConfiguration.empty);
        final completer = Completer<ui.Image>();
        late ImageStreamListener listener;
        listener = ImageStreamListener(
          (info, _) {
            completer.complete(info.image);
            imageStream.removeListener(listener);
          },
          onError: (e, _) {
            if (!completer.isCompleted) completer.completeError(e);
            imageStream.removeListener(listener);
          },
        );
        imageStream.addListener(listener);

        final image = await completer.future.timeout(const Duration(seconds: 6));

        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius - border)));
        final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
        const dst = Rect.fromLTWH(border, border, size - border * 2, size - border * 2);
        canvas.drawImageRect(image, src, dst, Paint());
        canvas.restore();
      } catch (_) {
        canvas.drawCircle(center, radius - border, Paint()..color = AppColors.fg);
      }
    } else {
      canvas.drawCircle(center, radius - border, Paint()..color = AppColors.fg);
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
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

      // Salva no cache estático para não mostrar loading ao voltar à página
      _hasInitialized = true;
      _cachedPosition = _currentPosition;

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

        _cachedPosition = LatLng(position.latitude, position.longitude);
        setState(() {
          _currentPosition = _cachedPosition;
        });

        // ✅ Atualiza gate
        _updateArrivalGate(position);
      },
      onError: (error) {
        assert(() {
          debugPrint('❌ Erro no stream de localização: $error');
          return true;
        }());
      },
    );
  }

  void _updateArrivalGate(Position p) {
    if (_artworkPoints.isEmpty) return;

    final now = DateTime.now();
    final distances = <String, double>{
      for (final a in _artworkPoints)
        a.id: Geolocator.distanceBetween(p.latitude, p.longitude, a.lat, a.lng),
    };

    // 1) Cada obra entra e sai do raio de forma independente — várias podem
    //    estar próximas ao mesmo tempo.
    var nearbyChanged = false;
    for (final a in _artworkPoints) {
      final d = distances[a.id]!;
      if (_nearbyIds.contains(a.id)) {
        if (d >= _exitRadiusMeters) {
          _nearbyIds.remove(a.id);
          _enteredRadiusAt.remove(a.id);
          _dismissedIds.remove(a.id); // sair do raio rearma a obra
          nearbyChanged = true;
        }
      } else if (d <= _entryRadiusMeters) {
        final since = _enteredRadiusAt[a.id] ??= now;
        if (now.difference(since).inSeconds >= _minDwellSeconds) {
          _nearbyIds.add(a.id);
          nearbyChanged = true;
        }
      } else {
        _enteredRadiusAt.remove(a.id);
      }
    }

    // 2) Sugere uma obra entre as que estão no raio, mantendo a atual enquanto
    //    ela continuar próxima: só troca se outra estiver claramente mais perto.
    final candidates =
        _nearbyIds.where((id) => !_dismissedIds.contains(id)).toList()
          ..sort((a, b) => distances[a]!.compareTo(distances[b]!));

    String? suggested;
    if (candidates.isNotEmpty) {
      final closest = candidates.first;
      final current = _autoArtworkId;
      final keepCurrent = current != null &&
          candidates.contains(current) &&
          distances[closest]! > distances[current]! - _switchMarginMeters;
      suggested = keepCurrent ? current : closest;
    }
    _autoArtworkId = suggested;

    // 3) O gate só mexe no card quando o usuário não escolheu uma obra na mão.
    if (!_userPinned) {
      if (suggested != null) {
        if (_selectedArtworkId != suggested) {
          _selectArtwork(suggested, pinned: false);
          return;
        }
      } else if (_selectedArtworkId != null) {
        setState(() {
          _selectedArtworkId = null;
          _selectedArtworkData = null;
        });
        _updateMarkers();
        return;
      }
    }

    // Reflete no card a mudança de "obras aqui" (contador / botão de AR).
    if (nearbyChanged && mounted) setState(() {});
  }

  void _selectArtwork(String id,
      {required bool pinned, bool moveCamera = false}) {
    final point = _artworkPoints.where((p) => p.id == id).firstOrNull;
    if (point == null) return;
    final raw = _rawArtworks.where((a) => a.id == id).firstOrNull;

    setState(() {
      _userPinned = pinned;
      _selectedArtworkId = id;
      _selectedArtworkData = {
        'id': id,
        'name': point.title,
        'artist': raw?.displayArtist ?? '',
        'imageUrl': raw?.imageUrl ?? '',
        'locationName': raw?.locationName ?? '',
        'lat': point.lat,
        'lng': point.lng,
      };
    });
    _updateMarkers();
    if (moveCamera) _moveCameraToPosition(LatLng(point.lat, point.lng));
  }

  // Alterna entre as obras que dividem o mesmo raio, sob comando do usuário.
  void _cycleNearby() {
    final ids = _nearbyIds.toList()..sort();
    if (ids.length < 2) return;
    final next = ids[(ids.indexOf(_selectedArtworkId ?? '') + 1) % ids.length];
    _dismissedIds.remove(next);
    _selectArtwork(next, pinned: true, moveCamera: true);
  }

  Future<void> _moveCameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 17.0));
  }

  Future<void> _updateMarkers() async {
    final newMarkers = <Marker>{};
    for (final point in _artworkPoints) {
      final raw = _rawArtworks.where((a) => a.id == point.id).firstOrNull;
      final imageUrl = raw?.imageUrl;
      final isSelected = point.id == _selectedArtworkId;
      final icon = await _buildDiamondMarker(imageUrl, isSelected: isSelected);
      newMarkers.add(Marker(
        markerId: MarkerId(point.id),
        position: LatLng(point.lat, point.lng),
        icon: icon,
        onTap: () => _onMarkerTapped(point),
      ));
    }
    if (mounted) setState(() => _markers = newMarkers);
  }

  void _onMarkerTapped(ArtworkPoint point) {
    _dismissedIds.remove(point.id);
    _selectArtwork(point.id, pinned: true, moveCamera: true);
  }

  Widget _buildBottomCard() {
    if (_selectedArtworkData != null) {
      final id = _selectedArtworkData!['id'] as String;
      final nearby = _nearbyIds.toList()..sort();
      return _ArtworkTapCard(
        key: ValueKey('card_$id'),
        data: _selectedArtworkData!,
        isNearby: _nearbyIds.contains(id),
        nearbyCount: nearby.length,
        nearbyIndex: nearby.indexOf(id),
        onCycle: nearby.length > 1 ? _cycleNearby : null,
        onClose: () {
          setState(() {
            // Fechar dispensa todas as obras do raio atual: sem isso o gate
            // reabre o card sozinho na leitura seguinte do GPS.
            _dismissedIds.addAll(_nearbyIds);
            _autoArtworkId = null;
            _userPinned = false;
            _selectedArtworkId = null;
            _selectedArtworkData = null;
          });
          _updateMarkers();
        },
        onOpenAr: _openArViewNow,
      );
    }
    if (!_isArActive && _artworkPoints.isNotEmpty) {
      return _NoNearbyArtworkCard(
        key: const ValueKey('no_nearby'),
        onShowOnMap: _fitAllArtworks,
      );
    }
    return const SizedBox.shrink(key: ValueKey('empty'));
  }

  Future<void> _fitAllArtworks() async {
    if (_artworkPoints.isEmpty) return;
    final controller = await _controller.future;
    double minLat = _artworkPoints.first.lat;
    double maxLat = _artworkPoints.first.lat;
    double minLng = _artworkPoints.first.lng;
    double maxLng = _artworkPoints.first.lng;
    for (final p in _artworkPoints) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }

  Future<void> _openArViewNow() async {
    // Abre sempre a obra que está no card — inclusive quando o usuário trocou
    // manualmente entre duas obras do mesmo raio.
    final id = _selectedArtworkId;
    if (id == null || !_nearbyIds.contains(id)) return;

    // Busca o objeto Artwork completo (com URL do modelo 3D) na lista carregada
    final artworkModel = _rawArtworks.where((a) => a.id == id).firstOrNull;
    if (artworkModel == null) return;

    // 1. Oculta o mapa para liberar recursos da GPU (SurfaceView)
    setState(() {
      _isArActive = true;
    });

    // Pequeno delay para garantir que o widget do mapa foi desmontado pelo Flutter
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    await Navigator.pushNamed(context, AppRouter.ar, arguments: artworkModel);

    // 2. Ao voltar da experiência AR, reexibe o mapa. O estado do gate é
    //    preservado: zerá-lo aqui fazia o card reabrir sozinho logo em seguida.
    if (mounted) {
      _controller = Completer<GoogleMapController>();
      setState(() => _isArActive = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    return Scaffold(
      body: _isLoading
          ? const SplashLoading()
          : (_locationError != null)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off_outlined, size: 36, color: AppColors.fg3),
                        const SizedBox(height: 16),
                        Text(
                          _locationError!,
                          textAlign: TextAlign.center,
                          style: AppText.body(),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isLoading = true;
                                _locationError = null;
                              });
                              _initLocationService();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.fg,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3)),
                            ),
                            child: Text(
                              t.ar.tryAgain,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
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
                      style: _grayMapStyle,
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
                        Navigator.pushNamed(context, AppRouter.settings);
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

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 380),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) => SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(opacity: animation, child: child),
                        ),
                        child: _buildBottomCard(),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: Rsp.isTablet(context)
          ? bottomNavBar(context, 0)
          : bottomNavBar(context, 0),
    );
  }

  static final String _grayMapStyle = jsonEncode([
    {"featureType": "all", "stylers": [{"saturation": -75}, {"lightness": 5}]},
    {"featureType": "poi", "stylers": [{"visibility": "off"}]},
    {"featureType": "transit", "stylers": [{"visibility": "simplified"}]},
  ]);
}

class _ArtworkTapCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final VoidCallback onClose;
  final bool isNearby;
  final VoidCallback onOpenAr;
  // Quantas obras dividem o raio atual e qual delas está em tela.
  final int nearbyCount;
  final int nearbyIndex;
  final VoidCallback? onCycle;

  const _ArtworkTapCard({
    super.key,
    required this.data,
    required this.onClose,
    required this.isNearby,
    required this.onOpenAr,
    this.nearbyCount = 0,
    this.nearbyIndex = -1,
    this.onCycle,
  });

  @override
  State<_ArtworkTapCard> createState() => _ArtworkTapCardState();
}

class _ArtworkTapCardState extends State<_ArtworkTapCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.025)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    if (widget.isNearby) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_ArtworkTapCard old) {
    super.didUpdateWidget(old);
    if (widget.isNearby && !old.isNearby) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isNearby && old.isNearby) {
      _pulseCtrl.stop();
      _pulseCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    final lat = widget.data['lat'] as double?;
    final lng = widget.data['lng'] as double?;
    if (lat == null || lng == null) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.data['name'] as String? ?? '';
    final artist = widget.data['artist'] as String? ?? '';
    final imageUrl = widget.data['imageUrl'] as String? ?? '';
    final locationName = widget.data['locationName'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 32, height: 3,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Hero image + arrived banner
          Stack(
            children: [
              SizedBox(
                height: Rsp.isTablet(context) ? 300 : 160,
                width: double.infinity,
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(color: AppColors.bg2),
                      )
                    : Container(color: AppColors.bg2),
              ),
              // Arrived strip — desliza de cima quando chegou
              AnimatedSlide(
                offset: widget.isNearby ? Offset.zero : const Offset(0, -1),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: AnimatedOpacity(
                  opacity: widget.isNearby ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    color: AppColors.accent,
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.white, size: 13),
                        const SizedBox(width: 6),
                        Text(
                          context.t.map.arrivedTitle,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Seletor: aparece quando há mais de uma obra no mesmo raio
              if (widget.onCycle != null && widget.nearbyIndex >= 0)
                Positioned(
                  bottom: 10, right: 10,
                  child: GestureDetector(
                    onTap: widget.onCycle,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.swap_horiz,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.nearbyIndex + 1}/${widget.nearbyCount}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Close button
              Positioned(
                top: 10, right: 10,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),

          // Info + botão
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (locationName.isNotEmpty)
                  Text(locationName.toUpperCase(), style: AppText.label(color: AppColors.accent)),
                const SizedBox(height: 4),
                Text(name, style: AppText.display(fontSize: 18),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                if (artist.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(artist, style: AppText.caption(),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 16),
                // Botão com pulse + transição de cor ao chegar
                ScaleTransition(
                  scale: widget.isNearby ? _scaleAnim : const AlwaysStoppedAnimation(1.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: widget.isNearby ? AppColors.accent : AppColors.fg,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(3),
                      child: InkWell(
                        onTap: widget.isNearby ? widget.onOpenAr : _navigate,
                        borderRadius: BorderRadius.circular(3),
                        splashColor: Colors.white.withValues(alpha: 0.12),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                widget.isNearby ? Icons.view_in_ar : Icons.arrow_forward,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.isNearby
                                    ? context.t.map.openArButton
                                    : context.t.map.navigate,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoNearbyArtworkCard extends StatelessWidget {
  final VoidCallback onShowOnMap;

  const _NoNearbyArtworkCard({super.key, required this.onShowOnMap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 3,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              context.t.map.noNearbyArtwork,
              style: AppText.display(fontSize: 14),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: onShowOnMap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.fg,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                child: Text(
                  context.t.map.takeToNearest,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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