/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 3
/// Strings: 294 (98 per locale)
///
/// Built on 2026-04-21 at 08:18 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	en(languageCode: 'en', build: Translations.build),
	es(languageCode: 'es', build: _StringsEs.build),
	pt(languageCode: 'pt', build: _StringsPt.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, Translations> build;

	/// Gets current instance managed by [LocaleSettings].
	Translations get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
Translations get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class TranslationProvider extends BaseTranslationProvider<AppLocale, Translations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, Translations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	Translations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, Translations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, Translations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	late final _StringsGalleryEn gallery = _StringsGalleryEn._(_root);
	late final _StringsSettingsEn settings = _StringsSettingsEn._(_root);
	late final _StringsLimiaresEn limiares = _StringsLimiaresEn._(_root);
	late final _StringsAboutEn about = _StringsAboutEn._(_root);
	late final _StringsLanguagePageEn languagePage = _StringsLanguagePageEn._(_root);
	late final _StringsMapEn map = _StringsMapEn._(_root);
	late final _StringsBottomNavEn bottomNav = _StringsBottomNavEn._(_root);
	late final _StringsWelcomeEn welcome = _StringsWelcomeEn._(_root);
	late final _StringsErrorScreenEn errorScreen = _StringsErrorScreenEn._(_root);
	late final _StringsArEn ar = _StringsArEn._(_root);
}

// Path: gallery
class _StringsGalleryEn {
	_StringsGalleryEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Artworks';
	String get tabArtwork => 'Artworks';
	String get tabArtists => 'Artists';
	String get search => 'Search...';
	String get artworkTitle => 'The Garden of Earthly Delights';
	String get artworkArtist => 'Hieronymus Bosch';
	String get artistSubtitle => 'Curitiba Biennial 2025';
	String get viewExhibition => 'View artwork';
	String get artistDetails => 'Artist Details';
	String get works => 'Works';
	String get noArtworkFound => 'No artwork found';
	String get noArtistFound => 'No artist found';
	String get unknownArtist => 'Unknown artist';
	String get highlights => 'Highlights';
	String get viewAll => 'View all';
	String get bioMore => ' more';
	String get showOnMap => 'Show on map';
	String get makeAvailableOffline => 'Make available offline';
	String get artist => 'Artist';
}

// Path: settings
class _StringsSettingsEn {
	_StringsSettingsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Settings';
	String get getHelp => 'How to use the App';
	String get appSettings => 'App Settings';
	String get language => 'Language';
	String get about => '16th International Biennial of Curitiba';
	String get limiares => 'Limiares';
	String get website => 'Website';
	String get instagram => 'Instagram';
	String get aboutApp => 'About the App';
	String get privacyPolicy => 'Privacy Policy';
	String get termsOfUse => 'Terms of Use';
}

// Path: limiares
class _StringsLimiaresEn {
	_StringsLimiaresEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'LIMIARES';
	String get conceptText => 'The 16th International Biennial of Curitiba draws on the concept of LIMIAR (THRESHOLD), understood as the space between what is not yet and what is already beginning to be. In a world marked by the dissolution of boundaries between the human and the technological, the natural and the artificial, the Biennial presents itself as a territory of transition — a laboratory of listening, risk, and transformation.\n\nHere, art acts as a mediating force between worlds, opening passages to new modes of existence and perception.\n\nOn the threshold between crisis and creation, art reveals its power of invention and its capacity to imagine possible futures.';
	String get statementTitle => 'CURATORIAL STATEMENT';
	String get statementText => 'In a world traversed by accelerating technological, social, and environmental transformations, the 16th International Biennial of Curitiba — taking place between March and August 2026 — presents itself as a transdisciplinary laboratory of experimentation, where art, science, technology, and critical thinking converge to explore the challenges of contemporaneity.\n\nThis edition tests the limits between artistic production, audiences, critical thought, and civic action, investigating hybrid modes of existence and the dissolved boundaries between the biological and the synthetic, the human and the non-human. These zones of friction — between the natural and the artificial, the sensory and the programmable — inform the practices of the future and offer fertile ground for the aesthetic and emergent existence of art.\n\nWe live in an era marked by the omnipresence of algorithms, the rise of artificial intelligence, and the supremacy of digital capitalism. In this context, artistic practice is no longer exclusively individual expression but becomes an expanded field of collaboration between humans, machines, and intelligent systems. The traditional concept of authorship is called into question, making space for the artist as programmer, mediator, or facilitator of algorithmic processes.\n\nHow does aesthetic experience transform in times of augmented realities, big data, and digital ecologies? Art, more than representing the world, becomes a living, responsive, and critical interface that questions the regimes of visuality and the systems of power that structure our daily lives. Hybrid languages — fusing the physical and the virtual, the organic and the computational — expand the horizons of sensibility and open pathways to new forms of activism, memory, and subjectivity.\n\nAnother fundamental axis of this edition lies in the critique of the neutrality of technology. Artificial intelligence and algorithmic systems are shaped by political, economic, and ideological interests. Art, in this context, emerges as a device of resistance against data extractivism, mass surveillance, and the mechanisms of control and inequality operating behind the scenes of the digital age.\n\nThe 16th International Biennial of Curitiba summons artists, researchers, scientists, technologists, and activists to imagine possible futures and reflect on the impacts of technological innovation on forms of life, identities, and the materialities of the contemporary world. Through immersive installations, generative art, interactive environments, virtual reality simulations, and post-humanist practices, the Biennial proposes to map the speculative terrain of emerging practices, placing the local and the global, the body and the code, the sensory and the synthetic in dialogue.\n\nThe public will be invited to participate in transformative experiences, interacting with works that reconfigure the ways of perceiving, acting, and imagining. In this encounter between art and technopolitics, the Biennial seeks to be a platform of listening, invention, and risk, opening breaches in the present to rehearse more just, conscious, and sensitive forms of coexistence.';
	String get curatorsLabel => 'Curators';
	String get curatorsNames => 'Adriana Almada and Tereza de Arruda';
}

// Path: about
class _StringsAboutEn {
	_StringsAboutEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get pageTitle => 'About the App';
	String get mainTitle => '16th International Biennial of Curitiba';
	String get description => 'This app is an official experience of the 16th International Biennial of Curitiba, developed with a focus on visualizing artworks through Augmented Reality (AR). In dialogue with the curatorial theme Limiares (Thresholds), the app invites visitors to cross boundaries between the physical and digital worlds, exploring art in an immersive and interactive way across the Biennial\'s venues.';
	String get missionTitle => 'About Outvision XR';
	String get missionText => 'Outvision XR is a platform specialized in art experiences with Augmented Reality. Combining technology and culture, we enhance the connection between artworks, artists, and audiences, making contemporary art more accessible, sensory, and memorable.';
	String get visionTitle => 'Limiares (Thresholds)';
	String get visionText => 'The curatorial theme Limiares (Thresholds) invites reflection on the boundaries — physical, cultural, symbolic — that separate and unite us. Through Augmented Reality, the app transforms these thresholds into portals, allowing each artwork to be experienced beyond the visible.';
	String get connectTitle => 'Connect With Us';
	String get website => 'Website';
	String get email => 'Email';
	String get instagram => 'Instagram';
	String get share => 'Share';
	String get copyright => 'Outvision XR © 2025. All rights reserved.';
}

// Path: languagePage
class _StringsLanguagePageEn {
	_StringsLanguagePageEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Language';
	String get portuguese => 'Portuguese';
	String get english => 'English';
	String get spanish => 'Spanish';
}

// Path: map
class _StringsMapEn {
	_StringsMapEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get loadingGps => 'Searching for GPS signal...';
	String get artworkLargo => 'AR Artwork: Largo da Ordem';
	String get artworkMon => 'AR Artwork: MON';
	String get artworkOpera => 'AR Artwork: Ópera de Arame';
	String get arrivedTitle => 'You have arrived at the artwork location';
	String get openArButton => 'Open Augmented Reality';
	String get locationServiceDisabled => 'Location service disabled.';
	String get locationPermissionDenied => 'Location permission denied.';
	String get locationPermissionPermanentlyDenied => 'Location permission permanently denied. Please enable it in settings.';
	String get locationNotFound => 'Could not get your location. Please try again.';
	String get locationError => 'Error initializing location.';
	String get helpTitle => 'Map Help';
	String get helpContent => 'Explore the map to find the artworks. When you get close to a point, you can open the Augmented Reality experience. Use the zoom buttons (+/-) and the navigation button to center the map on your current position.';
	String get noNearbyArtwork => 'No artwork near your location';
	String get noNearbyArtworkDesc => 'There are no artworks visible around your location. Zoom out or use the button below to navigate to the nearest artwork.';
	String get takeToNearest => 'Take me to the nearest artwork';
	String get navigate => 'Navigate';
	String get connectionError => 'Connection error. Check your internet.';
}

