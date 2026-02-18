/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 3
/// Strings: 132 (44 per locale)
///
/// Built on 2026-02-18 at 08:49 UTC

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
	late final _StringsAboutEn about = _StringsAboutEn._(_root);
	late final _StringsLanguagePageEn languagePage = _StringsLanguagePageEn._(_root);
	late final _StringsMapEn map = _StringsMapEn._(_root);
	late final _StringsBottomNavEn bottomNav = _StringsBottomNavEn._(_root);
	late final _StringsArEn ar = _StringsArEn._(_root);
}

// Path: gallery
class _StringsGalleryEn {
	_StringsGalleryEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Exhibitions';
	String get tabArtwork => 'Artwork';
	String get tabArtists => 'Artists';
	String get artworkTitle => 'The Garden of Earthly Delights';
	String get artworkArtist => 'Hieronymus Bosch';
	String get artistSubtitle => 'Curitiba Biennial 2025';
	String get viewExhibition => 'View exhibition';
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
	String get about => 'About Out Vision';
	String get imprint => 'Imprint';
	String get privacyPolicy => 'Privacy Policy';
	String get termsOfUse => 'Terms of Use';
}

// Path: about
class _StringsAboutEn {
	_StringsAboutEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get pageTitle => 'About Outvision';
	String get mainTitle => 'Outvision XR: Art and Augmented Reality';
	String get description => 'Outvision XR is an innovative platform that redefines the art experience, combining the physical world with the immersion of Augmented Reality (AR). Developed for art enthusiasts and exhibition visitors like the Curitiba Biennial, our app transforms the way you interact with artworks and artists.';
	String get missionTitle => 'Our Mission';
	String get missionText => 'To connect people to art in unprecedented ways, using technology to enrich the understanding and engagement with contemporary cultural expressions. We believe that AR can break down barriers and make art more accessible and interactive for everyone.';
	String get visionTitle => 'Our Vision';
	String get visionText => 'To be the leading platform for Augmented Reality art curation, recognized for its innovation, accessibility, and the ability to create memorable experiences that transcend the traditional limits of galleries and museums.';
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
	String get portuguese => 'Português';
	String get english => 'English';
	String get spanish => 'Español';
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
}

// Path: bottomNav
class _StringsBottomNavEn {
	_StringsBottomNavEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get explore => 'Explore';
	String get gallery => 'Exhibitions';
	String get captured => 'Captured';
	String get settings => 'Settings';
}

// Path: ar
class _StringsArEn {
	_StringsArEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get scanInstruction => 'Scan the floor by moving your phone';
	String get tapToPlace => 'Tap on screen to place artwork';
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
	@override late final _StringsAboutEs about = _StringsAboutEs._(_root);
	@override late final _StringsLanguagePageEs languagePage = _StringsLanguagePageEs._(_root);
	@override late final _StringsMapEs map = _StringsMapEs._(_root);
	@override late final _StringsBottomNavEs bottomNav = _StringsBottomNavEs._(_root);
	@override late final _StringsArEs ar = _StringsArEs._(_root);
}

// Path: gallery
class _StringsGalleryEs implements _StringsGalleryEn {
	_StringsGalleryEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Exposiciones';
	@override String get tabArtwork => 'Obras';
	@override String get tabArtists => 'Artistas';
	@override String get artworkTitle => 'El Jardín de las Delicias Terrenales';
	@override String get artworkArtist => 'El Bosco';
	@override String get artistSubtitle => 'Bienal de Curitiba 2025';
	@override String get viewExhibition => 'Ver exposición';
}

// Path: settings
class _StringsSettingsEs implements _StringsSettingsEn {
	_StringsSettingsEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ajustes';
	@override String get getHelp => 'Como usar el App';
	@override String get appSettings => 'Configuración de la Aplicación';
	@override String get language => 'Idioma';
	@override String get about => 'Acerca de Out Vision';
	@override String get imprint => 'Impresión';
	@override String get privacyPolicy => 'Política de Privacidad';
	@override String get termsOfUse => 'Términos de Uso';
}

