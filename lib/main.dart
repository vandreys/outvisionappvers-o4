import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/pages/explore_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:outvisionxr/utils/language_provider.dart';
import 'package:outvisionxr/services/artist_service.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:video_player/video_player.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  LocaleSettings.setLocale(AppLocale.pt);

  runApp(const SplashApp());
}

// App mínimo só para mostrar a splash imediatamente
class SplashApp extends StatelessWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  bool _firebaseReady = false;
  bool _videoEnded = false;

  @override
  void initState() {
    super.initState();

    // Inicia Firebase em paralelo com o vídeo
    _initFirebase();

    _controller = VideoPlayerController.asset('assets/images/splash.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.setVolume(0);
        _controller.play();
        _controller.addListener(_onVideoProgress);
      }).catchError((e) {
        debugPrint('Erro ao carregar vídeo: $e');
        _videoEnded = true;
        _tryNavigate();
      });
  }

  Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {}
    _firebaseReady = true;
    _tryNavigate();
  }

  void _onVideoProgress() {
    final dur = _controller.value.duration;
    final pos = _controller.value.position;
    if (dur > Duration.zero && pos >= dur - const Duration(milliseconds: 200)) {
      _controller.removeListener(_onVideoProgress);
      _videoEnded = true;
      _tryNavigate();
    }
  }

  void _tryNavigate() {
    if (!_firebaseReady || !_videoEnded) return;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider<LanguageProvider>(
              create: (_) => LanguageProvider(),
            ),
            ChangeNotifierProvider<ArtistService>(
              create: (_) => ArtistService(),
            ),
            ChangeNotifierProvider<ArtworkService>(
              create: (_) => ArtworkService(),
            ),
          ],
          child: TranslationProvider(
            child: const OutvisionApp(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
          ? LayoutBuilder(
              builder: (context, constraints) {
                final screenW = constraints.maxWidth;
                final screenH = constraints.maxHeight;
                final videoW = _controller.value.size.width;
                final videoH = _controller.value.size.height;

                // Calcula escala para cobrir a tela (cover) mantendo proporção
                final scaleW = screenW / videoW;
                final scaleH = screenH / videoH;
                final scale = scaleW > scaleH ? scaleW : scaleH;

                final displayW = videoW * scale;
                final displayH = videoH * scale;

                return ClipRect(
                  child: OverflowBox(
                    maxWidth: displayW,
                    maxHeight: displayH,
                    child: SizedBox(
                      width: displayW,
                      height: displayH,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                );
              },
            )
          : const SizedBox.expand(), // preto sólido enquanto inicializa
    );
  }
}

class OutvisionApp extends StatelessWidget {
  const OutvisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: TranslationProvider.of(context).flutterLocale,
      debugShowCheckedModeBanner: false,
      title: 'Bienal de Curitiba App',

      theme: ThemeData(
        useMaterial3: true,

        fontFamily: GoogleFonts.inter().fontFamily,

        // TextTheme compatível com Material 3
        textTheme: GoogleFonts.interTextTheme(),

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          brightness: Brightness.light,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          foregroundColor: Colors.black,
        ),

        // (Opcional, mas deixa tudo mais consistente)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),

      home: const ExplorePage(),
    );
  }
}