// Path: bottomNav
class _StringsBottomNavEn {
	_StringsBottomNavEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get explore => 'Explore';
	String get gallery => 'Artworks';
	String get captured => 'Captured';
	String get settings => 'Settings';
}

// Path: welcome
class _StringsWelcomeEn {
	_StringsWelcomeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get headline => 'Art and design\nat its best';
	String get startButton => 'Start';
}

// Path: errorScreen
class _StringsErrorScreenEn {
	_StringsErrorScreenEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get message => 'Something went wrong.\nRestart the application.';
}

// Path: ar
class _StringsArEn {
	_StringsArEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get scanInstruction => 'Scan the floor by moving your phone';
	String get tapToPlace => 'Tap the screen to place the artwork';
	String get helpTitle => 'Help';
	String get helpContent => 'Move the device slowly and point it at your surroundings to improve localization.';
	String get ok => 'OK';
	String get permissionTitle => 'Permissions Required';
	String get permissionContent => 'To view the artwork, we need access to your camera and location.';
	String get allowAccess => 'Allow Access';
	String get notNow => 'Not Now';
	String get onboardingContent => 'Move the device slowly to help the Artwork localize itself.';
	String get onboardingButton => 'Got it, let\'s start';
	String get errorTitle => 'An Error Occurred';
	String get backButton => 'Back';
	String get tryAgain => 'Try again';
	String get genericError => 'Augmented Reality error.';
	String get localizationTimeoutError => 'Could not localize the artwork. Try restarting the AR experience.';
	String get eventsError => 'Failed to receive Augmented Reality events.';
	String get unsupported => 'Augmented Reality not supported on this platform';
	String get openAr => 'Open AR';
	String get modelUnavailable => '3D model not available\nfor this artwork.';
}

// Path: <root>
class _StringsEs implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsEs.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	@override late final _StringsEs _root = this; // ignore: unused_field

	// Translations
	@override late final _StringsGalleryEs gallery = _StringsGalleryEs._(_root);
	@override late final _StringsSettingsEs settings = _StringsSettingsEs._(_root);
	@override late final _StringsLimiaresEs limiares = _StringsLimiaresEs._(_root);
	@override late final _StringsAboutEs about = _StringsAboutEs._(_root);
	@override late final _StringsLanguagePageEs languagePage = _StringsLanguagePageEs._(_root);
	@override late final _StringsMapEs map = _StringsMapEs._(_root);
	@override late final _StringsBottomNavEs bottomNav = _StringsBottomNavEs._(_root);
	@override late final _StringsWelcomeEs welcome = _StringsWelcomeEs._(_root);
	@override late final _StringsErrorScreenEs errorScreen = _StringsErrorScreenEs._(_root);
	@override late final _StringsArEs ar = _StringsArEs._(_root);
}

// Path: gallery
class _StringsGalleryEs implements _StringsGalleryEn {
	_StringsGalleryEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Obras';
	@override String get tabArtwork => 'Obras';
	@override String get tabArtists => 'Artistas';
	@override String get search => 'Buscar...';
	@override String get artworkTitle => 'El Jardín de las Delicias';
	@override String get artworkArtist => 'Hieronymus Bosch';
	@override String get artistSubtitle => 'Bienal de Curitiba 2025';
	@override String get viewExhibition => 'Ver obra';
	@override String get artistDetails => 'Detalles del Artista';
	@override String get works => 'Obras';
	@override String get noArtworkFound => 'Ninguna obra encontrada';
	@override String get noArtistFound => 'Ningún artista encontrado';
	@override String get unknownArtist => 'Artista desconocido';
	@override String get highlights => 'Destacados';
	@override String get viewAll => 'Ver todo';
	@override String get bioMore => ' más';
	@override String get showOnMap => 'Ver en el mapa';
	@override String get makeAvailableOffline => 'Hacer disponible sin conexión';
	@override String get artist => 'Artista';
}

// Path: settings
class _StringsSettingsEs implements _StringsSettingsEn {
	_StringsSettingsEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Configuración';
	@override String get getHelp => 'Cómo usar la App';
	@override String get appSettings => 'Configuración de la App';
	@override String get language => 'Idioma';
	@override String get about => '16ª Bienal Internacional de Curitiba';
	@override String get limiares => 'Limiares';
	@override String get website => 'Sitio Web';
	@override String get instagram => 'Instagram';
	@override String get aboutApp => 'Sobre la App';
	@override String get privacyPolicy => 'Política de Privacidad';
	@override String get termsOfUse => 'Términos de Uso';
}

// Path: limiares
class _StringsLimiaresEs implements _StringsLimiaresEn {
	_StringsLimiaresEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'LIMIARES';
	@override String get conceptText => 'La 16ª Bienal Internacional de Curitiba parte del concepto LIMIAR (UMBRAL), entendido como el espacio entre lo que aún no es y lo que ya comienza a ser. En un mundo marcado por la disolución de las fronteras entre lo humano y lo tecnológico, lo natural y lo artificial, la Bienal se propone como un territorio de transición — un laboratorio de escucha, riesgo y transformación.\n\nAquí, el arte actúa como fuerza mediadora entre mundos, abriendo pasajes hacia nuevos modos de existencia y percepción.\n\nEn el umbral entre crisis y creación, el arte revela su potencia de invención y su capacidad de imaginar futuros posibles.';
	@override String get statementTitle => 'STATEMENT CURATORIAL';
	@override String get statementText => 'En un mundo atravesado por aceleradas transformaciones tecnológicas, sociales y ambientales, la 16ª Bienal Internacional de Curitiba — que tiene lugar entre marzo y agosto de 2026 — se propone como un laboratorio transdisciplinar de experimentación, donde arte, ciencia, tecnología y pensamiento crítico convergen para explorar los desafíos de la contemporaneidad.\n\nEsta edición tensiona los límites entre producción artística, públicos, pensamiento crítico y acción ciudadana, investigando los modos de existencia híbridos y las fronteras disueltas entre lo biológico y lo sintético, lo humano y lo no-humano. Son estas zonas de fricción — entre lo natural y lo artificial, lo sensible y lo programable — las que informan las prácticas del porvenir y ofrecen terreno fértil para la existencia estética y emergencial del arte.\n\nVivemos una era marcada por la omnipresencia de los algoritmos, el auge de la inteligencia artificial y la supremacía del capitalismo digital. En este contexto, la práctica artística deja de ser exclusivamente expresión individual para convertirse en un campo expandido de colaboración entre humanos, máquinas y sistemas inteligentes. El concepto tradicional de autoría es puesto en cuestión, abriendo espacio para el artista como programador, mediador o facilitador de procesos algorítmicos.\n\n¿Cómo se transforma la experiencia estética en tiempos de realidades aumentadas, big data y ecologías digitales? El arte, más que representar el mundo, se convierte en una interfaz viva, responsiva y crítica, que cuestiona los regímenes de visualidad y los sistemas de poder que estructuran nuestro cotidiano. Los lenguajes híbridos — que fusionan lo físico y lo virtual, lo orgánico y lo computacional — amplían los horizontes de la sensibilidad y abren caminos hacia nuevas formas de activismo, memoria y subjetividad.\n\nOtro eje fundamental de esta edición reside en la crítica a la neutralidad de la tecnología. La inteligencia artificial y los sistemas algorítmicos son moldeados por intereses políticos, económicos e ideológicos. El arte, en este contexto, emerge como un dispositivo de resistencia contra el extractivismo de datos, la vigilancia masiva y los mecanismos de control y desigualdad que operan entre bastidores de la era digital.\n\nLa 16ª Bienal Internacional de Curitiba convoca a artistas, investigadores, científicos, tecnólogos y activistas a imaginar futuros posibles y reflexionar sobre los impactos de la innovación tecnológica en las formas de vida, las identidades y las materialidades del mundo contemporáneo. A través de instalaciones inmersivas, arte generativo, ambientes interactivos, simulaciones en realidad virtual y prácticas posthumanistas, la Bienal se propone trazar un mapa especulativo de las prácticas emergentes, poniendo en diálogo lo local y lo global, el cuerpo y el código, lo sensible y lo sintético.\n\nEl público será invitado a participar de experiencias transformadoras, interactuando con obras que reconfiguran los modos de percibir, actuar e imaginar. En este encuentro entre arte y tecnopolítica, la Bienal quiere ser plataforma de escucha, de invención y de riesgo, abriendo brechas en el presente para ensayar formas de coexistencia más justas, conscientes y sensibles.';
	@override String get curatorsLabel => 'Curadoras';
	@override String get curatorsNames => 'Adriana Almada y Tereza de Arruda';
}

