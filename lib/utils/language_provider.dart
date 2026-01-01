    import 'package:flutter/material.dart';
    import 'package:shared_preferences/shared_preferences.dart';

    class LanguageProvider extends ChangeNotifier {
      Locale _appLocale = const Locale('pt', 'BR'); // Idioma padrão

      Locale get appLocale => _appLocale;

      LanguageProvider() {
        fetchLocale();
      }

      // Carrega o idioma salvo nas preferências
      Future<void> fetchLocale() async {
        var prefs = await SharedPreferences.getInstance();
        if (prefs.getString('language_code') == null) {
          _appLocale = const Locale('pt', 'BR'); // Padrão
          return;
        }
        _appLocale = Locale(prefs.getString('language_code')!, prefs.getString('country_code'));
        notifyListeners(); // Notifica os ouvintes sobre a mudança
      }

      // Altera o idioma e salva nas preferências
      Future<void> changeLanguage(Locale type) async {
        var prefs = await SharedPreferences.getInstance();
        if (_appLocale == type) {
          return; // Não faz nada se o idioma já for o mesmo
        }
        if (type == const Locale('pt', 'BR')) {
          _appLocale = const Locale('pt', 'BR');
          await prefs.setString('language_code', 'pt');
          await prefs.setString('country_code', 'BR');
        } else if (type == const Locale('en', 'US')) {
          _appLocale = const Locale('en', 'US');
          await prefs.setString('language_code', 'en');
          await prefs.setString('country_code', 'US');
        } else if (type == const Locale('es', 'ES')) {
          _appLocale = const Locale('es', 'ES');
          await prefs.setString('language_code', 'es');
          await prefs.setString('country_code', 'ES');
        } else if (type == const Locale('fr', 'FR')) {
          _appLocale = const Locale('fr', 'FR');
          await prefs.setString('language_code', 'fr');
          await prefs.setString('country_code', 'FR');
        } else if (type == const Locale('de', 'DE')) {
          _appLocale = const Locale('de', 'DE');
          await prefs.setString('language_code', 'de');
          await prefs.setString('country_code', 'DE');
        } else if (type == const Locale('zh', 'CN')) { // Chinês simplificado
          _appLocale = const Locale('zh', 'CN');
          await prefs.setString('language_code', 'zh');
          await prefs.setString('country_code', 'CN');
        }
        notifyListeners(); // Notifica os ouvintes sobre a mudança
      }
    }