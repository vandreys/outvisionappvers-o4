import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Computed once — avoids URL parsing and platform checks on every build()
  late final String? _modelUrl;
  late final bool _hasModel;

  Artwork get _artwork => widget.artwork;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final url = _resolveModelUrl();
    _modelUrl = url;
    _hasModel = url != null && url.isNotEmpty && _isSafeModelUrl(url);

    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _launchAndroid());
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _eventSub?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

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