// Path: about
class _StringsAboutEs implements _StringsAboutEn {
	_StringsAboutEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get pageTitle => 'Sobre la App';
	@override String get mainTitle => '16ª Bienal Internacional de Curitiba';
	@override String get description => 'Esta aplicación es una experiencia oficial de la 16ª Bienal Internacional de Curitiba, desarrollada con foco en la visualización de obras en Realidad Aumentada (RA). En diálogo con el tema curatorial Limiares (Umbrales), la app invita al visitante a cruzar fronteras entre el mundo físico y el digital, explorando el arte de forma inmersiva e interactiva en los espacios de la Bienal.';
	@override String get missionTitle => 'Sobre Outvision XR';
	@override String get missionText => 'Outvision XR es una plataforma especializada en experiencias de arte con Realidad Aumentada. Uniendo tecnología y cultura, potenciamos la conexión entre obras, artistas y públicos, haciendo que el arte contemporáneo sea más accesible, sensorial y memorable.';
	@override String get visionTitle => 'Limiares (Umbrales)';
	@override String get visionText => 'El tema curatorial Limiares (Umbrales) propone una reflexión sobre las fronteras — físicas, culturales, simbólicas — que nos separan y nos unen. A través de la Realidad Aumentada, la app transforma esos umbrales en portales, permitiendo que cada obra sea vivida más allá de lo visible.';
	@override String get connectTitle => 'Conéctate con Nosotros';
	@override String get website => 'Sitio Web';
	@override String get email => 'Correo Electrónico';
	@override String get instagram => 'Instagram';
	@override String get share => 'Compartir';
	@override String get copyright => 'Outvision XR © 2025. Todos los derechos reservados.';
}

// Path: languagePage
class _StringsLanguagePageEs implements _StringsLanguagePageEn {
	_StringsLanguagePageEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Idioma';
	@override String get portuguese => 'Portugués';
	@override String get english => 'Inglés';
	@override String get spanish => 'Español';
}

// Path: map
class _StringsMapEs implements _StringsMapEn {
	_StringsMapEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get loadingGps => 'Buscando señal de GPS...';
	@override String get artworkLargo => 'Obra AR: Largo da Ordem';
	@override String get artworkMon => 'Obra AR: MON';
	@override String get artworkOpera => 'Obra AR: Ópera de Arame';
	@override String get arrivedTitle => 'Has llegado a la ubicación de la obra';
	@override String get openArButton => 'Abrir Realidad Aumentada';
	@override String get locationServiceDisabled => 'Servicio de ubicación desactivado.';
	@override String get locationPermissionDenied => 'Permiso de ubicación denegado.';
	@override String get locationPermissionPermanentlyDenied => 'Permiso de ubicación denegado permanentemente. Habilítelo en la configuración.';
	@override String get locationNotFound => 'No se pudo obtener tu ubicación. Por favor, inténtalo de nuevo.';
	@override String get locationError => 'Error al iniciar la ubicación.';
	@override String get helpTitle => 'Ayuda del Mapa';
	@override String get helpContent => 'Explora el mapa para encontrar las obras de arte. Cuando te acerques a un punto, podrás abrir la experiencia de Realidad Aumentada. Utiliza los botones de zoom (+/-) y el botón de navegación para centrar el mapa en tu posición actual.';
	@override String get noNearbyArtwork => 'Ninguna obra de arte cerca de tu ubicación';
	@override String get noNearbyArtworkDesc => 'No hay obras de arte visibles alrededor de tu ubicación. Aleja el zoom o usa el botón de abajo para navegar hacia la obra más cercana.';
	@override String get takeToNearest => 'Llévame a la obra más cercana';
	@override String get navigate => 'Navegar';
	@override String get connectionError => 'Error de conexión. Verifica tu internet.';
}

// Path: bottomNav
class _StringsBottomNavEs implements _StringsBottomNavEn {
	_StringsBottomNavEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get explore => 'Explorar';
	@override String get gallery => 'Obras';
	@override String get captured => 'Capturados';
	@override String get settings => 'Configuración';
}

// Path: welcome
class _StringsWelcomeEs implements _StringsWelcomeEn {
	_StringsWelcomeEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get headline => 'Arte y diseño\nen su máximo esplendor';
	@override String get startButton => 'Comenzar';
}

// Path: errorScreen
class _StringsErrorScreenEs implements _StringsErrorScreenEn {
	_StringsErrorScreenEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get message => 'Algo salió mal.\nReinicia la aplicación.';
}

// Path: ar
class _StringsArEs implements _StringsArEn {
	_StringsArEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get scanInstruction => 'Escanea el suelo moviendo el móvil';
	@override String get tapToPlace => 'Toca la pantalla para posicionar la obra';
	@override String get helpTitle => 'Ayuda';
	@override String get helpContent => 'Mueve el dispositivo lentamente y apúntalo a tu entorno para mejorar la localización.';
	@override String get ok => 'OK';
	@override String get permissionTitle => 'Permisos Necesarios';
	@override String get permissionContent => 'Para visualizar la obra, necesitamos acceso a tu cámara y ubicación.';
	@override String get allowAccess => 'Permitir Acceso';
	@override String get notNow => 'Ahora no';
	@override String get onboardingContent => 'Mueve el dispositivo lentamente para ayudar a la Obra a localizarse.';
	@override String get onboardingButton => 'Entendido, empecemos';
	@override String get errorTitle => 'Ocurrió un Error';
	@override String get backButton => 'Volver';
	@override String get tryAgain => 'Intentar de nuevo';
	@override String get genericError => 'Error en la Realidad Aumentada.';
	@override String get localizationTimeoutError => 'No se pudo localizar la obra. Intenta reiniciar la experiencia de RA.';
	@override String get eventsError => 'Fallo al recibir eventos de Realidad Aumentada.';
	@override String get unsupported => 'Realidad Aumentada no compatible en esta plataforma';
	@override String get openAr => 'Abrir RA';
	@override String get modelUnavailable => 'Modelo 3D no disponible\npara esta obra.';
}

// Path: <root>
class _StringsPt implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsPt.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.pt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	@override late final _StringsPt _root = this; // ignore: unused_field

	// Translations
	@override late final _StringsGalleryPt gallery = _StringsGalleryPt._(_root);
	@override late final _StringsSettingsPt settings = _StringsSettingsPt._(_root);
	@override late final _StringsLimiaresPt limiares = _StringsLimiaresPt._(_root);
	@override late final _StringsAboutPt about = _StringsAboutPt._(_root);
	@override late final _StringsLanguagePagePt languagePage = _StringsLanguagePagePt._(_root);
	@override late final _StringsMapPt map = _StringsMapPt._(_root);
	@override late final _StringsBottomNavPt bottomNav = _StringsBottomNavPt._(_root);
	@override late final _StringsWelcomePt welcome = _StringsWelcomePt._(_root);
	@override late final _StringsErrorScreenPt errorScreen = _StringsErrorScreenPt._(_root);
	@override late final _StringsArPt ar = _StringsArPt._(_root);
}

// Path: gallery
class _StringsGalleryPt implements _StringsGalleryEn {
	_StringsGalleryPt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Obras';
	@override String get tabArtwork => 'Obras';
	@override String get tabArtists => 'Artistas';
	@override String get search => 'Buscar...';
	@override String get artworkTitle => 'O Jardim das Delícias Terrenas';
	@override String get artworkArtist => 'Hieronymus Bosch';
	@override String get artistSubtitle => 'Bienal de Curitiba 2025';
	@override String get viewExhibition => 'Ver obra';
	@override String get artistDetails => 'Detalhes do Artista';
	@override String get works => 'Obras';
	@override String get noArtworkFound => 'Nenhuma obra encontrada';
	@override String get noArtistFound => 'Nenhum artista encontrado';
	@override String get unknownArtist => 'Artista desconhecido';
	@override String get highlights => 'Destaques';
	@override String get viewAll => 'Ver tudo';
	@override String get bioMore => ' mais';
	@override String get showOnMap => 'Ver no mapa';
	@override String get makeAvailableOffline => 'Disponibilizar offline';
	@override String get artist => 'Artista';
}

