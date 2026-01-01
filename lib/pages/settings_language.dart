import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  // Idioma selecionado atualmente
  String? _selectedLanguage = 'Português (Brasil)';

  final List<String> _availableLanguages = [
    'Português (Brasil)',
    'English (US)',
    'Español (España)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco da tela
      appBar: AppBar(
        title: Text(
          'Idioma',
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
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0), // Padding ao redor da lista de botões
        itemCount: _availableLanguages.length,
        itemBuilder: (context, index) {
          final language = _availableLanguages[index];
          final isSelected = language == _selectedLanguage; // Verifica se este idioma está selecionado

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0), // Espaçamento entre os botões
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedLanguage = language; // Atualiza o idioma selecionado
                  print('Idioma selecionado: $language');
                });
              },
              borderRadius: BorderRadius.circular(12), // Arredondamento do botão
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.black, // Fundo preto para todos os botões
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2) // Borda branca para o selecionado
                      : null, // Sem borda para os não selecionados
                  boxShadow: [ // Sombra sutil para dar profundidade
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinha texto à esquerda e ícone à direita
                  children: [
                    Text(
                      language,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white, // Texto branco para todos os botões
                      ),
                    ),
                    if (isSelected) // Ícone de checkmark (✓) se selecionado
                      const Icon(Icons.check, color: Colors.white, size: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}