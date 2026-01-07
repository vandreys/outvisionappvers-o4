import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/widgets/bottom_nav_bar.dart';
import 'package:outvisionxr/widgets/rounded_square_button.dart'; 

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
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

    // Define a posição inicial para o MON de Curitiba
    Position initialPosition = Position(
      latitude: -25.4095, // Latitude do Museu Oscar Niemeyer (MON) em Curitiba
      longitude: -49.2667, // Longitude do Museu Oscar Niemeyer (MON) em Curitiba
      timestamp: DateTime.now(),
      accuracy: 0.0, 
      altitude: 0.0, 
      heading: 0.0, 
      speed: 0.0, 
      speedAccuracy: 0.0, 
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );

    if (mounted) {
      setState(() {
        _currentPosition = LatLng(initialPosition.latitude, initialPosition.longitude);
        _isLoading = false; // Libera o mapa, pois já temos uma posição inicial
      });
      
      _moveCameraToPosition(_currentPosition!);
    }

    // 2. Inicia o monitoramento contínuo para atualizações em tempo real
    // Comentado para fins de teste!
    //_startTracking();
  }

  // NOVO MÉTODO: Configura a escuta contínua do GPS
  void _startTracking() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Atualiza a cada 1 metro de movimento
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
        position: const LatLng(-25.42776745339319, -49.2722254193995),
        infoWindow: InfoWindow(title: t.map.artworkLargo),
        icon: BitmapDescriptor.defaultMarkerWithHue(300.0),
      ),
      Marker(
        markerId: const MarkerId('obra_mon'),
        position: const LatLng(-25.40967648572163, -49.267092090902416),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Se estiver carregando, mostra um indicador de progresso
      body: _isLoading 
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.black),
                SizedBox(height: 20),
                Text(t.map.loadingGps, 
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
                zoomControlsEnabled: false, // Desabilitamos os controles padrão para usar os nossos
                compassEnabled: false,
                mapToolbarEnabled: false,
              ),
              Positioned(
                top: 60,
                left: 20,
                child: roundedSquareButton(Icons.help_outline, Colors.black, (){}),
              ),
              // Botões de Zoom e Navegação agrupados em uma Column
              Positioned(
                top: 60,
                right: 20,
                child: Column(
                  children: [
                    roundedSquareButton(Icons.add, Colors.black, () async {
                      final GoogleMapController controller = await _controller.future;
                      controller.animateCamera(CameraUpdate.zoomIn());
                    }),
                    const SizedBox(height: 10), // Espaçamento entre os botões
                    roundedSquareButton(Icons.remove, Colors.black, () async {
                      final GoogleMapController controller = await _controller.future;
                      controller.animateCamera(CameraUpdate.zoomOut());
                    }),
                    const SizedBox(height: 10), // Espaçamento entre os botões
                    roundedSquareButton(Icons.navigation, Colors.black, (){
                      if(_currentPosition != null) _moveCameraToPosition(_currentPosition!);
                    }),
                  ],
                ),
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
