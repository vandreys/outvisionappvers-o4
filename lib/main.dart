import 'package:flutter/material.dart';
import 'package:outvisionxr/pages/maple_sample.dart'; // Mantido conforme seu código
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart'; // Import do pacote provider
import 'package:outvisionxr/utils/language_provider.dart'; // Import do seu LanguageProvider

void main() {
  runApp(
    ChangeNotifierProvider( // Envolve o app com o provedor de idioma
      create: (context) => LanguageProvider(),
      child: const OutvisionApp(),
    ),
  );
}

class OutvisionApp extends StatelessWidget {
  const OutvisionApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Out Vision XR App', // Mantido
      theme: ThemeData(
        useMaterial3: true, // Mantido
        
        // Define a Montserrat como fonte padrão para todo o app
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
        
        // Gera um esquema de cores baseado em tons de preto e cinza
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black, // Mantido
          brightness: Brightness.light, // Mantido
        ),
        
        // Estilização extra para botões e AppBar (opcional, mas recomendado)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ), // Mantido
      ),
      // Certifique-se de que a MapSample() aponta para o seu mapa ou tela inicial
      home: const MapSample(),
    );
  }
}
