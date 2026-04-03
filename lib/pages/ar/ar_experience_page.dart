import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:outvisionxr/models/artwork_model.dart';

class ARExperiencePage extends StatefulWidget {
  final Artwork artwork;

  const ARExperiencePage({super.key, required this.artwork});

  @override
  State<ARExperiencePage> createState() => _ARExperiencePageState();
}

class _ARExperiencePageState extends State<ARExperiencePage> {
  bool _launching = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Dispara o AR assim que a página abre
    WidgetsBinding.instance.addPostFrameCallback((_) => _openAR());
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _openAR() async {
    final artwork = widget.artwork;

    final String? modelUrl = Platform.isAndroid
        ? (artwork.androidGlbUrl?.isNotEmpty == true
            ? artwork.androidGlbUrl
            : artwork.iosUsdzUrl)
        : (artwork.iosUsdzUrl?.isNotEmpty == true
            ? artwork.iosUsdzUrl
            : artwork.androidGlbUrl);

    if (modelUrl == null || modelUrl.isEmpty) return;

    setState(() => _launching = true);

    try {
      if (Platform.isAndroid) {
        await _launchSceneViewer(modelUrl, artwork.localizedTitle);
      } else {
        await _launchQuickLook(modelUrl);
      }
    } catch (e) {
      debugPrint('Erro ao abrir AR: $e');
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  /// Lança o Google Scene Viewer diretamente (Android).
  /// Mesmo mecanismo que o model_viewer_plus usa internamente.
  Future<void> _launchSceneViewer(String glbUrl, String title) async {
    final encodedUrl = Uri.encodeComponent(glbUrl);
    final encodedTitle = Uri.encodeComponent(title);

    final intentUrl =
        'intent://arvr.google.com/scene-viewer/1.0'
        '?file=$encodedUrl'
        '&mode=ar_preferred'
        '&title=$encodedTitle'
        '#Intent;scheme=https;'
        'package=com.google.android.googlequicksearchbox;'
        'action=android.intent.action.VIEW;'
        'S.browser_fallback_url=https://developers.google.com/ar;'
        'end;';

    final uri = Uri.parse(intentUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: tenta pelo Google AR Core viewer
      final fallbackUrl =
          'https://arvr.google.com/scene-viewer/1.0'
          '?file=$encodedUrl'
          '&mode=ar_preferred';
      await launchUrl(Uri.parse(fallbackUrl),
          mode: LaunchMode.externalApplication);
    }
  }

  /// Lança o Quick Look do iOS para AR.
  Future<void> _launchQuickLook(String usdzUrl) async {
    final uri = Uri.parse(usdzUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final artwork = widget.artwork;
    final topPadding = MediaQuery.of(context).padding.top;

    final String? modelUrl = Platform.isAndroid
        ? (artwork.androidGlbUrl?.isNotEmpty == true
            ? artwork.androidGlbUrl
            : artwork.iosUsdzUrl)
        : (artwork.iosUsdzUrl?.isNotEmpty == true
            ? artwork.iosUsdzUrl
            : artwork.androidGlbUrl);

    final bool hasModel = modelUrl != null && modelUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fundo — tela de espera enquanto o Scene Viewer abre
          Center(
            child: hasModel
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.view_in_ar,
                          color: Colors.white54, size: 80),
                      const SizedBox(height: 24),
                      Text(
                        artwork.localizedTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (artwork.displayArtist.isNotEmpty)
                        Text(
                          artwork.displayArtist,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 14),
                        ),
                      const SizedBox(height: 48),
                      if (_launching)
                        const CircularProgressIndicator(color: Colors.white)
                      else
                        ElevatedButton.icon(
                          onPressed: _openAR,
                          icon: const Icon(Icons.view_in_ar),
                          label: const Text('Abrir AR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(220, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.view_in_ar,
                          color: Colors.white54, size: 80),
                      SizedBox(height: 16),
                      Text(
                        'Modelo 3D não disponível\npara esta obra.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
          ),

          // Botão fechar
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
