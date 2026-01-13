import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  int? _platformViewId;
  StreamSubscription? _arEventsSub;

  ArRuntimeStatus _status = ArRuntimeStatus.localizing;
  String? _errorMessage;

  // ✅ MINIMUM LOCALIZING TIME
  DateTime? _localizingStartedAt;
  static const Duration _minLocalizingDuration = Duration(seconds: 5);
  Timer? _readyDelayTimer;

  @override
  void initState() {
    super.initState();
    _loadOnboarding();
  }

  Future<void> _loadOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool(_prefsKeyOnboardingDone) ?? false;
    if (!mounted) return;

    setState(() {
      _onboardingDone = done;
      _status = ArRuntimeStatus.localizing;
    });

    // ✅ Se já entrou direto no AR (onboarding já feito), inicia contagem do localizing
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

    // ✅ Começa contagem do mínimo de 5s assim que o onboarding termina
    _localizingStartedAt = DateTime.now();
  }

  void _onPlatformViewCreated(int id) {
    _platformViewId = id;

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
          // ✅ Segura o ready até completar 5s de overlay
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
          // ✅ Se voltar a localizing, cancela qualquer “ready agendado”
          _readyDelayTimer?.cancel();

          // ✅ Se ainda não começou a contagem, inicia agora
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
          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Mova o celular lentamente e aponte para o ambiente para melhorar a localização.',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artwork = widget.artwork;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _ARPlatformView(
              artwork: artwork,
              viewType: _viewType,
              onCreated: _onPlatformViewCreated,
            ),
            Positioned(
              top: 16,
              left: 16,
              child: roundedSquareButton(Icons.close, Colors.black, () => Navigator.pop(context)),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: roundedSquareButton(Icons.help_outline, Colors.black, _openHelp),
            ),
            if (!_onboardingDone) _OnboardingOverlay(onStart: _completeOnboarding),
            if (_onboardingDone && _status == ArRuntimeStatus.localizing) const _LocalizingOverlay(),
            if (_onboardingDone && _status == ArRuntimeStatus.error)
              _ErrorOverlay(message: _errorMessage ?? 'Erro no AR'),
          ],
        ),
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

      // ✅ GLB local asset (Android) - se você tiver esse campo no ArtworkPoint
      // Ex.: assets/3dmodels/stateofbeing.glb
      'androidGlbAsset': artwork.androidGlbUrl,
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
        color: Colors.black.withOpacity(0.65),
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
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mova o celular lentamente para ajudar o AR a se localizar.',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
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
                      style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
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
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.25)),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Scan the floor',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
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
                    fontFamily: 'Montserrat',
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
        color: Colors.black.withOpacity(0.65),
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
                style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Montserrat'),
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