// Path: about
class _StringsAboutEs implements _StringsAboutEn {
	_StringsAboutEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get pageTitle => 'Acerca de Outvision';
	@override String get mainTitle => 'Outvision XR: Arte y Realidad Aumentada';
	@override String get description => 'Outvision XR es una plataforma innovadora que redefine la experiencia del arte, combinando el mundo físico con la inmersión de la Realidad Aumentada (RA). Desarrollada para entusiastas del arte y visitantes de exposiciones como la Bienal de Curitiba, nuestra aplicación transforma la forma en que interactúas con obras de arte y artistas.';
	@override String get missionTitle => 'Nuestra Misión';
	@override String get missionText => 'Conectar a las personas con el arte de maneras sin precedentes, utilizando la tecnología para enriquecer la comprensión y el compromiso con las expresiones culturales contemporáneas. Creemos que la RA puede derribar barreras y hacer el arte más accesible e interactivo para todos.';
	@override String get visionTitle => 'Nuestra Visión';
	@override String get visionText => 'Ser la plataforma líder en curaduría de arte con Realidad Aumentada, reconocida por su innovación, accesibilidad y la capacidad de crear experiencias memorables que trascienden los límites tradicionales de las galerías y los museos.';
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
	@override String get portuguese => 'Português';
	@override String get english => 'Inglés';
	@override String get spanish => 'Español';
}

// Path: map
class _StringsMapEs implements _StringsMapEn {
	_StringsMapEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get loadingGps => 'Buscando señal de GPS...';
	@override String get artworkLargo => 'Obra RA: Largo da Ordem';
	@override String get artworkMon => 'Obra RA: MON';
	@override String get artworkOpera => 'Obra RA: Ópera de Arame';
	@override String get arrivedTitle => 'Has llegado a la ubicación de la obra';
	@override String get openArButton => 'Abrir Realidad aumentada';
}

// Path: bottomNav
class _StringsBottomNavEs implements _StringsBottomNavEn {
	_StringsBottomNavEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get explore => 'Explorar';
	@override String get gallery => 'Exposiciones';
	@override String get captured => 'Capturado';
	@override String get settings => 'Configuración';
}

// Path: ar
class _StringsArEs implements _StringsArEn {
	_StringsArEs._(this._root);

	@override final _StringsEs _root; // ignore: unused_field

	// Translations
	@override String get scanInstruction => 'Escanea el suelo moviendo el móvil';
	@override String get tapToPlace => 'Toca la pantalla para colocar la obra';
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
	@override late final _StringsAboutPt about = _StringsAboutPt._(_root);
	@override late final _StringsLanguagePagePt languagePage = _StringsLanguagePagePt._(_root);
	@override late final _StringsMapPt map = _StringsMapPt._(_root);
	@override late final _StringsBottomNavPt bottomNav = _StringsBottomNavPt._(_root);
	@override late final _StringsArPt ar = _StringsArPt._(_root);
}

// Path: gallery
class _StringsGalleryPt implements _StringsGalleryEn {
	_StringsGalleryPt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Exposições';
	@override String get tabArtwork => 'Obras';
	@override String get tabArtists => 'Artistas';
	@override String get artworkTitle => 'O Jardim das Delícias Terrenas';
	@override String get artworkArtist => 'Hieronymus Bosch';
	@override String get artistSubtitle => 'Bienal de Curitiba 2025';
	@override String get viewExhibition => 'Ver exposição';
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
	@override String get about => 'Sobre Out Vision';
	@override String get imprint => 'Impressão';
	@override String get privacyPolicy => 'Política de Privacidade';
	@override String get termsOfUse => 'Termos de Uso';
}

// Path: about
class _StringsAboutPt implements _StringsAboutEn {
	_StringsAboutPt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get pageTitle => 'Sobre Outvision';
	@override String get mainTitle => 'Outvision XR: Arte e Realidade Aumentada';
	@override String get description => 'Outvision XR é uma plataforma inovadora que redefine a experiência da arte, combinando o mundo físico com a imersão da Realidade Aumentada (RA). Desenvolvido para entusiastas da arte e visitantes de exposições como a Bienal de Curitiba, nosso aplicativo transforma a maneira como você interage com obras e artistas.';
	@override String get missionTitle => 'Nossa Missão';
	@override String get missionText => 'Conectar pessoas à arte de maneiras inéditas, utilizando a tecnologia para enriquecer a compreensão e o engajamento com expressões culturais contemporâneas. Acreditamos que a RA pode quebrar barreiras e tornar a arte mais acessível e interativa para todos.';
	@override String get visionTitle => 'Nossa Visão';
	@override String get visionText => 'Ser a plataforma líder em curadoria de arte com Realidade Aumentada, reconhecida por sua inovação, acessibilidade e pela capacidade de criar experiências memoráveis que transcendem os limites tradicionais das galerias e museus.';
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
}

// Path: bottomNav
class _StringsBottomNavPt implements _StringsBottomNavEn {
	_StringsBottomNavPt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get explore => 'Explorar';
	@override String get gallery => 'Exposições';
	@override String get captured => 'Capturados';
	@override String get settings => 'Configurações';
}

// Path: ar
class _StringsArPt implements _StringsArEn {
	_StringsArPt._(this._root);

	@override final _StringsPt _root; // ignore: unused_field

