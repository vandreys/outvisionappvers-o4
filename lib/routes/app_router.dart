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
import 'package:outvisionxr/pages/splash_screen.dart';

class AppRouter {
  static const String splash         = '/splash';
  static const String explore        = '/';
  static const String artwork        = '/artwork';
  static const String artists        = '/artists';
  static const String settings       = '/settings';
  static const String settingsLang   = '/settings/language';
  static const String settingsAbout  = '/settings/about';
  static const String settingsApp    = '/settings/about-app';
  static const String artworkDetails = '/artwork/details';
  static const String artistDetails  = '/artist/details';
  static const String ar             = '/ar';

  static Route<dynamic> onGenerateRoute(RouteSettings route) {
    switch (route.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case explore:
        return MaterialPageRoute(builder: (_) => const ExplorePage());

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

      case artworkDetails:
        final id = route.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ArtworkDetailsPage(artworkId: id),
        );

      case artistDetails:
        final artist = route.arguments as Artist;
        return MaterialPageRoute(
          builder: (_) => DetailsArtistPage(artist: artist),
        );

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
