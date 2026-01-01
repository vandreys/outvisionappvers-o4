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
  StreamSubscription<Position>? _positionStream; // ESSENCIAL: Variável para o stream do GPS
  
  // ESSENCIAL: Variável para controlar o estado de carregamento
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initLocationService(); // NOVO MÉTODO: Inicializa e monitora a localização
    _addBienalMarkers();
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // ESSENCIAL: Cancela a escuta do GPS quando a tela é fechada
    super.dispose();
  }

  // NOVO MÉTODO: Lógica robusta de inicialização e monitoramento contínuo
  Future<void> _initLocationService() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _isLoading = false; 
        });
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _isLoading = false; 
          });
        }
        return;
      }
    }

    // 1. Pega a posição IMEDIATA para tirar o app do estado de carregamento
    Position initialPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best
    );

    if (mounted) {
      setState(() {
        _currentPosition = LatLng(initialPosition.latitude, initialPosition.longitude);
        _isLoading = false; // Libera o mapa, pois já temos uma posição inicial
      });
      
      _moveCameraToPosition(_currentPosition!);
    }

    // 2. Inicia o monitoramento contínuo para atualizações em tempo real
    _startTracking();
  }

  // NOVO MÉTODO: Configura a escuta contínua do GPS
  void _startTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2, // Atualiza a cada 2 metros de movimento
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        _moveCameraToPosition(_currentPosition!); // Move a câmera para a nova posição
      }
    });
  }

  Future<void> _moveCameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(position, 17.0),
    );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Se estiver carregando, mostra um indicador de progresso
      body: _isLoading 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.black),
                SizedBox(height: 20),
                Text("Buscando sinal de GPS...", 
                  style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)
                ),
              ],
            ),
          )
        : Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                // A posição inicial do mapa será sempre a sua posição atual
                initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 17),
                onMapCreated: (controller) {
                  _controller.complete(controller);
                  controller.setMapStyle(_grayMapStyle);
                },
                markers: _markers,
                myLocationEnabled: true, // Mostra o ponto azul da sua localização
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
                child: roundedSquareButton(Icons.navigation, Colors.black, (){
                  if(_currentPosition != null) _moveCameraToPosition(_currentPosition!);
                }),
              ),
            ],
          ),
      bottomNavigationBar: bottomNavBar(context, 0), 
    );
  }

  static final String _grayMapStyle = jsonEncode([
    {"featureType": "all", "stylers": [{"saturation": -100}, {"lightness": 40}, {"gamma": 0.5}]},
    {"featureType": "poi", "stylers": [{"visibility": "off"}]}
  ]);
}