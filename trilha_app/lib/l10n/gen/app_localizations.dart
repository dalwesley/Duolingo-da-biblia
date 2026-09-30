import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @authAccountExists.
  ///
  /// In pt, this message translates to:
  /// **'Já existe uma conta com este e-mail usando outro método de login.'**
  String get authAccountExists;

  /// No description provided for @authEnableProviders.
  ///
  /// In pt, this message translates to:
  /// **'Ative os provedores no Firebase Console: Authentication → Sign-in method → Anonymous e/ou Google.'**
  String get authEnableProviders;

  /// No description provided for @authFirebaseNotReady.
  ///
  /// In pt, this message translates to:
  /// **'Firebase ainda não está pronto.'**
  String get authFirebaseNotReady;

  /// No description provided for @authGenericError.
  ///
  /// In pt, this message translates to:
  /// **'Erro de Auth ({code}): {message}'**
  String authGenericError(String code, String message);

  /// No description provided for @authInvalidCredential.
  ///
  /// In pt, this message translates to:
  /// **'Credencial Google inválida. Cadastre o SHA-1 do app no Firebase e baixe o google-services.json de novo.'**
  String get authInvalidCredential;

  /// No description provided for @authLoginInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Login em andamento.'**
  String get authLoginInProgress;

  /// No description provided for @authMissingIdToken.
  ///
  /// In pt, this message translates to:
  /// **'Google não retornou idToken. Confira se o SHA-1 da Play está no Firebase.'**
  String get authMissingIdToken;

  /// No description provided for @authNetworkReset.
  ///
  /// In pt, this message translates to:
  /// **'Falha de rede ao falar com o Firebase Auth (conexão resetada). Tente de novo em Wi‑Fi estável ou dados móveis.'**
  String get authNetworkReset;

  /// No description provided for @authNoInternet.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão com a internet. Verifique o Wi‑Fi/dados do aparelho.'**
  String get authNoInternet;

  /// No description provided for @authTooManyRequests.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Aguarde um pouco e tente de novo.'**
  String get authTooManyRequests;

  /// No description provided for @avatarChangePortrait.
  ///
  /// In pt, this message translates to:
  /// **'Alterar retrato'**
  String get avatarChangePortrait;

  /// No description provided for @avatarOpenProfile.
  ///
  /// In pt, this message translates to:
  /// **'Abrir perfil'**
  String get avatarOpenProfile;

  /// No description provided for @bibleBookFallback.
  ///
  /// In pt, this message translates to:
  /// **'Livro {number}'**
  String bibleBookFallback(int number);

  /// No description provided for @bibleBookReadSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{book}, {read} de {total} capítulos lidos'**
  String bibleBookReadSemantics(String book, int read, int total);

  /// No description provided for @bibleChapterCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 capítulo} other{{count} capítulos}}'**
  String bibleChapterCount(int count);

  /// No description provided for @bibleChapterCountShort.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 cap.} other{{count} caps.}}'**
  String bibleChapterCountShort(int count);

  /// No description provided for @bibleChapterLabel.
  ///
  /// In pt, this message translates to:
  /// **'Capítulo {chapter}'**
  String bibleChapterLabel(int chapter);

  /// No description provided for @bibleChapterReadSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Capítulo {chapter}, lido'**
  String bibleChapterReadSemantics(int chapter);

  /// No description provided for @bibleChaptersReadOf.
  ///
  /// In pt, this message translates to:
  /// **'{read} de {total} lidos'**
  String bibleChaptersReadOf(int read, int total);

  /// No description provided for @bibleDonate.
  ///
  /// In pt, this message translates to:
  /// **'Doar'**
  String get bibleDonate;

  /// No description provided for @bibleHeroContinueReading.
  ///
  /// In pt, this message translates to:
  /// **'Continuar leitura'**
  String get bibleHeroContinueReading;

  /// No description provided for @bibleHeroFreshBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Jesus, a Palavra que se fez carne — um bom começo.'**
  String get bibleHeroFreshBlurb;

  /// No description provided for @bibleHeroStartHere.
  ///
  /// In pt, this message translates to:
  /// **'Comece por aqui'**
  String get bibleHeroStartHere;

  /// No description provided for @bibleHeroStartReading.
  ///
  /// In pt, this message translates to:
  /// **'Começar a ler'**
  String get bibleHeroStartReading;

  /// No description provided for @bibleIntroAudience.
  ///
  /// In pt, this message translates to:
  /// **'Para quem'**
  String get bibleIntroAudience;

  /// No description provided for @bibleIntroAuthorByTradition.
  ///
  /// In pt, this message translates to:
  /// **'{author} · tradição'**
  String bibleIntroAuthorByTradition(String author);

  /// No description provided for @bibleIntroWhen.
  ///
  /// In pt, this message translates to:
  /// **'Quando'**
  String get bibleIntroWhen;

  /// No description provided for @bibleIntroWho.
  ///
  /// In pt, this message translates to:
  /// **'Quem'**
  String get bibleIntroWho;

  /// No description provided for @bibleNewTestament.
  ///
  /// In pt, this message translates to:
  /// **'Novo Testamento'**
  String get bibleNewTestament;

  /// No description provided for @bibleOldTestament.
  ///
  /// In pt, this message translates to:
  /// **'Antigo Testamento'**
  String get bibleOldTestament;

  /// No description provided for @biblePaperAuto.
  ///
  /// In pt, this message translates to:
  /// **'Automático'**
  String get biblePaperAuto;

  /// No description provided for @biblePaperLight.
  ///
  /// In pt, this message translates to:
  /// **'Clara'**
  String get biblePaperLight;

  /// No description provided for @biblePaperNight.
  ///
  /// In pt, this message translates to:
  /// **'Noite'**
  String get biblePaperNight;

  /// No description provided for @biblePaperSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Papel {paper}'**
  String biblePaperSemantics(String paper);

  /// No description provided for @biblePaperSepia.
  ///
  /// In pt, this message translates to:
  /// **'Sépia'**
  String get biblePaperSepia;

  /// No description provided for @biblePickerBackToBooks.
  ///
  /// In pt, this message translates to:
  /// **'Voltar aos livros'**
  String get biblePickerBackToBooks;

  /// No description provided for @biblePickerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ir para'**
  String get biblePickerTitle;

  /// No description provided for @bibleReadChapter.
  ///
  /// In pt, this message translates to:
  /// **'Ler o capítulo'**
  String get bibleReadChapter;

  /// No description provided for @bibleReadOf.
  ///
  /// In pt, this message translates to:
  /// **'{read} de {total}'**
  String bibleReadOf(int read, int total);

  /// No description provided for @bibleReaderChapterDone.
  ///
  /// In pt, this message translates to:
  /// **'Capítulo lido'**
  String get bibleReaderChapterDone;

  /// No description provided for @bibleReaderChapterEnd.
  ///
  /// In pt, this message translates to:
  /// **'Fim de {book} {chapter}'**
  String bibleReaderChapterEnd(String book, int chapter);

  /// No description provided for @bibleReaderChapterReadToast.
  ///
  /// In pt, this message translates to:
  /// **'{book} {chapter} lido'**
  String bibleReaderChapterReadToast(String book, int chapter);

  /// No description provided for @bibleReaderCompleteChapter.
  ///
  /// In pt, this message translates to:
  /// **'Concluir capítulo'**
  String get bibleReaderCompleteChapter;

  /// No description provided for @bibleReaderListen.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir'**
  String get bibleReaderListen;

  /// No description provided for @bibleReaderNextChapter.
  ///
  /// In pt, this message translates to:
  /// **'Próximo capítulo'**
  String get bibleReaderNextChapter;

  /// No description provided for @bibleReaderOpenFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir {reference}.'**
  String bibleReaderOpenFailed(String reference);

  /// No description provided for @bibleReaderPaper.
  ///
  /// In pt, this message translates to:
  /// **'Papel'**
  String get bibleReaderPaper;

  /// No description provided for @bibleReaderPrevChapter.
  ///
  /// In pt, this message translates to:
  /// **'Capítulo anterior'**
  String get bibleReaderPrevChapter;

  /// No description provided for @bibleReaderReadTag.
  ///
  /// In pt, this message translates to:
  /// **'lido'**
  String get bibleReaderReadTag;

  /// No description provided for @bibleReaderSettings.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes de leitura'**
  String get bibleReaderSettings;

  /// No description provided for @bibleReaderStop.
  ///
  /// In pt, this message translates to:
  /// **'Parar'**
  String get bibleReaderStop;

  /// No description provided for @bibleReaderSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Capítulo {chapter} · {translation}'**
  String bibleReaderSubtitle(int chapter, String translation);

  /// No description provided for @bibleReaderTextSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho do texto'**
  String get bibleReaderTextSize;

  /// No description provided for @bibleReaderUpNext.
  ///
  /// In pt, this message translates to:
  /// **'A seguir'**
  String get bibleReaderUpNext;

  /// No description provided for @bibleReaderVersion.
  ///
  /// In pt, this message translates to:
  /// **'Versão'**
  String get bibleReaderVersion;

  /// No description provided for @bibleSavedEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Na leitura, toque num versículo e escolha Guardar para voltar a ele depois.'**
  String get bibleSavedEmptyBody;

  /// No description provided for @bibleSavedEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum versículo guardado'**
  String get bibleSavedEmptyTitle;

  /// No description provided for @bibleSavedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Guardados'**
  String get bibleSavedTitle;

  /// No description provided for @bibleSearchBookHit.
  ///
  /// In pt, this message translates to:
  /// **'Livro'**
  String get bibleSearchBookHit;

  /// No description provided for @bibleSearchButtonHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar livro, versículo ou palavra…'**
  String get bibleSearchButtonHint;

  /// No description provided for @bibleSearchButtonSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Buscar livro ou versículo'**
  String get bibleSearchButtonSemantics;

  /// No description provided for @bibleSearchEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado encontrado'**
  String get bibleSearchEmpty;

  /// Os exemplos ficam em português: a busca é no texto bíblico em português.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Apocalipse, amor, fé…'**
  String get bibleSearchFieldHint;

  /// No description provided for @bibleSearchSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Livros e versículos'**
  String get bibleSearchSubtitle;

  /// No description provided for @bibleSearchTitle.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get bibleSearchTitle;

  /// No description provided for @bibleSectionBooksSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{{title}, 1 livro} other{{title}, {count} livros}}'**
  String bibleSectionBooksSemantics(String title, int count);

  /// No description provided for @bibleShareAsText.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar como texto'**
  String get bibleShareAsText;

  /// No description provided for @bibleShareImage.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar imagem'**
  String get bibleShareImage;

  /// No description provided for @bibleSharePreparing.
  ///
  /// In pt, this message translates to:
  /// **'Preparando…'**
  String get bibleSharePreparing;

  /// No description provided for @bibleShareTextFooter.
  ///
  /// In pt, this message translates to:
  /// **'Via Stway'**
  String get bibleShareTextFooter;

  /// No description provided for @bibleShareTitle.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar versículo'**
  String get bibleShareTitle;

  /// Assinatura em textos compartilhados do versículo
  ///
  /// In pt, this message translates to:
  /// **'{ref} — via Stway'**
  String bibleShareVia(String ref);

  /// No description provided for @bibleTabReading.
  ///
  /// In pt, this message translates to:
  /// **'Leitura'**
  String get bibleTabReading;

  /// No description provided for @bibleTapToClose.
  ///
  /// In pt, this message translates to:
  /// **'Toque para fechar'**
  String get bibleTapToClose;

  /// No description provided for @bibleTapToOpen.
  ///
  /// In pt, this message translates to:
  /// **'Toque para abrir'**
  String get bibleTapToOpen;

  /// No description provided for @bibleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bíblia'**
  String get bibleTitle;

  /// No description provided for @bibleTranslationSoonBody.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não temos {name}. Em breve essa tradução entra no app. Você pode contribuir com o projeto para ajudar a trazer mais versões.'**
  String bibleTranslationSoonBody(String name);

  /// No description provided for @bibleTranslationSoonTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tradução em breve'**
  String get bibleTranslationSoonTitle;

  /// No description provided for @bibleVerseCopied.
  ///
  /// In pt, this message translates to:
  /// **'Versículo copiado'**
  String get bibleVerseCopied;

  /// No description provided for @bibleVerseCopy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get bibleVerseCopy;

  /// No description provided for @bibleVerseCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 versículo} other{{count} versículos}}'**
  String bibleVerseCount(int count);

  /// No description provided for @bibleVerseListenFromHere.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir daqui em diante'**
  String get bibleVerseListenFromHere;

  /// No description provided for @bibleVerseListenFromHereDetail.
  ///
  /// In pt, this message translates to:
  /// **'Leitura em voz alta, versículo a versículo'**
  String get bibleVerseListenFromHereDetail;

  /// No description provided for @bibleVerseSave.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get bibleVerseSave;

  /// No description provided for @bibleVerseSaved.
  ///
  /// In pt, this message translates to:
  /// **'Guardado'**
  String get bibleVerseSaved;

  /// No description provided for @bibleVerseSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Versículo {number}. {text}'**
  String bibleVerseSemantics(int number, String text);

  /// No description provided for @bibleVerseStudy.
  ///
  /// In pt, this message translates to:
  /// **'Estudar este versículo'**
  String get bibleVerseStudy;

  /// No description provided for @bibleVerseStudyDetail.
  ///
  /// In pt, this message translates to:
  /// **'Originais, Strong, concordância e referências'**
  String get bibleVerseStudyDetail;

  /// No description provided for @canonEvangelhosBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Mateus a João — a vida de Jesus'**
  String get canonEvangelhosBlurb;

  /// No description provided for @canonEvangelhosTitle.
  ///
  /// In pt, this message translates to:
  /// **'Evangelhos'**
  String get canonEvangelhosTitle;

  /// No description provided for @canonGeraisBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Hebreus a Judas'**
  String get canonGeraisBlurb;

  /// No description provided for @canonGeraisTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cartas gerais'**
  String get canonGeraisTitle;

  /// No description provided for @canonHistoriaNtBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Atos dos Apóstolos'**
  String get canonHistoriaNtBlurb;

  /// No description provided for @canonHistoriaNtTitle.
  ///
  /// In pt, this message translates to:
  /// **'História'**
  String get canonHistoriaNtTitle;

  /// No description provided for @canonHistoricosBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Josué a Ester — a história de Israel'**
  String get canonHistoricosBlurb;

  /// No description provided for @canonHistoricosTitle.
  ///
  /// In pt, this message translates to:
  /// **'Históricos'**
  String get canonHistoricosTitle;

  /// No description provided for @canonPaulinasBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Romanos a Filemom'**
  String get canonPaulinasBlurb;

  /// No description provided for @canonPaulinasTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cartas paulinas'**
  String get canonPaulinasTitle;

  /// No description provided for @canonPentateucoBlurb.
  ///
  /// In pt, this message translates to:
  /// **'A Lei — Gênesis a Deuteronômio'**
  String get canonPentateucoBlurb;

  /// No description provided for @canonPentateucoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pentateuco'**
  String get canonPentateucoTitle;

  /// No description provided for @canonPoeticosBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Jó a Cantares'**
  String get canonPoeticosBlurb;

  /// No description provided for @canonPoeticosTitle.
  ///
  /// In pt, this message translates to:
  /// **'Poéticos e sabedoria'**
  String get canonPoeticosTitle;

  /// No description provided for @canonProfeciaBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Apocalipse'**
  String get canonProfeciaBlurb;

  /// No description provided for @canonProfeciaTitle.
  ///
  /// In pt, this message translates to:
  /// **'Profecia'**
  String get canonProfeciaTitle;

  /// No description provided for @canonProfetasMaioresBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Isaías a Daniel'**
  String get canonProfetasMaioresBlurb;

  /// No description provided for @canonProfetasMaioresTitle.
  ///
  /// In pt, this message translates to:
  /// **'Profetas maiores'**
  String get canonProfetasMaioresTitle;

  /// No description provided for @canonProfetasMenoresBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Oséias a Malaquias'**
  String get canonProfetasMenoresBlurb;

  /// No description provided for @canonProfetasMenoresTitle.
  ///
  /// In pt, this message translates to:
  /// **'Profetas menores'**
  String get canonProfetasMenoresTitle;

  /// No description provided for @categoryApocalipseBlurb.
  ///
  /// In pt, this message translates to:
  /// **'O livro de Apocalipse, escrito por João Evangelista.'**
  String get categoryApocalipseBlurb;

  /// No description provided for @categoryApocalipseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apocalipse ou Revelação'**
  String get categoryApocalipseTitle;

  /// No description provided for @categoryCristologiaTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cristologia'**
  String get categoryCristologiaTitle;

  /// No description provided for @categoryDiscipuladoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Discipulado'**
  String get categoryDiscipuladoTitle;

  /// No description provided for @categoryEpistolasBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Vinte e uma cartas às primeiras igrejas — treze de Paulo e oito de outros autores.'**
  String get categoryEpistolasBlurb;

  /// No description provided for @categoryEpistolasTitle.
  ///
  /// In pt, this message translates to:
  /// **'Epístolas ou cartas apostólicas'**
  String get categoryEpistolasTitle;

  /// No description provided for @categoryEvangelhosBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Nascimento, ministério, morte, ressurreição e ascensão de Jesus — Mateus a João.'**
  String get categoryEvangelhosBlurb;

  /// No description provided for @categoryEvangelhosTitle.
  ///
  /// In pt, this message translates to:
  /// **'Evangelhos'**
  String get categoryEvangelhosTitle;

  /// No description provided for @categoryHermeneuticaTitle.
  ///
  /// In pt, this message translates to:
  /// **'Hermenêutica'**
  String get categoryHermeneuticaTitle;

  /// No description provided for @categoryHistoriaIgrejaTitle.
  ///
  /// In pt, this message translates to:
  /// **'História da Igreja'**
  String get categoryHistoriaIgrejaTitle;

  /// No description provided for @categoryHistoricosAtBlurb.
  ///
  /// In pt, this message translates to:
  /// **'A história de Israel da conquista da Terra Prometida até o exílio babilônico.'**
  String get categoryHistoricosAtBlurb;

  /// No description provided for @categoryHistoricosAtTitle.
  ///
  /// In pt, this message translates to:
  /// **'Livros históricos'**
  String get categoryHistoricosAtTitle;

  /// No description provided for @categoryHistoricosNtBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Atos dos Apóstolos — o derramar do Espírito e a expansão do Evangelho.'**
  String get categoryHistoricosNtBlurb;

  /// No description provided for @categoryHistoricosNtTitle.
  ///
  /// In pt, this message translates to:
  /// **'História da Igreja primitiva'**
  String get categoryHistoricosNtTitle;

  /// No description provided for @categoryIntertestamentarioBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Os cerca de 400 anos de silêncio entre o Antigo e o Novo Testamento.'**
  String get categoryIntertestamentarioBlurb;

  /// No description provided for @categoryIntertestamentarioTitle.
  ///
  /// In pt, this message translates to:
  /// **'Período intertestamentário'**
  String get categoryIntertestamentarioTitle;

  /// No description provided for @categoryLinguasTitle.
  ///
  /// In pt, this message translates to:
  /// **'Línguas originais'**
  String get categoryLinguasTitle;

  /// No description provided for @categoryOracaoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Oração'**
  String get categoryOracaoTitle;

  /// No description provided for @categoryPentateucoBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Os cinco primeiros livros da Bíblia — a Torá, o Livro da Lei, em ordem cronológica.'**
  String get categoryPentateucoBlurb;

  /// No description provided for @categoryPentateucoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pentateuco'**
  String get categoryPentateucoTitle;

  /// No description provided for @categoryPoeticosBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Poesia, sabedoria, provérbios e cânticos — organizados por relevância.'**
  String get categoryPoeticosBlurb;

  /// No description provided for @categoryPoeticosTitle.
  ///
  /// In pt, this message translates to:
  /// **'Livros poéticos'**
  String get categoryPoeticosTitle;

  /// No description provided for @categoryProfetasMaioresBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Isaías a Daniel — obras mais extensas entre os registros proféticos.'**
  String get categoryProfetasMaioresBlurb;

  /// No description provided for @categoryProfetasMaioresTitle.
  ///
  /// In pt, this message translates to:
  /// **'Profetas maiores'**
  String get categoryProfetasMaioresTitle;

  /// No description provided for @categoryProfetasMenoresBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Oséias a Malaquias — doze livros; o nome refere-se à extensão, não à importância.'**
  String get categoryProfetasMenoresBlurb;

  /// No description provided for @categoryProfetasMenoresTitle.
  ///
  /// In pt, this message translates to:
  /// **'Profetas menores'**
  String get categoryProfetasMenoresTitle;

  /// No description provided for @categorySistematicaTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sistemática e dogmática'**
  String get categorySistematicaTitle;

  /// No description provided for @celebrationBackHome.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao início'**
  String get celebrationBackHome;

  /// No description provided for @celebrationBackToMap.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao mapa'**
  String get celebrationBackToMap;

  /// No description provided for @celebrationCommitmentBeyond.
  ///
  /// In pt, this message translates to:
  /// **'Além do compromisso de {goal} dias.'**
  String celebrationCommitmentBeyond(int goal);

  /// No description provided for @celebrationCommitmentDone.
  ///
  /// In pt, this message translates to:
  /// **'Compromisso de {goal} dias cumprido!'**
  String celebrationCommitmentDone(int goal);

  /// No description provided for @celebrationCommitmentLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 dia para o seu compromisso.} other{Faltam {count} dias para o seu compromisso.}}'**
  String celebrationCommitmentLeft(int count);

  /// No description provided for @celebrationEchoKicker.
  ///
  /// In pt, this message translates to:
  /// **'Hoje você viu'**
  String get celebrationEchoKicker;

  /// Link para a página de doação
  ///
  /// In pt, this message translates to:
  /// **'Ajude a continuar'**
  String get celebrationHelpContinue;

  /// No description provided for @celebrationInviteSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Um companheiro. Sem ranking — só presença.'**
  String get celebrationInviteSubtitle;

  /// No description provided for @celebrationInviteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Uma companhia na trilha'**
  String get celebrationInviteTitle;

  /// mode = Observação / Compreensão / Interpretação
  ///
  /// In pt, this message translates to:
  /// **'Modo {mode} concluído'**
  String celebrationModeDone(String mode);

  /// No description provided for @celebrationModeRetryPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Que tal responder de novo em {mode}? {subtitle}'**
  String celebrationModeRetryPrompt(String mode, String subtitle);

  /// No description provided for @celebrationModeReviewCta.
  ///
  /// In pt, this message translates to:
  /// **'Revisar uma cena em {mode}'**
  String celebrationModeReviewCta(String mode);

  /// No description provided for @celebrationModeSwitchCta.
  ///
  /// In pt, this message translates to:
  /// **'Mudar para {mode}'**
  String celebrationModeSwitchCta(String mode);

  /// No description provided for @celebrationModeTryCta.
  ///
  /// In pt, this message translates to:
  /// **'Tentar em {mode}'**
  String celebrationModeTryCta(String mode);

  /// No description provided for @celebrationModeTryPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Quer tentar as perguntas desta cena em {mode}?'**
  String celebrationModeTryPrompt(String mode);

  /// No description provided for @celebrationSceneDoneIn.
  ///
  /// In pt, this message translates to:
  /// **'Cena concluída em {mode}'**
  String celebrationSceneDoneIn(String mode);

  /// Rótulo acima do nome do personagem quando o aluno encontra um novo selo
  ///
  /// In pt, this message translates to:
  /// **'Encontro'**
  String get celebrationSealKicker;

  /// No description provided for @celebrationStatAccuracy.
  ///
  /// In pt, this message translates to:
  /// **'Acertos'**
  String get celebrationStatAccuracy;

  /// Rótulo sob o número 1 da sequência
  ///
  /// In pt, this message translates to:
  /// **'Dia'**
  String get celebrationStatDay;

  /// Rótulo sob o número de dias da sequência (≠ 1)
  ///
  /// In pt, this message translates to:
  /// **'Dias'**
  String get celebrationStatDays;

  /// No description provided for @celebrationStatSteps.
  ///
  /// In pt, this message translates to:
  /// **'Passos'**
  String get celebrationStatSteps;

  /// No description provided for @celebrationStreakPlusDay.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{+1 dia · sequência de 1 dia} other{+1 dia · sequência de {count} dias}}'**
  String celebrationStreakPlusDay(int count);

  /// No description provided for @celebrationStreakStarted.
  ///
  /// In pt, this message translates to:
  /// **'Sua sequência começou hoje.'**
  String get celebrationStreakStarted;

  /// No description provided for @celebrationTomorrowKicker.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã'**
  String get celebrationTomorrowKicker;

  /// No description provided for @chestBencaoMessage.
  ///
  /// In pt, this message translates to:
  /// **'\"O Senhor te abençoe e te guarde\" — Números 6:24.'**
  String get chestBencaoMessage;

  /// No description provided for @chestBencaoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bênção rara'**
  String get chestBencaoTitle;

  /// No description provided for @chestDailyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Baú do dia'**
  String get chestDailyTitle;

  /// No description provided for @chestGraoMessage.
  ///
  /// In pt, this message translates to:
  /// **'Pequeno hoje, semente de algo maior amanhã.'**
  String get chestGraoMessage;

  /// No description provided for @chestGraoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Grão de trigo'**
  String get chestGraoTitle;

  /// No description provided for @chestGuardadaMessage.
  ///
  /// In pt, this message translates to:
  /// **'Este momento vale um versículo guardado no coração hoje.'**
  String get chestGuardadaMessage;

  /// No description provided for @chestGuardadaTitle.
  ///
  /// In pt, this message translates to:
  /// **'Palavra guardada'**
  String get chestGuardadaTitle;

  /// No description provided for @chestLampadaMessage.
  ///
  /// In pt, this message translates to:
  /// **'\"Lâmpada para os meus pés é a tua palavra\" — Salmos 119:105.'**
  String get chestLampadaMessage;

  /// No description provided for @chestLampadaTitle.
  ///
  /// In pt, this message translates to:
  /// **'Lâmpada acesa'**
  String get chestLampadaTitle;

  /// No description provided for @chestLocked.
  ///
  /// In pt, this message translates to:
  /// **'Complete a cena de hoje para abrir'**
  String get chestLocked;

  /// No description provided for @chestLockedShort.
  ///
  /// In pt, this message translates to:
  /// **'Trancado'**
  String get chestLockedShort;

  /// No description provided for @chestMapaMessage.
  ///
  /// In pt, this message translates to:
  /// **'Uma curiosidade guardada: cada capítulo lido soma na sua trilha.'**
  String get chestMapaMessage;

  /// No description provided for @chestMapaTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mapa do dia'**
  String get chestMapaTitle;

  /// No description provided for @chestOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abrir o baú'**
  String get chestOpen;

  /// No description provided for @chestOpenShort.
  ///
  /// In pt, this message translates to:
  /// **'Abrir'**
  String get chestOpenShort;

  /// No description provided for @chestOpened.
  ///
  /// In pt, this message translates to:
  /// **'Aberto'**
  String get chestOpened;

  /// No description provided for @chestOpening.
  ///
  /// In pt, this message translates to:
  /// **'Abrindo…'**
  String get chestOpening;

  /// No description provided for @chestPassoMessage.
  ///
  /// In pt, this message translates to:
  /// **'Mais um dia caminhando — é isso que forma um peregrino.'**
  String get chestPassoMessage;

  /// No description provided for @chestPassoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Passo firme'**
  String get chestPassoTitle;

  /// No description provided for @chestReady.
  ///
  /// In pt, this message translates to:
  /// **'Sua recompensa de hoje está pronta'**
  String get chestReady;

  /// No description provided for @chestReadyShort.
  ///
  /// In pt, this message translates to:
  /// **'Pronto para abrir'**
  String get chestReadyShort;

  /// No description provided for @chestRevealStarts.
  ///
  /// In pt, this message translates to:
  /// **'A revelação começa agora.'**
  String get chestRevealStarts;

  /// No description provided for @chestRewards.
  ///
  /// In pt, this message translates to:
  /// **'Recompensas'**
  String get chestRewards;

  /// No description provided for @chestSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'A sequência de hoje guarda uma recompensa.'**
  String get chestSheetTitle;

  /// No description provided for @chestTierToday.
  ///
  /// In pt, this message translates to:
  /// **'{tier} de hoje'**
  String chestTierToday(String tier);

  /// No description provided for @chestVeryRare.
  ///
  /// In pt, this message translates to:
  /// **'Raríssimo'**
  String get chestVeryRare;

  /// No description provided for @chestVozMessage.
  ///
  /// In pt, this message translates to:
  /// **'Sua sequência já fala mais alto que qualquer palavra.'**
  String get chestVozMessage;

  /// No description provided for @chestVozTitle.
  ///
  /// In pt, this message translates to:
  /// **'Voz da caravana'**
  String get chestVozTitle;

  /// No description provided for @comebackEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'O peregrino'**
  String get comebackEyebrow;

  /// No description provided for @comebackSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'{name}, a trilha espera você. Uma cena retoma a sequência e rende +{bonus} passos de boas-vindas.'**
  String comebackSubtitle(String name, int bonus);

  /// No description provided for @comebackSubtitleGap.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{{name}, faz 1 dia sem uma cena. Uma só basta — e você ganha +{bonus} passos de boas-vindas.} other{{name}, faz {count} dias sem uma cena. Uma só basta — e você ganha +{bonus} passos de boas-vindas.}}'**
  String comebackSubtitleGap(String name, int count, int bonus);

  /// No description provided for @comebackTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua sequência te espera'**
  String get comebackTitle;

  /// No description provided for @commonActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get commonActive;

  /// No description provided for @commonBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get commonClose;

  /// No description provided for @commonCollect.
  ///
  /// In pt, this message translates to:
  /// **'Coletar'**
  String get commonCollect;

  /// No description provided for @commonComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Em breve'**
  String get commonComingSoon;

  /// No description provided for @commonContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @commonDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia} other{{count} dias}}'**
  String commonDays(int count);

  /// No description provided for @commonGotIt.
  ///
  /// In pt, this message translates to:
  /// **'Entendi'**
  String get commonGotIt;

  /// No description provided for @commonModule.
  ///
  /// In pt, this message translates to:
  /// **'Módulo'**
  String get commonModule;

  /// No description provided for @commonNextScene.
  ///
  /// In pt, this message translates to:
  /// **'Próxima cena'**
  String get commonNextScene;

  /// No description provided for @commonNotNow.
  ///
  /// In pt, this message translates to:
  /// **'Agora não'**
  String get commonNotNow;

  /// No description provided for @commonOff.
  ///
  /// In pt, this message translates to:
  /// **'Desligado'**
  String get commonOff;

  /// No description provided for @commonPlusSteps.
  ///
  /// In pt, this message translates to:
  /// **'+{count} passos'**
  String commonPlusSteps(int count);

  /// No description provided for @commonSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get commonSave;

  /// No description provided for @commonScene.
  ///
  /// In pt, this message translates to:
  /// **'Cena'**
  String get commonScene;

  /// No description provided for @commonScenes.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 cena} other{{count} cenas}}'**
  String commonScenes(int count);

  /// No description provided for @commonSendWhatsApp.
  ///
  /// In pt, this message translates to:
  /// **'Mandar no WhatsApp'**
  String get commonSendWhatsApp;

  /// No description provided for @commonShare.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get commonShare;

  /// No description provided for @commonSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get commonSkip;

  /// No description provided for @commonStart.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get commonStart;

  /// No description provided for @commonSteps.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 passo} other{{count} passos}}'**
  String commonSteps(int count);

  /// No description provided for @commonToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get commonToday;

  /// No description provided for @commonTrail.
  ///
  /// In pt, this message translates to:
  /// **'Trilha'**
  String get commonTrail;

  /// No description provided for @commonTryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get commonTryAgain;

  /// No description provided for @commonYou.
  ///
  /// In pt, this message translates to:
  /// **'Você'**
  String get commonYou;

  /// No description provided for @companionAwaitingCode.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando alguém entrar com o código'**
  String get companionAwaitingCode;

  /// No description provided for @companionDaysTogether.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia caminhando juntos} other{{count} dias caminhando juntos}}'**
  String companionDaysTogether(int count);

  /// No description provided for @companionDaysWithoutStudy.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia pra trás na caminhada} other{{count} dias pra trás na caminhada}}'**
  String companionDaysWithoutStudy(int count);

  /// No description provided for @companionDelayDustyHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Sua falta na trilha'**
  String get companionDelayDustyHeadline;

  /// No description provided for @companionDelayDustyInsight.
  ///
  /// In pt, this message translates to:
  /// **'A poeira já cobriu o caminho'**
  String get companionDelayDustyInsight;

  /// No description provided for @companionDelayFreshHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Ficando para trás'**
  String get companionDelayFreshHeadline;

  /// No description provided for @companionDelayFreshInsight.
  ///
  /// In pt, this message translates to:
  /// **'Está ficando para trás na nossa caminhada'**
  String get companionDelayFreshInsight;

  /// No description provided for @companionDelayLostHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Ainda tem lugar ao meu lado'**
  String get companionDelayLostHeadline;

  /// No description provided for @companionDelayLostInsight.
  ///
  /// In pt, this message translates to:
  /// **'Mas dá para retomar nossa caminhada'**
  String get companionDelayLostInsight;

  /// No description provided for @companionErrorAlreadyHave.
  ///
  /// In pt, this message translates to:
  /// **'Você já tem uma companhia.'**
  String get companionErrorAlreadyHave;

  /// No description provided for @companionErrorCreateInvite.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível criar o convite.'**
  String get companionErrorCreateInvite;

  /// No description provided for @companionErrorInvalidCode.
  ///
  /// In pt, this message translates to:
  /// **'Código inválido ou companhia já está completa.'**
  String get companionErrorInvalidCode;

  /// No description provided for @companionErrorSignInCreate.
  ///
  /// In pt, this message translates to:
  /// **'Entre com Google para criar uma companhia.'**
  String get companionErrorSignInCreate;

  /// No description provided for @companionErrorSignInJoin.
  ///
  /// In pt, this message translates to:
  /// **'Entre com Google para entrar numa companhia.'**
  String get companionErrorSignInJoin;

  /// No description provided for @companionErrorSignInWave.
  ///
  /// In pt, this message translates to:
  /// **'Entre na conta para acenar no app.'**
  String get companionErrorSignInWave;

  /// No description provided for @companionErrorWave.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar o aceno.'**
  String get companionErrorWave;

  /// No description provided for @companionFallbackName.
  ///
  /// In pt, this message translates to:
  /// **'Companheiro'**
  String get companionFallbackName;

  /// No description provided for @companionNextStepTogether.
  ///
  /// In pt, this message translates to:
  /// **'Vamos dar o próximo passo juntos?'**
  String get companionNextStepTogether;

  /// No description provided for @companionPartnerAway.
  ///
  /// In pt, this message translates to:
  /// **'{days, plural, =1{Faz 1 dia sem estudar — a trilha sente falta de {name}} other{Faz {days} dias sem estudar — a trilha sente falta de {name}}}'**
  String companionPartnerAway(String name, int days);

  /// No description provided for @companionPartnerAwayAfterStep.
  ///
  /// In pt, this message translates to:
  /// **'Você já deu o passo — {name} está a {days, plural, =1{1 dia} other{{days} dias}} atrás'**
  String companionPartnerAwayAfterStep(String name, int days);

  /// No description provided for @companionPartnerNotYet.
  ///
  /// In pt, this message translates to:
  /// **'Você já deu o passo — {name} ainda não apareceu'**
  String companionPartnerNotYet(String name);

  /// No description provided for @companionPresetComeBack.
  ///
  /// In pt, this message translates to:
  /// **'Tô te esperando pra limpar a trilha'**
  String get companionPresetComeBack;

  /// No description provided for @companionPresetMissed.
  ///
  /// In pt, this message translates to:
  /// **'Senti sua falta na trilha'**
  String get companionPresetMissed;

  /// No description provided for @companionPresetOnTrail.
  ///
  /// In pt, this message translates to:
  /// **'Tô te esperando na trilha'**
  String get companionPresetOnTrail;

  /// No description provided for @companionPresetResume.
  ///
  /// In pt, this message translates to:
  /// **'Dá pra retomar — tô aqui'**
  String get companionPresetResume;

  /// No description provided for @companionPresetStepCome.
  ///
  /// In pt, this message translates to:
  /// **'Dei meu passo hoje. Vem?'**
  String get companionPresetStepCome;

  /// No description provided for @companionPresetWalkToday.
  ///
  /// In pt, this message translates to:
  /// **'Vamos caminhar juntos hoje'**
  String get companionPresetWalkToday;

  /// No description provided for @companionPresetYoursNext.
  ///
  /// In pt, this message translates to:
  /// **'Já dei meu passo — falta o seu'**
  String get companionPresetYoursNext;

  /// No description provided for @companionShareDefault.
  ///
  /// In pt, this message translates to:
  /// **'Oi {name} 👋\nJá dei meus passos de hoje no Stway — tô te esperando!\nVem?'**
  String companionShareDefault(String name);

  /// No description provided for @companionShareDusty.
  ///
  /// In pt, this message translates to:
  /// **'Oi {name} 👋\nFaz {days} dias que a gente não caminha juntos no Stway.\nO caminho continua aberto — tô te esperando!\nVem?'**
  String companionShareDusty(String name, int days);

  /// No description provided for @companionShareFallbackName.
  ///
  /// In pt, this message translates to:
  /// **'você'**
  String get companionShareFallbackName;

  /// No description provided for @companionShareFresh.
  ///
  /// In pt, this message translates to:
  /// **'Oi {name} 👋\nSenti sua falta na nossa caminhada no Stway.\nJá dei meus passos de hoje e tô te esperando!\nVem?'**
  String companionShareFresh(String name);

  /// No description provided for @companionShareLost.
  ///
  /// In pt, this message translates to:
  /// **'Oi {name} 👋\nAinda tem lugar ao meu lado!\nFaz {days} dias que a gente não caminha juntos no Stway.\n\nMas dá pra retomar — já dei meus passos de hoje.\nVem?'**
  String companionShareLost(String name, int days);

  /// No description provided for @companionSheetEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Companhia'**
  String get companionSheetEyebrow;

  /// No description provided for @companionSheetFormedBody.
  ///
  /// In pt, this message translates to:
  /// **'Vocês caminham juntos agora.\nFechem os 7 dias da semana: +{steps} passos na jornada para os dois.'**
  String companionSheetFormedBody(int steps);

  /// No description provided for @companionSheetFormedBodyNamed.
  ///
  /// In pt, this message translates to:
  /// **'Agora você e {name} caminham juntos.\nFechem os 7 dias da semana: +{steps} passos na jornada para os dois.'**
  String companionSheetFormedBodyNamed(String name, int steps);

  /// No description provided for @companionSheetFormedCta.
  ///
  /// In pt, this message translates to:
  /// **'Caminhar juntos'**
  String get companionSheetFormedCta;

  /// No description provided for @companionSheetFormedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Companhia formada'**
  String get companionSheetFormedTitle;

  /// No description provided for @companionSheetInviteConfirmSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Alguém te chamou para caminhar junto.\nUm toque — sem digitar código.'**
  String get companionSheetInviteConfirmSubtitle;

  /// No description provided for @companionSheetInviteConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Convite de companhia'**
  String get companionSheetInviteConfirmTitle;

  /// No description provided for @companionSheetInviteCta.
  ///
  /// In pt, this message translates to:
  /// **'Chamar um companheiro'**
  String get companionSheetInviteCta;

  /// No description provided for @companionSheetPromptBody.
  ///
  /// In pt, this message translates to:
  /// **'Um companheiro. Fechem os 7 dias da semana juntos — os dois ganham +{steps} passos na jornada.'**
  String companionSheetPromptBody(int steps);

  /// No description provided for @companionSheetPromptBodyTomorrow.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã: {scene}. Chame alguém para chegar junto.'**
  String companionSheetPromptBodyTomorrow(String scene);

  /// No description provided for @companionSheetPromptTitle.
  ///
  /// In pt, this message translates to:
  /// **'Chame alguém para caminhar'**
  String get companionSheetPromptTitle;

  /// No description provided for @companionWalkedTogetherToday.
  ///
  /// In pt, this message translates to:
  /// **'Vocês caminharam juntos hoje'**
  String get companionWalkedTogetherToday;

  /// No description provided for @companionWaveFor.
  ///
  /// In pt, this message translates to:
  /// **'Você já deu o passo — acene para {name}'**
  String companionWaveFor(String name);

  /// No description provided for @companionWeekClosed.
  ///
  /// In pt, this message translates to:
  /// **'Semana fechada juntos'**
  String get companionWeekClosed;

  /// No description provided for @companionWeekDays.
  ///
  /// In pt, this message translates to:
  /// **'{count} de 7 dias juntos nesta semana'**
  String companionWeekDays(int count);

  /// No description provided for @companionYourTurn.
  ///
  /// In pt, this message translates to:
  /// **'{name} já caminhou — sua vez'**
  String companionYourTurn(String name);

  /// No description provided for @cornerAcceptedBy.
  ///
  /// In pt, this message translates to:
  /// **'{name} aceitou o desafio'**
  String cornerAcceptedBy(String name);

  /// No description provided for @cornerActionFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir. Tente de novo.'**
  String get cornerActionFailed;

  /// No description provided for @cornerArrivedMark.
  ///
  /// In pt, this message translates to:
  /// **'Chegou'**
  String get cornerArrivedMark;

  /// No description provided for @cornerBoardEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Na caravana, abra alguém na mesma cena e chame para o desafio. Quem chega até domingo ganha +{count} passos.'**
  String cornerBoardEmptyBody(int count);

  /// No description provided for @cornerBoardEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum desafio ainda'**
  String get cornerBoardEmptyTitle;

  /// No description provided for @cornerBoardFilterEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum ainda'**
  String get cornerBoardFilterEmpty;

  /// No description provided for @cornerBoardIdle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum desafio nesta semana. Chame alguém da caravana.'**
  String get cornerBoardIdle;

  /// No description provided for @cornerBoardOpenCaravan.
  ///
  /// In pt, this message translates to:
  /// **'Ver a caravana'**
  String get cornerBoardOpenCaravan;

  /// No description provided for @cornerBurstAccepted.
  ///
  /// In pt, this message translates to:
  /// **'Desafio aceito'**
  String get cornerBurstAccepted;

  /// No description provided for @cornerBurstLeft.
  ///
  /// In pt, this message translates to:
  /// **'Você saiu do desafio'**
  String get cornerBurstLeft;

  /// No description provided for @cornerBurstSent.
  ///
  /// In pt, this message translates to:
  /// **'Convite enviado'**
  String get cornerBurstSent;

  /// No description provided for @cornerBusyAccept.
  ///
  /// In pt, this message translates to:
  /// **'Você já tem um desafio. Chegue ou saia dele para aceitar.'**
  String get cornerBusyAccept;

  /// No description provided for @cornerBusyWeek.
  ///
  /// In pt, this message translates to:
  /// **'Você já tem um desafio nesta semana.'**
  String get cornerBusyWeek;

  /// No description provided for @cornerCancelled.
  ///
  /// In pt, this message translates to:
  /// **'Desafio cancelado'**
  String get cornerCancelled;

  /// No description provided for @cornerChallengeWith.
  ///
  /// In pt, this message translates to:
  /// **'Desafio com {name}'**
  String cornerChallengeWith(String name);

  /// No description provided for @cornerClosedChapter.
  ///
  /// In pt, this message translates to:
  /// **'Encerrados'**
  String get cornerClosedChapter;

  /// No description provided for @cornerClosesToday.
  ///
  /// In pt, this message translates to:
  /// **'Fecha hoje'**
  String get cornerClosesToday;

  /// No description provided for @cornerCtaInvite.
  ///
  /// In pt, this message translates to:
  /// **'Chamar para o desafio'**
  String get cornerCtaInvite;

  /// No description provided for @cornerDaysLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 dia} other{Faltam {count} dias}}'**
  String cornerDaysLeft(int count);

  /// No description provided for @cornerDeadline.
  ///
  /// In pt, this message translates to:
  /// **'Até domingo.'**
  String get cornerDeadline;

  /// No description provided for @cornerDeclinedAnon.
  ///
  /// In pt, this message translates to:
  /// **'O convite não foi aceito.'**
  String get cornerDeclinedAnon;

  /// No description provided for @cornerDeclinedBy.
  ///
  /// In pt, this message translates to:
  /// **'{name} não aceitou desta vez.'**
  String cornerDeclinedBy(String name);

  /// No description provided for @cornerDifferentScene.
  ///
  /// In pt, this message translates to:
  /// **'Vocês não estão na mesma cena.'**
  String get cornerDifferentScene;

  /// No description provided for @cornerDifferentTrail.
  ///
  /// In pt, this message translates to:
  /// **'Vocês não estão na mesma trilha.'**
  String get cornerDifferentTrail;

  /// No description provided for @cornerHoldAccept.
  ///
  /// In pt, this message translates to:
  /// **'Segure para aceitar'**
  String get cornerHoldAccept;

  /// No description provided for @cornerHoldInvite.
  ///
  /// In pt, this message translates to:
  /// **'Segure para chamar'**
  String get cornerHoldInvite;

  /// No description provided for @cornerIncomingFrom.
  ///
  /// In pt, this message translates to:
  /// **'{name} te chamou para esta cena.'**
  String cornerIncomingFrom(String name);

  /// No description provided for @cornerIncomingFromAnon.
  ///
  /// In pt, this message translates to:
  /// **'Alguém te chamou para esta cena.'**
  String get cornerIncomingFromAnon;

  /// No description provided for @cornerIncomingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Convite de desafio'**
  String get cornerIncomingTitle;

  /// No description provided for @cornerInviteBody.
  ///
  /// In pt, this message translates to:
  /// **'Você e {name} fazem essa cena até domingo.\n+{count} passos para cada um que chegar.'**
  String cornerInviteBody(String name, int count);

  /// No description provided for @cornerInviteBodyAnon.
  ///
  /// In pt, this message translates to:
  /// **'A mesma cena até domingo.\n+{count} passos para cada um que chegar.'**
  String cornerInviteBodyAnon(int count);

  /// No description provided for @cornerInviteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desafio: {mission}'**
  String cornerInviteTitle(String mission);

  /// No description provided for @cornerKicker.
  ///
  /// In pt, this message translates to:
  /// **'Desafio'**
  String get cornerKicker;

  /// No description provided for @cornerLeftMark.
  ///
  /// In pt, this message translates to:
  /// **'Saiu'**
  String get cornerLeftMark;

  /// No description provided for @cornerNeedsCloud.
  ///
  /// In pt, this message translates to:
  /// **'Entre com Google para chamar alguém.'**
  String get cornerNeedsCloud;

  /// No description provided for @cornerNoCorner.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma cena em comum para o desafio.'**
  String get cornerNoCorner;

  /// No description provided for @cornerNoneHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Ninguém chegou desta vez'**
  String get cornerNoneHeadline;

  /// No description provided for @cornerNoneLine.
  ///
  /// In pt, this message translates to:
  /// **'O desafio fechou no domingo.'**
  String get cornerNoneLine;

  /// No description provided for @cornerOnTheWay.
  ///
  /// In pt, this message translates to:
  /// **'A caminho'**
  String get cornerOnTheWay;

  /// No description provided for @cornerOtherPerson.
  ///
  /// In pt, this message translates to:
  /// **'A outra pessoa'**
  String get cornerOtherPerson;

  /// No description provided for @cornerOtherPersonLower.
  ///
  /// In pt, this message translates to:
  /// **'a outra pessoa'**
  String get cornerOtherPersonLower;

  /// No description provided for @cornerRecordArrived.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 completa} other{{count} completas}}'**
  String cornerRecordArrived(int count);

  /// No description provided for @cornerRecordChapter.
  ///
  /// In pt, this message translates to:
  /// **'Desafios'**
  String get cornerRecordChapter;

  /// No description provided for @cornerRecordTogether.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 junto} other{{count} juntos}}'**
  String cornerRecordTogether(int count);

  /// No description provided for @cornerResultLeft.
  ///
  /// In pt, this message translates to:
  /// **'Você saiu · sem os +{count} passos'**
  String cornerResultLeft(int count);

  /// No description provided for @cornerResultNone.
  ///
  /// In pt, this message translates to:
  /// **'Com {name} · ninguém chegou'**
  String cornerResultNone(String name);

  /// No description provided for @cornerResultTheyArrived.
  ///
  /// In pt, this message translates to:
  /// **'{name} chegou · você não chegou'**
  String cornerResultTheyArrived(String name);

  /// No description provided for @cornerResultTheyLeftMissed.
  ///
  /// In pt, this message translates to:
  /// **'{name} saiu · você não chegou'**
  String cornerResultTheyLeftMissed(String name);

  /// No description provided for @cornerResultTogether.
  ///
  /// In pt, this message translates to:
  /// **'Com {name} · os dois chegaram'**
  String cornerResultTogether(String name);

  /// No description provided for @cornerResultWon.
  ///
  /// In pt, this message translates to:
  /// **'Com {name} · +{count} passos'**
  String cornerResultWon(String name, int count);

  /// No description provided for @cornerSameStretch.
  ///
  /// In pt, this message translates to:
  /// **'A mesma cena até domingo. +{count} passos para cada um que chegar.'**
  String cornerSameStretch(int count);

  /// No description provided for @cornerSendFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar o convite. Tente de novo.'**
  String get cornerSendFailed;

  /// No description provided for @cornerSomeone.
  ///
  /// In pt, this message translates to:
  /// **'Alguém'**
  String get cornerSomeone;

  /// No description provided for @cornerStripIdle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum nesta semana'**
  String get cornerStripIdle;

  /// No description provided for @cornerStripInvitedYou.
  ///
  /// In pt, this message translates to:
  /// **'{name} te chamou'**
  String cornerStripInvitedYou(String name);

  /// No description provided for @cornerStripLost.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, other{{count} perdeu}}'**
  String cornerStripLost(int count);

  /// No description provided for @cornerStripWaiting.
  ///
  /// In pt, this message translates to:
  /// **'Esperando {name}'**
  String cornerStripWaiting(String name);

  /// No description provided for @cornerStripWon.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, other{{count} ganhou}}'**
  String cornerStripWon(int count);

  /// No description provided for @cornerTallyLost.
  ///
  /// In pt, this message translates to:
  /// **'Perdeu'**
  String get cornerTallyLost;

  /// No description provided for @cornerTallyTogether.
  ///
  /// In pt, this message translates to:
  /// **'Juntos'**
  String get cornerTallyTogether;

  /// No description provided for @cornerTallyWon.
  ///
  /// In pt, this message translates to:
  /// **'Ganhou'**
  String get cornerTallyWon;

  /// No description provided for @cornerTheyAhead.
  ///
  /// In pt, this message translates to:
  /// **'{name} já chegou. Falta você.'**
  String cornerTheyAhead(String name);

  /// No description provided for @cornerTheyArrived.
  ///
  /// In pt, this message translates to:
  /// **'{name} chegou'**
  String cornerTheyArrived(String name);

  /// No description provided for @cornerTheyLeft.
  ///
  /// In pt, this message translates to:
  /// **'{name} saiu. Você ainda pode chegar.'**
  String cornerTheyLeft(String name);

  /// No description provided for @cornerTheyLeftClosed.
  ///
  /// In pt, this message translates to:
  /// **'{name} saiu do desafio.'**
  String cornerTheyLeftClosed(String name);

  /// No description provided for @cornerTogether.
  ///
  /// In pt, this message translates to:
  /// **'Chegaram juntos'**
  String get cornerTogether;

  /// No description provided for @cornerTogetherLine.
  ///
  /// In pt, this message translates to:
  /// **'Os dois fizeram a cena a tempo.'**
  String get cornerTogetherLine;

  /// No description provided for @cornerWaitingArrival.
  ///
  /// In pt, this message translates to:
  /// **'Você chegou · esperando {name}.'**
  String cornerWaitingArrival(String name);

  /// No description provided for @cornerWaitingOn.
  ///
  /// In pt, this message translates to:
  /// **'Esperando {name} aceitar.'**
  String cornerWaitingOn(String name);

  /// No description provided for @cornerWaitingOnAnon.
  ///
  /// In pt, this message translates to:
  /// **'Esperando o aceite.'**
  String get cornerWaitingOnAnon;

  /// No description provided for @cornerWalk.
  ///
  /// In pt, this message translates to:
  /// **'Fazer a cena'**
  String get cornerWalk;

  /// No description provided for @cornerWhisperEach.
  ///
  /// In pt, this message translates to:
  /// **'Cada cena feita conta.'**
  String get cornerWhisperEach;

  /// No description provided for @cornerWhisperTogether.
  ///
  /// In pt, this message translates to:
  /// **'Cenas feitas lado a lado.'**
  String get cornerWhisperTogether;

  /// No description provided for @cornerWithPeer.
  ///
  /// In pt, this message translates to:
  /// **'Com {name} · até domingo'**
  String cornerWithPeer(String name);

  /// No description provided for @cornerWithdraw.
  ///
  /// In pt, this message translates to:
  /// **'Sair do desafio'**
  String get cornerWithdraw;

  /// No description provided for @cornerWithdrawBody.
  ///
  /// In pt, this message translates to:
  /// **'{name} continua e ainda pode chegar. Você fica sem os +{count} passos.'**
  String cornerWithdrawBody(String name, int count);

  /// No description provided for @cornerWithdrawConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get cornerWithdrawConfirm;

  /// No description provided for @cornerWithdrawPending.
  ///
  /// In pt, this message translates to:
  /// **'O convite some para {name}.'**
  String cornerWithdrawPending(String name);

  /// No description provided for @cornerWithdrawTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair do desafio?'**
  String get cornerWithdrawTitle;

  /// No description provided for @cornerYouArrived.
  ///
  /// In pt, this message translates to:
  /// **'Você chegou'**
  String get cornerYouArrived;

  /// No description provided for @cornerYouLeft.
  ///
  /// In pt, this message translates to:
  /// **'Você saiu do desafio.'**
  String get cornerYouLeft;

  /// Selo da cena-chefe (boss) na celebração
  ///
  /// In pt, this message translates to:
  /// **'Travessia'**
  String get crossingChip;

  /// No description provided for @dustAwayManyFreeze.
  ///
  /// In pt, this message translates to:
  /// **'{name}, {daysAway, plural, =1{1 dia sem caminhar} other{{daysAway} dias sem caminhar}}. O gelo ainda cobre 1 falta — retome a caminhada.'**
  String dustAwayManyFreeze(String name, int daysAway);

  /// No description provided for @dustAwayManyNoFreeze.
  ///
  /// In pt, this message translates to:
  /// **'{name}, {daysAway, plural, =1{1 dia sem caminhar} other{{daysAway} dias sem caminhar}}. Uma cena recomeça o caminho.'**
  String dustAwayManyNoFreeze(String name, int daysAway);

  /// No description provided for @dustAwayNoStreak.
  ///
  /// In pt, this message translates to:
  /// **'{name}, a trilha espera. Uma cena basta para retomar o caminho.'**
  String dustAwayNoStreak(String name);

  /// No description provided for @dustAwayStreak.
  ///
  /// In pt, this message translates to:
  /// **'{name}, {streak, plural, =1{1 dia de sequência espera} other{{streak} dias de sequência esperam}}. Uma cena e você retoma.'**
  String dustAwayStreak(String name, int streak);

  /// No description provided for @dustAwayTwoFreeze.
  ///
  /// In pt, this message translates to:
  /// **'{name}, dois dias sem caminhar. O gelo ainda pode salvar 1 dia — volte hoje.'**
  String dustAwayTwoFreeze(String name);

  /// No description provided for @dustAwayTwoNoFreeze.
  ///
  /// In pt, this message translates to:
  /// **'{name}, dois dias sem caminhar. Uma cena e você volta ao caminho.'**
  String dustAwayTwoNoFreeze(String name);

  /// No description provided for @dustCanReturn.
  ///
  /// In pt, this message translates to:
  /// **'Dá para voltar'**
  String get dustCanReturn;

  /// No description provided for @dustComeBackToday.
  ///
  /// In pt, this message translates to:
  /// **'Volte hoje'**
  String get dustComeBackToday;

  /// No description provided for @dustContinueWhere.
  ///
  /// In pt, this message translates to:
  /// **'Continue de onde parou'**
  String get dustContinueWhere;

  /// No description provided for @dustDayEnding.
  ///
  /// In pt, this message translates to:
  /// **'O dia está acabando'**
  String get dustDayEnding;

  /// No description provided for @dustEveningFreeze1.
  ///
  /// In pt, this message translates to:
  /// **'{name}, o dia fecha. Faltam {countdown} — caminhe, ou o gelo cobre 1 dia.'**
  String dustEveningFreeze1(String name, String countdown);

  /// No description provided for @dustEveningFreeze2.
  ///
  /// In pt, this message translates to:
  /// **'Últimas {countdown}. Continue a caminhada — o gelo ainda cobre 1 dia.'**
  String dustEveningFreeze2(String countdown);

  /// No description provided for @dustEveningNoFreeze2.
  ///
  /// In pt, this message translates to:
  /// **'Noite fechando. Faltam {countdown} — continue a caminhada agora.'**
  String dustEveningNoFreeze2(String countdown);

  /// No description provided for @dustFewHours.
  ///
  /// In pt, this message translates to:
  /// **'Poucas horas'**
  String get dustFewHours;

  /// No description provided for @dustHeroGapFreeze.
  ///
  /// In pt, this message translates to:
  /// **'Ontem ficou vazio. Faça a cena hoje — o gelo ainda salva 1 dia.'**
  String get dustHeroGapFreeze;

  /// No description provided for @dustHeroGapNoFreeze.
  ///
  /// In pt, this message translates to:
  /// **'Ontem ficou vazio. Faça a cena hoje para não perder a sequência.'**
  String get dustHeroGapNoFreeze;

  /// No description provided for @dustHeroRiskFreeze.
  ///
  /// In pt, this message translates to:
  /// **'{streak, plural, =0{Faltam {countdown} para a sequência cair. Faça a cena hoje — o gelo ainda salva 1 dia.} =1{Faltam {countdown} para a sequência cair. Faça a cena hoje — o gelo ainda salva 1 dia.} other{Faltam {countdown} para a sequência de {streak} dias cair. Faça a cena hoje — o gelo ainda salva 1 dia.}}'**
  String dustHeroRiskFreeze(int streak, String countdown);

  /// No description provided for @dustHeroRiskNoFreeze.
  ///
  /// In pt, this message translates to:
  /// **'{streak, plural, =0{Faltam {countdown} para a sequência cair. Faça a cena hoje.} =1{Faltam {countdown} para a sequência cair. Faça a cena hoje.} other{Faltam {countdown} para a sequência de {streak} dias cair. Faça a cena hoje.}}'**
  String dustHeroRiskNoFreeze(int streak, String countdown);

  /// No description provided for @dustNextSceneWaits.
  ///
  /// In pt, this message translates to:
  /// **'A próxima cena espera'**
  String get dustNextSceneWaits;

  /// No description provided for @dustOneDay.
  ///
  /// In pt, this message translates to:
  /// **'Um dia'**
  String get dustOneDay;

  /// No description provided for @dustRiskBodyFreeze1.
  ///
  /// In pt, this message translates to:
  /// **'{name} · faltam {countdown}. Uma cena protege a sequência — o gelo cobre 1 dia.'**
  String dustRiskBodyFreeze1(String name, String countdown);

  /// No description provided for @dustRiskBodyFreeze3.
  ///
  /// In pt, this message translates to:
  /// **'Faltam {countdown}. Continue a caminhada — o gelo cobre 1 dia.'**
  String dustRiskBodyFreeze3(String countdown);

  /// No description provided for @dustRiskBodyNoFreeze1.
  ///
  /// In pt, this message translates to:
  /// **'{name} · sem gelo. Faltam {countdown}. Uma cena e você fica.'**
  String dustRiskBodyNoFreeze1(String name, String countdown);

  /// No description provided for @dustRiskBodyNoFreeze2.
  ///
  /// In pt, this message translates to:
  /// **'{streak, plural, =1{1 dia em risco. Faltam {countdown} — caminhe agora.} other{{streak} dias em risco. Faltam {countdown} — caminhe agora.}}'**
  String dustRiskBodyNoFreeze2(int streak, String countdown);

  /// No description provided for @dustRiskBodyNoFreeze3.
  ///
  /// In pt, this message translates to:
  /// **'Sem gelo. Faltam {countdown} — caminhe agora.'**
  String dustRiskBodyNoFreeze3(String countdown);

  /// No description provided for @dustRiskBodyStreak.
  ///
  /// In pt, this message translates to:
  /// **'{streak, plural, =1{Sequência de 1 dia ainda em jogo. Faltam {countdown}.} other{Sequência de {streak} dias ainda em jogo. Faltam {countdown}.}}'**
  String dustRiskBodyStreak(int streak, String countdown);

  /// No description provided for @dustSceneToday.
  ///
  /// In pt, this message translates to:
  /// **'Uma cena hoje'**
  String get dustSceneToday;

  /// No description provided for @dustSceneTodayWaits.
  ///
  /// In pt, this message translates to:
  /// **'A cena de hoje espera'**
  String get dustSceneTodayWaits;

  /// No description provided for @dustSceneWaits.
  ///
  /// In pt, this message translates to:
  /// **'A cena espera'**
  String get dustSceneWaits;

  /// No description provided for @dustStillTime.
  ///
  /// In pt, this message translates to:
  /// **'Ainda dá tempo'**
  String get dustStillTime;

  /// No description provided for @dustStreakWaits.
  ///
  /// In pt, this message translates to:
  /// **'A sequência espera'**
  String get dustStreakWaits;

  /// No description provided for @dustTrailWaits.
  ///
  /// In pt, this message translates to:
  /// **'A trilha espera'**
  String get dustTrailWaits;

  /// No description provided for @dustTwoDays.
  ///
  /// In pt, this message translates to:
  /// **'Dois dias'**
  String get dustTwoDays;

  /// No description provided for @dustUiDetail2.
  ///
  /// In pt, this message translates to:
  /// **'Continue a caminhada · uma cena basta'**
  String get dustUiDetail2;

  /// No description provided for @dustUiDetail3.
  ///
  /// In pt, this message translates to:
  /// **'A sequência espera · caminhe hoje'**
  String get dustUiDetail3;

  /// No description provided for @dustUiFreeze1.
  ///
  /// In pt, this message translates to:
  /// **'Sequência em risco · gelo ainda cobre 1 dia'**
  String get dustUiFreeze1;

  /// No description provided for @dustUiFreeze2.
  ///
  /// In pt, this message translates to:
  /// **'Ainda dá tempo · gelo a postos'**
  String get dustUiFreeze2;

  /// No description provided for @dustUiFreeze3.
  ///
  /// In pt, this message translates to:
  /// **'Caminhe hoje · gelo cobre 1 falta'**
  String get dustUiFreeze3;

  /// No description provided for @dustUiNoFreeze1.
  ///
  /// In pt, this message translates to:
  /// **'Sequência em risco · caminhe agora'**
  String get dustUiNoFreeze1;

  /// No description provided for @dustUiNoFreeze2.
  ///
  /// In pt, this message translates to:
  /// **'Sem gelo · uma cena protege'**
  String get dustUiNoFreeze2;

  /// No description provided for @dustUiNoFreeze3.
  ///
  /// In pt, this message translates to:
  /// **'A sequência espera · uma cena alcança'**
  String get dustUiNoFreeze3;

  /// No description provided for @entryMissionDorAnsia01CentralInsight.
  ///
  /// In pt, this message translates to:
  /// **'O tesouro puxa o coração'**
  String get entryMissionDorAnsia01CentralInsight;

  /// No description provided for @entryMissionDorAnsia01HookNote.
  ///
  /// In pt, this message translates to:
  /// **'O cuidado do Pai é o argumento contra a ansiedade — não a ausência de necessidade.'**
  String get entryMissionDorAnsia01HookNote;

  /// No description provided for @entryMissionDorAnsia01Intro.
  ///
  /// In pt, this message translates to:
  /// **'Onde está o tesouro, está o coração. Jesus une Mamom e o amanhã.'**
  String get entryMissionDorAnsia01Intro;

  /// No description provided for @entryMissionDorAnsia01Objective.
  ///
  /// In pt, this message translates to:
  /// **'Ver como Jesus liga tesouro, senhorio e ansiedade.'**
  String get entryMissionDorAnsia01Objective;

  /// No description provided for @entryMissionDorAnsia01Title.
  ///
  /// In pt, this message translates to:
  /// **'Tesouros e ansiedade'**
  String get entryMissionDorAnsia01Title;

  /// No description provided for @entryMissionDorAnsia02CentralInsight.
  ///
  /// In pt, this message translates to:
  /// **'Cristo basta na fome e na fartura'**
  String get entryMissionDorAnsia02CentralInsight;

  /// No description provided for @entryMissionDorAnsia02HookNote.
  ///
  /// In pt, this message translates to:
  /// **'O contentamento de Paulo não é estoicismo: é Cristo na fome e na fartura.'**
  String get entryMissionDorAnsia02HookNote;

  /// No description provided for @entryMissionDorAnsia02Intro.
  ///
  /// In pt, this message translates to:
  /// **'Paulo aprendeu a estar contente em toda a sorte — em Cristo.'**
  String get entryMissionDorAnsia02Intro;

  /// No description provided for @entryMissionDorAnsia02Objective.
  ///
  /// In pt, this message translates to:
  /// **'Trocar a ansiedade do ter pelo contentamento em Cristo.'**
  String get entryMissionDorAnsia02Objective;

  /// No description provided for @entryMissionDorAnsia02Title.
  ///
  /// In pt, this message translates to:
  /// **'Contentamento'**
  String get entryMissionDorAnsia02Title;

  /// No description provided for @entryMissionDorAnsia03CentralInsight.
  ///
  /// In pt, this message translates to:
  /// **'Há pastor no vale'**
  String get entryMissionDorAnsia03CentralInsight;

  /// No description provided for @entryMissionDorAnsia03HookNote.
  ///
  /// In pt, this message translates to:
  /// **'O pastor guia — inclusive no vale. O que some não é a luta; é o medo e a sensação de solidão.'**
  String get entryMissionDorAnsia03HookNote;

  /// No description provided for @entryMissionDorAnsia03Intro.
  ///
  /// In pt, this message translates to:
  /// **'Nada me faltará — o Salmo 23 é confiança, não magia.'**
  String get entryMissionDorAnsia03Intro;

  /// No description provided for @entryMissionDorAnsia03Objective.
  ///
  /// In pt, this message translates to:
  /// **'Ler o Salmo 23 como cuidado, não como amuleto.'**
  String get entryMissionDorAnsia03Objective;

  /// No description provided for @entryMissionDorAnsia03Title.
  ///
  /// In pt, this message translates to:
  /// **'O Senhor é o meu pastor'**
  String get entryMissionDorAnsia03Title;

  /// No description provided for @entryMissionDorAnsia04CentralInsight.
  ///
  /// In pt, this message translates to:
  /// **'O pão é de hoje'**
  String get entryMissionDorAnsia04CentralInsight;

  /// No description provided for @entryMissionDorAnsia04HookNote.
  ///
  /// In pt, this message translates to:
  /// **'Jesus ensina a pedir o dia — não o estoque. O Reino vem antes do pão.'**
  String get entryMissionDorAnsia04HookNote;

  /// No description provided for @entryMissionDorAnsia04Intro.
  ///
  /// In pt, this message translates to:
  /// **'Pedir o pão de cada dia é o contrário de antecipar o mês inteiro.'**
  String get entryMissionDorAnsia04Intro;

  /// No description provided for @entryMissionDorAnsia04Objective.
  ///
  /// In pt, this message translates to:
  /// **'Orar o dia, não o censo do medo.'**
  String get entryMissionDorAnsia04Objective;

  /// No description provided for @entryMissionDorAnsia04Title.
  ///
  /// In pt, this message translates to:
  /// **'Pai nosso'**
  String get entryMissionDorAnsia04Title;

  /// No description provided for @entryMissionDorAnsia05CentralInsight.
  ///
  /// In pt, this message translates to:
  /// **'A herança está guardada'**
  String get entryMissionDorAnsia05CentralInsight;

  /// No description provided for @entryMissionDorAnsia05HookNote.
  ///
  /// In pt, this message translates to:
  /// **'A esperança não nega o sofrimento. Ela o ancora na ressurreição. Continue no Sermão do Monte.'**
  String get entryMissionDorAnsia05HookNote;

  /// No description provided for @entryMissionDorAnsia05Intro.
  ///
  /// In pt, this message translates to:
  /// **'Pedro ancora sofredores numa herança guardada — depois, o cânon.'**
  String get entryMissionDorAnsia05Intro;

  /// No description provided for @entryMissionDorAnsia05Objective.
  ///
  /// In pt, this message translates to:
  /// **'Sair da trilha de dor para o currículo: Sermão do Monte.'**
  String get entryMissionDorAnsia05Objective;

  /// No description provided for @entryMissionDorAnsia05Title.
  ///
  /// In pt, this message translates to:
  /// **'Esperança viva'**
  String get entryMissionDorAnsia05Title;

  /// No description provided for @entryMissionDorRecome01CentralInsight.
  ///
  /// In pt, this message translates to:
  /// **'Deus ainda pergunta onde estás'**
  String get entryMissionDorRecome01CentralInsight;

  /// No description provided for @entryMissionDorRecome01HookNote.
  ///
  /// In pt, this message translates to:
  /// **'O primeiro movimento depois da queda é Deus procurando — não o humano se escondendo com sucesso.'**
  String get entryMissionDorRecome01HookNote;

  /// No description provided for @entryMissionDorRecome01Intro.
  ///
  /// In pt, this message translates to:
  /// **'A desconfiança rompe a comunhão — e ainda assim Deus pergunta.'**
  String get entryMissionDorRecome01Intro;

  /// No description provided for @entryMissionDorRecome01Objective.
  ///
  /// In pt, this message translates to:
  /// **'Ver a queda como ruptura, não como o fim da conversa.'**
  String get entryMissionDorRecome01Objective;

  /// No description provided for @entryMissionDorRecome01Title.
  ///
  /// In pt, this message translates to:
  /// **'A queda'**
  String get entryMissionDorRecome01Title;

  /// No description provided for @entryMissionDorRecome02CentralInsight.
  ///
  /// In pt, this message translates to:
  /// **'Há semente depois da porta'**
  String get entryMissionDorRecome02CentralInsight;

  /// No description provided for @entryMissionDorRecome02EchoQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Ele perguntou. E depois da resposta, a história acabou?'**
  String get entryMissionDorRecome02EchoQuestion;

  /// No description provided for @entryMissionDorRecome02HookNote.
  ///
  /// In pt, this message translates to:
  /// **'No mesmo capítulo da expulsão, Deus fala de uma semente. O juízo não cancela a história.'**
  String get entryMissionDorRecome02HookNote;

  /// No description provided for @entryMissionDorRecome02Intro.
  ///
  /// In pt, this message translates to:
  /// **'O pecado tem custo. A promessa não some.'**
  String get entryMissionDorRecome02Intro;

  /// No description provided for @entryMissionDorRecome02Objective.
  ///
  /// In pt, this message translates to:
  /// **'Ler consequência e promessa no mesmo texto.'**
  String get entryMissionDorRecome02Objective;

  /// No description provided for @entryMissionDorRecome02Title.
  ///
  /// In pt, this message translates to:
  /// **'Consequências'**
  String get entryMissionDorRecome02Title;

  /// No description provided for @entryMissionDorRecome03CentralInsight.
  ///
  /// In pt, this message translates to:
  /// **'Recomeçar é aliança, não apagar'**
  String get entryMissionDorRecome03CentralInsight;

  /// No description provided for @entryMissionDorRecome03EchoQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Há semente depois da porta. O mundo recomeça apagando o passado?'**
  String get entryMissionDorRecome03EchoQuestion;

  /// No description provided for @entryMissionDorRecome03HookNote.
  ///
  /// In pt, this message translates to:
  /// **'O mundo recomeça sob aliança, não sob amnésia. O arco lembra a Deus — e a nós.'**
  String get entryMissionDorRecome03HookNote;

  /// No description provided for @entryMissionDorRecome03Intro.
  ///
  /// In pt, this message translates to:
  /// **'Juízo e recomeço cabem no mesmo Deus.'**
  String get entryMissionDorRecome03Intro;

  /// No description provided for @entryMissionDorRecome03Objective.
  ///
  /// In pt, this message translates to:
  /// **'Ver o dilúvio como juízo que guarda um resto.'**
  String get entryMissionDorRecome03Objective;

  /// No description provided for @entryMissionDorRecome03Title.
  ///
  /// In pt, this message translates to:
  /// **'Dilúvio'**
  String get entryMissionDorRecome03Title;

  /// No description provided for @entryMissionDorRecome04CentralInsight.
  ///
  /// In pt, this message translates to:
  /// **'O recomeço caminha para fora'**
  String get entryMissionDorRecome04CentralInsight;

  /// No description provided for @entryMissionDorRecome04EchoQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Recomeçar é aliança. Babel se conserta com outra torre?'**
  String get entryMissionDorRecome04EchoQuestion;

  /// No description provided for @entryMissionDorRecome04HookNote.
  ///
  /// In pt, this message translates to:
  /// **'Deus não conserta Babel com outra torre. Chama uma família para ser bênção.'**
  String get entryMissionDorRecome04HookNote;

  /// No description provided for @entryMissionDorRecome04Intro.
  ///
  /// In pt, this message translates to:
  /// **'Sair da terra é o gesto do recomeço que abençoa outros.'**
  String get entryMissionDorRecome04Intro;

  /// No description provided for @entryMissionDorRecome04Objective.
  ///
  /// In pt, this message translates to:
  /// **'Ligar recomeço a chamado, não a isolamento.'**
  String get entryMissionDorRecome04Objective;

  /// No description provided for @entryMissionDorRecome04Title.
  ///
  /// In pt, this message translates to:
  /// **'Chamado de Abrão'**
  String get entryMissionDorRecome04Title;

  /// No description provided for @entryMissionDorRecome05CentralInsight.
  ///
  /// In pt, this message translates to:
  /// **'Há conforto para quem chora de verdade'**
  String get entryMissionDorRecome05CentralInsight;

  /// No description provided for @entryMissionDorRecome05EchoQuestion.
  ///
  /// In pt, this message translates to:
  /// **'O recomeço caminha para fora. Quem chora o que morreu encontra o quê no Reino?'**
  String get entryMissionDorRecome05EchoQuestion;

  /// No description provided for @entryMissionDorRecome05HookNote.
  ///
  /// In pt, this message translates to:
  /// **'O Reino não apressa o luto. Consola. A trilha canônica começa em Gênesis 1–11.'**
  String get entryMissionDorRecome05HookNote;

  /// No description provided for @entryMissionDorRecome05Intro.
  ///
  /// In pt, this message translates to:
  /// **'Quem chora o que morreu é bem-aventurado. Continue em Gênesis 1–11.'**
  String get entryMissionDorRecome05Intro;

  /// No description provided for @entryMissionDorRecome05Objective.
  ///
  /// In pt, this message translates to:
  /// **'Sair da trilha de dor para o currículo: Gênesis 1–11.'**
  String get entryMissionDorRecome05Objective;

  /// No description provided for @entryMissionDorRecome05Title.
  ///
  /// In pt, this message translates to:
  /// **'Os que choram'**
  String get entryMissionDorRecome05Title;

  /// No description provided for @entryTrailAnsiedadeDescription.
  ///
  /// In pt, this message translates to:
  /// **'Cinco cenas para lançar o amanhã no Pai — e seguir no cânon.'**
  String get entryTrailAnsiedadeDescription;

  /// No description provided for @entryTrailAnsiedadeModuleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Lançar a ansiedade'**
  String get entryTrailAnsiedadeModuleTitle;

  /// No description provided for @entryTrailAnsiedadeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ansiedade'**
  String get entryTrailAnsiedadeTitle;

  /// No description provided for @entryTrailRecomecoDescription.
  ///
  /// In pt, this message translates to:
  /// **'Cinco cenas da queda ao chamado — e de volta a Gênesis 1–11.'**
  String get entryTrailRecomecoDescription;

  /// No description provided for @entryTrailRecomecoModuleTitle.
  ///
  /// In pt, this message translates to:
  /// **'Do rompimento ao chamado'**
  String get entryTrailRecomecoModuleTitle;

  /// No description provided for @entryTrailRecomecoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recomeço'**
  String get entryTrailRecomecoTitle;

  /// No description provided for @eraChurchBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Atos, epístolas e a consumação'**
  String get eraChurchBlurb;

  /// No description provided for @eraChurchTitle.
  ///
  /// In pt, this message translates to:
  /// **'Igreja e cartas'**
  String get eraChurchTitle;

  /// No description provided for @eraConquestBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Terra prometida e ciclo dos juízes'**
  String get eraConquestBlurb;

  /// No description provided for @eraConquestTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conquista e juízes'**
  String get eraConquestTitle;

  /// No description provided for @eraDividedBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Israel, Judá e a voz dos profetas'**
  String get eraDividedBlurb;

  /// No description provided for @eraDividedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Reinos e profetas'**
  String get eraDividedTitle;

  /// No description provided for @eraExileBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Babilônia e a esperança do retorno'**
  String get eraExileBlurb;

  /// No description provided for @eraExileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Exílio'**
  String get eraExileTitle;

  /// No description provided for @eraExodusBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Saída do Egito, Sinai e o deserto'**
  String get eraExodusBlurb;

  /// No description provided for @eraExodusTitle.
  ///
  /// In pt, this message translates to:
  /// **'Êxodo e Lei'**
  String get eraExodusTitle;

  /// No description provided for @eraGospelsBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Os quatro Evangelhos'**
  String get eraGospelsBlurb;

  /// No description provided for @eraGospelsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Vida de Jesus'**
  String get eraGospelsTitle;

  /// No description provided for @eraOriginsBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Criação, Dilúvio e a família de Abraão'**
  String get eraOriginsBlurb;

  /// No description provided for @eraOriginsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Origens e patriarcas'**
  String get eraOriginsTitle;

  /// No description provided for @eraReturnBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Templo, muros e o último dos profetas'**
  String get eraReturnBlurb;

  /// No description provided for @eraReturnTitle.
  ///
  /// In pt, this message translates to:
  /// **'Retorno e restauração'**
  String get eraReturnTitle;

  /// No description provided for @eraUnitedBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Saul, Davi e Salomão'**
  String get eraUnitedBlurb;

  /// No description provided for @eraUnitedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Monarquia unida'**
  String get eraUnitedTitle;

  /// No description provided for @exerciseCheck.
  ///
  /// In pt, this message translates to:
  /// **'Verificar'**
  String get exerciseCheck;

  /// No description provided for @exerciseCueMatch.
  ///
  /// In pt, this message translates to:
  /// **'Ligue cada par.'**
  String get exerciseCueMatch;

  /// No description provided for @exerciseCueOrder.
  ///
  /// In pt, this message translates to:
  /// **'Monte a sequência.'**
  String get exerciseCueOrder;

  /// No description provided for @exerciseCueTap.
  ///
  /// In pt, this message translates to:
  /// **'Toque o trecho que responde.'**
  String get exerciseCueTap;

  /// No description provided for @exerciseFalse.
  ///
  /// In pt, this message translates to:
  /// **'Falso'**
  String get exerciseFalse;

  /// Inicial de Falso no botão
  ///
  /// In pt, this message translates to:
  /// **'F'**
  String get exerciseFalseMark;

  /// No description provided for @exerciseHint.
  ///
  /// In pt, this message translates to:
  /// **'Dica'**
  String get exerciseHint;

  /// No description provided for @exerciseHintUsed.
  ///
  /// In pt, this message translates to:
  /// **'Dica usada'**
  String get exerciseHintUsed;

  /// No description provided for @exerciseLabelBridge.
  ///
  /// In pt, this message translates to:
  /// **'Ponte'**
  String get exerciseLabelBridge;

  /// No description provided for @exerciseLabelClaim.
  ///
  /// In pt, this message translates to:
  /// **'Afirmação'**
  String get exerciseLabelClaim;

  /// No description provided for @exerciseLabelPairs.
  ///
  /// In pt, this message translates to:
  /// **'Pares'**
  String get exerciseLabelPairs;

  /// No description provided for @exerciseLabelQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta'**
  String get exerciseLabelQuestion;

  /// Ordem dos fatos (não é a sequência de dias)
  ///
  /// In pt, this message translates to:
  /// **'Sequência'**
  String get exerciseLabelSequence;

  /// No description provided for @exerciseLabelWord.
  ///
  /// In pt, this message translates to:
  /// **'Palavra'**
  String get exerciseLabelWord;

  /// Passo 2 do gesto de parear
  ///
  /// In pt, this message translates to:
  /// **'Pareie'**
  String get exerciseMatchPair;

  /// Passo 1 do gesto de parear
  ///
  /// In pt, this message translates to:
  /// **'Escolha'**
  String get exerciseMatchPick;

  /// No description provided for @exerciseNoteLabel.
  ///
  /// In pt, this message translates to:
  /// **'Contexto'**
  String get exerciseNoteLabel;

  /// No description provided for @exerciseTitleChoose.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a resposta'**
  String get exerciseTitleChoose;

  /// No description provided for @exerciseTitleComplete.
  ///
  /// In pt, this message translates to:
  /// **'Complete o versículo'**
  String get exerciseTitleComplete;

  /// No description provided for @exerciseTitleConnect.
  ///
  /// In pt, this message translates to:
  /// **'Conecte os trechos'**
  String get exerciseTitleConnect;

  /// No description provided for @exerciseTitleOrder.
  ///
  /// In pt, this message translates to:
  /// **'Ordene os fatos'**
  String get exerciseTitleOrder;

  /// No description provided for @exerciseTitleTap.
  ///
  /// In pt, this message translates to:
  /// **'Toque a palavra'**
  String get exerciseTitleTap;

  /// No description provided for @exerciseTitleTrueFalse.
  ///
  /// In pt, this message translates to:
  /// **'Julgue o versículo'**
  String get exerciseTitleTrueFalse;

  /// No description provided for @exerciseTrue.
  ///
  /// In pt, this message translates to:
  /// **'Verdadeiro'**
  String get exerciseTrue;

  /// Inicial de Verdadeiro no botão
  ///
  /// In pt, this message translates to:
  /// **'V'**
  String get exerciseTrueMark;

  /// Tipo de pergunta (não o modo)
  ///
  /// In pt, this message translates to:
  /// **'Interpretação'**
  String get exerciseTypeBestInterpretation;

  /// Gesto (imperativo)
  ///
  /// In pt, this message translates to:
  /// **'Escolha'**
  String get exerciseTypeChoice;

  /// No description provided for @exerciseTypeClassify.
  ///
  /// In pt, this message translates to:
  /// **'Classifique'**
  String get exerciseTypeClassify;

  /// Gesto (imperativo)
  ///
  /// In pt, this message translates to:
  /// **'Complete'**
  String get exerciseTypeComplete;

  /// Gesto (imperativo)
  ///
  /// In pt, this message translates to:
  /// **'Conecte'**
  String get exerciseTypeConnect;

  /// No description provided for @exerciseTypeExplain.
  ///
  /// In pt, this message translates to:
  /// **'Explique'**
  String get exerciseTypeExplain;

  /// No description provided for @exerciseTypeFindInText.
  ///
  /// In pt, this message translates to:
  /// **'No texto'**
  String get exerciseTypeFindInText;

  /// No description provided for @exerciseTypeInsight.
  ///
  /// In pt, this message translates to:
  /// **'Insight'**
  String get exerciseTypeInsight;

  /// No description provided for @exerciseTypeMatch.
  ///
  /// In pt, this message translates to:
  /// **'Emparelhe'**
  String get exerciseTypeMatch;

  /// Gesto (imperativo)
  ///
  /// In pt, this message translates to:
  /// **'Ordene'**
  String get exerciseTypeOrder;

  /// No description provided for @exerciseTypeReview.
  ///
  /// In pt, this message translates to:
  /// **'Revisão'**
  String get exerciseTypeReview;

  /// Gesto (imperativo)
  ///
  /// In pt, this message translates to:
  /// **'Toque'**
  String get exerciseTypeTap;

  /// No description provided for @exerciseTypeTextSupported.
  ///
  /// In pt, this message translates to:
  /// **'O texto diz'**
  String get exerciseTypeTextSupported;

  /// No description provided for @exerciseTypeTrueFalse.
  ///
  /// In pt, this message translates to:
  /// **'Verdadeiro / Falso'**
  String get exerciseTypeTrueFalse;

  /// No description provided for @exerciseVerbAnswer.
  ///
  /// In pt, this message translates to:
  /// **'Responda'**
  String get exerciseVerbAnswer;

  /// No description provided for @exerciseVerbJudge.
  ///
  /// In pt, this message translates to:
  /// **'Julgue'**
  String get exerciseVerbJudge;

  /// No description provided for @feedbackAlmost.
  ///
  /// In pt, this message translates to:
  /// **'Quase'**
  String get feedbackAlmost;

  /// No description provided for @feedbackAnswer.
  ///
  /// In pt, this message translates to:
  /// **'Resposta'**
  String get feedbackAnswer;

  /// No description provided for @feedbackCheer1.
  ///
  /// In pt, this message translates to:
  /// **'Isso.'**
  String get feedbackCheer1;

  /// No description provided for @feedbackCheer2.
  ///
  /// In pt, this message translates to:
  /// **'Acertou.'**
  String get feedbackCheer2;

  /// No description provided for @feedbackCheer3.
  ///
  /// In pt, this message translates to:
  /// **'Muito bem.'**
  String get feedbackCheer3;

  /// No description provided for @feedbackCheer4.
  ///
  /// In pt, this message translates to:
  /// **'Certo.'**
  String get feedbackCheer4;

  /// No description provided for @feedbackCorrect.
  ///
  /// In pt, this message translates to:
  /// **'Acertou'**
  String get feedbackCorrect;

  /// Palavra certa, não a escolhida
  ///
  /// In pt, this message translates to:
  /// **'{expected}, não {got}'**
  String feedbackCorrection(String expected, String got);

  /// No description provided for @feedbackEndPartial.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar com passos parciais'**
  String get feedbackEndPartial;

  /// No description provided for @feedbackFollow.
  ///
  /// In pt, this message translates to:
  /// **'Seguir.'**
  String get feedbackFollow;

  /// No description provided for @feedbackNotYet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não'**
  String get feedbackNotYet;

  /// No description provided for @feedbackOutOfLamps.
  ///
  /// In pt, this message translates to:
  /// **'Sem lâmpadas'**
  String get feedbackOutOfLamps;

  /// No description provided for @feedbackReadPassage.
  ///
  /// In pt, this message translates to:
  /// **'Ler o texto da cena'**
  String get feedbackReadPassage;

  /// No description provided for @feedbackReportSent.
  ///
  /// In pt, this message translates to:
  /// **'Relato enviado. Obrigado.'**
  String get feedbackReportSent;

  /// No description provided for @feedbackReportTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Relatar problema nesta pergunta'**
  String get feedbackReportTooltip;

  /// No description provided for @feedbackRequeueHint.
  ///
  /// In pt, this message translates to:
  /// **'Tente de novo ou deixe para o fim da cena.'**
  String get feedbackRequeueHint;

  /// No description provided for @feedbackRereadHint.
  ///
  /// In pt, this message translates to:
  /// **'Releia o texto e tente de novo.'**
  String get feedbackRereadHint;

  /// No description provided for @feedbackSeeRightWord.
  ///
  /// In pt, this message translates to:
  /// **'Veja a palavra certa'**
  String get feedbackSeeRightWord;

  /// No description provided for @feedbackSeeText.
  ///
  /// In pt, this message translates to:
  /// **'Veja no texto'**
  String get feedbackSeeText;

  /// No description provided for @feedbackSkipToEnd.
  ///
  /// In pt, this message translates to:
  /// **'Pular e tentar no fim'**
  String get feedbackSkipToEnd;

  /// No description provided for @feedbackTryAgain.
  ///
  /// In pt, this message translates to:
  /// **'Tente de novo.'**
  String get feedbackTryAgain;

  /// No description provided for @groupCallEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Ninguém da caravana para chamar agora.'**
  String get groupCallEmpty;

  /// No description provided for @groupCallFull.
  ///
  /// In pt, this message translates to:
  /// **'Este grupo já tem {count} pessoas.'**
  String groupCallFull(int count);

  /// No description provided for @groupCallSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O convite aparece no app. Ou mande o link no WhatsApp.'**
  String get groupCallSubtitle;

  /// No description provided for @groupCallTitle.
  ///
  /// In pt, this message translates to:
  /// **'Chamar pessoas'**
  String get groupCallTitle;

  /// No description provided for @groupCaptionNotYet.
  ///
  /// In pt, this message translates to:
  /// **'ainda não'**
  String get groupCaptionNotYet;

  /// No description provided for @groupCaptionToday.
  ///
  /// In pt, this message translates to:
  /// **'hoje'**
  String get groupCaptionToday;

  /// No description provided for @groupCreateCta.
  ///
  /// In pt, this message translates to:
  /// **'Criar grupo'**
  String get groupCreateCta;

  /// Unit under a day count. Trailing space avoids a merge-script false positive; code trims it.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{dia } other{dias }}'**
  String groupDayUnit(int count);

  /// No description provided for @groupDaysAway.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia sem estudar} other{{count} dias sem estudar}}'**
  String groupDaysAway(int count);

  /// No description provided for @groupEmptyLeaderBody.
  ///
  /// In pt, this message translates to:
  /// **'Todos recebem a mesma cena — mesmo quem ainda não chegou nela na trilha.'**
  String get groupEmptyLeaderBody;

  /// No description provided for @groupEmptyLeaderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual texto o grupo vai estudar nesta semana?'**
  String get groupEmptyLeaderTitle;

  /// No description provided for @groupEmptyMemberBody.
  ///
  /// In pt, this message translates to:
  /// **'{leader} escolhe a cena que o grupo estuda junto.'**
  String groupEmptyMemberBody(String leader);

  /// No description provided for @groupEmptyMemberTitle.
  ///
  /// In pt, this message translates to:
  /// **'O texto da semana ainda não chegou.'**
  String get groupEmptyMemberTitle;

  /// No description provided for @groupInviteAccept.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar'**
  String get groupInviteAccept;

  /// No description provided for @groupInviteBody.
  ///
  /// In pt, this message translates to:
  /// **'{name} te chamou para o grupo · {kind}.'**
  String groupInviteBody(String name, String kind);

  /// No description provided for @groupInviteCta.
  ///
  /// In pt, this message translates to:
  /// **'Chamar'**
  String get groupInviteCta;

  /// No description provided for @groupInviteLabel.
  ///
  /// In pt, this message translates to:
  /// **'Convite'**
  String get groupInviteLabel;

  /// No description provided for @groupInviteSendFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar o convite. Tente de novo.'**
  String get groupInviteSendFailed;

  /// No description provided for @groupInviteSending.
  ///
  /// In pt, this message translates to:
  /// **'Enviando…'**
  String get groupInviteSending;

  /// No description provided for @groupInviteSent.
  ///
  /// In pt, this message translates to:
  /// **'Convite enviado'**
  String get groupInviteSent;

  /// No description provided for @groupInviteUndo.
  ///
  /// In pt, this message translates to:
  /// **'Desfazer'**
  String get groupInviteUndo;

  /// No description provided for @groupInviteUndoFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível desfazer o convite. Tente de novo.'**
  String get groupInviteUndoFailed;

  /// Leader role title followed by first name, e.g. 'Líder Ana'.
  ///
  /// In pt, this message translates to:
  /// **'{title} {name}'**
  String groupLeaderNoteTitle(String title, String name);

  /// No description provided for @groupMenuClearStudy.
  ///
  /// In pt, this message translates to:
  /// **'Tirar estudo da semana'**
  String get groupMenuClearStudy;

  /// No description provided for @groupMenuClose.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar o grupo'**
  String get groupMenuClose;

  /// No description provided for @groupMenuCopyCode.
  ///
  /// In pt, this message translates to:
  /// **'Copiar código {code}'**
  String groupMenuCopyCode(String code);

  /// No description provided for @groupMenuEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar nome e tipo'**
  String get groupMenuEdit;

  /// No description provided for @groupMenuGoal.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Meta da semana · 1 passo} other{Meta da semana · {count} passos}}'**
  String groupMenuGoal(int count);

  /// No description provided for @groupMenuLeadSection.
  ///
  /// In pt, this message translates to:
  /// **'Conduzir o grupo'**
  String get groupMenuLeadSection;

  /// No description provided for @groupMenuLeave.
  ///
  /// In pt, this message translates to:
  /// **'Sair do grupo'**
  String get groupMenuLeave;

  /// No description provided for @groupMenuSetGoal.
  ///
  /// In pt, this message translates to:
  /// **'Definir meta da semana'**
  String get groupMenuSetGoal;

  /// No description provided for @groupMenuTransfer.
  ///
  /// In pt, this message translates to:
  /// **'Passar a liderança'**
  String get groupMenuTransfer;

  /// No description provided for @groupNewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo grupo'**
  String get groupNewTitle;

  /// No description provided for @groupPickStudyCta.
  ///
  /// In pt, this message translates to:
  /// **'Escolher o estudo'**
  String get groupPickStudyCta;

  /// No description provided for @groupPickerConfirmCta.
  ///
  /// In pt, this message translates to:
  /// **'Marcar para o grupo'**
  String get groupPickerConfirmCta;

  /// No description provided for @groupPickerIntro.
  ///
  /// In pt, this message translates to:
  /// **'Todos do grupo recebem a mesma cena, mesmo quem ainda não chegou nela.'**
  String get groupPickerIntro;

  /// No description provided for @groupPickerMarkScene.
  ///
  /// In pt, this message translates to:
  /// **'Marcar a cena'**
  String get groupPickerMarkScene;

  /// No description provided for @groupPickerNoteHint.
  ///
  /// In pt, this message translates to:
  /// **'Opcional. Ex.: Leiam até quarta, conversamos na quinta.'**
  String get groupPickerNoteHint;

  /// No description provided for @groupPickerNoteLabel.
  ///
  /// In pt, this message translates to:
  /// **'Recado para o grupo'**
  String get groupPickerNoteLabel;

  /// No description provided for @groupPickerPreviewLabel.
  ///
  /// In pt, this message translates to:
  /// **'O grupo vai ver'**
  String get groupPickerPreviewLabel;

  /// No description provided for @groupRosterSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{{name}, 1 dia nesta semana} other{{name}, {count} dias nesta semana}}'**
  String groupRosterSemantics(String name, int count);

  /// No description provided for @groupSeatAlreadyWaved.
  ///
  /// In pt, this message translates to:
  /// **'Você já acenou para {name} hoje.'**
  String groupSeatAlreadyWaved(String name);

  /// No description provided for @groupSeatDaysInWeek.
  ///
  /// In pt, this message translates to:
  /// **'Dias na semana'**
  String get groupSeatDaysInWeek;

  /// No description provided for @groupSeatIdle.
  ///
  /// In pt, this message translates to:
  /// **'ainda não estudou nesta semana'**
  String get groupSeatIdle;

  /// No description provided for @groupSeatNever.
  ///
  /// In pt, this message translates to:
  /// **'ainda não estudou'**
  String get groupSeatNever;

  /// No description provided for @groupSeatSteps.
  ///
  /// In pt, this message translates to:
  /// **'Passos'**
  String get groupSeatSteps;

  /// No description provided for @groupSeatStudyDone.
  ///
  /// In pt, this message translates to:
  /// **'Feito'**
  String get groupSeatStudyDone;

  /// No description provided for @groupSeatStudyNotYet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não'**
  String get groupSeatStudyNotYet;

  /// No description provided for @groupSeatToday.
  ///
  /// In pt, this message translates to:
  /// **'estudou hoje'**
  String get groupSeatToday;

  /// No description provided for @groupSeatWeek.
  ///
  /// In pt, this message translates to:
  /// **'estudou nesta semana'**
  String get groupSeatWeek;

  /// No description provided for @groupSetupKindLabel.
  ///
  /// In pt, this message translates to:
  /// **'Para que é o grupo'**
  String get groupSetupKindLabel;

  /// No description provided for @groupSetupLimitHint.
  ///
  /// In pt, this message translates to:
  /// **'Até {limit} pessoas. Grupo grande? Abra outro — discipulado acontece em grupo pequeno.'**
  String groupSetupLimitHint(int limit);

  /// No description provided for @groupSetupNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get groupSetupNameLabel;

  /// No description provided for @groupStudyAgain.
  ///
  /// In pt, this message translates to:
  /// **'Você já fez · Estudar de novo'**
  String get groupStudyAgain;

  /// No description provided for @groupStudyCta.
  ///
  /// In pt, this message translates to:
  /// **'Estudar com o grupo'**
  String get groupStudyCta;

  /// No description provided for @groupStudyDoneCount.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total} já fizeram'**
  String groupStudyDoneCount(int done, int total);

  /// No description provided for @groupStudyNobodyYet.
  ///
  /// In pt, this message translates to:
  /// **'Ninguém fez ainda. Seja o primeiro.'**
  String get groupStudyNobodyYet;

  /// No description provided for @groupStudySwap.
  ///
  /// In pt, this message translates to:
  /// **'Trocar'**
  String get groupStudySwap;

  /// No description provided for @groupWeekStudy.
  ///
  /// In pt, this message translates to:
  /// **'Estudo da semana'**
  String get groupWeekStudy;

  /// Unit shown under the streak number. Trailing space only dodges the merge validator; code trims it.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{dia } other{dias }}'**
  String growthDayUnit(int count);

  /// No description provided for @growthDaysToStage.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 dia de sequência para {stage}} other{Faltam {count} dias de sequência para {stage}}}'**
  String growthDaysToStage(int count, String stage);

  /// No description provided for @growthFreezeUsed.
  ///
  /// In pt, this message translates to:
  /// **'{subtitle} · gelo já usado nesta semana'**
  String growthFreezeUsed(String subtitle);

  /// No description provided for @growthFruitSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia de sequência · deu fruto} other{{count} dias de sequência · deu fruto}}'**
  String growthFruitSubtitle(int count);

  /// No description provided for @growthHintDayZero.
  ///
  /// In pt, this message translates to:
  /// **'dia 0'**
  String get growthHintDayZero;

  /// No description provided for @growthNextIn.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Próximo: {stage} · faltam 1 dia na sequência} other{Próximo: {stage} · faltam {count} dias na sequência}}'**
  String growthNextIn(String stage, int count);

  /// No description provided for @growthNextMilestone.
  ///
  /// In pt, this message translates to:
  /// **'Próximo marco: {stage}'**
  String growthNextMilestone(String stage);

  /// No description provided for @growthPerfect.
  ///
  /// In pt, this message translates to:
  /// **'Cena perfeita'**
  String get growthPerfect;

  /// No description provided for @growthPerfectWith.
  ///
  /// In pt, this message translates to:
  /// **'Cena perfeita · {subtitle}'**
  String growthPerfectWith(String subtitle);

  /// No description provided for @growthSeedSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Faça 1 cena hoje para virar Broto'**
  String get growthSeedSubtitle;

  /// No description provided for @growthStageBranch.
  ///
  /// In pt, this message translates to:
  /// **'Ramo'**
  String get growthStageBranch;

  /// No description provided for @growthStageFruit.
  ///
  /// In pt, this message translates to:
  /// **'Fruto'**
  String get growthStageFruit;

  /// No description provided for @growthStageSeed.
  ///
  /// In pt, this message translates to:
  /// **'Semente'**
  String get growthStageSeed;

  /// No description provided for @growthStageSprout.
  ///
  /// In pt, this message translates to:
  /// **'Broto'**
  String get growthStageSprout;

  /// No description provided for @growthStageTree.
  ///
  /// In pt, this message translates to:
  /// **'Árvore'**
  String get growthStageTree;

  /// No description provided for @growthWhisper.
  ///
  /// In pt, this message translates to:
  /// **'Cada dia da sequência sobe um marco: Semente, Broto, Ramo, Árvore e Fruto.'**
  String get growthWhisper;

  /// No description provided for @homeBibleOfflineSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Leia sem internet'**
  String get homeBibleOfflineSubtitle;

  /// No description provided for @homeCatalogDownloading.
  ///
  /// In pt, this message translates to:
  /// **'Baixando…'**
  String get homeCatalogDownloading;

  /// No description provided for @homeCatalogEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'As cenas baixam na primeira abertura. Se a conexão falhar, toque para tentar de novo.'**
  String get homeCatalogEmptyBody;

  /// No description provided for @homeCatalogEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'As cenas ainda não chegaram'**
  String get homeCatalogEmptyTitle;

  /// Fallback name when the user has no name.
  ///
  /// In pt, this message translates to:
  /// **'Peregrino'**
  String get homeDefaultName;

  /// No description provided for @homeFreezeSheetBody.
  ///
  /// In pt, this message translates to:
  /// **'Você perdeu um dia, mas a sequência continua. O gelo salva uma falta por semana — caminhe hoje para seguir.'**
  String get homeFreezeSheetBody;

  /// No description provided for @homeFreezeSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'O gelo cobriu ontem'**
  String get homeFreezeSheetTitle;

  /// No description provided for @homeGoalLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 cena para a meta} other{Faltam {count} cenas para a meta}}'**
  String homeGoalLeft(int count);

  /// No description provided for @homeGoalMet.
  ///
  /// In pt, this message translates to:
  /// **'Meta do dia cumprida'**
  String get homeGoalMet;

  /// No description provided for @homeHeroEcho.
  ///
  /// In pt, this message translates to:
  /// **'Eco de ontem'**
  String get homeHeroEcho;

  /// No description provided for @homeHeroExtraSteps.
  ///
  /// In pt, this message translates to:
  /// **'+{count} passos · extra de hoje'**
  String homeHeroExtraSteps(int count);

  /// No description provided for @homeHeroFrozenLine.
  ///
  /// In pt, this message translates to:
  /// **'O gelo cobriu ontem · sequência preservada'**
  String get homeHeroFrozenLine;

  /// No description provided for @homeHeroMinutes.
  ///
  /// In pt, this message translates to:
  /// **'~3 min'**
  String get homeHeroMinutes;

  /// No description provided for @homeHeroProtect.
  ///
  /// In pt, this message translates to:
  /// **'Protege a sequência · ~3 min'**
  String get homeHeroProtect;

  /// No description provided for @homeHeroReady.
  ///
  /// In pt, this message translates to:
  /// **'Cena pronta'**
  String get homeHeroReady;

  /// No description provided for @homeHeroTomorrow.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã'**
  String get homeHeroTomorrow;

  /// No description provided for @homeJuntosNews.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 novidade} other{{count} novidades}}'**
  String homeJuntosNews(int count);

  /// No description provided for @homeLampsHint.
  ///
  /// In pt, this message translates to:
  /// **'Erro apaga uma · zerar encerra'**
  String get homeLampsHint;

  /// No description provided for @homeLampsSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{current} de {max} lâmpadas. Cada erro apaga uma.'**
  String homeLampsSemantics(int current, int max);

  /// No description provided for @homeLampsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Lâmpadas'**
  String get homeLampsTitle;

  /// No description provided for @homeMoodAlive.
  ///
  /// In pt, this message translates to:
  /// **'Em dia'**
  String get homeMoodAlive;

  /// No description provided for @homeMoodDusty.
  ///
  /// In pt, this message translates to:
  /// **'Sequência em risco'**
  String get homeMoodDusty;

  /// No description provided for @homeMoodFrozen.
  ///
  /// In pt, this message translates to:
  /// **'Protegido pelo gelo'**
  String get homeMoodFrozen;

  /// No description provided for @homeMoreToday.
  ///
  /// In pt, this message translates to:
  /// **'Mais para hoje'**
  String get homeMoreToday;

  /// No description provided for @homeOpenProfile.
  ///
  /// In pt, this message translates to:
  /// **'Abrir perfil de {name}'**
  String homeOpenProfile(String name);

  /// No description provided for @homeQuestsExtraCaption.
  ///
  /// In pt, this message translates to:
  /// **'Passos extras'**
  String get homeQuestsExtraCaption;

  /// No description provided for @homeReviewCaption.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 para reforçar} other{{count} para reforçar}}'**
  String homeReviewCaption(int count);

  /// No description provided for @homeReviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Revisão'**
  String get homeReviewTitle;

  /// No description provided for @homeSeasonChipDoneSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{season}. Dia {day} feito: {dayTitle}'**
  String homeSeasonChipDoneSemantics(String season, int day, String dayTitle);

  /// No description provided for @homeSeasonChipOpenSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{season}. Dia {day}: {dayTitle}'**
  String homeSeasonChipOpenSemantics(String season, int day, String dayTitle);

  /// No description provided for @homeSeasonChipSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{season} · abrir leitura da estação'**
  String homeSeasonChipSemantics(String season);

  /// No description provided for @homeSeasonDayDone.
  ///
  /// In pt, this message translates to:
  /// **'Dia {day} feito · {title}'**
  String homeSeasonDayDone(int day, String title);

  /// No description provided for @homeSeasonDayLine.
  ///
  /// In pt, this message translates to:
  /// **'Dia {day} · {title}'**
  String homeSeasonDayLine(int day, String title);

  /// No description provided for @homeSeasonDayOf.
  ///
  /// In pt, this message translates to:
  /// **'Dia {day} de {total} · {title}'**
  String homeSeasonDayOf(int day, int total, String title);

  /// No description provided for @homeSeasonDayOfDone.
  ///
  /// In pt, this message translates to:
  /// **'Dia {day} de {total} feito · {title}'**
  String homeSeasonDayOfDone(int day, int total, String title);

  /// No description provided for @homeSeeTrails.
  ///
  /// In pt, this message translates to:
  /// **'Ver trilhas'**
  String get homeSeeTrails;

  /// No description provided for @homeStatAtRisk.
  ///
  /// In pt, this message translates to:
  /// **'em risco'**
  String get homeStatAtRisk;

  /// No description provided for @homeStatFreeze.
  ///
  /// In pt, this message translates to:
  /// **'gelo'**
  String get homeStatFreeze;

  /// No description provided for @homeStatFreezeUsed.
  ///
  /// In pt, this message translates to:
  /// **'gelo usado'**
  String get homeStatFreezeUsed;

  /// No description provided for @homeStatGoal.
  ///
  /// In pt, this message translates to:
  /// **'meta'**
  String get homeStatGoal;

  /// No description provided for @homeStepsSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 passo na jornada} other{{count} passos na jornada}}'**
  String homeStepsSemantics(int count);

  /// No description provided for @homeTrailDoneBody.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a próxima e continue aprendendo.'**
  String get homeTrailDoneBody;

  /// No description provided for @homeTrailDoneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Trilha concluída'**
  String get homeTrailDoneTitle;

  /// No description provided for @homeWordInScene.
  ///
  /// In pt, this message translates to:
  /// **'Nesta cena'**
  String get homeWordInScene;

  /// No description provided for @homeWordRead.
  ///
  /// In pt, this message translates to:
  /// **'Ler {reference}'**
  String homeWordRead(String reference);

  /// No description provided for @homeWordWord.
  ///
  /// In pt, this message translates to:
  /// **'Palavra'**
  String get homeWordWord;

  /// No description provided for @inviteAcceptCta.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar convite'**
  String get inviteAcceptCta;

  /// No description provided for @inviteCalledYou.
  ///
  /// In pt, this message translates to:
  /// **'{name} te chamou'**
  String inviteCalledYou(String name);

  /// No description provided for @inviteCardBody.
  ///
  /// In pt, this message translates to:
  /// **'{name} te chamou para caminhar junto — sem disputa, só presença.'**
  String inviteCardBody(String name);

  /// No description provided for @inviteCardHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Caminhem juntos'**
  String get inviteCardHeadline;

  /// No description provided for @inviteCardInstallHint.
  ///
  /// In pt, this message translates to:
  /// **'Já tem o app? Toque no link do convite.\nAinda não? Baixe o Stway e toque de novo.'**
  String get inviteCardInstallHint;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In pt, this message translates to:
  /// **'Código copiado'**
  String get inviteCodeCopied;

  /// No description provided for @inviteCodeHint.
  ///
  /// In pt, this message translates to:
  /// **'Código'**
  String get inviteCodeHint;

  /// Share text sent to a friend.
  ///
  /// In pt, this message translates to:
  /// **'{name} te chamou pra caminhar junto no Stway.\nSem disputa — só presença.\n\nToque para aceitar (já tem o app):\n{link}\n\nAinda não tem o Stway? Baixe e toque no link de novo:\n{installUrl}'**
  String inviteCompanionShareText(String name, String link, String installUrl);

  /// No description provided for @inviteCreateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível criar o convite. Tente de novo.'**
  String get inviteCreateFailed;

  /// No description provided for @inviteHaveCodeSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Se você copiou o código no WhatsApp, ele já aparece aqui'**
  String get inviteHaveCodeSubtitle;

  /// No description provided for @inviteHaveCodeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tenho um código'**
  String get inviteHaveCodeTitle;

  /// No description provided for @inviteJoinCta.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get inviteJoinCta;

  /// No description provided for @inviteLinkHint.
  ///
  /// In pt, this message translates to:
  /// **'O link abre o app e aceita sem digitar o código'**
  String get inviteLinkHint;

  /// No description provided for @invitePreparing.
  ///
  /// In pt, this message translates to:
  /// **'Preparando…'**
  String get invitePreparing;

  /// No description provided for @inviteReadyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu convite está pronto'**
  String get inviteReadyTitle;

  /// No description provided for @inviteRoomShareText.
  ///
  /// In pt, this message translates to:
  /// **'Entre no Stway com o código {code}.\n\nAinda não tem o app? Baixe: {installUrl}'**
  String inviteRoomShareText(String code, String installUrl);

  /// No description provided for @inviteScanHint.
  ///
  /// In pt, this message translates to:
  /// **'Aponte para o QR do convite'**
  String get inviteScanHint;

  /// No description provided for @inviteScanQr.
  ///
  /// In pt, this message translates to:
  /// **'Escanear QR'**
  String get inviteScanQr;

  /// No description provided for @inviteShareCta.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar convite'**
  String get inviteShareCta;

  /// No description provided for @inviteShareSubject.
  ///
  /// In pt, this message translates to:
  /// **'Convite Stway — caminhem juntos'**
  String get inviteShareSubject;

  /// No description provided for @inviteSheetSubtitleCompanion.
  ///
  /// In pt, this message translates to:
  /// **'Toque no link, mostre o QR ou envie o card'**
  String get inviteSheetSubtitleCompanion;

  /// No description provided for @inviteSheetSubtitleRoom.
  ///
  /// In pt, this message translates to:
  /// **'Mostre o QR ou envie o código'**
  String get inviteSheetSubtitleRoom;

  /// No description provided for @inviteSomeone.
  ///
  /// In pt, this message translates to:
  /// **'Alguém'**
  String get inviteSomeone;

  /// No description provided for @journalEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Ao fixar uma cena, sua resposta fica registrada aqui.'**
  String get journalEmpty;

  /// No description provided for @journalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Anotações de estudo'**
  String get journalTitle;

  /// Locked trail on the area path
  ///
  /// In pt, this message translates to:
  /// **'Ainda além do horizonte'**
  String get journeyBeyondHorizon;

  /// No description provided for @journeyLockedHint.
  ///
  /// In pt, this message translates to:
  /// **'Conclua a trilha anterior para liberar esta.'**
  String get journeyLockedHint;

  /// No description provided for @journeyModeAhead.
  ///
  /// In pt, this message translates to:
  /// **'{mode} à frente'**
  String journeyModeAhead(String mode);

  /// No description provided for @journeyModeInProgress.
  ///
  /// In pt, this message translates to:
  /// **'{mode} em curso'**
  String journeyModeInProgress(String mode);

  /// No description provided for @journeyNow.
  ///
  /// In pt, this message translates to:
  /// **'Agora'**
  String get journeyNow;

  /// No description provided for @journeySoonHint.
  ///
  /// In pt, this message translates to:
  /// **'Em breve · esta trilha ainda está sendo escrita.'**
  String get journeySoonHint;

  /// No description provided for @journeyYouAreHere.
  ///
  /// In pt, this message translates to:
  /// **'Onde você está'**
  String get journeyYouAreHere;

  /// No description provided for @juntosAccept.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar'**
  String get juntosAccept;

  /// No description provided for @juntosBeforeLeaveBody.
  ///
  /// In pt, this message translates to:
  /// **'Escolha quem vai conduzir o grupo depois de você.'**
  String get juntosBeforeLeaveBody;

  /// No description provided for @juntosBeforeLeaveTitle.
  ///
  /// In pt, this message translates to:
  /// **'Antes de sair'**
  String get juntosBeforeLeaveTitle;

  /// No description provided for @juntosBondNotStudying.
  ///
  /// In pt, this message translates to:
  /// **'Sem estudar'**
  String get juntosBondNotStudying;

  /// No description provided for @juntosBondNotYet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não'**
  String get juntosBondNotYet;

  /// No description provided for @juntosBondYourTurn.
  ///
  /// In pt, this message translates to:
  /// **'Sua vez'**
  String get juntosBondYourTurn;

  /// No description provided for @juntosCancelInvite.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar convite'**
  String get juntosCancelInvite;

  /// No description provided for @juntosCancelInviteError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível cancelar o convite. Tente de novo.'**
  String get juntosCancelInviteError;

  /// No description provided for @juntosCaravanEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'O ranking aparece com pelo menos mais uma pessoa caminhando. Chame alguém para a caravana — ou comece por uma companhia.'**
  String get juntosCaravanEmptyBody;

  /// No description provided for @juntosCaravanEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'A caravana ainda é pequena'**
  String get juntosCaravanEmptyTitle;

  /// No description provided for @juntosCaravanInviteCta.
  ///
  /// In pt, this message translates to:
  /// **'Chamar para a caravana'**
  String get juntosCaravanInviteCta;

  /// No description provided for @juntosCaravanLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar a caravana. Puxe para atualizar.'**
  String get juntosCaravanLoadError;

  /// No description provided for @juntosCaravanMonthBody.
  ///
  /// In pt, this message translates to:
  /// **'Tudo conta: cenas, tarefas do dia, baús e companhia. Zera todo dia 1 — quem chegou agora também pode liderar.'**
  String get juntosCaravanMonthBody;

  /// No description provided for @juntosCaravanMonthStep1.
  ///
  /// In pt, this message translates to:
  /// **'Estude\numa cena'**
  String get juntosCaravanMonthStep1;

  /// No description provided for @juntosCaravanMonthStep2.
  ///
  /// In pt, this message translates to:
  /// **'Some\npassos'**
  String get juntosCaravanMonthStep2;

  /// No description provided for @juntosCaravanMonthStep3.
  ///
  /// In pt, this message translates to:
  /// **'Veja o\ncaminho'**
  String get juntosCaravanMonthStep3;

  /// No description provided for @juntosCaravanMonthTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem mais caminhou neste mês?'**
  String get juntosCaravanMonthTitle;

  /// No description provided for @juntosCaravanPilgrimsCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 peregrino da caravana} other{{count} peregrinos da caravana}}'**
  String juntosCaravanPilgrimsCount(int count);

  /// No description provided for @juntosCaravanShareSubject.
  ///
  /// In pt, this message translates to:
  /// **'Venha pra caravana no Stway'**
  String get juntosCaravanShareSubject;

  /// Share text a friend sends; casual friend voice.
  ///
  /// In pt, this message translates to:
  /// **'{name} te chama pra caravana no Stway — aprenda a Bíblia em cenas curtas e caminhe junto no ranking.\n\nBaixe: {url}'**
  String juntosCaravanShareText(String name, String url);

  /// No description provided for @juntosCaravanSignInLive.
  ///
  /// In pt, this message translates to:
  /// **'Entre com Google para ver a caravana ao vivo.'**
  String get juntosCaravanSignInLive;

  /// No description provided for @juntosCaravanTimeout.
  ///
  /// In pt, this message translates to:
  /// **'A caravana demorou para responder. Puxe para atualizar.'**
  String get juntosCaravanTimeout;

  /// No description provided for @juntosCaravanWeekBody.
  ///
  /// In pt, this message translates to:
  /// **'Só passos de cenas novas, de segunda a domingo. No fim da semana, os primeiros sobem de nível e os últimos descem.'**
  String get juntosCaravanWeekBody;

  /// No description provided for @juntosCaravanWeekStep1.
  ///
  /// In pt, this message translates to:
  /// **'Passos\nda semana'**
  String get juntosCaravanWeekStep1;

  /// No description provided for @juntosCaravanWeekStep2.
  ///
  /// In pt, this message translates to:
  /// **'Lugar no\nranking'**
  String get juntosCaravanWeekStep2;

  /// No description provided for @juntosCaravanWeekStep3.
  ///
  /// In pt, this message translates to:
  /// **'Sobe ou\ndesce'**
  String get juntosCaravanWeekStep3;

  /// No description provided for @juntosCaravanWeekTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem avançou nesta semana?'**
  String get juntosCaravanWeekTitle;

  /// No description provided for @juntosChallengeExplainerBody.
  ///
  /// In pt, this message translates to:
  /// **'Mesma cena, até domingo. Quem chegar ganha {reward} — se os dois chegarem, os dois ganham.'**
  String juntosChallengeExplainerBody(String reward);

  /// No description provided for @juntosChallengeExplainerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem chega até domingo?'**
  String get juntosChallengeExplainerTitle;

  /// No description provided for @juntosChallengeStep1.
  ///
  /// In pt, this message translates to:
  /// **'Mesma\ncena'**
  String get juntosChallengeStep1;

  /// No description provided for @juntosChallengeStep2.
  ///
  /// In pt, this message translates to:
  /// **'Chegar até\ndomingo'**
  String get juntosChallengeStep2;

  /// No description provided for @juntosChallengeStep3.
  ///
  /// In pt, this message translates to:
  /// **'+10 passos\nna chegada'**
  String get juntosChallengeStep3;

  /// No description provided for @juntosChoose.
  ///
  /// In pt, this message translates to:
  /// **'Escolher'**
  String get juntosChoose;

  /// Screen reader label for a tab with news.
  ///
  /// In pt, this message translates to:
  /// **'{label}, novidade'**
  String juntosChromeTabAlert(String label);

  /// No description provided for @juntosCloseConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar'**
  String get juntosCloseConfirm;

  /// No description provided for @juntosCloseRoomBody.
  ///
  /// In pt, this message translates to:
  /// **'O grupo some para todos e o código deixa de funcionar. Não é possível desfazer.'**
  String get juntosCloseRoomBody;

  /// No description provided for @juntosCloseRoomTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar o grupo?'**
  String get juntosCloseRoomTitle;

  /// No description provided for @juntosClosesToday.
  ///
  /// In pt, this message translates to:
  /// **'Fecha hoje'**
  String get juntosClosesToday;

  /// No description provided for @juntosCodeCopied.
  ///
  /// In pt, this message translates to:
  /// **'Código copiado'**
  String get juntosCodeCopied;

  /// No description provided for @juntosCodeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Código'**
  String get juntosCodeLabel;

  /// No description provided for @juntosCodeTapToCopy.
  ///
  /// In pt, this message translates to:
  /// **'Código {code}. Toque para copiar'**
  String juntosCodeTapToCopy(String code);

  /// No description provided for @juntosCompanionExplainerBody.
  ///
  /// In pt, this message translates to:
  /// **'Uma companhia de estudo. No dia em que os dois caminham, o fio acende e a sequência cresce.'**
  String get juntosCompanionExplainerBody;

  /// No description provided for @juntosCompanionExplainerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem caminha ao seu lado?'**
  String get juntosCompanionExplainerTitle;

  /// No description provided for @juntosCompanionFallback.
  ///
  /// In pt, this message translates to:
  /// **'Companheiro'**
  String get juntosCompanionFallback;

  /// No description provided for @juntosCompanionStep1.
  ///
  /// In pt, this message translates to:
  /// **'Os dois\nestudam'**
  String get juntosCompanionStep1;

  /// No description provided for @juntosCompanionStep2.
  ///
  /// In pt, this message translates to:
  /// **'O dia conta\njuntos'**
  String get juntosCompanionStep2;

  /// No description provided for @juntosCompanionStep3.
  ///
  /// In pt, this message translates to:
  /// **'Se um atrasa,\no outro acena'**
  String get juntosCompanionStep3;

  /// No description provided for @juntosCompanionsOfflineBody.
  ///
  /// In pt, this message translates to:
  /// **'Entre com Google para caminhar com alguém de verdade.'**
  String get juntosCompanionsOfflineBody;

  /// No description provided for @juntosCompanionsOfflineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Companhia precisa da nuvem'**
  String get juntosCompanionsOfflineTitle;

  /// No description provided for @juntosConnecting.
  ///
  /// In pt, this message translates to:
  /// **'Conectando…'**
  String get juntosConnecting;

  /// No description provided for @juntosCopy.
  ///
  /// In pt, this message translates to:
  /// **'Copiar'**
  String get juntosCopy;

  /// No description provided for @juntosCopyCodeSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Copiar código {code}'**
  String juntosCopyCodeSemantics(String code);

  /// No description provided for @juntosCreateInviteError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível criar o convite. Tente de novo.'**
  String get juntosCreateInviteError;

  /// No description provided for @juntosCreateRoom.
  ///
  /// In pt, this message translates to:
  /// **'Criar grupo'**
  String get juntosCreateRoom;

  /// No description provided for @juntosDaysLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 dia} other{Faltam {count} dias}}'**
  String juntosDaysLeft(int count);

  /// No description provided for @juntosDeclineInviteError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível recusar o convite. Tente de novo.'**
  String get juntosDeclineInviteError;

  /// No description provided for @juntosDemoteZone.
  ///
  /// In pt, this message translates to:
  /// **'Zona de descida · {tier}'**
  String juntosDemoteZone(String tier);

  /// No description provided for @juntosEditRoomTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar grupo'**
  String get juntosEditRoomTitle;

  /// No description provided for @juntosFirstMilestone.
  ///
  /// In pt, this message translates to:
  /// **'Primeiro marco: {count} dias juntos'**
  String juntosFirstMilestone(int count);

  /// Steps behind the person ranked just above (place = their position).
  ///
  /// In pt, this message translates to:
  /// **'{gap} do {place}º'**
  String juntosGapToAbove(int gap, int place);

  /// No description provided for @juntosHaveCode.
  ///
  /// In pt, this message translates to:
  /// **'Tenho um código'**
  String get juntosHaveCode;

  /// No description provided for @juntosInboxNews.
  ///
  /// In pt, this message translates to:
  /// **'Novidades · {count}'**
  String juntosInboxNews(int count);

  /// No description provided for @juntosInviteCompanion.
  ///
  /// In pt, this message translates to:
  /// **'Chamar um companheiro'**
  String get juntosInviteCompanion;

  /// No description provided for @juntosInvitePeople.
  ///
  /// In pt, this message translates to:
  /// **'Chamar pessoas'**
  String get juntosInvitePeople;

  /// No description provided for @juntosInviteShort.
  ///
  /// In pt, this message translates to:
  /// **'Chamar'**
  String get juntosInviteShort;

  /// No description provided for @juntosJoin.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get juntosJoin;

  /// No description provided for @juntosJoinError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível entrar. Tente de novo.'**
  String get juntosJoinError;

  /// No description provided for @juntosJoinRoomHint.
  ///
  /// In pt, this message translates to:
  /// **'Código que você recebeu'**
  String get juntosJoinRoomHint;

  /// No description provided for @juntosJoinRoomTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar no grupo'**
  String get juntosJoinRoomTitle;

  /// No description provided for @juntosLeader.
  ///
  /// In pt, this message translates to:
  /// **'Líder'**
  String get juntosLeader;

  /// No description provided for @juntosLeaveAllCompanionsBody.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{A companhia termina. Você fica sem companheiro.} other{As {count} companhias terminam. Você fica sem companheiro.}}'**
  String juntosLeaveAllCompanionsBody(int count);

  /// No description provided for @juntosLeaveAllCompanionsCta.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar todas as companhias'**
  String get juntosLeaveAllCompanionsCta;

  /// No description provided for @juntosLeaveAllCompanionsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar todas as companhias?'**
  String get juntosLeaveAllCompanionsTitle;

  /// No description provided for @juntosLeaveAllConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar todas'**
  String get juntosLeaveAllConfirm;

  /// No description provided for @juntosLeaveCompanionBody.
  ///
  /// In pt, this message translates to:
  /// **'A companhia com esta pessoa termina. A caravana continua.'**
  String get juntosLeaveCompanionBody;

  /// No description provided for @juntosLeaveCompanionCta.
  ///
  /// In pt, this message translates to:
  /// **'Sair da companhia'**
  String get juntosLeaveCompanionCta;

  /// No description provided for @juntosLeaveCompanionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair da companhia?'**
  String get juntosLeaveCompanionTitle;

  /// No description provided for @juntosLeaveConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get juntosLeaveConfirm;

  /// No description provided for @juntosLeaveRoomBody.
  ///
  /// In pt, this message translates to:
  /// **'Você sai da lista. Para voltar, use o código de novo.'**
  String get juntosLeaveRoomBody;

  /// No description provided for @juntosLeaveRoomTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair do grupo?'**
  String get juntosLeaveRoomTitle;

  /// No description provided for @juntosMilestoneLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 para o marco de {next}} other{Faltam {count} para o marco de {next}}}'**
  String juntosMilestoneLeft(int count, int next);

  /// No description provided for @juntosMilestones.
  ///
  /// In pt, this message translates to:
  /// **'Marcos'**
  String get juntosMilestones;

  /// No description provided for @juntosNextMilestone.
  ///
  /// In pt, this message translates to:
  /// **'Próximo marco: {count} dias'**
  String juntosNextMilestone(int count);

  /// Follows a big number: '3 of 5'. Keep the leading space.
  ///
  /// In pt, this message translates to:
  /// **' de {total}'**
  String juntosOfTotal(int total);

  /// No description provided for @juntosOnlineSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{countLabel}. Ver quem está estudando'**
  String juntosOnlineSemantics(String countLabel);

  /// No description provided for @juntosOpenInvite.
  ///
  /// In pt, this message translates to:
  /// **'Convite aberto'**
  String get juntosOpenInvite;

  /// No description provided for @juntosOpenInviteMissing.
  ///
  /// In pt, this message translates to:
  /// **'Falta uma pessoa do outro lado'**
  String get juntosOpenInviteMissing;

  /// No description provided for @juntosOrInviteCompanion.
  ///
  /// In pt, this message translates to:
  /// **'Ou chamar um companheiro'**
  String get juntosOrInviteCompanion;

  /// No description provided for @juntosPromoteZone.
  ///
  /// In pt, this message translates to:
  /// **'Zona de subida · {tier}'**
  String juntosPromoteZone(String tier);

  /// No description provided for @juntosRoomAllStudied.
  ///
  /// In pt, this message translates to:
  /// **'O grupo inteiro estudou nesta semana.'**
  String get juntosRoomAllStudied;

  /// No description provided for @juntosRoomBenefitList.
  ///
  /// In pt, this message translates to:
  /// **'Lista'**
  String get juntosRoomBenefitList;

  /// No description provided for @juntosRoomBenefitListDetail.
  ///
  /// In pt, this message translates to:
  /// **'Quem estudou'**
  String get juntosRoomBenefitListDetail;

  /// No description provided for @juntosRoomBenefitStudy.
  ///
  /// In pt, this message translates to:
  /// **'Estudo'**
  String get juntosRoomBenefitStudy;

  /// No description provided for @juntosRoomBenefitStudyDetail.
  ///
  /// In pt, this message translates to:
  /// **'Mesma cena'**
  String get juntosRoomBenefitStudyDetail;

  /// No description provided for @juntosRoomBenefitWave.
  ///
  /// In pt, this message translates to:
  /// **'Acenar'**
  String get juntosRoomBenefitWave;

  /// No description provided for @juntosRoomBenefitWaveDetail.
  ///
  /// In pt, this message translates to:
  /// **'Quem sumiu'**
  String get juntosRoomBenefitWaveDetail;

  /// No description provided for @juntosRoomChestAlready.
  ///
  /// In pt, this message translates to:
  /// **'Baú já coletado nesta semana'**
  String get juntosRoomChestAlready;

  /// No description provided for @juntosRoomChestClaimed.
  ///
  /// In pt, this message translates to:
  /// **'Baú do grupo · +{count} passos'**
  String juntosRoomChestClaimed(int count);

  /// No description provided for @juntosRoomChestOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abrir o baú do grupo · +{count} passos'**
  String juntosRoomChestOpen(int count);

  /// No description provided for @juntosRoomCreated.
  ///
  /// In pt, this message translates to:
  /// **'Grupo criado. Chame alguém da lista, ou mande o código {code}.'**
  String juntosRoomCreated(String code);

  /// No description provided for @juntosRoomFull.
  ///
  /// In pt, this message translates to:
  /// **'Grupo cheio. Para mais gente, abra outro grupo.'**
  String get juntosRoomFull;

  /// No description provided for @juntosRoomGoalHint.
  ///
  /// In pt, this message translates to:
  /// **'Soma da semana. Em branco, tira a meta.'**
  String get juntosRoomGoalHint;

  /// No description provided for @juntosRoomGoalLabel.
  ///
  /// In pt, this message translates to:
  /// **'Meta do grupo'**
  String get juntosRoomGoalLabel;

  /// No description provided for @juntosRoomGoalProgress.
  ///
  /// In pt, this message translates to:
  /// **'{sum} / {goal} passos'**
  String juntosRoomGoalProgress(int sum, int goal);

  /// No description provided for @juntosRoomGoalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meta de passos do grupo'**
  String get juntosRoomGoalTitle;

  /// No description provided for @juntosRoomHalfStudied.
  ///
  /// In pt, this message translates to:
  /// **'Metade do grupo já estudou.'**
  String get juntosRoomHalfStudied;

  /// No description provided for @juntosRoomHintClaimed.
  ///
  /// In pt, this message translates to:
  /// **'Baú do grupo coletado nesta semana.'**
  String get juntosRoomHintClaimed;

  /// No description provided for @juntosRoomHintHalf.
  ///
  /// In pt, this message translates to:
  /// **'O baú abre quando metade do grupo estudar.'**
  String get juntosRoomHintHalf;

  /// No description provided for @juntosRoomHintHalfOrGoal.
  ///
  /// In pt, this message translates to:
  /// **'O baú abre com metade do grupo ou a meta.'**
  String get juntosRoomHintHalfOrGoal;

  /// No description provided for @juntosRoomHintInvite.
  ///
  /// In pt, this message translates to:
  /// **'Chame quem estuda com você: célula, família, amigos.'**
  String get juntosRoomHintInvite;

  /// No description provided for @juntosRoomHintStudyToday.
  ///
  /// In pt, this message translates to:
  /// **'Estude hoje para abrir o baú do grupo.'**
  String get juntosRoomHintStudyToday;

  /// No description provided for @juntosRoomJoinError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível entrar no grupo. Tente de novo.'**
  String get juntosRoomJoinError;

  /// No description provided for @juntosRoomJoined.
  ///
  /// In pt, this message translates to:
  /// **'Você entrou em {name}.'**
  String juntosRoomJoined(String name);

  /// No description provided for @juntosRoomJoinedGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Você entrou no grupo.'**
  String get juntosRoomJoinedGeneric;

  /// No description provided for @juntosRoomLeaderLine.
  ///
  /// In pt, this message translates to:
  /// **'{leaderTitle}: {leader} · {count, plural, =1{1 pessoa} other{{count} pessoas}}'**
  String juntosRoomLeaderLine(String leaderTitle, String leader, int count);

  /// No description provided for @juntosRoomMissingForHalf.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 pessoa para metade do grupo.} other{Faltam {count} pessoas para metade do grupo.}}'**
  String juntosRoomMissingForHalf(int count);

  /// No description provided for @juntosRoomNotStudiedToday.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não estudou hoje.'**
  String get juntosRoomNotStudiedToday;

  /// No description provided for @juntosRoomOnlyYou.
  ///
  /// In pt, this message translates to:
  /// **'Só você no grupo por enquanto.'**
  String get juntosRoomOnlyYou;

  /// No description provided for @juntosRoomOptions.
  ///
  /// In pt, this message translates to:
  /// **'Opções do grupo'**
  String get juntosRoomOptions;

  /// No description provided for @juntosRoomQrSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Aponte a câmera ou digite o código para entrar'**
  String get juntosRoomQrSubtitle;

  /// Share text a friend sends; casual friend voice.
  ///
  /// In pt, this message translates to:
  /// **'Entra no grupo \"{name}\" no Stway.\nToque ou aponte a câmera:\n{url}\n\nCódigo: {code}\n\nA lista mostra quem estudou nesta semana.\n\nAinda não tem o app? Baixe: {storeUrl}'**
  String juntosRoomShareText(
    String name,
    String url,
    String code,
    String storeUrl,
  );

  /// No description provided for @juntosRoomStudySet.
  ///
  /// In pt, this message translates to:
  /// **'Estudo marcado para o grupo'**
  String get juntosRoomStudySet;

  /// No description provided for @juntosRoomStudySetError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível marcar o estudo. Tente de novo.'**
  String get juntosRoomStudySetError;

  /// No description provided for @juntosRoomsEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Um grupo fechado: célula, discipulado ou EBD. Marque a cena da semana e veja quem estudou — o convite vai no app ou no WhatsApp.'**
  String get juntosRoomsEmptyBody;

  /// No description provided for @juntosRoomsEmptyEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Célula · Discipulado · EBD'**
  String get juntosRoomsEmptyEyebrow;

  /// No description provided for @juntosRoomsEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem estuda com você?'**
  String get juntosRoomsEmptyTitle;

  /// No description provided for @juntosRoomsOfflineBody.
  ///
  /// In pt, this message translates to:
  /// **'O grupo fica na sua conta. Entre com Google para criar ou usar um código.'**
  String get juntosRoomsOfflineBody;

  /// No description provided for @juntosRoomsOfflineFoot.
  ///
  /// In pt, this message translates to:
  /// **'Sem login, o código não funciona'**
  String get juntosRoomsOfflineFoot;

  /// No description provided for @juntosRoomsOfflineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre para criar o grupo'**
  String get juntosRoomsOfflineTitle;

  /// No description provided for @juntosSeenToday.
  ///
  /// In pt, this message translates to:
  /// **'Visto hoje'**
  String get juntosSeenToday;

  /// No description provided for @juntosShowQrShare.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar QR e compartilhar'**
  String get juntosShowQrShare;

  /// No description provided for @juntosSomeone.
  ///
  /// In pt, this message translates to:
  /// **'Alguém'**
  String get juntosSomeone;

  /// No description provided for @juntosStudiedThisWeek.
  ///
  /// In pt, this message translates to:
  /// **'estudaram nesta semana'**
  String get juntosStudiedThisWeek;

  /// No description provided for @juntosStudyToday.
  ///
  /// In pt, this message translates to:
  /// **'Estudar hoje'**
  String get juntosStudyToday;

  /// No description provided for @juntosStudyingNow.
  ///
  /// In pt, this message translates to:
  /// **'Estudando agora'**
  String get juntosStudyingNow;

  /// No description provided for @juntosSwitchRoomBody.
  ///
  /// In pt, this message translates to:
  /// **'Você sai do grupo em que está agora.'**
  String get juntosSwitchRoomBody;

  /// No description provided for @juntosSwitchRoomTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar em {name}?'**
  String juntosSwitchRoomTitle(String name);

  /// No description provided for @juntosTabCaravan.
  ///
  /// In pt, this message translates to:
  /// **'Caravana'**
  String get juntosTabCaravan;

  /// No description provided for @juntosTabChallenge.
  ///
  /// In pt, this message translates to:
  /// **'Desafio'**
  String get juntosTabChallenge;

  /// No description provided for @juntosTabCompanion.
  ///
  /// In pt, this message translates to:
  /// **'Companhia'**
  String get juntosTabCompanion;

  /// No description provided for @juntosTabGroups.
  ///
  /// In pt, this message translates to:
  /// **'Grupos'**
  String get juntosTabGroups;

  /// No description provided for @juntosThisMonth.
  ///
  /// In pt, this message translates to:
  /// **'Este mês'**
  String get juntosThisMonth;

  /// No description provided for @juntosThisWeek.
  ///
  /// In pt, this message translates to:
  /// **'Esta semana'**
  String get juntosThisWeek;

  /// No description provided for @juntosTie.
  ///
  /// In pt, this message translates to:
  /// **'Empate'**
  String get juntosTie;

  /// No description provided for @juntosTogetherLegend.
  ///
  /// In pt, this message translates to:
  /// **'juntos'**
  String get juntosTogetherLegend;

  /// No description provided for @juntosTogetherOfSeven.
  ///
  /// In pt, this message translates to:
  /// **'{count} de 7 juntos'**
  String juntosTogetherOfSeven(int count);

  /// No description provided for @juntosTransferBody.
  ///
  /// In pt, this message translates to:
  /// **'Quem assumir marca o estudo, a meta e acena para o grupo. Você continua na lista.'**
  String get juntosTransferBody;

  /// No description provided for @juntosTransferDone.
  ///
  /// In pt, this message translates to:
  /// **'{name} agora conduz o grupo'**
  String juntosTransferDone(String name);

  /// No description provided for @juntosTransferError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível passar a liderança. Tente de novo.'**
  String get juntosTransferError;

  /// No description provided for @juntosTransferTitle.
  ///
  /// In pt, this message translates to:
  /// **'Passar a liderança'**
  String get juntosTransferTitle;

  /// No description provided for @juntosWaiting.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando'**
  String get juntosWaiting;

  /// No description provided for @juntosWalkedToday.
  ///
  /// In pt, this message translates to:
  /// **'Caminhou hoje'**
  String get juntosWalkedToday;

  /// No description provided for @juntosWaveAt.
  ///
  /// In pt, this message translates to:
  /// **'Acenar para {name}'**
  String juntosWaveAt(String name);

  /// No description provided for @juntosWaveError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível acenar. Tente de novo.'**
  String get juntosWaveError;

  /// No description provided for @juntosWavedAt.
  ///
  /// In pt, this message translates to:
  /// **'Você acenou para {name}'**
  String juntosWavedAt(String name);

  /// No description provided for @juntosWavedAtYou.
  ///
  /// In pt, this message translates to:
  /// **'{name} acenou para você'**
  String juntosWavedAtYou(String name);

  /// No description provided for @juntosWeekRankingEmpty.
  ///
  /// In pt, this message translates to:
  /// **'O ranking da semana só aparece com gente de verdade na caravana.'**
  String get juntosWeekRankingEmpty;

  /// No description provided for @juntosWeekTogetherBonus.
  ///
  /// In pt, this message translates to:
  /// **'A companhia ganhou +{count} passos na jornada'**
  String juntosWeekTogetherBonus(int count);

  /// No description provided for @juntosWho.
  ///
  /// In pt, this message translates to:
  /// **'Quem?'**
  String get juntosWho;

  /// Used inside a sentence, e.g. 'Leader: you'.
  ///
  /// In pt, this message translates to:
  /// **'você'**
  String get juntosYouLower;

  /// No description provided for @languageDevice.
  ///
  /// In pt, this message translates to:
  /// **'Do aparelho'**
  String get languageDevice;

  /// No description provided for @languageHint.
  ///
  /// In pt, this message translates to:
  /// **'Os textos das trilhas e a Bíblia continuam em português por enquanto.'**
  String get languageHint;

  /// No description provided for @languageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get languageTitle;

  /// No description provided for @leagueActiveToday.
  ///
  /// In pt, this message translates to:
  /// **'Ativo hoje'**
  String get leagueActiveToday;

  /// No description provided for @leagueBonusEncourage.
  ///
  /// In pt, this message translates to:
  /// **'+{count} passos de encorajamento'**
  String leagueBonusEncourage(int count);

  /// No description provided for @leagueDemotedBody.
  ///
  /// In pt, this message translates to:
  /// **'Ficou em {rank}º. No nível {tier}, dá para subir de novo.'**
  String leagueDemotedBody(int rank, String tier);

  /// No description provided for @leagueDemotedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você desceu para {tier}'**
  String leagueDemotedTitle(String tier);

  /// No description provided for @leagueDriftDown.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Desceu 1 posição hoje} other{Desceu {count} posições hoje}}'**
  String leagueDriftDown(int count);

  /// No description provided for @leagueDriftStable.
  ///
  /// In pt, this message translates to:
  /// **'Posição estável hoje'**
  String get leagueDriftStable;

  /// No description provided for @leagueDriftUp.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Subiu 1 posição hoje} other{Subiu {count} posições hoje}}'**
  String leagueDriftUp(int count);

  /// No description provided for @leagueLevelUpBodyOnly.
  ///
  /// In pt, this message translates to:
  /// **'Agora você caminha no nível\n{tier}'**
  String leagueLevelUpBodyOnly(String tier);

  /// No description provided for @leagueLevelUpBodyRank.
  ///
  /// In pt, this message translates to:
  /// **'Ficou em {rank}º · agora caminha no nível\n{tier}'**
  String leagueLevelUpBodyRank(int rank, String tier);

  /// No description provided for @leagueLevelUpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você subiu de nível'**
  String get leagueLevelUpTitle;

  /// No description provided for @leaguePromotedLevelOnly.
  ///
  /// In pt, this message translates to:
  /// **'Agora no nível {tier}'**
  String leaguePromotedLevelOnly(String tier);

  /// No description provided for @leaguePromotedRankLine.
  ///
  /// In pt, this message translates to:
  /// **'Ficou em {rank}º · agora no nível {tier}'**
  String leaguePromotedRankLine(int rank, String tier);

  /// No description provided for @leaguePromotedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você subiu para {tier}'**
  String leaguePromotedTitle(String tier);

  /// No description provided for @leagueRiskBodyClosing.
  ///
  /// In pt, this message translates to:
  /// **'Você está em {rank}º no nível {tier}. A caravana fecha em breve.'**
  String leagueRiskBodyClosing(int rank, String tier);

  /// No description provided for @leagueRiskBodyHold.
  ///
  /// In pt, this message translates to:
  /// **'Você está em {rank}º no nível {tier}. Um passo pode segurar o lugar.'**
  String leagueRiskBodyHold(int rank, String tier);

  /// No description provided for @leagueRiskNear.
  ///
  /// In pt, this message translates to:
  /// **'Perto da descida · {closes}'**
  String leagueRiskNear(String closes);

  /// No description provided for @leagueRiskZone.
  ///
  /// In pt, this message translates to:
  /// **'Zona de descida · {closes}'**
  String leagueRiskZone(String closes);

  /// No description provided for @leagueRoleLeader.
  ///
  /// In pt, this message translates to:
  /// **'Líder'**
  String get leagueRoleLeader;

  /// No description provided for @leagueRolePodium.
  ///
  /// In pt, this message translates to:
  /// **'Pódio'**
  String get leagueRolePodium;

  /// No description provided for @leagueRoleVice.
  ///
  /// In pt, this message translates to:
  /// **'Vice'**
  String get leagueRoleVice;

  /// No description provided for @leagueSeenDate.
  ///
  /// In pt, this message translates to:
  /// **'Visto {date}'**
  String leagueSeenDate(String date);

  /// No description provided for @leagueSeenOn.
  ///
  /// In pt, this message translates to:
  /// **'Visto em {date}'**
  String leagueSeenOn(String date);

  /// No description provided for @leagueSeenToday.
  ///
  /// In pt, this message translates to:
  /// **'Visto hoje'**
  String get leagueSeenToday;

  /// No description provided for @leagueSeenTodayWalked.
  ///
  /// In pt, this message translates to:
  /// **'Visto hoje · caminhou {date}'**
  String leagueSeenTodayWalked(String date);

  /// No description provided for @leagueStayedBody.
  ///
  /// In pt, this message translates to:
  /// **'Você ficou em {rank}º no nível {tier}. Nova semana — continue caminhando.'**
  String leagueStayedBody(int rank, String tier);

  /// No description provided for @leagueStudying.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{0 estudando} =1{1 estudando} other{{count} estudando}}'**
  String leagueStudying(int count);

  /// No description provided for @leagueTierCedro.
  ///
  /// In pt, this message translates to:
  /// **'Cedro'**
  String get leagueTierCedro;

  /// No description provided for @leagueTierEstrela.
  ///
  /// In pt, this message translates to:
  /// **'Estrela'**
  String get leagueTierEstrela;

  /// No description provided for @leagueTierOliveira.
  ///
  /// In pt, this message translates to:
  /// **'Oliveira'**
  String get leagueTierOliveira;

  /// No description provided for @leagueTierSemente.
  ///
  /// In pt, this message translates to:
  /// **'Semente'**
  String get leagueTierSemente;

  /// No description provided for @leagueTierVideira.
  ///
  /// In pt, this message translates to:
  /// **'Videira'**
  String get leagueTierVideira;

  /// No description provided for @leagueWalkedDate.
  ///
  /// In pt, this message translates to:
  /// **'Caminhou {date}'**
  String leagueWalkedDate(String date);

  /// No description provided for @leagueWalkedOn.
  ///
  /// In pt, this message translates to:
  /// **'Caminhou em {date}'**
  String leagueWalkedOn(String date);

  /// No description provided for @leagueWalkedSeen.
  ///
  /// In pt, this message translates to:
  /// **'Caminhou {walk} · visto {seen}'**
  String leagueWalkedSeen(String walk, String seen);

  /// No description provided for @leagueWalkedToday.
  ///
  /// In pt, this message translates to:
  /// **'Caminhou hoje'**
  String get leagueWalkedToday;

  /// No description provided for @leagueWeekEndedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Semana da caravana encerrada'**
  String get leagueWeekEndedTitle;

  /// No description provided for @lessonBackToQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Voltar à pergunta'**
  String get lessonBackToQuestion;

  /// No description provided for @lessonBonus.
  ///
  /// In pt, this message translates to:
  /// **'Bônus'**
  String get lessonBonus;

  /// Cena de revisão de etapa (boss)
  ///
  /// In pt, this message translates to:
  /// **'Travessia'**
  String get lessonBoss;

  /// Combo de acertos seguidos no HUD da cena
  ///
  /// In pt, this message translates to:
  /// **'×{count}'**
  String lessonCombo(int count);

  /// No description provided for @lessonComboMeterSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Combo {count} · {filled} de {cycle} até reacender'**
  String lessonComboMeterSemantics(int count, int filled, int cycle);

  /// Duração estimada da cena
  ///
  /// In pt, this message translates to:
  /// **'~3 min'**
  String get lessonDuration;

  /// No description provided for @lessonExitAnyway.
  ///
  /// In pt, this message translates to:
  /// **'Sair mesmo assim'**
  String get lessonExitAnyway;

  /// No description provided for @lessonExitBody.
  ///
  /// In pt, this message translates to:
  /// **'Você está na pergunta {act} de {total}. Saindo agora, os passos desta cena não contam.'**
  String lessonExitBody(int act, int total);

  /// No description provided for @lessonExitTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair da cena?'**
  String get lessonExitTitle;

  /// No description provided for @lessonInsightSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O que ficou'**
  String get lessonInsightSubtitle;

  /// No description provided for @lessonIntroBossPulse.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Travessia · 1 pergunta} other{Travessia · {count} perguntas}}'**
  String lessonIntroBossPulse(int count);

  /// No description provided for @lessonIntroPulse.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{~3 min · 1 pergunta} other{~3 min · {count} perguntas}}'**
  String lessonIntroPulse(int count);

  /// No description provided for @lessonLampRelit.
  ///
  /// In pt, this message translates to:
  /// **'Cinco seguidas: uma lâmpada reacendeu.'**
  String get lessonLampRelit;

  /// Lâmpada = vida dentro da cena
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =0{As lâmpadas acabaram — cada erro apaga uma.} =1{Resta 1 lâmpada — cada erro apaga uma.} other{Restam {count} lâmpadas — cada erro apaga uma.}}'**
  String lessonLampsLeft(int count);

  /// No description provided for @lessonListen.
  ///
  /// In pt, this message translates to:
  /// **'Ouvir o texto'**
  String get lessonListen;

  /// No description provided for @lessonListenStop.
  ///
  /// In pt, this message translates to:
  /// **'Parar'**
  String get lessonListenStop;

  /// No description provided for @lessonLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as perguntas desta cena. Tente de novo.'**
  String get lessonLoadError;

  /// No description provided for @lessonLocked.
  ///
  /// In pt, this message translates to:
  /// **'Esta cena ainda está bloqueada.'**
  String get lessonLocked;

  /// No description provided for @lessonMicroSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Complete o verso'**
  String get lessonMicroSubtitle;

  /// No description provided for @lessonPassageTitle.
  ///
  /// In pt, this message translates to:
  /// **'Texto da cena'**
  String get lessonPassageTitle;

  /// No description provided for @lessonPractice.
  ///
  /// In pt, this message translates to:
  /// **'Treino'**
  String get lessonPractice;

  /// No description provided for @lessonQuestionProgress.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta {current} de {total}'**
  String lessonQuestionProgress(int current, int total);

  /// Referência quando o versículo não tem referência
  ///
  /// In pt, this message translates to:
  /// **'Versículo'**
  String get lessonVerseFallback;

  /// No description provided for @liturgyAdvent.
  ///
  /// In pt, this message translates to:
  /// **'Advento'**
  String get liturgyAdvent;

  /// No description provided for @liturgyAdventSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Tempo de espera e preparação'**
  String get liturgyAdventSubtitle;

  /// No description provided for @liturgyChristmas.
  ///
  /// In pt, this message translates to:
  /// **'Natal'**
  String get liturgyChristmas;

  /// No description provided for @liturgyChristmasSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O Verbo se fez carne'**
  String get liturgyChristmasSubtitle;

  /// No description provided for @liturgyEaster.
  ///
  /// In pt, this message translates to:
  /// **'Páscoa'**
  String get liturgyEaster;

  /// No description provided for @liturgyEasterSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Cristo ressuscitou'**
  String get liturgyEasterSubtitle;

  /// No description provided for @liturgyHolyWeek.
  ///
  /// In pt, this message translates to:
  /// **'Semana Santa'**
  String get liturgyHolyWeek;

  /// No description provided for @liturgyHolyWeekSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Da cruz à espera da ressurreição'**
  String get liturgyHolyWeekSubtitle;

  /// No description provided for @liturgyLent.
  ///
  /// In pt, this message translates to:
  /// **'Quaresma'**
  String get liturgyLent;

  /// No description provided for @liturgyLentSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Deserto, jejum e retorno'**
  String get liturgyLentSubtitle;

  /// No description provided for @liturgyOrdinary.
  ///
  /// In pt, this message translates to:
  /// **'Tempo comum'**
  String get liturgyOrdinary;

  /// No description provided for @liturgyOrdinarySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Crescimento na Palavra, dia a dia'**
  String get liturgyOrdinarySubtitle;

  /// No description provided for @liturgyPentecost.
  ///
  /// In pt, this message translates to:
  /// **'Pentecostes'**
  String get liturgyPentecost;

  /// No description provided for @liturgyPentecostSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O Espírito é derramado'**
  String get liturgyPentecostSubtitle;

  /// No description provided for @liturgyQuestSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Leia um capítulo — foco: {ref}'**
  String liturgyQuestSubtitle(String ref);

  /// Seasonal daily quest title, e.g. 'Tempo de Advento'
  ///
  /// In pt, this message translates to:
  /// **'Tempo de {season}'**
  String liturgyQuestTitle(String season);

  /// No description provided for @loginAppleError.
  ///
  /// In pt, this message translates to:
  /// **'Falha no login com Apple'**
  String get loginAppleError;

  /// No description provided for @loginBody.
  ///
  /// In pt, this message translates to:
  /// **'Sua conta guarda seus passos, sua sequência e suas cenas — assim nada se perde entre aparelhos.'**
  String get loginBody;

  /// No description provided for @loginEntering.
  ///
  /// In pt, this message translates to:
  /// **'Entrando…'**
  String get loginEntering;

  /// No description provided for @loginGoogleError.
  ///
  /// In pt, this message translates to:
  /// **'Falha no login com Google'**
  String get loginGoogleError;

  /// No description provided for @loginHydrateError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar seu progresso. Verifique a conexão e tente de novo.'**
  String get loginHydrateError;

  /// No description provided for @loginLoadingBody.
  ///
  /// In pt, this message translates to:
  /// **'Carregando seus passos, sua sequência e suas cenas…'**
  String get loginLoadingBody;

  /// No description provided for @loginReconnect.
  ///
  /// In pt, this message translates to:
  /// **'Tentar reconectar'**
  String get loginReconnect;

  /// No description provided for @loginRequired.
  ///
  /// In pt, this message translates to:
  /// **'É necessário entrar para usar o Stway.'**
  String get loginRequired;

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre para continuar'**
  String get loginTitle;

  /// No description provided for @loginWithApple.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Apple'**
  String get loginWithApple;

  /// No description provided for @loginWithGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Google'**
  String get loginWithGoogle;

  /// No description provided for @mascotAllClear.
  ///
  /// In pt, this message translates to:
  /// **'Tudo claro. Volte amanhã para continuar.'**
  String get mascotAllClear;

  /// No description provided for @mascotBossHigh.
  ///
  /// In pt, this message translates to:
  /// **'O desafio final ficou para trás. Siga o mapa.'**
  String get mascotBossHigh;

  /// No description provided for @mascotBossLow.
  ///
  /// In pt, this message translates to:
  /// **'Travessia feita. Vale reforçar o que ainda tremeu.'**
  String get mascotBossLow;

  /// No description provided for @mascotCaravanDetailLead.
  ///
  /// In pt, this message translates to:
  /// **'Segure o 1º até o domingo e você avança de caravana.'**
  String get mascotCaravanDetailLead;

  /// No description provided for @mascotCaravanDetailOut.
  ///
  /// In pt, this message translates to:
  /// **'Cada cena move a caravana. Continue nesta semana.'**
  String get mascotCaravanDetailOut;

  /// No description provided for @mascotCaravanDetailZone.
  ///
  /// In pt, this message translates to:
  /// **'{rank}º agora · os primeiros sobem no domingo.'**
  String mascotCaravanDetailZone(int rank);

  /// No description provided for @mascotCaravanLead.
  ///
  /// In pt, this message translates to:
  /// **'Você lidera a caravana'**
  String get mascotCaravanLead;

  /// No description provided for @mascotCaravanRank.
  ///
  /// In pt, this message translates to:
  /// **'{rank}º na caravana'**
  String mascotCaravanRank(int rank);

  /// No description provided for @mascotCaravanZone.
  ///
  /// In pt, this message translates to:
  /// **'Zona de subida'**
  String get mascotCaravanZone;

  /// No description provided for @mascotFailedDetail.
  ///
  /// In pt, this message translates to:
  /// **'As lâmpadas acabaram antes do fim. A cena espera você — de novo, com calma.'**
  String get mascotFailedDetail;

  /// No description provided for @mascotFailedKicker.
  ///
  /// In pt, this message translates to:
  /// **'Faltou luz'**
  String get mascotFailedKicker;

  /// No description provided for @mascotGood.
  ///
  /// In pt, this message translates to:
  /// **'Boa cena. A trilha te espera amanhã.'**
  String get mascotGood;

  /// No description provided for @mascotHeadlineBoss.
  ///
  /// In pt, this message translates to:
  /// **'Travessia concluída'**
  String get mascotHeadlineBoss;

  /// No description provided for @mascotHeadlinePerfect.
  ///
  /// In pt, this message translates to:
  /// **'100% de acertos'**
  String get mascotHeadlinePerfect;

  /// No description provided for @mascotHeadlineReplay.
  ///
  /// In pt, this message translates to:
  /// **'Você voltou ao texto'**
  String get mascotHeadlineReplay;

  /// No description provided for @mascotHeadlineScene.
  ///
  /// In pt, this message translates to:
  /// **'Cena concluída'**
  String get mascotHeadlineScene;

  /// No description provided for @mascotKickerBoss.
  ///
  /// In pt, this message translates to:
  /// **'Travessia final'**
  String get mascotKickerBoss;

  /// No description provided for @mascotKickerPerfect.
  ///
  /// In pt, this message translates to:
  /// **'Sem erro'**
  String get mascotKickerPerfect;

  /// No description provided for @mascotKickerReplay.
  ///
  /// In pt, this message translates to:
  /// **'Revisão'**
  String get mascotKickerReplay;

  /// No description provided for @mascotKickerScene.
  ///
  /// In pt, this message translates to:
  /// **'Mais uma cena'**
  String get mascotKickerScene;

  /// No description provided for @mascotPerfect.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma lâmpada perdida. Isso fica.'**
  String get mascotPerfect;

  /// No description provided for @mascotReinforce.
  ///
  /// In pt, this message translates to:
  /// **'Cena feita. Reforce o que faltou — a memória agradece.'**
  String get mascotReinforce;

  /// No description provided for @mascotReplay.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao texto fortalece o que já caminhou.'**
  String get mascotReplay;

  /// No description provided for @medalAccuracyEliteHint.
  ///
  /// In pt, this message translates to:
  /// **'Manteve 95%+ de acertos em 150 questões ou mais'**
  String get medalAccuracyEliteHint;

  /// No description provided for @medalAccuracyEliteTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mira certeira'**
  String get medalAccuracyEliteTitle;

  /// No description provided for @medalAdventDoorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Porta aberta'**
  String get medalAdventDoorTitle;

  /// No description provided for @medalAdventHalfHint.
  ///
  /// In pt, this message translates to:
  /// **'Caminhe metade dos dias do Advento'**
  String get medalAdventHalfHint;

  /// No description provided for @medalAdventHalfTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meio do caminho'**
  String get medalAdventHalfTitle;

  /// No description provided for @medalAdventLivedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Temporada vivida'**
  String get medalAdventLivedTitle;

  /// No description provided for @medalAdventSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Espera e preparação'**
  String get medalAdventSubtitle;

  /// No description provided for @medalAdventTitle.
  ///
  /// In pt, this message translates to:
  /// **'Advento'**
  String get medalAdventTitle;

  /// No description provided for @medalAdventTrackSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Espera e preparação — {year}'**
  String medalAdventTrackSubtitle(String year);

  /// No description provided for @medalAdventVaultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Advento {year}'**
  String medalAdventVaultTitle(String year);

  /// No description provided for @medalAdventWeekHint.
  ///
  /// In pt, this message translates to:
  /// **'Sete dias de sequência no Advento'**
  String get medalAdventWeekHint;

  /// No description provided for @medalAdventWeekTitle.
  ///
  /// In pt, this message translates to:
  /// **'Semana de espera'**
  String get medalAdventWeekTitle;

  /// No description provided for @medalAllLevelsDone.
  ///
  /// In pt, this message translates to:
  /// **'Todos os níveis concluídos.'**
  String get medalAllLevelsDone;

  /// No description provided for @medalBibleBeforeHint.
  ///
  /// In pt, this message translates to:
  /// **'Leu um capítulo no mesmo dia, antes da cena'**
  String get medalBibleBeforeHint;

  /// No description provided for @medalBibleBeforeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Palavra antes'**
  String get medalBibleBeforeTitle;

  /// No description provided for @medalComebackHint.
  ///
  /// In pt, this message translates to:
  /// **'A porta estava aberta — voltou após 21 dias ou mais'**
  String get medalComebackHint;

  /// No description provided for @medalComebackTitle.
  ///
  /// In pt, this message translates to:
  /// **'Volta firme'**
  String get medalComebackTitle;

  /// No description provided for @medalFormationPerfect10Title.
  ///
  /// In pt, this message translates to:
  /// **'Olho firme'**
  String get medalFormationPerfect10Title;

  /// No description provided for @medalFormationPerfect1Title.
  ///
  /// In pt, this message translates to:
  /// **'Cena nítida'**
  String get medalFormationPerfect1Title;

  /// No description provided for @medalFormationPerfect25Hint.
  ///
  /// In pt, this message translates to:
  /// **'25 cenas com 100% de acertos'**
  String get medalFormationPerfect25Hint;

  /// No description provided for @medalFormationPerfect25Title.
  ///
  /// In pt, this message translates to:
  /// **'Tudo certo'**
  String get medalFormationPerfect25Title;

  /// No description provided for @medalFounderHint.
  ///
  /// In pt, this message translates to:
  /// **'Entrou no app durante o período de testes'**
  String get medalFounderHint;

  /// No description provided for @medalFounderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pioneiro'**
  String get medalFounderTitle;

  /// No description provided for @medalHeadlineDiscovery.
  ///
  /// In pt, this message translates to:
  /// **'Descoberta'**
  String get medalHeadlineDiscovery;

  /// No description provided for @medalHeadlineJourney.
  ///
  /// In pt, this message translates to:
  /// **'Medalha da jornada'**
  String get medalHeadlineJourney;

  /// No description provided for @medalHeadlineLevelUp.
  ///
  /// In pt, this message translates to:
  /// **'Subiu de nível'**
  String get medalHeadlineLevelUp;

  /// No description provided for @medalHeadlineLit.
  ///
  /// In pt, this message translates to:
  /// **'Medalha acesa'**
  String get medalHeadlineLit;

  /// No description provided for @medalHeadlineLocked.
  ///
  /// In pt, this message translates to:
  /// **'A desbloquear'**
  String get medalHeadlineLocked;

  /// No description provided for @medalHeadlineNew.
  ///
  /// In pt, this message translates to:
  /// **'Nova medalha'**
  String get medalHeadlineNew;

  /// No description provided for @medalHeadlineRare.
  ///
  /// In pt, this message translates to:
  /// **'Rara'**
  String get medalHeadlineRare;

  /// No description provided for @medalHeadlineTrail.
  ///
  /// In pt, this message translates to:
  /// **'Medalha da trilha'**
  String get medalHeadlineTrail;

  /// No description provided for @medalHintAdventDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Caminhe 1 dia no Advento} other{Caminhe {count} dias no Advento}}'**
  String medalHintAdventDays(int count);

  /// No description provided for @medalHintLentDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Caminhe 1 dia na Quaresma} other{Caminhe {count} dias na Quaresma}}'**
  String medalHintLentDays(int count);

  /// No description provided for @medalHintMemorizeVerses.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Firme 1 versículo na memorização} other{Firme {count} versículos na memorização}}'**
  String medalHintMemorizeVerses(int count);

  /// No description provided for @medalHintPerfectScenes.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Termine uma cena com 100% de acertos} other{Termine {count} cenas com 100% de acertos}}'**
  String medalHintPerfectScenes(int count);

  /// No description provided for @medalHintReadChapters.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Leia 1 capítulo na Bíblia} other{Leia {count} capítulos}}'**
  String medalHintReadChapters(int count);

  /// No description provided for @medalHintShareVerses.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Compartilhe 1 versículo} other{Compartilhe {count} versículos}}'**
  String medalHintShareVerses(int count);

  /// No description provided for @medalHintStreak.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Mantenha 1 dia de sequência} other{Mantenha {count} dias de sequência}}'**
  String medalHintStreak(int count);

  /// No description provided for @medalHowToEarn.
  ///
  /// In pt, this message translates to:
  /// **'Como ganhar: {hint}'**
  String medalHowToEarn(String hint);

  /// No description provided for @medalJourneyVaultSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Faísca acende; medalha fica'**
  String get medalJourneyVaultSubtitle;

  /// No description provided for @medalJourneyVaultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cofre da jornada'**
  String get medalJourneyVaultTitle;

  /// No description provided for @medalLeaderHint.
  ///
  /// In pt, this message translates to:
  /// **'Ficou em 1º no ranking geral por um dia'**
  String get medalLeaderHint;

  /// No description provided for @medalLeaderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Líder da caravana'**
  String get medalLeaderTitle;

  /// No description provided for @medalLentFirstStepTitle.
  ///
  /// In pt, this message translates to:
  /// **'Primeiro passo no deserto'**
  String get medalLentFirstStepTitle;

  /// No description provided for @medalLentHalfHint.
  ///
  /// In pt, this message translates to:
  /// **'Caminhe metade dos dias da Quaresma'**
  String get medalLentHalfHint;

  /// No description provided for @medalLentHalfTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meio do deserto'**
  String get medalLentHalfTitle;

  /// No description provided for @medalLentLivedTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quaresma vivida'**
  String get medalLentLivedTitle;

  /// No description provided for @medalLentSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Deserto, jejum e retorno'**
  String get medalLentSubtitle;

  /// No description provided for @medalLentTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quaresma'**
  String get medalLentTitle;

  /// No description provided for @medalLentTrackSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Deserto, jejum e retorno — {year}'**
  String medalLentTrackSubtitle(String year);

  /// No description provided for @medalLentVaultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quaresma {year}'**
  String medalLentVaultTitle(String year);

  /// No description provided for @medalMemoryVerse15Title.
  ///
  /// In pt, this message translates to:
  /// **'Palavra guardada'**
  String get medalMemoryVerse15Title;

  /// No description provided for @medalMemoryVerse1Title.
  ///
  /// In pt, this message translates to:
  /// **'Primeiro verso'**
  String get medalMemoryVerse1Title;

  /// No description provided for @medalMemoryVerse50Title.
  ///
  /// In pt, this message translates to:
  /// **'Escritura viva'**
  String get medalMemoryVerse50Title;

  /// No description provided for @medalMysteryHint.
  ///
  /// In pt, this message translates to:
  /// **'Revelam-se no caminho — sem dica no cofre.'**
  String get medalMysteryHint;

  /// No description provided for @medalMysteryTitle.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Uma descoberta} other{{count} descobertas}}'**
  String medalMysteryTitle(int count);

  /// No description provided for @medalNowTier.
  ///
  /// In pt, this message translates to:
  /// **'Agora em {tier}'**
  String medalNowTier(String tier);

  /// No description provided for @medalPathStreak14Title.
  ///
  /// In pt, this message translates to:
  /// **'Duas semanas'**
  String get medalPathStreak14Title;

  /// No description provided for @medalPathStreak30Title.
  ///
  /// In pt, this message translates to:
  /// **'Mês constante'**
  String get medalPathStreak30Title;

  /// No description provided for @medalPathStreak3Title.
  ///
  /// In pt, this message translates to:
  /// **'Três dias firmes'**
  String get medalPathStreak3Title;

  /// No description provided for @medalPerfectBossHint.
  ///
  /// In pt, this message translates to:
  /// **'Venceu um desafio final com 100% de acertos'**
  String get medalPerfectBossHint;

  /// No description provided for @medalPerfectBossTitle.
  ///
  /// In pt, this message translates to:
  /// **'Prova impecável'**
  String get medalPerfectBossTitle;

  /// No description provided for @medalProximityAction.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta {units} · {track}} other{Faltam {units} · {track}}}'**
  String medalProximityAction(int count, String units, String track);

  /// units = medalUnit* already counted (e.g. '3 capítulos'); count = remaining.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta {units} para {tier} em {track}} other{Faltam {units} para {tier} em {track}}}'**
  String medalProximityLeft(int count, String units, String tier, String track);

  /// No description provided for @medalProximityRemaining.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta {units}} other{Faltam {units}}}'**
  String medalProximityRemaining(int count, String units);

  /// No description provided for @medalProximityShortLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 para {tier}} other{Faltam {count} para {tier}}}'**
  String medalProximityShortLeft(int count, String tier);

  /// No description provided for @medalProximityShortToward.
  ///
  /// In pt, this message translates to:
  /// **'{current}/{target} rumo a {tier}'**
  String medalProximityShortToward(int current, int target, String tier);

  /// No description provided for @medalProximityToward.
  ///
  /// In pt, this message translates to:
  /// **'{units} rumo a {tier} em {track}'**
  String medalProximityToward(String units, String tier, String track);

  /// No description provided for @medalRareLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 {unit} para «{title}»} other{Faltam {count} {unit} para «{title}»}}'**
  String medalRareLeft(int count, String unit, String title);

  /// No description provided for @medalRareShortLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 para «{title}»} other{Faltam {count} para «{title}»}}'**
  String medalRareShortLeft(int count, String title);

  /// No description provided for @medalRareVaultSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Medalhas excepcionais — só aparecem quando você ganha'**
  String get medalRareVaultSubtitle;

  /// No description provided for @medalRareVaultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Raras'**
  String get medalRareVaultTitle;

  /// No description provided for @medalReflectionDeepHint.
  ///
  /// In pt, this message translates to:
  /// **'Registrou 40 reflexões no diário de cenas'**
  String get medalReflectionDeepHint;

  /// No description provided for @medalReflectionDeepTitle.
  ///
  /// In pt, this message translates to:
  /// **'Diário profundo'**
  String get medalReflectionDeepTitle;

  /// No description provided for @medalSeasonFirstWeekTitle.
  ///
  /// In pt, this message translates to:
  /// **'Primeira semana'**
  String get medalSeasonFirstWeekTitle;

  /// No description provided for @medalTierAurora.
  ///
  /// In pt, this message translates to:
  /// **'Ultra rara'**
  String get medalTierAurora;

  /// No description provided for @medalTierBronze.
  ///
  /// In pt, this message translates to:
  /// **'Bronze'**
  String get medalTierBronze;

  /// No description provided for @medalTierDiamond.
  ///
  /// In pt, this message translates to:
  /// **'Diamante'**
  String get medalTierDiamond;

  /// No description provided for @medalTierGold.
  ///
  /// In pt, this message translates to:
  /// **'Ouro'**
  String get medalTierGold;

  /// No description provided for @medalTierIron.
  ///
  /// In pt, this message translates to:
  /// **'Ferro'**
  String get medalTierIron;

  /// No description provided for @medalTierMirra.
  ///
  /// In pt, this message translates to:
  /// **'Mirra'**
  String get medalTierMirra;

  /// No description provided for @medalTierPlatinum.
  ///
  /// In pt, this message translates to:
  /// **'Platina'**
  String get medalTierPlatinum;

  /// No description provided for @medalTierSilver.
  ///
  /// In pt, this message translates to:
  /// **'Prata'**
  String get medalTierSilver;

  /// No description provided for @medalTrackComplete.
  ///
  /// In pt, this message translates to:
  /// **'Completa'**
  String get medalTrackComplete;

  /// No description provided for @medalTrackFormationSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Acertos e domínio nas cenas'**
  String get medalTrackFormationSubtitle;

  /// No description provided for @medalTrackFormationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Formação'**
  String get medalTrackFormationTitle;

  /// No description provided for @medalTrackMemorySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Versículos guardados no coração'**
  String get medalTrackMemorySubtitle;

  /// No description provided for @medalTrackMemoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Memória'**
  String get medalTrackMemoryTitle;

  /// No description provided for @medalTrackPathSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Sequência na jornada'**
  String get medalTrackPathSubtitle;

  /// No description provided for @medalTrackPathTitle.
  ///
  /// In pt, this message translates to:
  /// **'Caminho'**
  String get medalTrackPathTitle;

  /// No description provided for @medalTrackUnlit.
  ///
  /// In pt, this message translates to:
  /// **'A acender'**
  String get medalTrackUnlit;

  /// No description provided for @medalTrackWitnessSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar a Palavra'**
  String get medalTrackWitnessSubtitle;

  /// No description provided for @medalTrackWitnessTitle.
  ///
  /// In pt, this message translates to:
  /// **'Testemunho'**
  String get medalTrackWitnessTitle;

  /// No description provided for @medalTrackWordSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Leitura bíblica na jornada'**
  String get medalTrackWordSubtitle;

  /// No description provided for @medalTrackWordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Palavra'**
  String get medalTrackWordTitle;

  /// No description provided for @medalTrailFinalModeHint.
  ///
  /// In pt, this message translates to:
  /// **'Conclua a trilha no modo {mode}'**
  String medalTrailFinalModeHint(String mode);

  /// No description provided for @medalTrailFirstSceneHint.
  ///
  /// In pt, this message translates to:
  /// **'Conclua 1 cena nesta trilha'**
  String get medalTrailFirstSceneHint;

  /// No description provided for @medalTrailFirstSceneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Primeira cena'**
  String get medalTrailFirstSceneTitle;

  /// No description provided for @medalTrailFlawlessHint.
  ///
  /// In pt, this message translates to:
  /// **'Concluiu uma trilha inteira com 100% em todas as cenas'**
  String get medalTrailFlawlessHint;

  /// No description provided for @medalTrailFlawlessTitle.
  ///
  /// In pt, this message translates to:
  /// **'Trilha impecável'**
  String get medalTrailFlawlessTitle;

  /// No description provided for @medalTrailModeHint.
  ///
  /// In pt, this message translates to:
  /// **'Conclua o modo {mode}'**
  String medalTrailModeHint(String mode);

  /// No description provided for @medalTrailTrackSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Progresso nesta trilha'**
  String get medalTrailTrackSubtitle;

  /// No description provided for @medalUnitAdventDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia no Advento} other{{count} dias no Advento}}'**
  String medalUnitAdventDays(int count);

  /// No description provided for @medalUnitChapters.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 capítulo} other{{count} capítulos}}'**
  String medalUnitChapters(int count);

  /// No description provided for @medalUnitLentDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia na Quaresma} other{{count} dias na Quaresma}}'**
  String medalUnitLentDays(int count);

  /// No description provided for @medalUnitMemorizedVerses.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 versículo memorizado} other{{count} versículos memorizados}}'**
  String medalUnitMemorizedVerses(int count);

  /// No description provided for @medalUnitPerfectScenes.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 cena perfeita} other{{count} cenas perfeitas}}'**
  String medalUnitPerfectScenes(int count);

  /// No description provided for @medalUnitSharedVerses.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 versículo compartilhado} other{{count} versículos compartilhados}}'**
  String medalUnitSharedVerses(int count);

  /// No description provided for @medalUnitStreakDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia de sequência} other{{count} dias de sequência}}'**
  String medalUnitStreakDays(int count);

  /// No description provided for @medalVaultAllMedals.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 medalha} other{Todas as {count} medalhas}}'**
  String medalVaultAllMedals(int count);

  /// No description provided for @medalVaultCompleteBody.
  ///
  /// In pt, this message translates to:
  /// **'Você iluminou cada medalha deste cofre. Continue caminhando na Palavra.'**
  String get medalVaultCompleteBody;

  /// No description provided for @medalVaultCompleteLabel.
  ///
  /// In pt, this message translates to:
  /// **'Cofre completo'**
  String get medalVaultCompleteLabel;

  /// No description provided for @medalVaultDiscoveries.
  ///
  /// In pt, this message translates to:
  /// **'Descobertas'**
  String get medalVaultDiscoveries;

  /// No description provided for @medalVaultEmptyHint.
  ///
  /// In pt, this message translates to:
  /// **'Cada cena concluída aproxima você de uma medalha. A primeira está perto.'**
  String get medalVaultEmptyHint;

  /// No description provided for @medalVaultMysteryEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Revelam-se no caminho — sem dica.'**
  String get medalVaultMysteryEmpty;

  /// No description provided for @medalVaultMysteryMore.
  ///
  /// In pt, this message translates to:
  /// **'Outras se revelam no caminho.'**
  String get medalVaultMysteryMore;

  /// No description provided for @medalVaultNextSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Próxima medalha: {message}'**
  String medalVaultNextSemantics(String message);

  /// No description provided for @medalVaultNextTitle.
  ///
  /// In pt, this message translates to:
  /// **'Próxima medalha'**
  String get medalVaultNextTitle;

  /// No description provided for @medalVaultRemaining.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 {unit}} other{Faltam {count} {unit}}}'**
  String medalVaultRemaining(int count, String unit);

  /// No description provided for @medalVaultSeason.
  ///
  /// In pt, this message translates to:
  /// **'Estação'**
  String get medalVaultSeason;

  /// No description provided for @medalVaultTabJourney.
  ///
  /// In pt, this message translates to:
  /// **'Jornada'**
  String get medalVaultTabJourney;

  /// No description provided for @medalVaultTabTrails.
  ///
  /// In pt, this message translates to:
  /// **'Trilhas'**
  String get medalVaultTabTrails;

  /// No description provided for @medalVaultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Medalhas'**
  String get medalVaultTitle;

  /// No description provided for @medalWalkingInLightHint.
  ///
  /// In pt, this message translates to:
  /// **'Manteve 85%+ de acertos (mín. 50 questões)'**
  String get medalWalkingInLightHint;

  /// No description provided for @medalWalkingInLightTitle.
  ///
  /// In pt, this message translates to:
  /// **'Andando na luz'**
  String get medalWalkingInLightTitle;

  /// No description provided for @medalWitnessShare10Title.
  ///
  /// In pt, this message translates to:
  /// **'Semeador'**
  String get medalWitnessShare10Title;

  /// No description provided for @medalWitnessShare1Title.
  ///
  /// In pt, this message translates to:
  /// **'Palavra levada'**
  String get medalWitnessShare1Title;

  /// No description provided for @medalWitnessShare50Title.
  ///
  /// In pt, this message translates to:
  /// **'Voz na caravana'**
  String get medalWitnessShare50Title;

  /// No description provided for @medalWordChapters100Title.
  ///
  /// In pt, this message translates to:
  /// **'Leitor constante'**
  String get medalWordChapters100Title;

  /// No description provided for @medalWordChapters1Title.
  ///
  /// In pt, this message translates to:
  /// **'Primeira Palavra'**
  String get medalWordChapters1Title;

  /// No description provided for @medalWordChapters25Title.
  ///
  /// In pt, this message translates to:
  /// **'Leitor atento'**
  String get medalWordChapters25Title;

  /// No description provided for @memoryCard.
  ///
  /// In pt, this message translates to:
  /// **'Carta'**
  String get memoryCard;

  /// No description provided for @memoryDoneSummary.
  ///
  /// In pt, this message translates to:
  /// **'{known} firmes · {learning} em progresso'**
  String memoryDoneSummary(int known, int learning);

  /// No description provided for @memoryDoneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sessão concluída'**
  String get memoryDoneTitle;

  /// No description provided for @memoryKnown.
  ///
  /// In pt, this message translates to:
  /// **'Já sei'**
  String get memoryKnown;

  /// No description provided for @memoryNotYet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não'**
  String get memoryNotYet;

  /// No description provided for @memoryReveal.
  ///
  /// In pt, this message translates to:
  /// **'Revelar'**
  String get memoryReveal;

  /// No description provided for @memorySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Fixe na memória'**
  String get memorySubtitle;

  /// No description provided for @memoryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Memorizar'**
  String get memoryTitle;

  /// No description provided for @modeBadgeCleared.
  ///
  /// In pt, this message translates to:
  /// **'Concluída'**
  String get modeBadgeCleared;

  /// No description provided for @modeBadgeCurrent.
  ///
  /// In pt, this message translates to:
  /// **'Atual'**
  String get modeBadgeCurrent;

  /// No description provided for @modeBadgeHere.
  ///
  /// In pt, this message translates to:
  /// **'Você está aqui'**
  String get modeBadgeHere;

  /// No description provided for @modeBadgeInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Em andamento'**
  String get modeBadgeInProgress;

  /// No description provided for @modeBadgeLocked.
  ///
  /// In pt, this message translates to:
  /// **'Bloqueada'**
  String get modeBadgeLocked;

  /// No description provided for @modeBadgeReview.
  ///
  /// In pt, this message translates to:
  /// **'Revisão'**
  String get modeBadgeReview;

  /// No description provided for @modeBannerHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque para trocar de modo'**
  String get modeBannerHint;

  /// No description provided for @modeBannerSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Modo de estudo: {name}. {tagline}.'**
  String modeBannerSemantics(String name, String tagline);

  /// No description provided for @modeCaminhadaBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Ligue os fatos: causas, contexto e o fio da narrativa.'**
  String get modeCaminhadaBlurb;

  /// Nome do 2º modo (id interno caminhada)
  ///
  /// In pt, this message translates to:
  /// **'Compreensão'**
  String get modeCaminhadaLabel;

  /// No description provided for @modeCaminhadaSkill1.
  ///
  /// In pt, this message translates to:
  /// **'Relacionar'**
  String get modeCaminhadaSkill1;

  /// No description provided for @modeCaminhadaSkill2.
  ///
  /// In pt, this message translates to:
  /// **'Comparar'**
  String get modeCaminhadaSkill2;

  /// No description provided for @modeCaminhadaSkill3.
  ///
  /// In pt, this message translates to:
  /// **'Encadear'**
  String get modeCaminhadaSkill3;

  /// No description provided for @modeCaminhadaTagline.
  ///
  /// In pt, this message translates to:
  /// **'O que o texto comunica'**
  String get modeCaminhadaTagline;

  /// Legenda sob o emblema do modo
  ///
  /// In pt, this message translates to:
  /// **'concluída'**
  String get modeCaptionCleared;

  /// No description provided for @modeCaptionCurrent.
  ///
  /// In pt, this message translates to:
  /// **'atual'**
  String get modeCaptionCurrent;

  /// No description provided for @modeCaptionLocked.
  ///
  /// In pt, this message translates to:
  /// **'bloqueada'**
  String get modeCaptionLocked;

  /// Modo concluído; name = nome do modo (Observação…)
  ///
  /// In pt, this message translates to:
  /// **'{name} concluída'**
  String modeCleared(String name);

  /// No description provided for @modeClearedReview.
  ///
  /// In pt, this message translates to:
  /// **'Concluída · revise quando quiser'**
  String get modeClearedReview;

  /// No description provided for @modeCtaContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar em {name}'**
  String modeCtaContinue(String name);

  /// No description provided for @modeCtaReview.
  ///
  /// In pt, this message translates to:
  /// **'Revisar {name}'**
  String modeCtaReview(String name);

  /// No description provided for @modeCtaStart.
  ///
  /// In pt, this message translates to:
  /// **'Começar em {name}'**
  String modeCtaStart(String name);

  /// No description provided for @modeCtaStudy.
  ///
  /// In pt, this message translates to:
  /// **'Estudar em {name}'**
  String modeCtaStudy(String name);

  /// No description provided for @modeCurrent.
  ///
  /// In pt, this message translates to:
  /// **'{name} atual'**
  String modeCurrent(String name);

  /// No description provided for @modeLockHint.
  ///
  /// In pt, this message translates to:
  /// **'Conclua {name} para liberar'**
  String modeLockHint(String name);

  /// No description provided for @modeLocked.
  ///
  /// In pt, this message translates to:
  /// **'{name} bloqueada'**
  String modeLocked(String name);

  /// No description provided for @modeNamed.
  ///
  /// In pt, this message translates to:
  /// **'Modo {name}'**
  String modeNamed(String name);

  /// ordinal = I, II, III
  ///
  /// In pt, this message translates to:
  /// **'Modo {ordinal}'**
  String modeOrdinal(String ordinal);

  /// No description provided for @modeOrdinalBadge.
  ///
  /// In pt, this message translates to:
  /// **'Modo {ordinal} · {badge}'**
  String modeOrdinalBadge(String ordinal, String badge);

  /// No description provided for @modePickerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como você quer\nestudar?'**
  String get modePickerTitle;

  /// No description provided for @modePickerTopBar.
  ///
  /// In pt, this message translates to:
  /// **'Antes de partir'**
  String get modePickerTopBar;

  /// No description provided for @modePrevAlmostDone.
  ///
  /// In pt, this message translates to:
  /// **'{name} quase concluída'**
  String modePrevAlmostDone(String name);

  /// No description provided for @modeProfundezasBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Busque o sentido: o que o texto revela de Deus e para você.'**
  String get modeProfundezasBlurb;

  /// Nome do 3º modo (id interno profundezas)
  ///
  /// In pt, this message translates to:
  /// **'Interpretação'**
  String get modeProfundezasLabel;

  /// No description provided for @modeProfundezasSkill1.
  ///
  /// In pt, this message translates to:
  /// **'Interpretar'**
  String get modeProfundezasSkill1;

  /// No description provided for @modeProfundezasSkill2.
  ///
  /// In pt, this message translates to:
  /// **'Sustentar'**
  String get modeProfundezasSkill2;

  /// No description provided for @modeProfundezasSkill3.
  ///
  /// In pt, this message translates to:
  /// **'Aplicar'**
  String get modeProfundezasSkill3;

  /// No description provided for @modeProfundezasTagline.
  ///
  /// In pt, this message translates to:
  /// **'O que o texto significa'**
  String get modeProfundezasTagline;

  /// No description provided for @modeRuleFootnote.
  ///
  /// In pt, this message translates to:
  /// **'Três leituras do mesmo texto · conclua um modo para liberar o próximo'**
  String get modeRuleFootnote;

  /// No description provided for @modeScenesLeft.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 cena de {name}} other{Faltam {count} cenas de {name}}}'**
  String modeScenesLeft(int count, String name);

  /// No description provided for @modeScenesProgress.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total} cenas'**
  String modeScenesProgress(int done, int total);

  /// No description provided for @modeSementeBlurb.
  ///
  /// In pt, this message translates to:
  /// **'Repare nas palavras, nos fatos e na ordem em que acontecem.'**
  String get modeSementeBlurb;

  /// Nome do 1º modo (id interno semente)
  ///
  /// In pt, this message translates to:
  /// **'Observação'**
  String get modeSementeLabel;

  /// No description provided for @modeSementeSkill1.
  ///
  /// In pt, this message translates to:
  /// **'Reconhecer'**
  String get modeSementeSkill1;

  /// No description provided for @modeSementeSkill2.
  ///
  /// In pt, this message translates to:
  /// **'Identificar'**
  String get modeSementeSkill2;

  /// No description provided for @modeSementeSkill3.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar'**
  String get modeSementeSkill3;

  /// No description provided for @modeSementeTagline.
  ///
  /// In pt, this message translates to:
  /// **'O que o texto diz'**
  String get modeSementeTagline;

  /// No description provided for @modeSessionFootnote.
  ///
  /// In pt, this message translates to:
  /// **'Troca só nesta sessão · ao fechar o app, volta para {mode}'**
  String modeSessionFootnote(String mode);

  /// No description provided for @modeSheetEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Modo de estudo'**
  String get modeSheetEyebrow;

  /// No description provided for @modeSheetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como você quer estudar?'**
  String get modeSheetTitle;

  /// No description provided for @modeStartFirstScene.
  ///
  /// In pt, this message translates to:
  /// **'Comece pela primeira cena'**
  String get modeStartFirstScene;

  /// No description provided for @modeSwitch.
  ///
  /// In pt, this message translates to:
  /// **'Trocar'**
  String get modeSwitch;

  /// No description provided for @morphAbsolute.
  ///
  /// In pt, this message translates to:
  /// **'absoluto'**
  String get morphAbsolute;

  /// No description provided for @morphAdjective.
  ///
  /// In pt, this message translates to:
  /// **'adjetivo'**
  String get morphAdjective;

  /// No description provided for @morphAdverb.
  ///
  /// In pt, this message translates to:
  /// **'advérbio'**
  String get morphAdverb;

  /// No description provided for @morphAdverbConjAc.
  ///
  /// In pt, this message translates to:
  /// **'advérbio/conj. (ac)'**
  String get morphAdverbConjAc;

  /// No description provided for @morphArticle.
  ///
  /// In pt, this message translates to:
  /// **'artigo'**
  String get morphArticle;

  /// No description provided for @morphBoth.
  ///
  /// In pt, this message translates to:
  /// **'ambos'**
  String get morphBoth;

  /// No description provided for @morphCaseAccusative.
  ///
  /// In pt, this message translates to:
  /// **'acusativo'**
  String get morphCaseAccusative;

  /// No description provided for @morphCaseDative.
  ///
  /// In pt, this message translates to:
  /// **'dativo'**
  String get morphCaseDative;

  /// No description provided for @morphCaseGenitive.
  ///
  /// In pt, this message translates to:
  /// **'genitivo'**
  String get morphCaseGenitive;

  /// No description provided for @morphCaseNominative.
  ///
  /// In pt, this message translates to:
  /// **'nominativo'**
  String get morphCaseNominative;

  /// No description provided for @morphCaseVocative.
  ///
  /// In pt, this message translates to:
  /// **'vocativo'**
  String get morphCaseVocative;

  /// No description provided for @morphConjConsecutive.
  ///
  /// In pt, this message translates to:
  /// **'conjunção consecut./conj.'**
  String get morphConjConsecutive;

  /// No description provided for @morphConjunction.
  ///
  /// In pt, this message translates to:
  /// **'conjunção'**
  String get morphConjunction;

  /// No description provided for @morphConstruct.
  ///
  /// In pt, this message translates to:
  /// **'construto'**
  String get morphConstruct;

  /// No description provided for @morphDemonstrativeArticle.
  ///
  /// In pt, this message translates to:
  /// **'artigo demonstrativo'**
  String get morphDemonstrativeArticle;

  /// No description provided for @morphDetermined.
  ///
  /// In pt, this message translates to:
  /// **'determinado'**
  String get morphDetermined;

  /// No description provided for @morphDivineName.
  ///
  /// In pt, this message translates to:
  /// **'nome divino'**
  String get morphDivineName;

  /// No description provided for @morphDual.
  ///
  /// In pt, this message translates to:
  /// **'dual'**
  String get morphDual;

  /// No description provided for @morphExtraGentilic.
  ///
  /// In pt, this message translates to:
  /// **'gentílico'**
  String get morphExtraGentilic;

  /// No description provided for @morphExtraLocal.
  ///
  /// In pt, this message translates to:
  /// **'local'**
  String get morphExtraLocal;

  /// No description provided for @morphExtraProper.
  ///
  /// In pt, this message translates to:
  /// **'nome próprio'**
  String get morphExtraProper;

  /// No description provided for @morphExtraTitle.
  ///
  /// In pt, this message translates to:
  /// **'título'**
  String get morphExtraTitle;

  /// No description provided for @morphFem.
  ///
  /// In pt, this message translates to:
  /// **'fem.'**
  String get morphFem;

  /// No description provided for @morphGenderFeminine.
  ///
  /// In pt, this message translates to:
  /// **'feminino'**
  String get morphGenderFeminine;

  /// No description provided for @morphGenderMasculine.
  ///
  /// In pt, this message translates to:
  /// **'masculino'**
  String get morphGenderMasculine;

  /// No description provided for @morphInConstruct.
  ///
  /// In pt, this message translates to:
  /// **'em construto'**
  String get morphInConstruct;

  /// No description provided for @morphInterjection.
  ///
  /// In pt, this message translates to:
  /// **'interjeição'**
  String get morphInterjection;

  /// No description provided for @morphLangAramaic.
  ///
  /// In pt, this message translates to:
  /// **'aramaico'**
  String get morphLangAramaic;

  /// No description provided for @morphLangGreek.
  ///
  /// In pt, this message translates to:
  /// **'grego'**
  String get morphLangGreek;

  /// No description provided for @morphLangHebrew.
  ///
  /// In pt, this message translates to:
  /// **'hebraico'**
  String get morphLangHebrew;

  /// No description provided for @morphMasc.
  ///
  /// In pt, this message translates to:
  /// **'masc.'**
  String get morphMasc;

  /// No description provided for @morphMoodImperative.
  ///
  /// In pt, this message translates to:
  /// **'imperativo'**
  String get morphMoodImperative;

  /// No description provided for @morphMoodIndicative.
  ///
  /// In pt, this message translates to:
  /// **'indicativo'**
  String get morphMoodIndicative;

  /// No description provided for @morphMoodInfinitive.
  ///
  /// In pt, this message translates to:
  /// **'infinitivo'**
  String get morphMoodInfinitive;

  /// No description provided for @morphMoodOptative.
  ///
  /// In pt, this message translates to:
  /// **'optativo'**
  String get morphMoodOptative;

  /// No description provided for @morphMoodParticiple.
  ///
  /// In pt, this message translates to:
  /// **'particípio'**
  String get morphMoodParticiple;

  /// No description provided for @morphMoodSubjunctive.
  ///
  /// In pt, this message translates to:
  /// **'subjuntivo'**
  String get morphMoodSubjunctive;

  /// No description provided for @morphNegativeParticle.
  ///
  /// In pt, this message translates to:
  /// **'partícula negativa'**
  String get morphNegativeParticle;

  /// No description provided for @morphNeuter.
  ///
  /// In pt, this message translates to:
  /// **'neutro'**
  String get morphNeuter;

  /// No description provided for @morphNoun.
  ///
  /// In pt, this message translates to:
  /// **'substantivo'**
  String get morphNoun;

  /// No description provided for @morphNounCommon.
  ///
  /// In pt, this message translates to:
  /// **'comum'**
  String get morphNounCommon;

  /// No description provided for @morphNounGentilic.
  ///
  /// In pt, this message translates to:
  /// **'gentílico'**
  String get morphNounGentilic;

  /// No description provided for @morphNounPlace.
  ///
  /// In pt, this message translates to:
  /// **'lugar'**
  String get morphNounPlace;

  /// No description provided for @morphNounProper.
  ///
  /// In pt, this message translates to:
  /// **'próprio'**
  String get morphNounProper;

  /// No description provided for @morphNounTitle.
  ///
  /// In pt, this message translates to:
  /// **'título'**
  String get morphNounTitle;

  /// No description provided for @morphNumberDual.
  ///
  /// In pt, this message translates to:
  /// **'dual'**
  String get morphNumberDual;

  /// No description provided for @morphNumberPlural.
  ///
  /// In pt, this message translates to:
  /// **'plural'**
  String get morphNumberPlural;

  /// No description provided for @morphNumberSingular.
  ///
  /// In pt, this message translates to:
  /// **'singular'**
  String get morphNumberSingular;

  /// No description provided for @morphObjectMarker.
  ///
  /// In pt, this message translates to:
  /// **'marcador de objeto'**
  String get morphObjectMarker;

  /// No description provided for @morphParticle.
  ///
  /// In pt, this message translates to:
  /// **'partícula'**
  String get morphParticle;

  /// No description provided for @morphParticleInterrogative.
  ///
  /// In pt, this message translates to:
  /// **'partícula interrogativa'**
  String get morphParticleInterrogative;

  /// No description provided for @morphPerson1.
  ///
  /// In pt, this message translates to:
  /// **'1ª pessoa'**
  String get morphPerson1;

  /// No description provided for @morphPerson1p.
  ///
  /// In pt, this message translates to:
  /// **'1ª pl.'**
  String get morphPerson1p;

  /// No description provided for @morphPerson1s.
  ///
  /// In pt, this message translates to:
  /// **'1ª sing.'**
  String get morphPerson1s;

  /// No description provided for @morphPerson2.
  ///
  /// In pt, this message translates to:
  /// **'2ª pessoa'**
  String get morphPerson2;

  /// No description provided for @morphPerson2p.
  ///
  /// In pt, this message translates to:
  /// **'2ª pl.'**
  String get morphPerson2p;

  /// No description provided for @morphPerson2s.
  ///
  /// In pt, this message translates to:
  /// **'2ª sing.'**
  String get morphPerson2s;

  /// No description provided for @morphPerson3.
  ///
  /// In pt, this message translates to:
  /// **'3ª pessoa'**
  String get morphPerson3;

  /// No description provided for @morphPerson3p.
  ///
  /// In pt, this message translates to:
  /// **'3ª pl.'**
  String get morphPerson3p;

  /// No description provided for @morphPerson3s.
  ///
  /// In pt, this message translates to:
  /// **'3ª sing.'**
  String get morphPerson3s;

  /// No description provided for @morphPhraseConj.
  ///
  /// In pt, this message translates to:
  /// **'Conjunção.'**
  String get morphPhraseConj;

  /// No description provided for @morphPhraseConjGloss.
  ///
  /// In pt, this message translates to:
  /// **'Conjunção — {gloss}.'**
  String morphPhraseConjGloss(String gloss);

  /// No description provided for @morphPhraseHead.
  ///
  /// In pt, this message translates to:
  /// **'{head}.'**
  String morphPhraseHead(String head);

  /// No description provided for @morphPhraseHeadGloss.
  ///
  /// In pt, this message translates to:
  /// **'{head} — {gloss}.'**
  String morphPhraseHeadGloss(String head, String gloss);

  /// No description provided for @morphPhrasePersonOfNumber.
  ///
  /// In pt, this message translates to:
  /// **'{person} do {number}'**
  String morphPhrasePersonOfNumber(String person, String number);

  /// No description provided for @morphPhrasePrep.
  ///
  /// In pt, this message translates to:
  /// **'Preposição.'**
  String get morphPhrasePrep;

  /// No description provided for @morphPhrasePrepGloss.
  ///
  /// In pt, this message translates to:
  /// **'Preposição — {gloss}.'**
  String morphPhrasePrepGloss(String gloss);

  /// No description provided for @morphPhrasePrepSuffix.
  ///
  /// In pt, this message translates to:
  /// **'Preposição com sufixo pronominal.'**
  String get morphPhrasePrepSuffix;

  /// No description provided for @morphPhrasePrepSuffixGloss.
  ///
  /// In pt, this message translates to:
  /// **'Preposição com sufixo — {gloss}.'**
  String morphPhrasePrepSuffixGloss(String gloss);

  /// No description provided for @morphPhraseVerbBits.
  ///
  /// In pt, this message translates to:
  /// **'{bits} — {gloss}.'**
  String morphPhraseVerbBits(String bits, String gloss);

  /// No description provided for @morphPhraseVerbBitsPlain.
  ///
  /// In pt, this message translates to:
  /// **'{bits}.'**
  String morphPhraseVerbBitsPlain(String bits);

  /// No description provided for @morphPl.
  ///
  /// In pt, this message translates to:
  /// **'pl.'**
  String get morphPl;

  /// No description provided for @morphPrep.
  ///
  /// In pt, this message translates to:
  /// **'preposição'**
  String get morphPrep;

  /// No description provided for @morphPronominalSuffix.
  ///
  /// In pt, this message translates to:
  /// **'sufixo pronominal'**
  String get morphPronominalSuffix;

  /// No description provided for @morphPronounDemonstrative.
  ///
  /// In pt, this message translates to:
  /// **'pronome demonstrativo'**
  String get morphPronounDemonstrative;

  /// No description provided for @morphPronounPersonal.
  ///
  /// In pt, this message translates to:
  /// **'pronome pessoal'**
  String get morphPronounPersonal;

  /// No description provided for @morphPronounPossessive.
  ///
  /// In pt, this message translates to:
  /// **'pronome possessivo'**
  String get morphPronounPossessive;

  /// No description provided for @morphPronounReciprocal.
  ///
  /// In pt, this message translates to:
  /// **'pronome reciproc./correl.'**
  String get morphPronounReciprocal;

  /// No description provided for @morphPronounReflexive.
  ///
  /// In pt, this message translates to:
  /// **'pronome reflexivo'**
  String get morphPronounReflexive;

  /// No description provided for @morphPronounRelative.
  ///
  /// In pt, this message translates to:
  /// **'pronome relativo'**
  String get morphPronounRelative;

  /// No description provided for @morphRelativeParticle.
  ///
  /// In pt, this message translates to:
  /// **'partícula relativa'**
  String get morphRelativeParticle;

  /// No description provided for @morphSing.
  ///
  /// In pt, this message translates to:
  /// **'sing.'**
  String get morphSing;

  /// No description provided for @morphStemHifil.
  ///
  /// In pt, this message translates to:
  /// **'hifil'**
  String get morphStemHifil;

  /// No description provided for @morphStemHitpael.
  ///
  /// In pt, this message translates to:
  /// **'hitpael'**
  String get morphStemHitpael;

  /// No description provided for @morphStemHofal.
  ///
  /// In pt, this message translates to:
  /// **'hofal'**
  String get morphStemHofal;

  /// No description provided for @morphStemNifal.
  ///
  /// In pt, this message translates to:
  /// **'nifal'**
  String get morphStemNifal;

  /// No description provided for @morphStemPiel.
  ///
  /// In pt, this message translates to:
  /// **'piel'**
  String get morphStemPiel;

  /// No description provided for @morphStemPolal.
  ///
  /// In pt, this message translates to:
  /// **'polal'**
  String get morphStemPolal;

  /// No description provided for @morphStemPual.
  ///
  /// In pt, this message translates to:
  /// **'pual'**
  String get morphStemPual;

  /// No description provided for @morphStemPulal.
  ///
  /// In pt, this message translates to:
  /// **'pulal'**
  String get morphStemPulal;

  /// No description provided for @morphStemQal.
  ///
  /// In pt, this message translates to:
  /// **'qal'**
  String get morphStemQal;

  /// No description provided for @morphSuffix.
  ///
  /// In pt, this message translates to:
  /// **'sufixo'**
  String get morphSuffix;

  /// No description provided for @morphSuffixDirectional.
  ///
  /// In pt, this message translates to:
  /// **'direcional'**
  String get morphSuffixDirectional;

  /// No description provided for @morphSuffixNunParagogic.
  ///
  /// In pt, this message translates to:
  /// **'nun paragógico'**
  String get morphSuffixNunParagogic;

  /// No description provided for @morphSuffixParagogic.
  ///
  /// In pt, this message translates to:
  /// **'paragógico'**
  String get morphSuffixParagogic;

  /// No description provided for @morphSuffixPronominal.
  ///
  /// In pt, this message translates to:
  /// **'pronominal'**
  String get morphSuffixPronominal;

  /// No description provided for @morphTenseAorist.
  ///
  /// In pt, this message translates to:
  /// **'aoristo'**
  String get morphTenseAorist;

  /// No description provided for @morphTenseCohortative.
  ///
  /// In pt, this message translates to:
  /// **'coortativo'**
  String get morphTenseCohortative;

  /// No description provided for @morphTenseFuture.
  ///
  /// In pt, this message translates to:
  /// **'futuro'**
  String get morphTenseFuture;

  /// No description provided for @morphTenseImperative.
  ///
  /// In pt, this message translates to:
  /// **'imperativo'**
  String get morphTenseImperative;

  /// No description provided for @morphTenseImperfectGk.
  ///
  /// In pt, this message translates to:
  /// **'imperfeito'**
  String get morphTenseImperfectGk;

  /// No description provided for @morphTenseImperfectHeb.
  ///
  /// In pt, this message translates to:
  /// **'imperfecto'**
  String get morphTenseImperfectHeb;

  /// No description provided for @morphTenseInfAbsolute.
  ///
  /// In pt, this message translates to:
  /// **'infinitivo absoluto'**
  String get morphTenseInfAbsolute;

  /// No description provided for @morphTenseInfConstruct.
  ///
  /// In pt, this message translates to:
  /// **'infinitivo construto'**
  String get morphTenseInfConstruct;

  /// No description provided for @morphTenseJussive.
  ///
  /// In pt, this message translates to:
  /// **'jussivo'**
  String get morphTenseJussive;

  /// No description provided for @morphTenseParticiple.
  ///
  /// In pt, this message translates to:
  /// **'particípio'**
  String get morphTenseParticiple;

  /// No description provided for @morphTenseParticiplePassive.
  ///
  /// In pt, this message translates to:
  /// **'particípio passivo'**
  String get morphTenseParticiplePassive;

  /// No description provided for @morphTensePerfect.
  ///
  /// In pt, this message translates to:
  /// **'perfeito'**
  String get morphTensePerfect;

  /// No description provided for @morphTensePluperfect.
  ///
  /// In pt, this message translates to:
  /// **'mais-que-perfeito'**
  String get morphTensePluperfect;

  /// No description provided for @morphTensePresent.
  ///
  /// In pt, this message translates to:
  /// **'presente'**
  String get morphTensePresent;

  /// No description provided for @morphTenseSecondAorist.
  ///
  /// In pt, this message translates to:
  /// **'2º aoristo/futuro'**
  String get morphTenseSecondAorist;

  /// No description provided for @morphTenseUndefined.
  ///
  /// In pt, this message translates to:
  /// **'tempo indefinido'**
  String get morphTenseUndefined;

  /// No description provided for @morphTenseWayyiqtol.
  ///
  /// In pt, this message translates to:
  /// **'sequencial imperfecto (wayyiqtol)'**
  String get morphTenseWayyiqtol;

  /// No description provided for @morphTenseWeqatal.
  ///
  /// In pt, this message translates to:
  /// **'sequencial perfeito (weqatal)'**
  String get morphTenseWeqatal;

  /// No description provided for @morphVerb.
  ///
  /// In pt, this message translates to:
  /// **'verbo'**
  String get morphVerb;

  /// No description provided for @morphVoiceActive.
  ///
  /// In pt, this message translates to:
  /// **'ativa'**
  String get morphVoiceActive;

  /// No description provided for @morphVoiceImpersonal.
  ///
  /// In pt, this message translates to:
  /// **'impessoal'**
  String get morphVoiceImpersonal;

  /// No description provided for @morphVoiceMidPassDeponent.
  ///
  /// In pt, this message translates to:
  /// **'médio-passiva deponente'**
  String get morphVoiceMidPassDeponent;

  /// No description provided for @morphVoiceMiddle.
  ///
  /// In pt, this message translates to:
  /// **'média'**
  String get morphVoiceMiddle;

  /// No description provided for @morphVoiceMiddleDeponent.
  ///
  /// In pt, this message translates to:
  /// **'média deponente'**
  String get morphVoiceMiddleDeponent;

  /// No description provided for @morphVoiceMiddlePassive.
  ///
  /// In pt, this message translates to:
  /// **'médio-passiva'**
  String get morphVoiceMiddlePassive;

  /// No description provided for @morphVoicePassive.
  ///
  /// In pt, this message translates to:
  /// **'passiva'**
  String get morphVoicePassive;

  /// No description provided for @morphVoicePassiveDeponent.
  ///
  /// In pt, this message translates to:
  /// **'passiva deponente'**
  String get morphVoicePassiveDeponent;

  /// No description provided for @navBible.
  ///
  /// In pt, this message translates to:
  /// **'Bíblia'**
  String get navBible;

  /// Screen reader label for a bottom tab with a badge
  ///
  /// In pt, this message translates to:
  /// **'{tab}, com novidades'**
  String navTabWithNews(String tab);

  /// No description provided for @navTogether.
  ///
  /// In pt, this message translates to:
  /// **'Juntos'**
  String get navTogether;

  /// No description provided for @navTrails.
  ///
  /// In pt, this message translates to:
  /// **'Trilhas'**
  String get navTrails;

  /// No description provided for @notifChannelDesc.
  ///
  /// In pt, this message translates to:
  /// **'Meta diária, cenas, prática, memorização e favoritos'**
  String get notifChannelDesc;

  /// No description provided for @notifChannelName.
  ///
  /// In pt, this message translates to:
  /// **'Lembretes Stway'**
  String get notifChannelName;

  /// No description provided for @notifContinueTitle.
  ///
  /// In pt, this message translates to:
  /// **'Continue de onde parou'**
  String get notifContinueTitle;

  /// No description provided for @notifDailyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Do dia'**
  String get notifDailyTitle;

  /// No description provided for @notifFavoritesBody.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Você guardou um versículo. Que tal revisitá-lo agora?} other{Você tem {count} favoritos. Releia um e treine a memória.}}'**
  String notifFavoritesBody(int count);

  /// No description provided for @notifFavoritesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seus favoritos'**
  String get notifFavoritesTitle;

  /// No description provided for @notifGoalDoneBody.
  ///
  /// In pt, this message translates to:
  /// **'Meta feita. A sequência continua amanhã.'**
  String get notifGoalDoneBody;

  /// No description provided for @notifGoalLeftBody.
  ///
  /// In pt, this message translates to:
  /// **'{left, plural, =1{Falta 1 cena} other{Faltam {left} cenas}} para fechar a meta de hoje.'**
  String notifGoalLeftBody(int left);

  /// No description provided for @notifMemoryBody.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Um versículo espera por você. Dois minutos bastam.} other{{count} versículos no deck. Memorizar reforça o aprendizado.}}'**
  String notifMemoryBody(int count);

  /// No description provided for @notifMistakesBody.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Tem 1 erro para reforçar. Pratique agora e fixe o aprendizado.} other{Tem {count} erros para reforçar. Prática rápida, mente firme.}}'**
  String notifMistakesBody(int count);

  /// No description provided for @notifPracticeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Hora de praticar'**
  String get notifPracticeTitle;

  /// No description provided for @notifQuestsLeftBody.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Sobrou 1 gesto. Mais um e o dia fecha.} other{Ainda faltam {count} gestos do dia.}}'**
  String notifQuestsLeftBody(int count);

  /// No description provided for @notifResumeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Hora de retomar'**
  String get notifResumeTitle;

  /// No description provided for @notifReturningBody.
  ///
  /// In pt, this message translates to:
  /// **'{name}, faz {count, plural, =1{1 dia} other{{count} dias}} sem estudar. Uma cena retoma a sequência.'**
  String notifReturningBody(String name, int count);

  /// No description provided for @notifSceneWaitingBody.
  ///
  /// In pt, this message translates to:
  /// **'Uma cena por dia. A sequência continua amanhã.'**
  String get notifSceneWaitingBody;

  /// No description provided for @notifSceneWaitingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sua cena te espera'**
  String get notifSceneWaitingTitle;

  /// No description provided for @notifSceneWaitsBody.
  ///
  /// In pt, this message translates to:
  /// **'{name}, {title} espera.'**
  String notifSceneWaitsBody(String name, String title);

  /// No description provided for @notifSeeYouTomorrowTitle.
  ///
  /// In pt, this message translates to:
  /// **'Até amanhã'**
  String get notifSeeYouTomorrowTitle;

  /// No description provided for @notifSignature.
  ///
  /// In pt, this message translates to:
  /// **'O Peregrino'**
  String get notifSignature;

  /// No description provided for @notifStreakLeftBody.
  ///
  /// In pt, this message translates to:
  /// **'{name}, você já anda há {streak, plural, =1{1 dia} other{{streak} dias}}. {left, plural, =1{Falta 1 cena} other{Faltam {left} cenas}} para acompanhar.'**
  String notifStreakLeftBody(String name, int streak, int left);

  /// No description provided for @notifTodayGoalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meta de hoje'**
  String get notifTodayGoalTitle;

  /// No description provided for @notifTomorrowTitle.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã'**
  String get notifTomorrowTitle;

  /// No description provided for @notifTrialEndingBody.
  ///
  /// In pt, this message translates to:
  /// **'Gerencie sua assinatura Peregrino+ nas configurações se não quiser continuar.'**
  String get notifTrialEndingBody;

  /// No description provided for @notifTrialEndingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu teste grátis termina amanhã'**
  String get notifTrialEndingTitle;

  /// No description provided for @notifWeeklyLeftBody.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 passo semanal. Feche o ciclo com calma.} other{Ainda faltam {count} passos semanais. A semana ainda é sua.}}'**
  String notifWeeklyLeftBody(int count);

  /// No description provided for @notifWeeklyStepsBody.
  ///
  /// In pt, this message translates to:
  /// **'Ainda dá tempo de fechar a semana.'**
  String get notifWeeklyStepsBody;

  /// No description provided for @notifWeeklyStepsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Passos da semana'**
  String get notifWeeklyStepsTitle;

  /// No description provided for @nudgeAlreadySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Você já acenou hoje. Mande também no WhatsApp, se quiser.'**
  String get nudgeAlreadySubtitle;

  /// Share image, friend voice.
  ///
  /// In pt, this message translates to:
  /// **'Vem retomar comigo no Stway'**
  String get nudgeCardCta;

  /// No description provided for @nudgeCardDaysAway.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia sem estudar} other{{count} dias sem estudar}}'**
  String nudgeCardDaysAway(int count);

  /// Share image, friend voice.
  ///
  /// In pt, this message translates to:
  /// **'Senti sua falta hoje'**
  String get nudgeCardHeadline;

  /// No description provided for @nudgeCardWaiting.
  ///
  /// In pt, this message translates to:
  /// **'Te esperando'**
  String get nudgeCardWaiting;

  /// No description provided for @nudgeCardWalked.
  ///
  /// In pt, this message translates to:
  /// **'{name} já caminhou'**
  String nudgeCardWalked(String name);

  /// No description provided for @nudgeCompanionFallback.
  ///
  /// In pt, this message translates to:
  /// **'Companheiro'**
  String get nudgeCompanionFallback;

  /// Friend-to-friend wave message (casual, 1st person).
  ///
  /// In pt, this message translates to:
  /// **'Tô te esperando na trilha'**
  String get nudgeDefaultMessage;

  /// No description provided for @nudgeInAppSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Um aceno no app — {name} vê ao abrir o Stway.'**
  String nudgeInAppSubtitle(String name);

  /// No description provided for @nudgeSendFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar o aceno.'**
  String get nudgeSendFailed;

  /// No description provided for @nudgeSent.
  ///
  /// In pt, this message translates to:
  /// **'Aceno enviado. {name} vê ao abrir o Stway.'**
  String nudgeSent(String name);

  /// No description provided for @nudgeShareSubject.
  ///
  /// In pt, this message translates to:
  /// **'Vamos caminhar juntos?'**
  String get nudgeShareSubject;

  /// No description provided for @nudgeSignInSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entre na conta para acenar no app, ou mande no WhatsApp.'**
  String get nudgeSignInSubtitle;

  /// No description provided for @nudgeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Acenar para {name}'**
  String nudgeTitle(String name);

  /// No description provided for @offlineBody.
  ///
  /// In pt, this message translates to:
  /// **'Na primeira abertura, o Stway baixa o currículo da nuvem. Precisa de internet uma vez — depois fica no aparelho.'**
  String get offlineBody;

  /// No description provided for @offlineDownloadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível baixar as cenas. Tente de novo em instantes.'**
  String get offlineDownloadFailed;

  /// No description provided for @offlineDownloading.
  ///
  /// In pt, this message translates to:
  /// **'Baixando…'**
  String get offlineDownloading;

  /// No description provided for @offlineNoInternet.
  ///
  /// In pt, this message translates to:
  /// **'Sem internet no momento. Ligue o Wi‑Fi ou os dados e tente de novo.'**
  String get offlineNoInternet;

  /// No description provided for @offlineTitle.
  ///
  /// In pt, this message translates to:
  /// **'As cenas ainda não chegaram'**
  String get offlineTitle;

  /// No description provided for @onboardingAppearanceBody.
  ///
  /// In pt, this message translates to:
  /// **'Ela vale para o app inteiro.\nDá para trocar depois nos Ajustes.'**
  String get onboardingAppearanceBody;

  /// No description provided for @onboardingAppearanceSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Aparência {theme}'**
  String onboardingAppearanceSemantics(String theme);

  /// No description provided for @onboardingAppearanceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Escolha a aparência.'**
  String get onboardingAppearanceTitle;

  /// No description provided for @onboardingCommitmentLabel.
  ///
  /// In pt, this message translates to:
  /// **'Meu compromisso'**
  String get onboardingCommitmentLabel;

  /// No description provided for @onboardingDayOneOf.
  ///
  /// In pt, this message translates to:
  /// **'Hoje  ·  dia 1 de {goal}'**
  String onboardingDayOneOf(int goal);

  /// No description provided for @onboardingDefaultPromise.
  ///
  /// In pt, this message translates to:
  /// **'a primeira cena\njá está no caminho.'**
  String get onboardingDefaultPromise;

  /// No description provided for @onboardingEveryDay.
  ///
  /// In pt, this message translates to:
  /// **'Todo dia.'**
  String get onboardingEveryDay;

  /// No description provided for @onboardingFirstSceneMeta.
  ///
  /// In pt, this message translates to:
  /// **'Leia · responda · entenda  ·  ~3 min'**
  String get onboardingFirstSceneMeta;

  /// No description provided for @onboardingFirstSceneTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem criou o mundo?'**
  String get onboardingFirstSceneTitle;

  /// No description provided for @onboardingFiveLamps.
  ///
  /// In pt, this message translates to:
  /// **'5 lâmpadas'**
  String get onboardingFiveLamps;

  /// No description provided for @onboardingHabitBody.
  ///
  /// In pt, this message translates to:
  /// **'Conhecer a Deus não pede uma maratona.\nPede que você volte, todo dia.'**
  String get onboardingHabitBody;

  /// No description provided for @onboardingHoldToCommit.
  ///
  /// In pt, this message translates to:
  /// **'Segure para firmar'**
  String get onboardingHoldToCommit;

  /// No description provided for @onboardingHolding.
  ///
  /// In pt, this message translates to:
  /// **'Firmando…'**
  String get onboardingHolding;

  /// No description provided for @onboardingIntentBody.
  ///
  /// In pt, this message translates to:
  /// **'Cada cena: leia, responda, entenda.\nSeu motivo abre o caminho.'**
  String get onboardingIntentBody;

  /// No description provided for @onboardingIntentHabitCaption.
  ///
  /// In pt, this message translates to:
  /// **'todo dia'**
  String get onboardingIntentHabitCaption;

  /// No description provided for @onboardingIntentHabitPromise.
  ///
  /// In pt, this message translates to:
  /// **'a sequência\ncomeça hoje.'**
  String get onboardingIntentHabitPromise;

  /// No description provided for @onboardingIntentHabitTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar uma sequência'**
  String get onboardingIntentHabitTitle;

  /// No description provided for @onboardingIntentKnowCaption.
  ///
  /// In pt, this message translates to:
  /// **'de perto'**
  String get onboardingIntentKnowCaption;

  /// No description provided for @onboardingIntentKnowPromise.
  ///
  /// In pt, this message translates to:
  /// **'conhecer a Deus\ncomeça com uma cena.'**
  String get onboardingIntentKnowPromise;

  /// No description provided for @onboardingIntentKnowTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conhecer a Deus'**
  String get onboardingIntentKnowTitle;

  /// No description provided for @onboardingIntentPeaceCaption.
  ///
  /// In pt, this message translates to:
  /// **'um respiro'**
  String get onboardingIntentPeaceCaption;

  /// No description provided for @onboardingIntentPeacePromise.
  ///
  /// In pt, this message translates to:
  /// **'a paz do dia\ncomeça aqui.'**
  String get onboardingIntentPeacePromise;

  /// No description provided for @onboardingIntentPeaceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Paz no dia'**
  String get onboardingIntentPeaceTitle;

  /// No description provided for @onboardingIntentQuestion.
  ///
  /// In pt, this message translates to:
  /// **'O que te traz aqui?'**
  String get onboardingIntentQuestion;

  /// No description provided for @onboardingIntentUnderstandCaption.
  ///
  /// In pt, this message translates to:
  /// **'de verdade'**
  String get onboardingIntentUnderstandCaption;

  /// No description provided for @onboardingIntentUnderstandPromise.
  ///
  /// In pt, this message translates to:
  /// **'entender a Bíblia\ncomeça pelo começo.'**
  String get onboardingIntentUnderstandPromise;

  /// No description provided for @onboardingIntentUnderstandTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entender a Bíblia'**
  String get onboardingIntentUnderstandTitle;

  /// No description provided for @onboardingKickerAppearance.
  ///
  /// In pt, this message translates to:
  /// **'III   ·   Aparência'**
  String get onboardingKickerAppearance;

  /// No description provided for @onboardingKickerGoal.
  ///
  /// In pt, this message translates to:
  /// **'I   ·   A meta'**
  String get onboardingKickerGoal;

  /// No description provided for @onboardingKickerIntent.
  ///
  /// In pt, this message translates to:
  /// **'II   ·   Seu motivo'**
  String get onboardingKickerIntent;

  /// No description provided for @onboardingKickerJourney.
  ///
  /// In pt, this message translates to:
  /// **'V   ·   A jornada'**
  String get onboardingKickerJourney;

  /// No description provided for @onboardingKickerTomorrow.
  ///
  /// In pt, this message translates to:
  /// **'IV   ·   Amanhã'**
  String get onboardingKickerTomorrow;

  /// No description provided for @onboardingMinutes.
  ///
  /// In pt, this message translates to:
  /// **'Minutos'**
  String get onboardingMinutes;

  /// No description provided for @onboardingNameHint.
  ///
  /// In pt, this message translates to:
  /// **'seu nome'**
  String get onboardingNameHint;

  /// No description provided for @onboardingNamePrompt.
  ///
  /// In pt, this message translates to:
  /// **'Como te chamamos'**
  String get onboardingNamePrompt;

  /// No description provided for @onboardingOpening.
  ///
  /// In pt, this message translates to:
  /// **'Abrindo…'**
  String get onboardingOpening;

  /// No description provided for @onboardingPaceCaption.
  ///
  /// In pt, this message translates to:
  /// **'{scenes, plural, =1{1 cena por dia · ~{minutes} min} other{{scenes} cenas por dia · ~{minutes} min}}'**
  String onboardingPaceCaption(int scenes, int minutes);

  /// No description provided for @onboardingRemindAtLabel.
  ///
  /// In pt, this message translates to:
  /// **'Te lembramos às'**
  String get onboardingRemindAtLabel;

  /// No description provided for @onboardingReminderMorning.
  ///
  /// In pt, this message translates to:
  /// **'Um lembrete de manhã'**
  String get onboardingReminderMorning;

  /// No description provided for @onboardingReminderNight.
  ///
  /// In pt, this message translates to:
  /// **'Um lembrete à noite'**
  String get onboardingReminderNight;

  /// No description provided for @onboardingReminderNoon.
  ///
  /// In pt, this message translates to:
  /// **'Um lembrete ao meio-dia'**
  String get onboardingReminderNoon;

  /// No description provided for @onboardingStreakDays.
  ///
  /// In pt, this message translates to:
  /// **'{count} dias de sequência'**
  String onboardingStreakDays(int count);

  /// No description provided for @onboardingStreakMonth.
  ///
  /// In pt, this message translates to:
  /// **'Um mês inteiro'**
  String get onboardingStreakMonth;

  /// No description provided for @onboardingStreakTwoWeeks.
  ///
  /// In pt, this message translates to:
  /// **'Duas semanas de sequência'**
  String get onboardingStreakTwoWeeks;

  /// No description provided for @onboardingStreakWeek.
  ///
  /// In pt, this message translates to:
  /// **'Uma semana de sequência'**
  String get onboardingStreakWeek;

  /// No description provided for @onboardingTomorrowBody.
  ///
  /// In pt, this message translates to:
  /// **'O hábito nasce quando você volta.\nFirme com você mesmo um começo.'**
  String get onboardingTomorrowBody;

  /// No description provided for @onboardingTomorrowWord.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã'**
  String get onboardingTomorrowWord;

  /// No description provided for @onboardingYourPace.
  ///
  /// In pt, this message translates to:
  /// **'Seu ritmo'**
  String get onboardingYourPace;

  /// No description provided for @paywallAlreadyPlus.
  ///
  /// In pt, this message translates to:
  /// **'Você já é Peregrino+'**
  String get paywallAlreadyPlus;

  /// No description provided for @paywallHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Vá além na trilha'**
  String get paywallHeadline;

  /// No description provided for @paywallPerkSeason.
  ///
  /// In pt, this message translates to:
  /// **'A estação (Advento / Quaresma) — depois dos 3 dias grátis'**
  String get paywallPerkSeason;

  /// No description provided for @paywallPerkWeeklyReview.
  ///
  /// In pt, this message translates to:
  /// **'Revisão da semana: os 7 “Hoje:” + 3 perguntas'**
  String get paywallPerkWeeklyReview;

  /// No description provided for @paywallPitch.
  ///
  /// In pt, this message translates to:
  /// **'Um apoio direto ao projeto, com alguns extras.'**
  String get paywallPitch;

  /// No description provided for @paywallPriceAnnual.
  ///
  /// In pt, this message translates to:
  /// **'{price} por ano'**
  String paywallPriceAnnual(String price);

  /// No description provided for @paywallPriceLifetime.
  ///
  /// In pt, this message translates to:
  /// **'{price} pagamento único'**
  String paywallPriceLifetime(String price);

  /// No description provided for @paywallPriceMonthly.
  ///
  /// In pt, this message translates to:
  /// **'{price} por mês'**
  String paywallPriceMonthly(String price);

  /// No description provided for @paywallPriceMonths.
  ///
  /// In pt, this message translates to:
  /// **'{price} por {months} meses'**
  String paywallPriceMonths(int months, String price);

  /// No description provided for @paywallPriceWeekly.
  ///
  /// In pt, this message translates to:
  /// **'{price} por semana'**
  String paywallPriceWeekly(String price);

  /// No description provided for @paywallPurchaseFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível concluir a compra.'**
  String get paywallPurchaseFailed;

  /// No description provided for @paywallRestore.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar compra'**
  String get paywallRestore;

  /// No description provided for @paywallRestoreFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível restaurar a compra.'**
  String get paywallRestoreFailed;

  /// No description provided for @paywallThanks.
  ///
  /// In pt, this message translates to:
  /// **'Obrigado por apoiar o Stway.'**
  String get paywallThanks;

  /// Name of the supporter subscription
  ///
  /// In pt, this message translates to:
  /// **'Peregrino+'**
  String get paywallTitle;

  /// No description provided for @paywallUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Assinatura ainda não disponível nesta versão.'**
  String get paywallUnavailable;

  /// No description provided for @pilgrimAccuracyForming.
  ///
  /// In pt, this message translates to:
  /// **'Ainda em formação'**
  String get pilgrimAccuracyForming;

  /// No description provided for @pilgrimAccuracyGood.
  ///
  /// In pt, this message translates to:
  /// **'Boa compreensão nas cenas'**
  String get pilgrimAccuracyGood;

  /// No description provided for @pilgrimAccuracySharp.
  ///
  /// In pt, this message translates to:
  /// **'Leitura afiada das Escrituras'**
  String get pilgrimAccuracySharp;

  /// No description provided for @pilgrimAccuracySteady.
  ///
  /// In pt, this message translates to:
  /// **'Caminhando com firmeza'**
  String get pilgrimAccuracySteady;

  /// No description provided for @pilgrimAccuracyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Acertos'**
  String get pilgrimAccuracyTitle;

  /// No description provided for @pilgrimChaptersBooks.
  ///
  /// In pt, this message translates to:
  /// **'{chapters, plural, =1{1 capítulo} other{{chapters} capítulos}} · {books, plural, =1{1 livro} other{{books} livros}}'**
  String pilgrimChaptersBooks(int chapters, int books);

  /// No description provided for @pilgrimChaptersWordMedal.
  ///
  /// In pt, this message translates to:
  /// **'{chapters, plural, =1{1 capítulo} other{{chapters} capítulos}} · medalha Palavra'**
  String pilgrimChaptersWordMedal(int chapters);

  /// No description provided for @pilgrimCollections.
  ///
  /// In pt, this message translates to:
  /// **'Coleções'**
  String get pilgrimCollections;

  /// No description provided for @pilgrimCompletedOn.
  ///
  /// In pt, this message translates to:
  /// **'Concluída em {date}'**
  String pilgrimCompletedOn(String date);

  /// No description provided for @pilgrimCorrectOf.
  ///
  /// In pt, this message translates to:
  /// **'{correct} de {total}'**
  String pilgrimCorrectOf(int correct, int total);

  /// No description provided for @pilgrimCorrectOnJourney.
  ///
  /// In pt, this message translates to:
  /// **'perguntas certas na jornada'**
  String get pilgrimCorrectOnJourney;

  /// No description provided for @pilgrimCorrectRatio.
  ///
  /// In pt, this message translates to:
  /// **'{correct}/{total} certas'**
  String pilgrimCorrectRatio(int correct, int total);

  /// Shown when the user has no name
  ///
  /// In pt, this message translates to:
  /// **'Peregrino'**
  String get pilgrimFallbackName;

  /// No description provided for @pilgrimLastSeen.
  ///
  /// In pt, this message translates to:
  /// **'Visto por último · {when}'**
  String pilgrimLastSeen(String when);

  /// No description provided for @pilgrimLastStudyDay.
  ///
  /// In pt, this message translates to:
  /// **'Último dia de estudo'**
  String get pilgrimLastStudyDay;

  /// No description provided for @pilgrimLedOverall.
  ///
  /// In pt, this message translates to:
  /// **'Já liderou o ranking geral'**
  String get pilgrimLedOverall;

  /// No description provided for @pilgrimNoReadingYet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda sem leitura registrada'**
  String get pilgrimNoReadingYet;

  /// No description provided for @pilgrimNoTrailYet.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma trilha em andamento ainda.'**
  String get pilgrimNoTrailYet;

  /// No description provided for @pilgrimOnTheJourney.
  ///
  /// In pt, this message translates to:
  /// **'na jornada'**
  String get pilgrimOnTheJourney;

  /// No description provided for @pilgrimPrivacyBody.
  ///
  /// In pt, this message translates to:
  /// **'Toque no olho de cada card para escolher o que a caravana vê.'**
  String get pilgrimPrivacyBody;

  /// No description provided for @pilgrimPrivacyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade do perfil'**
  String get pilgrimPrivacyTitle;

  /// No description provided for @pilgrimPrivateBody.
  ///
  /// In pt, this message translates to:
  /// **'Escolheu não compartilhar detalhes com a caravana.'**
  String get pilgrimPrivateBody;

  /// No description provided for @pilgrimPrivateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil privado'**
  String get pilgrimPrivateTitle;

  /// No description provided for @pilgrimRank.
  ///
  /// In pt, this message translates to:
  /// **'{rank}º no ranking'**
  String pilgrimRank(int rank);

  /// No description provided for @pilgrimRankLeader.
  ///
  /// In pt, this message translates to:
  /// **'Líder do ranking'**
  String get pilgrimRankLeader;

  /// No description provided for @pilgrimRankListed.
  ///
  /// In pt, this message translates to:
  /// **'No ranking'**
  String get pilgrimRankListed;

  /// No description provided for @pilgrimRankMonthly.
  ///
  /// In pt, this message translates to:
  /// **'Ranking do mês'**
  String get pilgrimRankMonthly;

  /// No description provided for @pilgrimRankOrdinal.
  ///
  /// In pt, this message translates to:
  /// **'{rank}º'**
  String pilgrimRankOrdinal(int rank);

  /// No description provided for @pilgrimRankPodium.
  ///
  /// In pt, this message translates to:
  /// **'No pódio'**
  String get pilgrimRankPodium;

  /// No description provided for @pilgrimRankRunnerUp.
  ///
  /// In pt, this message translates to:
  /// **'Vice-líder'**
  String get pilgrimRankRunnerUp;

  /// No description provided for @pilgrimRankWeekly.
  ///
  /// In pt, this message translates to:
  /// **'Ranking semanal da caravana'**
  String get pilgrimRankWeekly;

  /// No description provided for @pilgrimSceneFallback.
  ///
  /// In pt, this message translates to:
  /// **'Cena'**
  String get pilgrimSceneFallback;

  /// No description provided for @pilgrimScenesOf.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total} cenas'**
  String pilgrimScenesOf(int done, int total);

  /// No description provided for @pilgrimScriptures.
  ///
  /// In pt, this message translates to:
  /// **'Escrituras'**
  String get pilgrimScriptures;

  /// No description provided for @pilgrimSealsAndTrails.
  ///
  /// In pt, this message translates to:
  /// **'Selos e trilhas'**
  String get pilgrimSealsAndTrails;

  /// No description provided for @pilgrimSeen.
  ///
  /// In pt, this message translates to:
  /// **'Visto'**
  String get pilgrimSeen;

  /// No description provided for @pilgrimStatScenes.
  ///
  /// In pt, this message translates to:
  /// **'Cenas'**
  String get pilgrimStatScenes;

  /// No description provided for @pilgrimStatSteps.
  ///
  /// In pt, this message translates to:
  /// **'Passos'**
  String get pilgrimStatSteps;

  /// No description provided for @pilgrimStreak.
  ///
  /// In pt, this message translates to:
  /// **'Sequência'**
  String get pilgrimStreak;

  /// No description provided for @pilgrimStreakOngoing.
  ///
  /// In pt, this message translates to:
  /// **'Em andamento'**
  String get pilgrimStreakOngoing;

  /// No description provided for @pilgrimTrail.
  ///
  /// In pt, this message translates to:
  /// **'Trilha'**
  String get pilgrimTrail;

  /// No description provided for @pilgrimTrailsInProgress.
  ///
  /// In pt, this message translates to:
  /// **'{count} em curso'**
  String pilgrimTrailsInProgress(int count);

  /// No description provided for @pilgrimWalked.
  ///
  /// In pt, this message translates to:
  /// **'Caminhou'**
  String get pilgrimWalked;

  /// No description provided for @pilgrimYourTrail.
  ///
  /// In pt, this message translates to:
  /// **'Sua trilha'**
  String get pilgrimYourTrail;

  /// No description provided for @pilgrimYourTrails.
  ///
  /// In pt, this message translates to:
  /// **'Suas trilhas'**
  String get pilgrimYourTrails;

  /// No description provided for @planAdjustTime.
  ///
  /// In pt, this message translates to:
  /// **'Ajustar tempo'**
  String get planAdjustTime;

  /// No description provided for @planAllRead.
  ///
  /// In pt, this message translates to:
  /// **'Tudo lido'**
  String get planAllRead;

  /// No description provided for @planAlreadyRead.
  ///
  /// In pt, this message translates to:
  /// **'Já lidos'**
  String get planAlreadyRead;

  /// No description provided for @planApproxDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{~1 dia} other{~{count} dias}}'**
  String planApproxDays(int count);

  /// No description provided for @planApproxHours.
  ///
  /// In pt, this message translates to:
  /// **'~{hours} h'**
  String planApproxHours(int hours);

  /// No description provided for @planApproxMinutes.
  ///
  /// In pt, this message translates to:
  /// **'~{minutes} min'**
  String planApproxMinutes(int minutes);

  /// No description provided for @planApproxMinutesDecimal.
  ///
  /// In pt, this message translates to:
  /// **'~{minutes} min'**
  String planApproxMinutesDecimal(String minutes);

  /// No description provided for @planApproxMonths.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{~1 mês} other{~{count} meses}}'**
  String planApproxMonths(int count);

  /// No description provided for @planAtYourPace.
  ///
  /// In pt, this message translates to:
  /// **'No seu ritmo'**
  String get planAtYourPace;

  /// No description provided for @planBibleFinished.
  ///
  /// In pt, this message translates to:
  /// **'Você concluiu a Bíblia neste plano.'**
  String get planBibleFinished;

  /// No description provided for @planCardDoneToday.
  ///
  /// In pt, this message translates to:
  /// **'Leitura de hoje feita'**
  String get planCardDoneToday;

  /// No description provided for @planCardIdle.
  ///
  /// In pt, this message translates to:
  /// **'Canônico ou cronológico, no seu tempo'**
  String get planCardIdle;

  /// No description provided for @planCardToday.
  ///
  /// In pt, this message translates to:
  /// **'{minutes} min hoje · {order}'**
  String planCardToday(int minutes, String order);

  /// No description provided for @planChaptersSkipped.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 capítulo pulado} other{{count} capítulos pulados}}'**
  String planChaptersSkipped(int count);

  /// No description provided for @planCreate.
  ///
  /// In pt, this message translates to:
  /// **'Criar um plano'**
  String get planCreate;

  /// No description provided for @planDayDoneToast.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Leitura do dia concluída · 1 capítulo} other{Leitura do dia concluída · {count} capítulos}}'**
  String planDayDoneToast(int count);

  /// No description provided for @planDone.
  ///
  /// In pt, this message translates to:
  /// **'Feito'**
  String get planDone;

  /// No description provided for @planEndConfirmAction.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar'**
  String get planEndConfirmAction;

  /// No description provided for @planEndConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Seu progresso no plano será zerado. Os capítulos já marcados como lidos na Bíblia permanecem.'**
  String get planEndConfirmBody;

  /// No description provided for @planEndConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar plano?'**
  String get planEndConfirmTitle;

  /// No description provided for @planEndCta.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar plano'**
  String get planEndCta;

  /// No description provided for @planEstimate.
  ///
  /// In pt, this message translates to:
  /// **'Estimativa'**
  String get planEstimate;

  /// No description provided for @planFinished.
  ///
  /// In pt, this message translates to:
  /// **'Plano concluído'**
  String get planFinished;

  /// No description provided for @planMarkDayRead.
  ///
  /// In pt, this message translates to:
  /// **'Marcar leitura do dia'**
  String get planMarkDayRead;

  /// No description provided for @planMinutes.
  ///
  /// In pt, this message translates to:
  /// **'{minutes} min'**
  String planMinutes(int minutes);

  /// No description provided for @planOrderAlphabetical.
  ///
  /// In pt, this message translates to:
  /// **'Ordem alfabética'**
  String get planOrderAlphabetical;

  /// No description provided for @planOrderAlphabeticalShort.
  ///
  /// In pt, this message translates to:
  /// **'Alfabética'**
  String get planOrderAlphabeticalShort;

  /// No description provided for @planOrderCanonical.
  ///
  /// In pt, this message translates to:
  /// **'Ordem da Bíblia'**
  String get planOrderCanonical;

  /// No description provided for @planOrderCanonicalShort.
  ///
  /// In pt, this message translates to:
  /// **'Canônica'**
  String get planOrderCanonicalShort;

  /// No description provided for @planOrderChronological.
  ///
  /// In pt, this message translates to:
  /// **'Ordem cronológica'**
  String get planOrderChronological;

  /// No description provided for @planOrderChronologicalShort.
  ///
  /// In pt, this message translates to:
  /// **'Cronológica'**
  String get planOrderChronologicalShort;

  /// No description provided for @planPendingChapters.
  ///
  /// In pt, this message translates to:
  /// **'Capítulos pendentes'**
  String get planPendingChapters;

  /// No description provided for @planPortionMeta.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{~{minutes} min · 1 capítulo · {order}} other{~{minutes} min · {count} capítulos · {order}}}'**
  String planPortionMeta(int minutes, int count, String order);

  /// No description provided for @planReadingDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia de leitura} other{{count} dias de leitura}}'**
  String planReadingDays(int count);

  /// No description provided for @planRemaining.
  ///
  /// In pt, this message translates to:
  /// **'Restante'**
  String get planRemaining;

  /// No description provided for @planSectionOrder.
  ///
  /// In pt, this message translates to:
  /// **'Ordem'**
  String get planSectionOrder;

  /// No description provided for @planSectionTime.
  ///
  /// In pt, this message translates to:
  /// **'Tempo disponível'**
  String get planSectionTime;

  /// No description provided for @planSetupBody.
  ///
  /// In pt, this message translates to:
  /// **'Montamos a porção diária para caber nesse tempo — na ordem da Bíblia ou na ordem dos acontecimentos. Capítulos que você já leu são pulados.'**
  String get planSetupBody;

  /// No description provided for @planSetupQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Quanto tempo você tem por dia?'**
  String get planSetupQuestion;

  /// No description provided for @planSkippedChaptersToast.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 capítulo já lido foi pulado} other{{count} capítulos já lidos foram pulados}}'**
  String planSkippedChaptersToast(int count);

  /// No description provided for @planStartCta.
  ///
  /// In pt, this message translates to:
  /// **'Começar plano · {minutes} min/dia'**
  String planStartCta(int minutes);

  /// No description provided for @planTitle.
  ///
  /// In pt, this message translates to:
  /// **'Plano de leitura'**
  String get planTitle;

  /// No description provided for @planTodayChapters.
  ///
  /// In pt, this message translates to:
  /// **'Capítulos de hoje'**
  String get planTodayChapters;

  /// No description provided for @planTodayDoneBody.
  ///
  /// In pt, this message translates to:
  /// **'Porção de hoje concluída. Volte amanhã — ou continue explorando a Bíblia livremente.'**
  String get planTodayDoneBody;

  /// No description provided for @portraitAvatar.
  ///
  /// In pt, this message translates to:
  /// **'Avatar'**
  String get portraitAvatar;

  /// No description provided for @portraitAvatarHint.
  ///
  /// In pt, this message translates to:
  /// **'Um peregrino ilustrado'**
  String get portraitAvatarHint;

  /// No description provided for @portraitEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Retrato'**
  String get portraitEyebrow;

  /// No description provided for @portraitLetter.
  ///
  /// In pt, this message translates to:
  /// **'Letra'**
  String get portraitLetter;

  /// No description provided for @portraitLetterHint.
  ///
  /// In pt, this message translates to:
  /// **'As iniciais do nome'**
  String get portraitLetterHint;

  /// No description provided for @portraitNoPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Sem foto nesta conta'**
  String get portraitNoPhoto;

  /// No description provided for @portraitPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Foto'**
  String get portraitPhoto;

  /// No description provided for @portraitPhotoHint.
  ///
  /// In pt, this message translates to:
  /// **'A foto da sua conta'**
  String get portraitPhotoHint;

  /// No description provided for @portraitTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como você aparece no perfil'**
  String get portraitTitle;

  /// No description provided for @practiceEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Continue as cenas. Quando errar, a pergunta volta aqui.'**
  String get practiceEmptyBody;

  /// No description provided for @practiceEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum erro guardado ainda'**
  String get practiceEmptyTitle;

  /// No description provided for @practiceIntro.
  ///
  /// In pt, this message translates to:
  /// **'Volte às perguntas em que você errou. Cada acerto limpa a pergunta da fila.'**
  String get practiceIntro;

  /// No description provided for @practiceSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Reforce as passagens'**
  String get practiceSubtitle;

  /// No description provided for @practiceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Revisar erros'**
  String get practiceTitle;

  /// No description provided for @profileDaysOnTop.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia no topo} other{{count} dias no topo}}'**
  String profileDaysOnTop(int count);

  /// No description provided for @profileDaysPerWeek.
  ///
  /// In pt, this message translates to:
  /// **'dias por semana'**
  String get profileDaysPerWeek;

  /// No description provided for @profileInTheWord.
  ///
  /// In pt, this message translates to:
  /// **'Na Palavra'**
  String get profileInTheWord;

  /// No description provided for @profileInTheWordWhisper.
  ///
  /// In pt, this message translates to:
  /// **'Versos que você guarda e os que já saíram daqui.'**
  String get profileInTheWordWhisper;

  /// No description provided for @profileLampHelp.
  ///
  /// In pt, this message translates to:
  /// **'Cada lamparina é uma semana: o azeite sobe a cada dia caminhado e a chama cresce.'**
  String get profileLampHelp;

  /// No description provided for @profileLastThreeMonths.
  ///
  /// In pt, this message translates to:
  /// **'Últimos 3 meses'**
  String get profileLastThreeMonths;

  /// No description provided for @profileMonthRank.
  ///
  /// In pt, this message translates to:
  /// **'{rank}º no ranking do mês'**
  String profileMonthRank(int rank);

  /// No description provided for @profileOfSevenDays.
  ///
  /// In pt, this message translates to:
  /// **'{count} de 7 dias'**
  String profileOfSevenDays(int count);

  /// No description provided for @profileOpenBible.
  ///
  /// In pt, this message translates to:
  /// **'Abrir a Bíblia'**
  String get profileOpenBible;

  /// No description provided for @profileOpenRef.
  ///
  /// In pt, this message translates to:
  /// **'Abrir {ref}'**
  String profileOpenRef(String ref);

  /// No description provided for @profilePrivacyHiddenSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{label} oculto da caravana'**
  String profilePrivacyHiddenSemantics(String label);

  /// No description provided for @profilePrivacyHiddenToast.
  ///
  /// In pt, this message translates to:
  /// **'{label} fica só com você.'**
  String profilePrivacyHiddenToast(String label);

  /// No description provided for @profilePrivacyShownSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{label} visível para a caravana'**
  String profilePrivacyShownSemantics(String label);

  /// No description provided for @profilePrivacyShownToast.
  ///
  /// In pt, this message translates to:
  /// **'{label} aparece no seu perfil na caravana.'**
  String profilePrivacyShownToast(String label);

  /// No description provided for @profileSavedVerses.
  ///
  /// In pt, this message translates to:
  /// **'Guardados'**
  String get profileSavedVerses;

  /// No description provided for @profileSavedVersesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Na leitura, toque num versículo e escolha Guardar para voltar a ele depois.'**
  String get profileSavedVersesEmpty;

  /// No description provided for @profileSectionAccuracy.
  ///
  /// In pt, this message translates to:
  /// **'Taxa de acertos'**
  String get profileSectionAccuracy;

  /// No description provided for @profileSectionAccuracyHint.
  ///
  /// In pt, this message translates to:
  /// **'Percentual de acertos nas cenas'**
  String get profileSectionAccuracyHint;

  /// No description provided for @profileSectionBibleHint.
  ///
  /// In pt, this message translates to:
  /// **'Livros e capítulos lidos'**
  String get profileSectionBibleHint;

  /// No description provided for @profileSectionDaysOnTop.
  ///
  /// In pt, this message translates to:
  /// **'Dias no topo'**
  String get profileSectionDaysOnTop;

  /// No description provided for @profileSectionDaysOnTopHint.
  ///
  /// In pt, this message translates to:
  /// **'Quantos dias ficou em 1º no ranking geral'**
  String get profileSectionDaysOnTopHint;

  /// No description provided for @profileSectionLastScene.
  ///
  /// In pt, this message translates to:
  /// **'Última cena'**
  String get profileSectionLastScene;

  /// No description provided for @profileSectionLastSceneHint.
  ///
  /// In pt, this message translates to:
  /// **'Nome da última cena concluída'**
  String get profileSectionLastSceneHint;

  /// No description provided for @profileSectionMedals.
  ///
  /// In pt, this message translates to:
  /// **'Medalhas'**
  String get profileSectionMedals;

  /// No description provided for @profileSectionMedalsHint.
  ///
  /// In pt, this message translates to:
  /// **'Medalhas da jornada'**
  String get profileSectionMedalsHint;

  /// No description provided for @profileSectionPresence.
  ///
  /// In pt, this message translates to:
  /// **'Presença'**
  String get profileSectionPresence;

  /// No description provided for @profileSectionPresenceHint.
  ///
  /// In pt, this message translates to:
  /// **'Semana, sequência e marcos, de Semente a Fruto'**
  String get profileSectionPresenceHint;

  /// No description provided for @profileSectionRanking.
  ///
  /// In pt, this message translates to:
  /// **'Ranking e passos'**
  String get profileSectionRanking;

  /// No description provided for @profileSectionRankingHint.
  ///
  /// In pt, this message translates to:
  /// **'Posição e passos totais'**
  String get profileSectionRankingHint;

  /// No description provided for @profileSectionTrailsHint.
  ///
  /// In pt, this message translates to:
  /// **'Progresso nas trilhas e selos adquiridos'**
  String get profileSectionTrailsHint;

  /// No description provided for @profileSharedVerses.
  ///
  /// In pt, this message translates to:
  /// **'Enviados'**
  String get profileSharedVerses;

  /// No description provided for @profileSharedVersesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Versículos que você compartilhar aparecem aqui — só a referência.'**
  String get profileSharedVersesEmpty;

  /// No description provided for @profileSince.
  ///
  /// In pt, this message translates to:
  /// **'Peregrino desde {month} de {year}'**
  String profileSince(String month, int year);

  /// No description provided for @profileStreakGoalDone.
  ///
  /// In pt, this message translates to:
  /// **'Compromisso de {goal} dias cumprido. Siga firme.'**
  String profileStreakGoalDone(int goal);

  /// No description provided for @profileStreakOf.
  ///
  /// In pt, this message translates to:
  /// **'Sequência de {streak} de {goal} dias'**
  String profileStreakOf(int streak, int goal);

  /// No description provided for @profileStreakOfGoal.
  ///
  /// In pt, this message translates to:
  /// **'de {goal}'**
  String profileStreakOfGoal(int goal);

  /// No description provided for @profileStreakRemaining.
  ///
  /// In pt, this message translates to:
  /// **'Faltam {left} para o compromisso de {goal} dias.'**
  String profileStreakRemaining(int left, int goal);

  /// No description provided for @profileStreakStart.
  ///
  /// In pt, this message translates to:
  /// **'Uma cena hoje acende o primeiro dia.'**
  String get profileStreakStart;

  /// No description provided for @profileThisWeek.
  ///
  /// In pt, this message translates to:
  /// **'Esta semana'**
  String get profileThisWeek;

  /// No description provided for @profileThisWeekLower.
  ///
  /// In pt, this message translates to:
  /// **'esta semana'**
  String get profileThisWeekLower;

  /// No description provided for @profileThisWeekSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Esta semana: {count} de 7 dias caminhados'**
  String profileThisWeekSemantics(int count);

  /// No description provided for @profileThreeMonthsAgo.
  ///
  /// In pt, this message translates to:
  /// **'há 3 meses'**
  String get profileThreeMonthsAgo;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @profileTodayLower.
  ///
  /// In pt, this message translates to:
  /// **'hoje'**
  String get profileTodayLower;

  /// No description provided for @profileWdFri.
  ///
  /// In pt, this message translates to:
  /// **'S'**
  String get profileWdFri;

  /// No description provided for @profileWdMon.
  ///
  /// In pt, this message translates to:
  /// **'S'**
  String get profileWdMon;

  /// No description provided for @profileWdSat.
  ///
  /// In pt, this message translates to:
  /// **'S'**
  String get profileWdSat;

  /// No description provided for @profileWdSun.
  ///
  /// In pt, this message translates to:
  /// **'D'**
  String get profileWdSun;

  /// No description provided for @profileWdThu.
  ///
  /// In pt, this message translates to:
  /// **'Q'**
  String get profileWdThu;

  /// No description provided for @profileWdTue.
  ///
  /// In pt, this message translates to:
  /// **'T'**
  String get profileWdTue;

  /// No description provided for @profileWdWed.
  ///
  /// In pt, this message translates to:
  /// **'Q'**
  String get profileWdWed;

  /// No description provided for @profileWeekHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico das semanas'**
  String get profileWeekHistory;

  /// No description provided for @profileWeeksWalkedSemantics.
  ///
  /// In pt, this message translates to:
  /// **'{walked} dias caminhados nas últimas {weeks} semanas'**
  String profileWeeksWalkedSemantics(int walked, int weeks);

  /// No description provided for @profileYourJourney.
  ///
  /// In pt, this message translates to:
  /// **'Sua jornada'**
  String get profileYourJourney;

  /// No description provided for @profileYourNumbers.
  ///
  /// In pt, this message translates to:
  /// **'Seus números'**
  String get profileYourNumbers;

  /// No description provided for @profileYourStreak.
  ///
  /// In pt, this message translates to:
  /// **'Sua sequência'**
  String get profileYourStreak;

  /// No description provided for @questAccuracySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Termine uma cena com 80% de acertos'**
  String get questAccuracySubtitle;

  /// No description provided for @questAccuracyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Olho firme'**
  String get questAccuracyTitle;

  /// No description provided for @questCountOf.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total}'**
  String questCountOf(int done, int total);

  /// No description provided for @questDailySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Passos extras além da cena.'**
  String get questDailySubtitle;

  /// No description provided for @questDailyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tarefas do dia'**
  String get questDailyTitle;

  /// No description provided for @questDone.
  ///
  /// In pt, this message translates to:
  /// **'Feito'**
  String get questDone;

  /// No description provided for @questDoneLower.
  ///
  /// In pt, this message translates to:
  /// **'feito'**
  String get questDoneLower;

  /// No description provided for @questMilestone100Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'100% — continue caminhando'**
  String get questMilestone100Subtitle;

  /// No description provided for @questMilestone100Title.
  ///
  /// In pt, this message translates to:
  /// **'Jornada percorrida'**
  String get questMilestone100Title;

  /// No description provided for @questMilestone25Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'25% da trilha'**
  String get questMilestone25Subtitle;

  /// No description provided for @questMilestone25Title.
  ///
  /// In pt, this message translates to:
  /// **'Bom começo'**
  String get questMilestone25Title;

  /// No description provided for @questMilestone50Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'50% da trilha'**
  String get questMilestone50Subtitle;

  /// No description provided for @questMilestone50Title.
  ///
  /// In pt, this message translates to:
  /// **'Meio do caminho'**
  String get questMilestone50Title;

  /// No description provided for @questMilestone75Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'75% da trilha'**
  String get questMilestone75Subtitle;

  /// No description provided for @questMilestone75Title.
  ///
  /// In pt, this message translates to:
  /// **'Quase lá'**
  String get questMilestone75Title;

  /// No description provided for @questMissionSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Complete uma cena'**
  String get questMissionSubtitle;

  /// No description provided for @questMissionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Uma cena'**
  String get questMissionTitle;

  /// No description provided for @questProgressLine.
  ///
  /// In pt, this message translates to:
  /// **'{value} de {target} · {subtitle}'**
  String questProgressLine(int value, int target, String subtitle);

  /// No description provided for @questReadSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Leia um capítulo'**
  String get questReadSubtitle;

  /// No description provided for @questReadTitle.
  ///
  /// In pt, this message translates to:
  /// **'Na Palavra'**
  String get questReadTitle;

  /// No description provided for @questWeeklyDaysSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Caminhe em 4 dias diferentes'**
  String get questWeeklyDaysSubtitle;

  /// No description provided for @questWeeklyDaysTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quatro dias'**
  String get questWeeklyDaysTitle;

  /// No description provided for @questWeeklyPerfectSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Duas cenas com 100% de acertos na semana'**
  String get questWeeklyPerfectSubtitle;

  /// No description provided for @questWeeklyPerfectTitle.
  ///
  /// In pt, this message translates to:
  /// **'Duas sem erro'**
  String get questWeeklyPerfectTitle;

  /// No description provided for @questWeeklyScenesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Complete 5 cenas nesta semana'**
  String get questWeeklyScenesSubtitle;

  /// No description provided for @questWeeklyScenesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cinco cenas'**
  String get questWeeklyScenesTitle;

  /// No description provided for @questWeeklyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Tarefas da semana'**
  String get questWeeklyTitle;

  /// No description provided for @realmAntigoTestamento.
  ///
  /// In pt, this message translates to:
  /// **'Antigo Testamento'**
  String get realmAntigoTestamento;

  /// No description provided for @realmEyebrowAntigoTestamento.
  ///
  /// In pt, this message translates to:
  /// **'A promessa'**
  String get realmEyebrowAntigoTestamento;

  /// No description provided for @realmEyebrowNovoTestamento.
  ///
  /// In pt, this message translates to:
  /// **'O cumprimento'**
  String get realmEyebrowNovoTestamento;

  /// No description provided for @realmEyebrowTeologia.
  ///
  /// In pt, this message translates to:
  /// **'O fundamento'**
  String get realmEyebrowTeologia;

  /// No description provided for @realmEyebrowVidaCrista.
  ///
  /// In pt, this message translates to:
  /// **'O caminhar'**
  String get realmEyebrowVidaCrista;

  /// No description provided for @realmNovoTestamento.
  ///
  /// In pt, this message translates to:
  /// **'Novo Testamento'**
  String get realmNovoTestamento;

  /// Catch-all area when suggesting a trail
  ///
  /// In pt, this message translates to:
  /// **'Outros'**
  String get realmOther;

  /// No description provided for @realmTaglineAntigoTestamento.
  ///
  /// In pt, this message translates to:
  /// **'Da criação aos profetas — o caminho da aliança'**
  String get realmTaglineAntigoTestamento;

  /// No description provided for @realmTaglineNovoTestamento.
  ///
  /// In pt, this message translates to:
  /// **'Cristo, a Igreja e a esperança que não falha'**
  String get realmTaglineNovoTestamento;

  /// No description provided for @realmTaglineTeologia.
  ///
  /// In pt, this message translates to:
  /// **'Hermenêutica, línguas e a doutrina da fé'**
  String get realmTaglineTeologia;

  /// No description provided for @realmTaglineVidaCrista.
  ///
  /// In pt, this message translates to:
  /// **'Discipulado, oração e a história da fé'**
  String get realmTaglineVidaCrista;

  /// No description provided for @realmTeologia.
  ///
  /// In pt, this message translates to:
  /// **'Teologia'**
  String get realmTeologia;

  /// No description provided for @realmTeologiaSoonBody.
  ///
  /// In pt, this message translates to:
  /// **'Hermenêutica, línguas originais e dogmática.'**
  String get realmTeologiaSoonBody;

  /// No description provided for @realmVidaCrista.
  ///
  /// In pt, this message translates to:
  /// **'Vida Cristã'**
  String get realmVidaCrista;

  /// No description provided for @recognitionAMedal.
  ///
  /// In pt, this message translates to:
  /// **'Uma medalha'**
  String get recognitionAMedal;

  /// No description provided for @recognitionAlready.
  ///
  /// In pt, this message translates to:
  /// **'Você já reconheceu'**
  String get recognitionAlready;

  /// No description provided for @recognitionAndMore.
  ///
  /// In pt, this message translates to:
  /// **'{a}, {b} e mais {count}'**
  String recognitionAndMore(String a, String b, int count);

  /// No description provided for @recognitionAndTwo.
  ///
  /// In pt, this message translates to:
  /// **'{a} e {b}'**
  String recognitionAndTwo(String a, String b);

  /// No description provided for @recognitionDaysAgo.
  ///
  /// In pt, this message translates to:
  /// **'Há {count} dias'**
  String recognitionDaysAgo(int count);

  /// No description provided for @recognitionEmptyCard.
  ///
  /// In pt, this message translates to:
  /// **'Quando alguém da caravana tocar no coração, aparece aqui.'**
  String get recognitionEmptyCard;

  /// No description provided for @recognitionEmptySheet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda ninguém reconheceu sua jornada.\nNa caravana, outros podem tocar no coração.'**
  String get recognitionEmptySheet;

  /// No description provided for @recognitionFailedGive.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível reconhecer'**
  String get recognitionFailedGive;

  /// No description provided for @recognitionFailedWithdraw.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível retirar'**
  String get recognitionFailedWithdraw;

  /// No description provided for @recognitionGivenTapWithdraw.
  ///
  /// In pt, this message translates to:
  /// **'Reconhecida · toque para retirar'**
  String get recognitionGivenTapWithdraw;

  /// No description provided for @recognitionHeadlineMedal.
  ///
  /// In pt, this message translates to:
  /// **'{name} reconheceu {title}'**
  String recognitionHeadlineMedal(String name, String title);

  /// No description provided for @recognitionHeadlineMedalUnknown.
  ///
  /// In pt, this message translates to:
  /// **'{name} reconheceu uma medalha sua'**
  String recognitionHeadlineMedalUnknown(String name);

  /// No description provided for @recognitionHeadlineWalk.
  ///
  /// In pt, this message translates to:
  /// **'{name} reconheceu sua cena'**
  String recognitionHeadlineWalk(String name);

  /// No description provided for @recognitionHomeSeeWho.
  ///
  /// In pt, this message translates to:
  /// **'Ver quem reconheceu'**
  String get recognitionHomeSeeWho;

  /// No description provided for @recognitionHomeTitleMany.
  ///
  /// In pt, this message translates to:
  /// **'Reconheceram sua jornada'**
  String get recognitionHomeTitleMany;

  /// No description provided for @recognitionHomeTitleSingle.
  ///
  /// In pt, this message translates to:
  /// **'{name} reconheceu sua jornada'**
  String recognitionHomeTitleSingle(String name);

  /// No description provided for @recognitionMedalDone.
  ///
  /// In pt, this message translates to:
  /// **'Medalha reconhecida'**
  String get recognitionMedalDone;

  /// No description provided for @recognitionMedalFirstScene.
  ///
  /// In pt, this message translates to:
  /// **'Primeira cena'**
  String get recognitionMedalFirstScene;

  /// No description provided for @recognitionMedalInterpretation.
  ///
  /// In pt, this message translates to:
  /// **'Interpretação'**
  String get recognitionMedalInterpretation;

  /// No description provided for @recognitionMedalObservation.
  ///
  /// In pt, this message translates to:
  /// **'Observação'**
  String get recognitionMedalObservation;

  /// No description provided for @recognitionMedalUnderstanding.
  ///
  /// In pt, this message translates to:
  /// **'Compreensão'**
  String get recognitionMedalUnderstanding;

  /// No description provided for @recognitionRecognizeScene.
  ///
  /// In pt, this message translates to:
  /// **'Reconhecer a cena'**
  String get recognitionRecognizeScene;

  /// No description provided for @recognitionRemoved.
  ///
  /// In pt, this message translates to:
  /// **'Reconhecimento retirado'**
  String get recognitionRemoved;

  /// No description provided for @recognitionSawJourney.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{{who} viu sua jornada} other{{who} viram sua jornada}}'**
  String recognitionSawJourney(int count, String who);

  /// No description provided for @recognitionSawYou.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{reconheceu você} other{reconheceu você {count} vezes}}'**
  String recognitionSawYou(int count);

  /// No description provided for @recognitionSceneDone.
  ///
  /// In pt, this message translates to:
  /// **'Cena reconhecida'**
  String get recognitionSceneDone;

  /// No description provided for @recognitionSceneOf.
  ///
  /// In pt, this message translates to:
  /// **'Cena de {date}'**
  String recognitionSceneOf(String date);

  /// No description provided for @recognitionSemanticsWho.
  ///
  /// In pt, this message translates to:
  /// **'Quem reconheceu. {subtitle}'**
  String recognitionSemanticsWho(String subtitle);

  /// No description provided for @recognitionSummaryCounts.
  ///
  /// In pt, this message translates to:
  /// **'{recog, plural, =1{1 reconhecimento} other{{recog} reconhecimentos}} de {people, plural, =1{1 pessoa} other{{people} pessoas}}'**
  String recognitionSummaryCounts(int recog, int people);

  /// No description provided for @recognitionSummaryEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Cena do dia e medalhas que outros viram em você.'**
  String get recognitionSummaryEmpty;

  /// No description provided for @recognitionTapToWithdraw.
  ///
  /// In pt, this message translates to:
  /// **'Toque de novo para retirar'**
  String get recognitionTapToWithdraw;

  /// No description provided for @recognitionWhichMedal.
  ///
  /// In pt, this message translates to:
  /// **'Qual medalha você viu?'**
  String get recognitionWhichMedal;

  /// No description provided for @recognitionWhoTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem reconheceu'**
  String get recognitionWhoTitle;

  /// No description provided for @recognitionYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get recognitionYesterday;

  /// No description provided for @recognitionYourScene.
  ///
  /// In pt, this message translates to:
  /// **'Sua cena'**
  String get recognitionYourScene;

  /// No description provided for @reminderDailyEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete diário'**
  String get reminderDailyEyebrow;

  /// No description provided for @reminderHour.
  ///
  /// In pt, this message translates to:
  /// **'{hour}h'**
  String reminderHour(int hour);

  /// No description provided for @reminderMorning.
  ///
  /// In pt, this message translates to:
  /// **'Manhã'**
  String get reminderMorning;

  /// No description provided for @reminderNight.
  ///
  /// In pt, this message translates to:
  /// **'Noite'**
  String get reminderNight;

  /// No description provided for @reminderNoon.
  ///
  /// In pt, this message translates to:
  /// **'Meio-dia'**
  String get reminderNoon;

  /// No description provided for @reminderRemindAt.
  ///
  /// In pt, this message translates to:
  /// **'Lembrar às {hour}h'**
  String reminderRemindAt(int hour);

  /// No description provided for @reminderSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Um horário fixo cola o hábito. Amanhã te avisamos da próxima cena.'**
  String get reminderSubtitle;

  /// No description provided for @reminderSubtitleSettings.
  ///
  /// In pt, this message translates to:
  /// **'Um aviso por dia, no horário que você escolher.'**
  String get reminderSubtitleSettings;

  /// No description provided for @reminderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Em que hora lembramos você?'**
  String get reminderTitle;

  /// No description provided for @reportCategoryFeedback.
  ///
  /// In pt, this message translates to:
  /// **'Feedback confuso'**
  String get reportCategoryFeedback;

  /// No description provided for @reportCategoryInterpretation.
  ///
  /// In pt, this message translates to:
  /// **'Interpretação questionável'**
  String get reportCategoryInterpretation;

  /// No description provided for @reportCategoryOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get reportCategoryOther;

  /// No description provided for @reportCategoryTheological.
  ///
  /// In pt, this message translates to:
  /// **'Erro teológico'**
  String get reportCategoryTheological;

  /// No description provided for @reportCategoryTypo.
  ///
  /// In pt, this message translates to:
  /// **'Ortografia / texto'**
  String get reportCategoryTypo;

  /// No description provided for @reportCategoryWrongAnswer.
  ///
  /// In pt, this message translates to:
  /// **'Resposta marcada errada'**
  String get reportCategoryWrongAnswer;

  /// No description provided for @reportCommentHint.
  ///
  /// In pt, this message translates to:
  /// **'Opcional: conte o que parece errado…'**
  String get reportCommentHint;

  /// No description provided for @reportHintFeedback.
  ///
  /// In pt, this message translates to:
  /// **'Explicação após a resposta confunde ou erra'**
  String get reportHintFeedback;

  /// No description provided for @reportHintInterpretation.
  ///
  /// In pt, this message translates to:
  /// **'Leitura do texto bíblico parece forçada ou imprecisa'**
  String get reportHintInterpretation;

  /// No description provided for @reportHintOther.
  ///
  /// In pt, this message translates to:
  /// **'Algo mais que não se encaixa acima'**
  String get reportHintOther;

  /// No description provided for @reportHintTheological.
  ///
  /// In pt, this message translates to:
  /// **'Doutrina ou doutrina implícita parece incorreta'**
  String get reportHintTheological;

  /// No description provided for @reportHintTypo.
  ///
  /// In pt, this message translates to:
  /// **'Erro de digitação, referência ou formatação'**
  String get reportHintTypo;

  /// No description provided for @reportHintWrongAnswer.
  ///
  /// In pt, this message translates to:
  /// **'A opção marcada como certa parece errada'**
  String get reportHintWrongAnswer;

  /// No description provided for @reportIntro.
  ///
  /// In pt, this message translates to:
  /// **'Ajude a melhorar a trilha — erro teológico, interpretação, resposta ou texto.'**
  String get reportIntro;

  /// No description provided for @reportSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar relato'**
  String get reportSend;

  /// No description provided for @reportSendError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar. Tente de novo.'**
  String get reportSendError;

  /// No description provided for @reportSending.
  ///
  /// In pt, this message translates to:
  /// **'Enviando…'**
  String get reportSending;

  /// No description provided for @reportSignInRequired.
  ///
  /// In pt, this message translates to:
  /// **'Entre com Google para enviar o relato.'**
  String get reportSignInRequired;

  /// No description provided for @reportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Relatar problema'**
  String get reportTitle;

  /// No description provided for @resetAwareness.
  ///
  /// In pt, this message translates to:
  /// **'Estou ciente de que vou perder o progresso'**
  String get resetAwareness;

  /// No description provided for @resetBody.
  ///
  /// In pt, this message translates to:
  /// **'Todos os passos, a sequência e o progresso serão apagados. A introdução volta a aparecer. Não dá para desfazer.'**
  String get resetBody;

  /// No description provided for @resetConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get resetConfirm;

  /// No description provided for @resetConfirmCountdown.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar · {seconds}s'**
  String resetConfirmCountdown(int seconds);

  /// No description provided for @resetTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apagar progresso'**
  String get resetTitle;

  /// No description provided for @roomErrorCreate.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível criar o grupo. Tente de novo.'**
  String get roomErrorCreate;

  /// No description provided for @roomErrorCreateFirst.
  ///
  /// In pt, this message translates to:
  /// **'Crie o grupo antes de chamar alguém.'**
  String get roomErrorCreateFirst;

  /// No description provided for @roomErrorFull.
  ///
  /// In pt, this message translates to:
  /// **'Este grupo já tem {limit} pessoas.'**
  String roomErrorFull(int limit);

  /// No description provided for @roomErrorFullAskLeader.
  ///
  /// In pt, this message translates to:
  /// **'Este grupo já tem {limit} pessoas. Peça ao líder para abrir outro grupo.'**
  String roomErrorFullAskLeader(int limit);

  /// No description provided for @roomErrorInvalidCode.
  ///
  /// In pt, this message translates to:
  /// **'Código inválido ou grupo não encontrado.'**
  String get roomErrorInvalidCode;

  /// No description provided for @roomErrorLostGroup.
  ///
  /// In pt, this message translates to:
  /// **'Não achamos o grupo em que você estava.'**
  String get roomErrorLostGroup;

  /// No description provided for @roomErrorSignInCreate.
  ///
  /// In pt, this message translates to:
  /// **'Entre com Google para criar um grupo.'**
  String get roomErrorSignInCreate;

  /// No description provided for @roomErrorSignInJoin.
  ///
  /// In pt, this message translates to:
  /// **'Entre com Google para entrar num grupo.'**
  String get roomErrorSignInJoin;

  /// No description provided for @roomFallbackName.
  ///
  /// In pt, this message translates to:
  /// **'Grupo'**
  String get roomFallbackName;

  /// No description provided for @roomKindAmigos.
  ///
  /// In pt, this message translates to:
  /// **'Amigos'**
  String get roomKindAmigos;

  /// No description provided for @roomKindCelula.
  ///
  /// In pt, this message translates to:
  /// **'Célula'**
  String get roomKindCelula;

  /// No description provided for @roomKindDiscipulado.
  ///
  /// In pt, this message translates to:
  /// **'Discipulado'**
  String get roomKindDiscipulado;

  /// No description provided for @roomKindEbd.
  ///
  /// In pt, this message translates to:
  /// **'EBD'**
  String get roomKindEbd;

  /// No description provided for @roomKindFamilia.
  ///
  /// In pt, this message translates to:
  /// **'Família'**
  String get roomKindFamilia;

  /// No description provided for @roomLeaderAmigos.
  ///
  /// In pt, this message translates to:
  /// **'Anfitrião'**
  String get roomLeaderAmigos;

  /// No description provided for @roomLeaderCelula.
  ///
  /// In pt, this message translates to:
  /// **'Líder'**
  String get roomLeaderCelula;

  /// No description provided for @roomLeaderDiscipulado.
  ///
  /// In pt, this message translates to:
  /// **'Discipulador'**
  String get roomLeaderDiscipulado;

  /// No description provided for @roomLeaderEbd.
  ///
  /// In pt, this message translates to:
  /// **'Professor'**
  String get roomLeaderEbd;

  /// No description provided for @roomLeaderFamilia.
  ///
  /// In pt, this message translates to:
  /// **'Responsável'**
  String get roomLeaderFamilia;

  /// No description provided for @roomNameHintAmigos.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Amigos da facul'**
  String get roomNameHintAmigos;

  /// No description provided for @roomNameHintCelula.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Célula Norte'**
  String get roomNameHintCelula;

  /// No description provided for @roomNameHintDiscipulado.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Discipulado de quinta'**
  String get roomNameHintDiscipulado;

  /// No description provided for @roomNameHintEbd.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: EBD Jovens'**
  String get roomNameHintEbd;

  /// No description provided for @roomNameHintFamilia.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Família Souza'**
  String get roomNameHintFamilia;

  /// No description provided for @roomStudyFallbackTitle.
  ///
  /// In pt, this message translates to:
  /// **'Estudo da semana'**
  String get roomStudyFallbackTitle;

  /// No description provided for @sealsAllRevealed.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total} — todos os selos revelados.'**
  String sealsAllRevealed(int done, int total);

  /// No description provided for @sealsCountFact.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 selo — fato e verso, no texto.} other{{count} selos — fato e verso, no texto.}}'**
  String sealsCountFact(int count);

  /// No description provided for @sealsEmptyHint.
  ///
  /// In pt, this message translates to:
  /// **'Fato e verso de quem o texto já mostrou.'**
  String get sealsEmptyHint;

  /// No description provided for @sealsSemanticsLocked.
  ///
  /// In pt, this message translates to:
  /// **'Selo ainda fechado'**
  String get sealsSemanticsLocked;

  /// No description provided for @sealsSemanticsNamed.
  ///
  /// In pt, this message translates to:
  /// **'Selo {name}'**
  String sealsSemanticsNamed(String name);

  /// No description provided for @sealsStartsAt.
  ///
  /// In pt, this message translates to:
  /// **'Ainda no texto — começa em {name}.'**
  String sealsStartsAt(String name);

  /// No description provided for @sealsStillInText.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total} — ainda no texto: {name}'**
  String sealsStillInText(int done, int total, String name);

  /// No description provided for @sealsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Selos'**
  String get sealsTitle;

  /// No description provided for @seasonChallengeDoneBody.
  ///
  /// In pt, this message translates to:
  /// **'Desafio da estação concluído. Bem caminhado.'**
  String get seasonChallengeDoneBody;

  /// No description provided for @seasonChallengeEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'O próximo chega com a nova estação litúrgica.'**
  String get seasonChallengeEmptyBody;

  /// No description provided for @seasonChallengeEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum desafio da estação agora'**
  String get seasonChallengeEmptyTitle;

  /// No description provided for @seasonChallengeInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Desafio da estação em andamento'**
  String get seasonChallengeInProgress;

  /// No description provided for @seasonChallengeInvite.
  ///
  /// In pt, this message translates to:
  /// **'Chamar para o desafio'**
  String get seasonChallengeInvite;

  /// No description provided for @seasonChallengePathPercent.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% do caminho'**
  String seasonChallengePathPercent(int percent);

  /// No description provided for @seasonChallengeSeeProgress.
  ///
  /// In pt, this message translates to:
  /// **'Ver progresso'**
  String get seasonChallengeSeeProgress;

  /// No description provided for @seasonChallengeShareBody.
  ///
  /// In pt, this message translates to:
  /// **'🕯️ Entrei no desafio {title} no Stway.\n\nVamos caminhar juntos nesta estação?\n\n{footer}'**
  String seasonChallengeShareBody(String title, String footer);

  /// No description provided for @seasonChallengeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Desafio da estação'**
  String get seasonChallengeTitle;

  /// No description provided for @seasonDayLine.
  ///
  /// In pt, this message translates to:
  /// **'Dia {day} · {title}'**
  String seasonDayLine(int day, String title);

  /// No description provided for @seasonDayOf.
  ///
  /// In pt, this message translates to:
  /// **'Dia {day} de {total}'**
  String seasonDayOf(String day, int total);

  /// No description provided for @seasonDaysWalked.
  ///
  /// In pt, this message translates to:
  /// **'{done} / {total} dias caminhados'**
  String seasonDaysWalked(int done, int total);

  /// No description provided for @seasonEnded.
  ///
  /// In pt, this message translates to:
  /// **'Estação encerrada'**
  String get seasonEnded;

  /// No description provided for @seasonFreeTrialLine.
  ///
  /// In pt, this message translates to:
  /// **'Gratuito: 3 primeiros dias · depois, Peregrino+'**
  String get seasonFreeTrialLine;

  /// No description provided for @seasonNotTodayYet.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não é hoje'**
  String get seasonNotTodayYet;

  /// No description provided for @seasonProFromDay4.
  ///
  /// In pt, this message translates to:
  /// **'Peregrino+ a partir do dia 4'**
  String get seasonProFromDay4;

  /// No description provided for @seasonReviewEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há perguntas desta semana no aparelho. Abra um dia primeiro.'**
  String get seasonReviewEmpty;

  /// No description provided for @seasonReviewMissionIntro.
  ///
  /// In pt, this message translates to:
  /// **'Três perguntas dos textos que você já estudou.'**
  String get seasonReviewMissionIntro;

  /// No description provided for @seasonReviewMissionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Revisão da semana'**
  String get seasonReviewMissionTitle;

  /// No description provided for @seasonReviewPreparing.
  ///
  /// In pt, this message translates to:
  /// **'Preparando…'**
  String get seasonReviewPreparing;

  /// No description provided for @seasonReviewStart.
  ///
  /// In pt, this message translates to:
  /// **'3 perguntas de revisão'**
  String get seasonReviewStart;

  /// No description provided for @seasonStartsIn.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Começa em 1 dia} other{Começa em {count} dias}}'**
  String seasonStartsIn(int count);

  /// No description provided for @seasonTodayInsight.
  ///
  /// In pt, this message translates to:
  /// **'Hoje: {insight}'**
  String seasonTodayInsight(String insight);

  /// No description provided for @seasonWalkAdvento2026Day01Insight.
  ///
  /// In pt, this message translates to:
  /// **'Deus se aproximou'**
  String get seasonWalkAdvento2026Day01Insight;

  /// No description provided for @seasonWalkAdvento2026Day01Title.
  ///
  /// In pt, this message translates to:
  /// **'O Verbo se fez carne'**
  String get seasonWalkAdvento2026Day01Title;

  /// No description provided for @seasonWalkAdvento2026Day02Insight.
  ///
  /// In pt, this message translates to:
  /// **'Deus é o centro, não eu'**
  String get seasonWalkAdvento2026Day02Insight;

  /// No description provided for @seasonWalkAdvento2026Day02Title.
  ///
  /// In pt, this message translates to:
  /// **'No princípio'**
  String get seasonWalkAdvento2026Day02Title;

  /// No description provided for @seasonWalkAdvento2026Day03Insight.
  ///
  /// In pt, this message translates to:
  /// **'Fomos feitos para refletir'**
  String get seasonWalkAdvento2026Day03Insight;

  /// No description provided for @seasonWalkAdvento2026Day03Title.
  ///
  /// In pt, this message translates to:
  /// **'Imagem'**
  String get seasonWalkAdvento2026Day03Title;

  /// No description provided for @seasonWalkAdvento2026Day04Insight.
  ///
  /// In pt, this message translates to:
  /// **'A fé anda quando Deus chama'**
  String get seasonWalkAdvento2026Day04Insight;

  /// No description provided for @seasonWalkAdvento2026Day04Title.
  ///
  /// In pt, this message translates to:
  /// **'Chamado'**
  String get seasonWalkAdvento2026Day04Title;

  /// No description provided for @seasonWalkAdvento2026Day05Insight.
  ///
  /// In pt, this message translates to:
  /// **'A promessa é maior que o medo'**
  String get seasonWalkAdvento2026Day05Insight;

  /// No description provided for @seasonWalkAdvento2026Day05Title.
  ///
  /// In pt, this message translates to:
  /// **'Estrelas'**
  String get seasonWalkAdvento2026Day05Title;

  /// No description provided for @seasonWalkAdvento2026Day06Insight.
  ///
  /// In pt, this message translates to:
  /// **'Deus proverá o cordeiro'**
  String get seasonWalkAdvento2026Day06Insight;

  /// No description provided for @seasonWalkAdvento2026Day06Title.
  ///
  /// In pt, this message translates to:
  /// **'Moriah'**
  String get seasonWalkAdvento2026Day06Title;

  /// No description provided for @seasonWalkAdvento2026Day07Insight.
  ///
  /// In pt, this message translates to:
  /// **'Deus levanta libertador'**
  String get seasonWalkAdvento2026Day07Insight;

  /// No description provided for @seasonWalkAdvento2026Day07Title.
  ///
  /// In pt, this message translates to:
  /// **'Moisés'**
  String get seasonWalkAdvento2026Day07Title;

  /// No description provided for @seasonWalkAdvento2026Day08Insight.
  ///
  /// In pt, this message translates to:
  /// **'O sangue guarda a casa'**
  String get seasonWalkAdvento2026Day08Insight;

  /// No description provided for @seasonWalkAdvento2026Day08Title.
  ///
  /// In pt, this message translates to:
  /// **'Páscoa'**
  String get seasonWalkAdvento2026Day08Title;

  /// No description provided for @seasonWalkAdvento2026Day09Insight.
  ///
  /// In pt, this message translates to:
  /// **'O Reino tem voz'**
  String get seasonWalkAdvento2026Day09Insight;

  /// No description provided for @seasonWalkAdvento2026Day09Title.
  ///
  /// In pt, this message translates to:
  /// **'O Rei no monte'**
  String get seasonWalkAdvento2026Day09Title;

  /// No description provided for @seasonWalkAdvento2026Day10Insight.
  ///
  /// In pt, this message translates to:
  /// **'O Reino cabe no vazio'**
  String get seasonWalkAdvento2026Day10Insight;

  /// No description provided for @seasonWalkAdvento2026Day10Title.
  ///
  /// In pt, this message translates to:
  /// **'Pobres de espírito'**
  String get seasonWalkAdvento2026Day10Title;

  /// No description provided for @seasonWalkAdvento2026Day11Insight.
  ///
  /// In pt, this message translates to:
  /// **'Há conforto para quem chora'**
  String get seasonWalkAdvento2026Day11Insight;

  /// No description provided for @seasonWalkAdvento2026Day11Title.
  ///
  /// In pt, this message translates to:
  /// **'Os que choram'**
  String get seasonWalkAdvento2026Day11Title;

  /// No description provided for @seasonWalkAdvento2026Day12Insight.
  ///
  /// In pt, this message translates to:
  /// **'Shalom é missão'**
  String get seasonWalkAdvento2026Day12Insight;

  /// No description provided for @seasonWalkAdvento2026Day12Title.
  ///
  /// In pt, this message translates to:
  /// **'Pacificadores'**
  String get seasonWalkAdvento2026Day12Title;

  /// No description provided for @seasonWalkAdvento2026Day13Insight.
  ///
  /// In pt, this message translates to:
  /// **'O céu se abre sobre o Filho'**
  String get seasonWalkAdvento2026Day13Insight;

  /// No description provided for @seasonWalkAdvento2026Day13Title.
  ///
  /// In pt, this message translates to:
  /// **'Batismo'**
  String get seasonWalkAdvento2026Day13Title;

  /// No description provided for @seasonWalkAdvento2026Day14Insight.
  ///
  /// In pt, this message translates to:
  /// **'O monte ensina o Reino'**
  String get seasonWalkAdvento2026Day14Insight;

  /// No description provided for @seasonWalkAdvento2026Day14Title.
  ///
  /// In pt, this message translates to:
  /// **'Sermão'**
  String get seasonWalkAdvento2026Day14Title;

  /// No description provided for @seasonWalkAdvento2026Day15Insight.
  ///
  /// In pt, this message translates to:
  /// **'Orar é pedir o Reino'**
  String get seasonWalkAdvento2026Day15Insight;

  /// No description provided for @seasonWalkAdvento2026Day15Title.
  ///
  /// In pt, this message translates to:
  /// **'Pai nosso'**
  String get seasonWalkAdvento2026Day15Title;

  /// No description provided for @seasonWalkAdvento2026Day16Insight.
  ///
  /// In pt, this message translates to:
  /// **'Nada me faltará'**
  String get seasonWalkAdvento2026Day16Insight;

  /// No description provided for @seasonWalkAdvento2026Day16Title.
  ///
  /// In pt, this message translates to:
  /// **'Meu pastor'**
  String get seasonWalkAdvento2026Day16Title;

  /// No description provided for @seasonWalkAdvento2026Day17Insight.
  ///
  /// In pt, this message translates to:
  /// **'Cristo desceu até a cruz'**
  String get seasonWalkAdvento2026Day17Insight;

  /// No description provided for @seasonWalkAdvento2026Day17Title.
  ///
  /// In pt, this message translates to:
  /// **'Humildade'**
  String get seasonWalkAdvento2026Day17Title;

  /// No description provided for @seasonWalkAdvento2026Day18Insight.
  ///
  /// In pt, this message translates to:
  /// **'O Reino se escuta em história'**
  String get seasonWalkAdvento2026Day18Insight;

  /// No description provided for @seasonWalkAdvento2026Day18Title.
  ///
  /// In pt, this message translates to:
  /// **'Parábolas'**
  String get seasonWalkAdvento2026Day18Title;

  /// No description provided for @seasonWalkAdvento2026Day19Insight.
  ///
  /// In pt, this message translates to:
  /// **'O Reino toca o corpo'**
  String get seasonWalkAdvento2026Day19Insight;

  /// No description provided for @seasonWalkAdvento2026Day19Title.
  ///
  /// In pt, this message translates to:
  /// **'Milagres'**
  String get seasonWalkAdvento2026Day19Title;

  /// No description provided for @seasonWalkAdvento2026Day20Insight.
  ///
  /// In pt, this message translates to:
  /// **'O tesouro puxa o coração'**
  String get seasonWalkAdvento2026Day20Insight;

  /// No description provided for @seasonWalkAdvento2026Day20Title.
  ///
  /// In pt, this message translates to:
  /// **'Ansiedade'**
  String get seasonWalkAdvento2026Day20Title;

  /// No description provided for @seasonWalkAdvento2026Day21Insight.
  ///
  /// In pt, this message translates to:
  /// **'O pão antecipa a entrega'**
  String get seasonWalkAdvento2026Day21Insight;

  /// No description provided for @seasonWalkAdvento2026Day21Title.
  ///
  /// In pt, this message translates to:
  /// **'Ceia'**
  String get seasonWalkAdvento2026Day21Title;

  /// No description provided for @seasonWalkAdvento2026Day22Insight.
  ///
  /// In pt, this message translates to:
  /// **'O Rei reina pregado'**
  String get seasonWalkAdvento2026Day22Insight;

  /// No description provided for @seasonWalkAdvento2026Day22Title.
  ///
  /// In pt, this message translates to:
  /// **'Cruz'**
  String get seasonWalkAdvento2026Day22Title;

  /// No description provided for @seasonWalkAdvento2026Day23Insight.
  ///
  /// In pt, this message translates to:
  /// **'A espera não foi vã'**
  String get seasonWalkAdvento2026Day23Insight;

  /// No description provided for @seasonWalkAdvento2026Day23Title.
  ///
  /// In pt, this message translates to:
  /// **'Ressurreição'**
  String get seasonWalkAdvento2026Day23Title;

  /// No description provided for @seasonWalkAdvento2026Day24Insight.
  ///
  /// In pt, this message translates to:
  /// **'O sétimo dia é dádiva'**
  String get seasonWalkAdvento2026Day24Insight;

  /// No description provided for @seasonWalkAdvento2026Day24Title.
  ///
  /// In pt, this message translates to:
  /// **'Descanso'**
  String get seasonWalkAdvento2026Day24Title;

  /// No description provided for @seasonWalkAdvento2026Day25Insight.
  ///
  /// In pt, this message translates to:
  /// **'Alegrai-vos no Senhor'**
  String get seasonWalkAdvento2026Day25Insight;

  /// No description provided for @seasonWalkAdvento2026Day25Title.
  ///
  /// In pt, this message translates to:
  /// **'Alegria'**
  String get seasonWalkAdvento2026Day25Title;

  /// No description provided for @seasonWalkAdvento2026Day26Insight.
  ///
  /// In pt, this message translates to:
  /// **'Quem tem fome será farto'**
  String get seasonWalkAdvento2026Day26Insight;

  /// No description provided for @seasonWalkAdvento2026Day26Title.
  ///
  /// In pt, this message translates to:
  /// **'Fome de justiça'**
  String get seasonWalkAdvento2026Day26Title;

  /// No description provided for @seasonWalkAdvento2026Subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Espera do Verbo · uma cena por dia'**
  String get seasonWalkAdvento2026Subtitle;

  /// No description provided for @seasonWalkAdvento2026Title.
  ///
  /// In pt, this message translates to:
  /// **'Advento 2026'**
  String get seasonWalkAdvento2026Title;

  /// No description provided for @seasonWeek.
  ///
  /// In pt, this message translates to:
  /// **'Semana {week}'**
  String seasonWeek(int week);

  /// No description provided for @seasonWeekInsightsHeader.
  ///
  /// In pt, this message translates to:
  /// **'Os 7 “Hoje:” desta semana'**
  String get seasonWeekInsightsHeader;

  /// No description provided for @seasonWeekReview.
  ///
  /// In pt, this message translates to:
  /// **'Revisão da semana'**
  String get seasonWeekReview;

  /// No description provided for @seasonWeekReviewPro.
  ///
  /// In pt, this message translates to:
  /// **'Revisão da semana · Peregrino+'**
  String get seasonWeekReviewPro;

  /// No description provided for @seasonWeekReviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Revisão da semana {week}'**
  String seasonWeekReviewTitle(int week);

  /// No description provided for @settingsAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get settingsAbout;

  /// No description provided for @settingsAboutSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Aprenda a Bíblia em cenas curtas, no seu ritmo.'**
  String get settingsAboutSubtitle;

  /// No description provided for @settingsAboutTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sobre o Stway'**
  String get settingsAboutTitle;

  /// No description provided for @settingsAccount.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get settingsAccount;

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsBackupInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Backup inválido.'**
  String get settingsBackupInvalid;

  /// No description provided for @settingsBackupSheetBody.
  ///
  /// In pt, this message translates to:
  /// **'Exporte o progresso como texto, ou copie um backup e toque em restaurar.'**
  String get settingsBackupSheetBody;

  /// No description provided for @settingsBackupSubject.
  ///
  /// In pt, this message translates to:
  /// **'Backup Stway'**
  String get settingsBackupSubject;

  /// No description provided for @settingsCheck.
  ///
  /// In pt, this message translates to:
  /// **'Verificar'**
  String get settingsCheck;

  /// No description provided for @settingsCheckingUpdate.
  ///
  /// In pt, this message translates to:
  /// **'Procurando atualização…'**
  String get settingsCheckingUpdate;

  /// No description provided for @settingsCreditsRowSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Textos bíblicos e estudo'**
  String get settingsCreditsRowSubtitle;

  /// No description provided for @settingsCreditsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Textos bíblicos e ferramentas de estudo usados no Stway.'**
  String get settingsCreditsSubtitle;

  /// No description provided for @settingsCreditsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Traduções e créditos'**
  String get settingsCreditsTitle;

  /// No description provided for @settingsDailyReminder.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete diário'**
  String get settingsDailyReminder;

  /// No description provided for @settingsDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia} other{{count} dias}}'**
  String settingsDays(int count);

  /// No description provided for @settingsDeleteProgress.
  ///
  /// In pt, this message translates to:
  /// **'Apagar progresso'**
  String get settingsDeleteProgress;

  /// No description provided for @settingsDeleteProgressSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Apaga o progresso de vez · pede confirmação'**
  String get settingsDeleteProgressSubtitle;

  /// No description provided for @settingsDeviceId.
  ///
  /// In pt, this message translates to:
  /// **'Dispositivo · {id}'**
  String settingsDeviceId(String id);

  /// No description provided for @settingsDeviceOnly.
  ///
  /// In pt, this message translates to:
  /// **'Só neste aparelho'**
  String get settingsDeviceOnly;

  /// No description provided for @settingsExport.
  ///
  /// In pt, this message translates to:
  /// **'Exportar'**
  String get settingsExport;

  /// No description provided for @settingsFontExtra.
  ///
  /// In pt, this message translates to:
  /// **'Extra'**
  String get settingsFontExtra;

  /// No description provided for @settingsFontLarge.
  ///
  /// In pt, this message translates to:
  /// **'Grande'**
  String get settingsFontLarge;

  /// No description provided for @settingsFontMedium.
  ///
  /// In pt, this message translates to:
  /// **'Médio'**
  String get settingsFontMedium;

  /// No description provided for @settingsFontSmall.
  ///
  /// In pt, this message translates to:
  /// **'Pequeno'**
  String get settingsFontSmall;

  /// No description provided for @settingsGenesisTitle.
  ///
  /// In pt, this message translates to:
  /// **'Gênesis 1–11'**
  String get settingsGenesisTitle;

  /// No description provided for @settingsGroupAccountData.
  ///
  /// In pt, this message translates to:
  /// **'Conta e dados'**
  String get settingsGroupAccountData;

  /// No description provided for @settingsGroupDevice.
  ///
  /// In pt, this message translates to:
  /// **'Neste aparelho'**
  String get settingsGroupDevice;

  /// No description provided for @settingsGroupProgress.
  ///
  /// In pt, this message translates to:
  /// **'Progresso'**
  String get settingsGroupProgress;

  /// No description provided for @settingsInCloud.
  ///
  /// In pt, this message translates to:
  /// **'Na nuvem'**
  String get settingsInCloud;

  /// No description provided for @settingsLastBackup.
  ///
  /// In pt, this message translates to:
  /// **'Último backup · {date}'**
  String settingsLastBackup(String date);

  /// No description provided for @settingsLastShort.
  ///
  /// In pt, this message translates to:
  /// **'Último · {date}'**
  String settingsLastShort(String date);

  /// No description provided for @settingsManualBackup.
  ///
  /// In pt, this message translates to:
  /// **'Backup manual'**
  String get settingsManualBackup;

  /// No description provided for @settingsManualBackupSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Exportar ou restaurar o progresso'**
  String get settingsManualBackupSubtitle;

  /// No description provided for @settingsPaceIntense.
  ///
  /// In pt, this message translates to:
  /// **'Intenso'**
  String get settingsPaceIntense;

  /// No description provided for @settingsPaceLight.
  ///
  /// In pt, this message translates to:
  /// **'Leve'**
  String get settingsPaceLight;

  /// No description provided for @settingsPaceSteady.
  ///
  /// In pt, this message translates to:
  /// **'Firme'**
  String get settingsPaceSteady;

  /// No description provided for @settingsPasteBackupFirst.
  ///
  /// In pt, this message translates to:
  /// **'Cole o backup na área de transferência primeiro.'**
  String get settingsPasteBackupFirst;

  /// No description provided for @settingsPlusTeaser.
  ///
  /// In pt, this message translates to:
  /// **'Mais espaço para a companhia'**
  String get settingsPlusTeaser;

  /// No description provided for @settingsProgressInCloud.
  ///
  /// In pt, this message translates to:
  /// **'Progresso na nuvem'**
  String get settingsProgressInCloud;

  /// No description provided for @settingsProgressRestored.
  ///
  /// In pt, this message translates to:
  /// **'Progresso restaurado.'**
  String get settingsProgressRestored;

  /// No description provided for @settingsReminderAt.
  ///
  /// In pt, this message translates to:
  /// **'Às {hour}h · toque para mudar'**
  String settingsReminderAt(int hour);

  /// No description provided for @settingsRemindersTitle.
  ///
  /// In pt, this message translates to:
  /// **'Lembretes'**
  String get settingsRemindersTitle;

  /// No description provided for @settingsReplayIntro.
  ///
  /// In pt, this message translates to:
  /// **'Rever introdução'**
  String get settingsReplayIntro;

  /// No description provided for @settingsReplayIntroSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'A apresentação do começo, de novo'**
  String get settingsReplayIntroSubtitle;

  /// No description provided for @settingsRestoreFromClipboard.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar da área de transferência'**
  String get settingsRestoreFromClipboard;

  /// No description provided for @settingsRhythmSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Quantas cenas cabem no seu dia.'**
  String get settingsRhythmSubtitle;

  /// No description provided for @settingsRhythmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ritmo diário'**
  String get settingsRhythmTitle;

  /// No description provided for @settingsSampleVerse.
  ///
  /// In pt, this message translates to:
  /// **'No princípio, criou Deus os céus e a terra.'**
  String get settingsSampleVerse;

  /// No description provided for @settingsSaveName.
  ///
  /// In pt, this message translates to:
  /// **'Salvar nome'**
  String get settingsSaveName;

  /// No description provided for @settingsSavedInCloud.
  ///
  /// In pt, this message translates to:
  /// **'Salvo na nuvem · {date}'**
  String settingsSavedInCloud(String date);

  /// No description provided for @settingsScenes.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 cena} other{{count} cenas}}'**
  String settingsScenes(int count);

  /// No description provided for @settingsScenesPerDay.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 cena por dia} other{{count} cenas por dia}}'**
  String settingsScenesPerDay(int count);

  /// No description provided for @settingsSignInAgain.
  ///
  /// In pt, this message translates to:
  /// **'Entre de novo para sincronizar o progresso.'**
  String get settingsSignInAgain;

  /// No description provided for @settingsSignOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível sair. Tente de novo.'**
  String get settingsSignOutFailed;

  /// No description provided for @settingsSignOutSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Limpa este aparelho · o progresso fica na nuvem'**
  String get settingsSignOutSubtitle;

  /// No description provided for @settingsSignedInAs.
  ///
  /// In pt, this message translates to:
  /// **'Conectado como {email}'**
  String settingsSignedInAs(String email);

  /// No description provided for @settingsSounds.
  ///
  /// In pt, this message translates to:
  /// **'Sons'**
  String get settingsSounds;

  /// No description provided for @settingsSoundsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Efeitos nas cenas'**
  String get settingsSoundsSubtitle;

  /// No description provided for @settingsStreakGoalHint.
  ///
  /// In pt, this message translates to:
  /// **'Até quantos dias você quer levar sua sequência.'**
  String get settingsStreakGoalHint;

  /// No description provided for @settingsStreakGoalLabel.
  ///
  /// In pt, this message translates to:
  /// **'Compromisso de sequência'**
  String get settingsStreakGoalLabel;

  /// No description provided for @settingsStudyAttribution.
  ///
  /// In pt, this message translates to:
  /// **'Estudo (Strong) — {attribution}'**
  String settingsStudyAttribution(String attribution);

  /// No description provided for @settingsSubscriptionActive.
  ///
  /// In pt, this message translates to:
  /// **'Assinatura ativa'**
  String get settingsSubscriptionActive;

  /// No description provided for @settingsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Conta, aparência e lembretes'**
  String get settingsSubtitle;

  /// No description provided for @settingsSupport.
  ///
  /// In pt, this message translates to:
  /// **'Ajude a continuar'**
  String get settingsSupport;

  /// No description provided for @settingsTextSize.
  ///
  /// In pt, this message translates to:
  /// **'Tamanho do texto'**
  String get settingsTextSize;

  /// No description provided for @settingsTextSizeHint.
  ///
  /// In pt, this message translates to:
  /// **'O versículo abaixo muda junto.'**
  String get settingsTextSizeHint;

  /// No description provided for @settingsThemeAuto.
  ///
  /// In pt, this message translates to:
  /// **'Automático'**
  String get settingsThemeAuto;

  /// No description provided for @settingsThemeCaptionAuto.
  ///
  /// In pt, this message translates to:
  /// **'Muda com o horário'**
  String get settingsThemeCaptionAuto;

  /// No description provided for @settingsThemeCaptionDark.
  ///
  /// In pt, this message translates to:
  /// **'Sempre escuro'**
  String get settingsThemeCaptionDark;

  /// No description provided for @settingsThemeCaptionLight.
  ///
  /// In pt, this message translates to:
  /// **'Sempre claro'**
  String get settingsThemeCaptionLight;

  /// No description provided for @settingsThemeCaptionMedium.
  ///
  /// In pt, this message translates to:
  /// **'Sempre em meia-luz'**
  String get settingsThemeCaptionMedium;

  /// No description provided for @settingsThemeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeHint.
  ///
  /// In pt, this message translates to:
  /// **'Um tema fixo, ou automático conforme o horário.'**
  String get settingsThemeHint;

  /// No description provided for @settingsThemeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get settingsThemeLabel;

  /// No description provided for @settingsThemeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeMedium.
  ///
  /// In pt, this message translates to:
  /// **'Médio'**
  String get settingsThemeMedium;

  /// No description provided for @settingsThemeSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Tema da tela'**
  String get settingsThemeSemantics;

  /// No description provided for @settingsThemeSemanticsHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque ou deslize para escolher'**
  String get settingsThemeSemanticsHint;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsUpToDate.
  ///
  /// In pt, this message translates to:
  /// **'Você está na versão mais recente · {version}'**
  String settingsUpToDate(String version);

  /// No description provided for @settingsVersion.
  ///
  /// In pt, this message translates to:
  /// **'Versão'**
  String get settingsVersion;

  /// No description provided for @settingsYourName.
  ///
  /// In pt, this message translates to:
  /// **'Seu nome'**
  String get settingsYourName;

  /// No description provided for @shellReferralBonus.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Seu convite valeu +{steps} passos} other{Seus convites valeram +{steps} passos}}'**
  String shellReferralBonus(int count, int steps);

  /// No description provided for @shellTogetherSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Companhia · Caravana · Grupos'**
  String get shellTogetherSubtitle;

  /// No description provided for @shellTrailsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O mapa da jornada'**
  String get shellTrailsSubtitle;

  /// No description provided for @shellWeekTogetherBonus.
  ///
  /// In pt, this message translates to:
  /// **'A companhia ganhou +{steps} passos na jornada'**
  String shellWeekTogetherBonus(int steps);

  /// No description provided for @splashPreparing.
  ///
  /// In pt, this message translates to:
  /// **'Preparando sua jornada…'**
  String get splashPreparing;

  /// No description provided for @splashSlogan.
  ///
  /// In pt, this message translates to:
  /// **'A Bíblia, cena a cena'**
  String get splashSlogan;

  /// No description provided for @streakDayEmpty.
  ///
  /// In pt, this message translates to:
  /// **'sem cena'**
  String get streakDayEmpty;

  /// No description provided for @streakDayFrozen.
  ///
  /// In pt, this message translates to:
  /// **'protegido pelo gelo'**
  String get streakDayFrozen;

  /// No description provided for @streakDaySemantics.
  ///
  /// In pt, this message translates to:
  /// **'{day}: {status}'**
  String streakDaySemantics(String day, String status);

  /// No description provided for @streakDayTodaySemantics.
  ///
  /// In pt, this message translates to:
  /// **'Hoje, {day}: {status}'**
  String streakDayTodaySemantics(String day, String status);

  /// No description provided for @streakRepairAction.
  ///
  /// In pt, this message translates to:
  /// **'Reparar'**
  String get streakRepairAction;

  /// No description provided for @streakRepairBody.
  ///
  /// In pt, this message translates to:
  /// **'{broken, plural, =1{Você tinha 1 dia. Restaure para {restored} — 1× neste mês.} other{Você tinha {broken} dias. Restaure para {restored} — 1× neste mês.}}'**
  String streakRepairBody(int broken, int restored);

  /// No description provided for @streakRepairCanReturn.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia ainda pode voltar} other{{count} dias ainda podem voltar}}'**
  String streakRepairCanReturn(int count);

  /// No description provided for @streakRepairContinueWith.
  ///
  /// In pt, this message translates to:
  /// **'Continue com {count} · 1× neste mês'**
  String streakRepairContinueWith(int count);

  /// No description provided for @streakRepairDismiss.
  ///
  /// In pt, this message translates to:
  /// **'Deixar'**
  String get streakRepairDismiss;

  /// No description provided for @streakRepairDone.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Sequência restaurada · 1 dia} other{Sequência restaurada · {count} dias}}'**
  String streakRepairDone(int count);

  /// No description provided for @streakRepairTitle.
  ///
  /// In pt, this message translates to:
  /// **'Reparar sequência'**
  String get streakRepairTitle;

  /// Share text the user sends to friends. {signature} is empty or a new line with the user's name.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{🔥 1 dia no Stway!\n\nEstou aprendendo a Bíblia em cenas curtas — {steps} passos até agora.{signature}\n\nBaixe o Stway e venha junto.} other{🔥 {count} dias no Stway!\n\nEstou aprendendo a Bíblia em cenas curtas — {steps} passos até agora.{signature}\n\nBaixe o Stway e venha junto.}}'**
  String streakShareDays(int count, int steps, String signature);

  /// No description provided for @streakShareStart.
  ///
  /// In pt, this message translates to:
  /// **'🔥 Comecei a aprender a Bíblia com o Stway.{signature}\n\nBaixe o Stway e venha junto.'**
  String streakShareStart(String signature);

  /// No description provided for @streakShareSteps.
  ///
  /// In pt, this message translates to:
  /// **'🔥 Estou aprendendo a Bíblia no Stway — {steps} passos até agora.{signature}\n\nBaixe o Stway e venha junto.'**
  String streakShareSteps(int steps, String signature);

  /// No description provided for @streakShareSubject.
  ///
  /// In pt, this message translates to:
  /// **'Minha sequência no Stway'**
  String get streakShareSubject;

  /// No description provided for @streakShareTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar sequência'**
  String get streakShareTooltip;

  /// No description provided for @strongKindConjunction.
  ///
  /// In pt, this message translates to:
  /// **'Conjunção'**
  String get strongKindConjunction;

  /// No description provided for @strongKindGreek.
  ///
  /// In pt, this message translates to:
  /// **'Grego'**
  String get strongKindGreek;

  /// No description provided for @strongKindHebrew.
  ///
  /// In pt, this message translates to:
  /// **'Hebraico'**
  String get strongKindHebrew;

  /// No description provided for @strongKindParticle.
  ///
  /// In pt, this message translates to:
  /// **'Partícula'**
  String get strongKindParticle;

  /// No description provided for @strongKindPrefix.
  ///
  /// In pt, this message translates to:
  /// **'Prefixo'**
  String get strongKindPrefix;

  /// No description provided for @strongKindPronoun.
  ///
  /// In pt, this message translates to:
  /// **'Pronome'**
  String get strongKindPronoun;

  /// No description provided for @strongKindPunctuation.
  ///
  /// In pt, this message translates to:
  /// **'Pontuação'**
  String get strongKindPunctuation;

  /// No description provided for @strongKindSuffix.
  ///
  /// In pt, this message translates to:
  /// **'Sufixo'**
  String get strongKindSuffix;

  /// No description provided for @strongNoteConjunction.
  ///
  /// In pt, this message translates to:
  /// **'Conjunção prefixada (vav). O sentido está no verbo ou no nome que ela liga.'**
  String get strongNoteConjunction;

  /// No description provided for @strongNoteParticle.
  ///
  /// In pt, this message translates to:
  /// **'Partícula gramatical do sistema STEP, não um número Strong clássico.'**
  String get strongNoteParticle;

  /// No description provided for @strongNotePrefix.
  ///
  /// In pt, this message translates to:
  /// **'Preposição ou artigo inseparável — cola-se à palavra seguinte. Não é verbete do Strong clássico.'**
  String get strongNotePrefix;

  /// No description provided for @strongNotePronoun.
  ///
  /// In pt, this message translates to:
  /// **'Pronome sufixado: quem recebe ou possui o que a palavra diz.'**
  String get strongNotePronoun;

  /// No description provided for @strongNotePunctuation.
  ///
  /// In pt, this message translates to:
  /// **'Marca de leitura do texto hebraico, não uma palavra.'**
  String get strongNotePunctuation;

  /// No description provided for @strongNoteSuffix.
  ///
  /// In pt, this message translates to:
  /// **'Terminação gramatical, não um verbete de dicionário.'**
  String get strongNoteSuffix;

  /// No description provided for @suggestionAuthorEmail.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get suggestionAuthorEmail;

  /// No description provided for @suggestionAuthorEmailHint.
  ///
  /// In pt, this message translates to:
  /// **'nome@email.com'**
  String get suggestionAuthorEmailHint;

  /// No description provided for @suggestionAuthorHintContact.
  ///
  /// In pt, this message translates to:
  /// **'Informe telefone, e-mail ou Instagram.'**
  String get suggestionAuthorHintContact;

  /// No description provided for @suggestionAuthorHintEmail.
  ///
  /// In pt, this message translates to:
  /// **'Confira o e-mail.'**
  String get suggestionAuthorHintEmail;

  /// No description provided for @suggestionAuthorHintInstagram.
  ///
  /// In pt, this message translates to:
  /// **'Confira o Instagram.'**
  String get suggestionAuthorHintInstagram;

  /// No description provided for @suggestionAuthorHintName.
  ///
  /// In pt, this message translates to:
  /// **'Escreva o nome — pelo menos 2 letras.'**
  String get suggestionAuthorHintName;

  /// No description provided for @suggestionAuthorHintPhone.
  ///
  /// In pt, this message translates to:
  /// **'Confira o telefone, com DDD.'**
  String get suggestionAuthorHintPhone;

  /// No description provided for @suggestionAuthorInstagramHint.
  ///
  /// In pt, this message translates to:
  /// **'@usuario'**
  String get suggestionAuthorInstagramHint;

  /// No description provided for @suggestionAuthorName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get suggestionAuthorName;

  /// No description provided for @suggestionAuthorNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Como a pessoa se apresenta'**
  String get suggestionAuthorNameHint;

  /// No description provided for @suggestionAuthorPhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone'**
  String get suggestionAuthorPhone;

  /// No description provided for @suggestionAuthorSent.
  ///
  /// In pt, this message translates to:
  /// **'Sugestão enviada. Obrigado por indicar o autor.'**
  String get suggestionAuthorSent;

  /// No description provided for @suggestionAuthorSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem ainda falta no mapa?'**
  String get suggestionAuthorSubtitle;

  /// No description provided for @suggestionAuthorTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sugerir um autor'**
  String get suggestionAuthorTitle;

  /// No description provided for @suggestionHintAntigoTestamento.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Salmos, Êxodo, os profetas…'**
  String get suggestionHintAntigoTestamento;

  /// No description provided for @suggestionHintNovoTestamento.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: o Sermão do Monte, Romanos, Atos…'**
  String get suggestionHintNovoTestamento;

  /// No description provided for @suggestionHintOther.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: um tema, um livro ou uma pergunta que ainda falta…'**
  String get suggestionHintOther;

  /// No description provided for @suggestionHintTeologia.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Trindade, hermenêutica, hebraico…'**
  String get suggestionHintTeologia;

  /// No description provided for @suggestionHintVidaCrista.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: oração, jejum, a história da igreja…'**
  String get suggestionHintVidaCrista;

  /// No description provided for @suggestionSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar sugestão'**
  String get suggestionSend;

  /// No description provided for @suggestionSendError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível enviar. Tente de novo.'**
  String get suggestionSendError;

  /// No description provided for @suggestionSending.
  ///
  /// In pt, this message translates to:
  /// **'Enviando…'**
  String get suggestionSending;

  /// No description provided for @suggestionSignInToSend.
  ///
  /// In pt, this message translates to:
  /// **'Entre para enviar a sugestão.'**
  String get suggestionSignInToSend;

  /// No description provided for @suggestionTrailHintBoth.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma área e descreva a trilha.'**
  String get suggestionTrailHintBoth;

  /// No description provided for @suggestionTrailHintRealm.
  ///
  /// In pt, this message translates to:
  /// **'Escolha onde essa trilha encaixa.'**
  String get suggestionTrailHintRealm;

  /// No description provided for @suggestionTrailHintText.
  ///
  /// In pt, this message translates to:
  /// **'Escreva a trilha — pelo menos 4 letras.'**
  String get suggestionTrailHintText;

  /// No description provided for @suggestionTrailPlaceholder.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma área e descreva a trilha…'**
  String get suggestionTrailPlaceholder;

  /// No description provided for @suggestionTrailRealmLabel.
  ///
  /// In pt, this message translates to:
  /// **'Onde encaixa'**
  String get suggestionTrailRealmLabel;

  /// No description provided for @suggestionTrailSent.
  ///
  /// In pt, this message translates to:
  /// **'Sugestão enviada. Obrigado.'**
  String get suggestionTrailSent;

  /// No description provided for @suggestionTrailSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'O que ainda falta no mapa?'**
  String get suggestionTrailSubtitle;

  /// No description provided for @suggestionTrailTextLabel.
  ///
  /// In pt, this message translates to:
  /// **'A trilha'**
  String get suggestionTrailTextLabel;

  /// No description provided for @suggestionTrailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sugerir uma trilha'**
  String get suggestionTrailTitle;

  /// No description provided for @tomorrowDayOf.
  ///
  /// In pt, this message translates to:
  /// **'Dia {streak} de {goal}'**
  String tomorrowDayOf(int streak, int goal);

  /// No description provided for @tomorrowLine.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã: {title}'**
  String tomorrowLine(String title);

  /// No description provided for @tomorrowNextTrail.
  ///
  /// In pt, this message translates to:
  /// **'Próxima trilha'**
  String get tomorrowNextTrail;

  /// No description provided for @tomorrowNextTrailOnMap.
  ///
  /// In pt, this message translates to:
  /// **'A próxima trilha já está no mapa.'**
  String get tomorrowNextTrailOnMap;

  /// No description provided for @tomorrowSceneWaits.
  ///
  /// In pt, this message translates to:
  /// **'A cena espera você.'**
  String get tomorrowSceneWaits;

  /// No description provided for @tomorrowSevenDays.
  ///
  /// In pt, this message translates to:
  /// **'Sete dias. O hábito pegou.'**
  String get tomorrowSevenDays;

  /// No description provided for @tomorrowStoryContinues.
  ///
  /// In pt, this message translates to:
  /// **'A história continua no texto.'**
  String get tomorrowStoryContinues;

  /// No description provided for @tomorrowTodayYouSaw.
  ///
  /// In pt, this message translates to:
  /// **'Hoje você viu'**
  String get tomorrowTodayYouSaw;

  /// No description provided for @tomorrowYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem: {text}'**
  String tomorrowYesterday(String text);

  /// Boss/review scene at the end of a stage
  ///
  /// In pt, this message translates to:
  /// **'Travessia'**
  String get trailMapCrossing;

  /// A locked scene
  ///
  /// In pt, this message translates to:
  /// **'Bloqueada'**
  String get trailMapLocked;

  /// No description provided for @trailMapScene.
  ///
  /// In pt, this message translates to:
  /// **'Cena'**
  String get trailMapScene;

  /// Character seal; name is a Bible character
  ///
  /// In pt, this message translates to:
  /// **'Selo {name}'**
  String trailMapSeal(String name);

  /// No description provided for @trailsAreasHeading.
  ///
  /// In pt, this message translates to:
  /// **'As áreas'**
  String get trailsAreasHeading;

  /// Status of a scene, stage or trail (feminine in pt/es)
  ///
  /// In pt, this message translates to:
  /// **'Concluída'**
  String get trailsCleared;

  /// Screen reader label; title = scene title
  ///
  /// In pt, this message translates to:
  /// **'Continuar · {title}'**
  String trailsContinueSemantics(String title);

  /// No description provided for @trailsDonateBody.
  ///
  /// In pt, this message translates to:
  /// **'Uma contribuição voluntária para as próximas trilhas.'**
  String get trailsDonateBody;

  /// No description provided for @trailsDonateCta.
  ///
  /// In pt, this message translates to:
  /// **'Doar'**
  String get trailsDonateCta;

  /// No description provided for @trailsDonateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ajude a continuar'**
  String get trailsDonateTitle;

  /// No description provided for @trailsDoneOfTotal.
  ///
  /// In pt, this message translates to:
  /// **'{done} de {total}'**
  String trailsDoneOfTotal(int done, int total);

  /// No description provided for @trailsDownloading.
  ///
  /// In pt, this message translates to:
  /// **'Baixando…'**
  String get trailsDownloading;

  /// No description provided for @trailsEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'O currículo baixa na primeira abertura. Se a rede oscilar, toque para tentar de novo.'**
  String get trailsEmptyBody;

  /// No description provided for @trailsEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'As cenas ainda não chegaram'**
  String get trailsEmptyTitle;

  /// No description provided for @trailsHorizonBody.
  ///
  /// In pt, this message translates to:
  /// **'Novas trilhas estão sendo preparadas.'**
  String get trailsHorizonBody;

  /// No description provided for @trailsHorizonEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'No horizonte'**
  String get trailsHorizonEyebrow;

  /// No description provided for @trailsInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Em andamento'**
  String get trailsInProgress;

  /// label is a study mode name or a trail title
  ///
  /// In pt, this message translates to:
  /// **'{total, plural, =1{{label} · {done} de 1 cena} other{{label} · {done} de {total} cenas}}'**
  String trailsLabeledScenesOf(String label, int done, int total);

  /// No description provided for @trailsLearnMore.
  ///
  /// In pt, this message translates to:
  /// **'Saiba mais'**
  String get trailsLearnMore;

  /// No description provided for @trailsModeAllSealed.
  ///
  /// In pt, this message translates to:
  /// **'{mode} concluída · os três modos desta trilha estão selados'**
  String trailsModeAllSealed(String mode);

  /// No description provided for @trailsModeChip.
  ///
  /// In pt, this message translates to:
  /// **'Modo {mode}'**
  String trailsModeChip(String mode);

  /// mode = Observação/Compreensão/Interpretação
  ///
  /// In pt, this message translates to:
  /// **'{mode} concluída'**
  String trailsModeCleared(String mode);

  /// No description provided for @trailsModeNextHint.
  ///
  /// In pt, this message translates to:
  /// **'{mode} concluída · o próximo modo é {next}'**
  String trailsModeNextHint(String mode, String next);

  /// No description provided for @trailsModeReplayHint.
  ///
  /// In pt, this message translates to:
  /// **'{cleared} concluída · progresso abaixo é do modo {active}'**
  String trailsModeReplayHint(String cleared, String active);

  /// modes = list of mode names joined by ' · '
  ///
  /// In pt, this message translates to:
  /// **'{modes} concluídas'**
  String trailsModesCleared(String modes);

  /// Number of unlocked trails in an area
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 aberta} other{{count} abertas}}'**
  String trailsRealmOpenCount(int count);

  /// No description provided for @trailsRealmTrailCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 trilha} other{{count} trilhas}}'**
  String trailsRealmTrailCount(int count);

  /// No description provided for @trailsRealmTrailsDone.
  ///
  /// In pt, this message translates to:
  /// **'{total, plural, =1{{done} de 1 trilha} other{{done} de {total} trilhas}}'**
  String trailsRealmTrailsDone(int done, int total);

  /// No description provided for @trailsScenesOf.
  ///
  /// In pt, this message translates to:
  /// **'{total, plural, =1{{done} de 1 cena} other{{done} de {total} cenas}}'**
  String trailsScenesOf(int done, int total);

  /// No description provided for @trailsScenesShort.
  ///
  /// In pt, this message translates to:
  /// **'{total, plural, =1{{done}/1 cena} other{{done}/{total} cenas}}'**
  String trailsScenesShort(int done, int total);

  /// Module number in Roman numerals, e.g. Etapa II
  ///
  /// In pt, this message translates to:
  /// **'Etapa {roman}'**
  String trailsStage(String roman);

  /// countdown is a preformatted time left, e.g. 3h 20min
  ///
  /// In pt, this message translates to:
  /// **'Sequência cai em {countdown}'**
  String trailsStreakAtRisk(String countdown);

  /// Trail number in Roman numerals
  ///
  /// In pt, this message translates to:
  /// **'Trilha {roman}'**
  String trailsTrailNumber(String roman);

  /// No description provided for @updateCheckDisabled.
  ///
  /// In pt, this message translates to:
  /// **'Checagem desligada.'**
  String get updateCheckDisabled;

  /// No description provided for @updateCheckFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível verificar agora.'**
  String get updateCheckFailed;

  /// No description provided for @updateDefaultMessage.
  ///
  /// In pt, this message translates to:
  /// **'Uma nova versão do Stway está pronta, com melhorias e correções.'**
  String get updateDefaultMessage;

  /// No description provided for @updateEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Atualização'**
  String get updateEyebrow;

  /// No description provided for @updateFirebaseUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Firebase indisponível.'**
  String get updateFirebaseUnavailable;

  /// No description provided for @updateForceTitle.
  ///
  /// In pt, this message translates to:
  /// **'Esta versão precisa atualizar'**
  String get updateForceTitle;

  /// No description provided for @updateInStore.
  ///
  /// In pt, this message translates to:
  /// **'Na loja'**
  String get updateInStore;

  /// No description provided for @updateNoneInCloud.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma versão publicada na nuvem.'**
  String get updateNoneInCloud;

  /// No description provided for @updateNow.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar agora'**
  String get updateNow;

  /// No description provided for @updateSoftTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova versão disponível'**
  String get updateSoftTitle;

  /// No description provided for @updateStoreOpenFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir a loja. Tente de novo.'**
  String get updateStoreOpenFailed;

  /// No description provided for @verseStudyAttribution.
  ///
  /// In pt, this message translates to:
  /// **'Léxico e texto etiquetado: STEPBible / Tyndale House Cambridge (CC BY 4.0). Referências cruzadas: openbible.info (CC BY). Definições traduzidas automaticamente para português.'**
  String get verseStudyAttribution;

  /// No description provided for @verseStudyCopied.
  ///
  /// In pt, this message translates to:
  /// **'Copiado'**
  String get verseStudyCopied;

  /// No description provided for @verseStudyCrossRefs.
  ///
  /// In pt, this message translates to:
  /// **'Referências cruzadas'**
  String get verseStudyCrossRefs;

  /// No description provided for @verseStudyDefinition.
  ///
  /// In pt, this message translates to:
  /// **'Definição'**
  String get verseStudyDefinition;

  /// No description provided for @verseStudyEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'O léxico Strong, a gramática e cada vez que ela aparece nas Escrituras abrem aqui.'**
  String get verseStudyEmptyBody;

  /// No description provided for @verseStudyEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Toque numa palavra original'**
  String get verseStudyEmptyTitle;

  /// No description provided for @verseStudyEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Estudar'**
  String get verseStudyEyebrow;

  /// No description provided for @verseStudyFirst.
  ///
  /// In pt, this message translates to:
  /// **'primeira'**
  String get verseStudyFirst;

  /// No description provided for @verseStudyGoToText.
  ///
  /// In pt, this message translates to:
  /// **'Ir para o texto'**
  String get verseStudyGoToText;

  /// No description provided for @verseStudyInThisBook.
  ///
  /// In pt, this message translates to:
  /// **'Neste livro — as aparições perto deste versículo.'**
  String get verseStudyInThisBook;

  /// No description provided for @verseStudyInThisVerse.
  ///
  /// In pt, this message translates to:
  /// **'Neste versículo'**
  String get verseStudyInThisVerse;

  /// No description provided for @verseStudyLast.
  ///
  /// In pt, this message translates to:
  /// **'última'**
  String get verseStudyLast;

  /// No description provided for @verseStudyLemma.
  ///
  /// In pt, this message translates to:
  /// **'Lema'**
  String get verseStudyLemma;

  /// No description provided for @verseStudyLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o estudo.'**
  String get verseStudyLoadFailed;

  /// No description provided for @verseStudyLoading.
  ///
  /// In pt, this message translates to:
  /// **'Abrindo o léxico…'**
  String get verseStudyLoading;

  /// No description provided for @verseStudyNeedsRestart.
  ///
  /// In pt, this message translates to:
  /// **'Feche e abra o app de novo para carregar o estudo.'**
  String get verseStudyNeedsRestart;

  /// No description provided for @verseStudyNoCrossRefs.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexões catalogadas para este versículo.'**
  String get verseStudyNoCrossRefs;

  /// No description provided for @verseStudyNoData.
  ///
  /// In pt, this message translates to:
  /// **'Sem dados de originais para este versículo.'**
  String get verseStudyNoData;

  /// No description provided for @verseStudyNoOtherHits.
  ///
  /// In pt, this message translates to:
  /// **'Sem outras ocorrências neste recorte.'**
  String get verseStudyNoOtherHits;

  /// No description provided for @verseStudyNotLiteral.
  ///
  /// In pt, this message translates to:
  /// **'A Tradução Brasileira não traz esta forma à letra neste versículo.'**
  String get verseStudyNotLiteral;

  /// No description provided for @verseStudyOccurrencesIn.
  ///
  /// In pt, this message translates to:
  /// **'Ocorrências em {book}'**
  String verseStudyOccurrencesIn(String book);

  /// No description provided for @verseStudyOnlyHere.
  ///
  /// In pt, this message translates to:
  /// **'Só neste versículo no índice.'**
  String get verseStudyOnlyHere;

  /// No description provided for @verseStudyOtherBooks.
  ///
  /// In pt, this message translates to:
  /// **'Em outros livros'**
  String get verseStudyOtherBooks;

  /// No description provided for @verseStudyOtherBooksBody.
  ///
  /// In pt, this message translates to:
  /// **'A primeira aparição em cada livro onde a palavra é mais frequente.'**
  String get verseStudyOtherBooksBody;

  /// No description provided for @verseStudyParticleNearby.
  ///
  /// In pt, this message translates to:
  /// **'Esta partícula aparece milhares de vezes. Abaixo, as formas perto deste versículo.'**
  String get verseStudyParticleNearby;

  /// No description provided for @verseStudyParticleNote.
  ///
  /// In pt, this message translates to:
  /// **'Partícula gramatical · {count} formas no cânon. O sentido está no nome ou no verbo que ela acompanha.'**
  String verseStudyParticleNote(int count);

  /// No description provided for @verseStudySpan.
  ///
  /// In pt, this message translates to:
  /// **'{count} lugares · de {first} a {last}'**
  String verseStudySpan(int count, String first, String last);

  /// No description provided for @verseStudyTabLinks.
  ///
  /// In pt, this message translates to:
  /// **'Conexões'**
  String get verseStudyTabLinks;

  /// No description provided for @verseStudyTabLinksCount.
  ///
  /// In pt, this message translates to:
  /// **'Conexões · {count}'**
  String verseStudyTabLinksCount(int count);

  /// No description provided for @verseStudyTabUses.
  ///
  /// In pt, this message translates to:
  /// **'Usos'**
  String get verseStudyTabUses;

  /// No description provided for @verseStudyTabUsesCount.
  ///
  /// In pt, this message translates to:
  /// **'Usos · {count}'**
  String verseStudyTabUsesCount(int count);

  /// No description provided for @verseStudyTabWord.
  ///
  /// In pt, this message translates to:
  /// **'Palavra'**
  String get verseStudyTabWord;

  /// No description provided for @verseStudyThisForm.
  ///
  /// In pt, this message translates to:
  /// **'Nesta forma'**
  String get verseStudyThisForm;

  /// No description provided for @verseStudyVerseUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Versículo indisponível nesta tradução.'**
  String get verseStudyVerseUnavailable;

  /// No description provided for @waveCta.
  ///
  /// In pt, this message translates to:
  /// **'Acenar'**
  String get waveCta;

  /// No description provided for @widgetBehindCaravan.
  ///
  /// In pt, this message translates to:
  /// **'Ficando para trás na caravana — caminhe hoje'**
  String get widgetBehindCaravan;

  /// No description provided for @widgetGoalDone.
  ///
  /// In pt, this message translates to:
  /// **'Meta concluída'**
  String get widgetGoalDone;

  /// No description provided for @widgetProgressScenes.
  ///
  /// In pt, this message translates to:
  /// **'{goal, plural, =1{{done}/1 cena} other{{done}/{goal} cenas}}'**
  String widgetProgressScenes(int done, int goal);

  /// No description provided for @widgetScenesLeftToday.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Falta 1 cena hoje} other{Faltam {count} cenas hoje}}'**
  String widgetScenesLeftToday(int count);

  /// No description provided for @widgetTodayTitle.
  ///
  /// In pt, this message translates to:
  /// **'Hoje: {title}'**
  String widgetTodayTitle(String title);

  /// No description provided for @widgetTomorrowTitle.
  ///
  /// In pt, this message translates to:
  /// **'Amanhã: {title}'**
  String widgetTomorrowTitle(String title);

  /// No description provided for @widgetTrailWaitsTomorrow.
  ///
  /// In pt, this message translates to:
  /// **'A trilha espera amanhã'**
  String get widgetTrailWaitsTomorrow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
