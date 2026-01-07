// widgets/language_switcher.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/pages/explore_page.dart';
import 'package:provider/provider.dart';
import 'package:outvisionxr/i18n/strings.g.dart'; // Importe o seu arquivo de traduções
import 'package:outvisionxr/utils/language_provider.dart'; // Importe o seu LanguageProvider

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  // Função auxiliar para obter um nome legível para o idioma
  String _getLocaleName(AppLocale locale) {
    switch (locale) {
      case AppLocale.pt:
        return 'Português (Brasil)';
      case AppLocale.en:
        return 'English';
      case AppLocale.es:
        return 'Español';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para ouvir as mudanças no LanguageProvider e reconstruir esta parte da UI
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final currentAppLocale = languageProvider.currentLocale;

        // Mapeia os AppLocales para nomes de exibição amigáveis
        final Map<AppLocale, String> languageDisplayMap = {
          AppLocale.pt: _getLocaleName(AppLocale.pt),
          AppLocale.en: _getLocaleName(AppLocale.en),
          AppLocale.es: _getLocaleName(AppLocale.es),
        };

        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.all(16.0), // Padding ao redor da lista de botões
            itemCount: languageDisplayMap.length,
            itemBuilder: (context, index) {
              // Obtém o AppLocale e o nome de exibição para o item atual
              final AppLocale appLocale = languageDisplayMap.keys.elementAt(index);
              final String languageDisplayName = languageDisplayMap.values.elementAt(index);
              
              // Verifica se este idioma é o atualmente selecionado globalmente
              final isSelected = appLocale == currentAppLocale;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0), // Espaçamento entre os botões
                child: InkWell(
                  onTap: () {
                    languageProvider.setLocale(appLocale);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ExplorePage()),
                    );
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
                          languageDisplayName,
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
      },
    );
  }
}