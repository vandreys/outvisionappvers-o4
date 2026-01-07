// utils/language_provider.dart
import 'package:flutter/material.dart';
import 'package:outvisionxr/i18n/strings.g.dart'; // Certifique-se de que este caminho está correto

class LanguageProvider extends ChangeNotifier {
  AppLocale _currentLocale = AppLocale.pt;

  AppLocale get currentLocale => _currentLocale;

  void setLocale(AppLocale newLocale) {
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
      LocaleSettings.setLocale(newLocale); // ESSENCIAL: Atualiza o locale global do slang
      notifyListeners(); // Notifica os widgets que estão ouvindo
    }
  }
}
