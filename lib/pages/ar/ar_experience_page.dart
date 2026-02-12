import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:outvisionxr/models/artwork_point.dart';
import 'package:outvisionxr/widgets/rounded_square_button.dart';

enum ArRuntimeStatus { localizing, ready, error }

class ARExperiencePage extends StatefulWidget {
  final ArtworkPoint artwork;

  const ARExperiencePage({
    super.key,
    required this.artwork,
  });

  @override
  State<ARExperiencePage> createState() => _ARExperiencePageState();
}

class _ARExperiencePageState extends State<ARExperiencePage> {
  static const String _prefsKeyOnboardingDone = 'ar_onboarding_done';
  static const String _viewType = 'outvisionxr/ar_view';

  bool _onboardingDone = false;

  StreamSubscription? _arEventsSub;

  ArRuntimeStatus _status = ArRuntimeStatus.localizing;
  String? _errorMessage;

  // ✅ MINIMUM LOCALIZING TIME
  DateTime? _localizingStartedAt;
  static const Duration _minLocalizingDuration = Duration(seconds: 5);
  Timer? _readyDelayTimer;

  // ✅ PERMISSION GATE (câmera + localização)
  bool _cameraGranted = false; // aqui significa "permissões do AR ok"
  bool _checkingCamera = true;

  @override
  void initState() {
    super.initState();
    _loadOnboarding();
    _checkArPermissions();
  }

  // ✅ CÂMERA + LOCALIZAÇÃO (necessário p/ Geospatial)
  Future<void> _checkArPermissions() async {
    setState(() => _checkingCamera = true);

    final results = await [
      Permission.camera,
      Permission.locationWhenInUse,
    ].request();

    if (!mounted) return;

    final cameraOk = results[Permission.camera]?.isGranted ?? false;
    final locationOk = results[Permission.locationWhenInUse]?.isGranted ?? false;

    setState(() {
      _cameraGranted = cameraOk && locationOk;
      _checkingCamera = false;
    });
  }

  Future<void> _loadOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_prefsKeyOnboardingDone) ?? false;
    if (!mounted) return;

    setState(() {
      _onboardingDone = done;
      _status = ArRuntimeStatus.localizing;
    });

    if (done) _localizingStartedAt = DateTime.now();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyOnboardingDone, true);
    if (!mounted) return;

    setState(() {
      _onboardingDone = true;
      _status = ArRuntimeStatus.localizing;
    });

    _localizingStartedAt = DateTime.now();
  }

  void _onPlatformViewCreated(int id) {
    final channelName = 'outvisionxr/ar_view_events_$id';
    final events = EventChannel(channelName);

    _arEventsSub?.cancel();
    _arEventsSub = events.receiveBroadcastStream().listen(
      (dynamic event) {
        String? status;
        String? message;

        if (event is String) {
          status = event;
        } else if (event is Map) {
          final m = Map<String, dynamic>.from(event);
          status = (m['status'] ?? m['state'])?.toString();
          message = m['message']?.toString();
        }

        if (!mounted) return;

        if (status == 'ready') {
          final started = _localizingStartedAt ?? DateTime.now();
          final elapsed = DateTime.now().difference(started);
          final remaining = _minLocalizingDuration - elapsed;

          _readyDelayTimer?.cancel();

          if (remaining.isNegative || remaining == Duration.zero) {
            setState(() {
              _status = ArRuntimeStatus.ready;
              _errorMessage = null;
            });
          } else {
            _readyDelayTimer = Timer(remaining, () {
              if (!mounted) return;
              setState(() {
                _status = ArRuntimeStatus.ready;
                _errorMessage = null;
              });
            });
          }
        } else if (status == 'localizing' || status == 'scanning') {
          _readyDelayTimer?.cancel();
          _localizingStartedAt ??= DateTime.now();

          setState(() {
            _status = ArRuntimeStatus.localizing;
            _errorMessage = null;
          });
        } else if (status == 'error') {
          _readyDelayTimer?.cancel();

          setState(() {
            _status = ArRuntimeStatus.error;
            _errorMessage = message ?? 'Erro no AR.';
          });
        }
      },
      onError: (e) {
        if (!mounted) return;
        _readyDelayTimer?.cancel();

        setState(() {
          _status = ArRuntimeStatus.error;
          _errorMessage = 'Falha ao receber eventos do AR.';
        });
      },
    );
  }

  @override
  void dispose() {
    _readyDelayTimer?.cancel();
    _arEventsSub?.cancel();
    super.dispose();
  }

  void _openHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Ajuda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Mova o celular lentamente e aponte para o ambiente para melhorar a localização.'
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _cameraPermissionOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Permissão necessária',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Precisamos de câmera e localização para abrir o AR.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _checkArPermissions,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  child: const Text('Permitir'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => openAppSettings(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  child: const Text('Abrir configurações'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black12),
                  ),
                  child: const Text('Voltar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artwork = widget.artwork;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_checkingCamera)
            const Center(child: CircularProgressIndicator())
          else if (!_cameraGranted)
            _cameraPermissionOverlay()
          else
            Positioned.fill(
              child: _ARPlatformView(
                artwork: artwork,
                viewType: _viewType,
                onCreated: _onPlatformViewCreated,
              ),
            ),
          Positioned(
            top: topPadding + 16,
            left: 16,
            child: roundedSquareButton(Icons.close, Colors.black, () => Navigator.pop(context)),
          ),
          Positioned(
            top: topPadding + 16,
            right: 16,
            child: roundedSquareButton(Icons.help_outline, Colors.black, _openHelp),
          ),
          if (_cameraGranted && !_onboardingDone) _OnboardingOverlay(onStart: _completeOnboarding),
          if (_cameraGranted && _onboardingDone && _status == ArRuntimeStatus.localizing) const _LocalizingOverlay(),
          if (_cameraGranted && _onboardingDone && _status == ArRuntimeStatus.error)
            _ErrorOverlay(message: _errorMessage ?? 'Erro no AR'),
        ],
      ),
    );
  }
}

class _ARPlatformView extends StatelessWidget {
  final ArtworkPoint artwork;
  final String viewType;
  final void Function(int) onCreated;

  const _ARPlatformView({
    required this.artwork,
    required this.viewType,
    required this.onCreated,
  });

  @override
  Widget build(BuildContext context) {
    final creationParams = <String, dynamic>{
      'artworkId': artwork.id,
      'title': artwork.title,
      'lat': artwork.lat,
      'lng': artwork.lng,
      'arrivalRadiusMeters': artwork.arrivalRadiusMeters,
      'eyeLevelOffsetMeters': artwork.eyeLevelOffsetMeters,
      'faceUser': artwork.faceUser,
      'androidGlbAsset': 'assets/3dmodels/stateofbeing.glb',
      'iosUsdzAsset': 'assets/3dmodels/stateofbeing.usdz',
    };

    if (Platform.isAndroid) {
      return AndroidView(
        viewType: viewType,
        onPlatformViewCreated: onCreated,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: onCreated,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return const Center(
      child: Text('AR não suportado nesta plataforma', style: TextStyle(color: Colors.white)),
    );
  }
}

class _OnboardingOverlay extends StatelessWidget {
  final VoidCallback onStart;

  const _OnboardingOverlay({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        child: Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan the floor in front of you.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mova o celular lentamente para ajudar o AR a se localizar.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: onStart,
                    child: const Text(
                      'Got it, let’s start →',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocalizingOverlay extends StatelessWidget {
  const _LocalizingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 28),
          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.25)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Scan the floor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Scan the floor in front of you to place the artwork.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  final String message;

  const _ErrorOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Erro no AR',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
                  child: const Text('Voltar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}