	// Translations
	@override String get scanInstruction => 'Escaneie o chão movendo o celular';
	@override String get tapToPlace => 'Toque na tela para posicionar a obra';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'gallery.title': return 'Exhibitions';
			case 'gallery.tabArtwork': return 'Artwork';
			case 'gallery.tabArtists': return 'Artists';
			case 'gallery.artworkTitle': return 'The Garden of Earthly Delights';
			case 'gallery.artworkArtist': return 'Hieronymus Bosch';
			case 'gallery.artistSubtitle': return 'Curitiba Biennial 2025';
			case 'gallery.viewExhibition': return 'View exhibition';
			case 'settings.title': return 'Settings';
			case 'settings.getHelp': return 'How to use the App';
			case 'settings.appSettings': return 'App Settings';
			case 'settings.language': return 'Language';
			case 'settings.about': return 'About Out Vision';
			case 'settings.imprint': return 'Imprint';
			case 'settings.privacyPolicy': return 'Privacy Policy';
			case 'settings.termsOfUse': return 'Terms of Use';
			case 'about.pageTitle': return 'About Outvision';
			case 'about.mainTitle': return 'Outvision XR: Art and Augmented Reality';
			case 'about.description': return 'Outvision XR is an innovative platform that redefines the art experience, combining the physical world with the immersion of Augmented Reality (AR). Developed for art enthusiasts and exhibition visitors like the Curitiba Biennial, our app transforms the way you interact with artworks and artists.';
			case 'about.missionTitle': return 'Our Mission';
			case 'about.missionText': return 'To connect people to art in unprecedented ways, using technology to enrich the understanding and engagement with contemporary cultural expressions. We believe that AR can break down barriers and make art more accessible and interactive for everyone.';
			case 'about.visionTitle': return 'Our Vision';
			case 'about.visionText': return 'To be the leading platform for Augmented Reality art curation, recognized for its innovation, accessibility, and the ability to create memorable experiences that transcend the traditional limits of galleries and museums.';
			case 'about.connectTitle': return 'Connect With Us';
			case 'about.website': return 'Website';
			case 'about.email': return 'Email';
			case 'about.instagram': return 'Instagram';
			case 'about.share': return 'Share';
			case 'about.copyright': return 'Outvision XR © 2025. All rights reserved.';
			case 'languagePage.title': return 'Language';
			case 'languagePage.portuguese': return 'Português';
			case 'languagePage.english': return 'English';
			case 'languagePage.spanish': return 'Español';
			case 'map.loadingGps': return 'Searching for GPS signal...';
			case 'map.artworkLargo': return 'AR Artwork: Largo da Ordem';
			case 'map.artworkMon': return 'AR Artwork: MON';
			case 'map.artworkOpera': return 'AR Artwork: Ópera de Arame';
			case 'map.arrivedTitle': return 'You have arrived at the artwork location';
			case 'map.openArButton': return 'Open Augmented Reality';
			case 'bottomNav.explore': return 'Explore';
			case 'bottomNav.gallery': return 'Exhibitions';
			case 'bottomNav.captured': return 'Captured';
			case 'bottomNav.settings': return 'Settings';
			case 'ar.scanInstruction': return 'Scan the floor by moving your phone';
			case 'ar.tapToPlace': return 'Tap on screen to place artwork';
			default: return null;
		}
	}
}