// Path: settings
class _StringsSettingsPt implements _StringsSettingsEn {
	_StringsSettingsPt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Configurações';
	@override String get getHelp => 'Como usar o App';
	@override String get appSettings => 'Configurações do App';
	@override String get language => 'Idioma';
	@override String get about => '16ª Bienal Internacional de Curitiba';
	@override String get limiares => 'Limiares';
	@override String get website => 'Website';
	@override String get instagram => 'Instagram';
	@override String get aboutApp => 'Sobre o App';
	@override String get privacyPolicy => 'Política de Privacidade';
	@override String get termsOfUse => 'Termos de Uso';
}

// Path: limiares
class _StringsLimiaresPt implements _StringsLimiaresEn {
	_StringsLimiaresPt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'LIMIARES';
	@override String get conceptText => 'A 16ª Bienal Internacional de Curitiba parte do conceito LIMIAR, entendido como o espaço entre o que ainda não é e o que já começa a ser. Num mundo marcado pela dissolução das fronteiras entre o humano e o tecnológico, o natural e o artificial, a Bienal propõe-se como um território de transição — um laboratório de escuta, risco e transformação.\n\nAqui, a arte atua como força mediadora entre mundos, abrindo passagens para novos modos de existência e percepção.\n\nNo limiar entre crise e criação, a arte revela sua potência de invenção e sua capacidade de imaginar futuros possíveis.';
	@override String get statementTitle => 'STATEMENT CURATORIAL';
	@override String get statementText => 'Em um mundo atravessado por aceleradas transformações tecnológicas, sociais e ambientais, a 16ª Bienal Internacional de Curitiba — que acontece entre março e agosto de 2026 — propõe-se como um laboratório transdisciplinar de experimentação, onde arte, ciência, tecnologia e pensamento crítico convergem para explorar os desafios da contemporaneidade.\n\nEsta edição tensiona os limites entre produção artística, públicos, pensamento crítico e ação cidadã, investigando os modos de existência híbridos e as fronteiras dissolvidas entre o biológico e o sintético, o humano e o não-humano. São essas zonas de atrito — entre o natural e o artificial, o sensível e o programável — que informam as práticas do porvir e oferecem terreno fértil para a existência estética e emergencial da arte.\n\nVivemos uma era marcada pela onipresença dos algoritmos, pela ascensão da inteligência artificial e pela supremacia do capitalismo digital. Nesse contexto, a prática artística deixa de ser exclusivamente expressão individual para tornar-se um campo expandido de colaboração entre humanos, máquinas e sistemas inteligentes. O conceito tradicional de autoria é colocado em xeque, abrindo espaço para o artista como programador, mediador ou facilitador de processos algorítmicos.\n\nComo se transforma a experiência estética em tempos de realidades aumentadas, big data e ecologias digitais? A arte, mais do que representar o mundo, torna-se uma interface viva, responsiva e crítica, que questiona os regimes de visualidade e os sistemas de poder que estruturam nosso cotidiano. As linguagens híbridas — que fundem o físico e o virtual, o orgânico e o computacional — expandem os horizontes da sensibilidade e abrem caminhos para novas formas de ativismo, memória e subjetividade.\n\nOutro eixo fundamental desta edição reside na crítica à neutralidade da tecnologia. A inteligência artificial e os sistemas algorítmicos são moldados por interesses políticos, econômicos e ideológicos. A arte, nesse contexto, emerge como um dispositivo de resistência contra o extrativismo de dados, a vigilância em massa e os mecanismos de controle e desigualdade que operam nos bastidores da era digital.\n\nA 16ª Bienal Internacional de Curitiba convoca artistas, pesquisadores, cientistas, tecnólogos e ativistas a imaginar futuros possíveis e refletir sobre os impactos da inovação tecnológica nas formas de vida, nas identidades e nas materialidades do mundo contemporâneo. Por meio de instalações imersivas, arte generativa, ambientes interativos, simulações em realidade virtual e práticas pós-humanistas, a Bienal propõe-se a traçar um mapa especulativo das práticas emergentes, colocando em diálogo o local e o global, o corpo e o código, o sensível e o sintético.\n\nO público será convidado a participar de experiências transformadoras, interagindo com obras que reconfiguram os modos de perceber, agir e imaginar. Neste encontro entre arte e tecnopolítica, a Bienal quer ser plataforma de escuta, de invenção e de risco, abrindo brechas no presente para ensaiar formas de coexistência mais justas, conscientes e sensíveis.';
	@override String get curatorsLabel => 'Curadoras';
	@override String get curatorsNames => 'Adriana Almada e Tereza de Arruda';
}

// Path: about
class _StringsAboutPt implements _StringsAboutEn {
	_StringsAboutPt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get pageTitle => 'Sobre o App';
	@override String get mainTitle => '16ª Bienal Internacional de Curitiba';
	@override String get description => 'Este aplicativo é uma experiência oficial da 16ª Bienal Internacional de Curitiba, desenvolvido com foco na visualização de obras em Realidade Aumentada (RA). Em diálogo com o tema curatorial Limiares, o app convida o visitante a cruzar fronteiras entre o mundo físico e o digital, explorando a arte de forma imersiva e interativa nos espaços da Bienal.';
	@override String get missionTitle => 'Sobre a Outvision XR';
	@override String get missionText => 'A Outvision XR é uma plataforma especializada em experiências de arte com Realidade Aumentada. Unindo tecnologia e cultura, potencializamos a conexão entre obras, artistas e públicos, tornando a arte contemporânea mais acessível, sensorial e memorável.';
	@override String get visionTitle => 'Limiares';
	@override String get visionText => 'O tema curatorial Limiares propõe uma reflexão sobre as fronteiras — físicas, culturais, simbólicas — que nos separam e nos unem. Por meio da Realidade Aumentada, o app transforma esses limiares em portais, permitindo que cada obra seja vivida além do visível.';
	@override String get connectTitle => 'Conecte-se Conosco';
	@override String get website => 'Website';
	@override String get email => 'Email';
	@override String get instagram => 'Instagram';
	@override String get share => 'Compartilhar';
	@override String get copyright => 'Outvision XR © 2025. Todos os direitos reservados.';
}

// Path: languagePage
class _StringsLanguagePagePt implements _StringsLanguagePageEn {
	_StringsLanguagePagePt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Idioma';
	@override String get portuguese => 'Português';
	@override String get english => 'Inglês';
	@override String get spanish => 'Espanhol';
}

// Path: map
class _StringsMapPt implements _StringsMapEn {
	_StringsMapPt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get loadingGps => 'Buscando sinal de GPS...';
	@override String get artworkLargo => 'Obra AR: Largo da Ordem';
	@override String get artworkMon => 'Obra AR: MON';
	@override String get artworkOpera => 'Obra AR: Ópera de Arame';
	@override String get arrivedTitle => 'Você chegou ao local da obra';
	@override String get openArButton => 'Abrir Realidade aumentada';
	@override String get locationServiceDisabled => 'Serviço de localização desativado.';
	@override String get locationPermissionDenied => 'Permissão de localização negada.';
	@override String get locationPermissionPermanentlyDenied => 'Permissão de localização negada permanentemente. Habilite nas configurações.';
	@override String get locationNotFound => 'Não foi possível obter sua localização. Tente novamente.';
	@override String get locationError => 'Erro ao iniciar localização.';
	@override String get helpTitle => 'Ajuda do Mapa';
	@override String get helpContent => 'Explore o mapa para encontrar as obras de arte. Ao se aproximar de um ponto, você poderá abrir a experiência em Realidade Aumentada. Use os botões de zoom (+/-) e o botão de navegação para centralizar o mapa em sua posição atual.';
	@override String get noNearbyArtwork => 'Nenhuma obra de arte perto da sua localização';
	@override String get noNearbyArtworkDesc => 'Não há obras de arte visíveis ao redor da sua localização. Amplie a visualização ou use o botão abaixo para ver as obras mais próximas.';
	@override String get takeToNearest => 'Leve-me para a obra mais próxima';
	@override String get navigate => 'Navegar';
	@override String get connectionError => 'Erro de conexão. Verifique sua internet.';
}

// Path: bottomNav
class _StringsBottomNavPt implements _StringsBottomNavEn {
	_StringsBottomNavPt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get explore => 'Explorar';
	@override String get gallery => 'Obras';
	@override String get captured => 'Capturados';
	@override String get settings => 'Configurações';
}

// Path: welcome
class _StringsWelcomePt implements _StringsWelcomeEn {
	_StringsWelcomePt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get headline => 'Arte e design\nno seu melhor';
	@override String get startButton => 'Começar';
}

// Path: errorScreen
class _StringsErrorScreenPt implements _StringsErrorScreenEn {
	_StringsErrorScreenPt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get message => 'Algo deu errado.\nReinicie o aplicativo.';
}

