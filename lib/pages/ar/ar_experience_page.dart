import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/models/artwork_model.dart';

enum _ArStatus { localizing, ready, error }

class ARExperiencePage extends StatefulWidget {
  final Artwork artwork;

  const ARExperiencePage({super.key, required this.artwork});

  @override
  State<ARExperiencePage> createState() => _ARExperiencePageState();
}

class _ARExperiencePageState extends State<ARExperiencePage> {
  _ArStatus _status = _ArStatus.localizing;
  String? _errorMessage;
  StreamSubscription<dynamic>? _eventSub;
  bool _androidLaunching = false;

  late final String? _modelUrl;
  late final bool _hasModel;
  bool _cameraPermissionGranted = false;
  bool _arInitFailed = false;
  Timer? _arInitTimer;

  Artwork get _artwork => widget.artwork;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Video AR mode: native view handles everything — skip 3D model logic
    if (_artwork.videoUrl != null) {
      _modelUrl = null;
      _hasModel = false;
      _requestCameraAndLaunch();
      return;
    }

    final url = _resolveModelUrl();
    _modelUrl = url;
    _hasModel = url != null && url.isNotEmpty && _isSafeModelUrl(url);

    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _launchAndroid());
    }
  }

  Future<void> _requestCameraAndLaunch() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      // Aguarda a Activity retomar completamente após o diálogo de permissão
      // antes de criar a view nativa, evitando AR_ERROR_SESSION_PAUSED
      await Future.delayed(const Duration(milliseconds: 400));
    }
    if (!mounted) return;
    setState(() => _cameraPermissionGranted = status.isGranted);
    if (status.isGranted) _startArInitTimer();
  }

  void _startArInitTimer() {
    _arInitTimer?.cancel();
    _arInitTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _status != _ArStatus.ready) {
        setState(() => _arInitFailed = true);
      }
    });
  }

  void _retryAr() {
    setState(() {
      _cameraPermissionGranted = false;
      _arInitFailed = false;
    });
    _requestCameraAndLaunch();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _eventSub?.cancel();
    _arInitTimer?.cancel();
    super.dispose();
  }

  String? _resolveModelUrl() {
    if (Platform.isAndroid) {
      return _artwork.androidGlbUrl?.isNotEmpty == true
          ? _artwork.androidGlbUrl
          : _artwork.iosUsdzUrl;
    }
    return _artwork.iosUsdzUrl?.isNotEmpty == true
        ? _artwork.iosUsdzUrl
        : _artwork.androidGlbUrl;
  }

  bool _isSafeModelUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https' &&
          (uri.host.endsWith('firebasestorage.googleapis.com') ||
              uri.host.endsWith('firebasestorage.app') ||
              uri.host.endsWith('storage.googleapis.com'));
    } catch (_) {
      return false;
    }
  }

  // Called by UiKitView once the native view is ready; subscribe to event channel.
  void _onPlatformViewCreated(int viewId) {
    _eventSub = EventChannel('outvisionxr/ar_view_events_$viewId')
        .receiveBroadcastStream()
        .listen(
          _onArEvent,
          onError: (_) {
            if (mounted) setState(() => _status = _ArStatus.error);
          },
        );
  }

  void _onArEvent(dynamic event) {
    if (!mounted) return;
    if (event is String) {
      if (event == 'ready') _arInitTimer?.cancel();
      setState(() {
        _status = event == 'ready' ? _ArStatus.ready : _ArStatus.localizing;
      });
    } else if (event is Map) {
      setState(() {
        _status = _ArStatus.error;
        _errorMessage = event['message'] as String?;
      });
    }
  }

  // Android: launch Google Scene Viewer
  Future<void> _launchAndroid() async {
    if (!_hasModel) return;
    setState(() => _androidLaunching = true);
    try {
      await _launchSceneViewer(_modelUrl!, _artwork.localizedTitle);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _androidLaunching = false);
    }
  }

  Future<void> _launchSceneViewer(String glbUrl, String title) async {
    final encodedUrl = Uri.encodeComponent(glbUrl);
    final encodedTitle = Uri.encodeComponent(title);
    final fallbackStore = Uri.encodeComponent(
      'https://play.google.com/store/apps/details?id=com.google.android.googlequicksearchbox',
    );

    final intentUrl = 'intent://arvr.google.com/scene-viewer/1.0'
        '?file=$encodedUrl'
        '&mode=ar_preferred'
        '&title=$encodedTitle'
        '#Intent;scheme=https;'
        'package=com.google.android.googlequicksearchbox;'
        'action=android.intent.action.VIEW;'
        'S.browser_fallback_url=$fallbackStore;'
        'end;';

    final intentUri = Uri.parse(intentUrl);
    if (await canLaunchUrl(intentUri)) {
      await launchUrl(intentUri);
    } else {
      await launchUrl(
        Uri.parse(
            'https://arvr.google.com/scene-viewer/1.0?file=$encodedUrl&mode=ar_preferred'),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Map<String, dynamic> get _videoArParams => {
    'videoUrl': _artwork.videoUrl,
    'eyeLevelOffsetMeters': _artwork.eyeLevelOffsetMeters ?? 1.5,
    'faceUser': _artwork.faceUser ?? true,
    'lat': 0.0,
    'lng': 0.0,
  };

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    // Video AR mode — vídeo flutuando no espaço via ARCore / ARKit
    if (_artwork.videoUrl != null) {
      // Aguarda permissão de câmera antes de montar o view nativo
      if (Platform.isAndroid && !_cameraPermissionGranted) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              const Center(child: CircularProgressIndicator(color: Colors.white)),
              Positioned(
                top: topPadding + 12,
                left: 12,
                child: _GlassmorphicButton(
                  icon: Icons.close,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      }

      // GLSurfaceView requer ExpensiveAndroidView (Hybrid Composition)
      final Widget nativeView = Platform.isAndroid
          ? PlatformViewLink(
              viewType: 'outvisionxr/ar_video_view',
              surfaceFactory: (context, controller) => AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              ),
              onCreatePlatformView: (params) =>
                  PlatformViewsService.initExpensiveAndroidView(
                    id: params.id,
                    viewType: 'outvisionxr/ar_video_view',
                    layoutDirection: TextDirection.ltr,
                    creationParams: _videoArParams,
                    creationParamsCodec: const StandardMessageCodec(),
                    onFocus: () => params.onFocusChanged(true),
                  )
                    ..addOnPlatformViewCreatedListener((id) {
                      params.onPlatformViewCreated(id);
                      _onPlatformViewCreated(id);
                    })
                    ..create(),
            )
          : UiKitView(
              viewType: 'outvisionxr/ar_view',
              creationParams: _videoArParams,
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: _onPlatformViewCreated,
            );

      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            if (_arInitFailed) const SizedBox.shrink() else nativeView,
            if (_arInitFailed)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.videocam_off_outlined,
                        color: Colors.white54, size: 52),
                    const SizedBox(height: 16),
                    Text(
                      t.ar.errorTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.ar.genericError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: _retryAr,
                      child: Text(t.ar.tryAgain,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
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
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // iOS: native ARKit view full screen
          if (Platform.isIOS && _hasModel)
            UiKitView(
              viewType: 'outvisionxr/ar_view',
              creationParams: {
                'lat': _artwork.location.latitude,
                'lng': _artwork.location.longitude,
                'eyeLevelOffsetMeters': _artwork.eyeLevelOffsetMeters ?? 1.5,
                'faceUser': _artwork.faceUser ?? true,
                'iosUsdzAsset': _modelUrl,
              },
              creationParamsCodec: const StandardMessageCodec(),
              onPlatformViewCreated: _onPlatformViewCreated,
            )
          else
            _buildFallback(),

          // Close button — blur on 48×48 is negligible
          Positioned(
            top: topPadding + 12,
            left: 12,
            child: _GlassmorphicButton(
              icon: Icons.close,
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // iOS status overlay — RepaintBoundary isolates repaints from AR camera
          if (Platform.isIOS && _hasModel && _status != _ArStatus.ready)
            RepaintBoundary(child: _buildIosStatusOverlay()),
        ],
      ),
    );
  }

  // Android waiting screen / model unavailable
  Widget _buildFallback() {
    if (Platform.isAndroid && _hasModel) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.view_in_ar, color: Colors.white54, size: 80),
            const SizedBox(height: 24),
            Text(
              _artwork.localizedTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            if (_artwork.displayArtist.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                _artwork.displayArtist,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
            const SizedBox(height: 48),
            if (_androidLaunching)
              const CircularProgressIndicator(color: Colors.white)
            else
              ElevatedButton.icon(
                onPressed: _launchAndroid,
                icon: const Icon(Icons.view_in_ar),
                label: Text(t.ar.openAr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(220, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.view_in_ar, color: Colors.white54, size: 80),
          const SizedBox(height: 16),
          Text(
            t.ar.modelUnavailable,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildIosStatusOverlay() {
    if (_status == _ArStatus.error) {
      return Positioned(
        bottom: 60,
        left: 24,
        right: 24,
        child: _StatusPanel(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.orangeAccent, size: 36),
              const SizedBox(height: 12),
              Text(
                t.ar.errorTitle,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? t.ar.genericError,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Positioned(
      bottom: 60,
      left: 24,
      right: 24,
      child: _StatusPanel(
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                t.ar.onboardingContent,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Glassmorphic close button — blur on small area is cheap
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
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
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

// Solid semi-opaque panel — no BackdropFilter on top of live camera (expensive)
class _StatusPanel extends StatelessWidget {
  final Widget child;

  const _StatusPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
