import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/widgets/language_switcher.dart';


class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Helper para obter o nome do idioma traduzido
    String getLanguageName(AppLocale locale) {
      switch (locale) {
        case AppLocale.pt:
          return context.t.languagePage.portuguese;
        case AppLocale.en:
          return context.t.languagePage.english;
        case AppLocale.es:
          return context.t.languagePage.spanish;
      }
    }

    // Define a ordem de exibição explicitamente: Português primeiro
    final orderedLocales = [
      AppLocale.pt,
      AppLocale.en,
      AppLocale.es,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Background Off-white / Gelo
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5), // AppBar combinando com o fundo
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          context.t.languagePage.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0), // Padding similar ao da SettingsPage
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // Container Branco (#ffffff)
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: orderedLocales.asMap().entries.map((entry) {
                  final index = entry.key;
                  final locale = entry.value;
                  final isSelected = LocaleSettings.currentLocale == locale;
                  final isLast = index == orderedLocales.length - 1;

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          getLanguageName(locale),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black, // Texto Preto
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.black)
                            : null,
                        onTap: () {
                          // Atualiza o idioma do app
                          LocaleSettings.setLocale(locale);
                        },
                      ),
                      // Adiciona o divisor apenas se não for o último item
                      if (!isLast)
                        Divider(height: 1, color: Colors.grey[300]),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
