import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:localization/localization.dart';

// The generated bucket classes (AppLocalization, ErrorsLocalization, SettingsLocalization,
// AuthLocalization, Locales) reach call sites through core.dart via this export.
export 'package:localization/localization.dart';

extension LocalizationX on BuildContext {
  /// {@macro localization}
  AppLocalization get l10n => Localization.of(this);
}

/// {@template localization}
/// Static facade over the sheety_localization/gen-l10n bucket classes
/// (`app` / `errors` / `settings` / `auth` — one Google Sheets tab each).
/// {@endtemplate}
abstract final class Localization {
  /// Get supported locales.
  static List<Locale> get supportedLocales => Locales.values;

  /// List of localization delegates.
  static List<LocalizationsDelegate<Object?>> get localizationDelegates => [
    // Delegates below take care of built-in flutter widgets
    GlobalWidgetsLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,

    // Each bucket is loaded through a capture, so a controller can read the CURRENT sheet without a
    // BuildContext — which is what a `.description(...)` on a telemetry draft needs, since it is
    // written where the failure happens and not where it is shown.
    const _CurrentCapture<AppLocalization>(AppLocalization.delegate, _captureApp),
    const _CurrentCapture<ErrorsLocalization>(ErrorsLocalization.delegate, _captureErrors),
    const _CurrentCapture<SettingsLocalization>(SettingsLocalization.delegate, _captureSettings),
    const _CurrentCapture<AuthLocalization>(AuthLocalization.delegate, _captureAuth),
  ];

  /// Computes the default locale: the platform locale when supported, English otherwise.
  static Locale get computeDefaultLocale {
    final locale = PlatformDispatcher.instance.locale;
    return supportedLocales.firstWhere(
      (supported) => supported.languageCode == locale.languageCode,
      orElse: () => Locales.en,
    );
  }

  /// The most recently loaded bucket of each sheet — the context-free escape
  /// hatch for controller-side localization (`user_facing_error.dart`, and any
  /// `.description(...)` written outside the widget tree).
  ///
  /// `null` until the delegate has loaded, which is why every reader carries an
  /// English fallback.
  static AppLocalization? _currentApp;

  /// The current `app` sheet, or `null` before the first load.
  static AppLocalization? get currentApp => _currentApp;
  static ErrorsLocalization? _currentErrors;

  /// The current `errors` sheet, or `null` before the first load.
  static ErrorsLocalization? get currentErrors => _currentErrors;

  static SettingsLocalization? _currentSettings;

  /// The current `settings` sheet, or `null` before the first load.
  static SettingsLocalization? get currentSettings => _currentSettings;

  static AuthLocalization? _currentAuth;

  /// The current `auth` sheet, or `null` before the first load.
  static AuthLocalization? get currentAuth => _currentAuth;

  /// Sets the captured buckets by hand. Tests only.
  ///
  /// The readers of `current*` are the ones with no `BuildContext` — a controller's sentence, a
  /// release error box's semantics label — so a test of one of those has no widget tree to load
  /// a delegate from. Called with nothing, it restores the "no frame yet" state, which is the
  /// other branch every reader carries.
  @visibleForTesting
  static void debugSetCurrent({
    AppLocalization? app,
    ErrorsLocalization? errors,
    SettingsLocalization? settings,
    AuthLocalization? auth,
  }) {
    _currentApp = app;
    _currentErrors = errors;
    _currentSettings = settings;
    _currentAuth = auth;
  }

  /// The `app` bucket for the given context (most UI strings live there).
  /// The other buckets are read directly: `SettingsLocalization.of(context)`, etc.
  static AppLocalization of(BuildContext context) => AppLocalization.of(context);

  /// Get language by code.
  static ({String name, String nativeName})? getLanguageByCode(String code) => switch (_kIsoLangs[code]) {
    final (String, String) lang => (name: lang.$1, nativeName: lang.$2),
    _ => null,
  };