extension on _StringsEs {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'gallery.title': return 'Exposiciones';
			case 'gallery.tabArtwork': return 'Obras';
			case 'gallery.tabArtists': return 'Artistas';
			case 'gallery.artworkTitle': return 'El Jardín de las Delicias Terrenales';
			case 'gallery.artworkArtist': return 'El Bosco';
			case 'gallery.artistSubtitle': return 'Bienal de Curitiba 2025';
			case 'gallery.viewExhibition': return 'Ver exposición';
			case 'settings.title': return 'Ajustes';
			case 'settings.getHelp': return 'Como usar el App';
			case 'settings.appSettings': return 'Configuración de la Aplicación';
			case 'settings.language': return 'Idioma';
			case 'settings.about': return 'Acerca de Out Vision';
			case 'settings.imprint': return 'Impresión';
			case 'settings.privacyPolicy': return 'Política de Privacidad';
			case 'settings.termsOfUse': return 'Términos de Uso';
			case 'about.pageTitle': return 'Acerca de Outvision';
			case 'about.mainTitle': return 'Outvision XR: Arte y Realidad Aumentada';
			case 'about.description': return 'Outvision XR es una plataforma innovadora que redefine la experiencia del arte, combinando el mundo físico con la inmersión de la Realidad Aumentada (RA). Desarrollada para entusiastas del arte y visitantes de exposiciones como la Bienal de Curitiba, nuestra aplicación transforma la forma en que interactúas con obras de arte y artistas.';
			case 'about.missionTitle': return 'Nuestra Misión';
			case 'about.missionText': return 'Conectar a las personas con el arte de maneras sin precedentes, utilizando la tecnología para enriquecer la comprensión y el compromiso con las expresiones culturales contemporáneas. Creemos que la RA puede derribar barreras y hacer el arte más accesible e interactivo para todos.';
			case 'about.visionTitle': return 'Nuestra Visión';
			case 'about.visionText': return 'Ser la plataforma líder en curaduría de arte con Realidad Aumentada, reconocida por su innovación, accesibilidad y la capacidad de crear experiencias memorables que trascienden los límites tradicionales de las galerías y los museos.';
			case 'about.connectTitle': return 'Conéctate con Nosotros';
			case 'about.website': return 'Sitio Web';
			case 'about.email': return 'Correo Electrónico';
			case 'about.instagram': return 'Instagram';
			case 'about.share': return 'Compartir';
			case 'about.copyright': return 'Outvision XR © 2025. Todos los derechos reservados.';
			case 'languagePage.title': return 'Idioma';
			case 'languagePage.portuguese': return 'Português';
			case 'languagePage.english': return 'Inglés';
			case 'languagePage.spanish': return 'Español';
			case 'map.loadingGps': return 'Buscando señal de GPS...';
			case 'map.artworkLargo': return 'Obra RA: Largo da Ordem';
			case 'map.artworkMon': return 'Obra RA: MON';
			case 'map.artworkOpera': return 'Obra RA: Ópera de Arame';
			case 'map.arrivedTitle': return 'Has llegado a la ubicación de la obra';
			case 'map.openArButton': return 'Abrir Realidad aumentada';
			case 'bottomNav.explore': return 'Explorar';
			case 'bottomNav.gallery': return 'Exposiciones';
			case 'bottomNav.captured': return 'Capturado';
			case 'bottomNav.settings': return 'Configuración';
			case 'ar.scanInstruction': return 'Escanea el suelo moviendo el móvil';
			case 'ar.tapToPlace': return 'Toca la pantalla para colocar la obra';
			default: return null;
		}
	}
}

extension on _StringsPt {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'gallery.title': return 'Exposições';
			case 'gallery.tabArtwork': return 'Obras';
			case 'gallery.tabArtists': return 'Artistas';
			case 'gallery.artworkTitle': return 'O Jardim das Delícias Terrenas';
			case 'gallery.artworkArtist': return 'Hieronymus Bosch';
			case 'gallery.artistSubtitle': return 'Bienal de Curitiba 2025';
			case 'gallery.viewExhibition': return 'Ver exposição';
			case 'settings.title': return 'Configurações';
			case 'settings.getHelp': return 'Como usar o App';
			case 'settings.appSettings': return 'Configurações do App';
			case 'settings.language': return 'Idioma';
			case 'settings.about': return 'Sobre Out Vision';
			case 'settings.imprint': return 'Impressão';
			case 'settings.privacyPolicy': return 'Política de Privacidade';
			case 'settings.termsOfUse': return 'Termos de Uso';
			case 'about.pageTitle': return 'Sobre Outvision';
			case 'about.mainTitle': return 'Outvision XR: Arte e Realidade Aumentada';
			case 'about.description': return 'Outvision XR é uma plataforma inovadora que redefine a experiência da arte, combinando o mundo físico com a imersão da Realidade Aumentada (RA). Desenvolvido para entusiastas da arte e visitantes de exposições como a Bienal de Curitiba, nosso aplicativo transforma a maneira como você interage com obras e artistas.';
			case 'about.missionTitle': return 'Nossa Missão';
			case 'about.missionText': return 'Conectar pessoas à arte de maneiras inéditas, utilizando a tecnologia para enriquecer a compreensão e o engajamento com expressões culturais contemporâneas. Acreditamos que a RA pode quebrar barreiras e tornar a arte mais acessível e interativa para todos.';
			case 'about.visionTitle': return 'Nossa Visão';
			case 'about.visionText': return 'Ser a plataforma líder em curadoria de arte com Realidade Aumentada, reconhecida por sua inovação, acessibilidade e pela capacidade de criar experiências memoráveis que transcendem os limites tradicionais das galerias e museus.';
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
			case 'bottomNav.explore': return 'Explorar';
			case 'bottomNav.gallery': return 'Exposições';
			case 'bottomNav.captured': return 'Capturados';
			case 'bottomNav.settings': return 'Configurações';
			case 'ar.scanInstruction': return 'Escaneie o chão movendo o celular';
			case 'ar.tapToPlace': return 'Toque na tela para posicionar a obra';
			default: return null;
		}
	}
}
