import 'package:auth_app/core/gen/localization/l10n.dart' as generated
    show GeneratedLocalization, AppLocalizationDelegate;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:meta/meta.dart';

extension LocalizationX on BuildContext {
  /// {@macro localization}
  Localization get l10n => Localization.of(this);
}

/// {@template localization}
/// Localization class which is used to localize app.
/// This class provides handy methods and tools.
/// {@endtemplate}
final class Localization extends generated.GeneratedLocalization {
  /// Locale which is currently used.
  final Locale locale;

  /// Localization delegate.
  static const delegate = _LocalizationDelegate(generated.AppLocalizationDelegate());
  static Localization? _current;

  /// Get supported locales.
  static List<Locale> get supportedLocales => const generated.AppLocalizationDelegate().supportedLocales;

  /// List of localization delegates.
  static List<LocalizationsDelegate<void>> get localizationDelegates => [
        // Delegates below take care of built-in flutter widgets
        GlobalWidgetsLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,

        // Provide the labels that are not overridden by LabelOverrides
        // FirebaseUILocalizations.delegate,
        // Creates an instance of FirebaseUILocalizationDelegate with overridden labels
        // FirebaseUILocalizations.withDefaultOverrides(LabelOverrides()),

        Localization.delegate,
      ];

  /// Current localization instance.
  static Localization? get current => _current;

  /// {@macro localization}
  Localization._({
    required this.locale,
  });

  /// Obtain [Localization] instance from [BuildContext].
  static Localization of(BuildContext context) => switch (Localizations.of<Localization>(context, Localization)) {
        final Localization localization => localization,
        _ => throw ArgumentError(
            'Out of scope, not found inherited widget a Localization of the exact type',
            'out_of_scope',
          ),
      };

  /// Get language by code.
  static ({String name, String nativeName})? getLanguageByCode(String code) => //
      switch (_kIsoLangs[code]) {
        (:final String name, :final String nativeName) => (name: name, nativeName: nativeName),
        _ => null,
      };
}

@immutable
final class _LocalizationDelegate extends LocalizationsDelegate<Localization> {
  final LocalizationsDelegate<generated.GeneratedLocalization> _delegate;

  @literal
  const _LocalizationDelegate(
    LocalizationsDelegate<generated.GeneratedLocalization> delegate,
  ) : _delegate = delegate;

  @override
  bool isSupported(Locale locale) => _delegate.isSupported(locale);

  @override
  Future<Localization> load(Locale locale) async {
    await generated.GeneratedLocalization.load(locale);
    return Localization._current = Localization._(locale: locale);
  }

  @override
  bool shouldReload(covariant _LocalizationDelegate old) => _delegate.shouldReload(old._delegate);
}

const _kIsoLangs = <String, (String name, String nativeName)>{
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