  // Methods, not setters: each is torn off into a `const _CurrentCapture(...)`, and a setter
  // cannot be torn off.
  // ignore_for_file: use_setters_to_change_properties
  static void _captureApp(AppLocalization loaded) => _currentApp = loaded;
  static void _captureErrors(ErrorsLocalization loaded) => _currentErrors = loaded;
  static void _captureSettings(SettingsLocalization loaded) => _currentSettings = loaded;
  static void _captureAuth(AuthLocalization loaded) => _currentAuth = loaded;
}

/// Loads a bucket through its generated delegate and records the result.
///
/// `SynchronousFuture.then` runs inline, so the capture lands before the first
/// frame. Const with a static tear-off: `localizationDelegates` builds a fresh
/// list on every read, and two identical const instances are the same object —
/// without that, Flutter would see a new delegate each build and reload.
@immutable
final class _CurrentCapture<T extends Object> extends LocalizationsDelegate<T> {
  const _CurrentCapture(this._delegate, this._capture);

  final LocalizationsDelegate<T> _delegate;
  final void Function(T loaded) _capture;

  @override
  bool isSupported(Locale locale) => _delegate.isSupported(locale);

  @override
  Future<T> load(Locale locale) {
    final future = _delegate.load(locale);
    final _ = future.then(_capture);
    return future;
  }

  @override
  bool shouldReload(covariant _CurrentCapture<T> old) => false;
}

