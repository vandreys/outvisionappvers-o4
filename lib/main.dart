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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  final languageProvider = LanguageProvider();
  LocaleSettings.setLocale(AppLocale.pt);

  // Configura a barra de status e navegação para serem transparentes/modernas
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent, // Deixa a barra de baixo transparente em Androids modernos
  ));

  // Ativa o modo imersivo (esconde as barras do sistema e só mostra ao deslizar)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>.value(
          value: languageProvider,
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
  );
}

class OutvisionApp extends StatelessWidget {
  const OutvisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: TranslationProvider.of(context).flutterLocale,
      debugShowCheckedModeBanner: false,
      title: 'Out Vision XR App',

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
