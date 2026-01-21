// widgets/language_switcher.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/pages/explore_page.dart';
import 'package:provider/provider.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/utils/language_provider.dart';

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
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final currentAppLocale = languageProvider.currentLocale;

        final Map<AppLocale, String> languageDisplayMap = {
          AppLocale.pt: _getLocaleName(AppLocale.pt),
          AppLocale.en: _getLocaleName(AppLocale.en),
          AppLocale.es: _getLocaleName(AppLocale.es),
        };

        return Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: languageDisplayMap.length,
            itemBuilder: (context, index) {
              final AppLocale appLocale =
                  languageDisplayMap.keys.elementAt(index);
              final String languageDisplayName =
                  languageDisplayMap.values.elementAt(index);

              final bool isSelected = appLocale == currentAppLocale;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    languageProvider.setLocale(appLocale);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ExplorePage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: Colors.white,
                              width: 2,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          languageDisplayName,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
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
