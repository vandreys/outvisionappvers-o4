import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/pages/explore_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:outvisionxr/utils/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final languageProvider = LanguageProvider();
  LocaleSettings.setLocale(AppLocale.pt);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageProvider>.value(
          value: languageProvider,
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

        // FORÇA INTER EM TODO O APP
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
