import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/routes/app_router.dart';

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
    'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2F5-Obra%20de%20Louise%20Bourgeois%20na%2014A%20Bienal%20-%20MON.jpg?alt=media&token=eab31612-0375-4390-827b-e17093fb17c2',
    'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2F4.jpg?alt=media&token=ff8a19f1-f4bb-4cdc-a342-af480c3e60f4',
    'https://firebasestorage.googleapis.com/v0/b/outvision-app-24329.firebasestorage.app/o/Fotos%20Bienal%2Fintro%203.jpg?alt=media&token=12dd3951-c1fc-424d-84f8-e80b5cd64f73',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Slideshow de fundo com crossfade
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Image.network(
              _images[_currentIndex],
              key: ValueKey(_currentIndex),
              fit: BoxFit.cover,
              width: size.width,
              height: size.height,
            ),
          ),

          // Gradiente para legibilidade do texto
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 1.0],
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),

          // Conteúdo
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicadores de página
                  Row(
                    children: List.generate(_images.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: i == _currentIndex ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _currentIndex
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t.welcome.headline,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRouter.explore,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        t.welcome.startButton,
                        style: GoogleFonts.inter(
                          fontSize: 17,
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
