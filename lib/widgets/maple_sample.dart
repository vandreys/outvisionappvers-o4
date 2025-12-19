import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  LatLng? _currentPosition;
  bool _showNoArtworkCard = false; // Escondido por default como no Wava
  final Set<Marker> _markers = <Marker>{};
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Fallback para Bienal de Curitiba (Largo da Ordem)
  static const CameraPosition _bienalInitial = CameraPosition(
    target: LatLng(-25.4268, -49.2721), // Coordenadas de Curitiba/Bienal
    zoom: 15.0,
  );

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(_pulseController);
    _getCurrentLocation();
    _addBienalMarkers();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Obtém localização real
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      final controller = await _controller.future;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15.0),
      );
    }
  }

  // Markers simulados para obras da Bienal (rosa como no Wava)
  void _addBienalMarkers() {
    _markers.addAll([
      Marker(
        markerId: const MarkerId('obra_largo'),
        position: const LatLng(-25.4268, -49.2721),
        infoWindow: const InfoWindow(title: 'Obra AR: Largo da Ordem'),
        icon: BitmapDescriptor.defaultMarkerWithHue(300.0), // Rosa vibrante
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

  // Anima para obra mais próxima (opcional, sem FAB no Wava)
  Future<void> _goToNearestArtwork() async {
    final controller = await _controller.future;
    if (_markers.isNotEmpty) {
      final nearest = _markers.first.position;
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(nearest, 16.0),
      );
      if (mounted) setState(() => _showNoArtworkCard = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mapa cinza desaturado como no Wava
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _currentPosition != null
                ? CameraPosition(target: _currentPosition!, zoom: 15.0)
                : _bienalInitial,
            onMapCreated: (controller) {
              _controller.complete(controller);
              controller.setMapStyle(_grayMapStyle); // Estilo cinza mais forte
            },
            markers: _markers,
            zoomControlsEnabled: false,
            myLocationEnabled: false, // Desabilitado para custom marcador
            myLocationButtonEnabled: false,
            buildingsEnabled: false,
            trafficEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false, // Sem toolbar extra
          ),

          // Marcador usuário customizado (azul pulsante como no Wava)
          if (_currentPosition != null)
            Positioned(
              bottom: 100, // Posição aproximada do centro-direita
              right: 20,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.5),
                          width: 5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Botões topo brancos arredondados (help e navigation como no Wava)
          Positioned(
            top: 70,
            left: 20,
            child: _roundedSquareButton(Icons.help_outline, Colors.black), // Corrigido: chamada posicional
          ),
          Positioned(
            top: 70,
            right: 20,
            child: _roundedSquareButton(Icons.navigation, Colors.black), // Corrigido: chamada posicional
          ),

          // Cartão "No artwork" (escondido por default; mostre se necessário)
          if (_showNoArtworkCard)
            Positioned(
              left: 0,
              right: 0,
              bottom: 120,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _noArtworkCard(),
              ),
            ),
        ],
      ),
      // Bottom nav clean como no Wava (sem FAB)
      bottomNavigationBar: _bottomNavBar(),
    );
  }

   static final String _grayMapStyle = jsonEncode([
    {
      "featureType": "all",
      "stylers": [
        {"saturation": -100},
        {"lightness": 40},
        {"gamma": 0.5}
      ]
    },
    {
      "featureType": "water",
      "stylers": [{"lightness": 50}]
    },
    {
      "featureType": "poi",
      "stylers": [{"visibility": "off"}]
    }
  ]);

  // Botão arredondado branco (como no Wava)
  Widget _roundedSquareButton(IconData icon, Color color) {
    return Container(
      width: 56,
      height: 56, // Tamanho exato do Wava
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2), // Sombra sutil
          ),
        ],
      ),
      child: Icon(icon, size: 28, color: color),
    );
  }

  // Cartão (mantido, mas escondido)
  Widget _noArtworkCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "No artwork near your location",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showNoArtworkCard = false),
                child: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "There is no artwork visible around your location. Zoom out "
            "or use the button below to see the nearest artworks.",
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToNearestArtwork,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Take me to the nearest artwork",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom nav como no Wava (Explore rosa ativo, outros cinza)
  Widget _bottomNavBar() {
    return Container(
      height: 70, // Altura exata do Wava
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Sombra leve
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(Icons.location_on, "Explore", true, Colors.pinkAccent), // Rosa ativo
          _navItem(Icons.grid_view, "Gallery", false, Colors.grey[600]!),
          _navItem(Icons.photo_camera, "Captured", false, Colors.grey[600]!),
          _navItem(Icons.settings, "Settings", false, Colors.grey[600]!),
        ],
      ),
    );
  }

  // Item da bottom nav (ajustado para match Wava)
  Widget _navItem(IconData icon, String label, bool active, Color color) {
    return GestureDetector(
      onTap: () {
        if (label == "Explore") {
          // Lógica para aba Explore (já ativa)
        } else if (label == "AR") { // Ajustado para AR
          // Para futura tela AR
          // Navigator.push(context, MaterialPageRoute(builder: (_) => ARViewScreen()));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 28,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}