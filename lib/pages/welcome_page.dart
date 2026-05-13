import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:outvisionxr/utils/language_provider.dart';
import 'package:provider/provider.dart';
import 'package:outvisionxr/utils/app_theme.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  static const _images = [
    'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2Fintro.jpg?alt=media&token=4db3f574-bd86-45f7-9552-9b63c0af1c50',
    'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2Fintro%201.jpg?alt=media&token=feb15f27-12be-4727-a428-b3c4b76caf4e',
    'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2F7.jpg?alt=media&token=599b03ce-e4da-4ea5-a527-1378d50e1641',
    'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2F5-Obra%20de%20Louise%20Bourgeois%20na%2014A%20Bienal%20-%20MON.jpg?alt=media&token=eab31612-0375-4340-827b-e17093fb17c2',
    'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2F4.jpg?alt=media&token=ff8a19f1-f4bb-4cdc-a342-af480c3e60f4',
    'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2Fintro%203.jpg?alt=media&token=12dd3951-c1fc-424d-84f8-e80b5cd64f73',
  ];

  int _current = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => _current = (_current + 1) % _images.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Slideshow
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 700),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: CachedNetworkImage(
              imageUrl: _images[_current],
              key: ValueKey(_current),
              fit: BoxFit.cover,
              width: size.width,
              height: size.height,
              placeholder: (_, __) => Container(color: Colors.black),
              errorWidget: (_, __, ___) => Container(color: Colors.black),
            ),
          ),

          // Gradient — light vignette top, strong bottom
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.35, 1.0],
                colors: [
                  Color(0x55000000),
                  Color(0x00000000),
                  Color(0xE0000000),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  // Typewriter headline
                  _TypewriterHeadline(fontSize: Rsp.fs(context, 38)),
                  const SizedBox(height: 6),

                  // Concept subtitle
                  Text(
                    t.welcome.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Colors.white.withValues(alpha: 0.55),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, AppRouter.explore),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: Text(
                        t.welcome.startButton,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _TwState { typing, holding, deleting, pausing }

class _TypewriterHeadline extends StatefulWidget {
  final double fontSize;
  const _TypewriterHeadline({required this.fontSize});

  @override
  State<_TypewriterHeadline> createState() => _TypewriterHeadlineState();
}

class _TypewriterHeadlineState extends State<_TypewriterHeadline> {
  List<String> get _phrases => t.welcome.phrases;

  // Timing (ms)
  static const _typeDelay = 48;
  static const _deleteDelay = 28;
  static const _holdDuration = 1800;
  static const _pauseDuration = 320;
  static const _cursorBlinkMs = 530;

  int _phraseIndex = 0;
  String _displayed = '';
  _TwState _state = _TwState.typing;
  bool _cursorVisible = true;
  Timer? _actionTimer;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startCursor();
    _tick();
  }

  void _startCursor() {
    _cursorTimer = Timer.periodic(
      const Duration(milliseconds: _cursorBlinkMs),
      (_) {
        if (mounted) setState(() => _cursorVisible = !_cursorVisible);
      },
    );
  }

  void _tick() {
    final full = _phrases[_phraseIndex];

    switch (_state) {
      case _TwState.typing:
        if (_displayed.length < full.length) {
          _actionTimer = Timer(const Duration(milliseconds: _typeDelay), () {
            if (!mounted) return;
            setState(() => _displayed = full.substring(0, _displayed.length + 1));
            _tick();
          });
        } else {
          _state = _TwState.holding;
          _actionTimer = Timer(const Duration(milliseconds: _holdDuration), () {
            if (!mounted) return;
            _state = _TwState.deleting;
            _tick();
          });
        }

      case _TwState.deleting:
        if (_displayed.isNotEmpty) {
          _actionTimer = Timer(const Duration(milliseconds: _deleteDelay), () {
            if (!mounted) return;
            setState(() => _displayed =
                _displayed.substring(0, _displayed.length - 1));
            _tick();
          });
        } else {
          _state = _TwState.pausing;
          _phraseIndex = (_phraseIndex + 1) % _phrases.length;
          _actionTimer = Timer(const Duration(milliseconds: _pauseDuration), () {
            if (!mounted) return;
            _state = _TwState.typing;
            _tick();
          });
        }

      case _TwState.holding:
      case _TwState.pausing:
        break;
    }
  }

  @override
  void dispose() {
    _actionTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Reserve height for 2 lines so layout doesn't jump
    return SizedBox(
      height: widget.fontSize * 1.1 * 2 + 4,
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: _displayed),
              TextSpan(
                text: _cursorVisible ? '|' : ' ',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w700,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
