import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:outvisionxr/i18n/strings.g.dart';

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
            _errorMessage = message ?? context.t.ar.genericError;
          });
        }
      },
      onError: (e) {
        if (!mounted) return;
        _readyDelayTimer?.cancel();

        setState(() {
          _status = ArRuntimeStatus.error;
          _errorMessage = context.t.ar.eventsError;
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
      barrierColor: Colors.transparent, // To see the blur
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E).withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(
            context.t.ar.helpTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            context.t.ar.helpContent,
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.t.ar.ok, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraPermissionOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 40),
                  const SizedBox(height: 16),
                  Text(
                    context.t.ar.permissionTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.t.ar.permissionContent,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _checkArPermissions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(context.t.ar.allowAccess, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      context.t.ar.notNow,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
            top: topPadding + 12,
            left: 12,
            child: _GlassmorphicButton(
              icon: Icons.close,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: topPadding + 12,
            right: 12,
            child: _GlassmorphicButton(
              icon: Icons.help_outline,
              onPressed: _openHelp,
            ),
          ),
          if (_cameraGranted && !_onboardingDone)
            _OnboardingOverlay(onStart: _completeOnboarding),
          if (_cameraGranted && _onboardingDone && _status == ArRuntimeStatus.localizing) _LocalizingOverlay(),
          if (_cameraGranted && _onboardingDone && _status == ArRuntimeStatus.error)
            _ErrorOverlay(message: _errorMessage ?? context.t.ar.genericError),
        ],
      ),
    );
  }
}

class _GlassmorphicButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _GlassmorphicButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(icon, color: Colors.white, size: 24),
            onPressed: onPressed,
          ),
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

    return Center(
      child: Text(context.t.ar.unsupported, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _OnboardingOverlay extends StatelessWidget {
  final VoidCallback onStart;

  const _OnboardingOverlay({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E), // Dark grey, iOS-like
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.t.ar.scanInstruction,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.t.ar.onboardingContent,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: onStart,
                      child: Text(
                        context.t.ar.onboardingButton,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
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
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(100), // Pill shape
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    context.t.ar.scanInstruction,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
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
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                const SizedBox(height: 16),
                Text(
                  context.t.ar.errorTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 15),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      context.t.ar.backButton,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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