import 'package:flutter/material.dart';
import 'package:outvisionxr/pages/maple_sample.dart'; 
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const OutvisionApp());
}

class OutvisionApp extends StatelessWidget {
  const OutvisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Out Vision XR App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, // Essencial para habilitar o design moderno do Material 3
        
        // Define a Montserrat como fonte padrão para todo o app
        textTheme: GoogleFonts.montserratTextTheme(
          Theme.of(context).textTheme,
        ),
        
        // Gera um esquema de cores baseado em tons de preto e cinza
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black, // Substituí o ARGB por Colors.black para simplificar
          brightness: Brightness.light, // Define se o tema base é claro ou escuro
        ),
        
        // Estilização extra para botões e AppBar (opcional, mas recomendado)
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      // Certifique-se de que a MapSample() aponta para o seu mapa ou tela inicial
      home: const MapSample(), 
    );
  }
}