const Map<String, (String name, String nativeName)> _kIsoLangs = <String, (String name, String nativeName)>{
  'ab': ('Abkhaz', 'аҧсуа'),
  'aa': ('Afar', 'Afaraf'),
  'af': ('Afrikaans', 'Afrikaans'),
  'ak': ('Akan', 'Akan'),
  'sq': ('Albanian', 'Shqip'),
  'am': ('Amharic', 'አማርኛ'),
  'ar': ('Arabic', 'العربية'),
  'an': ('Aragonese', 'Aragonés'),
  'hy': ('Armenian', 'Հայերեն'),
  'as': ('Assamese', 'অসমীয়া'),
  'av': ('Avaric', 'авар мацӀ, магӀарул мацӀ'),
  'ae': ('Avestan', 'avesta'),
  'ay': ('Aymara', 'aymar aru'),
  'az': ('Azerbaijani', 'azərbaycan dili'),
  'bm': ('Bambara', 'bamanankan'),
  'ba': ('Bashkir', 'башҡорт теле'),
  'eu': ('Basque', 'euskara, euskera'),
  'be': ('Belarusian', 'Беларуская'),
  'bn': ('Bengali', 'বাংলা'),
  'bh': ('Bihari', 'भोजपुरी'),
  'bi': ('Bislama', 'Bislama'),
  'bs': ('Bosnian', 'bosanski jezik'),
  'br': ('Breton', 'brezhoneg'),
  'bg': ('Bulgarian', 'български език'),
  'my': ('Burmese', 'ဗမာစာ'),
  'ca': ('Catalan, Valencian', 'Català'),
  'ch': ('Chamorro', 'Chamoru'),
  'ce': ('Chechen', 'нохчийн мотт'),
  'ny': ('Chichewa, Chewa, Nyanja', 'chiCheŵa, chinyanja'),
  'zh': ('Chinese', '中文 (Zhōngwén), 汉语, 漢語'),
  'cv': ('Chuvash', 'чӑваш чӗлхи'),
  'kw': ('Cornish', 'Kernewek'),
  'co': ('Corsican', 'corsu, lingua corsa'),
  'cr': ('Cree', 'ᓀᐦᐃᔭᐍᐏᐣ'),
  'hr': ('Croatian', 'hrvatski'),
  'cs': ('Czech', 'česky, čeština'),
  'da': ('Danish', 'dansk'),
  'dv': ('Divehi, Dhivehi, Maldivian;', 'ދިވެހި'),
  'nl': ('Dutch', 'Nederlands, Vlaams'),
  'en': ('English', 'English'),
  'eo': ('Esperanto', 'Esperanto'),
  'et': ('Estonian', 'eesti, eesti keel'),
  'fo': ('Faroese', 'føroyskt'),
  'fj': ('Fijian', 'vosa Vakaviti'),
  'fi': ('Finnish', 'suomi, suomen kieli'),
  'fr': ('French', 'Français'),
  'ff': ('Fula, Fulah, Pulaar, Pular', 'Fulfulde, Pulaar, Pular'),
  'gl': ('Galician', 'Galego'),
  'ka': ('Georgian', 'ქართული'),
  'de': ('German', 'Deutsch'),
  'el': ('Greek, Modern', 'Ελληνικά'),
  'gn': ('Guaraní', 'Avañeẽ'),
  'gu': ('Gujarati', 'ગુજરાતી'),
  'ht': ('Haitian, Haitian Creole', 'Kreyòl ayisyen'),
  'ha': ('Hausa', 'Hausa, هَوُسَ'),
  'he': ('Hebrew (modern)', 'עברית'),
  'hz': ('Herero', 'Otjiherero'),
  'hi': ('Hindi', 'हिन्दी, हिंदी'),
  'ho': ('Hiri Motu', 'Hiri Motu'),
  'hu': ('Hungarian', 'Magyar'),
  'ia': ('Interlingua', 'Interlingua'),
  'id': ('Indonesian', 'Bahasa Indonesia'),
  'ie': ('Interlingue', 'Interlingue'),
  'ga': ('Irish', 'Gaeilge'),
  'ig': ('Igbo', 'Asụsụ Igbo'),
  'ik': ('Inupiaq', 'Iñupiaq, Iñupiatun'),
  'io': ('Ido', 'Ido'),
  'is': ('Icelandic', 'Íslenska'),
  'it': ('Italian', 'Italiano'),
  'iu': ('Inuktitut', 'ᐃᓄᒃᑎᑐᑦ'),
  'ja': ('Japanese', '日本語 (にほんご／にっぽんご)'),
  'jv': ('Javanese', 'basa Jawa'),
  'kl': ('Kalaallisut, Greenlandic', 'kalaallisut, kalaallit oqaasii'),
  'kn': ('Kannada', 'ಕನ್ನಡ'),
  'kr': ('Kanuri', 'Kanuri'),
  'kk': ('Kazakh', 'Қазақ тілі'),
  'km': ('Khmer', 'ភាសាខ្មែរ'),
  'ki': ('Kikuyu, Gikuyu', 'Gĩkũyũ'),
  'rw': ('Kinyarwanda', 'Ikinyarwanda'),
  'ky': ('Kirghiz, Kyrgyz', 'кыргыз тили'),
  'kv': ('Komi', 'коми кыв'),
  'kg': ('Kongo', 'KiKongo'),
  'ko': ('Korean', '한국어 (韓國語), 조선말 (朝鮮語)'),
  'kj': ('Kwanyama, Kuanyama', 'Kuanyama'),
  'la': ('Latin', 'latine, lingua latina'),
  'lb': ('Luxembourgish', 'Lëtzebuergesch'),
  'lg': ('Luganda', 'Luganda'),
  'li': ('Limburgish, Limburgan, Limburger', 'Limburgs'),
  'ln': ('Lingala', 'Lingála'),
  'lo': ('Lao', 'ພາສາລາວ'),
  'lt': ('Lithuanian', 'lietuvių kalba'),
  'lu': ('Luba-Katanga', ''),
  'lv': ('Latvian', 'latviešu valoda'),
  'gv': ('Manx', 'Gaelg, Gailck'),
  'mk': ('Macedonian', 'македонски јазик'),
  'mg': ('Malagasy', 'Malagasy fiteny'),
  'ml': ('Malayalam', 'മലയാളം'),
  'mt': ('Maltese', 'Malti'),
  'mi': ('Māori', 'te reo Māori'),
  'mr': ('Marathi (Marāṭhī)', 'मराठी'),
  'mh': ('Marshallese', 'Kajin M̧ajeļ'),
  'mn': ('Mongolian', 'монгол'),
  'na': ('Nauru', 'Ekakairũ Naoero'),
  'nb': ('Norwegian Bokmål', 'Norsk bokmål'),
  'nd': ('North Ndebele', 'isiNdebele'),
  'ne': ('Nepali', 'नेपाली'),
  'ng': ('Ndonga', 'Owambo'),
  'nn': ('Norwegian Nynorsk', 'Norsk nynorsk'),
  'no': ('Norwegian', 'Norsk'),
  'ii': ('Nuosu', 'ꆈꌠ꒿ Nuosuhxop'),
  'nr': ('South Ndebele', 'isiNdebele'),
  'oc': ('Occitan', 'Occitan'),
  'oj': ('Ojibwe, Ojibwa', 'ᐊᓂᔑᓈᐯᒧᐎᓐ'),
  'om': ('Oromo', 'Afaan Oromoo'),
  'or': ('Oriya', 'ଓଡ଼ିଆ'),
  'pi': ('Pāli', 'पाऴि'),
  'fa': ('Persian', 'فارسی'),
  'pl': ('Polish', 'Polski'),
  'ps': ('Pashto, Pushto', 'پښتو'),
  'pt': ('Portuguese', 'Português'),
  'qu': ('Quechua', 'Runa Simi, Kichwa'),
  'rm': ('Romansh', 'rumantsch grischun'),
  'rn': ('Kirundi', 'kiRundi'),
  'ro': ('Romanian, Moldavian, Moldovan', 'română'),
  'ru': ('Russian', 'Русский'),
  'sa': ('Sanskrit (Saṁskṛta)', 'संस्कृतम्'),
  'sc': ('Sardinian', 'sardu'),
  'se': ('Northern Sami', 'Davvisámegiella'),
  'sm': ('Samoan', 'gagana faa Samoa'),
  'sg': ('Sango', 'yângâ tî sängö'),
  'sr': ('Serbian', 'српски језик'),
  'gd': ('Scottish Gaelic, Gaelic', 'Gàidhlig'),
  'sn': ('Shona', 'chiShona'),
  'si': ('Sinhala, Sinhalese', 'සිංහල'),
  'sk': ('Slovak', 'slovenčina'),
  'sl': ('Slovene', 'slovenščina'),
  'so': ('Somali', 'Soomaaliga, af Soomaali'),
  'st': ('Southern Sotho', 'Sesotho'),
  'es': ('Spanish', 'Español'),
  'su': ('Sundanese', 'Basa Sunda'),
  'sw': ('Swahili', 'Kiswahili'),
  'ss': ('Swati', 'SiSwati'),
  'sv': ('Swedish', 'svenska'),
  'ta': ('Tamil', 'தமிழ்'),
  'te': ('Telugu', 'తెలుగు'),
  'th': ('Thai', 'ไทย'),
  'ti': ('Tigrinya', 'ትግርኛ'),
  'bo': ('Tibetan', 'བོད་ཡིག'),
  'tk': ('Turkmen', 'Türkmen, Түркмен'),
  'tn': ('Tswana', 'Setswana'),
  'to': ('Tonga (Tonga Islands)', 'faka Tonga'),
  'tr': ('Turkish', 'Türkçe'),
  'ts': ('Tsonga', 'Xitsonga'),
  'tw': ('Twi', 'Twi'),
  'ty': ('Tahitian', 'Reo Tahiti'),
  'uk': ('Ukrainian', 'українська'),
  'ur': ('Urdu', 'اردو'),
  've': ('Venda', 'Tshivenḓa'),
  'vi': ('Vietnamese', 'Tiếng Việt'),
  'vo': ('Volapük', 'Volapük'),
  'wa': ('Walloon', 'Walon'),
  'cy': ('Welsh', 'Cymraeg'),
  'wo': ('Wolof', 'Wollof'),
  'fy': ('Western Frisian', 'Frysk'),
  'xh': ('Xhosa', 'isiXhosa'),
  'yi': ('Yiddish', 'ייִדיש'),
  'yo': ('Yoruba', 'Yorùbá'),
};