// Path: ar
class _StringsArPt implements _StringsArEn {
	_StringsArPt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get scanInstruction => 'Escaneie o chão movendo o celular';
	@override String get tapToPlace => 'Toque na tela para posicionar a obra';
	@override String get helpTitle => 'Ajuda';
	@override String get helpContent => 'Mova o aparelho lentamente e aponte para o ambiente para melhorar a localização.';
	@override String get ok => 'OK';
	@override String get permissionTitle => 'Permissões Necessárias';
	@override String get permissionContent => 'Para visualizar a obra, precisamos de acesso à sua câmera e localização.';
	@override String get allowAccess => 'Permitir Acesso';
	@override String get notNow => 'Agora não';
	@override String get onboardingContent => 'Mova o aparelho lentamente para ajudar a Obra a se localizar.';
	@override String get onboardingButton => 'Entendi, vamos começar';
	@override String get errorTitle => 'Ocorreu um Erro';
	@override String get backButton => 'Voltar';
	@override String get tryAgain => 'Tentar novamente';
	@override String get genericError => 'Erro na Realidade Aumentada.';
	@override String get localizationTimeoutError => 'Não foi possível localizar a obra. Tente reiniciar a experiência AR.';
	@override String get eventsError => 'Falha ao receber eventos de Realidade Aumentada.';
	@override String get unsupported => 'Realidade Aumentada não suportada nesta plataforma';
	@override String get openAr => 'Abrir AR';
	@override String get modelUnavailable => 'Modelo 3D não disponível\npara esta obra.';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'gallery.title': return 'Artworks';
			case 'gallery.tabArtwork': return 'Artworks';
			case 'gallery.tabArtists': return 'Artists';
			case 'gallery.search': return 'Search...';
			case 'gallery.artworkTitle': return 'The Garden of Earthly Delights';
			case 'gallery.artworkArtist': return 'Hieronymus Bosch';
			case 'gallery.artistSubtitle': return 'Curitiba Biennial 2025';
			case 'gallery.viewExhibition': return 'View artwork';
			case 'gallery.artistDetails': return 'Artist Details';
			case 'gallery.works': return 'Works';
			case 'gallery.noArtworkFound': return 'No artwork found';
			case 'gallery.noArtistFound': return 'No artist found';
			case 'gallery.unknownArtist': return 'Unknown artist';
			case 'gallery.highlights': return 'Highlights';
			case 'gallery.viewAll': return 'View all';
			case 'gallery.bioMore': return ' more';
			case 'gallery.showOnMap': return 'Show on map';
			case 'gallery.makeAvailableOffline': return 'Make available offline';
			case 'gallery.artist': return 'Artist';
			case 'settings.title': return 'Settings';
			case 'settings.getHelp': return 'How to use the App';
			case 'settings.appSettings': return 'App Settings';
			case 'settings.language': return 'Language';
			case 'settings.about': return '16th International Biennial of Curitiba';
			case 'settings.limiares': return 'Limiares';
			case 'settings.website': return 'Website';
			case 'settings.instagram': return 'Instagram';
			case 'settings.aboutApp': return 'About the App';
			case 'settings.privacyPolicy': return 'Privacy Policy';
			case 'settings.termsOfUse': return 'Terms of Use';
			case 'limiares.title': return 'LIMIARES';
			case 'limiares.conceptText': return 'The 16th International Biennial of Curitiba draws on the concept of LIMIAR (THRESHOLD), understood as the space between what is not yet and what is already beginning to be. In a world marked by the dissolution of boundaries between the human and the technological, the natural and the artificial, the Biennial presents itself as a territory of transition — a laboratory of listening, risk, and transformation.\n\nHere, art acts as a mediating force between worlds, opening passages to new modes of existence and perception.\n\nOn the threshold between crisis and creation, art reveals its power of invention and its capacity to imagine possible futures.';
			case 'limiares.statementTitle': return 'CURATORIAL STATEMENT';
			case 'limiares.statementText': return 'In a world traversed by accelerating technological, social, and environmental transformations, the 16th International Biennial of Curitiba — taking place between March and August 2026 — presents itself as a transdisciplinary laboratory of experimentation, where art, science, technology, and critical thinking converge to explore the challenges of contemporaneity.\n\nThis edition tests the limits between artistic production, audiences, critical thought, and civic action, investigating hybrid modes of existence and the dissolved boundaries between the biological and the synthetic, the human and the non-human. These zones of friction — between the natural and the artificial, the sensory and the programmable — inform the practices of the future and offer fertile ground for the aesthetic and emergent existence of art.\n\nWe live in an era marked by the omnipresence of algorithms, the rise of artificial intelligence, and the supremacy of digital capitalism. In this context, artistic practice is no longer exclusively individual expression but becomes an expanded field of collaboration between humans, machines, and intelligent systems. The traditional concept of authorship is called into question, making space for the artist as programmer, mediator, or facilitator of algorithmic processes.\n\nHow does aesthetic experience transform in times of augmented realities, big data, and digital ecologies? Art, more than representing the world, becomes a living, responsive, and critical interface that questions the regimes of visuality and the systems of power that structure our daily lives. Hybrid languages — fusing the physical and the virtual, the organic and the computational — expand the horizons of sensibility and open pathways to new forms of activism, memory, and subjectivity.\n\nAnother fundamental axis of this edition lies in the critique of the neutrality of technology. Artificial intelligence and algorithmic systems are shaped by political, economic, and ideological interests. Art, in this context, emerges as a device of resistance against data extractivism, mass surveillance, and the mechanisms of control and inequality operating behind the scenes of the digital age.\n\nThe 16th International Biennial of Curitiba summons artists, researchers, scientists, technologists, and activists to imagine possible futures and reflect on the impacts of technological innovation on forms of life, identities, and the materialities of the contemporary world. Through immersive installations, generative art, interactive environments, virtual reality simulations, and post-humanist practices, the Biennial proposes to map the speculative terrain of emerging practices, placing the local and the global, the body and the code, the sensory and the synthetic in dialogue.\n\nThe public will be invited to participate in transformative experiences, interacting with works that reconfigure the ways of perceiving, acting, and imagining. In this encounter between art and technopolitics, the Biennial seeks to be a platform of listening, invention, and risk, opening breaches in the present to rehearse more just, conscious, and sensitive forms of coexistence.';
			case 'limiares.curatorsLabel': return 'Curators';
			case 'limiares.curatorsNames': return 'Adriana Almada and Tereza de Arruda';
			case 'about.pageTitle': return 'About the App';
			case 'about.mainTitle': return '16th International Biennial of Curitiba';
			case 'about.description': return 'This app is an official experience of the 16th International Biennial of Curitiba, developed with a focus on visualizing artworks through Augmented Reality (AR). In dialogue with the curatorial theme Limiares (Thresholds), the app invites visitors to cross boundaries between the physical and digital worlds, exploring art in an immersive and interactive way across the Biennial\'s venues.';
			case 'about.missionTitle': return 'About Outvision XR';
			case 'about.missionText': return 'Outvision XR is a platform specialized in art experiences with Augmented Reality. Combining technology and culture, we enhance the connection between artworks, artists, and audiences, making contemporary art more accessible, sensory, and memorable.';
			case 'about.visionTitle': return 'Limiares (Thresholds)';
			case 'about.visionText': return 'The curatorial theme Limiares (Thresholds) invites reflection on the boundaries — physical, cultural, symbolic — that separate and unite us. Through Augmented Reality, the app transforms these thresholds into portals, allowing each artwork to be experienced beyond the visible.';
			case 'about.connectTitle': return 'Connect With Us';
			case 'about.website': return 'Website';
			case 'about.email': return 'Email';
			case 'about.instagram': return 'Instagram';
			case 'about.share': return 'Share';
			case 'about.copyright': return 'Outvision XR © 2025. All rights reserved.';
			case 'languagePage.title': return 'Language';
			case 'languagePage.portuguese': return 'Portuguese';
			case 'languagePage.english': return 'English';
			case 'languagePage.spanish': return 'Spanish';
			case 'map.loadingGps': return 'Searching for GPS signal...';
			case 'map.artworkLargo': return 'AR Artwork: Largo da Ordem';
			case 'map.artworkMon': return 'AR Artwork: MON';
			case 'map.artworkOpera': return 'AR Artwork: Ópera de Arame';
			case 'map.arrivedTitle': return 'You have arrived at the artwork location';
			case 'map.openArButton': return 'Open Augmented Reality';
			case 'map.locationServiceDisabled': return 'Location service disabled.';
			case 'map.locationPermissionDenied': return 'Location permission denied.';
			case 'map.locationPermissionPermanentlyDenied': return 'Location permission permanently denied. Please enable it in settings.';
			case 'map.locationNotFound': return 'Could not get your location. Please try again.';
			case 'map.locationError': return 'Error initializing location.';
			case 'map.helpTitle': return 'Map Help';
			case 'map.helpContent': return 'Explore the map to find the artworks. When you get close to a point, you can open the Augmented Reality experience. Use the zoom buttons (+/-) and the navigation button to center the map on your current position.';
			case 'map.noNearbyArtwork': return 'No artwork near your location';
			case 'map.noNearbyArtworkDesc': return 'There are no artworks visible around your location. Zoom out or use the button below to navigate to the nearest artwork.';
			case 'map.takeToNearest': return 'Take me to the nearest artwork';
			case 'map.navigate': return 'Navigate';
			case 'map.connectionError': return 'Connection error. Check your internet.';
			case 'bottomNav.explore': return 'Explore';
			case 'bottomNav.gallery': return 'Artworks';
			case 'bottomNav.captured': return 'Captured';
			case 'bottomNav.settings': return 'Settings';
			case 'welcome.headline': return 'Art and design\nat its best';
			case 'welcome.startButton': return 'Start';
			case 'errorScreen.message': return 'Something went wrong.\nRestart the application.';
			case 'ar.scanInstruction': return 'Scan the floor by moving your phone';
			case 'ar.tapToPlace': return 'Tap the screen to place the artwork';
			case 'ar.helpTitle': return 'Help';
			case 'ar.helpContent': return 'Move the device slowly and point it at your surroundings to improve localization.';
			case 'ar.ok': return 'OK';
			case 'ar.permissionTitle': return 'Permissions Required';
			case 'ar.permissionContent': return 'To view the artwork, we need access to your camera and location.';
			case 'ar.allowAccess': return 'Allow Access';
			case 'ar.notNow': return 'Not Now';
			case 'ar.onboardingContent': return 'Move the device slowly to help the Artwork localize itself.';
			case 'ar.onboardingButton': return 'Got it, let\'s start';
			case 'ar.errorTitle': return 'An Error Occurred';
			case 'ar.backButton': return 'Back';
			case 'ar.tryAgain': return 'Try again';
			case 'ar.genericError': return 'Augmented Reality error.';
			case 'ar.localizationTimeoutError': return 'Could not localize the artwork. Try restarting the AR experience.';
			case 'ar.eventsError': return 'Failed to receive Augmented Reality events.';
			case 'ar.unsupported': return 'Augmented Reality not supported on this platform';
			case 'ar.openAr': return 'Open AR';
			case 'ar.modelUnavailable': return '3D model not available\nfor this artwork.';
			default: return null;
		}
	}
}

