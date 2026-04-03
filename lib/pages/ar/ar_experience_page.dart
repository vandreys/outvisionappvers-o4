import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ARExperiencePage extends StatefulWidget {
  final Artwork artwork;

  const ARExperiencePage({super.key, required this.artwork});

  @override
  State<ARExperiencePage> createState() => _ARExperiencePageState();
}

class _ARExperiencePageState extends State<ARExperiencePage> {
  WebViewController? _webViewController;
  bool _showLoading = true;
  Timer? _loadingTimer;
  Timer? _autoArTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Esconde overlay de loading após 5 s e mostra botão de fallback
    _loadingTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showLoading = false);
    });
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _autoArTimer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _activateAR() {
    _webViewController?.runJavaScript(
      "document.querySelector('model-viewer').activateAR();",
    );
  }

  @override
  Widget build(BuildContext context) {
    final artwork = widget.artwork;
    final topPadding = MediaQuery.of(context).padding.top;

    final String? glbUrl =
        Platform.isAndroid ? artwork.androidGlbUrl : artwork.iosUsdzUrl;
    final String? fallbackUrl = Platform.isAndroid
        ? (artwork.androidGlbUrl ?? artwork.iosUsdzUrl)
        : (artwork.iosUsdzUrl ?? artwork.androidGlbUrl);
    final String? modelUrl =
        glbUrl?.isNotEmpty == true ? glbUrl : fallbackUrl;

    if (modelUrl == null || modelUrl.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.view_in_ar, color: Colors.white54, size: 80),
                const SizedBox(height: 16),
                const Text(
                  'Modelo 3D não disponível\npara esta obra.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Voltar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ModelViewer — sem relatedJs para não corromper o WebView
          ModelViewer(
            src: modelUrl,
            alt: artwork.localizedTitle,
            ar: true,
            arModes: const ['scene-viewer', 'webxr', 'quick-look'],
            autoRotate: false,
            cameraControls: true,
            backgroundColor: const Color(0xFF111111),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              // Aguarda 4 s para o modelo carregar e dispara AR automaticamente
              _autoArTimer = Timer(const Duration(seconds: 4), () {
                if (mounted) {
                  controller.runJavaScript(
                    "document.querySelector('model-viewer').activateAR();",
                  );
                }
              });
            },
          ),

          // Loading overlay — visível nos primeiros 5 s
          if (_showLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'Carregando modelo...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Botão fechar (sempre visível)
          Positioned(
            top: topPadding + 12,
            left: 12,
            child: _GlassmorphicButton(
              icon: Icons.close,
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Botão fallback "Abrir AR" — aparece após o overlay de loading sumir
          if (!_showLoading)
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: ElevatedButton.icon(
                onPressed: _activateAR,
                icon: const Icon(Icons.view_in_ar),
                label: const Text('Abrir AR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
