import 'package:flutter/material.dart';
import 'package:outvisionxr/models/artist_model.dart';
import 'package:outvisionxr/models/artwork_model.dart';
import 'package:outvisionxr/pages/ar/ar_experience_page.dart';
import 'package:outvisionxr/pages/artist_page.dart';
import 'package:outvisionxr/pages/artwork_details_page.dart';
import 'package:outvisionxr/pages/artwork_page.dart';
import 'package:outvisionxr/pages/details_artist_page.dart';
import 'package:outvisionxr/pages/explore_page.dart';
import 'package:outvisionxr/pages/settings_page.dart';
import 'package:outvisionxr/pages/settings/settings_language.dart';
import 'package:outvisionxr/pages/settings/settings_about.dart';
import 'package:outvisionxr/pages/settings/settings_about_app.dart';
import 'package:outvisionxr/pages/settings/settings_howtouse.dart';
import 'package:outvisionxr/pages/settings/settings_limiares.dart';
import 'package:outvisionxr/pages/splash_screen.dart';
import 'package:outvisionxr/pages/welcome_page.dart';

PageRouteBuilder<T> _fadeSlideRoute<T>({required Widget page}) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.035),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
    },
  );
}

class AppRouter {
  static const String splash         = '/splash';
  static const String welcome        = '/welcome';
  static const String explore        = '/';
  static const String artwork        = '/artwork';
  static const String artists        = '/artists';
  static const String settings       = '/settings';
  static const String settingsLang      = '/settings/language';
  static const String settingsAbout     = '/settings/about';
  static const String settingsApp       = '/settings/about-app';
  static const String settingsLimiares  = '/settings/limiares';
  static const String settingsHowToUse  = '/settings/how-to-use';
  static const String artworkDetails = '/artwork/details';
  static const String artistDetails  = '/artist/details';
  static const String ar             = '/ar';

  static Route<dynamic> onGenerateRoute(RouteSettings route) {
    switch (route.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomePage());

      case explore:
        final artworkId = route.arguments as String?;
        return MaterialPageRoute(builder: (_) => ExplorePage(initialArtworkId: artworkId));

      case artwork:
        return MaterialPageRoute(builder: (_) => const ArtworkPage());

      case artists:
        return MaterialPageRoute(builder: (_) => const ArtistsPage());

      case settings:
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SettingsPage(),
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.ease))
                .animate(animation),
            child: child,
          ),
        );

      case settingsLang:
        return MaterialPageRoute(builder: (_) => const LanguagePage());

      case settingsAbout:
        return MaterialPageRoute(builder: (_) => const AboutPage());

      case settingsApp:
        return MaterialPageRoute(builder: (_) => const AboutAppPage());

      case settingsLimiares:
        return MaterialPageRoute(builder: (_) => const LimiaresPage());

      case settingsHowToUse:
        return MaterialPageRoute(builder: (_) => const HowToUsePage());

      case artworkDetails:
        final id = route.arguments as String;
        return _fadeSlideRoute(page: ArtworkDetailsPage(artworkId: id));

      case artistDetails:
        final artist = route.arguments as Artist;
        return _fadeSlideRoute(page: DetailsArtistPage(artist: artist));

      case ar:
        final artworkModel = route.arguments as Artwork;
        return MaterialPageRoute(
          builder: (_) => ARExperiencePage(artwork: artworkModel),
        );

      default:
        return MaterialPageRoute(builder: (_) => const ExplorePage());
    }
  }
}