extension on _StringsEs {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'gallery.title': return 'Obras';
			case 'gallery.tabArtwork': return 'Obras';
			case 'gallery.tabArtists': return 'Artistas';
			case 'gallery.search': return 'Buscar...';
			case 'gallery.artworkTitle': return 'El Jardín de las Delicias';
			case 'gallery.artworkArtist': return 'Hieronymus Bosch';
			case 'gallery.artistSubtitle': return 'Bienal de Curitiba 2025';
			case 'gallery.viewExhibition': return 'Ver obra';
			case 'gallery.artistDetails': return 'Detalles del Artista';
			case 'gallery.works': return 'Obras';
			case 'gallery.noArtworkFound': return 'Ninguna obra encontrada';
			case 'gallery.noArtistFound': return 'Ningún artista encontrado';
			case 'gallery.unknownArtist': return 'Artista desconocido';
			case 'gallery.highlights': return 'Destacados';
			case 'gallery.viewAll': return 'Ver todo';
			case 'gallery.bioMore': return ' más';
			case 'gallery.showOnMap': return 'Ver en el mapa';
			case 'gallery.makeAvailableOffline': return 'Hacer disponible sin conexión';
			case 'gallery.artist': return 'Artista';
			case 'settings.title': return 'Configuración';
			case 'settings.getHelp': return 'Cómo usar la App';
			case 'settings.appSettings': return 'Configuración de la App';
			case 'settings.language': return 'Idioma';
			case 'settings.about': return '16ª Bienal Internacional de Curitiba';
			case 'settings.limiares': return 'Limiares';
			case 'settings.website': return 'Sitio Web';
			case 'settings.instagram': return 'Instagram';
			case 'settings.aboutApp': return 'Sobre la App';
			case 'settings.privacyPolicy': return 'Política de Privacidad';
			case 'settings.termsOfUse': return 'Términos de Uso';
			case 'limiares.title': return 'LIMIARES';
			case 'limiares.conceptText': return 'La 16ª Bienal Internacional de Curitiba parte del concepto LIMIAR (UMBRAL), entendido como el espacio entre lo que aún no es y lo que ya comienza a ser. En un mundo marcado por la disolución de las fronteras entre lo humano y lo tecnológico, lo natural y lo artificial, la Bienal se propone como un territorio de transición — un laboratorio de escucha, riesgo y transformación.\n\nAquí, el arte actúa como fuerza mediadora entre mundos, abriendo pasajes hacia nuevos modos de existencia y percepción.\n\nEn el umbral entre crisis y creación, el arte revela su potencia de invención y su capacidad de imaginar futuros posibles.';
			case 'limiares.statementTitle': return 'STATEMENT CURATORIAL';
			case 'limiares.statementText': return 'En un mundo atravesado por aceleradas transformaciones tecnológicas, sociales y ambientales, la 16ª Bienal Internacional de Curitiba — que tiene lugar entre marzo y agosto de 2026 — se propone como un laboratorio transdisciplinar de experimentación, donde arte, ciencia, tecnología y pensamiento crítico convergen para explorar los desafíos de la contemporaneidad.\n\nEsta edición tensiona los límites entre producción artística, públicos, pensamiento crítico y acción ciudadana, investigando los modos de existencia híbridos y las fronteras disueltas entre lo biológico y lo sintético, lo humano y lo no-humano. Son estas zonas de fricción — entre lo natural y lo artificial, lo sensible y lo programable — las que informan las prácticas del porvenir y ofrecen terreno fértil para la existencia estética y emergencial del arte.\n\nVivemos una era marcada por la omnipresencia de los algoritmos, el auge de la inteligencia artificial y la supremacía del capitalismo digital. En este contexto, la práctica artística deja de ser exclusivamente expresión individual para convertirse en un campo expandido de colaboración entre humanos, máquinas y sistemas inteligentes. El concepto tradicional de autoría es puesto en cuestión, abriendo espacio para el artista como programador, mediador o facilitador de procesos algorítmicos.\n\n¿Cómo se transforma la experiencia estética en tiempos de realidades aumentadas, big data y ecologías digitales? El arte, más que representar el mundo, se convierte en una interfaz viva, responsiva y crítica, que cuestiona los regímenes de visualidad y los sistemas de poder que estructuran nuestro cotidiano. Los lenguajes híbridos — que fusionan lo físico y lo virtual, lo orgánico y lo computacional — amplían los horizontes de la sensibilidad y abren caminos hacia nuevas formas de activismo, memoria y subjetividad.\n\nOtro eje fundamental de esta edición reside en la crítica a la neutralidad de la tecnología. La inteligencia artificial y los sistemas algorítmicos son moldeados por intereses políticos, económicos e ideológicos. El arte, en este contexto, emerge como un dispositivo de resistencia contra el extractivismo de datos, la vigilancia masiva y los mecanismos de control y desigualdad que operan entre bastidores de la era digital.\n\nLa 16ª Bienal Internacional de Curitiba convoca a artistas, investigadores, científicos, tecnólogos y activistas a imaginar futuros posibles y reflexionar sobre los impactos de la innovación tecnológica en las formas de vida, las identidades y las materialidades del mundo contemporáneo. A través de instalaciones inmersivas, arte generativo, ambientes interactivos, simulaciones en realidad virtual y prácticas posthumanistas, la Bienal se propone trazar un mapa especulativo de las prácticas emergentes, poniendo en diálogo lo local y lo global, el cuerpo y el código, lo sensible y lo sintético.\n\nEl público será invitado a participar de experiencias transformadoras, interactuando con obras que reconfiguran los modos de percibir, actuar e imaginar. En este encuentro entre arte y tecnopolítica, la Bienal quiere ser plataforma de escucha, de invención y de riesgo, abriendo brechas en el presente para ensayar formas de coexistencia más justas, conscientes y sensibles.';
			case 'limiares.curatorsLabel': return 'Curadoras';
			case 'limiares.curatorsNames': return 'Adriana Almada y Tereza de Arruda';
			case 'about.pageTitle': return 'Sobre la App';
			case 'about.mainTitle': return '16ª Bienal Internacional de Curitiba';
			case 'about.description': return 'Esta aplicación es una experiencia oficial de la 16ª Bienal Internacional de Curitiba, desarrollada con foco en la visualización de obras en Realidad Aumentada (RA). En diálogo con el tema curatorial Limiares (Umbrales), la app invita al visitante a cruzar fronteras entre el mundo físico y el digital, explorando el arte de forma inmersiva e interactiva en los espacios de la Bienal.';
			case 'about.missionTitle': return 'Sobre Outvision XR';
			case 'about.missionText': return 'Outvision XR es una plataforma especializada en experiencias de arte con Realidad Aumentada. Uniendo tecnología y cultura, potenciamos la conexión entre obras, artistas y públicos, haciendo que el arte contemporáneo sea más accesible, sensorial y memorable.';
			case 'about.visionTitle': return 'Limiares (Umbrales)';
			case 'about.visionText': return 'El tema curatorial Limiares (Umbrales) propone una reflexión sobre las fronteras — físicas, culturales, simbólicas — que nos separan y nos unen. A través de la Realidad Aumentada, la app transforma esos umbrales en portales, permitiendo que cada obra sea vivida más allá de lo visible.';
			case 'about.connectTitle': return 'Conéctate con Nosotros';
			case 'about.website': return 'Sitio Web';
			case 'about.email': return 'Correo Electrónico';
			case 'about.instagram': return 'Instagram';
			case 'about.share': return 'Compartir';
			case 'about.copyright': return 'Outvision XR © 2025. Todos los derechos reservados.';
			case 'languagePage.title': return 'Idioma';
			case 'languagePage.portuguese': return 'Portugués';
			case 'languagePage.english': return 'Inglés';
			case 'languagePage.spanish': return 'Español';
			case 'map.loadingGps': return 'Buscando señal de GPS...';
			case 'map.artworkLargo': return 'Obra AR: Largo da Ordem';
			case 'map.artworkMon': return 'Obra AR: MON';
			case 'map.artworkOpera': return 'Obra AR: Ópera de Arame';
			case 'map.arrivedTitle': return 'Has llegado a la ubicación de la obra';
			case 'map.openArButton': return 'Abrir Realidad Aumentada';
			case 'map.locationServiceDisabled': return 'Servicio de ubicación desactivado.';
			case 'map.locationPermissionDenied': return 'Permiso de ubicación denegado.';
			case 'map.locationPermissionPermanentlyDenied': return 'Permiso de ubicación denegado permanentemente. Habilítelo en la configuración.';
			case 'map.locationNotFound': return 'No se pudo obtener tu ubicación. Por favor, inténtalo de nuevo.';
			case 'map.locationError': return 'Error al iniciar la ubicación.';
			case 'map.helpTitle': return 'Ayuda del Mapa';
			case 'map.helpContent': return 'Explora el mapa para encontrar las obras de arte. Cuando te acerques a un punto, podrás abrir la experiencia de Realidad Aumentada. Utiliza los botones de zoom (+/-) y el botón de navegación para centrar el mapa en tu posición actual.';
			case 'map.noNearbyArtwork': return 'Ninguna obra de arte cerca de tu ubicación';
			case 'map.noNearbyArtworkDesc': return 'No hay obras de arte visibles alrededor de tu ubicación. Aleja el zoom o usa el botón de abajo para navegar hacia la obra más cercana.';
			case 'map.takeToNearest': return 'Llévame a la obra más cercana';
			case 'map.navigate': return 'Navegar';
			case 'map.connectionError': return 'Error de conexión. Verifica tu internet.';
			case 'bottomNav.explore': return 'Explorar';
			case 'bottomNav.gallery': return 'Obras';
			case 'bottomNav.captured': return 'Capturados';
			case 'bottomNav.settings': return 'Configuración';
			case 'welcome.headline': return 'Arte y diseño\nen su máximo esplendor';
			case 'welcome.startButton': return 'Comenzar';
			case 'errorScreen.message': return 'Algo salió mal.\nReinicia la aplicación.';
			case 'ar.scanInstruction': return 'Escanea el suelo moviendo el móvil';
			case 'ar.tapToPlace': return 'Toca la pantalla para posicionar la obra';
			case 'ar.helpTitle': return 'Ayuda';
			case 'ar.helpContent': return 'Mueve el dispositivo lentamente y apúntalo a tu entorno para mejorar la localización.';
			case 'ar.ok': return 'OK';
			case 'ar.permissionTitle': return 'Permisos Necesarios';
			case 'ar.permissionContent': return 'Para visualizar la obra, necesitamos acceso a tu cámara y ubicación.';
			case 'ar.allowAccess': return 'Permitir Acceso';
			case 'ar.notNow': return 'Ahora no';
			case 'ar.onboardingContent': return 'Mueve el dispositivo lentamente para ayudar a la Obra a localizarse.';
			case 'ar.onboardingButton': return 'Entendido, empecemos';
			case 'ar.errorTitle': return 'Ocurrió un Error';
			case 'ar.backButton': return 'Volver';
			case 'ar.tryAgain': return 'Intentar de nuevo';
			case 'ar.genericError': return 'Error en la Realidad Aumentada.';
			case 'ar.localizationTimeoutError': return 'No se pudo localizar la obra. Intenta reiniciar la experiencia de RA.';
			case 'ar.eventsError': return 'Fallo al recibir eventos de Realidad Aumentada.';
			case 'ar.unsupported': return 'Realidad Aumentada no compatible en esta plataforma';
			case 'ar.openAr': return 'Abrir RA';
			case 'ar.modelUnavailable': return 'Modelo 3D no disponible\npara esta obra.';
			default: return null;
		}
	}
}

