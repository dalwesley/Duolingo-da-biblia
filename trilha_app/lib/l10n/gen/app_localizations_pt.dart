// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get authAccountExists =>
      'Já existe uma conta com este e-mail usando outro método de login.';

  @override
  String get authEnableProviders =>
      'Ative os provedores no Firebase Console: Authentication → Sign-in method → Anonymous e/ou Google.';

  @override
  String get authFirebaseNotReady => 'Firebase ainda não está pronto.';

  @override
  String authGenericError(String code, String message) {
    return 'Erro de Auth ($code): $message';
  }

  @override
  String get authInvalidCredential =>
      'Credencial Google inválida. Cadastre o SHA-1 do app no Firebase e baixe o google-services.json de novo.';

  @override
  String get authLoginInProgress => 'Login em andamento.';

  @override
  String get authMissingIdToken =>
      'Google não retornou idToken. Confira se o SHA-1 da Play está no Firebase.';

  @override
  String get authNetworkReset =>
      'Falha de rede ao falar com o Firebase Auth (conexão resetada). Tente de novo em Wi‑Fi estável ou dados móveis.';

  @override
  String get authNoInternet =>
      'Sem conexão com a internet. Verifique o Wi‑Fi/dados do aparelho.';

  @override
  String get authTooManyRequests =>
      'Muitas tentativas. Aguarde um pouco e tente de novo.';

  @override
  String get avatarChangePortrait => 'Alterar retrato';

  @override
  String get avatarOpenProfile => 'Abrir perfil';

  @override
  String bibleBookFallback(int number) {
    return 'Livro $number';
  }

  @override
  String bibleBookReadSemantics(String book, int read, int total) {
    return '$book, $read de $total capítulos lidos';
  }

  @override
  String bibleChapterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capítulos',
      one: '1 capítulo',
    );
    return '$_temp0';
  }

  @override
  String bibleChapterCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caps.',
      one: '1 cap.',
    );
    return '$_temp0';
  }

  @override
  String bibleChapterLabel(int chapter) {
    return 'Capítulo $chapter';
  }

  @override
  String bibleChapterReadSemantics(int chapter) {
    return 'Capítulo $chapter, lido';
  }

  @override
  String bibleChaptersReadOf(int read, int total) {
    return '$read de $total lidos';
  }

  @override
  String get bibleDonate => 'Doar';

  @override
  String get bibleHeroContinueReading => 'Continuar leitura';

  @override
  String get bibleHeroFreshBlurb =>
      'Jesus, a Palavra que se fez carne — um bom começo.';

  @override
  String get bibleHeroStartHere => 'Comece por aqui';

  @override
  String get bibleHeroStartReading => 'Começar a ler';

  @override
  String get bibleIntroAudience => 'Para quem';

  @override
  String bibleIntroAuthorByTradition(String author) {
    return '$author · tradição';
  }

  @override
  String get bibleIntroWhen => 'Quando';

  @override
  String get bibleIntroWho => 'Quem';

  @override
  String get bibleNewTestament => 'Novo Testamento';

  @override
  String get bibleOldTestament => 'Antigo Testamento';

  @override
  String get biblePaperAuto => 'Automático';

  @override
  String get biblePaperLight => 'Clara';

  @override
  String get biblePaperNight => 'Noite';

  @override
  String biblePaperSemantics(String paper) {
    return 'Papel $paper';
  }

  @override
  String get biblePaperSepia => 'Sépia';

  @override
  String get biblePickerBackToBooks => 'Voltar aos livros';

  @override
  String get biblePickerTitle => 'Ir para';

  @override
  String get bibleReadChapter => 'Ler o capítulo';

  @override
  String bibleReadOf(int read, int total) {
    return '$read de $total';
  }

  @override
  String get bibleReaderChapterDone => 'Capítulo lido';

  @override
  String bibleReaderChapterEnd(String book, int chapter) {
    return 'Fim de $book $chapter';
  }

  @override
  String bibleReaderChapterReadToast(String book, int chapter) {
    return '$book $chapter lido';
  }

  @override
  String get bibleReaderCompleteChapter => 'Concluir capítulo';

  @override
  String get bibleReaderListen => 'Ouvir';

  @override
  String get bibleReaderNextChapter => 'Próximo capítulo';

  @override
  String bibleReaderOpenFailed(String reference) {
    return 'Não foi possível abrir $reference.';
  }

  @override
  String get bibleReaderPaper => 'Papel';

  @override
  String get bibleReaderPrevChapter => 'Capítulo anterior';

  @override
  String get bibleReaderReadTag => 'lido';

  @override
  String get bibleReaderSettings => 'Ajustes de leitura';

  @override
  String get bibleReaderStop => 'Parar';

  @override
  String bibleReaderSubtitle(int chapter, String translation) {
    return 'Capítulo $chapter · $translation';
  }

  @override
  String get bibleReaderTextSize => 'Tamanho do texto';

  @override
  String get bibleReaderUpNext => 'A seguir';

  @override
  String get bibleReaderVersion => 'Versão';

  @override
  String get bibleSavedEmptyBody =>
      'Na leitura, toque num versículo e escolha Guardar para voltar a ele depois.';

  @override
  String get bibleSavedEmptyTitle => 'Nenhum versículo guardado';

  @override
  String get bibleSavedTitle => 'Guardados';

  @override
  String get bibleSearchBookHit => 'Livro';

  @override
  String get bibleSearchButtonHint => 'Buscar livro, versículo ou palavra…';

  @override
  String get bibleSearchButtonSemantics => 'Buscar livro ou versículo';

  @override
  String get bibleSearchEmpty => 'Nenhum resultado encontrado';

  @override
  String get bibleSearchFieldHint => 'Ex.: Apocalipse, amor, fé…';

  @override
  String get bibleSearchSubtitle => 'Livros e versículos';

  @override
  String get bibleSearchTitle => 'Buscar';

  @override
  String bibleSectionBooksSemantics(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title, $count livros',
      one: '$title, 1 livro',
    );
    return '$_temp0';
  }

  @override
  String get bibleShareAsText => 'Compartilhar como texto';

  @override
  String get bibleShareImage => 'Compartilhar imagem';

  @override
  String get bibleSharePreparing => 'Preparando…';

  @override
  String get bibleShareTextFooter => 'Via Stway';

  @override
  String get bibleShareTitle => 'Compartilhar versículo';

  @override
  String bibleShareVia(String ref) {
    return '$ref — via Stway';
  }

  @override
  String get bibleTabReading => 'Leitura';

  @override
  String get bibleTapToClose => 'Toque para fechar';

  @override
  String get bibleTapToOpen => 'Toque para abrir';

  @override
  String get bibleTitle => 'Bíblia';

  @override
  String bibleTranslationSoonBody(String name) {
    return 'Ainda não temos $name. Em breve essa tradução entra no app. Você pode contribuir com o projeto para ajudar a trazer mais versões.';
  }

  @override
  String get bibleTranslationSoonTitle => 'Tradução em breve';

  @override
  String get bibleVerseCopied => 'Versículo copiado';

  @override
  String get bibleVerseCopy => 'Copiar';

  @override
  String bibleVerseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versículos',
      one: '1 versículo',
    );
    return '$_temp0';
  }

  @override
  String get bibleVerseListenFromHere => 'Ouvir daqui em diante';

  @override
  String get bibleVerseListenFromHereDetail =>
      'Leitura em voz alta, versículo a versículo';

  @override
  String get bibleVerseSave => 'Guardar';

  @override
  String get bibleVerseSaved => 'Guardado';

  @override
  String bibleVerseSemantics(int number, String text) {
    return 'Versículo $number. $text';
  }

  @override
  String get bibleVerseStudy => 'Estudar este versículo';

  @override
  String get bibleVerseStudyDetail =>
      'Originais, Strong, concordância e referências';

  @override
  String get canonEvangelhosBlurb => 'Mateus a João — a vida de Jesus';

  @override
  String get canonEvangelhosTitle => 'Evangelhos';

  @override
  String get canonGeraisBlurb => 'Hebreus a Judas';

  @override
  String get canonGeraisTitle => 'Cartas gerais';

  @override
  String get canonHistoriaNtBlurb => 'Atos dos Apóstolos';

  @override
  String get canonHistoriaNtTitle => 'História';

  @override
  String get canonHistoricosBlurb => 'Josué a Ester — a história de Israel';

  @override
  String get canonHistoricosTitle => 'Históricos';

  @override
  String get canonPaulinasBlurb => 'Romanos a Filemom';

  @override
  String get canonPaulinasTitle => 'Cartas paulinas';

  @override
  String get canonPentateucoBlurb => 'A Lei — Gênesis a Deuteronômio';

  @override
  String get canonPentateucoTitle => 'Pentateuco';

  @override
  String get canonPoeticosBlurb => 'Jó a Cantares';

  @override
  String get canonPoeticosTitle => 'Poéticos e sabedoria';

  @override
  String get canonProfeciaBlurb => 'Apocalipse';

  @override
  String get canonProfeciaTitle => 'Profecia';

  @override
  String get canonProfetasMaioresBlurb => 'Isaías a Daniel';

  @override
  String get canonProfetasMaioresTitle => 'Profetas maiores';

  @override
  String get canonProfetasMenoresBlurb => 'Oséias a Malaquias';

  @override
  String get canonProfetasMenoresTitle => 'Profetas menores';

  @override
  String get categoryApocalipseBlurb =>
      'O livro de Apocalipse, escrito por João Evangelista.';

  @override
  String get categoryApocalipseTitle => 'Apocalipse ou Revelação';

  @override
  String get categoryCristologiaTitle => 'Cristologia';

  @override
  String get categoryDiscipuladoTitle => 'Discipulado';

  @override
  String get categoryEpistolasBlurb =>
      'Vinte e uma cartas às primeiras igrejas — treze de Paulo e oito de outros autores.';

  @override
  String get categoryEpistolasTitle => 'Epístolas ou cartas apostólicas';

  @override
  String get categoryEvangelhosBlurb =>
      'Nascimento, ministério, morte, ressurreição e ascensão de Jesus — Mateus a João.';

  @override
  String get categoryEvangelhosTitle => 'Evangelhos';

  @override
  String get categoryHermeneuticaTitle => 'Hermenêutica';

  @override
  String get categoryHistoriaIgrejaTitle => 'História da Igreja';

  @override
  String get categoryHistoricosAtBlurb =>
      'A história de Israel da conquista da Terra Prometida até o exílio babilônico.';

  @override
  String get categoryHistoricosAtTitle => 'Livros históricos';

  @override
  String get categoryHistoricosNtBlurb =>
      'Atos dos Apóstolos — o derramar do Espírito e a expansão do Evangelho.';

  @override
  String get categoryHistoricosNtTitle => 'História da Igreja primitiva';

  @override
  String get categoryIntertestamentarioBlurb =>
      'Os cerca de 400 anos de silêncio entre o Antigo e o Novo Testamento.';

  @override
  String get categoryIntertestamentarioTitle => 'Período intertestamentário';

  @override
  String get categoryLinguasTitle => 'Línguas originais';

  @override
  String get categoryOracaoTitle => 'Oração';

  @override
  String get categoryPentateucoBlurb =>
      'Os cinco primeiros livros da Bíblia — a Torá, o Livro da Lei, em ordem cronológica.';

  @override
  String get categoryPentateucoTitle => 'Pentateuco';

  @override
  String get categoryPoeticosBlurb =>
      'Poesia, sabedoria, provérbios e cânticos — organizados por relevância.';

  @override
  String get categoryPoeticosTitle => 'Livros poéticos';

  @override
  String get categoryProfetasMaioresBlurb =>
      'Isaías a Daniel — obras mais extensas entre os registros proféticos.';

  @override
  String get categoryProfetasMaioresTitle => 'Profetas maiores';

  @override
  String get categoryProfetasMenoresBlurb =>
      'Oséias a Malaquias — doze livros; o nome refere-se à extensão, não à importância.';

  @override
  String get categoryProfetasMenoresTitle => 'Profetas menores';

  @override
  String get categorySistematicaTitle => 'Sistemática e dogmática';

  @override
  String get celebrationBackHome => 'Voltar ao início';

  @override
  String get celebrationBackToMap => 'Voltar ao mapa';

  @override
  String celebrationCommitmentBeyond(int goal) {
    return 'Além do compromisso de $goal dias.';
  }

  @override
  String celebrationCommitmentDone(int goal) {
    return 'Compromisso de $goal dias cumprido!';
  }

  @override
  String celebrationCommitmentLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count dias para o seu compromisso.',
      one: 'Falta 1 dia para o seu compromisso.',
    );
    return '$_temp0';
  }

  @override
  String get celebrationEchoKicker => 'Hoje você viu';

  @override
  String get celebrationHelpContinue => 'Ajude a continuar';

  @override
  String get celebrationInviteSubtitle =>
      'Um companheiro. Sem ranking — só presença.';

  @override
  String get celebrationInviteTitle => 'Uma companhia na trilha';

  @override
  String celebrationModeDone(String mode) {
    return 'Modo $mode concluído';
  }

  @override
  String celebrationModeRetryPrompt(String mode, String subtitle) {
    return 'Que tal responder de novo em $mode? $subtitle';
  }

  @override
  String celebrationModeReviewCta(String mode) {
    return 'Revisar uma cena em $mode';
  }

  @override
  String celebrationModeSwitchCta(String mode) {
    return 'Mudar para $mode';
  }

  @override
  String celebrationModeTryCta(String mode) {
    return 'Tentar em $mode';
  }

  @override
  String celebrationModeTryPrompt(String mode) {
    return 'Quer tentar as perguntas desta cena em $mode?';
  }

  @override
  String celebrationSceneDoneIn(String mode) {
    return 'Cena concluída em $mode';
  }

  @override
  String get celebrationSealKicker => 'Encontro';

  @override
  String get celebrationStatAccuracy => 'Acertos';

  @override
  String get celebrationStatDay => 'Dia';

  @override
  String get celebrationStatDays => 'Dias';

  @override
  String get celebrationStatSteps => 'Passos';

  @override
  String celebrationStreakPlusDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+1 dia · sequência de $count dias',
      one: '+1 dia · sequência de 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get celebrationStreakStarted => 'Sua sequência começou hoje.';

  @override
  String get celebrationTomorrowKicker => 'Amanhã';

  @override
  String get chestBencaoMessage =>
      '\"O Senhor te abençoe e te guarde\" — Números 6:24.';

  @override
  String get chestBencaoTitle => 'Bênção rara';

  @override
  String get chestDailyTitle => 'Baú do dia';

  @override
  String get chestGraoMessage => 'Pequeno hoje, semente de algo maior amanhã.';

  @override
  String get chestGraoTitle => 'Grão de trigo';

  @override
  String get chestGuardadaMessage =>
      'Este momento vale um versículo guardado no coração hoje.';

  @override
  String get chestGuardadaTitle => 'Palavra guardada';

  @override
  String get chestLampadaMessage =>
      '\"Lâmpada para os meus pés é a tua palavra\" — Salmos 119:105.';

  @override
  String get chestLampadaTitle => 'Lâmpada acesa';

  @override
  String get chestLocked => 'Complete a cena de hoje para abrir';

  @override
  String get chestLockedShort => 'Trancado';

  @override
  String get chestMapaMessage =>
      'Uma curiosidade guardada: cada capítulo lido soma na sua trilha.';

  @override
  String get chestMapaTitle => 'Mapa do dia';

  @override
  String get chestOpen => 'Abrir o baú';

  @override
  String get chestOpenShort => 'Abrir';

  @override
  String get chestOpened => 'Aberto';

  @override
  String get chestOpening => 'Abrindo…';

  @override
  String get chestPassoMessage =>
      'Mais um dia caminhando — é isso que forma um peregrino.';

  @override
  String get chestPassoTitle => 'Passo firme';

  @override
  String get chestReady => 'Sua recompensa de hoje está pronta';

  @override
  String get chestReadyShort => 'Pronto para abrir';

  @override
  String get chestRevealStarts => 'A revelação começa agora.';

  @override
  String get chestRewards => 'Recompensas';

  @override
  String get chestSheetTitle => 'A sequência de hoje guarda uma recompensa.';

  @override
  String chestTierToday(String tier) {
    return '$tier de hoje';
  }

  @override
  String get chestVeryRare => 'Raríssimo';

  @override
  String get chestVozMessage =>
      'Sua sequência já fala mais alto que qualquer palavra.';

  @override
  String get chestVozTitle => 'Voz da caravana';

  @override
  String get comebackEyebrow => 'O peregrino';

  @override
  String comebackSubtitle(String name, int bonus) {
    return '$name, a trilha espera você. Uma cena retoma a sequência e rende +$bonus passos de boas-vindas.';
  }

  @override
  String comebackSubtitleGap(String name, int count, int bonus) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$name, faz $count dias sem uma cena. Uma só basta — e você ganha +$bonus passos de boas-vindas.',
      one:
          '$name, faz 1 dia sem uma cena. Uma só basta — e você ganha +$bonus passos de boas-vindas.',
    );
    return '$_temp0';
  }

  @override
  String get comebackTitle => 'Sua sequência te espera';

  @override
  String get commonActive => 'Ativo';

  @override
  String get commonBack => 'Voltar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonCollect => 'Coletar';

  @override
  String get commonComingSoon => 'Em breve';

  @override
  String get commonContinue => 'Continuar';

  @override
  String commonDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get commonGotIt => 'Entendi';

  @override
  String get commonModule => 'Módulo';

  @override
  String get commonNextScene => 'Próxima cena';

  @override
  String get commonNotNow => 'Agora não';

  @override
  String get commonOff => 'Desligado';

  @override
  String commonPlusSteps(int count) {
    return '+$count passos';
  }

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonScene => 'Cena';

  @override
  String commonScenes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cenas',
      one: '1 cena',
    );
    return '$_temp0';
  }

  @override
  String get commonSendWhatsApp => 'Mandar no WhatsApp';

  @override
  String get commonShare => 'Compartilhar';

  @override
  String get commonSkip => 'Pular';

  @override
  String get commonStart => 'Começar';

  @override
  String commonSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passos',
      one: '1 passo',
    );
    return '$_temp0';
  }

  @override
  String get commonToday => 'Hoje';

  @override
  String get commonTrail => 'Trilha';

  @override
  String get commonTryAgain => 'Tentar de novo';

  @override
  String get commonYou => 'Você';

  @override
  String get companionAwaitingCode => 'Aguardando alguém entrar com o código';

  @override
  String companionDaysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias caminhando juntos',
      one: '1 dia caminhando juntos',
    );
    return '$_temp0';
  }

  @override
  String companionDaysWithoutStudy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias pra trás na caminhada',
      one: '1 dia pra trás na caminhada',
    );
    return '$_temp0';
  }

  @override
  String get companionDelayDustyHeadline => 'Sua falta na trilha';

  @override
  String get companionDelayDustyInsight => 'A poeira já cobriu o caminho';

  @override
  String get companionDelayFreshHeadline => 'Ficando para trás';

  @override
  String get companionDelayFreshInsight =>
      'Está ficando para trás na nossa caminhada';

  @override
  String get companionDelayLostHeadline => 'Ainda tem lugar ao meu lado';

  @override
  String get companionDelayLostInsight => 'Mas dá para retomar nossa caminhada';

  @override
  String get companionErrorAlreadyHave => 'Você já tem uma companhia.';

  @override
  String get companionErrorCreateInvite => 'Não foi possível criar o convite.';

  @override
  String get companionErrorInvalidCode =>
      'Código inválido ou companhia já está completa.';

  @override
  String get companionErrorSignInCreate =>
      'Entre com Google para criar uma companhia.';

  @override
  String get companionErrorSignInJoin =>
      'Entre com Google para entrar numa companhia.';

  @override
  String get companionErrorSignInWave => 'Entre na conta para acenar no app.';

  @override
  String get companionErrorWave => 'Não foi possível enviar o aceno.';

  @override
  String get companionFallbackName => 'Companheiro';

  @override
  String get companionNextStepTogether => 'Vamos dar o próximo passo juntos?';

  @override
  String companionPartnerAway(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Faz $days dias sem estudar — a trilha sente falta de $name',
      one: 'Faz 1 dia sem estudar — a trilha sente falta de $name',
    );
    return '$_temp0';
  }

  @override
  String companionPartnerAwayAfterStep(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dias',
      one: '1 dia',
    );
    return 'Você já deu o passo — $name está a $_temp0 atrás';
  }

  @override
  String companionPartnerNotYet(String name) {
    return 'Você já deu o passo — $name ainda não apareceu';
  }

  @override
  String get companionPresetComeBack => 'Tô te esperando pra limpar a trilha';

  @override
  String get companionPresetMissed => 'Senti sua falta na trilha';

  @override
  String get companionPresetOnTrail => 'Tô te esperando na trilha';

  @override
  String get companionPresetResume => 'Dá pra retomar — tô aqui';

  @override
  String get companionPresetStepCome => 'Dei meu passo hoje. Vem?';

  @override
  String get companionPresetWalkToday => 'Vamos caminhar juntos hoje';

  @override
  String get companionPresetYoursNext => 'Já dei meu passo — falta o seu';

  @override
  String companionShareDefault(String name) {
    return 'Oi $name 👋\nJá dei meus passos de hoje no Stway — tô te esperando!\nVem?';
  }

  @override
  String companionShareDusty(String name, int days) {
    return 'Oi $name 👋\nFaz $days dias que a gente não caminha juntos no Stway.\nO caminho continua aberto — tô te esperando!\nVem?';
  }

  @override
  String get companionShareFallbackName => 'você';

  @override
  String companionShareFresh(String name) {
    return 'Oi $name 👋\nSenti sua falta na nossa caminhada no Stway.\nJá dei meus passos de hoje e tô te esperando!\nVem?';
  }

  @override
  String companionShareLost(String name, int days) {
    return 'Oi $name 👋\nAinda tem lugar ao meu lado!\nFaz $days dias que a gente não caminha juntos no Stway.\n\nMas dá pra retomar — já dei meus passos de hoje.\nVem?';
  }

  @override
  String get companionSheetEyebrow => 'Companhia';

  @override
  String companionSheetFormedBody(int steps) {
    return 'Vocês caminham juntos agora.\nFechem os 7 dias da semana: +$steps passos na jornada para os dois.';
  }

  @override
  String companionSheetFormedBodyNamed(String name, int steps) {
    return 'Agora você e $name caminham juntos.\nFechem os 7 dias da semana: +$steps passos na jornada para os dois.';
  }

  @override
  String get companionSheetFormedCta => 'Caminhar juntos';

  @override
  String get companionSheetFormedTitle => 'Companhia formada';

  @override
  String get companionSheetInviteConfirmSubtitle =>
      'Alguém te chamou para caminhar junto.\nUm toque — sem digitar código.';

  @override
  String get companionSheetInviteConfirmTitle => 'Convite de companhia';

  @override
  String get companionSheetInviteCta => 'Chamar um companheiro';

  @override
  String companionSheetPromptBody(int steps) {
    return 'Um companheiro. Fechem os 7 dias da semana juntos — os dois ganham +$steps passos na jornada.';
  }

  @override
  String companionSheetPromptBodyTomorrow(String scene) {
    return 'Amanhã: $scene. Chame alguém para chegar junto.';
  }

  @override
  String get companionSheetPromptTitle => 'Chame alguém para caminhar';

  @override
  String get companionWalkedTogetherToday => 'Vocês caminharam juntos hoje';

  @override
  String companionWaveFor(String name) {
    return 'Você já deu o passo — acene para $name';
  }

  @override
  String get companionWeekClosed => 'Semana fechada juntos';

  @override
  String companionWeekDays(int count) {
    return '$count de 7 dias juntos nesta semana';
  }

  @override
  String companionYourTurn(String name) {
    return '$name já caminhou — sua vez';
  }

  @override
  String cornerAcceptedBy(String name) {
    return '$name aceitou o desafio';
  }

  @override
  String get cornerActionFailed => 'Não foi possível concluir. Tente de novo.';

  @override
  String get cornerArrivedMark => 'Chegou';

  @override
  String cornerBoardEmptyBody(int count) {
    return 'Na caravana, abra alguém na mesma cena e chame para o desafio. Quem chega até domingo ganha +$count passos.';
  }

  @override
  String get cornerBoardEmptyTitle => 'Nenhum desafio ainda';

  @override
  String get cornerBoardFilterEmpty => 'Nenhum ainda';

  @override
  String get cornerBoardIdle =>
      'Nenhum desafio nesta semana. Chame alguém da caravana.';

  @override
  String get cornerBoardOpenCaravan => 'Ver a caravana';

  @override
  String get cornerBurstAccepted => 'Desafio aceito';

  @override
  String get cornerBurstLeft => 'Você saiu do desafio';

  @override
  String get cornerBurstSent => 'Convite enviado';

  @override
  String get cornerBusyAccept =>
      'Você já tem um desafio. Chegue ou saia dele para aceitar.';

  @override
  String get cornerBusyWeek => 'Você já tem um desafio nesta semana.';

  @override
  String get cornerCancelled => 'Desafio cancelado';

  @override
  String cornerChallengeWith(String name) {
    return 'Desafio com $name';
  }

  @override
  String get cornerClosedChapter => 'Encerrados';

  @override
  String get cornerClosesToday => 'Fecha hoje';

  @override
  String get cornerCtaInvite => 'Chamar para o desafio';

  @override
  String cornerDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count dias',
      one: 'Falta 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get cornerDeadline => 'Até domingo.';

  @override
  String get cornerDeclinedAnon => 'O convite não foi aceito.';

  @override
  String cornerDeclinedBy(String name) {
    return '$name não aceitou desta vez.';
  }

  @override
  String get cornerDifferentScene => 'Vocês não estão na mesma cena.';

  @override
  String get cornerDifferentTrail => 'Vocês não estão na mesma trilha.';

  @override
  String get cornerHoldAccept => 'Segure para aceitar';

  @override
  String get cornerHoldInvite => 'Segure para chamar';

  @override
  String cornerIncomingFrom(String name) {
    return '$name te chamou para esta cena.';
  }

  @override
  String get cornerIncomingFromAnon => 'Alguém te chamou para esta cena.';

  @override
  String get cornerIncomingTitle => 'Convite de desafio';

  @override
  String cornerInviteBody(String name, int count) {
    return 'Você e $name fazem essa cena até domingo.\n+$count passos para cada um que chegar.';
  }

  @override
  String cornerInviteBodyAnon(int count) {
    return 'A mesma cena até domingo.\n+$count passos para cada um que chegar.';
  }

  @override
  String cornerInviteTitle(String mission) {
    return 'Desafio: $mission';
  }

  @override
  String get cornerKicker => 'Desafio';

  @override
  String get cornerLeftMark => 'Saiu';

  @override
  String get cornerNeedsCloud => 'Entre com Google para chamar alguém.';

  @override
  String get cornerNoCorner => 'Nenhuma cena em comum para o desafio.';

  @override
  String get cornerNoneHeadline => 'Ninguém chegou desta vez';

  @override
  String get cornerNoneLine => 'O desafio fechou no domingo.';

  @override
  String get cornerOnTheWay => 'A caminho';

  @override
  String get cornerOtherPerson => 'A outra pessoa';

  @override
  String get cornerOtherPersonLower => 'a outra pessoa';

  @override
  String cornerRecordArrived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completas',
      one: '1 completa',
    );
    return '$_temp0';
  }

  @override
  String get cornerRecordChapter => 'Desafios';

  @override
  String cornerRecordTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count juntos',
      one: '1 junto',
    );
    return '$_temp0';
  }

  @override
  String cornerResultLeft(int count) {
    return 'Você saiu · sem os +$count passos';
  }

  @override
  String cornerResultNone(String name) {
    return 'Com $name · ninguém chegou';
  }

  @override
  String cornerResultTheyArrived(String name) {
    return '$name chegou · você não chegou';
  }

  @override
  String cornerResultTheyLeftMissed(String name) {
    return '$name saiu · você não chegou';
  }

  @override
  String cornerResultTogether(String name) {
    return 'Com $name · os dois chegaram';
  }

  @override
  String cornerResultWon(String name, int count) {
    return 'Com $name · +$count passos';
  }

  @override
  String cornerSameStretch(int count) {
    return 'A mesma cena até domingo. +$count passos para cada um que chegar.';
  }

  @override
  String get cornerSendFailed =>
      'Não foi possível enviar o convite. Tente de novo.';

  @override
  String get cornerSomeone => 'Alguém';

  @override
  String get cornerStripIdle => 'Nenhum nesta semana';

  @override
  String cornerStripInvitedYou(String name) {
    return '$name te chamou';
  }

  @override
  String cornerStripLost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perdeu',
    );
    return '$_temp0';
  }

  @override
  String cornerStripWaiting(String name) {
    return 'Esperando $name';
  }

  @override
  String cornerStripWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ganhou',
    );
    return '$_temp0';
  }

  @override
  String get cornerTallyLost => 'Perdeu';

  @override
  String get cornerTallyTogether => 'Juntos';

  @override
  String get cornerTallyWon => 'Ganhou';

  @override
  String cornerTheyAhead(String name) {
    return '$name já chegou. Falta você.';
  }

  @override
  String cornerTheyArrived(String name) {
    return '$name chegou';
  }

  @override
  String cornerTheyLeft(String name) {
    return '$name saiu. Você ainda pode chegar.';
  }

  @override
  String cornerTheyLeftClosed(String name) {
    return '$name saiu do desafio.';
  }

  @override
  String get cornerTogether => 'Chegaram juntos';

  @override
  String get cornerTogetherLine => 'Os dois fizeram a cena a tempo.';

  @override
  String cornerWaitingArrival(String name) {
    return 'Você chegou · esperando $name.';
  }

  @override
  String cornerWaitingOn(String name) {
    return 'Esperando $name aceitar.';
  }

  @override
  String get cornerWaitingOnAnon => 'Esperando o aceite.';

  @override
  String get cornerWalk => 'Fazer a cena';

  @override
  String get cornerWhisperEach => 'Cada cena feita conta.';

  @override
  String get cornerWhisperTogether => 'Cenas feitas lado a lado.';

  @override
  String cornerWithPeer(String name) {
    return 'Com $name · até domingo';
  }

  @override
  String get cornerWithdraw => 'Sair do desafio';

  @override
  String cornerWithdrawBody(String name, int count) {
    return '$name continua e ainda pode chegar. Você fica sem os +$count passos.';
  }

  @override
  String get cornerWithdrawConfirm => 'Sair';

  @override
  String cornerWithdrawPending(String name) {
    return 'O convite some para $name.';
  }

  @override
  String get cornerWithdrawTitle => 'Sair do desafio?';

  @override
  String get cornerYouArrived => 'Você chegou';

  @override
  String get cornerYouLeft => 'Você saiu do desafio.';

  @override
  String get crossingChip => 'Travessia';

  @override
  String dustAwayManyFreeze(String name, int daysAway) {
    String _temp0 = intl.Intl.pluralLogic(
      daysAway,
      locale: localeName,
      other: '$daysAway dias sem caminhar',
      one: '1 dia sem caminhar',
    );
    return '$name, $_temp0. O gelo ainda cobre 1 falta — retome a caminhada.';
  }

  @override
  String dustAwayManyNoFreeze(String name, int daysAway) {
    String _temp0 = intl.Intl.pluralLogic(
      daysAway,
      locale: localeName,
      other: '$daysAway dias sem caminhar',
      one: '1 dia sem caminhar',
    );
    return '$name, $_temp0. Uma cena recomeça o caminho.';
  }

  @override
  String dustAwayNoStreak(String name) {
    return '$name, a trilha espera. Uma cena basta para retomar o caminho.';
  }

  @override
  String dustAwayStreak(String name, int streak) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '$streak dias de sequência esperam',
      one: '1 dia de sequência espera',
    );
    return '$name, $_temp0. Uma cena e você retoma.';
  }

  @override
  String dustAwayTwoFreeze(String name) {
    return '$name, dois dias sem caminhar. O gelo ainda pode salvar 1 dia — volte hoje.';
  }

  @override
  String dustAwayTwoNoFreeze(String name) {
    return '$name, dois dias sem caminhar. Uma cena e você volta ao caminho.';
  }

  @override
  String get dustCanReturn => 'Dá para voltar';

  @override
  String get dustComeBackToday => 'Volte hoje';

  @override
  String get dustContinueWhere => 'Continue de onde parou';

  @override
  String get dustDayEnding => 'O dia está acabando';

  @override
  String dustEveningFreeze1(String name, String countdown) {
    return '$name, o dia fecha. Faltam $countdown — caminhe, ou o gelo cobre 1 dia.';
  }

  @override
  String dustEveningFreeze2(String countdown) {
    return 'Últimas $countdown. Continue a caminhada — o gelo ainda cobre 1 dia.';
  }

  @override
  String dustEveningNoFreeze2(String countdown) {
    return 'Noite fechando. Faltam $countdown — continue a caminhada agora.';
  }

  @override
  String get dustFewHours => 'Poucas horas';

  @override
  String get dustHeroGapFreeze =>
      'Ontem ficou vazio. Faça a cena hoje — o gelo ainda salva 1 dia.';

  @override
  String get dustHeroGapNoFreeze =>
      'Ontem ficou vazio. Faça a cena hoje para não perder a sequência.';

  @override
  String dustHeroRiskFreeze(int streak, String countdown) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other:
          'Faltam $countdown para a sequência de $streak dias cair. Faça a cena hoje — o gelo ainda salva 1 dia.',
      one:
          'Faltam $countdown para a sequência cair. Faça a cena hoje — o gelo ainda salva 1 dia.',
      zero:
          'Faltam $countdown para a sequência cair. Faça a cena hoje — o gelo ainda salva 1 dia.',
    );
    return '$_temp0';
  }

  @override
  String dustHeroRiskNoFreeze(int streak, String countdown) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other:
          'Faltam $countdown para a sequência de $streak dias cair. Faça a cena hoje.',
      one: 'Faltam $countdown para a sequência cair. Faça a cena hoje.',
      zero: 'Faltam $countdown para a sequência cair. Faça a cena hoje.',
    );
    return '$_temp0';
  }

  @override
  String get dustNextSceneWaits => 'A próxima cena espera';

  @override
  String get dustOneDay => 'Um dia';

  @override
  String dustRiskBodyFreeze1(String name, String countdown) {
    return '$name · faltam $countdown. Uma cena protege a sequência — o gelo cobre 1 dia.';
  }

  @override
  String dustRiskBodyFreeze3(String countdown) {
    return 'Faltam $countdown. Continue a caminhada — o gelo cobre 1 dia.';
  }

  @override
  String dustRiskBodyNoFreeze1(String name, String countdown) {
    return '$name · sem gelo. Faltam $countdown. Uma cena e você fica.';
  }

  @override
  String dustRiskBodyNoFreeze2(int streak, String countdown) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '$streak dias em risco. Faltam $countdown — caminhe agora.',
      one: '1 dia em risco. Faltam $countdown — caminhe agora.',
    );
    return '$_temp0';
  }

  @override
  String dustRiskBodyNoFreeze3(String countdown) {
    return 'Sem gelo. Faltam $countdown — caminhe agora.';
  }

  @override
  String dustRiskBodyStreak(int streak, String countdown) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: 'Sequência de $streak dias ainda em jogo. Faltam $countdown.',
      one: 'Sequência de 1 dia ainda em jogo. Faltam $countdown.',
    );
    return '$_temp0';
  }

  @override
  String get dustSceneToday => 'Uma cena hoje';

  @override
  String get dustSceneTodayWaits => 'A cena de hoje espera';

  @override
  String get dustSceneWaits => 'A cena espera';

  @override
  String get dustStillTime => 'Ainda dá tempo';

  @override
  String get dustStreakWaits => 'A sequência espera';

  @override
  String get dustTrailWaits => 'A trilha espera';

  @override
  String get dustTwoDays => 'Dois dias';

  @override
  String get dustUiDetail2 => 'Continue a caminhada · uma cena basta';

  @override
  String get dustUiDetail3 => 'A sequência espera · caminhe hoje';

  @override
  String get dustUiFreeze1 => 'Sequência em risco · gelo ainda cobre 1 dia';

  @override
  String get dustUiFreeze2 => 'Ainda dá tempo · gelo a postos';

  @override
  String get dustUiFreeze3 => 'Caminhe hoje · gelo cobre 1 falta';

  @override
  String get dustUiNoFreeze1 => 'Sequência em risco · caminhe agora';

  @override
  String get dustUiNoFreeze2 => 'Sem gelo · uma cena protege';

  @override
  String get dustUiNoFreeze3 => 'A sequência espera · uma cena alcança';

  @override
  String get entryMissionDorAnsia01CentralInsight => 'O tesouro puxa o coração';

  @override
  String get entryMissionDorAnsia01HookNote =>
      'O cuidado do Pai é o argumento contra a ansiedade — não a ausência de necessidade.';

  @override
  String get entryMissionDorAnsia01Intro =>
      'Onde está o tesouro, está o coração. Jesus une Mamom e o amanhã.';

  @override
  String get entryMissionDorAnsia01Objective =>
      'Ver como Jesus liga tesouro, senhorio e ansiedade.';

  @override
  String get entryMissionDorAnsia01Title => 'Tesouros e ansiedade';

  @override
  String get entryMissionDorAnsia02CentralInsight =>
      'Cristo basta na fome e na fartura';

  @override
  String get entryMissionDorAnsia02HookNote =>
      'O contentamento de Paulo não é estoicismo: é Cristo na fome e na fartura.';

  @override
  String get entryMissionDorAnsia02Intro =>
      'Paulo aprendeu a estar contente em toda a sorte — em Cristo.';

  @override
  String get entryMissionDorAnsia02Objective =>
      'Trocar a ansiedade do ter pelo contentamento em Cristo.';

  @override
  String get entryMissionDorAnsia02Title => 'Contentamento';

  @override
  String get entryMissionDorAnsia03CentralInsight => 'Há pastor no vale';

  @override
  String get entryMissionDorAnsia03HookNote =>
      'O pastor guia — inclusive no vale. O que some não é a luta; é o medo e a sensação de solidão.';

  @override
  String get entryMissionDorAnsia03Intro =>
      'Nada me faltará — o Salmo 23 é confiança, não magia.';

  @override
  String get entryMissionDorAnsia03Objective =>
      'Ler o Salmo 23 como cuidado, não como amuleto.';

  @override
  String get entryMissionDorAnsia03Title => 'O Senhor é o meu pastor';

  @override
  String get entryMissionDorAnsia04CentralInsight => 'O pão é de hoje';

  @override
  String get entryMissionDorAnsia04HookNote =>
      'Jesus ensina a pedir o dia — não o estoque. O Reino vem antes do pão.';

  @override
  String get entryMissionDorAnsia04Intro =>
      'Pedir o pão de cada dia é o contrário de antecipar o mês inteiro.';

  @override
  String get entryMissionDorAnsia04Objective =>
      'Orar o dia, não o censo do medo.';

  @override
  String get entryMissionDorAnsia04Title => 'Pai nosso';

  @override
  String get entryMissionDorAnsia05CentralInsight => 'A herança está guardada';

  @override
  String get entryMissionDorAnsia05HookNote =>
      'A esperança não nega o sofrimento. Ela o ancora na ressurreição. Continue no Sermão do Monte.';

  @override
  String get entryMissionDorAnsia05Intro =>
      'Pedro ancora sofredores numa herança guardada — depois, o cânon.';

  @override
  String get entryMissionDorAnsia05Objective =>
      'Sair da trilha de dor para o currículo: Sermão do Monte.';

  @override
  String get entryMissionDorAnsia05Title => 'Esperança viva';

  @override
  String get entryMissionDorRecome01CentralInsight =>
      'Deus ainda pergunta onde estás';

  @override
  String get entryMissionDorRecome01HookNote =>
      'O primeiro movimento depois da queda é Deus procurando — não o humano se escondendo com sucesso.';

  @override
  String get entryMissionDorRecome01Intro =>
      'A desconfiança rompe a comunhão — e ainda assim Deus pergunta.';

  @override
  String get entryMissionDorRecome01Objective =>
      'Ver a queda como ruptura, não como o fim da conversa.';

  @override
  String get entryMissionDorRecome01Title => 'A queda';

  @override
  String get entryMissionDorRecome02CentralInsight =>
      'Há semente depois da porta';

  @override
  String get entryMissionDorRecome02EchoQuestion =>
      'Ele perguntou. E depois da resposta, a história acabou?';

  @override
  String get entryMissionDorRecome02HookNote =>
      'No mesmo capítulo da expulsão, Deus fala de uma semente. O juízo não cancela a história.';

  @override
  String get entryMissionDorRecome02Intro =>
      'O pecado tem custo. A promessa não some.';

  @override
  String get entryMissionDorRecome02Objective =>
      'Ler consequência e promessa no mesmo texto.';

  @override
  String get entryMissionDorRecome02Title => 'Consequências';

  @override
  String get entryMissionDorRecome03CentralInsight =>
      'Recomeçar é aliança, não apagar';

  @override
  String get entryMissionDorRecome03EchoQuestion =>
      'Há semente depois da porta. O mundo recomeça apagando o passado?';

  @override
  String get entryMissionDorRecome03HookNote =>
      'O mundo recomeça sob aliança, não sob amnésia. O arco lembra a Deus — e a nós.';

  @override
  String get entryMissionDorRecome03Intro =>
      'Juízo e recomeço cabem no mesmo Deus.';

  @override
  String get entryMissionDorRecome03Objective =>
      'Ver o dilúvio como juízo que guarda um resto.';

  @override
  String get entryMissionDorRecome03Title => 'Dilúvio';

  @override
  String get entryMissionDorRecome04CentralInsight =>
      'O recomeço caminha para fora';

  @override
  String get entryMissionDorRecome04EchoQuestion =>
      'Recomeçar é aliança. Babel se conserta com outra torre?';

  @override
  String get entryMissionDorRecome04HookNote =>
      'Deus não conserta Babel com outra torre. Chama uma família para ser bênção.';

  @override
  String get entryMissionDorRecome04Intro =>
      'Sair da terra é o gesto do recomeço que abençoa outros.';

  @override
  String get entryMissionDorRecome04Objective =>
      'Ligar recomeço a chamado, não a isolamento.';

  @override
  String get entryMissionDorRecome04Title => 'Chamado de Abrão';

  @override
  String get entryMissionDorRecome05CentralInsight =>
      'Há conforto para quem chora de verdade';

  @override
  String get entryMissionDorRecome05EchoQuestion =>
      'O recomeço caminha para fora. Quem chora o que morreu encontra o quê no Reino?';

  @override
  String get entryMissionDorRecome05HookNote =>
      'O Reino não apressa o luto. Consola. A trilha canônica começa em Gênesis 1–11.';

  @override
  String get entryMissionDorRecome05Intro =>
      'Quem chora o que morreu é bem-aventurado. Continue em Gênesis 1–11.';

  @override
  String get entryMissionDorRecome05Objective =>
      'Sair da trilha de dor para o currículo: Gênesis 1–11.';

  @override
  String get entryMissionDorRecome05Title => 'Os que choram';

  @override
  String get entryTrailAnsiedadeDescription =>
      'Cinco cenas para lançar o amanhã no Pai — e seguir no cânon.';

  @override
  String get entryTrailAnsiedadeModuleTitle => 'Lançar a ansiedade';

  @override
  String get entryTrailAnsiedadeTitle => 'Ansiedade';

  @override
  String get entryTrailRecomecoDescription =>
      'Cinco cenas da queda ao chamado — e de volta a Gênesis 1–11.';

  @override
  String get entryTrailRecomecoModuleTitle => 'Do rompimento ao chamado';

  @override
  String get entryTrailRecomecoTitle => 'Recomeço';

  @override
  String get eraChurchBlurb => 'Atos, epístolas e a consumação';

  @override
  String get eraChurchTitle => 'Igreja e cartas';

  @override
  String get eraConquestBlurb => 'Terra prometida e ciclo dos juízes';

  @override
  String get eraConquestTitle => 'Conquista e juízes';

  @override
  String get eraDividedBlurb => 'Israel, Judá e a voz dos profetas';

  @override
  String get eraDividedTitle => 'Reinos e profetas';

  @override
  String get eraExileBlurb => 'Babilônia e a esperança do retorno';

  @override
  String get eraExileTitle => 'Exílio';

  @override
  String get eraExodusBlurb => 'Saída do Egito, Sinai e o deserto';

  @override
  String get eraExodusTitle => 'Êxodo e Lei';

  @override
  String get eraGospelsBlurb => 'Os quatro Evangelhos';

  @override
  String get eraGospelsTitle => 'Vida de Jesus';

  @override
  String get eraOriginsBlurb => 'Criação, Dilúvio e a família de Abraão';

  @override
  String get eraOriginsTitle => 'Origens e patriarcas';

  @override
  String get eraReturnBlurb => 'Templo, muros e o último dos profetas';

  @override
  String get eraReturnTitle => 'Retorno e restauração';

  @override
  String get eraUnitedBlurb => 'Saul, Davi e Salomão';

  @override
  String get eraUnitedTitle => 'Monarquia unida';

  @override
  String get exerciseCheck => 'Verificar';

  @override
  String get exerciseCueMatch => 'Ligue cada par.';

  @override
  String get exerciseCueOrder => 'Monte a sequência.';

  @override
  String get exerciseCueTap => 'Toque o trecho que responde.';

  @override
  String get exerciseFalse => 'Falso';

  @override
  String get exerciseFalseMark => 'F';

  @override
  String get exerciseHint => 'Dica';

  @override
  String get exerciseHintUsed => 'Dica usada';

  @override
  String get exerciseLabelBridge => 'Ponte';

  @override
  String get exerciseLabelClaim => 'Afirmação';

  @override
  String get exerciseLabelPairs => 'Pares';

  @override
  String get exerciseLabelQuestion => 'Pergunta';

  @override
  String get exerciseLabelSequence => 'Sequência';

  @override
  String get exerciseLabelWord => 'Palavra';

  @override
  String get exerciseMatchPair => 'Pareie';

  @override
  String get exerciseMatchPick => 'Escolha';

  @override
  String get exerciseNoteLabel => 'Contexto';

  @override
  String get exerciseTitleChoose => 'Escolha a resposta';

  @override
  String get exerciseTitleComplete => 'Complete o versículo';

  @override
  String get exerciseTitleConnect => 'Conecte os trechos';

  @override
  String get exerciseTitleOrder => 'Ordene os fatos';

  @override
  String get exerciseTitleTap => 'Toque a palavra';

  @override
  String get exerciseTitleTrueFalse => 'Julgue o versículo';

  @override
  String get exerciseTrue => 'Verdadeiro';

  @override
  String get exerciseTrueMark => 'V';

  @override
  String get exerciseTypeBestInterpretation => 'Interpretação';

  @override
  String get exerciseTypeChoice => 'Escolha';

  @override
  String get exerciseTypeClassify => 'Classifique';

  @override
  String get exerciseTypeComplete => 'Complete';

  @override
  String get exerciseTypeConnect => 'Conecte';

  @override
  String get exerciseTypeExplain => 'Explique';

  @override
  String get exerciseTypeFindInText => 'No texto';

  @override
  String get exerciseTypeInsight => 'Insight';

  @override
  String get exerciseTypeMatch => 'Emparelhe';

  @override
  String get exerciseTypeOrder => 'Ordene';

  @override
  String get exerciseTypeReview => 'Revisão';

  @override
  String get exerciseTypeTap => 'Toque';

  @override
  String get exerciseTypeTextSupported => 'O texto diz';

  @override
  String get exerciseTypeTrueFalse => 'Verdadeiro / Falso';

  @override
  String get exerciseVerbAnswer => 'Responda';

  @override
  String get exerciseVerbJudge => 'Julgue';

  @override
  String get feedbackAlmost => 'Quase';

  @override
  String get feedbackAnswer => 'Resposta';

  @override
  String get feedbackCheer1 => 'Isso.';

  @override
  String get feedbackCheer2 => 'Acertou.';

  @override
  String get feedbackCheer3 => 'Muito bem.';

  @override
  String get feedbackCheer4 => 'Certo.';

  @override
  String get feedbackCorrect => 'Acertou';

  @override
  String feedbackCorrection(String expected, String got) {
    return '$expected, não $got';
  }

  @override
  String get feedbackEndPartial => 'Encerrar com passos parciais';

  @override
  String get feedbackFollow => 'Seguir.';

  @override
  String get feedbackNotYet => 'Ainda não';

  @override
  String get feedbackOutOfLamps => 'Sem lâmpadas';

  @override
  String get feedbackReadPassage => 'Ler o texto da cena';

  @override
  String get feedbackReportSent => 'Relato enviado. Obrigado.';

  @override
  String get feedbackReportTooltip => 'Relatar problema nesta pergunta';

  @override
  String get feedbackRequeueHint =>
      'Tente de novo ou deixe para o fim da cena.';

  @override
  String get feedbackRereadHint => 'Releia o texto e tente de novo.';

  @override
  String get feedbackSeeRightWord => 'Veja a palavra certa';

  @override
  String get feedbackSeeText => 'Veja no texto';

  @override
  String get feedbackSkipToEnd => 'Pular e tentar no fim';

  @override
  String get feedbackTryAgain => 'Tente de novo.';

  @override
  String get groupCallEmpty => 'Ninguém da caravana para chamar agora.';

  @override
  String groupCallFull(int count) {
    return 'Este grupo já tem $count pessoas.';
  }

  @override
  String get groupCallSubtitle =>
      'O convite aparece no app. Ou mande o link no WhatsApp.';

  @override
  String get groupCallTitle => 'Chamar pessoas';

  @override
  String get groupCaptionNotYet => 'ainda não';

  @override
  String get groupCaptionToday => 'hoje';

  @override
  String get groupCreateCta => 'Criar grupo';

  @override
  String groupDayUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dias ',
      one: 'dia ',
    );
    return '$_temp0';
  }

  @override
  String groupDaysAway(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias sem estudar',
      one: '1 dia sem estudar',
    );
    return '$_temp0';
  }

  @override
  String get groupEmptyLeaderBody =>
      'Todos recebem a mesma cena — mesmo quem ainda não chegou nela na trilha.';

  @override
  String get groupEmptyLeaderTitle =>
      'Qual texto o grupo vai estudar nesta semana?';

  @override
  String groupEmptyMemberBody(String leader) {
    return '$leader escolhe a cena que o grupo estuda junto.';
  }

  @override
  String get groupEmptyMemberTitle => 'O texto da semana ainda não chegou.';

  @override
  String get groupInviteAccept => 'Aceitar';

  @override
  String groupInviteBody(String name, String kind) {
    return '$name te chamou para o grupo · $kind.';
  }

  @override
  String get groupInviteCta => 'Chamar';

  @override
  String get groupInviteLabel => 'Convite';

  @override
  String get groupInviteSendFailed =>
      'Não foi possível enviar o convite. Tente de novo.';

  @override
  String get groupInviteSending => 'Enviando…';

  @override
  String get groupInviteSent => 'Convite enviado';

  @override
  String get groupInviteUndo => 'Desfazer';

  @override
  String get groupInviteUndoFailed =>
      'Não foi possível desfazer o convite. Tente de novo.';

  @override
  String groupLeaderNoteTitle(String title, String name) {
    return '$title $name';
  }

  @override
  String get groupMenuClearStudy => 'Tirar estudo da semana';

  @override
  String get groupMenuClose => 'Encerrar o grupo';

  @override
  String groupMenuCopyCode(String code) {
    return 'Copiar código $code';
  }

  @override
  String get groupMenuEdit => 'Editar nome e tipo';

  @override
  String groupMenuGoal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Meta da semana · $count passos',
      one: 'Meta da semana · 1 passo',
    );
    return '$_temp0';
  }

  @override
  String get groupMenuLeadSection => 'Conduzir o grupo';

  @override
  String get groupMenuLeave => 'Sair do grupo';

  @override
  String get groupMenuSetGoal => 'Definir meta da semana';

  @override
  String get groupMenuTransfer => 'Passar a liderança';

  @override
  String get groupNewTitle => 'Novo grupo';

  @override
  String get groupPickStudyCta => 'Escolher o estudo';

  @override
  String get groupPickerConfirmCta => 'Marcar para o grupo';

  @override
  String get groupPickerIntro =>
      'Todos do grupo recebem a mesma cena, mesmo quem ainda não chegou nela.';

  @override
  String get groupPickerMarkScene => 'Marcar a cena';

  @override
  String get groupPickerNoteHint =>
      'Opcional. Ex.: Leiam até quarta, conversamos na quinta.';

  @override
  String get groupPickerNoteLabel => 'Recado para o grupo';

  @override
  String get groupPickerPreviewLabel => 'O grupo vai ver';

  @override
  String groupRosterSemantics(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, $count dias nesta semana',
      one: '$name, 1 dia nesta semana',
    );
    return '$_temp0';
  }

  @override
  String groupSeatAlreadyWaved(String name) {
    return 'Você já acenou para $name hoje.';
  }

  @override
  String get groupSeatDaysInWeek => 'Dias na semana';

  @override
  String get groupSeatIdle => 'ainda não estudou nesta semana';

  @override
  String get groupSeatNever => 'ainda não estudou';

  @override
  String get groupSeatSteps => 'Passos';

  @override
  String get groupSeatStudyDone => 'Feito';

  @override
  String get groupSeatStudyNotYet => 'Ainda não';

  @override
  String get groupSeatToday => 'estudou hoje';

  @override
  String get groupSeatWeek => 'estudou nesta semana';

  @override
  String get groupSetupKindLabel => 'Para que é o grupo';

  @override
  String groupSetupLimitHint(int limit) {
    return 'Até $limit pessoas. Grupo grande? Abra outro — discipulado acontece em grupo pequeno.';
  }

  @override
  String get groupSetupNameLabel => 'Nome';

  @override
  String get groupStudyAgain => 'Você já fez · Estudar de novo';

  @override
  String get groupStudyCta => 'Estudar com o grupo';

  @override
  String groupStudyDoneCount(int done, int total) {
    return '$done de $total já fizeram';
  }

  @override
  String get groupStudyNobodyYet => 'Ninguém fez ainda. Seja o primeiro.';

  @override
  String get groupStudySwap => 'Trocar';

  @override
  String get groupWeekStudy => 'Estudo da semana';

  @override
  String growthDayUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dias ',
      one: 'dia ',
    );
    return '$_temp0';
  }

  @override
  String growthDaysToStage(int count, String stage) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count dias de sequência para $stage',
      one: 'Falta 1 dia de sequência para $stage',
    );
    return '$_temp0';
  }

  @override
  String growthFreezeUsed(String subtitle) {
    return '$subtitle · gelo já usado nesta semana';
  }

  @override
  String growthFruitSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias de sequência · deu fruto',
      one: '1 dia de sequência · deu fruto',
    );
    return '$_temp0';
  }

  @override
  String get growthHintDayZero => 'dia 0';

  @override
  String growthNextIn(String stage, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Próximo: $stage · faltam $count dias na sequência',
      one: 'Próximo: $stage · faltam 1 dia na sequência',
    );
    return '$_temp0';
  }

  @override
  String growthNextMilestone(String stage) {
    return 'Próximo marco: $stage';
  }

  @override
  String get growthPerfect => 'Cena perfeita';

  @override
  String growthPerfectWith(String subtitle) {
    return 'Cena perfeita · $subtitle';
  }

  @override
  String get growthSeedSubtitle => 'Faça 1 cena hoje para virar Broto';

  @override
  String get growthStageBranch => 'Ramo';

  @override
  String get growthStageFruit => 'Fruto';

  @override
  String get growthStageSeed => 'Semente';

  @override
  String get growthStageSprout => 'Broto';

  @override
  String get growthStageTree => 'Árvore';

  @override
  String get growthWhisper =>
      'Cada dia da sequência sobe um marco: Semente, Broto, Ramo, Árvore e Fruto.';

  @override
  String get homeBibleOfflineSubtitle => 'Leia sem internet';

  @override
  String get homeCatalogDownloading => 'Baixando…';

  @override
  String get homeCatalogEmptyBody =>
      'As cenas baixam na primeira abertura. Se a conexão falhar, toque para tentar de novo.';

  @override
  String get homeCatalogEmptyTitle => 'As cenas ainda não chegaram';

  @override
  String get homeDefaultName => 'Peregrino';

  @override
  String get homeFreezeSheetBody =>
      'Você perdeu um dia, mas a sequência continua. O gelo salva uma falta por semana — caminhe hoje para seguir.';

  @override
  String get homeFreezeSheetTitle => 'O gelo cobriu ontem';

  @override
  String homeGoalLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count cenas para a meta',
      one: 'Falta 1 cena para a meta',
    );
    return '$_temp0';
  }

  @override
  String get homeGoalMet => 'Meta do dia cumprida';

  @override
  String get homeHeroEcho => 'Eco de ontem';

  @override
  String homeHeroExtraSteps(int count) {
    return '+$count passos · extra de hoje';
  }

  @override
  String get homeHeroFrozenLine => 'O gelo cobriu ontem · sequência preservada';

  @override
  String get homeHeroMinutes => '~3 min';

  @override
  String get homeHeroProtect => 'Protege a sequência · ~3 min';

  @override
  String get homeHeroReady => 'Cena pronta';

  @override
  String get homeHeroTomorrow => 'Amanhã';

  @override
  String homeJuntosNews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novidades',
      one: '1 novidade',
    );
    return '$_temp0';
  }

  @override
  String get homeLampsHint => 'Erro apaga uma · zerar encerra';

  @override
  String homeLampsSemantics(int current, int max) {
    return '$current de $max lâmpadas. Cada erro apaga uma.';
  }

  @override
  String get homeLampsTitle => 'Lâmpadas';

  @override
  String get homeMoodAlive => 'Em dia';

  @override
  String get homeMoodDusty => 'Sequência em risco';

  @override
  String get homeMoodFrozen => 'Protegido pelo gelo';

  @override
  String get homeMoreToday => 'Mais para hoje';

  @override
  String homeOpenProfile(String name) {
    return 'Abrir perfil de $name';
  }

  @override
  String get homeQuestsExtraCaption => 'Passos extras';

  @override
  String homeReviewCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count para reforçar',
      one: '1 para reforçar',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewTitle => 'Revisão';

  @override
  String homeSeasonChipDoneSemantics(String season, int day, String dayTitle) {
    return '$season. Dia $day feito: $dayTitle';
  }

  @override
  String homeSeasonChipOpenSemantics(String season, int day, String dayTitle) {
    return '$season. Dia $day: $dayTitle';
  }

  @override
  String homeSeasonChipSemantics(String season) {
    return '$season · abrir leitura da estação';
  }

  @override
  String homeSeasonDayDone(int day, String title) {
    return 'Dia $day feito · $title';
  }

  @override
  String homeSeasonDayLine(int day, String title) {
    return 'Dia $day · $title';
  }

  @override
  String homeSeasonDayOf(int day, int total, String title) {
    return 'Dia $day de $total · $title';
  }

  @override
  String homeSeasonDayOfDone(int day, int total, String title) {
    return 'Dia $day de $total feito · $title';
  }

  @override
  String get homeSeeTrails => 'Ver trilhas';

  @override
  String get homeStatAtRisk => 'em risco';

  @override
  String get homeStatFreeze => 'gelo';

  @override
  String get homeStatFreezeUsed => 'gelo usado';

  @override
  String get homeStatGoal => 'meta';

  @override
  String homeStepsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passos na jornada',
      one: '1 passo na jornada',
    );
    return '$_temp0';
  }

  @override
  String get homeTrailDoneBody => 'Escolha a próxima e continue aprendendo.';

  @override
  String get homeTrailDoneTitle => 'Trilha concluída';

  @override
  String get homeWordInScene => 'Nesta cena';

  @override
  String homeWordRead(String reference) {
    return 'Ler $reference';
  }

  @override
  String get homeWordWord => 'Palavra';

  @override
  String get inviteAcceptCta => 'Aceitar convite';

  @override
  String inviteCalledYou(String name) {
    return '$name te chamou';
  }

  @override
  String inviteCardBody(String name) {
    return '$name te chamou para caminhar junto — sem disputa, só presença.';
  }

  @override
  String get inviteCardHeadline => 'Caminhem juntos';

  @override
  String get inviteCardInstallHint =>
      'Já tem o app? Toque no link do convite.\nAinda não? Baixe o Stway e toque de novo.';

  @override
  String get inviteCodeCopied => 'Código copiado';

  @override
  String get inviteCodeHint => 'Código';

  @override
  String inviteCompanionShareText(String name, String link, String installUrl) {
    return '$name te chamou pra caminhar junto no Stway.\nSem disputa — só presença.\n\nToque para aceitar (já tem o app):\n$link\n\nAinda não tem o Stway? Baixe e toque no link de novo:\n$installUrl';
  }

  @override
  String get inviteCreateFailed =>
      'Não foi possível criar o convite. Tente de novo.';

  @override
  String get inviteHaveCodeSubtitle =>
      'Se você copiou o código no WhatsApp, ele já aparece aqui';

  @override
  String get inviteHaveCodeTitle => 'Tenho um código';

  @override
  String get inviteJoinCta => 'Entrar';

  @override
  String get inviteLinkHint =>
      'O link abre o app e aceita sem digitar o código';

  @override
  String get invitePreparing => 'Preparando…';

  @override
  String get inviteReadyTitle => 'Seu convite está pronto';

  @override
  String inviteRoomShareText(String code, String installUrl) {
    return 'Entre no Stway com o código $code.\n\nAinda não tem o app? Baixe: $installUrl';
  }

  @override
  String get inviteScanHint => 'Aponte para o QR do convite';

  @override
  String get inviteScanQr => 'Escanear QR';

  @override
  String get inviteShareCta => 'Compartilhar convite';

  @override
  String get inviteShareSubject => 'Convite Stway — caminhem juntos';

  @override
  String get inviteSheetSubtitleCompanion =>
      'Toque no link, mostre o QR ou envie o card';

  @override
  String get inviteSheetSubtitleRoom => 'Mostre o QR ou envie o código';

  @override
  String get inviteSomeone => 'Alguém';

  @override
  String get journalEmpty =>
      'Ao fixar uma cena, sua resposta fica registrada aqui.';

  @override
  String get journalTitle => 'Anotações de estudo';

  @override
  String get journeyBeyondHorizon => 'Ainda além do horizonte';

  @override
  String get journeyLockedHint =>
      'Conclua a trilha anterior para liberar esta.';

  @override
  String journeyModeAhead(String mode) {
    return '$mode à frente';
  }

  @override
  String journeyModeInProgress(String mode) {
    return '$mode em curso';
  }

  @override
  String get journeyNow => 'Agora';

  @override
  String get journeySoonHint =>
      'Em breve · esta trilha ainda está sendo escrita.';

  @override
  String get journeyYouAreHere => 'Onde você está';

  @override
  String get juntosAccept => 'Aceitar';

  @override
  String get juntosBeforeLeaveBody =>
      'Escolha quem vai conduzir o grupo depois de você.';

  @override
  String get juntosBeforeLeaveTitle => 'Antes de sair';

  @override
  String get juntosBondNotStudying => 'Sem estudar';

  @override
  String get juntosBondNotYet => 'Ainda não';

  @override
  String get juntosBondYourTurn => 'Sua vez';

  @override
  String get juntosCancelInvite => 'Cancelar convite';

  @override
  String get juntosCancelInviteError =>
      'Não foi possível cancelar o convite. Tente de novo.';

  @override
  String get juntosCaravanEmptyBody =>
      'O ranking aparece com pelo menos mais uma pessoa caminhando. Chame alguém para a caravana — ou comece por uma companhia.';

  @override
  String get juntosCaravanEmptyTitle => 'A caravana ainda é pequena';

  @override
  String get juntosCaravanInviteCta => 'Chamar para a caravana';

  @override
  String get juntosCaravanLoadError =>
      'Não foi possível carregar a caravana. Puxe para atualizar.';

  @override
  String get juntosCaravanMonthBody =>
      'Tudo conta: cenas, tarefas do dia, baús e companhia. Zera todo dia 1 — quem chegou agora também pode liderar.';

  @override
  String get juntosCaravanMonthStep1 => 'Estude\numa cena';

  @override
  String get juntosCaravanMonthStep2 => 'Some\npassos';

  @override
  String get juntosCaravanMonthStep3 => 'Veja o\ncaminho';

  @override
  String get juntosCaravanMonthTitle => 'Quem mais caminhou neste mês?';

  @override
  String juntosCaravanPilgrimsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peregrinos da caravana',
      one: '1 peregrino da caravana',
    );
    return '$_temp0';
  }

  @override
  String get juntosCaravanShareSubject => 'Venha pra caravana no Stway';

  @override
  String juntosCaravanShareText(String name, String url) {
    return '$name te chama pra caravana no Stway — aprenda a Bíblia em cenas curtas e caminhe junto no ranking.\n\nBaixe: $url';
  }

  @override
  String get juntosCaravanSignInLive =>
      'Entre com Google para ver a caravana ao vivo.';

  @override
  String get juntosCaravanTimeout =>
      'A caravana demorou para responder. Puxe para atualizar.';

  @override
  String get juntosCaravanWeekBody =>
      'Só passos de cenas novas, de segunda a domingo. No fim da semana, os primeiros sobem de nível e os últimos descem.';

  @override
  String get juntosCaravanWeekStep1 => 'Passos\nda semana';

  @override
  String get juntosCaravanWeekStep2 => 'Lugar no\nranking';

  @override
  String get juntosCaravanWeekStep3 => 'Sobe ou\ndesce';

  @override
  String get juntosCaravanWeekTitle => 'Quem avançou nesta semana?';

  @override
  String juntosChallengeExplainerBody(String reward) {
    return 'Mesma cena, até domingo. Quem chegar ganha $reward — se os dois chegarem, os dois ganham.';
  }

  @override
  String get juntosChallengeExplainerTitle => 'Quem chega até domingo?';

  @override
  String get juntosChallengeStep1 => 'Mesma\ncena';

  @override
  String get juntosChallengeStep2 => 'Chegar até\ndomingo';

  @override
  String get juntosChallengeStep3 => '+10 passos\nna chegada';

  @override
  String get juntosChoose => 'Escolher';

  @override
  String juntosChromeTabAlert(String label) {
    return '$label, novidade';
  }

  @override
  String get juntosCloseConfirm => 'Encerrar';

  @override
  String get juntosCloseRoomBody =>
      'O grupo some para todos e o código deixa de funcionar. Não é possível desfazer.';

  @override
  String get juntosCloseRoomTitle => 'Encerrar o grupo?';

  @override
  String get juntosClosesToday => 'Fecha hoje';

  @override
  String get juntosCodeCopied => 'Código copiado';

  @override
  String get juntosCodeLabel => 'Código';

  @override
  String juntosCodeTapToCopy(String code) {
    return 'Código $code. Toque para copiar';
  }

  @override
  String get juntosCompanionExplainerBody =>
      'Uma companhia de estudo. No dia em que os dois caminham, o fio acende e a sequência cresce.';

  @override
  String get juntosCompanionExplainerTitle => 'Quem caminha ao seu lado?';

  @override
  String get juntosCompanionFallback => 'Companheiro';

  @override
  String get juntosCompanionStep1 => 'Os dois\nestudam';

  @override
  String get juntosCompanionStep2 => 'O dia conta\njuntos';

  @override
  String get juntosCompanionStep3 => 'Se um atrasa,\no outro acena';

  @override
  String get juntosCompanionsOfflineBody =>
      'Entre com Google para caminhar com alguém de verdade.';

  @override
  String get juntosCompanionsOfflineTitle => 'Companhia precisa da nuvem';

  @override
  String get juntosConnecting => 'Conectando…';

  @override
  String get juntosCopy => 'Copiar';

  @override
  String juntosCopyCodeSemantics(String code) {
    return 'Copiar código $code';
  }

  @override
  String get juntosCreateInviteError =>
      'Não foi possível criar o convite. Tente de novo.';

  @override
  String get juntosCreateRoom => 'Criar grupo';

  @override
  String juntosDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count dias',
      one: 'Falta 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get juntosDeclineInviteError =>
      'Não foi possível recusar o convite. Tente de novo.';

  @override
  String juntosDemoteZone(String tier) {
    return 'Zona de descida · $tier';
  }

  @override
  String get juntosEditRoomTitle => 'Editar grupo';

  @override
  String juntosFirstMilestone(int count) {
    return 'Primeiro marco: $count dias juntos';
  }

  @override
  String juntosGapToAbove(int gap, int place) {
    return '$gap do $placeº';
  }

  @override
  String get juntosHaveCode => 'Tenho um código';

  @override
  String juntosInboxNews(int count) {
    return 'Novidades · $count';
  }

  @override
  String get juntosInviteCompanion => 'Chamar um companheiro';

  @override
  String get juntosInvitePeople => 'Chamar pessoas';

  @override
  String get juntosInviteShort => 'Chamar';

  @override
  String get juntosJoin => 'Entrar';

  @override
  String get juntosJoinError => 'Não foi possível entrar. Tente de novo.';

  @override
  String get juntosJoinRoomHint => 'Código que você recebeu';

  @override
  String get juntosJoinRoomTitle => 'Entrar no grupo';

  @override
  String get juntosLeader => 'Líder';

  @override
  String juntosLeaveAllCompanionsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'As $count companhias terminam. Você fica sem companheiro.',
      one: 'A companhia termina. Você fica sem companheiro.',
    );
    return '$_temp0';
  }

  @override
  String get juntosLeaveAllCompanionsCta => 'Encerrar todas as companhias';

  @override
  String get juntosLeaveAllCompanionsTitle => 'Encerrar todas as companhias?';

  @override
  String get juntosLeaveAllConfirm => 'Encerrar todas';

  @override
  String get juntosLeaveCompanionBody =>
      'A companhia com esta pessoa termina. A caravana continua.';

  @override
  String get juntosLeaveCompanionCta => 'Sair da companhia';

  @override
  String get juntosLeaveCompanionTitle => 'Sair da companhia?';

  @override
  String get juntosLeaveConfirm => 'Sair';

  @override
  String get juntosLeaveRoomBody =>
      'Você sai da lista. Para voltar, use o código de novo.';

  @override
  String get juntosLeaveRoomTitle => 'Sair do grupo?';

  @override
  String juntosMilestoneLeft(int count, int next) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count para o marco de $next',
      one: 'Falta 1 para o marco de $next',
    );
    return '$_temp0';
  }

  @override
  String get juntosMilestones => 'Marcos';

  @override
  String juntosNextMilestone(int count) {
    return 'Próximo marco: $count dias';
  }

  @override
  String juntosOfTotal(int total) {
    return ' de $total';
  }

  @override
  String juntosOnlineSemantics(String countLabel) {
    return '$countLabel. Ver quem está estudando';
  }

  @override
  String get juntosOpenInvite => 'Convite aberto';

  @override
  String get juntosOpenInviteMissing => 'Falta uma pessoa do outro lado';

  @override
  String get juntosOrInviteCompanion => 'Ou chamar um companheiro';

  @override
  String juntosPromoteZone(String tier) {
    return 'Zona de subida · $tier';
  }

  @override
  String get juntosRoomAllStudied => 'O grupo inteiro estudou nesta semana.';

  @override
  String get juntosRoomBenefitList => 'Lista';

  @override
  String get juntosRoomBenefitListDetail => 'Quem estudou';

  @override
  String get juntosRoomBenefitStudy => 'Estudo';

  @override
  String get juntosRoomBenefitStudyDetail => 'Mesma cena';

  @override
  String get juntosRoomBenefitWave => 'Acenar';

  @override
  String get juntosRoomBenefitWaveDetail => 'Quem sumiu';

  @override
  String get juntosRoomChestAlready => 'Baú já coletado nesta semana';

  @override
  String juntosRoomChestClaimed(int count) {
    return 'Baú do grupo · +$count passos';
  }

  @override
  String juntosRoomChestOpen(int count) {
    return 'Abrir o baú do grupo · +$count passos';
  }

  @override
  String juntosRoomCreated(String code) {
    return 'Grupo criado. Chame alguém da lista, ou mande o código $code.';
  }

  @override
  String get juntosRoomFull =>
      'Grupo cheio. Para mais gente, abra outro grupo.';

  @override
  String get juntosRoomGoalHint => 'Soma da semana. Em branco, tira a meta.';

  @override
  String get juntosRoomGoalLabel => 'Meta do grupo';

  @override
  String juntosRoomGoalProgress(int sum, int goal) {
    return '$sum / $goal passos';
  }

  @override
  String get juntosRoomGoalTitle => 'Meta de passos do grupo';

  @override
  String get juntosRoomHalfStudied => 'Metade do grupo já estudou.';

  @override
  String get juntosRoomHintClaimed => 'Baú do grupo coletado nesta semana.';

  @override
  String get juntosRoomHintHalf => 'O baú abre quando metade do grupo estudar.';

  @override
  String get juntosRoomHintHalfOrGoal =>
      'O baú abre com metade do grupo ou a meta.';

  @override
  String get juntosRoomHintInvite =>
      'Chame quem estuda com você: célula, família, amigos.';

  @override
  String get juntosRoomHintStudyToday =>
      'Estude hoje para abrir o baú do grupo.';

  @override
  String get juntosRoomJoinError =>
      'Não foi possível entrar no grupo. Tente de novo.';

  @override
  String juntosRoomJoined(String name) {
    return 'Você entrou em $name.';
  }

  @override
  String get juntosRoomJoinedGeneric => 'Você entrou no grupo.';

  @override
  String juntosRoomLeaderLine(String leaderTitle, String leader, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
    );
    return '$leaderTitle: $leader · $_temp0';
  }

  @override
  String juntosRoomMissingForHalf(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count pessoas para metade do grupo.',
      one: 'Falta 1 pessoa para metade do grupo.',
    );
    return '$_temp0';
  }

  @override
  String get juntosRoomNotStudiedToday => 'Você ainda não estudou hoje.';

  @override
  String get juntosRoomOnlyYou => 'Só você no grupo por enquanto.';

  @override
  String get juntosRoomOptions => 'Opções do grupo';

  @override
  String get juntosRoomQrSubtitle =>
      'Aponte a câmera ou digite o código para entrar';

  @override
  String juntosRoomShareText(
    String name,
    String url,
    String code,
    String storeUrl,
  ) {
    return 'Entra no grupo \"$name\" no Stway.\nToque ou aponte a câmera:\n$url\n\nCódigo: $code\n\nA lista mostra quem estudou nesta semana.\n\nAinda não tem o app? Baixe: $storeUrl';
  }

  @override
  String get juntosRoomStudySet => 'Estudo marcado para o grupo';

  @override
  String get juntosRoomStudySetError =>
      'Não foi possível marcar o estudo. Tente de novo.';

  @override
  String get juntosRoomsEmptyBody =>
      'Um grupo fechado: célula, discipulado ou EBD. Marque a cena da semana e veja quem estudou — o convite vai no app ou no WhatsApp.';

  @override
  String get juntosRoomsEmptyEyebrow => 'Célula · Discipulado · EBD';

  @override
  String get juntosRoomsEmptyTitle => 'Quem estuda com você?';

  @override
  String get juntosRoomsOfflineBody =>
      'O grupo fica na sua conta. Entre com Google para criar ou usar um código.';

  @override
  String get juntosRoomsOfflineFoot => 'Sem login, o código não funciona';

  @override
  String get juntosRoomsOfflineTitle => 'Entre para criar o grupo';

  @override
  String get juntosSeenToday => 'Visto hoje';

  @override
  String get juntosShowQrShare => 'Mostrar QR e compartilhar';

  @override
  String get juntosSomeone => 'Alguém';

  @override
  String get juntosStudiedThisWeek => 'estudaram nesta semana';

  @override
  String get juntosStudyToday => 'Estudar hoje';

  @override
  String get juntosStudyingNow => 'Estudando agora';

  @override
  String get juntosSwitchRoomBody => 'Você sai do grupo em que está agora.';

  @override
  String juntosSwitchRoomTitle(String name) {
    return 'Entrar em $name?';
  }

  @override
  String get juntosTabCaravan => 'Caravana';

  @override
  String get juntosTabChallenge => 'Desafio';

  @override
  String get juntosTabCompanion => 'Companhia';

  @override
  String get juntosTabGroups => 'Grupos';

  @override
  String get juntosThisMonth => 'Este mês';

  @override
  String get juntosThisWeek => 'Esta semana';

  @override
  String get juntosTie => 'Empate';

  @override
  String get juntosTogetherLegend => 'juntos';

  @override
  String juntosTogetherOfSeven(int count) {
    return '$count de 7 juntos';
  }

  @override
  String get juntosTransferBody =>
      'Quem assumir marca o estudo, a meta e acena para o grupo. Você continua na lista.';

  @override
  String juntosTransferDone(String name) {
    return '$name agora conduz o grupo';
  }

  @override
  String get juntosTransferError =>
      'Não foi possível passar a liderança. Tente de novo.';

  @override
  String get juntosTransferTitle => 'Passar a liderança';

  @override
  String get juntosWaiting => 'Aguardando';

  @override
  String get juntosWalkedToday => 'Caminhou hoje';

  @override
  String juntosWaveAt(String name) {
    return 'Acenar para $name';
  }

  @override
  String get juntosWaveError => 'Não foi possível acenar. Tente de novo.';

  @override
  String juntosWavedAt(String name) {
    return 'Você acenou para $name';
  }

  @override
  String juntosWavedAtYou(String name) {
    return '$name acenou para você';
  }

  @override
  String get juntosWeekRankingEmpty =>
      'O ranking da semana só aparece com gente de verdade na caravana.';

  @override
  String juntosWeekTogetherBonus(int count) {
    return 'A companhia ganhou +$count passos na jornada';
  }

  @override
  String get juntosWho => 'Quem?';

  @override
  String get juntosYouLower => 'você';

  @override
  String get languageDevice => 'Do aparelho';

  @override
  String get languageHint =>
      'Os textos das trilhas e a Bíblia continuam em português por enquanto.';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get leagueActiveToday => 'Ativo hoje';

  @override
  String leagueBonusEncourage(int count) {
    return '+$count passos de encorajamento';
  }

  @override
  String leagueDemotedBody(int rank, String tier) {
    return 'Ficou em $rankº. No nível $tier, dá para subir de novo.';
  }

  @override
  String leagueDemotedTitle(String tier) {
    return 'Você desceu para $tier';
  }

  @override
  String leagueDriftDown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Desceu $count posições hoje',
      one: 'Desceu 1 posição hoje',
    );
    return '$_temp0';
  }

  @override
  String get leagueDriftStable => 'Posição estável hoje';

  @override
  String leagueDriftUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Subiu $count posições hoje',
      one: 'Subiu 1 posição hoje',
    );
    return '$_temp0';
  }

  @override
  String leagueLevelUpBodyOnly(String tier) {
    return 'Agora você caminha no nível\n$tier';
  }

  @override
  String leagueLevelUpBodyRank(int rank, String tier) {
    return 'Ficou em $rankº · agora caminha no nível\n$tier';
  }

  @override
  String get leagueLevelUpTitle => 'Você subiu de nível';

  @override
  String leaguePromotedLevelOnly(String tier) {
    return 'Agora no nível $tier';
  }

  @override
  String leaguePromotedRankLine(int rank, String tier) {
    return 'Ficou em $rankº · agora no nível $tier';
  }

  @override
  String leaguePromotedTitle(String tier) {
    return 'Você subiu para $tier';
  }

  @override
  String leagueRiskBodyClosing(int rank, String tier) {
    return 'Você está em $rankº no nível $tier. A caravana fecha em breve.';
  }

  @override
  String leagueRiskBodyHold(int rank, String tier) {
    return 'Você está em $rankº no nível $tier. Um passo pode segurar o lugar.';
  }

  @override
  String leagueRiskNear(String closes) {
    return 'Perto da descida · $closes';
  }

  @override
  String leagueRiskZone(String closes) {
    return 'Zona de descida · $closes';
  }

  @override
  String get leagueRoleLeader => 'Líder';

  @override
  String get leagueRolePodium => 'Pódio';

  @override
  String get leagueRoleVice => 'Vice';

  @override
  String leagueSeenDate(String date) {
    return 'Visto $date';
  }

  @override
  String leagueSeenOn(String date) {
    return 'Visto em $date';
  }

  @override
  String get leagueSeenToday => 'Visto hoje';

  @override
  String leagueSeenTodayWalked(String date) {
    return 'Visto hoje · caminhou $date';
  }

  @override
  String leagueStayedBody(int rank, String tier) {
    return 'Você ficou em $rankº no nível $tier. Nova semana — continue caminhando.';
  }

  @override
  String leagueStudying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estudando',
      one: '1 estudando',
      zero: '0 estudando',
    );
    return '$_temp0';
  }

  @override
  String get leagueTierCedro => 'Cedro';

  @override
  String get leagueTierEstrela => 'Estrela';

  @override
  String get leagueTierOliveira => 'Oliveira';

  @override
  String get leagueTierSemente => 'Semente';

  @override
  String get leagueTierVideira => 'Videira';

  @override
  String leagueWalkedDate(String date) {
    return 'Caminhou $date';
  }

  @override
  String leagueWalkedOn(String date) {
    return 'Caminhou em $date';
  }

  @override
  String leagueWalkedSeen(String walk, String seen) {
    return 'Caminhou $walk · visto $seen';
  }

  @override
  String get leagueWalkedToday => 'Caminhou hoje';

  @override
  String get leagueWeekEndedTitle => 'Semana da caravana encerrada';

  @override
  String get lessonBackToQuestion => 'Voltar à pergunta';

  @override
  String get lessonBonus => 'Bônus';

  @override
  String get lessonBoss => 'Travessia';

  @override
  String lessonCombo(int count) {
    return '×$count';
  }

  @override
  String lessonComboMeterSemantics(int count, int filled, int cycle) {
    return 'Combo $count · $filled de $cycle até reacender';
  }

  @override
  String get lessonDuration => '~3 min';

  @override
  String get lessonExitAnyway => 'Sair mesmo assim';

  @override
  String lessonExitBody(int act, int total) {
    return 'Você está na pergunta $act de $total. Saindo agora, os passos desta cena não contam.';
  }

  @override
  String get lessonExitTitle => 'Sair da cena?';

  @override
  String get lessonInsightSubtitle => 'O que ficou';

  @override
  String lessonIntroBossPulse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Travessia · $count perguntas',
      one: 'Travessia · 1 pergunta',
    );
    return '$_temp0';
  }

  @override
  String lessonIntroPulse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~3 min · $count perguntas',
      one: '~3 min · 1 pergunta',
    );
    return '$_temp0';
  }

  @override
  String get lessonLampRelit => 'Cinco seguidas: uma lâmpada reacendeu.';

  @override
  String lessonLampsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Restam $count lâmpadas — cada erro apaga uma.',
      one: 'Resta 1 lâmpada — cada erro apaga uma.',
      zero: 'As lâmpadas acabaram — cada erro apaga uma.',
    );
    return '$_temp0';
  }

  @override
  String get lessonListen => 'Ouvir o texto';

  @override
  String get lessonListenStop => 'Parar';

  @override
  String get lessonLoadError =>
      'Não foi possível carregar as perguntas desta cena. Tente de novo.';

  @override
  String get lessonLocked => 'Esta cena ainda está bloqueada.';

  @override
  String get lessonMicroSubtitle => 'Complete o verso';

  @override
  String get lessonPassageTitle => 'Texto da cena';

  @override
  String get lessonPractice => 'Treino';

  @override
  String lessonQuestionProgress(int current, int total) {
    return 'Pergunta $current de $total';
  }

  @override
  String get lessonVerseFallback => 'Versículo';

  @override
  String get liturgyAdvent => 'Advento';

  @override
  String get liturgyAdventSubtitle => 'Tempo de espera e preparação';

  @override
  String get liturgyChristmas => 'Natal';

  @override
  String get liturgyChristmasSubtitle => 'O Verbo se fez carne';

  @override
  String get liturgyEaster => 'Páscoa';

  @override
  String get liturgyEasterSubtitle => 'Cristo ressuscitou';

  @override
  String get liturgyHolyWeek => 'Semana Santa';

  @override
  String get liturgyHolyWeekSubtitle => 'Da cruz à espera da ressurreição';

  @override
  String get liturgyLent => 'Quaresma';

  @override
  String get liturgyLentSubtitle => 'Deserto, jejum e retorno';

  @override
  String get liturgyOrdinary => 'Tempo comum';

  @override
  String get liturgyOrdinarySubtitle => 'Crescimento na Palavra, dia a dia';

  @override
  String get liturgyPentecost => 'Pentecostes';

  @override
  String get liturgyPentecostSubtitle => 'O Espírito é derramado';

  @override
  String liturgyQuestSubtitle(String ref) {
    return 'Leia um capítulo — foco: $ref';
  }

  @override
  String liturgyQuestTitle(String season) {
    return 'Tempo de $season';
  }

  @override
  String get loginAppleError => 'Falha no login com Apple';

  @override
  String get loginBody =>
      'Sua conta guarda seus passos, sua sequência e suas cenas — assim nada se perde entre aparelhos.';

  @override
  String get loginEntering => 'Entrando…';

  @override
  String get loginGoogleError => 'Falha no login com Google';

  @override
  String get loginHydrateError =>
      'Não foi possível carregar seu progresso. Verifique a conexão e tente de novo.';

  @override
  String get loginLoadingBody =>
      'Carregando seus passos, sua sequência e suas cenas…';

  @override
  String get loginReconnect => 'Tentar reconectar';

  @override
  String get loginRequired => 'É necessário entrar para usar o Stway.';

  @override
  String get loginTitle => 'Entre para continuar';

  @override
  String get loginWithApple => 'Continuar com Apple';

  @override
  String get loginWithGoogle => 'Continuar com Google';

  @override
  String get mascotAllClear => 'Tudo claro. Volte amanhã para continuar.';

  @override
  String get mascotBossHigh => 'O desafio final ficou para trás. Siga o mapa.';

  @override
  String get mascotBossLow =>
      'Travessia feita. Vale reforçar o que ainda tremeu.';

  @override
  String get mascotCaravanDetailLead =>
      'Segure o 1º até o domingo e você avança de caravana.';

  @override
  String get mascotCaravanDetailOut =>
      'Cada cena move a caravana. Continue nesta semana.';

  @override
  String mascotCaravanDetailZone(int rank) {
    return '$rankº agora · os primeiros sobem no domingo.';
  }

  @override
  String get mascotCaravanLead => 'Você lidera a caravana';

  @override
  String mascotCaravanRank(int rank) {
    return '$rankº na caravana';
  }

  @override
  String get mascotCaravanZone => 'Zona de subida';

  @override
  String get mascotFailedDetail =>
      'As lâmpadas acabaram antes do fim. A cena espera você — de novo, com calma.';

  @override
  String get mascotFailedKicker => 'Faltou luz';

  @override
  String get mascotGood => 'Boa cena. A trilha te espera amanhã.';

  @override
  String get mascotHeadlineBoss => 'Travessia concluída';

  @override
  String get mascotHeadlinePerfect => '100% de acertos';

  @override
  String get mascotHeadlineReplay => 'Você voltou ao texto';

  @override
  String get mascotHeadlineScene => 'Cena concluída';

  @override
  String get mascotKickerBoss => 'Travessia final';

  @override
  String get mascotKickerPerfect => 'Sem erro';

  @override
  String get mascotKickerReplay => 'Revisão';

  @override
  String get mascotKickerScene => 'Mais uma cena';

  @override
  String get mascotPerfect => 'Nenhuma lâmpada perdida. Isso fica.';

  @override
  String get mascotReinforce =>
      'Cena feita. Reforce o que faltou — a memória agradece.';

  @override
  String get mascotReplay => 'Voltar ao texto fortalece o que já caminhou.';

  @override
  String get medalAccuracyEliteHint =>
      'Manteve 95%+ de acertos em 150 questões ou mais';

  @override
  String get medalAccuracyEliteTitle => 'Mira certeira';

  @override
  String get medalAdventDoorTitle => 'Porta aberta';

  @override
  String get medalAdventHalfHint => 'Caminhe metade dos dias do Advento';

  @override
  String get medalAdventHalfTitle => 'Meio do caminho';

  @override
  String get medalAdventLivedTitle => 'Temporada vivida';

  @override
  String get medalAdventSubtitle => 'Espera e preparação';

  @override
  String get medalAdventTitle => 'Advento';

  @override
  String medalAdventTrackSubtitle(String year) {
    return 'Espera e preparação — $year';
  }

  @override
  String medalAdventVaultTitle(String year) {
    return 'Advento $year';
  }

  @override
  String get medalAdventWeekHint => 'Sete dias de sequência no Advento';

  @override
  String get medalAdventWeekTitle => 'Semana de espera';

  @override
  String get medalAllLevelsDone => 'Todos os níveis concluídos.';

  @override
  String get medalBibleBeforeHint =>
      'Leu um capítulo no mesmo dia, antes da cena';

  @override
  String get medalBibleBeforeTitle => 'Palavra antes';

  @override
  String get medalComebackHint =>
      'A porta estava aberta — voltou após 21 dias ou mais';

  @override
  String get medalComebackTitle => 'Volta firme';

  @override
  String get medalFormationPerfect10Title => 'Olho firme';

  @override
  String get medalFormationPerfect1Title => 'Cena nítida';

  @override
  String get medalFormationPerfect25Hint => '25 cenas com 100% de acertos';

  @override
  String get medalFormationPerfect25Title => 'Tudo certo';

  @override
  String get medalFounderHint => 'Entrou no app durante o período de testes';

  @override
  String get medalFounderTitle => 'Pioneiro';

  @override
  String get medalHeadlineDiscovery => 'Descoberta';

  @override
  String get medalHeadlineJourney => 'Medalha da jornada';

  @override
  String get medalHeadlineLevelUp => 'Subiu de nível';

  @override
  String get medalHeadlineLit => 'Medalha acesa';

  @override
  String get medalHeadlineLocked => 'A desbloquear';

  @override
  String get medalHeadlineNew => 'Nova medalha';

  @override
  String get medalHeadlineRare => 'Rara';

  @override
  String get medalHeadlineTrail => 'Medalha da trilha';

  @override
  String medalHintAdventDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Caminhe $count dias no Advento',
      one: 'Caminhe 1 dia no Advento',
    );
    return '$_temp0';
  }

  @override
  String medalHintLentDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Caminhe $count dias na Quaresma',
      one: 'Caminhe 1 dia na Quaresma',
    );
    return '$_temp0';
  }

  @override
  String medalHintMemorizeVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Firme $count versículos na memorização',
      one: 'Firme 1 versículo na memorização',
    );
    return '$_temp0';
  }

  @override
  String medalHintPerfectScenes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Termine $count cenas com 100% de acertos',
      one: 'Termine uma cena com 100% de acertos',
    );
    return '$_temp0';
  }

  @override
  String medalHintReadChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Leia $count capítulos',
      one: 'Leia 1 capítulo na Bíblia',
    );
    return '$_temp0';
  }

  @override
  String medalHintShareVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Compartilhe $count versículos',
      one: 'Compartilhe 1 versículo',
    );
    return '$_temp0';
  }

  @override
  String medalHintStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mantenha $count dias de sequência',
      one: 'Mantenha 1 dia de sequência',
    );
    return '$_temp0';
  }

  @override
  String medalHowToEarn(String hint) {
    return 'Como ganhar: $hint';
  }

  @override
  String get medalJourneyVaultSubtitle => 'Faísca acende; medalha fica';

  @override
  String get medalJourneyVaultTitle => 'Cofre da jornada';

  @override
  String get medalLeaderHint => 'Ficou em 1º no ranking geral por um dia';

  @override
  String get medalLeaderTitle => 'Líder da caravana';

  @override
  String get medalLentFirstStepTitle => 'Primeiro passo no deserto';

  @override
  String get medalLentHalfHint => 'Caminhe metade dos dias da Quaresma';

  @override
  String get medalLentHalfTitle => 'Meio do deserto';

  @override
  String get medalLentLivedTitle => 'Quaresma vivida';

  @override
  String get medalLentSubtitle => 'Deserto, jejum e retorno';

  @override
  String get medalLentTitle => 'Quaresma';

  @override
  String medalLentTrackSubtitle(String year) {
    return 'Deserto, jejum e retorno — $year';
  }

  @override
  String medalLentVaultTitle(String year) {
    return 'Quaresma $year';
  }

  @override
  String get medalMemoryVerse15Title => 'Palavra guardada';

  @override
  String get medalMemoryVerse1Title => 'Primeiro verso';

  @override
  String get medalMemoryVerse50Title => 'Escritura viva';

  @override
  String get medalMysteryHint => 'Revelam-se no caminho — sem dica no cofre.';

  @override
  String medalMysteryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count descobertas',
      one: 'Uma descoberta',
    );
    return '$_temp0';
  }

  @override
  String medalNowTier(String tier) {
    return 'Agora em $tier';
  }

  @override
  String get medalPathStreak14Title => 'Duas semanas';

  @override
  String get medalPathStreak30Title => 'Mês constante';

  @override
  String get medalPathStreak3Title => 'Três dias firmes';

  @override
  String get medalPerfectBossHint =>
      'Venceu um desafio final com 100% de acertos';

  @override
  String get medalPerfectBossTitle => 'Prova impecável';

  @override
  String medalProximityAction(int count, String units, String track) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $units · $track',
      one: 'Falta $units · $track',
    );
    return '$_temp0';
  }

  @override
  String medalProximityLeft(
    int count,
    String units,
    String tier,
    String track,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $units para $tier em $track',
      one: 'Falta $units para $tier em $track',
    );
    return '$_temp0';
  }

  @override
  String medalProximityRemaining(int count, String units) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $units',
      one: 'Falta $units',
    );
    return '$_temp0';
  }

  @override
  String medalProximityShortLeft(int count, String tier) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count para $tier',
      one: 'Falta 1 para $tier',
    );
    return '$_temp0';
  }

  @override
  String medalProximityShortToward(int current, int target, String tier) {
    return '$current/$target rumo a $tier';
  }

  @override
  String medalProximityToward(String units, String tier, String track) {
    return '$units rumo a $tier em $track';
  }

  @override
  String medalRareLeft(int count, String unit, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count $unit para «$title»',
      one: 'Falta 1 $unit para «$title»',
    );
    return '$_temp0';
  }

  @override
  String medalRareShortLeft(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count para «$title»',
      one: 'Falta 1 para «$title»',
    );
    return '$_temp0';
  }

  @override
  String get medalRareVaultSubtitle =>
      'Medalhas excepcionais — só aparecem quando você ganha';

  @override
  String get medalRareVaultTitle => 'Raras';

  @override
  String get medalReflectionDeepHint =>
      'Registrou 40 reflexões no diário de cenas';

  @override
  String get medalReflectionDeepTitle => 'Diário profundo';

  @override
  String get medalSeasonFirstWeekTitle => 'Primeira semana';

  @override
  String get medalTierAurora => 'Ultra rara';

  @override
  String get medalTierBronze => 'Bronze';

  @override
  String get medalTierDiamond => 'Diamante';

  @override
  String get medalTierGold => 'Ouro';

  @override
  String get medalTierIron => 'Ferro';

  @override
  String get medalTierMirra => 'Mirra';

  @override
  String get medalTierPlatinum => 'Platina';

  @override
  String get medalTierSilver => 'Prata';

  @override
  String get medalTrackComplete => 'Completa';

  @override
  String get medalTrackFormationSubtitle => 'Acertos e domínio nas cenas';

  @override
  String get medalTrackFormationTitle => 'Formação';

  @override
  String get medalTrackMemorySubtitle => 'Versículos guardados no coração';

  @override
  String get medalTrackMemoryTitle => 'Memória';

  @override
  String get medalTrackPathSubtitle => 'Sequência na jornada';

  @override
  String get medalTrackPathTitle => 'Caminho';

  @override
  String get medalTrackUnlit => 'A acender';

  @override
  String get medalTrackWitnessSubtitle => 'Compartilhar a Palavra';

  @override
  String get medalTrackWitnessTitle => 'Testemunho';

  @override
  String get medalTrackWordSubtitle => 'Leitura bíblica na jornada';

  @override
  String get medalTrackWordTitle => 'Palavra';

  @override
  String medalTrailFinalModeHint(String mode) {
    return 'Conclua a trilha no modo $mode';
  }

  @override
  String get medalTrailFirstSceneHint => 'Conclua 1 cena nesta trilha';

  @override
  String get medalTrailFirstSceneTitle => 'Primeira cena';

  @override
  String get medalTrailFlawlessHint =>
      'Concluiu uma trilha inteira com 100% em todas as cenas';

  @override
  String get medalTrailFlawlessTitle => 'Trilha impecável';

  @override
  String medalTrailModeHint(String mode) {
    return 'Conclua o modo $mode';
  }

  @override
  String get medalTrailTrackSubtitle => 'Progresso nesta trilha';

  @override
  String medalUnitAdventDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias no Advento',
      one: '1 dia no Advento',
    );
    return '$_temp0';
  }

  @override
  String medalUnitChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capítulos',
      one: '1 capítulo',
    );
    return '$_temp0';
  }

  @override
  String medalUnitLentDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias na Quaresma',
      one: '1 dia na Quaresma',
    );
    return '$_temp0';
  }

  @override
  String medalUnitMemorizedVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versículos memorizados',
      one: '1 versículo memorizado',
    );
    return '$_temp0';
  }

  @override
  String medalUnitPerfectScenes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cenas perfeitas',
      one: '1 cena perfeita',
    );
    return '$_temp0';
  }

  @override
  String medalUnitSharedVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versículos compartilhados',
      one: '1 versículo compartilhado',
    );
    return '$_temp0';
  }

  @override
  String medalUnitStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias de sequência',
      one: '1 dia de sequência',
    );
    return '$_temp0';
  }

  @override
  String medalVaultAllMedals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Todas as $count medalhas',
      one: '1 medalha',
    );
    return '$_temp0';
  }

  @override
  String get medalVaultCompleteBody =>
      'Você iluminou cada medalha deste cofre. Continue caminhando na Palavra.';

  @override
  String get medalVaultCompleteLabel => 'Cofre completo';

  @override
  String get medalVaultDiscoveries => 'Descobertas';

  @override
  String get medalVaultEmptyHint =>
      'Cada cena concluída aproxima você de uma medalha. A primeira está perto.';

  @override
  String get medalVaultMysteryEmpty => 'Revelam-se no caminho — sem dica.';

  @override
  String get medalVaultMysteryMore => 'Outras se revelam no caminho.';

  @override
  String medalVaultNextSemantics(String message) {
    return 'Próxima medalha: $message';
  }

  @override
  String get medalVaultNextTitle => 'Próxima medalha';

  @override
  String medalVaultRemaining(int count, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count $unit',
      one: 'Falta 1 $unit',
    );
    return '$_temp0';
  }

  @override
  String get medalVaultSeason => 'Estação';

  @override
  String get medalVaultTabJourney => 'Jornada';

  @override
  String get medalVaultTabTrails => 'Trilhas';

  @override
  String get medalVaultTitle => 'Medalhas';

  @override
  String get medalWalkingInLightHint =>
      'Manteve 85%+ de acertos (mín. 50 questões)';

  @override
  String get medalWalkingInLightTitle => 'Andando na luz';

  @override
  String get medalWitnessShare10Title => 'Semeador';

  @override
  String get medalWitnessShare1Title => 'Palavra levada';

  @override
  String get medalWitnessShare50Title => 'Voz na caravana';

  @override
  String get medalWordChapters100Title => 'Leitor constante';

  @override
  String get medalWordChapters1Title => 'Primeira Palavra';

  @override
  String get medalWordChapters25Title => 'Leitor atento';

  @override
  String get memoryCard => 'Carta';

  @override
  String memoryDoneSummary(int known, int learning) {
    return '$known firmes · $learning em progresso';
  }

  @override
  String get memoryDoneTitle => 'Sessão concluída';

  @override
  String get memoryKnown => 'Já sei';

  @override
  String get memoryNotYet => 'Ainda não';

  @override
  String get memoryReveal => 'Revelar';

  @override
  String get memorySubtitle => 'Fixe na memória';

  @override
  String get memoryTitle => 'Memorizar';

  @override
  String get modeBadgeCleared => 'Concluída';

  @override
  String get modeBadgeCurrent => 'Atual';

  @override
  String get modeBadgeHere => 'Você está aqui';

  @override
  String get modeBadgeInProgress => 'Em andamento';

  @override
  String get modeBadgeLocked => 'Bloqueada';

  @override
  String get modeBadgeReview => 'Revisão';

  @override
  String get modeBannerHint => 'Toque para trocar de modo';

  @override
  String modeBannerSemantics(String name, String tagline) {
    return 'Modo de estudo: $name. $tagline.';
  }

  @override
  String get modeCaminhadaBlurb =>
      'Ligue os fatos: causas, contexto e o fio da narrativa.';

  @override
  String get modeCaminhadaLabel => 'Compreensão';

  @override
  String get modeCaminhadaSkill1 => 'Relacionar';

  @override
  String get modeCaminhadaSkill2 => 'Comparar';

  @override
  String get modeCaminhadaSkill3 => 'Encadear';

  @override
  String get modeCaminhadaTagline => 'O que o texto comunica';

  @override
  String get modeCaptionCleared => 'concluída';

  @override
  String get modeCaptionCurrent => 'atual';

  @override
  String get modeCaptionLocked => 'bloqueada';

  @override
  String modeCleared(String name) {
    return '$name concluída';
  }

  @override
  String get modeClearedReview => 'Concluída · revise quando quiser';

  @override
  String modeCtaContinue(String name) {
    return 'Continuar em $name';
  }

  @override
  String modeCtaReview(String name) {
    return 'Revisar $name';
  }

  @override
  String modeCtaStart(String name) {
    return 'Começar em $name';
  }

  @override
  String modeCtaStudy(String name) {
    return 'Estudar em $name';
  }

  @override
  String modeCurrent(String name) {
    return '$name atual';
  }

  @override
  String modeLockHint(String name) {
    return 'Conclua $name para liberar';
  }

  @override
  String modeLocked(String name) {
    return '$name bloqueada';
  }

  @override
  String modeNamed(String name) {
    return 'Modo $name';
  }

  @override
  String modeOrdinal(String ordinal) {
    return 'Modo $ordinal';
  }

  @override
  String modeOrdinalBadge(String ordinal, String badge) {
    return 'Modo $ordinal · $badge';
  }

  @override
  String get modePickerTitle => 'Como você quer\nestudar?';

  @override
  String get modePickerTopBar => 'Antes de partir';

  @override
  String modePrevAlmostDone(String name) {
    return '$name quase concluída';
  }

  @override
  String get modeProfundezasBlurb =>
      'Busque o sentido: o que o texto revela de Deus e para você.';

  @override
  String get modeProfundezasLabel => 'Interpretação';

  @override
  String get modeProfundezasSkill1 => 'Interpretar';

  @override
  String get modeProfundezasSkill2 => 'Sustentar';

  @override
  String get modeProfundezasSkill3 => 'Aplicar';

  @override
  String get modeProfundezasTagline => 'O que o texto significa';

  @override
  String get modeRuleFootnote =>
      'Três leituras do mesmo texto · conclua um modo para liberar o próximo';

  @override
  String modeScenesLeft(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count cenas de $name',
      one: 'Falta 1 cena de $name',
    );
    return '$_temp0';
  }

  @override
  String modeScenesProgress(int done, int total) {
    return '$done de $total cenas';
  }

  @override
  String get modeSementeBlurb =>
      'Repare nas palavras, nos fatos e na ordem em que acontecem.';

  @override
  String get modeSementeLabel => 'Observação';

  @override
  String get modeSementeSkill1 => 'Reconhecer';

  @override
  String get modeSementeSkill2 => 'Identificar';

  @override
  String get modeSementeSkill3 => 'Ordenar';

  @override
  String get modeSementeTagline => 'O que o texto diz';

  @override
  String modeSessionFootnote(String mode) {
    return 'Troca só nesta sessão · ao fechar o app, volta para $mode';
  }

  @override
  String get modeSheetEyebrow => 'Modo de estudo';

  @override
  String get modeSheetTitle => 'Como você quer estudar?';

  @override
  String get modeStartFirstScene => 'Comece pela primeira cena';

  @override
  String get modeSwitch => 'Trocar';

  @override
  String get morphAbsolute => 'absoluto';

  @override
  String get morphAdjective => 'adjetivo';

  @override
  String get morphAdverb => 'advérbio';

  @override
  String get morphAdverbConjAc => 'advérbio/conj. (ac)';

  @override
  String get morphArticle => 'artigo';

  @override
  String get morphBoth => 'ambos';

  @override
  String get morphCaseAccusative => 'acusativo';

  @override
  String get morphCaseDative => 'dativo';

  @override
  String get morphCaseGenitive => 'genitivo';

  @override
  String get morphCaseNominative => 'nominativo';

  @override
  String get morphCaseVocative => 'vocativo';

  @override
  String get morphConjConsecutive => 'conjunção consecut./conj.';

  @override
  String get morphConjunction => 'conjunção';

  @override
  String get morphConstruct => 'construto';

  @override
  String get morphDemonstrativeArticle => 'artigo demonstrativo';

  @override
  String get morphDetermined => 'determinado';

  @override
  String get morphDivineName => 'nome divino';

  @override
  String get morphDual => 'dual';

  @override
  String get morphExtraGentilic => 'gentílico';

  @override
  String get morphExtraLocal => 'local';

  @override
  String get morphExtraProper => 'nome próprio';

  @override
  String get morphExtraTitle => 'título';

  @override
  String get morphFem => 'fem.';

  @override
  String get morphGenderFeminine => 'feminino';

  @override
  String get morphGenderMasculine => 'masculino';

  @override
  String get morphInConstruct => 'em construto';

  @override
  String get morphInterjection => 'interjeição';

  @override
  String get morphLangAramaic => 'aramaico';

  @override
  String get morphLangGreek => 'grego';

  @override
  String get morphLangHebrew => 'hebraico';

  @override
  String get morphMasc => 'masc.';

  @override
  String get morphMoodImperative => 'imperativo';

  @override
  String get morphMoodIndicative => 'indicativo';

  @override
  String get morphMoodInfinitive => 'infinitivo';

  @override
  String get morphMoodOptative => 'optativo';

  @override
  String get morphMoodParticiple => 'particípio';

  @override
  String get morphMoodSubjunctive => 'subjuntivo';

  @override
  String get morphNegativeParticle => 'partícula negativa';

  @override
  String get morphNeuter => 'neutro';

  @override
  String get morphNoun => 'substantivo';

  @override
  String get morphNounCommon => 'comum';

  @override
  String get morphNounGentilic => 'gentílico';

  @override
  String get morphNounPlace => 'lugar';

  @override
  String get morphNounProper => 'próprio';

  @override
  String get morphNounTitle => 'título';

  @override
  String get morphNumberDual => 'dual';

  @override
  String get morphNumberPlural => 'plural';

  @override
  String get morphNumberSingular => 'singular';

  @override
  String get morphObjectMarker => 'marcador de objeto';

  @override
  String get morphParticle => 'partícula';

  @override
  String get morphParticleInterrogative => 'partícula interrogativa';

  @override
  String get morphPerson1 => '1ª pessoa';

  @override
  String get morphPerson1p => '1ª pl.';

  @override
  String get morphPerson1s => '1ª sing.';

  @override
  String get morphPerson2 => '2ª pessoa';

  @override
  String get morphPerson2p => '2ª pl.';

  @override
  String get morphPerson2s => '2ª sing.';

  @override
  String get morphPerson3 => '3ª pessoa';

  @override
  String get morphPerson3p => '3ª pl.';

  @override
  String get morphPerson3s => '3ª sing.';

  @override
  String get morphPhraseConj => 'Conjunção.';

  @override
  String morphPhraseConjGloss(String gloss) {
    return 'Conjunção — $gloss.';
  }

  @override
  String morphPhraseHead(String head) {
    return '$head.';
  }

  @override
  String morphPhraseHeadGloss(String head, String gloss) {
    return '$head — $gloss.';
  }

  @override
  String morphPhrasePersonOfNumber(String person, String number) {
    return '$person do $number';
  }

  @override
  String get morphPhrasePrep => 'Preposição.';

  @override
  String morphPhrasePrepGloss(String gloss) {
    return 'Preposição — $gloss.';
  }

  @override
  String get morphPhrasePrepSuffix => 'Preposição com sufixo pronominal.';

  @override
  String morphPhrasePrepSuffixGloss(String gloss) {
    return 'Preposição com sufixo — $gloss.';
  }

  @override
  String morphPhraseVerbBits(String bits, String gloss) {
    return '$bits — $gloss.';
  }

  @override
  String morphPhraseVerbBitsPlain(String bits) {
    return '$bits.';
  }

  @override
  String get morphPl => 'pl.';

  @override
  String get morphPrep => 'preposição';

  @override
  String get morphPronominalSuffix => 'sufixo pronominal';

  @override
  String get morphPronounDemonstrative => 'pronome demonstrativo';

  @override
  String get morphPronounPersonal => 'pronome pessoal';

  @override
  String get morphPronounPossessive => 'pronome possessivo';

  @override
  String get morphPronounReciprocal => 'pronome reciproc./correl.';

  @override
  String get morphPronounReflexive => 'pronome reflexivo';

  @override
  String get morphPronounRelative => 'pronome relativo';

  @override
  String get morphRelativeParticle => 'partícula relativa';

  @override
  String get morphSing => 'sing.';

  @override
  String get morphStemHifil => 'hifil';

  @override
  String get morphStemHitpael => 'hitpael';

  @override
  String get morphStemHofal => 'hofal';

  @override
  String get morphStemNifal => 'nifal';

  @override
  String get morphStemPiel => 'piel';

  @override
  String get morphStemPolal => 'polal';

  @override
  String get morphStemPual => 'pual';

  @override
  String get morphStemPulal => 'pulal';

  @override
  String get morphStemQal => 'qal';

  @override
  String get morphSuffix => 'sufixo';

  @override
  String get morphSuffixDirectional => 'direcional';

  @override
  String get morphSuffixNunParagogic => 'nun paragógico';

  @override
  String get morphSuffixParagogic => 'paragógico';

  @override
  String get morphSuffixPronominal => 'pronominal';

  @override
  String get morphTenseAorist => 'aoristo';

  @override
  String get morphTenseCohortative => 'coortativo';

  @override
  String get morphTenseFuture => 'futuro';

  @override
  String get morphTenseImperative => 'imperativo';

  @override
  String get morphTenseImperfectGk => 'imperfeito';

  @override
  String get morphTenseImperfectHeb => 'imperfecto';

  @override
  String get morphTenseInfAbsolute => 'infinitivo absoluto';

  @override
  String get morphTenseInfConstruct => 'infinitivo construto';

  @override
  String get morphTenseJussive => 'jussivo';

  @override
  String get morphTenseParticiple => 'particípio';

  @override
  String get morphTenseParticiplePassive => 'particípio passivo';

  @override
  String get morphTensePerfect => 'perfeito';

  @override
  String get morphTensePluperfect => 'mais-que-perfeito';

  @override
  String get morphTensePresent => 'presente';

  @override
  String get morphTenseSecondAorist => '2º aoristo/futuro';

  @override
  String get morphTenseUndefined => 'tempo indefinido';

  @override
  String get morphTenseWayyiqtol => 'sequencial imperfecto (wayyiqtol)';

  @override
  String get morphTenseWeqatal => 'sequencial perfeito (weqatal)';

  @override
  String get morphVerb => 'verbo';

  @override
  String get morphVoiceActive => 'ativa';

  @override
  String get morphVoiceImpersonal => 'impessoal';

  @override
  String get morphVoiceMidPassDeponent => 'médio-passiva deponente';

  @override
  String get morphVoiceMiddle => 'média';

  @override
  String get morphVoiceMiddleDeponent => 'média deponente';

  @override
  String get morphVoiceMiddlePassive => 'médio-passiva';

  @override
  String get morphVoicePassive => 'passiva';

  @override
  String get morphVoicePassiveDeponent => 'passiva deponente';

  @override
  String get navBible => 'Bíblia';

  @override
  String navTabWithNews(String tab) {
    return '$tab, com novidades';
  }

  @override
  String get navTogether => 'Juntos';

  @override
  String get navTrails => 'Trilhas';

  @override
  String get notifChannelDesc =>
      'Meta diária, cenas, prática, memorização e favoritos';

  @override
  String get notifChannelName => 'Lembretes Stway';

  @override
  String get notifContinueTitle => 'Continue de onde parou';

  @override
  String get notifDailyTitle => 'Do dia';

  @override
  String notifFavoritesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Você tem $count favoritos. Releia um e treine a memória.',
      one: 'Você guardou um versículo. Que tal revisitá-lo agora?',
    );
    return '$_temp0';
  }

  @override
  String get notifFavoritesTitle => 'Seus favoritos';

  @override
  String get notifGoalDoneBody => 'Meta feita. A sequência continua amanhã.';

  @override
  String notifGoalLeftBody(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Faltam $left cenas',
      one: 'Falta 1 cena',
    );
    return '$_temp0 para fechar a meta de hoje.';
  }

  @override
  String notifMemoryBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versículos no deck. Memorizar reforça o aprendizado.',
      one: 'Um versículo espera por você. Dois minutos bastam.',
    );
    return '$_temp0';
  }

  @override
  String notifMistakesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tem $count erros para reforçar. Prática rápida, mente firme.',
      one: 'Tem 1 erro para reforçar. Pratique agora e fixe o aprendizado.',
    );
    return '$_temp0';
  }

  @override
  String get notifPracticeTitle => 'Hora de praticar';

  @override
  String notifQuestsLeftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ainda faltam $count gestos do dia.',
      one: 'Sobrou 1 gesto. Mais um e o dia fecha.',
    );
    return '$_temp0';
  }

  @override
  String get notifResumeTitle => 'Hora de retomar';

  @override
  String notifReturningBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$name, faz $_temp0 sem estudar. Uma cena retoma a sequência.';
  }

  @override
  String get notifSceneWaitingBody =>
      'Uma cena por dia. A sequência continua amanhã.';

  @override
  String get notifSceneWaitingTitle => 'Sua cena te espera';

  @override
  String notifSceneWaitsBody(String name, String title) {
    return '$name, $title espera.';
  }

  @override
  String get notifSeeYouTomorrowTitle => 'Até amanhã';

  @override
  String get notifSignature => 'O Peregrino';

  @override
  String notifStreakLeftBody(String name, int streak, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '$streak dias',
      one: '1 dia',
    );
    String _temp1 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Faltam $left cenas',
      one: 'Falta 1 cena',
    );
    return '$name, você já anda há $_temp0. $_temp1 para acompanhar.';
  }

  @override
  String get notifTodayGoalTitle => 'Meta de hoje';

  @override
  String get notifTomorrowTitle => 'Amanhã';

  @override
  String get notifTrialEndingBody =>
      'Gerencie sua assinatura Peregrino+ nas configurações se não quiser continuar.';

  @override
  String get notifTrialEndingTitle => 'Seu teste grátis termina amanhã';

  @override
  String notifWeeklyLeftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ainda faltam $count passos semanais. A semana ainda é sua.',
      one: 'Falta 1 passo semanal. Feche o ciclo com calma.',
    );
    return '$_temp0';
  }

  @override
  String get notifWeeklyStepsBody => 'Ainda dá tempo de fechar a semana.';

  @override
  String get notifWeeklyStepsTitle => 'Passos da semana';

  @override
  String get nudgeAlreadySubtitle =>
      'Você já acenou hoje. Mande também no WhatsApp, se quiser.';

  @override
  String get nudgeCardCta => 'Vem retomar comigo no Stway';

  @override
  String nudgeCardDaysAway(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias sem estudar',
      one: '1 dia sem estudar',
    );
    return '$_temp0';
  }

  @override
  String get nudgeCardHeadline => 'Senti sua falta hoje';

  @override
  String get nudgeCardWaiting => 'Te esperando';

  @override
  String nudgeCardWalked(String name) {
    return '$name já caminhou';
  }

  @override
  String get nudgeCompanionFallback => 'Companheiro';

  @override
  String get nudgeDefaultMessage => 'Tô te esperando na trilha';

  @override
  String nudgeInAppSubtitle(String name) {
    return 'Um aceno no app — $name vê ao abrir o Stway.';
  }

  @override
  String get nudgeSendFailed => 'Não foi possível enviar o aceno.';

  @override
  String nudgeSent(String name) {
    return 'Aceno enviado. $name vê ao abrir o Stway.';
  }

  @override
  String get nudgeShareSubject => 'Vamos caminhar juntos?';

  @override
  String get nudgeSignInSubtitle =>
      'Entre na conta para acenar no app, ou mande no WhatsApp.';

  @override
  String nudgeTitle(String name) {
    return 'Acenar para $name';
  }

  @override
  String get offlineBody =>
      'Na primeira abertura, o Stway baixa o currículo da nuvem. Precisa de internet uma vez — depois fica no aparelho.';

  @override
  String get offlineDownloadFailed =>
      'Não foi possível baixar as cenas. Tente de novo em instantes.';

  @override
  String get offlineDownloading => 'Baixando…';

  @override
  String get offlineNoInternet =>
      'Sem internet no momento. Ligue o Wi‑Fi ou os dados e tente de novo.';

  @override
  String get offlineTitle => 'As cenas ainda não chegaram';

  @override
  String get onboardingAppearanceBody =>
      'Ela vale para o app inteiro.\nDá para trocar depois nos Ajustes.';

  @override
  String onboardingAppearanceSemantics(String theme) {
    return 'Aparência $theme';
  }

  @override
  String get onboardingAppearanceTitle => 'Escolha a aparência.';

  @override
  String get onboardingCommitmentLabel => 'Meu compromisso';

  @override
  String onboardingDayOneOf(int goal) {
    return 'Hoje  ·  dia 1 de $goal';
  }

  @override
  String get onboardingDefaultPromise => 'a primeira cena\njá está no caminho.';

  @override
  String get onboardingEveryDay => 'Todo dia.';

  @override
  String get onboardingFirstSceneMeta => 'Leia · responda · entenda  ·  ~3 min';

  @override
  String get onboardingFirstSceneTitle => 'Quem criou o mundo?';

  @override
  String get onboardingFiveLamps => '5 lâmpadas';

  @override
  String get onboardingHabitBody =>
      'Conhecer a Deus não pede uma maratona.\nPede que você volte, todo dia.';

  @override
  String get onboardingHoldToCommit => 'Segure para firmar';

  @override
  String get onboardingHolding => 'Firmando…';

  @override
  String get onboardingIntentBody =>
      'Cada cena: leia, responda, entenda.\nSeu motivo abre o caminho.';

  @override
  String get onboardingIntentHabitCaption => 'todo dia';

  @override
  String get onboardingIntentHabitPromise => 'a sequência\ncomeça hoje.';

  @override
  String get onboardingIntentHabitTitle => 'Criar uma sequência';

  @override
  String get onboardingIntentKnowCaption => 'de perto';

  @override
  String get onboardingIntentKnowPromise =>
      'conhecer a Deus\ncomeça com uma cena.';

  @override
  String get onboardingIntentKnowTitle => 'Conhecer a Deus';

  @override
  String get onboardingIntentPeaceCaption => 'um respiro';

  @override
  String get onboardingIntentPeacePromise => 'a paz do dia\ncomeça aqui.';

  @override
  String get onboardingIntentPeaceTitle => 'Paz no dia';

  @override
  String get onboardingIntentQuestion => 'O que te traz aqui?';

  @override
  String get onboardingIntentUnderstandCaption => 'de verdade';

  @override
  String get onboardingIntentUnderstandPromise =>
      'entender a Bíblia\ncomeça pelo começo.';

  @override
  String get onboardingIntentUnderstandTitle => 'Entender a Bíblia';

  @override
  String get onboardingKickerAppearance => 'III   ·   Aparência';

  @override
  String get onboardingKickerGoal => 'I   ·   A meta';

  @override
  String get onboardingKickerIntent => 'II   ·   Seu motivo';

  @override
  String get onboardingKickerJourney => 'V   ·   A jornada';

  @override
  String get onboardingKickerTomorrow => 'IV   ·   Amanhã';

  @override
  String get onboardingMinutes => 'Minutos';

  @override
  String get onboardingNameHint => 'seu nome';

  @override
  String get onboardingNamePrompt => 'Como te chamamos';

  @override
  String get onboardingOpening => 'Abrindo…';

  @override
  String onboardingPaceCaption(int scenes, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      scenes,
      locale: localeName,
      other: '$scenes cenas por dia · ~$minutes min',
      one: '1 cena por dia · ~$minutes min',
    );
    return '$_temp0';
  }

  @override
  String get onboardingRemindAtLabel => 'Te lembramos às';

  @override
  String get onboardingReminderMorning => 'Um lembrete de manhã';

  @override
  String get onboardingReminderNight => 'Um lembrete à noite';

  @override
  String get onboardingReminderNoon => 'Um lembrete ao meio-dia';

  @override
  String onboardingStreakDays(int count) {
    return '$count dias de sequência';
  }

  @override
  String get onboardingStreakMonth => 'Um mês inteiro';

  @override
  String get onboardingStreakTwoWeeks => 'Duas semanas de sequência';

  @override
  String get onboardingStreakWeek => 'Uma semana de sequência';

  @override
  String get onboardingTomorrowBody =>
      'O hábito nasce quando você volta.\nFirme com você mesmo um começo.';

  @override
  String get onboardingTomorrowWord => 'Amanhã';

  @override
  String get onboardingYourPace => 'Seu ritmo';

  @override
  String get paywallAlreadyPlus => 'Você já é Peregrino+';

  @override
  String get paywallHeadline => 'Vá além na trilha';

  @override
  String get paywallPerkSeason =>
      'A estação (Advento / Quaresma) — depois dos 3 dias grátis';

  @override
  String get paywallPerkWeeklyReview =>
      'Revisão da semana: os 7 “Hoje:” + 3 perguntas';

  @override
  String get paywallPitch => 'Um apoio direto ao projeto, com alguns extras.';

  @override
  String paywallPriceAnnual(String price) {
    return '$price por ano';
  }

  @override
  String paywallPriceLifetime(String price) {
    return '$price pagamento único';
  }

  @override
  String paywallPriceMonthly(String price) {
    return '$price por mês';
  }

  @override
  String paywallPriceMonths(int months, String price) {
    return '$price por $months meses';
  }

  @override
  String paywallPriceWeekly(String price) {
    return '$price por semana';
  }

  @override
  String get paywallPurchaseFailed => 'Não foi possível concluir a compra.';

  @override
  String get paywallRestore => 'Restaurar compra';

  @override
  String get paywallRestoreFailed => 'Não foi possível restaurar a compra.';

  @override
  String get paywallThanks => 'Obrigado por apoiar o Stway.';

  @override
  String get paywallTitle => 'Peregrino+';

  @override
  String get paywallUnavailable =>
      'Assinatura ainda não disponível nesta versão.';

  @override
  String get pilgrimAccuracyForming => 'Ainda em formação';

  @override
  String get pilgrimAccuracyGood => 'Boa compreensão nas cenas';

  @override
  String get pilgrimAccuracySharp => 'Leitura afiada das Escrituras';

  @override
  String get pilgrimAccuracySteady => 'Caminhando com firmeza';

  @override
  String get pilgrimAccuracyTitle => 'Acertos';

  @override
  String pilgrimChaptersBooks(int chapters, int books) {
    String _temp0 = intl.Intl.pluralLogic(
      chapters,
      locale: localeName,
      other: '$chapters capítulos',
      one: '1 capítulo',
    );
    String _temp1 = intl.Intl.pluralLogic(
      books,
      locale: localeName,
      other: '$books livros',
      one: '1 livro',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String pilgrimChaptersWordMedal(int chapters) {
    String _temp0 = intl.Intl.pluralLogic(
      chapters,
      locale: localeName,
      other: '$chapters capítulos',
      one: '1 capítulo',
    );
    return '$_temp0 · medalha Palavra';
  }

  @override
  String get pilgrimCollections => 'Coleções';

  @override
  String pilgrimCompletedOn(String date) {
    return 'Concluída em $date';
  }

  @override
  String pilgrimCorrectOf(int correct, int total) {
    return '$correct de $total';
  }

  @override
  String get pilgrimCorrectOnJourney => 'perguntas certas na jornada';

  @override
  String pilgrimCorrectRatio(int correct, int total) {
    return '$correct/$total certas';
  }

  @override
  String get pilgrimFallbackName => 'Peregrino';

  @override
  String pilgrimLastSeen(String when) {
    return 'Visto por último · $when';
  }

  @override
  String get pilgrimLastStudyDay => 'Último dia de estudo';

  @override
  String get pilgrimLedOverall => 'Já liderou o ranking geral';

  @override
  String get pilgrimNoReadingYet => 'Ainda sem leitura registrada';

  @override
  String get pilgrimNoTrailYet => 'Nenhuma trilha em andamento ainda.';

  @override
  String get pilgrimOnTheJourney => 'na jornada';

  @override
  String get pilgrimPrivacyBody =>
      'Toque no olho de cada card para escolher o que a caravana vê.';

  @override
  String get pilgrimPrivacyTitle => 'Privacidade do perfil';

  @override
  String get pilgrimPrivateBody =>
      'Escolheu não compartilhar detalhes com a caravana.';

  @override
  String get pilgrimPrivateTitle => 'Perfil privado';

  @override
  String pilgrimRank(int rank) {
    return '$rankº no ranking';
  }

  @override
  String get pilgrimRankLeader => 'Líder do ranking';

  @override
  String get pilgrimRankListed => 'No ranking';

  @override
  String get pilgrimRankMonthly => 'Ranking do mês';

  @override
  String pilgrimRankOrdinal(int rank) {
    return '$rankº';
  }

  @override
  String get pilgrimRankPodium => 'No pódio';

  @override
  String get pilgrimRankRunnerUp => 'Vice-líder';

  @override
  String get pilgrimRankWeekly => 'Ranking semanal da caravana';

  @override
  String get pilgrimSceneFallback => 'Cena';

  @override
  String pilgrimScenesOf(int done, int total) {
    return '$done de $total cenas';
  }

  @override
  String get pilgrimScriptures => 'Escrituras';

  @override
  String get pilgrimSealsAndTrails => 'Selos e trilhas';

  @override
  String get pilgrimSeen => 'Visto';

  @override
  String get pilgrimStatScenes => 'Cenas';

  @override
  String get pilgrimStatSteps => 'Passos';

  @override
  String get pilgrimStreak => 'Sequência';

  @override
  String get pilgrimStreakOngoing => 'Em andamento';

  @override
  String get pilgrimTrail => 'Trilha';

  @override
  String pilgrimTrailsInProgress(int count) {
    return '$count em curso';
  }

  @override
  String get pilgrimWalked => 'Caminhou';

  @override
  String get pilgrimYourTrail => 'Sua trilha';

  @override
  String get pilgrimYourTrails => 'Suas trilhas';

  @override
  String get planAdjustTime => 'Ajustar tempo';

  @override
  String get planAllRead => 'Tudo lido';

  @override
  String get planAlreadyRead => 'Já lidos';

  @override
  String planApproxDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~$count dias',
      one: '~1 dia',
    );
    return '$_temp0';
  }

  @override
  String planApproxHours(int hours) {
    return '~$hours h';
  }

  @override
  String planApproxMinutes(int minutes) {
    return '~$minutes min';
  }

  @override
  String planApproxMinutesDecimal(String minutes) {
    return '~$minutes min';
  }

  @override
  String planApproxMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~$count meses',
      one: '~1 mês',
    );
    return '$_temp0';
  }

  @override
  String get planAtYourPace => 'No seu ritmo';

  @override
  String get planBibleFinished => 'Você concluiu a Bíblia neste plano.';

  @override
  String get planCardDoneToday => 'Leitura de hoje feita';

  @override
  String get planCardIdle => 'Canônico ou cronológico, no seu tempo';

  @override
  String planCardToday(int minutes, String order) {
    return '$minutes min hoje · $order';
  }

  @override
  String planChaptersSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capítulos pulados',
      one: '1 capítulo pulado',
    );
    return '$_temp0';
  }

  @override
  String get planCreate => 'Criar um plano';

  @override
  String planDayDoneToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Leitura do dia concluída · $count capítulos',
      one: 'Leitura do dia concluída · 1 capítulo',
    );
    return '$_temp0';
  }

  @override
  String get planDone => 'Feito';

  @override
  String get planEndConfirmAction => 'Encerrar';

  @override
  String get planEndConfirmBody =>
      'Seu progresso no plano será zerado. Os capítulos já marcados como lidos na Bíblia permanecem.';

  @override
  String get planEndConfirmTitle => 'Encerrar plano?';

  @override
  String get planEndCta => 'Encerrar plano';

  @override
  String get planEstimate => 'Estimativa';

  @override
  String get planFinished => 'Plano concluído';

  @override
  String get planMarkDayRead => 'Marcar leitura do dia';

  @override
  String planMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get planOrderAlphabetical => 'Ordem alfabética';

  @override
  String get planOrderAlphabeticalShort => 'Alfabética';

  @override
  String get planOrderCanonical => 'Ordem da Bíblia';

  @override
  String get planOrderCanonicalShort => 'Canônica';

  @override
  String get planOrderChronological => 'Ordem cronológica';

  @override
  String get planOrderChronologicalShort => 'Cronológica';

  @override
  String get planPendingChapters => 'Capítulos pendentes';

  @override
  String planPortionMeta(int minutes, int count, String order) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~$minutes min · $count capítulos · $order',
      one: '~$minutes min · 1 capítulo · $order',
    );
    return '$_temp0';
  }

  @override
  String planReadingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias de leitura',
      one: '1 dia de leitura',
    );
    return '$_temp0';
  }

  @override
  String get planRemaining => 'Restante';

  @override
  String get planSectionOrder => 'Ordem';

  @override
  String get planSectionTime => 'Tempo disponível';

  @override
  String get planSetupBody =>
      'Montamos a porção diária para caber nesse tempo — na ordem da Bíblia ou na ordem dos acontecimentos. Capítulos que você já leu são pulados.';

  @override
  String get planSetupQuestion => 'Quanto tempo você tem por dia?';

  @override
  String planSkippedChaptersToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capítulos já lidos foram pulados',
      one: '1 capítulo já lido foi pulado',
    );
    return '$_temp0';
  }

  @override
  String planStartCta(int minutes) {
    return 'Começar plano · $minutes min/dia';
  }

  @override
  String get planTitle => 'Plano de leitura';

  @override
  String get planTodayChapters => 'Capítulos de hoje';

  @override
  String get planTodayDoneBody =>
      'Porção de hoje concluída. Volte amanhã — ou continue explorando a Bíblia livremente.';

  @override
  String get portraitAvatar => 'Avatar';

  @override
  String get portraitAvatarHint => 'Um peregrino ilustrado';

  @override
  String get portraitEyebrow => 'Retrato';

  @override
  String get portraitLetter => 'Letra';

  @override
  String get portraitLetterHint => 'As iniciais do nome';

  @override
  String get portraitNoPhoto => 'Sem foto nesta conta';

  @override
  String get portraitPhoto => 'Foto';

  @override
  String get portraitPhotoHint => 'A foto da sua conta';

  @override
  String get portraitTitle => 'Como você aparece no perfil';

  @override
  String get practiceEmptyBody =>
      'Continue as cenas. Quando errar, a pergunta volta aqui.';

  @override
  String get practiceEmptyTitle => 'Nenhum erro guardado ainda';

  @override
  String get practiceIntro =>
      'Volte às perguntas em que você errou. Cada acerto limpa a pergunta da fila.';

  @override
  String get practiceSubtitle => 'Reforce as passagens';

  @override
  String get practiceTitle => 'Revisar erros';

  @override
  String profileDaysOnTop(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias no topo',
      one: '1 dia no topo',
    );
    return '$_temp0';
  }

  @override
  String get profileDaysPerWeek => 'dias por semana';

  @override
  String get profileInTheWord => 'Na Palavra';

  @override
  String get profileInTheWordWhisper =>
      'Versos que você guarda e os que já saíram daqui.';

  @override
  String get profileLampHelp =>
      'Cada lamparina é uma semana: o azeite sobe a cada dia caminhado e a chama cresce.';

  @override
  String get profileLastThreeMonths => 'Últimos 3 meses';

  @override
  String profileMonthRank(int rank) {
    return '$rankº no ranking do mês';
  }

  @override
  String profileOfSevenDays(int count) {
    return '$count de 7 dias';
  }

  @override
  String get profileOpenBible => 'Abrir a Bíblia';

  @override
  String profileOpenRef(String ref) {
    return 'Abrir $ref';
  }

  @override
  String profilePrivacyHiddenSemantics(String label) {
    return '$label oculto da caravana';
  }

  @override
  String profilePrivacyHiddenToast(String label) {
    return '$label fica só com você.';
  }

  @override
  String profilePrivacyShownSemantics(String label) {
    return '$label visível para a caravana';
  }

  @override
  String profilePrivacyShownToast(String label) {
    return '$label aparece no seu perfil na caravana.';
  }

  @override
  String get profileSavedVerses => 'Guardados';

  @override
  String get profileSavedVersesEmpty =>
      'Na leitura, toque num versículo e escolha Guardar para voltar a ele depois.';

  @override
  String get profileSectionAccuracy => 'Taxa de acertos';

  @override
  String get profileSectionAccuracyHint => 'Percentual de acertos nas cenas';

  @override
  String get profileSectionBibleHint => 'Livros e capítulos lidos';

  @override
  String get profileSectionDaysOnTop => 'Dias no topo';

  @override
  String get profileSectionDaysOnTopHint =>
      'Quantos dias ficou em 1º no ranking geral';

  @override
  String get profileSectionLastScene => 'Última cena';

  @override
  String get profileSectionLastSceneHint => 'Nome da última cena concluída';

  @override
  String get profileSectionMedals => 'Medalhas';

  @override
  String get profileSectionMedalsHint => 'Medalhas da jornada';

  @override
  String get profileSectionPresence => 'Presença';

  @override
  String get profileSectionPresenceHint =>
      'Semana, sequência e marcos, de Semente a Fruto';

  @override
  String get profileSectionRanking => 'Ranking e passos';

  @override
  String get profileSectionRankingHint => 'Posição e passos totais';

  @override
  String get profileSectionTrailsHint =>
      'Progresso nas trilhas e selos adquiridos';

  @override
  String get profileSharedVerses => 'Enviados';

  @override
  String get profileSharedVersesEmpty =>
      'Versículos que você compartilhar aparecem aqui — só a referência.';

  @override
  String profileSince(String month, int year) {
    return 'Peregrino desde $month de $year';
  }

  @override
  String profileStreakGoalDone(int goal) {
    return 'Compromisso de $goal dias cumprido. Siga firme.';
  }

  @override
  String profileStreakOf(int streak, int goal) {
    return 'Sequência de $streak de $goal dias';
  }

  @override
  String profileStreakOfGoal(int goal) {
    return 'de $goal';
  }

  @override
  String profileStreakRemaining(int left, int goal) {
    return 'Faltam $left para o compromisso de $goal dias.';
  }

  @override
  String get profileStreakStart => 'Uma cena hoje acende o primeiro dia.';

  @override
  String get profileThisWeek => 'Esta semana';

  @override
  String get profileThisWeekLower => 'esta semana';

  @override
  String profileThisWeekSemantics(int count) {
    return 'Esta semana: $count de 7 dias caminhados';
  }

  @override
  String get profileThreeMonthsAgo => 'há 3 meses';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileTodayLower => 'hoje';

  @override
  String get profileWdFri => 'S';

  @override
  String get profileWdMon => 'S';

  @override
  String get profileWdSat => 'S';

  @override
  String get profileWdSun => 'D';

  @override
  String get profileWdThu => 'Q';

  @override
  String get profileWdTue => 'T';

  @override
  String get profileWdWed => 'Q';

  @override
  String get profileWeekHistory => 'Histórico das semanas';

  @override
  String profileWeeksWalkedSemantics(int walked, int weeks) {
    return '$walked dias caminhados nas últimas $weeks semanas';
  }

  @override
  String get profileYourJourney => 'Sua jornada';

  @override
  String get profileYourNumbers => 'Seus números';

  @override
  String get profileYourStreak => 'Sua sequência';

  @override
  String get questAccuracySubtitle => 'Termine uma cena com 80% de acertos';

  @override
  String get questAccuracyTitle => 'Olho firme';

  @override
  String questCountOf(int done, int total) {
    return '$done de $total';
  }

  @override
  String get questDailySubtitle => 'Passos extras além da cena.';

  @override
  String get questDailyTitle => 'Tarefas do dia';

  @override
  String get questDone => 'Feito';

  @override
  String get questDoneLower => 'feito';

  @override
  String get questMilestone100Subtitle => '100% — continue caminhando';

  @override
  String get questMilestone100Title => 'Jornada percorrida';

  @override
  String get questMilestone25Subtitle => '25% da trilha';

  @override
  String get questMilestone25Title => 'Bom começo';

  @override
  String get questMilestone50Subtitle => '50% da trilha';

  @override
  String get questMilestone50Title => 'Meio do caminho';

  @override
  String get questMilestone75Subtitle => '75% da trilha';

  @override
  String get questMilestone75Title => 'Quase lá';

  @override
  String get questMissionSubtitle => 'Complete uma cena';

  @override
  String get questMissionTitle => 'Uma cena';

  @override
  String questProgressLine(int value, int target, String subtitle) {
    return '$value de $target · $subtitle';
  }

  @override
  String get questReadSubtitle => 'Leia um capítulo';

  @override
  String get questReadTitle => 'Na Palavra';

  @override
  String get questWeeklyDaysSubtitle => 'Caminhe em 4 dias diferentes';

  @override
  String get questWeeklyDaysTitle => 'Quatro dias';

  @override
  String get questWeeklyPerfectSubtitle =>
      'Duas cenas com 100% de acertos na semana';

  @override
  String get questWeeklyPerfectTitle => 'Duas sem erro';

  @override
  String get questWeeklyScenesSubtitle => 'Complete 5 cenas nesta semana';

  @override
  String get questWeeklyScenesTitle => 'Cinco cenas';

  @override
  String get questWeeklyTitle => 'Tarefas da semana';

  @override
  String get realmAntigoTestamento => 'Antigo Testamento';

  @override
  String get realmEyebrowAntigoTestamento => 'A promessa';

  @override
  String get realmEyebrowNovoTestamento => 'O cumprimento';

  @override
  String get realmEyebrowTeologia => 'O fundamento';

  @override
  String get realmEyebrowVidaCrista => 'O caminhar';

  @override
  String get realmNovoTestamento => 'Novo Testamento';

  @override
  String get realmOther => 'Outros';

  @override
  String get realmTaglineAntigoTestamento =>
      'Da criação aos profetas — o caminho da aliança';

  @override
  String get realmTaglineNovoTestamento =>
      'Cristo, a Igreja e a esperança que não falha';

  @override
  String get realmTaglineTeologia => 'Hermenêutica, línguas e a doutrina da fé';

  @override
  String get realmTaglineVidaCrista => 'Discipulado, oração e a história da fé';

  @override
  String get realmTeologia => 'Teologia';

  @override
  String get realmTeologiaSoonBody =>
      'Hermenêutica, línguas originais e dogmática.';

  @override
  String get realmVidaCrista => 'Vida Cristã';

  @override
  String get recognitionAMedal => 'Uma medalha';

  @override
  String get recognitionAlready => 'Você já reconheceu';

  @override
  String recognitionAndMore(String a, String b, int count) {
    return '$a, $b e mais $count';
  }

  @override
  String recognitionAndTwo(String a, String b) {
    return '$a e $b';
  }

  @override
  String recognitionDaysAgo(int count) {
    return 'Há $count dias';
  }

  @override
  String get recognitionEmptyCard =>
      'Quando alguém da caravana tocar no coração, aparece aqui.';

  @override
  String get recognitionEmptySheet =>
      'Ainda ninguém reconheceu sua jornada.\nNa caravana, outros podem tocar no coração.';

  @override
  String get recognitionFailedGive => 'Não foi possível reconhecer';

  @override
  String get recognitionFailedWithdraw => 'Não foi possível retirar';

  @override
  String get recognitionGivenTapWithdraw => 'Reconhecida · toque para retirar';

  @override
  String recognitionHeadlineMedal(String name, String title) {
    return '$name reconheceu $title';
  }

  @override
  String recognitionHeadlineMedalUnknown(String name) {
    return '$name reconheceu uma medalha sua';
  }

  @override
  String recognitionHeadlineWalk(String name) {
    return '$name reconheceu sua cena';
  }

  @override
  String get recognitionHomeSeeWho => 'Ver quem reconheceu';

  @override
  String get recognitionHomeTitleMany => 'Reconheceram sua jornada';

  @override
  String recognitionHomeTitleSingle(String name) {
    return '$name reconheceu sua jornada';
  }

  @override
  String get recognitionMedalDone => 'Medalha reconhecida';

  @override
  String get recognitionMedalFirstScene => 'Primeira cena';

  @override
  String get recognitionMedalInterpretation => 'Interpretação';

  @override
  String get recognitionMedalObservation => 'Observação';

  @override
  String get recognitionMedalUnderstanding => 'Compreensão';

  @override
  String get recognitionRecognizeScene => 'Reconhecer a cena';

  @override
  String get recognitionRemoved => 'Reconhecimento retirado';

  @override
  String recognitionSawJourney(int count, String who) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$who viram sua jornada',
      one: '$who viu sua jornada',
    );
    return '$_temp0';
  }

  @override
  String recognitionSawYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'reconheceu você $count vezes',
      one: 'reconheceu você',
    );
    return '$_temp0';
  }

  @override
  String get recognitionSceneDone => 'Cena reconhecida';

  @override
  String recognitionSceneOf(String date) {
    return 'Cena de $date';
  }

  @override
  String recognitionSemanticsWho(String subtitle) {
    return 'Quem reconheceu. $subtitle';
  }

  @override
  String recognitionSummaryCounts(int recog, int people) {
    String _temp0 = intl.Intl.pluralLogic(
      recog,
      locale: localeName,
      other: '$recog reconhecimentos',
      one: '1 reconhecimento',
    );
    String _temp1 = intl.Intl.pluralLogic(
      people,
      locale: localeName,
      other: '$people pessoas',
      one: '1 pessoa',
    );
    return '$_temp0 de $_temp1';
  }

  @override
  String get recognitionSummaryEmpty =>
      'Cena do dia e medalhas que outros viram em você.';

  @override
  String get recognitionTapToWithdraw => 'Toque de novo para retirar';

  @override
  String get recognitionWhichMedal => 'Qual medalha você viu?';

  @override
  String get recognitionWhoTitle => 'Quem reconheceu';

  @override
  String get recognitionYesterday => 'Ontem';

  @override
  String get recognitionYourScene => 'Sua cena';

  @override
  String get reminderDailyEyebrow => 'Lembrete diário';

  @override
  String reminderHour(int hour) {
    return '${hour}h';
  }

  @override
  String get reminderMorning => 'Manhã';

  @override
  String get reminderNight => 'Noite';

  @override
  String get reminderNoon => 'Meio-dia';

  @override
  String reminderRemindAt(int hour) {
    return 'Lembrar às ${hour}h';
  }

  @override
  String get reminderSubtitle =>
      'Um horário fixo cola o hábito. Amanhã te avisamos da próxima cena.';

  @override
  String get reminderSubtitleSettings =>
      'Um aviso por dia, no horário que você escolher.';

  @override
  String get reminderTitle => 'Em que hora lembramos você?';

  @override
  String get reportCategoryFeedback => 'Feedback confuso';

  @override
  String get reportCategoryInterpretation => 'Interpretação questionável';

  @override
  String get reportCategoryOther => 'Outro';

  @override
  String get reportCategoryTheological => 'Erro teológico';

  @override
  String get reportCategoryTypo => 'Ortografia / texto';

  @override
  String get reportCategoryWrongAnswer => 'Resposta marcada errada';

  @override
  String get reportCommentHint => 'Opcional: conte o que parece errado…';

  @override
  String get reportHintFeedback =>
      'Explicação após a resposta confunde ou erra';

  @override
  String get reportHintInterpretation =>
      'Leitura do texto bíblico parece forçada ou imprecisa';

  @override
  String get reportHintOther => 'Algo mais que não se encaixa acima';

  @override
  String get reportHintTheological =>
      'Doutrina ou doutrina implícita parece incorreta';

  @override
  String get reportHintTypo => 'Erro de digitação, referência ou formatação';

  @override
  String get reportHintWrongAnswer =>
      'A opção marcada como certa parece errada';

  @override
  String get reportIntro =>
      'Ajude a melhorar a trilha — erro teológico, interpretação, resposta ou texto.';

  @override
  String get reportSend => 'Enviar relato';

  @override
  String get reportSendError => 'Não foi possível enviar. Tente de novo.';

  @override
  String get reportSending => 'Enviando…';

  @override
  String get reportSignInRequired => 'Entre com Google para enviar o relato.';

  @override
  String get reportTitle => 'Relatar problema';

  @override
  String get resetAwareness => 'Estou ciente de que vou perder o progresso';

  @override
  String get resetBody =>
      'Todos os passos, a sequência e o progresso serão apagados. A introdução volta a aparecer. Não dá para desfazer.';

  @override
  String get resetConfirm => 'Confirmar';

  @override
  String resetConfirmCountdown(int seconds) {
    return 'Confirmar · ${seconds}s';
  }

  @override
  String get resetTitle => 'Apagar progresso';

  @override
  String get roomErrorCreate =>
      'Não foi possível criar o grupo. Tente de novo.';

  @override
  String get roomErrorCreateFirst => 'Crie o grupo antes de chamar alguém.';

  @override
  String roomErrorFull(int limit) {
    return 'Este grupo já tem $limit pessoas.';
  }

  @override
  String roomErrorFullAskLeader(int limit) {
    return 'Este grupo já tem $limit pessoas. Peça ao líder para abrir outro grupo.';
  }

  @override
  String get roomErrorInvalidCode => 'Código inválido ou grupo não encontrado.';

  @override
  String get roomErrorLostGroup => 'Não achamos o grupo em que você estava.';

  @override
  String get roomErrorSignInCreate => 'Entre com Google para criar um grupo.';

  @override
  String get roomErrorSignInJoin => 'Entre com Google para entrar num grupo.';

  @override
  String get roomFallbackName => 'Grupo';

  @override
  String get roomKindAmigos => 'Amigos';

  @override
  String get roomKindCelula => 'Célula';

  @override
  String get roomKindDiscipulado => 'Discipulado';

  @override
  String get roomKindEbd => 'EBD';

  @override
  String get roomKindFamilia => 'Família';

  @override
  String get roomLeaderAmigos => 'Anfitrião';

  @override
  String get roomLeaderCelula => 'Líder';

  @override
  String get roomLeaderDiscipulado => 'Discipulador';

  @override
  String get roomLeaderEbd => 'Professor';

  @override
  String get roomLeaderFamilia => 'Responsável';

  @override
  String get roomNameHintAmigos => 'Ex.: Amigos da facul';

  @override
  String get roomNameHintCelula => 'Ex.: Célula Norte';

  @override
  String get roomNameHintDiscipulado => 'Ex.: Discipulado de quinta';

  @override
  String get roomNameHintEbd => 'Ex.: EBD Jovens';

  @override
  String get roomNameHintFamilia => 'Ex.: Família Souza';

  @override
  String get roomStudyFallbackTitle => 'Estudo da semana';

  @override
  String sealsAllRevealed(int done, int total) {
    return '$done de $total — todos os selos revelados.';
  }

  @override
  String sealsCountFact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selos — fato e verso, no texto.',
      one: '1 selo — fato e verso, no texto.',
    );
    return '$_temp0';
  }

  @override
  String get sealsEmptyHint => 'Fato e verso de quem o texto já mostrou.';

  @override
  String get sealsSemanticsLocked => 'Selo ainda fechado';

  @override
  String sealsSemanticsNamed(String name) {
    return 'Selo $name';
  }

  @override
  String sealsStartsAt(String name) {
    return 'Ainda no texto — começa em $name.';
  }

  @override
  String sealsStillInText(int done, int total, String name) {
    return '$done de $total — ainda no texto: $name';
  }

  @override
  String get sealsTitle => 'Selos';

  @override
  String get seasonChallengeDoneBody =>
      'Desafio da estação concluído. Bem caminhado.';

  @override
  String get seasonChallengeEmptyBody =>
      'O próximo chega com a nova estação litúrgica.';

  @override
  String get seasonChallengeEmptyTitle => 'Nenhum desafio da estação agora';

  @override
  String get seasonChallengeInProgress => 'Desafio da estação em andamento';

  @override
  String get seasonChallengeInvite => 'Chamar para o desafio';

  @override
  String seasonChallengePathPercent(int percent) {
    return '$percent% do caminho';
  }

  @override
  String get seasonChallengeSeeProgress => 'Ver progresso';

  @override
  String seasonChallengeShareBody(String title, String footer) {
    return '🕯️ Entrei no desafio $title no Stway.\n\nVamos caminhar juntos nesta estação?\n\n$footer';
  }

  @override
  String get seasonChallengeTitle => 'Desafio da estação';

  @override
  String seasonDayLine(int day, String title) {
    return 'Dia $day · $title';
  }

  @override
  String seasonDayOf(String day, int total) {
    return 'Dia $day de $total';
  }

  @override
  String seasonDaysWalked(int done, int total) {
    return '$done / $total dias caminhados';
  }

  @override
  String get seasonEnded => 'Estação encerrada';

  @override
  String get seasonFreeTrialLine =>
      'Gratuito: 3 primeiros dias · depois, Peregrino+';

  @override
  String get seasonNotTodayYet => 'Ainda não é hoje';

  @override
  String get seasonProFromDay4 => 'Peregrino+ a partir do dia 4';

  @override
  String get seasonReviewEmpty =>
      'Ainda não há perguntas desta semana no aparelho. Abra um dia primeiro.';

  @override
  String get seasonReviewMissionIntro =>
      'Três perguntas dos textos que você já estudou.';

  @override
  String get seasonReviewMissionTitle => 'Revisão da semana';

  @override
  String get seasonReviewPreparing => 'Preparando…';

  @override
  String get seasonReviewStart => '3 perguntas de revisão';

  @override
  String seasonStartsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Começa em $count dias',
      one: 'Começa em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String seasonTodayInsight(String insight) {
    return 'Hoje: $insight';
  }

  @override
  String get seasonWalkAdvento2026Day01Insight => 'Deus se aproximou';

  @override
  String get seasonWalkAdvento2026Day01Title => 'O Verbo se fez carne';

  @override
  String get seasonWalkAdvento2026Day02Insight => 'Deus é o centro, não eu';

  @override
  String get seasonWalkAdvento2026Day02Title => 'No princípio';

  @override
  String get seasonWalkAdvento2026Day03Insight => 'Fomos feitos para refletir';

  @override
  String get seasonWalkAdvento2026Day03Title => 'Imagem';

  @override
  String get seasonWalkAdvento2026Day04Insight => 'A fé anda quando Deus chama';

  @override
  String get seasonWalkAdvento2026Day04Title => 'Chamado';

  @override
  String get seasonWalkAdvento2026Day05Insight =>
      'A promessa é maior que o medo';

  @override
  String get seasonWalkAdvento2026Day05Title => 'Estrelas';

  @override
  String get seasonWalkAdvento2026Day06Insight => 'Deus proverá o cordeiro';

  @override
  String get seasonWalkAdvento2026Day06Title => 'Moriah';

  @override
  String get seasonWalkAdvento2026Day07Insight => 'Deus levanta libertador';

  @override
  String get seasonWalkAdvento2026Day07Title => 'Moisés';

  @override
  String get seasonWalkAdvento2026Day08Insight => 'O sangue guarda a casa';

  @override
  String get seasonWalkAdvento2026Day08Title => 'Páscoa';

  @override
  String get seasonWalkAdvento2026Day09Insight => 'O Reino tem voz';

  @override
  String get seasonWalkAdvento2026Day09Title => 'O Rei no monte';

  @override
  String get seasonWalkAdvento2026Day10Insight => 'O Reino cabe no vazio';

  @override
  String get seasonWalkAdvento2026Day10Title => 'Pobres de espírito';

  @override
  String get seasonWalkAdvento2026Day11Insight => 'Há conforto para quem chora';

  @override
  String get seasonWalkAdvento2026Day11Title => 'Os que choram';

  @override
  String get seasonWalkAdvento2026Day12Insight => 'Shalom é missão';

  @override
  String get seasonWalkAdvento2026Day12Title => 'Pacificadores';

  @override
  String get seasonWalkAdvento2026Day13Insight => 'O céu se abre sobre o Filho';

  @override
  String get seasonWalkAdvento2026Day13Title => 'Batismo';

  @override
  String get seasonWalkAdvento2026Day14Insight => 'O monte ensina o Reino';

  @override
  String get seasonWalkAdvento2026Day14Title => 'Sermão';

  @override
  String get seasonWalkAdvento2026Day15Insight => 'Orar é pedir o Reino';

  @override
  String get seasonWalkAdvento2026Day15Title => 'Pai nosso';

  @override
  String get seasonWalkAdvento2026Day16Insight => 'Nada me faltará';

  @override
  String get seasonWalkAdvento2026Day16Title => 'Meu pastor';

  @override
  String get seasonWalkAdvento2026Day17Insight => 'Cristo desceu até a cruz';

  @override
  String get seasonWalkAdvento2026Day17Title => 'Humildade';

  @override
  String get seasonWalkAdvento2026Day18Insight =>
      'O Reino se escuta em história';

  @override
  String get seasonWalkAdvento2026Day18Title => 'Parábolas';

  @override
  String get seasonWalkAdvento2026Day19Insight => 'O Reino toca o corpo';

  @override
  String get seasonWalkAdvento2026Day19Title => 'Milagres';

  @override
  String get seasonWalkAdvento2026Day20Insight => 'O tesouro puxa o coração';

  @override
  String get seasonWalkAdvento2026Day20Title => 'Ansiedade';

  @override
  String get seasonWalkAdvento2026Day21Insight => 'O pão antecipa a entrega';

  @override
  String get seasonWalkAdvento2026Day21Title => 'Ceia';

  @override
  String get seasonWalkAdvento2026Day22Insight => 'O Rei reina pregado';

  @override
  String get seasonWalkAdvento2026Day22Title => 'Cruz';

  @override
  String get seasonWalkAdvento2026Day23Insight => 'A espera não foi vã';

  @override
  String get seasonWalkAdvento2026Day23Title => 'Ressurreição';

  @override
  String get seasonWalkAdvento2026Day24Insight => 'O sétimo dia é dádiva';

  @override
  String get seasonWalkAdvento2026Day24Title => 'Descanso';

  @override
  String get seasonWalkAdvento2026Day25Insight => 'Alegrai-vos no Senhor';

  @override
  String get seasonWalkAdvento2026Day25Title => 'Alegria';

  @override
  String get seasonWalkAdvento2026Day26Insight => 'Quem tem fome será farto';

  @override
  String get seasonWalkAdvento2026Day26Title => 'Fome de justiça';

  @override
  String get seasonWalkAdvento2026Subtitle =>
      'Espera do Verbo · uma cena por dia';

  @override
  String get seasonWalkAdvento2026Title => 'Advento 2026';

  @override
  String seasonWeek(int week) {
    return 'Semana $week';
  }

  @override
  String get seasonWeekInsightsHeader => 'Os 7 “Hoje:” desta semana';

  @override
  String get seasonWeekReview => 'Revisão da semana';

  @override
  String get seasonWeekReviewPro => 'Revisão da semana · Peregrino+';

  @override
  String seasonWeekReviewTitle(int week) {
    return 'Revisão da semana $week';
  }

  @override
  String get settingsAbout => 'Sobre';

  @override
  String get settingsAboutSubtitle =>
      'Aprenda a Bíblia em cenas curtas, no seu ritmo.';

  @override
  String get settingsAboutTitle => 'Sobre o Stway';

  @override
  String get settingsAccount => 'Conta';

  @override
  String get settingsAppearanceTitle => 'Aparência';

  @override
  String get settingsBackupInvalid => 'Backup inválido.';

  @override
  String get settingsBackupSheetBody =>
      'Exporte o progresso como texto, ou copie um backup e toque em restaurar.';

  @override
  String get settingsBackupSubject => 'Backup Stway';

  @override
  String get settingsCheck => 'Verificar';

  @override
  String get settingsCheckingUpdate => 'Procurando atualização…';

  @override
  String get settingsCreditsRowSubtitle => 'Textos bíblicos e estudo';

  @override
  String get settingsCreditsSubtitle =>
      'Textos bíblicos e ferramentas de estudo usados no Stway.';

  @override
  String get settingsCreditsTitle => 'Traduções e créditos';

  @override
  String get settingsDailyReminder => 'Lembrete diário';

  @override
  String settingsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String get settingsDeleteProgress => 'Apagar progresso';

  @override
  String get settingsDeleteProgressSubtitle =>
      'Apaga o progresso de vez · pede confirmação';

  @override
  String settingsDeviceId(String id) {
    return 'Dispositivo · $id';
  }

  @override
  String get settingsDeviceOnly => 'Só neste aparelho';

  @override
  String get settingsExport => 'Exportar';

  @override
  String get settingsFontExtra => 'Extra';

  @override
  String get settingsFontLarge => 'Grande';

  @override
  String get settingsFontMedium => 'Médio';

  @override
  String get settingsFontSmall => 'Pequeno';

  @override
  String get settingsGenesisTitle => 'Gênesis 1–11';

  @override
  String get settingsGroupAccountData => 'Conta e dados';

  @override
  String get settingsGroupDevice => 'Neste aparelho';

  @override
  String get settingsGroupProgress => 'Progresso';

  @override
  String get settingsInCloud => 'Na nuvem';

  @override
  String settingsLastBackup(String date) {
    return 'Último backup · $date';
  }

  @override
  String settingsLastShort(String date) {
    return 'Último · $date';
  }

  @override
  String get settingsManualBackup => 'Backup manual';

  @override
  String get settingsManualBackupSubtitle =>
      'Exportar ou restaurar o progresso';

  @override
  String get settingsPaceIntense => 'Intenso';

  @override
  String get settingsPaceLight => 'Leve';

  @override
  String get settingsPaceSteady => 'Firme';

  @override
  String get settingsPasteBackupFirst =>
      'Cole o backup na área de transferência primeiro.';

  @override
  String get settingsPlusTeaser => 'Mais espaço para a companhia';

  @override
  String get settingsProgressInCloud => 'Progresso na nuvem';

  @override
  String get settingsProgressRestored => 'Progresso restaurado.';

  @override
  String settingsReminderAt(int hour) {
    return 'Às ${hour}h · toque para mudar';
  }

  @override
  String get settingsRemindersTitle => 'Lembretes';

  @override
  String get settingsReplayIntro => 'Rever introdução';

  @override
  String get settingsReplayIntroSubtitle => 'A apresentação do começo, de novo';

  @override
  String get settingsRestoreFromClipboard =>
      'Restaurar da área de transferência';

  @override
  String get settingsRhythmSubtitle => 'Quantas cenas cabem no seu dia.';

  @override
  String get settingsRhythmTitle => 'Ritmo diário';

  @override
  String get settingsSampleVerse =>
      'No princípio, criou Deus os céus e a terra.';

  @override
  String get settingsSaveName => 'Salvar nome';

  @override
  String settingsSavedInCloud(String date) {
    return 'Salvo na nuvem · $date';
  }

  @override
  String settingsScenes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cenas',
      one: '1 cena',
    );
    return '$_temp0';
  }

  @override
  String settingsScenesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cenas por dia',
      one: '1 cena por dia',
    );
    return '$_temp0';
  }

  @override
  String get settingsSignInAgain =>
      'Entre de novo para sincronizar o progresso.';

  @override
  String get settingsSignOut => 'Sair da conta';

  @override
  String get settingsSignOutFailed => 'Não foi possível sair. Tente de novo.';

  @override
  String get settingsSignOutSubtitle =>
      'Limpa este aparelho · o progresso fica na nuvem';

  @override
  String settingsSignedInAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String get settingsSounds => 'Sons';

  @override
  String get settingsSoundsSubtitle => 'Efeitos nas cenas';

  @override
  String get settingsStreakGoalHint =>
      'Até quantos dias você quer levar sua sequência.';

  @override
  String get settingsStreakGoalLabel => 'Compromisso de sequência';

  @override
  String settingsStudyAttribution(String attribution) {
    return 'Estudo (Strong) — $attribution';
  }

  @override
  String get settingsSubscriptionActive => 'Assinatura ativa';

  @override
  String get settingsSubtitle => 'Conta, aparência e lembretes';

  @override
  String get settingsSupport => 'Ajude a continuar';

  @override
  String get settingsTextSize => 'Tamanho do texto';

  @override
  String get settingsTextSizeHint => 'O versículo abaixo muda junto.';

  @override
  String get settingsThemeAuto => 'Automático';

  @override
  String get settingsThemeCaptionAuto => 'Muda com o horário';

  @override
  String get settingsThemeCaptionDark => 'Sempre escuro';

  @override
  String get settingsThemeCaptionLight => 'Sempre claro';

  @override
  String get settingsThemeCaptionMedium => 'Sempre em meia-luz';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsThemeHint =>
      'Um tema fixo, ou automático conforme o horário.';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeMedium => 'Médio';

  @override
  String get settingsThemeSemantics => 'Tema da tela';

  @override
  String get settingsThemeSemanticsHint => 'Toque ou deslize para escolher';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String settingsUpToDate(String version) {
    return 'Você está na versão mais recente · $version';
  }

  @override
  String get settingsVersion => 'Versão';

  @override
  String get settingsYourName => 'Seu nome';

  @override
  String shellReferralBonus(int count, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Seus convites valeram +$steps passos',
      one: 'Seu convite valeu +$steps passos',
    );
    return '$_temp0';
  }

  @override
  String get shellTogetherSubtitle => 'Companhia · Caravana · Grupos';

  @override
  String get shellTrailsSubtitle => 'O mapa da jornada';

  @override
  String shellWeekTogetherBonus(int steps) {
    return 'A companhia ganhou +$steps passos na jornada';
  }

  @override
  String get splashPreparing => 'Preparando sua jornada…';

  @override
  String get splashSlogan => 'A Bíblia, cena a cena';

  @override
  String get streakDayEmpty => 'sem cena';

  @override
  String get streakDayFrozen => 'protegido pelo gelo';

  @override
  String streakDaySemantics(String day, String status) {
    return '$day: $status';
  }

  @override
  String streakDayTodaySemantics(String day, String status) {
    return 'Hoje, $day: $status';
  }

  @override
  String get streakRepairAction => 'Reparar';

  @override
  String streakRepairBody(int broken, int restored) {
    String _temp0 = intl.Intl.pluralLogic(
      broken,
      locale: localeName,
      other: 'Você tinha $broken dias. Restaure para $restored — 1× neste mês.',
      one: 'Você tinha 1 dia. Restaure para $restored — 1× neste mês.',
    );
    return '$_temp0';
  }

  @override
  String streakRepairCanReturn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias ainda podem voltar',
      one: '1 dia ainda pode voltar',
    );
    return '$_temp0';
  }

  @override
  String streakRepairContinueWith(int count) {
    return 'Continue com $count · 1× neste mês';
  }

  @override
  String get streakRepairDismiss => 'Deixar';

  @override
  String streakRepairDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sequência restaurada · $count dias',
      one: 'Sequência restaurada · 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get streakRepairTitle => 'Reparar sequência';

  @override
  String streakShareDays(int count, int steps, String signature) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '🔥 $count dias no Stway!\n\nEstou aprendendo a Bíblia em cenas curtas — $steps passos até agora.$signature\n\nBaixe o Stway e venha junto.',
      one:
          '🔥 1 dia no Stway!\n\nEstou aprendendo a Bíblia em cenas curtas — $steps passos até agora.$signature\n\nBaixe o Stway e venha junto.',
    );
    return '$_temp0';
  }

  @override
  String streakShareStart(String signature) {
    return '🔥 Comecei a aprender a Bíblia com o Stway.$signature\n\nBaixe o Stway e venha junto.';
  }

  @override
  String streakShareSteps(int steps, String signature) {
    return '🔥 Estou aprendendo a Bíblia no Stway — $steps passos até agora.$signature\n\nBaixe o Stway e venha junto.';
  }

  @override
  String get streakShareSubject => 'Minha sequência no Stway';

  @override
  String get streakShareTooltip => 'Compartilhar sequência';

  @override
  String get strongKindConjunction => 'Conjunção';

  @override
  String get strongKindGreek => 'Grego';

  @override
  String get strongKindHebrew => 'Hebraico';

  @override
  String get strongKindParticle => 'Partícula';

  @override
  String get strongKindPrefix => 'Prefixo';

  @override
  String get strongKindPronoun => 'Pronome';

  @override
  String get strongKindPunctuation => 'Pontuação';

  @override
  String get strongKindSuffix => 'Sufixo';

  @override
  String get strongNoteConjunction =>
      'Conjunção prefixada (vav). O sentido está no verbo ou no nome que ela liga.';

  @override
  String get strongNoteParticle =>
      'Partícula gramatical do sistema STEP, não um número Strong clássico.';

  @override
  String get strongNotePrefix =>
      'Preposição ou artigo inseparável — cola-se à palavra seguinte. Não é verbete do Strong clássico.';

  @override
  String get strongNotePronoun =>
      'Pronome sufixado: quem recebe ou possui o que a palavra diz.';

  @override
  String get strongNotePunctuation =>
      'Marca de leitura do texto hebraico, não uma palavra.';

  @override
  String get strongNoteSuffix =>
      'Terminação gramatical, não um verbete de dicionário.';

  @override
  String get suggestionAuthorEmail => 'E-mail';

  @override
  String get suggestionAuthorEmailHint => 'nome@email.com';

  @override
  String get suggestionAuthorHintContact =>
      'Informe telefone, e-mail ou Instagram.';

  @override
  String get suggestionAuthorHintEmail => 'Confira o e-mail.';

  @override
  String get suggestionAuthorHintInstagram => 'Confira o Instagram.';

  @override
  String get suggestionAuthorHintName =>
      'Escreva o nome — pelo menos 2 letras.';

  @override
  String get suggestionAuthorHintPhone => 'Confira o telefone, com DDD.';

  @override
  String get suggestionAuthorInstagramHint => '@usuario';

  @override
  String get suggestionAuthorName => 'Nome';

  @override
  String get suggestionAuthorNameHint => 'Como a pessoa se apresenta';

  @override
  String get suggestionAuthorPhone => 'Telefone';

  @override
  String get suggestionAuthorSent =>
      'Sugestão enviada. Obrigado por indicar o autor.';

  @override
  String get suggestionAuthorSubtitle => 'Quem ainda falta no mapa?';

  @override
  String get suggestionAuthorTitle => 'Sugerir um autor';

  @override
  String get suggestionHintAntigoTestamento =>
      'Ex.: Salmos, Êxodo, os profetas…';

  @override
  String get suggestionHintNovoTestamento =>
      'Ex.: o Sermão do Monte, Romanos, Atos…';

  @override
  String get suggestionHintOther =>
      'Ex.: um tema, um livro ou uma pergunta que ainda falta…';

  @override
  String get suggestionHintTeologia => 'Ex.: Trindade, hermenêutica, hebraico…';

  @override
  String get suggestionHintVidaCrista =>
      'Ex.: oração, jejum, a história da igreja…';

  @override
  String get suggestionSend => 'Enviar sugestão';

  @override
  String get suggestionSendError => 'Não foi possível enviar. Tente de novo.';

  @override
  String get suggestionSending => 'Enviando…';

  @override
  String get suggestionSignInToSend => 'Entre para enviar a sugestão.';

  @override
  String get suggestionTrailHintBoth => 'Escolha uma área e descreva a trilha.';

  @override
  String get suggestionTrailHintRealm => 'Escolha onde essa trilha encaixa.';

  @override
  String get suggestionTrailHintText =>
      'Escreva a trilha — pelo menos 4 letras.';

  @override
  String get suggestionTrailPlaceholder =>
      'Escolha uma área e descreva a trilha…';

  @override
  String get suggestionTrailRealmLabel => 'Onde encaixa';

  @override
  String get suggestionTrailSent => 'Sugestão enviada. Obrigado.';

  @override
  String get suggestionTrailSubtitle => 'O que ainda falta no mapa?';

  @override
  String get suggestionTrailTextLabel => 'A trilha';

  @override
  String get suggestionTrailTitle => 'Sugerir uma trilha';

  @override
  String tomorrowDayOf(int streak, int goal) {
    return 'Dia $streak de $goal';
  }

  @override
  String tomorrowLine(String title) {
    return 'Amanhã: $title';
  }

  @override
  String get tomorrowNextTrail => 'Próxima trilha';

  @override
  String get tomorrowNextTrailOnMap => 'A próxima trilha já está no mapa.';

  @override
  String get tomorrowSceneWaits => 'A cena espera você.';

  @override
  String get tomorrowSevenDays => 'Sete dias. O hábito pegou.';

  @override
  String get tomorrowStoryContinues => 'A história continua no texto.';

  @override
  String get tomorrowTodayYouSaw => 'Hoje você viu';

  @override
  String tomorrowYesterday(String text) {
    return 'Ontem: $text';
  }

  @override
  String get trailMapCrossing => 'Travessia';

  @override
  String get trailMapLocked => 'Bloqueada';

  @override
  String get trailMapScene => 'Cena';

  @override
  String trailMapSeal(String name) {
    return 'Selo $name';
  }

  @override
  String get trailsAreasHeading => 'As áreas';

  @override
  String get trailsCleared => 'Concluída';

  @override
  String trailsContinueSemantics(String title) {
    return 'Continuar · $title';
  }

  @override
  String get trailsDonateBody =>
      'Uma contribuição voluntária para as próximas trilhas.';

  @override
  String get trailsDonateCta => 'Doar';

  @override
  String get trailsDonateTitle => 'Ajude a continuar';

  @override
  String trailsDoneOfTotal(int done, int total) {
    return '$done de $total';
  }

  @override
  String get trailsDownloading => 'Baixando…';

  @override
  String get trailsEmptyBody =>
      'O currículo baixa na primeira abertura. Se a rede oscilar, toque para tentar de novo.';

  @override
  String get trailsEmptyTitle => 'As cenas ainda não chegaram';

  @override
  String get trailsHorizonBody => 'Novas trilhas estão sendo preparadas.';

  @override
  String get trailsHorizonEyebrow => 'No horizonte';

  @override
  String get trailsInProgress => 'Em andamento';

  @override
  String trailsLabeledScenesOf(String label, int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$label · $done de $total cenas',
      one: '$label · $done de 1 cena',
    );
    return '$_temp0';
  }

  @override
  String get trailsLearnMore => 'Saiba mais';

  @override
  String trailsModeAllSealed(String mode) {
    return '$mode concluída · os três modos desta trilha estão selados';
  }

  @override
  String trailsModeChip(String mode) {
    return 'Modo $mode';
  }

  @override
  String trailsModeCleared(String mode) {
    return '$mode concluída';
  }

  @override
  String trailsModeNextHint(String mode, String next) {
    return '$mode concluída · o próximo modo é $next';
  }

  @override
  String trailsModeReplayHint(String cleared, String active) {
    return '$cleared concluída · progresso abaixo é do modo $active';
  }

  @override
  String trailsModesCleared(String modes) {
    return '$modes concluídas';
  }

  @override
  String trailsRealmOpenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abertas',
      one: '1 aberta',
    );
    return '$_temp0';
  }

  @override
  String trailsRealmTrailCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trilhas',
      one: '1 trilha',
    );
    return '$_temp0';
  }

  @override
  String trailsRealmTrailsDone(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done de $total trilhas',
      one: '$done de 1 trilha',
    );
    return '$_temp0';
  }

  @override
  String trailsScenesOf(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done de $total cenas',
      one: '$done de 1 cena',
    );
    return '$_temp0';
  }

  @override
  String trailsScenesShort(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done/$total cenas',
      one: '$done/1 cena',
    );
    return '$_temp0';
  }

  @override
  String trailsStage(String roman) {
    return 'Etapa $roman';
  }

  @override
  String trailsStreakAtRisk(String countdown) {
    return 'Sequência cai em $countdown';
  }

  @override
  String trailsTrailNumber(String roman) {
    return 'Trilha $roman';
  }

  @override
  String get updateCheckDisabled => 'Checagem desligada.';

  @override
  String get updateCheckFailed => 'Não foi possível verificar agora.';

  @override
  String get updateDefaultMessage =>
      'Uma nova versão do Stway está pronta, com melhorias e correções.';

  @override
  String get updateEyebrow => 'Atualização';

  @override
  String get updateFirebaseUnavailable => 'Firebase indisponível.';

  @override
  String get updateForceTitle => 'Esta versão precisa atualizar';

  @override
  String get updateInStore => 'Na loja';

  @override
  String get updateNoneInCloud => 'Nenhuma versão publicada na nuvem.';

  @override
  String get updateNow => 'Atualizar agora';

  @override
  String get updateSoftTitle => 'Nova versão disponível';

  @override
  String get updateStoreOpenFailed =>
      'Não foi possível abrir a loja. Tente de novo.';

  @override
  String get verseStudyAttribution =>
      'Léxico e texto etiquetado: STEPBible / Tyndale House Cambridge (CC BY 4.0). Referências cruzadas: openbible.info (CC BY). Definições traduzidas automaticamente para português.';

  @override
  String get verseStudyCopied => 'Copiado';

  @override
  String get verseStudyCrossRefs => 'Referências cruzadas';

  @override
  String get verseStudyDefinition => 'Definição';

  @override
  String get verseStudyEmptyBody =>
      'O léxico Strong, a gramática e cada vez que ela aparece nas Escrituras abrem aqui.';

  @override
  String get verseStudyEmptyTitle => 'Toque numa palavra original';

  @override
  String get verseStudyEyebrow => 'Estudar';

  @override
  String get verseStudyFirst => 'primeira';

  @override
  String get verseStudyGoToText => 'Ir para o texto';

  @override
  String get verseStudyInThisBook =>
      'Neste livro — as aparições perto deste versículo.';

  @override
  String get verseStudyInThisVerse => 'Neste versículo';

  @override
  String get verseStudyLast => 'última';

  @override
  String get verseStudyLemma => 'Lema';

  @override
  String get verseStudyLoadFailed => 'Não foi possível carregar o estudo.';

  @override
  String get verseStudyLoading => 'Abrindo o léxico…';

  @override
  String get verseStudyNeedsRestart =>
      'Feche e abra o app de novo para carregar o estudo.';

  @override
  String get verseStudyNoCrossRefs =>
      'Sem conexões catalogadas para este versículo.';

  @override
  String get verseStudyNoData => 'Sem dados de originais para este versículo.';

  @override
  String get verseStudyNoOtherHits => 'Sem outras ocorrências neste recorte.';

  @override
  String get verseStudyNotLiteral =>
      'A Tradução Brasileira não traz esta forma à letra neste versículo.';

  @override
  String verseStudyOccurrencesIn(String book) {
    return 'Ocorrências em $book';
  }

  @override
  String get verseStudyOnlyHere => 'Só neste versículo no índice.';

  @override
  String get verseStudyOtherBooks => 'Em outros livros';

  @override
  String get verseStudyOtherBooksBody =>
      'A primeira aparição em cada livro onde a palavra é mais frequente.';

  @override
  String get verseStudyParticleNearby =>
      'Esta partícula aparece milhares de vezes. Abaixo, as formas perto deste versículo.';

  @override
  String verseStudyParticleNote(int count) {
    return 'Partícula gramatical · $count formas no cânon. O sentido está no nome ou no verbo que ela acompanha.';
  }

  @override
  String verseStudySpan(int count, String first, String last) {
    return '$count lugares · de $first a $last';
  }

  @override
  String get verseStudyTabLinks => 'Conexões';

  @override
  String verseStudyTabLinksCount(int count) {
    return 'Conexões · $count';
  }

  @override
  String get verseStudyTabUses => 'Usos';

  @override
  String verseStudyTabUsesCount(int count) {
    return 'Usos · $count';
  }

  @override
  String get verseStudyTabWord => 'Palavra';

  @override
  String get verseStudyThisForm => 'Nesta forma';

  @override
  String get verseStudyVerseUnavailable =>
      'Versículo indisponível nesta tradução.';

  @override
  String get waveCta => 'Acenar';

  @override
  String get widgetBehindCaravan =>
      'Ficando para trás na caravana — caminhe hoje';

  @override
  String get widgetGoalDone => 'Meta concluída';

  @override
  String widgetProgressScenes(int done, int goal) {
    String _temp0 = intl.Intl.pluralLogic(
      goal,
      locale: localeName,
      other: '$done/$goal cenas',
      one: '$done/1 cena',
    );
    return '$_temp0';
  }

  @override
  String widgetScenesLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltam $count cenas hoje',
      one: 'Falta 1 cena hoje',
    );
    return '$_temp0';
  }

  @override
  String widgetTodayTitle(String title) {
    return 'Hoje: $title';
  }

  @override
  String widgetTomorrowTitle(String title) {
    return 'Amanhã: $title';
  }

  @override
  String get widgetTrailWaitsTomorrow => 'A trilha espera amanhã';
}
