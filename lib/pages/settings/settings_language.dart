import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:outvisionxr/i18n/strings.g.dart';
import 'package:outvisionxr/utils/app_theme.dart';
import 'package:outvisionxr/utils/language_provider.dart';
import 'package:provider/provider.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
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

    final orderedLocales = [
      AppLocale.pt,
      AppLocale.en,
      AppLocale.es,
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.hairline, width: 1),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.bg2,
                      ),
                      child: const Icon(Icons.chevron_left, size: 18, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Text(
                context.t.languagePage.title,
                style: GoogleFonts.inter(
                  fontSize: 36,
                  fontWeight: FontWeight.w400,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: orderedLocales.length,
                itemBuilder: (context, index) {
                  final locale = orderedLocales[index];
                  final languageProvider = Provider.of<LanguageProvider>(context);
                  final isSelected = languageProvider.currentLocale == locale;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.hairline, width: 1),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => languageProvider.setLocale(locale),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                getLanguageName(locale),
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check,
                                  size: 16, color: AppColors.ink),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