extension on _StringsPt {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'gallery.title': return 'Obras';
			case 'gallery.tabArtwork': return 'Obras';
			case 'gallery.tabArtists': return 'Artistas';
			case 'gallery.search': return 'Buscar...';
			case 'gallery.artworkTitle': return 'O Jardim das Delícias Terrenas';
			case 'gallery.artworkArtist': return 'Hieronymus Bosch';
			case 'gallery.artistSubtitle': return 'Bienal de Curitiba 2025';
			case 'gallery.viewExhibition': return 'Ver obra';
			case 'gallery.artistDetails': return 'Detalhes do Artista';
			case 'gallery.works': return 'Obras';
			case 'gallery.noArtworkFound': return 'Nenhuma obra encontrada';
			case 'gallery.noArtistFound': return 'Nenhum artista encontrado';
			case 'gallery.unknownArtist': return 'Artista desconhecido';
			case 'gallery.highlights': return 'Destaques';
			case 'gallery.viewAll': return 'Ver tudo';
			case 'gallery.bioMore': return ' mais';
			case 'gallery.showOnMap': return 'Ver no mapa';
			case 'gallery.makeAvailableOffline': return 'Disponibilizar offline';
			case 'gallery.artist': return 'Artista';
			case 'settings.title': return 'Configurações';
			case 'settings.getHelp': return 'Como usar o App';
			case 'settings.appSettings': return 'Configurações do App';
			case 'settings.language': return 'Idioma';
			case 'settings.about': return '16ª Bienal Internacional de Curitiba';
			case 'settings.limiares': return 'Limiares';
			case 'settings.website': return 'Website';
			case 'settings.instagram': return 'Instagram';
			case 'settings.aboutApp': return 'Sobre o App';
			case 'settings.privacyPolicy': return 'Política de Privacidade';
			case 'settings.termsOfUse': return 'Termos de Uso';
			case 'limiares.title': return 'LIMIARES';
			case 'limiares.conceptText': return 'A 16ª Bienal Internacional de Curitiba parte do conceito LIMIAR, entendido como o espaço entre o que ainda não é e o que já começa a ser. Num mundo marcado pela dissolução das fronteiras entre o humano e o tecnológico, o natural e o artificial, a Bienal propõe-se como um território de transição — um laboratório de escuta, risco e transformação.\n\nAqui, a arte atua como força mediadora entre mundos, abrindo passagens para novos modos de existência e percepção.\n\nNo limiar entre crise e criação, a arte revela sua potência de invenção e sua capacidade de imaginar futuros possíveis.';
			case 'limiares.statementTitle': return 'STATEMENT CURATORIAL';
			case 'limiares.statementText': return 'Em um mundo atravessado por aceleradas transformações tecnológicas, sociais e ambientais, a 16ª Bienal Internacional de Curitiba — que acontece entre março e agosto de 2026 — propõe-se como um laboratório transdisciplinar de experimentação, onde arte, ciência, tecnologia e pensamento crítico convergem para explorar os desafios da contemporaneidade.\n\nEsta edição tensiona os limites entre produção artística, públicos, pensamento crítico e ação cidadã, investigando os modos de existência híbridos e as fronteiras dissolvidas entre o biológico e o sintético, o humano e o não-humano. São essas zonas de atrito — entre o natural e o artificial, o sensível e o programável — que informam as práticas do porvir e oferecem terreno fértil para a existência estética e emergencial da arte.\n\nVivemos uma era marcada pela onipresença dos algoritmos, pela ascensão da inteligência artificial e pela supremacia do capitalismo digital. Nesse contexto, a prática artística deixa de ser exclusivamente expressão individual para tornar-se um campo expandido de colaboração entre humanos, máquinas e sistemas inteligentes. O conceito tradicional de autoria é colocado em xeque, abrindo espaço para o artista como programador, mediador ou facilitador de processos algorítmicos.\n\nComo se transforma a experiência estética em tempos de realidades aumentadas, big data e ecologias digitais? A arte, mais do que representar o mundo, torna-se uma interface viva, responsiva e crítica, que questiona os regimes de visualidade e os sistemas de poder que estruturam nosso cotidiano. As linguagens híbridas — que fundem o físico e o virtual, o orgânico e o computacional — expandem os horizontes da sensibilidade e abrem caminhos para novas formas de ativismo, memória e subjetividade.\n\nOutro eixo fundamental desta edição reside na crítica à neutralidade da tecnologia. A inteligência artificial e os sistemas algorítmicos são moldados por interesses políticos, econômicos e ideológicos. A arte, nesse contexto, emerge como um dispositivo de resistência contra o extrativismo de dados, a vigilância em massa e os mecanismos de controle e desigualdade que operam nos bastidores da era digital.\n\nA 16ª Bienal Internacional de Curitiba convoca artistas, pesquisadores, cientistas, tecnólogos e ativistas a imaginar futuros possíveis e refletir sobre os impactos da inovação tecnológica nas formas de vida, nas identidades e nas materialidades do mundo contemporâneo. Por meio de instalações imersivas, arte generativa, ambientes interativos, simulações em realidade virtual e práticas pós-humanistas, a Bienal propõe-se a traçar um mapa especulativo das práticas emergentes, colocando em diálogo o local e o global, o corpo e o código, o sensível e o sintético.\n\nO público será convidado a participar de experiências transformadoras, interagindo com obras que reconfiguram os modos de perceber, agir e imaginar. Neste encontro entre arte e tecnopolítica, a Bienal quer ser plataforma de escuta, de invenção e de risco, abrindo brechas no presente para ensaiar formas de coexistência mais justas, conscientes e sensíveis.';
			case 'limiares.curatorsLabel': return 'Curadoras';
			case 'limiares.curatorsNames': return 'Adriana Almada e Tereza de Arruda';
			case 'about.pageTitle': return 'Sobre o App';
			case 'about.mainTitle': return '16ª Bienal Internacional de Curitiba';
			case 'about.description': return 'Este aplicativo é uma experiência oficial da 16ª Bienal Internacional de Curitiba, desenvolvido com foco na visualização de obras em Realidade Aumentada (RA). Em diálogo com o tema curatorial Limiares, o app convida o visitante a cruzar fronteiras entre o mundo físico e o digital, explorando a arte de forma imersiva e interativa nos espaços da Bienal.';
			case 'about.missionTitle': return 'Sobre a Outvision XR';
			case 'about.missionText': return 'A Outvision XR é uma plataforma especializada em experiências de arte com Realidade Aumentada. Unindo tecnologia e cultura, potencializamos a conexão entre obras, artistas e públicos, tornando a arte contemporânea mais acessível, sensorial e memorável.';
			case 'about.visionTitle': return 'Limiares';
			case 'about.visionText': return 'O tema curatorial Limiares propõe uma reflexão sobre as fronteiras — físicas, culturais, simbólicas — que nos separam e nos unem. Por meio da Realidade Aumentada, o app transforma esses limiares em portais, permitindo que cada obra seja vivida além do visível.';
			case 'about.connectTitle': return 'Conecte-se Conosco';
			case 'about.website': return 'Website';
			case 'about.email': return 'Email';
			case 'about.instagram': return 'Instagram';
			case 'about.share': return 'Compartilhar';
			case 'about.copyright': return 'Outvision XR © 2025. Todos os direitos reservados.';
			case 'languagePage.title': return 'Idioma';
			case 'languagePage.portuguese': return 'Português';
			case 'languagePage.english': return 'Inglês';
			case 'languagePage.spanish': return 'Espanhol';
			case 'map.loadingGps': return 'Buscando sinal de GPS...';
			case 'map.artworkLargo': return 'Obra AR: Largo da Ordem';
			case 'map.artworkMon': return 'Obra AR: MON';
			case 'map.artworkOpera': return 'Obra AR: Ópera de Arame';
			case 'map.arrivedTitle': return 'Você chegou ao local da obra';
			case 'map.openArButton': return 'Abrir Realidade aumentada';
			case 'map.locationServiceDisabled': return 'Serviço de localização desativado.';
			case 'map.locationPermissionDenied': return 'Permissão de localização negada.';
			case 'map.locationPermissionPermanentlyDenied': return 'Permissão de localização negada permanentemente. Habilite nas configurações.';
			case 'map.locationNotFound': return 'Não foi possível obter sua localização. Tente novamente.';
			case 'map.locationError': return 'Erro ao iniciar localização.';
			case 'map.helpTitle': return 'Ajuda do Mapa';
			case 'map.helpContent': return 'Explore o mapa para encontrar as obras de arte. Ao se aproximar de um ponto, você poderá abrir a experiência em Realidade Aumentada. Use os botões de zoom (+/-) e o botão de navegação para centralizar o mapa em sua posição atual.';
			case 'map.noNearbyArtwork': return 'Nenhuma obra de arte perto da sua localização';
			case 'map.noNearbyArtworkDesc': return 'Não há obras de arte visíveis ao redor da sua localização. Amplie a visualização ou use o botão abaixo para ver as obras mais próximas.';
			case 'map.takeToNearest': return 'Leve-me para a obra mais próxima';
			case 'map.navigate': return 'Navegar';
			case 'map.connectionError': return 'Erro de conexão. Verifique sua internet.';
			case 'bottomNav.explore': return 'Explorar';
			case 'bottomNav.gallery': return 'Obras';
			case 'bottomNav.captured': return 'Capturados';
			case 'bottomNav.settings': return 'Configurações';
			case 'welcome.headline': return 'Arte e design\nno seu melhor';
			case 'welcome.startButton': return 'Começar';
			case 'errorScreen.message': return 'Algo deu errado.\nReinicie o aplicativo.';
			case 'ar.scanInstruction': return 'Escaneie o chão movendo o celular';
			case 'ar.tapToPlace': return 'Toque na tela para posicionar a obra';
			case 'ar.helpTitle': return 'Ajuda';
			case 'ar.helpContent': return 'Mova o aparelho lentamente e aponte para o ambiente para melhorar a localização.';
			case 'ar.ok': return 'OK';
			case 'ar.permissionTitle': return 'Permissões Necessárias';
			case 'ar.permissionContent': return 'Para visualizar a obra, precisamos de acesso à sua câmera e localização.';
			case 'ar.allowAccess': return 'Permitir Acesso';
			case 'ar.notNow': return 'Agora não';
			case 'ar.onboardingContent': return 'Mova o aparelho lentamente para ajudar a Obra a se localizar.';
			case 'ar.onboardingButton': return 'Entendi, vamos começar';
			case 'ar.errorTitle': return 'Ocorreu um Erro';
			case 'ar.backButton': return 'Voltar';
			case 'ar.tryAgain': return 'Tentar novamente';
			case 'ar.genericError': return 'Erro na Realidade Aumentada.';
			case 'ar.localizationTimeoutError': return 'Não foi possível localizar a obra. Tente reiniciar a experiência AR.';
			case 'ar.eventsError': return 'Falha ao receber eventos de Realidade Aumentada.';
			case 'ar.unsupported': return 'Realidade Aumentada não suportada nesta plataforma';
			case 'ar.openAr': return 'Abrir AR';
			case 'ar.modelUnavailable': return 'Modelo 3D não disponível\npara esta obra.';
			default: return null;
		}
	}
}
