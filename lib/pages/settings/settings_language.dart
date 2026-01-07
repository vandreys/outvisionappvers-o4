import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/widgets/language_switcher.dart';
// import 'package:provider/provider.dart'; // Não é necessário importar aqui se o Provider for configurado no main.dart

class LanguagePage extends StatelessWidget { // Mudado para StatelessWidget
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco da tela
      appBar: AppBar(
        title: Text(t.languagePage.title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black, // Título do AppBar em preto
          ),
        ),
        backgroundColor: Colors.white, // Fundo do AppBar branco
        elevation: 0, // Sem sombra no AppBar
        iconTheme: const IconThemeData(color: Colors.black), // Ícone de voltar em preto
      ),
      body: const LanguageSwitcher(),
    );
  }
}
