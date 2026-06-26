import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/routes/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:outvisionxr/utils/language_provider.dart';
import 'package:outvisionxr/services/artist_service.dart';
import 'package:outvisionxr/services/artwork_service.dart';
import 'package:outvisionxr/services/download_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force SurfaceView renderer — compatible with Impeller disabled + ARCore
  final mapsImpl = GoogleMapsFlutterPlatform.instance;
  if (mapsImpl is GoogleMapsFlutterAndroid) {
    mapsImpl.useAndroidViewSurface = true;
  }

  GoogleFonts.config.allowRuntimeFetching = false;

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    return true;
  };

  if (kReleaseMode) {
    ErrorWidget.builder =
        (details) => _ErrorScreen(details.exception.toString());
  }

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  LocaleSettings.setLocale(AppLocale.pt);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(
    MultiProvider(
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
        ChangeNotifierProvider<DownloadService>(
          create: (_) => DownloadService(),
        ),
      ],
      child: TranslationProvider(
        child: const BienalDeCuritibaApp(),
      ),
    ),
  );
}

class BienalDeCuritibaApp extends StatelessWidget {
  const BienalDeCuritibaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: TranslationProvider.of(context).flutterLocale,
      debugShowCheckedModeBanner: false,
      title: 'Bienal de Curitiba App',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 24,
        ),
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  const _ErrorScreen(this.message);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: Colors.black54),
                const SizedBox(height: 16),
                Text(
                  t.errorScreen.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
