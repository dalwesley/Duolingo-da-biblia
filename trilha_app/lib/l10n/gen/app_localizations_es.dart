// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get authAccountExists =>
      'Ya existe una cuenta con este correo usando otro método de acceso.';

  @override
  String get authEnableProviders =>
      'Activa los proveedores en Firebase Console: Authentication → Sign-in method → Anonymous y/o Google.';

  @override
  String get authFirebaseNotReady => 'Firebase aún no está listo.';

  @override
  String authGenericError(String code, String message) {
    return 'Error de Auth ($code): $message';
  }

  @override
  String get authInvalidCredential =>
      'Credencial de Google inválida. Registra el SHA-1 de la app en Firebase y descarga google-services.json de nuevo.';

  @override
  String get authLoginInProgress => 'Inicio de sesión en curso.';

  @override
  String get authMissingIdToken =>
      'Google no devolvió idToken. Revisa que el SHA-1 de Play esté en Firebase.';

  @override
  String get authNetworkReset =>
      'Fallo de red al hablar con Firebase Auth (conexión reiniciada). Inténtalo de nuevo en Wi‑Fi estable o datos móviles.';

  @override
  String get authNoInternet =>
      'Sin conexión a internet. Revisa el Wi‑Fi o los datos del aparato.';

  @override
  String get authTooManyRequests =>
      'Demasiados intentos. Espera un poco e inténtalo de nuevo.';

  @override
  String get avatarChangePortrait => 'Cambiar retrato';

  @override
  String get avatarOpenProfile => 'Abrir perfil';

  @override
  String bibleBookFallback(int number) {
    return 'Libro $number';
  }

  @override
  String bibleBookReadSemantics(String book, int read, int total) {
    return '$book, $read de $total capítulos leídos';
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
    return 'Capítulo $chapter, leído';
  }

  @override
  String bibleChaptersReadOf(int read, int total) {
    return '$read de $total leídos';
  }

  @override
  String get bibleDonate => 'Donar';

  @override
  String get bibleHeroContinueReading => 'Continuar lectura';

  @override
  String get bibleHeroFreshBlurb =>
      'Jesús, la Palabra hecha carne — un buen comienzo.';

  @override
  String get bibleHeroStartHere => 'Empieza aquí';

  @override
  String get bibleHeroStartReading => 'Empezar a leer';

  @override
  String get bibleIntroAudience => 'Para quién';

  @override
  String bibleIntroAuthorByTradition(String author) {
    return '$author · según la tradición';
  }

  @override
  String get bibleIntroWhen => 'Cuándo';

  @override
  String get bibleIntroWho => 'Quién';

  @override
  String get bibleNewTestament => 'Nuevo Testamento';

  @override
  String get bibleOldTestament => 'Antiguo Testamento';

  @override
  String get biblePaperAuto => 'Automático';

  @override
  String get biblePaperLight => 'Clara';

  @override
  String get biblePaperNight => 'Noche';

  @override
  String biblePaperSemantics(String paper) {
    return 'Papel $paper';
  }

  @override
  String get biblePaperSepia => 'Sepia';

  @override
  String get biblePickerBackToBooks => 'Volver a los libros';

  @override
  String get biblePickerTitle => 'Ir a';

  @override
  String get bibleReadChapter => 'Leer el capítulo';

  @override
  String bibleReadOf(int read, int total) {
    return '$read de $total';
  }

  @override
  String get bibleReaderChapterDone => 'Capítulo leído';

  @override
  String bibleReaderChapterEnd(String book, int chapter) {
    return 'Fin de $book $chapter';
  }

  @override
  String bibleReaderChapterReadToast(String book, int chapter) {
    return '$book $chapter leído';
  }

  @override
  String get bibleReaderCompleteChapter => 'Terminar capítulo';

  @override
  String get bibleReaderListen => 'Escuchar';

  @override
  String get bibleReaderNextChapter => 'Siguiente capítulo';

  @override
  String bibleReaderOpenFailed(String reference) {
    return 'No se pudo abrir $reference.';
  }

  @override
  String get bibleReaderPaper => 'Papel';

  @override
  String get bibleReaderPrevChapter => 'Capítulo anterior';

  @override
  String get bibleReaderReadTag => 'leído';

  @override
  String get bibleReaderSettings => 'Ajustes de lectura';

  @override
  String get bibleReaderStop => 'Detener';

  @override
  String bibleReaderSubtitle(int chapter, String translation) {
    return 'Capítulo $chapter · $translation';
  }

  @override
  String get bibleReaderTextSize => 'Tamaño del texto';

  @override
  String get bibleReaderUpNext => 'A continuación';

  @override
  String get bibleReaderVersion => 'Versión';

  @override
  String get bibleSavedEmptyBody =>
      'Al leer, toca un versículo y elige Guardar para volver a él después.';

  @override
  String get bibleSavedEmptyTitle => 'Ningún versículo guardado';

  @override
  String get bibleSavedTitle => 'Guardados';

  @override
  String get bibleSearchBookHit => 'Libro';

  @override
  String get bibleSearchButtonHint => 'Buscar libro, versículo o palabra…';

  @override
  String get bibleSearchButtonSemantics => 'Buscar libro o versículo';

  @override
  String get bibleSearchEmpty => 'No se encontraron resultados';

  @override
  String get bibleSearchFieldHint => 'Ej.: Apocalipse, amor, fé…';

  @override
  String get bibleSearchSubtitle => 'Libros y versículos';

  @override
  String get bibleSearchTitle => 'Buscar';

  @override
  String bibleSectionBooksSemantics(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title, $count libros',
      one: '$title, 1 libro',
    );
    return '$_temp0';
  }

  @override
  String get bibleShareAsText => 'Compartir como texto';

  @override
  String get bibleShareImage => 'Compartir imagen';

  @override
  String get bibleSharePreparing => 'Preparando…';

  @override
  String get bibleShareTextFooter => 'Vía Stway';

  @override
  String get bibleShareTitle => 'Compartir versículo';

  @override
  String bibleShareVia(String ref) {
    return '$ref — vía Stway';
  }

  @override
  String get bibleTabReading => 'Lectura';

  @override
  String get bibleTapToClose => 'Toca para cerrar';

  @override
  String get bibleTapToOpen => 'Toca para abrir';

  @override
  String get bibleTitle => 'Biblia';

  @override
  String bibleTranslationSoonBody(String name) {
    return 'Todavía no tenemos $name. Pronto esta traducción llegará a la app. Puedes apoyar el proyecto para ayudar a traer más versiones.';
  }

  @override
  String get bibleTranslationSoonTitle => 'Traducción próximamente';

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
  String get bibleVerseListenFromHere => 'Escuchar desde aquí';

  @override
  String get bibleVerseListenFromHereDetail =>
      'Lectura en voz alta, versículo a versículo';

  @override
  String get bibleVerseSave => 'Guardar';

  @override
  String get bibleVerseSaved => 'Guardado';

  @override
  String bibleVerseSemantics(int number, String text) {
    return 'Versículo $number. $text';
  }

  @override
  String get bibleVerseStudy => 'Estudiar este versículo';

  @override
  String get bibleVerseStudyDetail =>
      'Idiomas originales, Strong, concordancia y referencias';

  @override
  String get canonEvangelhosBlurb => 'Mateo a Juan — la vida de Jesús';

  @override
  String get canonEvangelhosTitle => 'Evangelios';

  @override
  String get canonGeraisBlurb => 'Hebreos a Judas';

  @override
  String get canonGeraisTitle => 'Cartas generales';

  @override
  String get canonHistoriaNtBlurb => 'Hechos de los Apóstoles';

  @override
  String get canonHistoriaNtTitle => 'Historia';

  @override
  String get canonHistoricosBlurb => 'Josué a Ester — la historia de Israel';

  @override
  String get canonHistoricosTitle => 'Históricos';

  @override
  String get canonPaulinasBlurb => 'Romanos a Filemón';

  @override
  String get canonPaulinasTitle => 'Cartas paulinas';

  @override
  String get canonPentateucoBlurb => 'La Ley — Génesis a Deuteronomio';

  @override
  String get canonPentateucoTitle => 'Pentateuco';

  @override
  String get canonPoeticosBlurb => 'Job a Cantares';

  @override
  String get canonPoeticosTitle => 'Poéticos y sabiduría';

  @override
  String get canonProfeciaBlurb => 'Apocalipsis';

  @override
  String get canonProfeciaTitle => 'Profecía';

  @override
  String get canonProfetasMaioresBlurb => 'Isaías a Daniel';

  @override
  String get canonProfetasMaioresTitle => 'Profetas mayores';

  @override
  String get canonProfetasMenoresBlurb => 'Oseas a Malaquías';

  @override
  String get canonProfetasMenoresTitle => 'Profetas menores';

  @override
  String get categoryApocalipseBlurb =>
      'El libro de Apocalipsis, escrito por Juan el Evangelista.';

  @override
  String get categoryApocalipseTitle => 'Apocalipsis o Revelación';

  @override
  String get categoryCristologiaTitle => 'Cristología';

  @override
  String get categoryDiscipuladoTitle => 'Discipulado';

  @override
  String get categoryEpistolasBlurb =>
      'Veintiuna cartas a las primeras iglesias — trece de Pablo y ocho de otros autores.';

  @override
  String get categoryEpistolasTitle => 'Epístolas o cartas apostólicas';

  @override
  String get categoryEvangelhosBlurb =>
      'Nacimiento, ministerio, muerte, resurrección y ascensión de Jesús — Mateo a Juan.';

  @override
  String get categoryEvangelhosTitle => 'Evangelios';

  @override
  String get categoryHermeneuticaTitle => 'Hermenéutica';

  @override
  String get categoryHistoriaIgrejaTitle => 'Historia de la Iglesia';

  @override
  String get categoryHistoricosAtBlurb =>
      'La historia de Israel desde la conquista de la Tierra Prometida hasta el exilio babilónico.';

  @override
  String get categoryHistoricosAtTitle => 'Libros históricos';

  @override
  String get categoryHistoricosNtBlurb =>
      'Hechos de los Apóstoles — el derramamiento del Espíritu y la expansión del Evangelio.';

  @override
  String get categoryHistoricosNtTitle => 'Historia de la Iglesia primitiva';

  @override
  String get categoryIntertestamentarioBlurb =>
      'Los cerca de 400 años de silencio entre el Antiguo y el Nuevo Testamento.';

  @override
  String get categoryIntertestamentarioTitle => 'Período intertestamentario';

  @override
  String get categoryLinguasTitle => 'Lenguas originales';

  @override
  String get categoryOracaoTitle => 'Oración';

  @override
  String get categoryPentateucoBlurb =>
      'Los cinco primeros libros de la Biblia — la Torá, el Libro de la Ley, en orden cronológico.';

  @override
  String get categoryPentateucoTitle => 'Pentateuco';

  @override
  String get categoryPoeticosBlurb =>
      'Poesía, sabiduría, proverbios y cánticos — organizados por relevancia.';

  @override
  String get categoryPoeticosTitle => 'Libros poéticos';

  @override
  String get categoryProfetasMaioresBlurb =>
      'Isaías a Daniel — las obras más extensas entre los escritos proféticos.';

  @override
  String get categoryProfetasMaioresTitle => 'Profetas mayores';

  @override
  String get categoryProfetasMenoresBlurb =>
      'Oseas a Malaquías — doce libros; el nombre se refiere a la extensión, no a la importancia.';

  @override
  String get categoryProfetasMenoresTitle => 'Profetas menores';

  @override
  String get categorySistematicaTitle => 'Sistemática y dogmática';

  @override
  String get celebrationBackHome => 'Volver al inicio';

  @override
  String get celebrationBackToMap => 'Volver al mapa';

  @override
  String celebrationCommitmentBeyond(int goal) {
    return 'Más allá del compromiso de $goal días.';
  }

  @override
  String celebrationCommitmentDone(int goal) {
    return '¡Compromiso de $goal días cumplido!';
  }

  @override
  String celebrationCommitmentLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count días para tu compromiso.',
      one: 'Falta 1 día para tu compromiso.',
    );
    return '$_temp0';
  }

  @override
  String get celebrationEchoKicker => 'Hoy viste';

  @override
  String get celebrationHelpContinue => 'Ayuda a continuar';

  @override
  String get celebrationInviteSubtitle =>
      'Un compañero. Sin ranking — solo presencia.';

  @override
  String get celebrationInviteTitle => 'Una compañía en la ruta';

  @override
  String celebrationModeDone(String mode) {
    return 'Modo $mode completado';
  }

  @override
  String celebrationModeRetryPrompt(String mode, String subtitle) {
    return '¿Qué tal responder de nuevo en $mode? $subtitle';
  }

  @override
  String celebrationModeReviewCta(String mode) {
    return 'Repasa una escena en $mode';
  }

  @override
  String celebrationModeSwitchCta(String mode) {
    return 'Cambia a $mode';
  }

  @override
  String celebrationModeTryCta(String mode) {
    return 'Intenta en $mode';
  }

  @override
  String celebrationModeTryPrompt(String mode) {
    return '¿Quieres intentar las preguntas de esta escena en $mode?';
  }

  @override
  String celebrationSceneDoneIn(String mode) {
    return 'Escena completada en $mode';
  }

  @override
  String get celebrationSealKicker => 'Encuentro';

  @override
  String get celebrationStatAccuracy => 'Aciertos';

  @override
  String get celebrationStatDay => 'Día';

  @override
  String get celebrationStatDays => 'Días';

  @override
  String get celebrationStatSteps => 'Pasos';

  @override
  String celebrationStreakPlusDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+1 día · racha de $count días',
      one: '+1 día · racha de 1 día',
    );
    return '$_temp0';
  }

  @override
  String get celebrationStreakStarted => 'Tu racha empezó hoy.';

  @override
  String get celebrationTomorrowKicker => 'Mañana';

  @override
  String get chestBencaoMessage =>
      '\"Jehová te bendiga y te guarde\" — Números 6:24.';

  @override
  String get chestBencaoTitle => 'Bendición rara';

  @override
  String get chestDailyTitle => 'Cofre del día';

  @override
  String get chestGraoMessage => 'Pequeño hoy, semilla de algo mayor mañana.';

  @override
  String get chestGraoTitle => 'Grano de trigo';

  @override
  String get chestGuardadaMessage =>
      'Este momento vale un versículo guardado en el corazón hoy.';

  @override
  String get chestGuardadaTitle => 'Palabra guardada';

  @override
  String get chestLampadaMessage =>
      '\"Lámpara a mis pies es tu palabra\" — Salmos 119:105.';

  @override
  String get chestLampadaTitle => 'Lámpara encendida';

  @override
  String get chestLocked => 'Completa la escena de hoy para abrirlo';

  @override
  String get chestLockedShort => 'Cerrado';

  @override
  String get chestMapaMessage =>
      'Una curiosidad guardada: cada capítulo leído suma en tu ruta.';

  @override
  String get chestMapaTitle => 'Mapa del día';

  @override
  String get chestOpen => 'Abrir el cofre';

  @override
  String get chestOpenShort => 'Abrir';

  @override
  String get chestOpened => 'Abierto';

  @override
  String get chestOpening => 'Abriendo…';

  @override
  String get chestPassoMessage =>
      'Un día más caminando — eso es lo que forma a un peregrino.';

  @override
  String get chestPassoTitle => 'Paso firme';

  @override
  String get chestReady => 'Tu recompensa de hoy está lista';

  @override
  String get chestReadyShort => 'Listo para abrir';

  @override
  String get chestRevealStarts => 'La revelación empieza ahora.';

  @override
  String get chestRewards => 'Recompensas';

  @override
  String get chestSheetTitle => 'La racha de hoy guarda una recompensa.';

  @override
  String chestTierToday(String tier) {
    return '$tier de hoy';
  }

  @override
  String get chestVeryRare => 'Rarísimo';

  @override
  String get chestVozMessage =>
      'Tu racha ya habla más alto que cualquier palabra.';

  @override
  String get chestVozTitle => 'Voz de la caravana';

  @override
  String get comebackEyebrow => 'El peregrino';

  @override
  String comebackSubtitle(String name, int bonus) {
    return '$name, la ruta te espera. Una escena retoma tu racha y te da +$bonus pasos de bienvenida.';
  }

  @override
  String comebackSubtitleGap(String name, int count, int bonus) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$name, llevas $count días sin una escena. Basta con una — y ganas +$bonus pasos de bienvenida.',
      one:
          '$name, llevas 1 día sin una escena. Basta con una — y ganas +$bonus pasos de bienvenida.',
    );
    return '$_temp0';
  }

  @override
  String get comebackTitle => 'Tu racha te espera';

  @override
  String get commonActive => 'Activo';

  @override
  String get commonBack => 'Volver';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonCollect => 'Recoger';

  @override
  String get commonComingSoon => 'Próximamente';

  @override
  String get commonContinue => 'Continuar';

  @override
  String commonDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get commonGotIt => 'Entendido';

  @override
  String get commonModule => 'Módulo';

  @override
  String get commonNextScene => 'Siguiente escena';

  @override
  String get commonNotNow => 'Ahora no';

  @override
  String get commonOff => 'Desactivado';

  @override
  String commonPlusSteps(int count) {
    return '+$count pasos';
  }

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonScene => 'Escena';

  @override
  String commonScenes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escenas',
      one: '1 escena',
    );
    return '$_temp0';
  }

  @override
  String get commonSendWhatsApp => 'Enviar por WhatsApp';

  @override
  String get commonShare => 'Compartir';

  @override
  String get commonSkip => 'Omitir';

  @override
  String get commonStart => 'Empezar';

  @override
  String commonSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
    );
    return '$_temp0';
  }

  @override
  String get commonToday => 'Hoy';

  @override
  String get commonTrail => 'Ruta';

  @override
  String get commonTryAgain => 'Intentar de nuevo';

  @override
  String get commonYou => 'Tú';

  @override
  String get companionAwaitingCode =>
      'Esperando que alguien entre con el código';

  @override
  String companionDaysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días caminando juntos',
      one: '1 día caminando juntos',
    );
    return '$_temp0';
  }

  @override
  String companionDaysWithoutStudy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días atrás en la caminata',
      one: '1 día atrás en la caminata',
    );
    return '$_temp0';
  }

  @override
  String get companionDelayDustyHeadline => 'Tu falta en la ruta';

  @override
  String get companionDelayDustyInsight => 'El polvo ya cubrió el camino';

  @override
  String get companionDelayFreshHeadline => 'Quedándose atrás';

  @override
  String get companionDelayFreshInsight =>
      'Se está quedando atrás en nuestra caminata';

  @override
  String get companionDelayLostHeadline => 'Todavía hay lugar a mi lado';

  @override
  String get companionDelayLostInsight =>
      'Pero se puede retomar nuestra caminata';

  @override
  String get companionErrorAlreadyHave => 'Ya tienes una compañía.';

  @override
  String get companionErrorCreateInvite => 'No se pudo crear la invitación.';

  @override
  String get companionErrorInvalidCode =>
      'Código inválido o la compañía ya está completa.';

  @override
  String get companionErrorSignInCreate =>
      'Entra con Google para crear una compañía.';

  @override
  String get companionErrorSignInJoin =>
      'Entra con Google para unirte a una compañía.';

  @override
  String get companionErrorSignInWave =>
      'Entra en la cuenta para saludar en la app.';

  @override
  String get companionErrorWave => 'No se pudo enviar el saludo.';

  @override
  String get companionFallbackName => 'Compañero';

  @override
  String get companionNextStepTogether => '¿Damos el próximo paso juntos?';

  @override
  String companionPartnerAway(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Hace $days días sin estudiar — la ruta echa de menos a $name',
      one: 'Hace 1 día sin estudiar — la ruta echa de menos a $name',
    );
    return '$_temp0';
  }

  @override
  String companionPartnerAwayAfterStep(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return 'Ya diste tu paso — $name está a $_temp0 atrás';
  }

  @override
  String companionPartnerNotYet(String name) {
    return 'Ya diste tu paso — $name aún no apareció';
  }

  @override
  String get companionPresetComeBack =>
      'Te estoy esperando para limpiar la ruta';

  @override
  String get companionPresetMissed => 'Te eché de menos en la ruta';

  @override
  String get companionPresetOnTrail => 'Te estoy esperando en la ruta';

  @override
  String get companionPresetResume => 'Se puede retomar — estoy aquí';

  @override
  String get companionPresetStepCome => 'Di mi paso hoy. ¿Vienes?';

  @override
  String get companionPresetWalkToday => 'Vamos a caminar juntos hoy';

  @override
  String get companionPresetYoursNext => 'Ya di mi paso — falta el tuyo';

  @override
  String companionShareDefault(String name) {
    return 'Hola $name 👋\n¡Ya di mis pasos de hoy en Stway — te estoy esperando!\n¿Vienes?';
  }

  @override
  String companionShareDusty(String name, int days) {
    return 'Hola $name 👋\nHace $days días que no caminamos juntos en Stway.\nEl camino sigue abierto — ¡te estoy esperando!\n¿Vienes?';
  }

  @override
  String get companionShareFallbackName => 'tú';

  @override
  String companionShareFresh(String name) {
    return 'Hola $name 👋\nTe eché de menos en nuestra caminata en Stway.\n¡Ya di mis pasos de hoy y te estoy esperando!\n¿Vienes?';
  }

  @override
  String companionShareLost(String name, int days) {
    return 'Hola $name 👋\n¡Todavía hay lugar a mi lado!\nHace $days días que no caminamos juntos en Stway.\n\nPero se puede retomar — ya di mis pasos de hoy.\n¿Vienes?';
  }

  @override
  String get companionSheetEyebrow => 'Compañía';

  @override
  String companionSheetFormedBody(int steps) {
    return 'Ahora caminan juntos.\nCompleten los 7 días de la semana: +$steps pasos en el camino para los dos.';
  }

  @override
  String companionSheetFormedBodyNamed(String name, int steps) {
    return 'Ahora tú y $name caminan juntos.\nCompleten los 7 días de la semana: +$steps pasos en el camino para los dos.';
  }

  @override
  String get companionSheetFormedCta => 'Caminar juntos';

  @override
  String get companionSheetFormedTitle => 'Compañía formada';

  @override
  String get companionSheetInviteConfirmSubtitle =>
      'Alguien te invitó a caminar juntos.\nUn toque, sin escribir código.';

  @override
  String get companionSheetInviteConfirmTitle => 'Invitación de compañía';

  @override
  String get companionSheetInviteCta => 'Invitar a un compañero';

  @override
  String companionSheetPromptBody(int steps) {
    return 'Un compañero. Completen juntos los 7 días de la semana: los dos ganan +$steps pasos en el camino.';
  }

  @override
  String companionSheetPromptBodyTomorrow(String scene) {
    return 'Mañana: $scene. Invita a alguien para llegar juntos.';
  }

  @override
  String get companionSheetPromptTitle => 'Invita a alguien a caminar';

  @override
  String get companionWalkedTogetherToday => 'Caminaron juntos hoy';

  @override
  String companionWaveFor(String name) {
    return 'Ya diste tu paso — saluda a $name';
  }

  @override
  String get companionWeekClosed => 'Semana cerrada juntos';

  @override
  String companionWeekDays(int count) {
    return '$count de 7 días juntos esta semana';
  }

  @override
  String companionYourTurn(String name) {
    return '$name ya caminó — te toca';
  }

  @override
  String cornerAcceptedBy(String name) {
    return '$name aceptó el desafío';
  }

  @override
  String get cornerActionFailed => 'No se pudo completar. Inténtalo de nuevo.';

  @override
  String get cornerArrivedMark => 'Llegó';

  @override
  String cornerBoardEmptyBody(int count) {
    return 'En la caravana, abre a alguien en la misma escena e invítalo al desafío. Quien llegue hasta el domingo gana +$count pasos.';
  }

  @override
  String get cornerBoardEmptyTitle => 'Ningún desafío aún';

  @override
  String get cornerBoardFilterEmpty => 'Ninguno aún';

  @override
  String get cornerBoardIdle =>
      'Ningún desafío esta semana. Invita a alguien de la caravana.';

  @override
  String get cornerBoardOpenCaravan => 'Ver la caravana';

  @override
  String get cornerBurstAccepted => 'Desafío aceptado';

  @override
  String get cornerBurstLeft => 'Saliste del desafío';

  @override
  String get cornerBurstSent => 'Invitación enviada';

  @override
  String get cornerBusyAccept =>
      'Ya tienes un desafío. Termínalo o sal de él para aceptar.';

  @override
  String get cornerBusyWeek => 'Ya tienes un desafío esta semana.';

  @override
  String get cornerCancelled => 'Desafío cancelado';

  @override
  String cornerChallengeWith(String name) {
    return 'Desafío con $name';
  }

  @override
  String get cornerClosedChapter => 'Cerrados';

  @override
  String get cornerClosesToday => 'Cierra hoy';

  @override
  String get cornerCtaInvite => 'Invitar al desafío';

  @override
  String cornerDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count días',
      one: 'Falta 1 día',
    );
    return '$_temp0';
  }

  @override
  String get cornerDeadline => 'Hasta el domingo.';

  @override
  String get cornerDeclinedAnon => 'La invitación no fue aceptada.';

  @override
  String cornerDeclinedBy(String name) {
    return '$name no aceptó esta vez.';
  }

  @override
  String get cornerDifferentScene => 'No están en la misma escena.';

  @override
  String get cornerDifferentTrail => 'No están en la misma ruta.';

  @override
  String get cornerHoldAccept => 'Mantén pulsado para aceptar';

  @override
  String get cornerHoldInvite => 'Mantén pulsado para invitar';

  @override
  String cornerIncomingFrom(String name) {
    return '$name te invitó a esta escena.';
  }

  @override
  String get cornerIncomingFromAnon => 'Alguien te invitó a esta escena.';

  @override
  String get cornerIncomingTitle => 'Invitación al desafío';

  @override
  String cornerInviteBody(String name, int count) {
    return 'Tú y $name hacen esta escena hasta el domingo.\n+$count pasos para cada uno que llegue.';
  }

  @override
  String cornerInviteBodyAnon(int count) {
    return 'La misma escena hasta el domingo.\n+$count pasos para cada uno que llegue.';
  }

  @override
  String cornerInviteTitle(String mission) {
    return 'Desafío: $mission';
  }

  @override
  String get cornerKicker => 'Desafío';

  @override
  String get cornerLeftMark => 'Salió';

  @override
  String get cornerNeedsCloud =>
      'Inicia sesión con Google para invitar a alguien.';

  @override
  String get cornerNoCorner => 'Ninguna escena en común para el desafío.';

  @override
  String get cornerNoneHeadline => 'Nadie llegó esta vez';

  @override
  String get cornerNoneLine => 'El desafío cerró el domingo.';

  @override
  String get cornerOnTheWay => 'En camino';

  @override
  String get cornerOtherPerson => 'La otra persona';

  @override
  String get cornerOtherPersonLower => 'la otra persona';

  @override
  String cornerRecordArrived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completadas',
      one: '1 completada',
    );
    return '$_temp0';
  }

  @override
  String get cornerRecordChapter => 'Desafíos';

  @override
  String cornerRecordTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lado a lado',
      one: '1 lado a lado',
    );
    return '$_temp0';
  }

  @override
  String cornerResultLeft(int count) {
    return 'Saliste · sin los +$count pasos';
  }

  @override
  String cornerResultNone(String name) {
    return 'Con $name · nadie llegó';
  }

  @override
  String cornerResultTheyArrived(String name) {
    return '$name llegó · tú no llegaste';
  }

  @override
  String cornerResultTheyLeftMissed(String name) {
    return '$name salió · tú no llegaste';
  }

  @override
  String cornerResultTogether(String name) {
    return 'Con $name · llegaron los dos';
  }

  @override
  String cornerResultWon(String name, int count) {
    return 'Con $name · +$count pasos';
  }

  @override
  String cornerSameStretch(int count) {
    return 'La misma escena hasta el domingo. +$count pasos para cada uno que llegue.';
  }

  @override
  String get cornerSendFailed =>
      'No se pudo enviar la invitación. Inténtalo de nuevo.';

  @override
  String get cornerSomeone => 'Alguien';

  @override
  String get cornerStripIdle => 'Ninguno esta semana';

  @override
  String cornerStripInvitedYou(String name) {
    return '$name te invitó';
  }

  @override
  String cornerStripLost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perdidos',
      one: '1 perdido',
    );
    return '$_temp0';
  }

  @override
  String cornerStripWaiting(String name) {
    return 'Esperando a $name';
  }

  @override
  String cornerStripWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ganados',
      one: '1 ganado',
    );
    return '$_temp0';
  }

  @override
  String get cornerTallyLost => 'Perdió';

  @override
  String get cornerTallyTogether => 'Juntos';

  @override
  String get cornerTallyWon => 'Ganó';

  @override
  String cornerTheyAhead(String name) {
    return '$name ya llegó. Faltas tú.';
  }

  @override
  String cornerTheyArrived(String name) {
    return '$name llegó';
  }

  @override
  String cornerTheyLeft(String name) {
    return '$name salió. Todavía puedes llegar.';
  }

  @override
  String cornerTheyLeftClosed(String name) {
    return '$name salió del desafío.';
  }

  @override
  String get cornerTogether => 'Llegaron juntos';

  @override
  String get cornerTogetherLine => 'Los dos hicieron la escena a tiempo.';

  @override
  String cornerWaitingArrival(String name) {
    return 'Llegaste · esperando a $name.';
  }

  @override
  String cornerWaitingOn(String name) {
    return 'Esperando que $name acepte.';
  }

  @override
  String get cornerWaitingOnAnon => 'Esperando que acepte.';

  @override
  String get cornerWalk => 'Haz la escena';

  @override
  String get cornerWhisperEach => 'Cada escena hecha cuenta.';

  @override
  String get cornerWhisperTogether => 'Escenas hechas lado a lado.';

  @override
  String cornerWithPeer(String name) {
    return 'Con $name · hasta el domingo';
  }

  @override
  String get cornerWithdraw => 'Salir del desafío';

  @override
  String cornerWithdrawBody(String name, int count) {
    return '$name sigue y todavía puede llegar. Te quedas sin los +$count pasos.';
  }

  @override
  String get cornerWithdrawConfirm => 'Salir';

  @override
  String cornerWithdrawPending(String name) {
    return 'La invitación desaparece para $name.';
  }

  @override
  String get cornerWithdrawTitle => '¿Salir del desafío?';

  @override
  String get cornerYouArrived => 'Llegaste';

  @override
  String get cornerYouLeft => 'Saliste del desafío.';

  @override
  String get crossingChip => 'Travesía';

  @override
  String dustAwayManyFreeze(String name, int daysAway) {
    String _temp0 = intl.Intl.pluralLogic(
      daysAway,
      locale: localeName,
      other: '$daysAway días sin caminar',
      one: '1 día sin caminar',
    );
    return '$name, $_temp0. El hielo aún cubre 1 falta — retoma la caminata.';
  }

  @override
  String dustAwayManyNoFreeze(String name, int daysAway) {
    String _temp0 = intl.Intl.pluralLogic(
      daysAway,
      locale: localeName,
      other: '$daysAway días sin caminar',
      one: '1 día sin caminar',
    );
    return '$name, $_temp0. Una escena reinicia el camino.';
  }

  @override
  String dustAwayNoStreak(String name) {
    return '$name, la ruta espera. Una escena basta para retomar el camino.';
  }

  @override
  String dustAwayStreak(String name, int streak) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '$streak días de racha esperan',
      one: '1 día de racha espera',
    );
    return '$name, $_temp0. Una escena y retomas.';
  }

  @override
  String dustAwayTwoFreeze(String name) {
    return '$name, dos días sin caminar. El hielo aún puede salvar 1 día — vuelve hoy.';
  }

  @override
  String dustAwayTwoNoFreeze(String name) {
    return '$name, dos días sin caminar. Una escena y vuelves al camino.';
  }

  @override
  String get dustCanReturn => 'Se puede volver';

  @override
  String get dustComeBackToday => 'Vuelve hoy';

  @override
  String get dustContinueWhere => 'Continúa donde lo dejaste';

  @override
  String get dustDayEnding => 'El día se acaba';

  @override
  String dustEveningFreeze1(String name, String countdown) {
    return '$name, el día cierra. Faltan $countdown — camina, o el hielo cubre 1 día.';
  }

  @override
  String dustEveningFreeze2(String countdown) {
    return 'Últimas $countdown. Sigue la caminata — el hielo aún cubre 1 día.';
  }

  @override
  String dustEveningNoFreeze2(String countdown) {
    return 'La noche cierra. Faltan $countdown — sigue la caminata ahora.';
  }

  @override
  String get dustFewHours => 'Pocas horas';

  @override
  String get dustHeroGapFreeze =>
      'Ayer quedó vacío. Haz la escena hoy — el hielo aún salva 1 día.';

  @override
  String get dustHeroGapNoFreeze =>
      'Ayer quedó vacío. Haz la escena hoy para no perder la racha.';

  @override
  String dustHeroRiskFreeze(int streak, String countdown) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other:
          'Faltan $countdown para que caiga la racha de $streak días. Haz la escena hoy — el hielo aún salva 1 día.',
      one:
          'Faltan $countdown para que caiga la racha. Haz la escena hoy — el hielo aún salva 1 día.',
      zero:
          'Faltan $countdown para que caiga la racha. Haz la escena hoy — el hielo aún salva 1 día.',
    );
    return '$_temp0';
  }

  @override
  String dustHeroRiskNoFreeze(int streak, String countdown) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other:
          'Faltan $countdown para que caiga la racha de $streak días. Haz la escena hoy.',
      one: 'Faltan $countdown para que caiga la racha. Haz la escena hoy.',
      zero: 'Faltan $countdown para que caiga la racha. Haz la escena hoy.',
    );
    return '$_temp0';
  }

  @override
  String get dustNextSceneWaits => 'La próxima escena espera';

  @override
  String get dustOneDay => 'Un día';

  @override
  String dustRiskBodyFreeze1(String name, String countdown) {
    return '$name · faltan $countdown. Una escena protege la racha — el hielo cubre 1 día.';
  }

  @override
  String dustRiskBodyFreeze3(String countdown) {
    return 'Faltan $countdown. Sigue la caminata — el hielo cubre 1 día.';
  }

  @override
  String dustRiskBodyNoFreeze1(String name, String countdown) {
    return '$name · sin hielo. Faltan $countdown. Una escena y te quedas.';
  }

  @override
  String dustRiskBodyNoFreeze2(int streak, String countdown) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '$streak días en riesgo. Faltan $countdown — camina ahora.',
      one: '1 día en riesgo. Faltan $countdown — camina ahora.',
    );
    return '$_temp0';
  }

  @override
  String dustRiskBodyNoFreeze3(String countdown) {
    return 'Sin hielo. Faltan $countdown — camina ahora.';
  }

  @override
  String dustRiskBodyStreak(int streak, String countdown) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: 'Racha de $streak días aún en juego. Faltan $countdown.',
      one: 'Racha de 1 día aún en juego. Faltan $countdown.',
    );
    return '$_temp0';
  }

  @override
  String get dustSceneToday => 'Una escena hoy';

  @override
  String get dustSceneTodayWaits => 'La escena de hoy espera';

  @override
  String get dustSceneWaits => 'La escena espera';

  @override
  String get dustStillTime => 'Aún hay tiempo';

  @override
  String get dustStreakWaits => 'La racha espera';

  @override
  String get dustTrailWaits => 'La ruta espera';

  @override
  String get dustTwoDays => 'Dos días';

  @override
  String get dustUiDetail2 => 'Sigue la caminata · una escena basta';

  @override
  String get dustUiDetail3 => 'La racha espera · camina hoy';

  @override
  String get dustUiFreeze1 => 'Racha en riesgo · el hielo aún cubre 1 día';

  @override
  String get dustUiFreeze2 => 'Aún hay tiempo · hielo listo';

  @override
  String get dustUiFreeze3 => 'Camina hoy · el hielo cubre 1 falta';

  @override
  String get dustUiNoFreeze1 => 'Racha en riesgo · camina ahora';

  @override
  String get dustUiNoFreeze2 => 'Sin hielo · una escena protege';

  @override
  String get dustUiNoFreeze3 => 'La racha espera · una escena alcanza';

  @override
  String get entryMissionDorAnsia01CentralInsight =>
      'El tesoro arrastra el corazón';

  @override
  String get entryMissionDorAnsia01HookNote =>
      'El cuidado del Padre es el argumento contra la ansiedad — no la ausencia de necesidad.';

  @override
  String get entryMissionDorAnsia01Intro =>
      'Donde está el tesoro, está el corazón. Jesús une a Mammón y el mañana.';

  @override
  String get entryMissionDorAnsia01Objective =>
      'Ver cómo Jesús une tesoro, señorío y ansiedad.';

  @override
  String get entryMissionDorAnsia01Title => 'Tesoros y ansiedad';

  @override
  String get entryMissionDorAnsia02CentralInsight =>
      'Cristo basta en el hambre y la hartura';

  @override
  String get entryMissionDorAnsia02HookNote =>
      'El contentamiento de Pablo no es estoicismo: es Cristo en el hambre y la hartura.';

  @override
  String get entryMissionDorAnsia02Intro =>
      'Pablo aprendió a estar contento en toda suerte — en Cristo.';

  @override
  String get entryMissionDorAnsia02Objective =>
      'Cambiar la ansiedad del tener por el contentamiento en Cristo.';

  @override
  String get entryMissionDorAnsia02Title => 'Contentamiento';

  @override
  String get entryMissionDorAnsia03CentralInsight => 'Hay pastor en el valle';

  @override
  String get entryMissionDorAnsia03HookNote =>
      'El pastor guía — incluso en el valle. Lo que se va no es la lucha; es el miedo y la sensación de soledad.';

  @override
  String get entryMissionDorAnsia03Intro =>
      'Nada me faltará — el Salmo 23 es confianza, no magia.';

  @override
  String get entryMissionDorAnsia03Objective =>
      'Leer el Salmo 23 como cuidado, no como amuleto.';

  @override
  String get entryMissionDorAnsia03Title => 'El Señor es mi pastor';

  @override
  String get entryMissionDorAnsia04CentralInsight => 'El pan es de hoy';

  @override
  String get entryMissionDorAnsia04HookNote =>
      'Jesús enseña a pedir el día — no el stock. El Reino viene antes del pan.';

  @override
  String get entryMissionDorAnsia04Intro =>
      'Pedir el pan de cada día es lo contrario de anticipar el mes entero.';

  @override
  String get entryMissionDorAnsia04Objective =>
      'Orar el día, no el censo del miedo.';

  @override
  String get entryMissionDorAnsia04Title => 'Padre nuestro';

  @override
  String get entryMissionDorAnsia05CentralInsight =>
      'La herencia está guardada';

  @override
  String get entryMissionDorAnsia05HookNote =>
      'La esperanza no niega el sufrimiento. Lo ancla en la resurrección. Continúa en el Sermón del Monte.';

  @override
  String get entryMissionDorAnsia05Intro =>
      'Pedro ancla a los que sufren en una herencia guardada — después, el canon.';

  @override
  String get entryMissionDorAnsia05Objective =>
      'Salir de la ruta de dolor al currículo: Sermón del Monte.';

  @override
  String get entryMissionDorAnsia05Title => 'Esperanza viva';

  @override
  String get entryMissionDorRecome01CentralInsight =>
      'Dios todavía pregunta dónde estás';

  @override
  String get entryMissionDorRecome01HookNote =>
      'El primer movimiento después de la caída es Dios buscando — no el humano escondiéndose con éxito.';

  @override
  String get entryMissionDorRecome01Intro =>
      'La desconfianza rompe la comunión — y aun así Dios pregunta.';

  @override
  String get entryMissionDorRecome01Objective =>
      'Ver la caída como ruptura, no como el fin de la conversación.';

  @override
  String get entryMissionDorRecome01Title => 'La caída';

  @override
  String get entryMissionDorRecome02CentralInsight =>
      'Hay semilla después de la puerta';

  @override
  String get entryMissionDorRecome02EchoQuestion =>
      'Él preguntó. ¿Y después de la respuesta, se acabó la historia?';

  @override
  String get entryMissionDorRecome02HookNote =>
      'En el mismo capítulo de la expulsión, Dios habla de una semilla. El juicio no cancela la historia.';

  @override
  String get entryMissionDorRecome02Intro =>
      'El pecado tiene costo. La promesa no desaparece.';

  @override
  String get entryMissionDorRecome02Objective =>
      'Leer consecuencia y promesa en el mismo texto.';

  @override
  String get entryMissionDorRecome02Title => 'Consecuencias';

  @override
  String get entryMissionDorRecome03CentralInsight =>
      'Recomenzar es pacto, no borrar';

  @override
  String get entryMissionDorRecome03EchoQuestion =>
      'Hay semilla después de la puerta. ¿El mundo recomienza borrando el pasado?';

  @override
  String get entryMissionDorRecome03HookNote =>
      'El mundo recomienza bajo pacto, no bajo amnesia. El arco recuerda a Dios — y a nosotros.';

  @override
  String get entryMissionDorRecome03Intro =>
      'Juicio y recomienzo caben en el mismo Dios.';

  @override
  String get entryMissionDorRecome03Objective =>
      'Ver el diluvio como juicio que guarda un resto.';

  @override
  String get entryMissionDorRecome03Title => 'Diluvio';

  @override
  String get entryMissionDorRecome04CentralInsight =>
      'El recomienzo camina hacia fuera';

  @override
  String get entryMissionDorRecome04EchoQuestion =>
      'Recomenzar es pacto. ¿Babel se arregla con otra torre?';

  @override
  String get entryMissionDorRecome04HookNote =>
      'Dios no arregla Babel con otra torre. Llama a una familia para ser bendición.';

  @override
  String get entryMissionDorRecome04Intro =>
      'Salir de la tierra es el gesto del recomienzo que bendice a otros.';

  @override
  String get entryMissionDorRecome04Objective =>
      'Unir recomienzo a llamado, no a aislamiento.';

  @override
  String get entryMissionDorRecome04Title => 'Llamado de Abram';

  @override
  String get entryMissionDorRecome05CentralInsight =>
      'Hay consuelo para quien llora de verdad';

  @override
  String get entryMissionDorRecome05EchoQuestion =>
      'El recomienzo camina hacia fuera. ¿Quién llora lo que murió encuentra qué en el Reino?';

  @override
  String get entryMissionDorRecome05HookNote =>
      'El Reino no apresura el luto. Consuela. La ruta canónica empieza en Génesis 1–11.';

  @override
  String get entryMissionDorRecome05Intro =>
      'Quien llora lo que murió es bienaventurado. Continúa en Génesis 1–11.';

  @override
  String get entryMissionDorRecome05Objective =>
      'Salir de la ruta de dolor al currículo: Génesis 1–11.';

  @override
  String get entryMissionDorRecome05Title => 'Los que lloran';

  @override
  String get entryTrailAnsiedadeDescription =>
      'Cinco escenas para echar el mañana en el Padre — y seguir en el canon.';

  @override
  String get entryTrailAnsiedadeModuleTitle => 'Echar la ansiedad';

  @override
  String get entryTrailAnsiedadeTitle => 'Ansiedad';

  @override
  String get entryTrailRecomecoDescription =>
      'Cinco escenas de la caída al llamado — y de vuelta a Génesis 1–11.';

  @override
  String get entryTrailRecomecoModuleTitle => 'Del rompimiento al llamado';

  @override
  String get entryTrailRecomecoTitle => 'Recomienzo';

  @override
  String get eraChurchBlurb => 'Hechos, epístolas y la consumación';

  @override
  String get eraChurchTitle => 'Iglesia y cartas';

  @override
  String get eraConquestBlurb => 'Tierra prometida y el ciclo de los jueces';

  @override
  String get eraConquestTitle => 'Conquista y jueces';

  @override
  String get eraDividedBlurb => 'Israel, Judá y la voz de los profetas';

  @override
  String get eraDividedTitle => 'Reinos y profetas';

  @override
  String get eraExileBlurb => 'Babilonia y la esperanza del retorno';

  @override
  String get eraExileTitle => 'Exilio';

  @override
  String get eraExodusBlurb => 'Salida de Egipto, Sinaí y el desierto';

  @override
  String get eraExodusTitle => 'Éxodo y Ley';

  @override
  String get eraGospelsBlurb => 'Los cuatro Evangelios';

  @override
  String get eraGospelsTitle => 'Vida de Jesús';

  @override
  String get eraOriginsBlurb => 'Creación, Diluvio y la familia de Abraham';

  @override
  String get eraOriginsTitle => 'Orígenes y patriarcas';

  @override
  String get eraReturnBlurb => 'Templo, muros y el último de los profetas';

  @override
  String get eraReturnTitle => 'Retorno y restauración';

  @override
  String get eraUnitedBlurb => 'Saúl, David y Salomón';

  @override
  String get eraUnitedTitle => 'Monarquía unida';

  @override
  String get exerciseCheck => 'Comprobar';

  @override
  String get exerciseCueMatch => 'Une cada par.';

  @override
  String get exerciseCueOrder => 'Arma la secuencia.';

  @override
  String get exerciseCueTap => 'Toca el pasaje que responde.';

  @override
  String get exerciseFalse => 'Falso';

  @override
  String get exerciseFalseMark => 'F';

  @override
  String get exerciseHint => 'Pista';

  @override
  String get exerciseHintUsed => 'Pista usada';

  @override
  String get exerciseLabelBridge => 'Puente';

  @override
  String get exerciseLabelClaim => 'Afirmación';

  @override
  String get exerciseLabelPairs => 'Pares';

  @override
  String get exerciseLabelQuestion => 'Pregunta';

  @override
  String get exerciseLabelSequence => 'Secuencia';

  @override
  String get exerciseLabelWord => 'Palabra';

  @override
  String get exerciseMatchPair => 'Empareja';

  @override
  String get exerciseMatchPick => 'Elige';

  @override
  String get exerciseNoteLabel => 'Contexto';

  @override
  String get exerciseTitleChoose => 'Elige la respuesta';

  @override
  String get exerciseTitleComplete => 'Completa el versículo';

  @override
  String get exerciseTitleConnect => 'Conecta los fragmentos';

  @override
  String get exerciseTitleOrder => 'Ordena los hechos';

  @override
  String get exerciseTitleTap => 'Toca la palabra';

  @override
  String get exerciseTitleTrueFalse => 'Juzga el versículo';

  @override
  String get exerciseTrue => 'Verdadero';

  @override
  String get exerciseTrueMark => 'V';

  @override
  String get exerciseTypeBestInterpretation => 'Interpretación';

  @override
  String get exerciseTypeChoice => 'Elige';

  @override
  String get exerciseTypeClassify => 'Clasifica';

  @override
  String get exerciseTypeComplete => 'Completa';

  @override
  String get exerciseTypeConnect => 'Conecta';

  @override
  String get exerciseTypeExplain => 'Explica';

  @override
  String get exerciseTypeFindInText => 'En el texto';

  @override
  String get exerciseTypeInsight => 'Idea clave';

  @override
  String get exerciseTypeMatch => 'Empareja';

  @override
  String get exerciseTypeOrder => 'Ordena';

  @override
  String get exerciseTypeReview => 'Repaso';

  @override
  String get exerciseTypeTap => 'Toca';

  @override
  String get exerciseTypeTextSupported => 'El texto dice';

  @override
  String get exerciseTypeTrueFalse => 'Verdadero / Falso';

  @override
  String get exerciseVerbAnswer => 'Responde';

  @override
  String get exerciseVerbJudge => 'Juzga';

  @override
  String get feedbackAlmost => 'Casi';

  @override
  String get feedbackAnswer => 'Respuesta';

  @override
  String get feedbackCheer1 => 'Eso es.';

  @override
  String get feedbackCheer2 => 'Acertaste.';

  @override
  String get feedbackCheer3 => 'Muy bien.';

  @override
  String get feedbackCheer4 => 'Correcto.';

  @override
  String get feedbackCorrect => 'Acertaste';

  @override
  String feedbackCorrection(String expected, String got) {
    return '$expected, no $got';
  }

  @override
  String get feedbackEndPartial => 'Terminar con pasos parciales';

  @override
  String get feedbackFollow => 'Sigue.';

  @override
  String get feedbackNotYet => 'Todavía no';

  @override
  String get feedbackOutOfLamps => 'Sin lámparas';

  @override
  String get feedbackReadPassage => 'Leer el texto de la escena';

  @override
  String get feedbackReportSent => 'Reporte enviado. Gracias.';

  @override
  String get feedbackReportTooltip => 'Reportar un problema en esta pregunta';

  @override
  String get feedbackRequeueHint =>
      'Inténtalo de nuevo o déjalo para el final de la escena.';

  @override
  String get feedbackRereadHint =>
      'Vuelve a leer el texto e inténtalo de nuevo.';

  @override
  String get feedbackSeeRightWord => 'Mira la palabra correcta';

  @override
  String get feedbackSeeText => 'Míralo en el texto';

  @override
  String get feedbackSkipToEnd => 'Saltar e intentarlo al final';

  @override
  String get feedbackTryAgain => 'Inténtalo de nuevo.';

  @override
  String get groupCallEmpty => 'Nadie de la caravana para invitar ahora.';

  @override
  String groupCallFull(int count) {
    return 'Este grupo ya tiene $count personas.';
  }

  @override
  String get groupCallSubtitle =>
      'La invitación aparece en la app. O envía el enlace por WhatsApp.';

  @override
  String get groupCallTitle => 'Invitar personas';

  @override
  String get groupCaptionNotYet => 'aún no';

  @override
  String get groupCaptionToday => 'hoy';

  @override
  String get groupCreateCta => 'Crear grupo';

  @override
  String groupDayUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'días ',
      one: 'día ',
    );
    return '$_temp0';
  }

  @override
  String groupDaysAway(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días sin estudiar',
      one: '1 día sin estudiar',
    );
    return '$_temp0';
  }

  @override
  String get groupEmptyLeaderBody =>
      'Todos reciben la misma escena, incluso quien aún no llegó a ella en la ruta.';

  @override
  String get groupEmptyLeaderTitle =>
      '¿Qué texto va a estudiar el grupo esta semana?';

  @override
  String groupEmptyMemberBody(String leader) {
    return '$leader elige la escena que el grupo estudia junto.';
  }

  @override
  String get groupEmptyMemberTitle => 'El texto de la semana aún no llegó.';

  @override
  String get groupInviteAccept => 'Aceptar';

  @override
  String groupInviteBody(String name, String kind) {
    return '$name te invitó al grupo · $kind.';
  }

  @override
  String get groupInviteCta => 'Invitar';

  @override
  String get groupInviteLabel => 'Invitación';

  @override
  String get groupInviteSendFailed =>
      'No se pudo enviar la invitación. Inténtalo de nuevo.';

  @override
  String get groupInviteSending => 'Enviando…';

  @override
  String get groupInviteSent => 'Invitación enviada';

  @override
  String get groupInviteUndo => 'Deshacer';

  @override
  String get groupInviteUndoFailed =>
      'No se pudo deshacer la invitación. Inténtalo de nuevo.';

  @override
  String groupLeaderNoteTitle(String title, String name) {
    return '$title $name';
  }

  @override
  String get groupMenuClearStudy => 'Quitar estudio de la semana';

  @override
  String get groupMenuClose => 'Cerrar el grupo';

  @override
  String groupMenuCopyCode(String code) {
    return 'Copiar código $code';
  }

  @override
  String get groupMenuEdit => 'Editar nombre y tipo';

  @override
  String groupMenuGoal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Meta de la semana · $count pasos',
      one: 'Meta de la semana · 1 paso',
    );
    return '$_temp0';
  }

  @override
  String get groupMenuLeadSection => 'Guiar el grupo';

  @override
  String get groupMenuLeave => 'Salir del grupo';

  @override
  String get groupMenuSetGoal => 'Definir meta de la semana';

  @override
  String get groupMenuTransfer => 'Pasar el liderazgo';

  @override
  String get groupNewTitle => 'Nuevo grupo';

  @override
  String get groupPickStudyCta => 'Elegir el estudio';

  @override
  String get groupPickerConfirmCta => 'Marcar para el grupo';

  @override
  String get groupPickerIntro =>
      'Todos en el grupo reciben la misma escena, incluso quien aún no llegó a ella.';

  @override
  String get groupPickerMarkScene => 'Marcar la escena';

  @override
  String get groupPickerNoteHint =>
      'Opcional. Ej.: Lean hasta el miércoles, hablamos el jueves.';

  @override
  String get groupPickerNoteLabel => 'Mensaje para el grupo';

  @override
  String get groupPickerPreviewLabel => 'El grupo verá';

  @override
  String groupRosterSemantics(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, $count días esta semana',
      one: '$name, 1 día esta semana',
    );
    return '$_temp0';
  }

  @override
  String groupSeatAlreadyWaved(String name) {
    return 'Ya saludaste a $name hoy.';
  }

  @override
  String get groupSeatDaysInWeek => 'Días en la semana';

  @override
  String get groupSeatIdle => 'aún no estudió esta semana';

  @override
  String get groupSeatNever => 'aún no estudió';

  @override
  String get groupSeatSteps => 'Pasos';

  @override
  String get groupSeatStudyDone => 'Hecho';

  @override
  String get groupSeatStudyNotYet => 'Aún no';

  @override
  String get groupSeatToday => 'estudió hoy';

  @override
  String get groupSeatWeek => 'estudió esta semana';

  @override
  String get groupSetupKindLabel => 'Para qué es el grupo';

  @override
  String groupSetupLimitHint(int limit) {
    return 'Hasta $limit personas. ¿Grupo grande? Abre otro: el discipulado ocurre en grupos pequeños.';
  }

  @override
  String get groupSetupNameLabel => 'Nombre';

  @override
  String get groupStudyAgain => 'Ya lo hiciste · Estudiar de nuevo';

  @override
  String get groupStudyCta => 'Estudiar con el grupo';

  @override
  String groupStudyDoneCount(int done, int total) {
    return '$done de $total ya lo hicieron';
  }

  @override
  String get groupStudyNobodyYet => 'Nadie lo hizo todavía. Sé el primero.';

  @override
  String get groupStudySwap => 'Cambiar';

  @override
  String get groupWeekStudy => 'Estudio de la semana';

  @override
  String growthDayUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'días ',
      one: 'día ',
    );
    return '$_temp0';
  }

  @override
  String growthDaysToStage(int count, String stage) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count días de racha para $stage',
      one: 'Falta 1 día de racha para $stage',
    );
    return '$_temp0';
  }

  @override
  String growthFreezeUsed(String subtitle) {
    return '$subtitle · hielo ya usado esta semana';
  }

  @override
  String growthFruitSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días de racha · dio fruto',
      one: '1 día de racha · dio fruto',
    );
    return '$_temp0';
  }

  @override
  String get growthHintDayZero => 'día 0';

  @override
  String growthNextIn(String stage, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Próximo: $stage · faltan $count días de racha',
      one: 'Próximo: $stage · falta 1 día de racha',
    );
    return '$_temp0';
  }

  @override
  String growthNextMilestone(String stage) {
    return 'Próximo hito: $stage';
  }

  @override
  String get growthPerfect => 'Escena perfecta';

  @override
  String growthPerfectWith(String subtitle) {
    return 'Escena perfecta · $subtitle';
  }

  @override
  String get growthSeedSubtitle => 'Haz 1 escena hoy para volverte Brote';

  @override
  String get growthStageBranch => 'Rama';

  @override
  String get growthStageFruit => 'Fruto';

  @override
  String get growthStageSeed => 'Semilla';

  @override
  String get growthStageSprout => 'Brote';

  @override
  String get growthStageTree => 'Árbol';

  @override
  String get growthWhisper =>
      'Cada día de racha sube un hito: Semilla, Brote, Rama, Árbol y Fruto.';

  @override
  String get homeBibleOfflineSubtitle => 'Lee sin internet';

  @override
  String get homeCatalogDownloading => 'Descargando…';

  @override
  String get homeCatalogEmptyBody =>
      'Las escenas se descargan al abrir por primera vez. Si falla la conexión, toca para intentarlo de nuevo.';

  @override
  String get homeCatalogEmptyTitle => 'Las escenas aún no llegaron';

  @override
  String get homeDefaultName => 'Peregrino';

  @override
  String get homeFreezeSheetBody =>
      'Perdiste un día, pero tu racha sigue. El hielo salva una falta por semana — camina hoy para continuar.';

  @override
  String get homeFreezeSheetTitle => 'El hielo cubrió ayer';

  @override
  String homeGoalLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count escenas para la meta',
      one: 'Falta 1 escena para la meta',
    );
    return '$_temp0';
  }

  @override
  String get homeGoalMet => 'Meta del día cumplida';

  @override
  String get homeHeroEcho => 'Eco de ayer';

  @override
  String homeHeroExtraSteps(int count) {
    return '+$count pasos · extra de hoy';
  }

  @override
  String get homeHeroFrozenLine => 'El hielo cubrió ayer · racha a salvo';

  @override
  String get homeHeroMinutes => '~3 min';

  @override
  String get homeHeroProtect => 'Protege tu racha · ~3 min';

  @override
  String get homeHeroReady => 'Escena lista';

  @override
  String get homeHeroTomorrow => 'Mañana';

  @override
  String homeJuntosNews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novedades',
      one: '1 novedad',
    );
    return '$_temp0';
  }

  @override
  String get homeLampsHint => 'Un error apaga una · sin lámparas, termina';

  @override
  String homeLampsSemantics(int current, int max) {
    return '$current de $max lámparas. Cada error apaga una.';
  }

  @override
  String get homeLampsTitle => 'Lámparas';

  @override
  String get homeMoodAlive => 'Al día';

  @override
  String get homeMoodDusty => 'Racha en riesgo';

  @override
  String get homeMoodFrozen => 'Protegida por el hielo';

  @override
  String get homeMoreToday => 'Más para hoy';

  @override
  String homeOpenProfile(String name) {
    return 'Abrir el perfil de $name';
  }

  @override
  String get homeQuestsExtraCaption => 'Pasos extra';

  @override
  String homeReviewCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count para reforzar',
      one: '1 para reforzar',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewTitle => 'Repaso';

  @override
  String homeSeasonChipDoneSemantics(String season, int day, String dayTitle) {
    return '$season. Día $day hecho: $dayTitle';
  }

  @override
  String homeSeasonChipOpenSemantics(String season, int day, String dayTitle) {
    return '$season. Día $day: $dayTitle';
  }

  @override
  String homeSeasonChipSemantics(String season) {
    return '$season · abrir la lectura de la temporada litúrgica';
  }

  @override
  String homeSeasonDayDone(int day, String title) {
    return 'Día $day hecho · $title';
  }

  @override
  String homeSeasonDayLine(int day, String title) {
    return 'Día $day · $title';
  }

  @override
  String homeSeasonDayOf(int day, int total, String title) {
    return 'Día $day de $total · $title';
  }

  @override
  String homeSeasonDayOfDone(int day, int total, String title) {
    return 'Día $day de $total hecho · $title';
  }

  @override
  String get homeSeeTrails => 'Ver rutas';

  @override
  String get homeStatAtRisk => 'en riesgo';

  @override
  String get homeStatFreeze => 'hielo';

  @override
  String get homeStatFreezeUsed => 'hielo usado';

  @override
  String get homeStatGoal => 'meta';

  @override
  String homeStepsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos en el camino',
      one: '1 paso en el camino',
    );
    return '$_temp0';
  }

  @override
  String get homeTrailDoneBody => 'Elige la siguiente y sigue aprendiendo.';

  @override
  String get homeTrailDoneTitle => 'Ruta completada';

  @override
  String get homeWordInScene => 'En esta escena';

  @override
  String homeWordRead(String reference) {
    return 'Leer $reference';
  }

  @override
  String get homeWordWord => 'Palabra';

  @override
  String get inviteAcceptCta => 'Aceptar invitación';

  @override
  String inviteCalledYou(String name) {
    return '$name te invitó';
  }

  @override
  String inviteCardBody(String name) {
    return '$name te invitó a caminar juntos: sin competir, solo presencia.';
  }

  @override
  String get inviteCardHeadline => 'Caminen juntos';

  @override
  String get inviteCardInstallHint =>
      '¿Ya tienes la app? Toca el enlace de la invitación.\n¿Aún no? Descarga Stway y toca otra vez.';

  @override
  String get inviteCodeCopied => 'Código copiado';

  @override
  String get inviteCodeHint => 'Código';

  @override
  String inviteCompanionShareText(String name, String link, String installUrl) {
    return '$name te invitó a caminar juntos en Stway.\nSin competir, solo presencia.\n\nToca para aceptar (si ya tienes la app):\n$link\n\n¿Aún no tienes Stway? Descárgalo y toca el enlace otra vez:\n$installUrl';
  }

  @override
  String get inviteCreateFailed =>
      'No se pudo crear la invitación. Inténtalo de nuevo.';

  @override
  String get inviteHaveCodeSubtitle =>
      'Si copiaste el código en WhatsApp, ya aparece aquí';

  @override
  String get inviteHaveCodeTitle => 'Tengo un código';

  @override
  String get inviteJoinCta => 'Entrar';

  @override
  String get inviteLinkHint =>
      'El enlace abre la app y acepta sin escribir el código';

  @override
  String get invitePreparing => 'Preparando…';

  @override
  String get inviteReadyTitle => 'Tu invitación está lista';

  @override
  String inviteRoomShareText(String code, String installUrl) {
    return 'Entra en Stway con el código $code.\n\n¿Aún no tienes la app? Descárgala: $installUrl';
  }

  @override
  String get inviteScanHint => 'Apunta al QR de la invitación';

  @override
  String get inviteScanQr => 'Escanear QR';

  @override
  String get inviteShareCta => 'Compartir invitación';

  @override
  String get inviteShareSubject => 'Invitación de Stway: caminen juntos';

  @override
  String get inviteSheetSubtitleCompanion =>
      'Toca el enlace, muestra el QR o envía la tarjeta';

  @override
  String get inviteSheetSubtitleRoom => 'Muestra el QR o envía el código';

  @override
  String get inviteSomeone => 'Alguien';

  @override
  String get journalEmpty =>
      'Al fijar una escena, tu respuesta queda guardada aquí.';

  @override
  String get journalTitle => 'Notas de estudio';

  @override
  String get journeyBeyondHorizon => 'Aún más allá del horizonte';

  @override
  String get journeyLockedHint =>
      'Completa la ruta anterior para desbloquear esta.';

  @override
  String journeyModeAhead(String mode) {
    return '$mode por delante';
  }

  @override
  String journeyModeInProgress(String mode) {
    return '$mode en curso';
  }

  @override
  String get journeyNow => 'Ahora';

  @override
  String get journeySoonHint =>
      'Próximamente · esta ruta aún se está escribiendo.';

  @override
  String get journeyYouAreHere => 'Dónde estás';

  @override
  String get juntosAccept => 'Aceptar';

  @override
  String get juntosBeforeLeaveBody =>
      'Elige quién guiará el grupo después de ti.';

  @override
  String get juntosBeforeLeaveTitle => 'Antes de salir';

  @override
  String get juntosBondNotStudying => 'Sin estudiar';

  @override
  String get juntosBondNotYet => 'Todavía no';

  @override
  String get juntosBondYourTurn => 'Tu turno';

  @override
  String get juntosCancelInvite => 'Cancelar invitación';

  @override
  String get juntosCancelInviteError =>
      'No se pudo cancelar la invitación. Inténtalo de nuevo.';

  @override
  String get juntosCaravanEmptyBody =>
      'El ranking aparece con al menos una persona más caminando. Invita a alguien a la caravana — o empieza con una compañía.';

  @override
  String get juntosCaravanEmptyTitle => 'La caravana aún es pequeña';

  @override
  String get juntosCaravanInviteCta => 'Invitar a la caravana';

  @override
  String get juntosCaravanLoadError =>
      'No se pudo cargar la caravana. Desliza para actualizar.';

  @override
  String get juntosCaravanMonthBody =>
      'Todo cuenta: escenas, tareas del día, cofres y compañía. Se reinicia cada día 1 — quien acaba de llegar también puede liderar.';

  @override
  String get juntosCaravanMonthStep1 => 'Estudia\nuna escena';

  @override
  String get juntosCaravanMonthStep2 => 'Suma\npasos';

  @override
  String get juntosCaravanMonthStep3 => 'Mira el\ncamino';

  @override
  String get juntosCaravanMonthTitle => '¿Quién caminó más este mes?';

  @override
  String juntosCaravanPilgrimsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peregrinos de la caravana',
      one: '1 peregrino de la caravana',
    );
    return '$_temp0';
  }

  @override
  String get juntosCaravanShareSubject => 'Ven a la caravana en Stway';

  @override
  String juntosCaravanShareText(String name, String url) {
    return '$name te invita a la caravana en Stway — aprende la Biblia en escenas cortas y camina junto en el ranking.\n\nDescárgala: $url';
  }

  @override
  String get juntosCaravanSignInLive =>
      'Inicia sesión con Google para ver la caravana en vivo.';

  @override
  String get juntosCaravanTimeout =>
      'La caravana tardó en responder. Desliza para actualizar.';

  @override
  String get juntosCaravanWeekBody =>
      'Solo pasos de escenas nuevas, de lunes a domingo. Al final de la semana, los primeros suben de nivel y los últimos bajan.';

  @override
  String get juntosCaravanWeekStep1 => 'Pasos\nde la semana';

  @override
  String get juntosCaravanWeekStep2 => 'Lugar en\nel ranking';

  @override
  String get juntosCaravanWeekStep3 => 'Sube o\nbaja';

  @override
  String get juntosCaravanWeekTitle => '¿Quién avanzó esta semana?';

  @override
  String juntosChallengeExplainerBody(String reward) {
    return 'Misma escena, hasta el domingo. Quien llegue gana $reward — si los dos llegan, los dos ganan.';
  }

  @override
  String get juntosChallengeExplainerTitle => '¿Quién llega antes del domingo?';

  @override
  String get juntosChallengeStep1 => 'Misma\nescena';

  @override
  String get juntosChallengeStep2 => 'Llegar antes\ndel domingo';

  @override
  String get juntosChallengeStep3 => '+10 pasos\nal llegar';

  @override
  String get juntosChoose => 'Elegir';

  @override
  String juntosChromeTabAlert(String label) {
    return '$label, novedad';
  }

  @override
  String get juntosCloseConfirm => 'Cerrar';

  @override
  String get juntosCloseRoomBody =>
      'El grupo desaparece para todos y el código deja de funcionar. No se puede deshacer.';

  @override
  String get juntosCloseRoomTitle => '¿Cerrar el grupo?';

  @override
  String get juntosClosesToday => 'Cierra hoy';

  @override
  String get juntosCodeCopied => 'Código copiado';

  @override
  String get juntosCodeLabel => 'Código';

  @override
  String juntosCodeTapToCopy(String code) {
    return 'Código $code. Toca para copiar';
  }

  @override
  String get juntosCompanionExplainerBody =>
      'Una compañía de estudio. El día en que los dos caminan, el hilo se enciende y la racha crece.';

  @override
  String get juntosCompanionExplainerTitle => '¿Quién camina a tu lado?';

  @override
  String get juntosCompanionFallback => 'Compañero';

  @override
  String get juntosCompanionStep1 => 'Los dos\nestudian';

  @override
  String get juntosCompanionStep2 => 'El día cuenta\njuntos';

  @override
  String get juntosCompanionStep3 => 'Si uno se atrasa,\nel otro saluda';

  @override
  String get juntosCompanionsOfflineBody =>
      'Inicia sesión con Google para caminar con alguien de verdad.';

  @override
  String get juntosCompanionsOfflineTitle => 'La compañía necesita la nube';

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
      'No se pudo crear la invitación. Inténtalo de nuevo.';

  @override
  String get juntosCreateRoom => 'Crear grupo';

  @override
  String juntosDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count días',
      one: 'Falta 1 día',
    );
    return '$_temp0';
  }

  @override
  String get juntosDeclineInviteError =>
      'No se pudo rechazar la invitación. Inténtalo de nuevo.';

  @override
  String juntosDemoteZone(String tier) {
    return 'Zona de descenso · $tier';
  }

  @override
  String get juntosEditRoomTitle => 'Editar grupo';

  @override
  String juntosFirstMilestone(int count) {
    return 'Primer hito: $count días juntos';
  }

  @override
  String juntosGapToAbove(int gap, int place) {
    return '$gap del $placeº';
  }

  @override
  String get juntosHaveCode => 'Tengo un código';

  @override
  String juntosInboxNews(int count) {
    return 'Novedades · $count';
  }

  @override
  String get juntosInviteCompanion => 'Invitar a un compañero';

  @override
  String get juntosInvitePeople => 'Invitar personas';

  @override
  String get juntosInviteShort => 'Invitar';

  @override
  String get juntosJoin => 'Entrar';

  @override
  String get juntosJoinError => 'No se pudo entrar. Inténtalo de nuevo.';

  @override
  String get juntosJoinRoomHint => 'Código que recibiste';

  @override
  String get juntosJoinRoomTitle => 'Entrar al grupo';

  @override
  String get juntosLeader => 'Líder';

  @override
  String juntosLeaveAllCompanionsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Las $count compañías terminan. Te quedas sin compañero.',
      one: 'La compañía termina. Te quedas sin compañero.',
    );
    return '$_temp0';
  }

  @override
  String get juntosLeaveAllCompanionsCta => 'Terminar todas las compañías';

  @override
  String get juntosLeaveAllCompanionsTitle => '¿Terminar todas las compañías?';

  @override
  String get juntosLeaveAllConfirm => 'Terminar todas';

  @override
  String get juntosLeaveCompanionBody =>
      'La compañía con esta persona termina. La caravana sigue.';

  @override
  String get juntosLeaveCompanionCta => 'Salir de la compañía';

  @override
  String get juntosLeaveCompanionTitle => '¿Salir de la compañía?';

  @override
  String get juntosLeaveConfirm => 'Salir';

  @override
  String get juntosLeaveRoomBody =>
      'Sales de la lista. Para volver, usa el código de nuevo.';

  @override
  String get juntosLeaveRoomTitle => '¿Salir del grupo?';

  @override
  String juntosMilestoneLeft(int count, int next) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count para el hito de $next',
      one: 'Falta 1 para el hito de $next',
    );
    return '$_temp0';
  }

  @override
  String get juntosMilestones => 'Hitos';

  @override
  String juntosNextMilestone(int count) {
    return 'Próximo hito: $count días';
  }

  @override
  String juntosOfTotal(int total) {
    return ' de $total';
  }

  @override
  String juntosOnlineSemantics(String countLabel) {
    return '$countLabel. Ver quién está estudiando';
  }

  @override
  String get juntosOpenInvite => 'Invitación abierta';

  @override
  String get juntosOpenInviteMissing => 'Falta una persona del otro lado';

  @override
  String get juntosOrInviteCompanion => 'O invitar a un compañero';

  @override
  String juntosPromoteZone(String tier) {
    return 'Zona de ascenso · $tier';
  }

  @override
  String get juntosRoomAllStudied => 'Todo el grupo estudió esta semana.';

  @override
  String get juntosRoomBenefitList => 'Lista';

  @override
  String get juntosRoomBenefitListDetail => 'Quién estudió';

  @override
  String get juntosRoomBenefitStudy => 'Estudio';

  @override
  String get juntosRoomBenefitStudyDetail => 'Misma escena';

  @override
  String get juntosRoomBenefitWave => 'Saludar';

  @override
  String get juntosRoomBenefitWaveDetail => 'Quién desapareció';

  @override
  String get juntosRoomChestAlready => 'Cofre ya recogido esta semana';

  @override
  String juntosRoomChestClaimed(int count) {
    return 'Cofre del grupo · +$count pasos';
  }

  @override
  String juntosRoomChestOpen(int count) {
    return 'Abrir el cofre del grupo · +$count pasos';
  }

  @override
  String juntosRoomCreated(String code) {
    return 'Grupo creado. Invita a alguien de la lista o envía el código $code.';
  }

  @override
  String get juntosRoomFull => 'Grupo lleno. Para más gente, abre otro grupo.';

  @override
  String get juntosRoomGoalHint =>
      'Suma de la semana. En blanco, quita la meta.';

  @override
  String get juntosRoomGoalLabel => 'Meta del grupo';

  @override
  String juntosRoomGoalProgress(int sum, int goal) {
    return '$sum / $goal pasos';
  }

  @override
  String get juntosRoomGoalTitle => 'Meta de pasos del grupo';

  @override
  String get juntosRoomHalfStudied => 'La mitad del grupo ya estudió.';

  @override
  String get juntosRoomHintClaimed => 'Cofre del grupo recogido esta semana.';

  @override
  String get juntosRoomHintHalf =>
      'El cofre se abre cuando la mitad del grupo estudie.';

  @override
  String get juntosRoomHintHalfOrGoal =>
      'El cofre se abre con la mitad del grupo o la meta.';

  @override
  String get juntosRoomHintInvite =>
      'Invita a quien estudia contigo: célula, familia, amigos.';

  @override
  String get juntosRoomHintStudyToday =>
      'Estudia hoy para abrir el cofre del grupo.';

  @override
  String get juntosRoomJoinError =>
      'No se pudo entrar al grupo. Inténtalo de nuevo.';

  @override
  String juntosRoomJoined(String name) {
    return 'Entraste en $name.';
  }

  @override
  String get juntosRoomJoinedGeneric => 'Entraste al grupo.';

  @override
  String juntosRoomLeaderLine(String leaderTitle, String leader, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
    );
    return '$leaderTitle: $leader · $_temp0';
  }

  @override
  String juntosRoomMissingForHalf(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count personas para la mitad del grupo.',
      one: 'Falta 1 persona para la mitad del grupo.',
    );
    return '$_temp0';
  }

  @override
  String get juntosRoomNotStudiedToday => 'Aún no has estudiado hoy.';

  @override
  String get juntosRoomOnlyYou => 'Solo tú en el grupo por ahora.';

  @override
  String get juntosRoomOptions => 'Opciones del grupo';

  @override
  String get juntosRoomQrSubtitle =>
      'Apunta la cámara o escribe el código para entrar';

  @override
  String juntosRoomShareText(
    String name,
    String url,
    String code,
    String storeUrl,
  ) {
    return 'Únete al grupo \"$name\" en Stway.\nToca o apunta la cámara:\n$url\n\nCódigo: $code\n\nLa lista muestra quién estudió esta semana.\n\n¿Aún no tienes la app? Descárgala: $storeUrl';
  }

  @override
  String get juntosRoomStudySet => 'Estudio marcado para el grupo';

  @override
  String get juntosRoomStudySetError =>
      'No se pudo marcar el estudio. Inténtalo de nuevo.';

  @override
  String get juntosRoomsEmptyBody =>
      'Un grupo cerrado: célula, discipulado o escuela dominical. Marca la escena de la semana y mira quién estudió — la invitación va por la app o por WhatsApp.';

  @override
  String get juntosRoomsEmptyEyebrow =>
      'Célula · Discipulado · Escuela dominical';

  @override
  String get juntosRoomsEmptyTitle => '¿Quién estudia contigo?';

  @override
  String get juntosRoomsOfflineBody =>
      'El grupo queda en tu cuenta. Inicia sesión con Google para crear uno o usar un código.';

  @override
  String get juntosRoomsOfflineFoot =>
      'Sin iniciar sesión, el código no funciona';

  @override
  String get juntosRoomsOfflineTitle => 'Inicia sesión para crear el grupo';

  @override
  String get juntosSeenToday => 'Visto hoy';

  @override
  String get juntosShowQrShare => 'Mostrar QR y compartir';

  @override
  String get juntosSomeone => 'Alguien';

  @override
  String get juntosStudiedThisWeek => 'estudiaron esta semana';

  @override
  String get juntosStudyToday => 'Estudiar hoy';

  @override
  String get juntosStudyingNow => 'Estudiando ahora';

  @override
  String get juntosSwitchRoomBody => 'Saldrás del grupo en el que estás ahora.';

  @override
  String juntosSwitchRoomTitle(String name) {
    return '¿Entrar en $name?';
  }

  @override
  String get juntosTabCaravan => 'Caravana';

  @override
  String get juntosTabChallenge => 'Desafío';

  @override
  String get juntosTabCompanion => 'Compañía';

  @override
  String get juntosTabGroups => 'Grupos';

  @override
  String get juntosThisMonth => 'Este mes';

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
      'Quien asuma marca el estudio y la meta, y saluda al grupo. Sigues en la lista.';

  @override
  String juntosTransferDone(String name) {
    return '$name ahora guía el grupo';
  }

  @override
  String get juntosTransferError =>
      'No se pudo pasar el liderazgo. Inténtalo de nuevo.';

  @override
  String get juntosTransferTitle => 'Pasar el liderazgo';

  @override
  String get juntosWaiting => 'Esperando';

  @override
  String get juntosWalkedToday => 'Caminó hoy';

  @override
  String juntosWaveAt(String name) {
    return 'Saludar a $name';
  }

  @override
  String get juntosWaveError => 'No se pudo saludar. Inténtalo de nuevo.';

  @override
  String juntosWavedAt(String name) {
    return 'Saludaste a $name';
  }

  @override
  String juntosWavedAtYou(String name) {
    return '$name te saludó';
  }

  @override
  String get juntosWeekRankingEmpty =>
      'El ranking de la semana solo aparece con gente de verdad en la caravana.';

  @override
  String juntosWeekTogetherBonus(int count) {
    return 'La compañía ganó +$count pasos en el camino';
  }

  @override
  String get juntosWho => '¿Quién?';

  @override
  String get juntosYouLower => 'tú';

  @override
  String get languageDevice => 'Del dispositivo';

  @override
  String get languageHint =>
      'El contenido de las rutas y la Biblia siguen en portugués por ahora.';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get leagueActiveToday => 'Activo hoy';

  @override
  String leagueBonusEncourage(int count) {
    return '+$count pasos de ánimo';
  }

  @override
  String leagueDemotedBody(int rank, String tier) {
    return 'Quedaste $rank.º. En el nivel $tier, puedes subir de nuevo.';
  }

  @override
  String leagueDemotedTitle(String tier) {
    return 'Bajaste a $tier';
  }

  @override
  String leagueDriftDown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Bajó $count puestos hoy',
      one: 'Bajó 1 puesto hoy',
    );
    return '$_temp0';
  }

  @override
  String get leagueDriftStable => 'Posición estable hoy';

  @override
  String leagueDriftUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Subió $count puestos hoy',
      one: 'Subió 1 puesto hoy',
    );
    return '$_temp0';
  }

  @override
  String leagueLevelUpBodyOnly(String tier) {
    return 'Ahora caminas en el nivel\n$tier';
  }

  @override
  String leagueLevelUpBodyRank(int rank, String tier) {
    return 'Quedaste $rank.º · ahora caminas en el nivel\n$tier';
  }

  @override
  String get leagueLevelUpTitle => 'Subiste de nivel';

  @override
  String leaguePromotedLevelOnly(String tier) {
    return 'Ahora en el nivel $tier';
  }

  @override
  String leaguePromotedRankLine(int rank, String tier) {
    return 'Quedaste $rank.º · ahora en el nivel $tier';
  }

  @override
  String leaguePromotedTitle(String tier) {
    return 'Subiste a $tier';
  }

  @override
  String leagueRiskBodyClosing(int rank, String tier) {
    return 'Estás $rank.º en el nivel $tier. La caravana cierra pronto.';
  }

  @override
  String leagueRiskBodyHold(int rank, String tier) {
    return 'Estás $rank.º en el nivel $tier. Un paso puede asegurar el puesto.';
  }

  @override
  String leagueRiskNear(String closes) {
    return 'Cerca de la bajada · $closes';
  }

  @override
  String leagueRiskZone(String closes) {
    return 'Zona de bajada · $closes';
  }

  @override
  String get leagueRoleLeader => 'Líder';

  @override
  String get leagueRolePodium => 'Podio';

  @override
  String get leagueRoleVice => 'Subcampeón';

  @override
  String leagueSeenDate(String date) {
    return 'Visto $date';
  }

  @override
  String leagueSeenOn(String date) {
    return 'Visto el $date';
  }

  @override
  String get leagueSeenToday => 'Visto hoy';

  @override
  String leagueSeenTodayWalked(String date) {
    return 'Visto hoy · caminó $date';
  }

  @override
  String leagueStayedBody(int rank, String tier) {
    return 'Quedaste $rank.º en el nivel $tier. Nueva semana — sigue caminando.';
  }

  @override
  String leagueStudying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estudiando',
      one: '1 estudiando',
      zero: '0 estudiando',
    );
    return '$_temp0';
  }

  @override
  String get leagueTierCedro => 'Cedro';

  @override
  String get leagueTierEstrela => 'Estrella';

  @override
  String get leagueTierOliveira => 'Olivo';

  @override
  String get leagueTierSemente => 'Semilla';

  @override
  String get leagueTierVideira => 'Vid';

  @override
  String leagueWalkedDate(String date) {
    return 'Caminó $date';
  }

  @override
  String leagueWalkedOn(String date) {
    return 'Caminó el $date';
  }

  @override
  String leagueWalkedSeen(String walk, String seen) {
    return 'Caminó $walk · visto $seen';
  }

  @override
  String get leagueWalkedToday => 'Caminó hoy';

  @override
  String get leagueWeekEndedTitle => 'Semana de la caravana cerrada';

  @override
  String get lessonBackToQuestion => 'Volver a la pregunta';

  @override
  String get lessonBonus => 'Bonus';

  @override
  String get lessonBoss => 'Travesía';

  @override
  String lessonCombo(int count) {
    return '×$count';
  }

  @override
  String lessonComboMeterSemantics(int count, int filled, int cycle) {
    return 'Combo $count · $filled de $cycle hasta reencender';
  }

  @override
  String get lessonDuration => '~3 min';

  @override
  String get lessonExitAnyway => 'Salir de todos modos';

  @override
  String lessonExitBody(int act, int total) {
    return 'Estás en la pregunta $act de $total. Si sales ahora, los pasos de esta escena no cuentan.';
  }

  @override
  String get lessonExitTitle => '¿Salir de la escena?';

  @override
  String get lessonInsightSubtitle => 'Lo que quedó';

  @override
  String lessonIntroBossPulse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Travesía · $count preguntas',
      one: 'Travesía · 1 pregunta',
    );
    return '$_temp0';
  }

  @override
  String lessonIntroPulse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~3 min · $count preguntas',
      one: '~3 min · 1 pregunta',
    );
    return '$_temp0';
  }

  @override
  String get lessonLampRelit =>
      'Cinco seguidas: una lámpara se volvió a encender.';

  @override
  String lessonLampsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count lámparas — cada error apaga una.',
      one: 'Queda 1 lámpara — cada error apaga una.',
      zero: 'Se acabaron las lámparas — cada error apaga una.',
    );
    return '$_temp0';
  }

  @override
  String get lessonListen => 'Escuchar el texto';

  @override
  String get lessonListenStop => 'Detener';

  @override
  String get lessonLoadError =>
      'No se pudieron cargar las preguntas de esta escena. Inténtalo de nuevo.';

  @override
  String get lessonLocked => 'Esta escena todavía está bloqueada.';

  @override
  String get lessonMicroSubtitle => 'Completa el versículo';

  @override
  String get lessonPassageTitle => 'Texto de la escena';

  @override
  String get lessonPractice => 'Práctica';

  @override
  String lessonQuestionProgress(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get lessonVerseFallback => 'Versículo';

  @override
  String get liturgyAdvent => 'Adviento';

  @override
  String get liturgyAdventSubtitle => 'Tiempo de espera y preparación';

  @override
  String get liturgyChristmas => 'Navidad';

  @override
  String get liturgyChristmasSubtitle => 'El Verbo se hizo carne';

  @override
  String get liturgyEaster => 'Pascua';

  @override
  String get liturgyEasterSubtitle => 'Cristo resucitó';

  @override
  String get liturgyHolyWeek => 'Semana Santa';

  @override
  String get liturgyHolyWeekSubtitle =>
      'De la cruz a la espera de la resurrección';

  @override
  String get liturgyLent => 'Cuaresma';

  @override
  String get liturgyLentSubtitle => 'Desierto, ayuno y regreso';

  @override
  String get liturgyOrdinary => 'Tiempo ordinario';

  @override
  String get liturgyOrdinarySubtitle => 'Creciendo en la Palabra, día a día';

  @override
  String get liturgyPentecost => 'Pentecostés';

  @override
  String get liturgyPentecostSubtitle => 'El Espíritu es derramado';

  @override
  String liturgyQuestSubtitle(String ref) {
    return 'Lee un capítulo — enfoque: $ref';
  }

  @override
  String liturgyQuestTitle(String season) {
    return 'Tiempo de $season';
  }

  @override
  String get loginAppleError => 'Falló el acceso con Apple';

  @override
  String get loginBody =>
      'Tu cuenta guarda tus pasos, tu racha y tus escenas — así no se pierde nada entre aparatos.';

  @override
  String get loginEntering => 'Entrando…';

  @override
  String get loginGoogleError => 'Falló el acceso con Google';

  @override
  String get loginHydrateError =>
      'No se pudo cargar tu progreso. Revisa la conexión e inténtalo de nuevo.';

  @override
  String get loginLoadingBody => 'Cargando tus pasos, tu racha y tus escenas…';

  @override
  String get loginReconnect => 'Intentar reconectar';

  @override
  String get loginRequired => 'Necesitas entrar para usar Stway.';

  @override
  String get loginTitle => 'Entra para continuar';

  @override
  String get loginWithApple => 'Continuar con Apple';

  @override
  String get loginWithGoogle => 'Continuar con Google';

  @override
  String get mascotAllClear => 'Todo claro. Vuelve mañana para continuar.';

  @override
  String get mascotBossHigh => 'El desafío final quedó atrás. Sigue el mapa.';

  @override
  String get mascotBossLow =>
      'Travesía hecha. Vale reforzar lo que aún tembló.';

  @override
  String get mascotCaravanDetailLead =>
      'Mantén el 1º hasta el domingo y avanzas de caravana.';

  @override
  String get mascotCaravanDetailOut =>
      'Cada escena mueve la caravana. Sigue esta semana.';

  @override
  String mascotCaravanDetailZone(int rank) {
    return '$rankº ahora · los primeros suben el domingo.';
  }

  @override
  String get mascotCaravanLead => 'Lideras la caravana';

  @override
  String mascotCaravanRank(int rank) {
    return '$rankº en la caravana';
  }

  @override
  String get mascotCaravanZone => 'Zona de subida';

  @override
  String get mascotFailedDetail =>
      'Las lámparas se acabaron antes del final. La escena te espera — de nuevo, con calma.';

  @override
  String get mascotFailedKicker => 'Faltó luz';

  @override
  String get mascotGood => 'Buena escena. La ruta te espera mañana.';

  @override
  String get mascotHeadlineBoss => 'Travesía concluida';

  @override
  String get mascotHeadlinePerfect => '100% de aciertos';

  @override
  String get mascotHeadlineReplay => 'Volviste al texto';

  @override
  String get mascotHeadlineScene => 'Escena concluida';

  @override
  String get mascotKickerBoss => 'Travesía final';

  @override
  String get mascotKickerPerfect => 'Sin error';

  @override
  String get mascotKickerReplay => 'Repaso';

  @override
  String get mascotKickerScene => 'Una escena más';

  @override
  String get mascotPerfect => 'Ninguna lámpara perdida. Eso queda.';

  @override
  String get mascotReinforce =>
      'Escena hecha. Refuerza lo que faltó — la memoria agradece.';

  @override
  String get mascotReplay => 'Volver al texto fortalece lo que ya caminaste.';

  @override
  String get medalAccuracyEliteHint =>
      'Mantuviste 95%+ de aciertos en 150 preguntas o más';

  @override
  String get medalAccuracyEliteTitle => 'Puntería certera';

  @override
  String get medalAdventDoorTitle => 'Puerta abierta';

  @override
  String get medalAdventHalfHint => 'Camina la mitad de los días de Adviento';

  @override
  String get medalAdventHalfTitle => 'A mitad del camino';

  @override
  String get medalAdventLivedTitle => 'Temporada vivida';

  @override
  String get medalAdventSubtitle => 'Espera y preparación';

  @override
  String get medalAdventTitle => 'Adviento';

  @override
  String medalAdventTrackSubtitle(String year) {
    return 'Espera y preparación — $year';
  }

  @override
  String medalAdventVaultTitle(String year) {
    return 'Adviento $year';
  }

  @override
  String get medalAdventWeekHint => 'Una racha de siete días en Adviento';

  @override
  String get medalAdventWeekTitle => 'Semana de espera';

  @override
  String get medalAllLevelsDone => 'Todos los niveles completados.';

  @override
  String get medalBibleBeforeHint =>
      'Leíste un capítulo el mismo día, antes de la escena';

  @override
  String get medalBibleBeforeTitle => 'Palabra primero';

  @override
  String get medalComebackHint =>
      'La puerta estaba abierta — volviste tras 21 días o más';

  @override
  String get medalComebackTitle => 'Regreso firme';

  @override
  String get medalFormationPerfect10Title => 'Ojo firme';

  @override
  String get medalFormationPerfect1Title => 'Escena nítida';

  @override
  String get medalFormationPerfect25Hint => '25 escenas con 100% de aciertos';

  @override
  String get medalFormationPerfect25Title => 'Todo correcto';

  @override
  String get medalFounderHint =>
      'Entraste en la app durante el período de pruebas';

  @override
  String get medalFounderTitle => 'Pionero';

  @override
  String get medalHeadlineDiscovery => 'Descubrimiento';

  @override
  String get medalHeadlineJourney => 'Medalla del camino';

  @override
  String get medalHeadlineLevelUp => 'Subiste de nivel';

  @override
  String get medalHeadlineLit => 'Medalla encendida';

  @override
  String get medalHeadlineLocked => 'Por desbloquear';

  @override
  String get medalHeadlineNew => 'Nueva medalla';

  @override
  String get medalHeadlineRare => 'Rara';

  @override
  String get medalHeadlineTrail => 'Medalla de la ruta';

  @override
  String medalHintAdventDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Camina $count días en Adviento',
      one: 'Camina 1 día en Adviento',
    );
    return '$_temp0';
  }

  @override
  String medalHintLentDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Camina $count días en Cuaresma',
      one: 'Camina 1 día en Cuaresma',
    );
    return '$_temp0';
  }

  @override
  String medalHintMemorizeVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Afianza $count versículos en la memorización',
      one: 'Afianza 1 versículo en la memorización',
    );
    return '$_temp0';
  }

  @override
  String medalHintPerfectScenes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Termina $count escenas con 100% de aciertos',
      one: 'Termina una escena con 100% de aciertos',
    );
    return '$_temp0';
  }

  @override
  String medalHintReadChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lee $count capítulos',
      one: 'Lee 1 capítulo en la Biblia',
    );
    return '$_temp0';
  }

  @override
  String medalHintShareVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Comparte $count versículos',
      one: 'Comparte 1 versículo',
    );
    return '$_temp0';
  }

  @override
  String medalHintStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mantén una racha de $count días',
      one: 'Mantén una racha de 1 día',
    );
    return '$_temp0';
  }

  @override
  String medalHowToEarn(String hint) {
    return 'Cómo ganarla: $hint';
  }

  @override
  String get medalJourneyVaultSubtitle =>
      'La chispa se enciende; la medalla se queda';

  @override
  String get medalJourneyVaultTitle => 'Cofre del camino';

  @override
  String get medalLeaderHint => 'Quedaste 1.º en el ranking general por un día';

  @override
  String get medalLeaderTitle => 'Líder de la caravana';

  @override
  String get medalLentFirstStepTitle => 'Primer paso en el desierto';

  @override
  String get medalLentHalfHint => 'Camina la mitad de los días de Cuaresma';

  @override
  String get medalLentHalfTitle => 'En medio del desierto';

  @override
  String get medalLentLivedTitle => 'Cuaresma vivida';

  @override
  String get medalLentSubtitle => 'Desierto, ayuno y regreso';

  @override
  String get medalLentTitle => 'Cuaresma';

  @override
  String medalLentTrackSubtitle(String year) {
    return 'Desierto, ayuno y regreso — $year';
  }

  @override
  String medalLentVaultTitle(String year) {
    return 'Cuaresma $year';
  }

  @override
  String get medalMemoryVerse15Title => 'Palabra guardada';

  @override
  String get medalMemoryVerse1Title => 'Primer versículo';

  @override
  String get medalMemoryVerse50Title => 'Escritura viva';

  @override
  String get medalMysteryHint =>
      'Se revelan en el camino — sin pistas en el cofre.';

  @override
  String medalMysteryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count descubrimientos',
      one: 'Un descubrimiento',
    );
    return '$_temp0';
  }

  @override
  String medalNowTier(String tier) {
    return 'Ahora en $tier';
  }

  @override
  String get medalPathStreak14Title => 'Dos semanas';

  @override
  String get medalPathStreak30Title => 'Mes constante';

  @override
  String get medalPathStreak3Title => 'Tres días firmes';

  @override
  String get medalPerfectBossHint =>
      'Ganaste un desafío final con 100% de aciertos';

  @override
  String get medalPerfectBossTitle => 'Prueba impecable';

  @override
  String medalProximityAction(int count, String units, String track) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $units · $track',
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
      other: 'Faltan $units para $tier en $track',
      one: 'Falta $units para $tier en $track',
    );
    return '$_temp0';
  }

  @override
  String medalProximityRemaining(int count, String units) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $units',
      one: 'Falta $units',
    );
    return '$_temp0';
  }

  @override
  String medalProximityShortLeft(int count, String tier) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count para $tier',
      one: 'Falta 1 para $tier',
    );
    return '$_temp0';
  }

  @override
  String medalProximityShortToward(int current, int target, String tier) {
    return '$current/$target rumbo a $tier';
  }

  @override
  String medalProximityToward(String units, String tier, String track) {
    return '$units rumbo a $tier en $track';
  }

  @override
  String medalRareLeft(int count, String unit, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count $unit para «$title»',
      one: 'Falta 1 $unit para «$title»',
    );
    return '$_temp0';
  }

  @override
  String medalRareShortLeft(int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count para «$title»',
      one: 'Falta 1 para «$title»',
    );
    return '$_temp0';
  }

  @override
  String get medalRareVaultSubtitle =>
      'Medallas excepcionales — solo aparecen cuando las ganas';

  @override
  String get medalRareVaultTitle => 'Raras';

  @override
  String get medalReflectionDeepHint =>
      'Registraste 40 reflexiones en el diario de escenas';

  @override
  String get medalReflectionDeepTitle => 'Diario profundo';

  @override
  String get medalSeasonFirstWeekTitle => 'Primera semana';

  @override
  String get medalTierAurora => 'Ultrarrara';

  @override
  String get medalTierBronze => 'Bronce';

  @override
  String get medalTierDiamond => 'Diamante';

  @override
  String get medalTierGold => 'Oro';

  @override
  String get medalTierIron => 'Hierro';

  @override
  String get medalTierMirra => 'Mirra';

  @override
  String get medalTierPlatinum => 'Platino';

  @override
  String get medalTierSilver => 'Plata';

  @override
  String get medalTrackComplete => 'Completa';

  @override
  String get medalTrackFormationSubtitle => 'Aciertos y dominio en las escenas';

  @override
  String get medalTrackFormationTitle => 'Formación';

  @override
  String get medalTrackMemorySubtitle => 'Versículos guardados en el corazón';

  @override
  String get medalTrackMemoryTitle => 'Memoria';

  @override
  String get medalTrackPathSubtitle => 'Racha en tu camino';

  @override
  String get medalTrackPathTitle => 'Camino';

  @override
  String get medalTrackUnlit => 'Por encender';

  @override
  String get medalTrackWitnessSubtitle => 'Compartir la Palabra';

  @override
  String get medalTrackWitnessTitle => 'Testimonio';

  @override
  String get medalTrackWordSubtitle => 'Lectura bíblica en tu camino';

  @override
  String get medalTrackWordTitle => 'Palabra';

  @override
  String medalTrailFinalModeHint(String mode) {
    return 'Completa la ruta en el modo $mode';
  }

  @override
  String get medalTrailFirstSceneHint => 'Completa 1 escena en esta ruta';

  @override
  String get medalTrailFirstSceneTitle => 'Primera escena';

  @override
  String get medalTrailFlawlessHint =>
      'Completaste una ruta entera con 100% en todas las escenas';

  @override
  String get medalTrailFlawlessTitle => 'Ruta impecable';

  @override
  String medalTrailModeHint(String mode) {
    return 'Completa el modo $mode';
  }

  @override
  String get medalTrailTrackSubtitle => 'Progreso en esta ruta';

  @override
  String medalUnitAdventDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días en Adviento',
      one: '1 día en Adviento',
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
      other: '$count días en Cuaresma',
      one: '1 día en Cuaresma',
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
      other: '$count escenas perfectas',
      one: '1 escena perfecta',
    );
    return '$_temp0';
  }

  @override
  String medalUnitSharedVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versículos compartidos',
      one: '1 versículo compartido',
    );
    return '$_temp0';
  }

  @override
  String medalUnitStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días de racha',
      one: '1 día de racha',
    );
    return '$_temp0';
  }

  @override
  String medalVaultAllMedals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Las $count medallas',
      one: '1 medalla',
    );
    return '$_temp0';
  }

  @override
  String get medalVaultCompleteBody =>
      'Iluminaste cada medalla de este cofre. Sigue caminando en la Palabra.';

  @override
  String get medalVaultCompleteLabel => 'Cofre completo';

  @override
  String get medalVaultDiscoveries => 'Descubrimientos';

  @override
  String get medalVaultEmptyHint =>
      'Cada escena completada te acerca a una medalla. La primera está cerca.';

  @override
  String get medalVaultMysteryEmpty => 'Se revelan en el camino — sin pista.';

  @override
  String get medalVaultMysteryMore => 'Otras se revelan en el camino.';

  @override
  String medalVaultNextSemantics(String message) {
    return 'Próxima medalla: $message';
  }

  @override
  String get medalVaultNextTitle => 'Próxima medalla';

  @override
  String medalVaultRemaining(int count, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count $unit',
      one: 'Falta 1 $unit',
    );
    return '$_temp0';
  }

  @override
  String get medalVaultSeason => 'Temporada';

  @override
  String get medalVaultTabJourney => 'Camino';

  @override
  String get medalVaultTabTrails => 'Rutas';

  @override
  String get medalVaultTitle => 'Medallas';

  @override
  String get medalWalkingInLightHint =>
      'Mantuviste 85%+ de aciertos (mín. 50 preguntas)';

  @override
  String get medalWalkingInLightTitle => 'Andando en la luz';

  @override
  String get medalWitnessShare10Title => 'Sembrador';

  @override
  String get medalWitnessShare1Title => 'Palabra llevada';

  @override
  String get medalWitnessShare50Title => 'Voz en la caravana';

  @override
  String get medalWordChapters100Title => 'Lector constante';

  @override
  String get medalWordChapters1Title => 'Primera Palabra';

  @override
  String get medalWordChapters25Title => 'Lector atento';

  @override
  String get memoryCard => 'Tarjeta';

  @override
  String memoryDoneSummary(int known, int learning) {
    return '$known firmes · $learning en progreso';
  }

  @override
  String get memoryDoneTitle => 'Sesión completada';

  @override
  String get memoryKnown => 'Ya lo sé';

  @override
  String get memoryNotYet => 'Todavía no';

  @override
  String get memoryReveal => 'Revelar';

  @override
  String get memorySubtitle => 'Grábalo en la memoria';

  @override
  String get memoryTitle => 'Memorizar';

  @override
  String get modeBadgeCleared => 'Completada';

  @override
  String get modeBadgeCurrent => 'Actual';

  @override
  String get modeBadgeHere => 'Estás aquí';

  @override
  String get modeBadgeInProgress => 'En curso';

  @override
  String get modeBadgeLocked => 'Bloqueada';

  @override
  String get modeBadgeReview => 'Repaso';

  @override
  String get modeBannerHint => 'Toca para cambiar de modo';

  @override
  String modeBannerSemantics(String name, String tagline) {
    return 'Modo de estudio: $name. $tagline.';
  }

  @override
  String get modeCaminhadaBlurb =>
      'Conecta los hechos: causas, contexto y el hilo de la narración.';

  @override
  String get modeCaminhadaLabel => 'Comprensión';

  @override
  String get modeCaminhadaSkill1 => 'Relacionar';

  @override
  String get modeCaminhadaSkill2 => 'Comparar';

  @override
  String get modeCaminhadaSkill3 => 'Encadenar';

  @override
  String get modeCaminhadaTagline => 'Lo que comunica el texto';

  @override
  String get modeCaptionCleared => 'completada';

  @override
  String get modeCaptionCurrent => 'actual';

  @override
  String get modeCaptionLocked => 'bloqueada';

  @override
  String modeCleared(String name) {
    return '$name completada';
  }

  @override
  String get modeClearedReview => 'Completada · repasa cuando quieras';

  @override
  String modeCtaContinue(String name) {
    return 'Continuar en $name';
  }

  @override
  String modeCtaReview(String name) {
    return 'Repasar $name';
  }

  @override
  String modeCtaStart(String name) {
    return 'Empezar en $name';
  }

  @override
  String modeCtaStudy(String name) {
    return 'Estudiar en $name';
  }

  @override
  String modeCurrent(String name) {
    return '$name actual';
  }

  @override
  String modeLockHint(String name) {
    return 'Completa $name para desbloquear';
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
  String get modePickerTitle => '¿Cómo quieres\nestudiar?';

  @override
  String get modePickerTopBar => 'Antes de partir';

  @override
  String modePrevAlmostDone(String name) {
    return '$name casi completada';
  }

  @override
  String get modeProfundezasBlurb =>
      'Busca el sentido: lo que el texto revela de Dios y para ti.';

  @override
  String get modeProfundezasLabel => 'Interpretación';

  @override
  String get modeProfundezasSkill1 => 'Interpretar';

  @override
  String get modeProfundezasSkill2 => 'Sustentar';

  @override
  String get modeProfundezasSkill3 => 'Aplicar';

  @override
  String get modeProfundezasTagline => 'Lo que significa el texto';

  @override
  String get modeRuleFootnote =>
      'Tres lecturas del mismo texto · completa un modo para desbloquear el siguiente';

  @override
  String modeScenesLeft(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count escenas de $name',
      one: 'Falta 1 escena de $name',
    );
    return '$_temp0';
  }

  @override
  String modeScenesProgress(int done, int total) {
    return '$done de $total escenas';
  }

  @override
  String get modeSementeBlurb =>
      'Fíjate en las palabras, los hechos y el orden en que suceden.';

  @override
  String get modeSementeLabel => 'Observación';

  @override
  String get modeSementeSkill1 => 'Reconocer';

  @override
  String get modeSementeSkill2 => 'Identificar';

  @override
  String get modeSementeSkill3 => 'Ordenar';

  @override
  String get modeSementeTagline => 'Lo que dice el texto';

  @override
  String modeSessionFootnote(String mode) {
    return 'Solo en esta sesión · al cerrar la app, vuelve a $mode';
  }

  @override
  String get modeSheetEyebrow => 'Modo de estudio';

  @override
  String get modeSheetTitle => '¿Cómo quieres estudiar?';

  @override
  String get modeStartFirstScene => 'Empieza por la primera escena';

  @override
  String get modeSwitch => 'Cambiar';

  @override
  String get morphAbsolute => 'absoluto';

  @override
  String get morphAdjective => 'adjetivo';

  @override
  String get morphAdverb => 'adverbio';

  @override
  String get morphAdverbConjAc => 'adverbio/conj. (ac)';

  @override
  String get morphArticle => 'artículo';

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
  String get morphConjConsecutive => 'conjunción consecutiva';

  @override
  String get morphConjunction => 'conjunción';

  @override
  String get morphConstruct => 'constructo';

  @override
  String get morphDemonstrativeArticle => 'artículo demostrativo';

  @override
  String get morphDetermined => 'determinado';

  @override
  String get morphDivineName => 'nombre divino';

  @override
  String get morphDual => 'dual';

  @override
  String get morphExtraGentilic => 'gentilicio';

  @override
  String get morphExtraLocal => 'local';

  @override
  String get morphExtraProper => 'nombre propio';

  @override
  String get morphExtraTitle => 'título';

  @override
  String get morphFem => 'fem.';

  @override
  String get morphGenderFeminine => 'femenino';

  @override
  String get morphGenderMasculine => 'masculino';

  @override
  String get morphInConstruct => 'en constructo';

  @override
  String get morphInterjection => 'interjección';

  @override
  String get morphLangAramaic => 'arameo';

  @override
  String get morphLangGreek => 'griego';

  @override
  String get morphLangHebrew => 'hebreo';

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
  String get morphMoodParticiple => 'participio';

  @override
  String get morphMoodSubjunctive => 'subjuntivo';

  @override
  String get morphNegativeParticle => 'partícula negativa';

  @override
  String get morphNeuter => 'neutro';

  @override
  String get morphNoun => 'sustantivo';

  @override
  String get morphNounCommon => 'común';

  @override
  String get morphNounGentilic => 'gentilicio';

  @override
  String get morphNounPlace => 'lugar';

  @override
  String get morphNounProper => 'propio';

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
  String get morphPerson1 => '1.ª persona';

  @override
  String get morphPerson1p => '1.ª pl.';

  @override
  String get morphPerson1s => '1.ª sing.';

  @override
  String get morphPerson2 => '2.ª persona';

  @override
  String get morphPerson2p => '2.ª pl.';

  @override
  String get morphPerson2s => '2.ª sing.';

  @override
  String get morphPerson3 => '3.ª persona';

  @override
  String get morphPerson3p => '3.ª pl.';

  @override
  String get morphPerson3s => '3.ª sing.';

  @override
  String get morphPhraseConj => 'Conjunción.';

  @override
  String morphPhraseConjGloss(String gloss) {
    return 'Conjunción — $gloss.';
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
    return '$person del $number';
  }

  @override
  String get morphPhrasePrep => 'Preposición.';

  @override
  String morphPhrasePrepGloss(String gloss) {
    return 'Preposición — $gloss.';
  }

  @override
  String get morphPhrasePrepSuffix => 'Preposición con sufijo pronominal.';

  @override
  String morphPhrasePrepSuffixGloss(String gloss) {
    return 'Preposición con sufijo — $gloss.';
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
  String get morphPrep => 'preposición';

  @override
  String get morphPronominalSuffix => 'sufijo pronominal';

  @override
  String get morphPronounDemonstrative => 'pronombre demostrativo';

  @override
  String get morphPronounPersonal => 'pronombre personal';

  @override
  String get morphPronounPossessive => 'pronombre posesivo';

  @override
  String get morphPronounReciprocal => 'pronombre recíproco/correl.';

  @override
  String get morphPronounReflexive => 'pronombre reflexivo';

  @override
  String get morphPronounRelative => 'pronombre relativo';

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
  String get morphSuffix => 'sufijo';

  @override
  String get morphSuffixDirectional => 'direccional';

  @override
  String get morphSuffixNunParagogic => 'nun paragógico';

  @override
  String get morphSuffixParagogic => 'paragógico';

  @override
  String get morphSuffixPronominal => 'pronominal';

  @override
  String get morphTenseAorist => 'aoristo';

  @override
  String get morphTenseCohortative => 'cohortativo';

  @override
  String get morphTenseFuture => 'futuro';

  @override
  String get morphTenseImperative => 'imperativo';

  @override
  String get morphTenseImperfectGk => 'imperfecto';

  @override
  String get morphTenseImperfectHeb => 'imperfecto';

  @override
  String get morphTenseInfAbsolute => 'infinitivo absoluto';

  @override
  String get morphTenseInfConstruct => 'infinitivo constructo';

  @override
  String get morphTenseJussive => 'yusivo';

  @override
  String get morphTenseParticiple => 'participio';

  @override
  String get morphTenseParticiplePassive => 'participio pasivo';

  @override
  String get morphTensePerfect => 'perfecto';

  @override
  String get morphTensePluperfect => 'pluscuamperfecto';

  @override
  String get morphTensePresent => 'presente';

  @override
  String get morphTenseSecondAorist => '2.º aoristo/futuro';

  @override
  String get morphTenseUndefined => 'tiempo indefinido';

  @override
  String get morphTenseWayyiqtol => 'imperfecto secuencial (wayyiqtol)';

  @override
  String get morphTenseWeqatal => 'perfecto secuencial (weqatal)';

  @override
  String get morphVerb => 'verbo';

  @override
  String get morphVoiceActive => 'activa';

  @override
  String get morphVoiceImpersonal => 'impersonal';

  @override
  String get morphVoiceMidPassDeponent => 'medio-pasiva deponente';

  @override
  String get morphVoiceMiddle => 'media';

  @override
  String get morphVoiceMiddleDeponent => 'media deponente';

  @override
  String get morphVoiceMiddlePassive => 'medio-pasiva';

  @override
  String get morphVoicePassive => 'pasiva';

  @override
  String get morphVoicePassiveDeponent => 'pasiva deponente';

  @override
  String get navBible => 'Biblia';

  @override
  String navTabWithNews(String tab) {
    return '$tab, con novedades';
  }

  @override
  String get navTogether => 'Juntos';

  @override
  String get navTrails => 'Rutas';

  @override
  String get notifChannelDesc =>
      'Meta diaria, escenas, práctica, memorización y favoritos';

  @override
  String get notifChannelName => 'Recordatorios Stway';

  @override
  String get notifContinueTitle => 'Continúa donde lo dejaste';

  @override
  String get notifDailyTitle => 'Del día';

  @override
  String notifFavoritesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tienes $count favoritos. Relee uno y entrena la memoria.',
      one: 'Guardaste un versículo. ¿Qué tal revisitarlo ahora?',
    );
    return '$_temp0';
  }

  @override
  String get notifFavoritesTitle => 'Tus favoritos';

  @override
  String get notifGoalDoneBody => 'Meta hecha. La racha continúa mañana.';

  @override
  String notifGoalLeftBody(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Faltan $left escenas',
      one: 'Falta 1 escena',
    );
    return '$_temp0 para cerrar la meta de hoy.';
  }

  @override
  String notifMemoryBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versículos en el mazo. Memorizar refuerza el aprendizaje.',
      one: 'Un versículo te espera. Bastan dos minutos.',
    );
    return '$_temp0';
  }

  @override
  String notifMistakesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tienes $count errores para reforzar. Práctica rápida, mente firme.',
      one:
          'Tienes 1 error para reforzar. Practica ahora y fija el aprendizaje.',
    );
    return '$_temp0';
  }

  @override
  String get notifPracticeTitle => 'Hora de practicar';

  @override
  String notifQuestsLeftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aún faltan $count gestos del día.',
      one: 'Queda 1 gesto. Uno más y el día cierra.',
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
      other: '$count días',
      one: '1 día',
    );
    return '$name, llevas $_temp0 sin estudiar. Una escena retoma la racha.';
  }

  @override
  String get notifSceneWaitingBody =>
      'Una escena al día. La racha continúa mañana.';

  @override
  String get notifSceneWaitingTitle => 'Tu escena te espera';

  @override
  String notifSceneWaitsBody(String name, String title) {
    return '$name, $title espera.';
  }

  @override
  String get notifSeeYouTomorrowTitle => 'Hasta mañana';

  @override
  String get notifSignature => 'El Peregrino';

  @override
  String notifStreakLeftBody(String name, int streak, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '$streak días',
      one: '1 día',
    );
    String _temp1 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Faltan $left escenas',
      one: 'Falta 1 escena',
    );
    return '$name, ya llevas $_temp0. $_temp1 para seguir el ritmo.';
  }

  @override
  String get notifTodayGoalTitle => 'Meta de hoy';

  @override
  String get notifTomorrowTitle => 'Mañana';

  @override
  String get notifTrialEndingBody =>
      'Gestiona tu suscripción Peregrino+ en ajustes si no quieres continuar.';

  @override
  String get notifTrialEndingTitle => 'Tu prueba gratis termina mañana';

  @override
  String notifWeeklyLeftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aún faltan $count pasos semanales. La semana todavía es tuya.',
      one: 'Falta 1 paso semanal. Cierra el ciclo con calma.',
    );
    return '$_temp0';
  }

  @override
  String get notifWeeklyStepsBody => 'Aún da tiempo de cerrar la semana.';

  @override
  String get notifWeeklyStepsTitle => 'Pasos de la semana';

  @override
  String get nudgeAlreadySubtitle =>
      'Ya saludaste hoy. Envíalo también por WhatsApp, si quieres.';

  @override
  String get nudgeCardCta => 'Vuelve a caminar conmigo en Stway';

  @override
  String nudgeCardDaysAway(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días sin estudiar',
      one: '1 día sin estudiar',
    );
    return '$_temp0';
  }

  @override
  String get nudgeCardHeadline => 'Te extrañé hoy';

  @override
  String get nudgeCardWaiting => 'Esperándote';

  @override
  String nudgeCardWalked(String name) {
    return '$name ya caminó';
  }

  @override
  String get nudgeCompanionFallback => 'Compañero';

  @override
  String get nudgeDefaultMessage => 'Te estoy esperando en la ruta';

  @override
  String nudgeInAppSubtitle(String name) {
    return 'Un saludo en la app: $name lo ve al abrir Stway.';
  }

  @override
  String get nudgeSendFailed => 'No se pudo enviar el saludo.';

  @override
  String nudgeSent(String name) {
    return 'Saludo enviado. $name lo verá al abrir Stway.';
  }

  @override
  String get nudgeShareSubject => '¿Caminamos juntos?';

  @override
  String get nudgeSignInSubtitle =>
      'Inicia sesión para saludar en la app, o envíalo por WhatsApp.';

  @override
  String nudgeTitle(String name) {
    return 'Saludar a $name';
  }

  @override
  String get offlineBody =>
      'La primera vez que lo abres, Stway descarga el currículo de la nube. Necesita internet una vez — después queda en tu dispositivo.';

  @override
  String get offlineDownloadFailed =>
      'No se pudieron descargar las escenas. Inténtalo de nuevo en un momento.';

  @override
  String get offlineDownloading => 'Descargando…';

  @override
  String get offlineNoInternet =>
      'Sin internet por ahora. Activa el Wi‑Fi o los datos e inténtalo de nuevo.';

  @override
  String get offlineTitle => 'Las escenas aún no llegaron';

  @override
  String get onboardingAppearanceBody =>
      'Vale para toda la app.\nPuedes cambiarla después en Ajustes.';

  @override
  String onboardingAppearanceSemantics(String theme) {
    return 'Apariencia $theme';
  }

  @override
  String get onboardingAppearanceTitle => 'Elige la apariencia.';

  @override
  String get onboardingCommitmentLabel => 'Mi compromiso';

  @override
  String onboardingDayOneOf(int goal) {
    return 'Hoy  ·  día 1 de $goal';
  }

  @override
  String get onboardingDefaultPromise =>
      'la primera escena\nya está en el camino.';

  @override
  String get onboardingEveryDay => 'Todos los días.';

  @override
  String get onboardingFirstSceneMeta => 'Lee · responde · entiende  ·  ~3 min';

  @override
  String get onboardingFirstSceneTitle => '¿Quién creó el mundo?';

  @override
  String get onboardingFiveLamps => '5 lámparas';

  @override
  String get onboardingHabitBody =>
      'Conocer a Dios no pide una maratón.\nPide que vuelvas, todos los días.';

  @override
  String get onboardingHoldToCommit => 'Mantén pulsado para fijar';

  @override
  String get onboardingHolding => 'Fijando…';

  @override
  String get onboardingIntentBody =>
      'Cada escena: lee, responde, entiende.\nTu motivo abre el camino.';

  @override
  String get onboardingIntentHabitCaption => 'todos los días';

  @override
  String get onboardingIntentHabitPromise => 'la racha\nempieza hoy.';

  @override
  String get onboardingIntentHabitTitle => 'Crear una racha';

  @override
  String get onboardingIntentKnowCaption => 'de cerca';

  @override
  String get onboardingIntentKnowPromise =>
      'conocer a Dios\nempieza con una escena.';

  @override
  String get onboardingIntentKnowTitle => 'Conocer a Dios';

  @override
  String get onboardingIntentPeaceCaption => 'un respiro';

  @override
  String get onboardingIntentPeacePromise => 'la paz del día\nempieza aquí.';

  @override
  String get onboardingIntentPeaceTitle => 'Paz en el día';

  @override
  String get onboardingIntentQuestion => '¿Qué te trae aquí?';

  @override
  String get onboardingIntentUnderstandCaption => 'de verdad';

  @override
  String get onboardingIntentUnderstandPromise =>
      'entender la Biblia\nempieza por el principio.';

  @override
  String get onboardingIntentUnderstandTitle => 'Entender la Biblia';

  @override
  String get onboardingKickerAppearance => 'III   ·   Apariencia';

  @override
  String get onboardingKickerGoal => 'I   ·   La meta';

  @override
  String get onboardingKickerIntent => 'II   ·   Tu motivo';

  @override
  String get onboardingKickerJourney => 'V   ·   La jornada';

  @override
  String get onboardingKickerTomorrow => 'IV   ·   Mañana';

  @override
  String get onboardingMinutes => 'Minutos';

  @override
  String get onboardingNameHint => 'tu nombre';

  @override
  String get onboardingNamePrompt => 'Cómo te llamamos';

  @override
  String get onboardingOpening => 'Abriendo…';

  @override
  String onboardingPaceCaption(int scenes, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      scenes,
      locale: localeName,
      other: '$scenes escenas al día · ~$minutes min',
      one: '1 escena al día · ~$minutes min',
    );
    return '$_temp0';
  }

  @override
  String get onboardingRemindAtLabel => 'Te recordamos a las';

  @override
  String get onboardingReminderMorning => 'Un recordatorio por la mañana';

  @override
  String get onboardingReminderNight => 'Un recordatorio por la noche';

  @override
  String get onboardingReminderNoon => 'Un recordatorio al mediodía';

  @override
  String onboardingStreakDays(int count) {
    return '$count días de racha';
  }

  @override
  String get onboardingStreakMonth => 'Un mes entero';

  @override
  String get onboardingStreakTwoWeeks => 'Dos semanas de racha';

  @override
  String get onboardingStreakWeek => 'Una semana de racha';

  @override
  String get onboardingTomorrowBody =>
      'El hábito nace cuando vuelves.\nFija contigo mismo un comienzo.';

  @override
  String get onboardingTomorrowWord => 'Mañana';

  @override
  String get onboardingYourPace => 'Tu ritmo';

  @override
  String get paywallAlreadyPlus => 'Ya eres Peregrino+';

  @override
  String get paywallHeadline => 'Ve más allá en la ruta';

  @override
  String get paywallPerkSeason =>
      'La temporada litúrgica (Adviento / Cuaresma) — después de los 3 días gratis';

  @override
  String get paywallPerkWeeklyReview =>
      'Repaso de la semana: los 7 “Hoy:” + 3 preguntas';

  @override
  String get paywallPitch =>
      'Un apoyo directo al proyecto, con algunos extras.';

  @override
  String paywallPriceAnnual(String price) {
    return '$price al año';
  }

  @override
  String paywallPriceLifetime(String price) {
    return '$price pago único';
  }

  @override
  String paywallPriceMonthly(String price) {
    return '$price al mes';
  }

  @override
  String paywallPriceMonths(int months, String price) {
    return '$price por $months meses';
  }

  @override
  String paywallPriceWeekly(String price) {
    return '$price a la semana';
  }

  @override
  String get paywallPurchaseFailed => 'No se pudo completar la compra.';

  @override
  String get paywallRestore => 'Restaurar compra';

  @override
  String get paywallRestoreFailed => 'No se pudo restaurar la compra.';

  @override
  String get paywallThanks => 'Gracias por apoyar Stway.';

  @override
  String get paywallTitle => 'Peregrino+';

  @override
  String get paywallUnavailable =>
      'La suscripción aún no está disponible en esta versión.';

  @override
  String get pilgrimAccuracyForming => 'Aún en formación';

  @override
  String get pilgrimAccuracyGood => 'Buena comprensión en las escenas';

  @override
  String get pilgrimAccuracySharp => 'Lectura aguda de las Escrituras';

  @override
  String get pilgrimAccuracySteady => 'Caminando con firmeza';

  @override
  String get pilgrimAccuracyTitle => 'Aciertos';

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
      other: '$books libros',
      one: '1 libro',
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
    return '$_temp0 · medalla Palabra';
  }

  @override
  String get pilgrimCollections => 'Colecciones';

  @override
  String pilgrimCompletedOn(String date) {
    return 'Completada el $date';
  }

  @override
  String pilgrimCorrectOf(int correct, int total) {
    return '$correct de $total';
  }

  @override
  String get pilgrimCorrectOnJourney => 'preguntas correctas en el camino';

  @override
  String pilgrimCorrectRatio(int correct, int total) {
    return '$correct/$total correctas';
  }

  @override
  String get pilgrimFallbackName => 'Peregrino';

  @override
  String pilgrimLastSeen(String when) {
    return 'Visto por última vez · $when';
  }

  @override
  String get pilgrimLastStudyDay => 'Último día de estudio';

  @override
  String get pilgrimLedOverall => 'Ya lideró el ranking general';

  @override
  String get pilgrimNoReadingYet => 'Aún sin lectura registrada';

  @override
  String get pilgrimNoTrailYet => 'Aún no hay ninguna ruta en curso.';

  @override
  String get pilgrimOnTheJourney => 'en el camino';

  @override
  String get pilgrimPrivacyBody =>
      'Toca el ojo de cada tarjeta para elegir qué ve la caravana.';

  @override
  String get pilgrimPrivacyTitle => 'Privacidad del perfil';

  @override
  String get pilgrimPrivateBody =>
      'Eligió no compartir detalles con la caravana.';

  @override
  String get pilgrimPrivateTitle => 'Perfil privado';

  @override
  String pilgrimRank(int rank) {
    return '$rank.º en el ranking';
  }

  @override
  String get pilgrimRankLeader => 'Líder del ranking';

  @override
  String get pilgrimRankListed => 'En el ranking';

  @override
  String get pilgrimRankMonthly => 'Ranking del mes';

  @override
  String pilgrimRankOrdinal(int rank) {
    return '$rank.º';
  }

  @override
  String get pilgrimRankPodium => 'En el podio';

  @override
  String get pilgrimRankRunnerUp => 'Subcampeón';

  @override
  String get pilgrimRankWeekly => 'Ranking semanal de la caravana';

  @override
  String get pilgrimSceneFallback => 'Escena';

  @override
  String pilgrimScenesOf(int done, int total) {
    return '$done de $total escenas';
  }

  @override
  String get pilgrimScriptures => 'Escrituras';

  @override
  String get pilgrimSealsAndTrails => 'Sellos y rutas';

  @override
  String get pilgrimSeen => 'Visto';

  @override
  String get pilgrimStatScenes => 'Escenas';

  @override
  String get pilgrimStatSteps => 'Pasos';

  @override
  String get pilgrimStreak => 'Racha';

  @override
  String get pilgrimStreakOngoing => 'En curso';

  @override
  String get pilgrimTrail => 'Ruta';

  @override
  String pilgrimTrailsInProgress(int count) {
    return '$count en curso';
  }

  @override
  String get pilgrimWalked => 'Caminó';

  @override
  String get pilgrimYourTrail => 'Tu ruta';

  @override
  String get pilgrimYourTrails => 'Tus rutas';

  @override
  String get planAdjustTime => 'Ajustar tiempo';

  @override
  String get planAllRead => 'Todo leído';

  @override
  String get planAlreadyRead => 'Ya leídos';

  @override
  String planApproxDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~$count días',
      one: '~1 día',
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
      one: '~1 mes',
    );
    return '$_temp0';
  }

  @override
  String get planAtYourPace => 'A tu ritmo';

  @override
  String get planBibleFinished => 'Terminaste la Biblia con este plan.';

  @override
  String get planCardDoneToday => 'Lectura de hoy hecha';

  @override
  String get planCardIdle => 'Canónico o cronológico, a tu tiempo';

  @override
  String planCardToday(int minutes, String order) {
    return '$minutes min hoy · $order';
  }

  @override
  String planChaptersSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count capítulos omitidos',
      one: '1 capítulo omitido',
    );
    return '$_temp0';
  }

  @override
  String get planCreate => 'Crear un plan';

  @override
  String planDayDoneToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lectura del día completada · $count capítulos',
      one: 'Lectura del día completada · 1 capítulo',
    );
    return '$_temp0';
  }

  @override
  String get planDone => 'Hecho';

  @override
  String get planEndConfirmAction => 'Terminar';

  @override
  String get planEndConfirmBody =>
      'Tu progreso en el plan se reiniciará. Los capítulos ya marcados como leídos en la Biblia se mantienen.';

  @override
  String get planEndConfirmTitle => '¿Terminar el plan?';

  @override
  String get planEndCta => 'Terminar el plan';

  @override
  String get planEstimate => 'Estimación';

  @override
  String get planFinished => 'Plan completado';

  @override
  String get planMarkDayRead => 'Marcar la lectura del día';

  @override
  String planMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get planOrderAlphabetical => 'Orden alfabético';

  @override
  String get planOrderAlphabeticalShort => 'Alfabético';

  @override
  String get planOrderCanonical => 'Orden de la Biblia';

  @override
  String get planOrderCanonicalShort => 'Canónico';

  @override
  String get planOrderChronological => 'Orden cronológico';

  @override
  String get planOrderChronologicalShort => 'Cronológico';

  @override
  String get planPendingChapters => 'Capítulos pendientes';

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
      other: '$count días de lectura',
      one: '1 día de lectura',
    );
    return '$_temp0';
  }

  @override
  String get planRemaining => 'Restante';

  @override
  String get planSectionOrder => 'Orden';

  @override
  String get planSectionTime => 'Tiempo disponible';

  @override
  String get planSetupBody =>
      'Armamos la porción diaria para que quepa en ese tiempo — en el orden de la Biblia o en el orden de los acontecimientos. Los capítulos que ya leíste se omiten.';

  @override
  String get planSetupQuestion => '¿Cuánto tiempo tienes al día?';

  @override
  String planSkippedChaptersToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se omitieron $count capítulos ya leídos',
      one: 'Se omitió 1 capítulo ya leído',
    );
    return '$_temp0';
  }

  @override
  String planStartCta(int minutes) {
    return 'Empezar plan · $minutes min/día';
  }

  @override
  String get planTitle => 'Plan de lectura';

  @override
  String get planTodayChapters => 'Capítulos de hoy';

  @override
  String get planTodayDoneBody =>
      'Porción de hoy completada. Vuelve mañana — o sigue explorando la Biblia libremente.';

  @override
  String get portraitAvatar => 'Avatar';

  @override
  String get portraitAvatarHint => 'Un peregrino ilustrado';

  @override
  String get portraitEyebrow => 'Retrato';

  @override
  String get portraitLetter => 'Letra';

  @override
  String get portraitLetterHint => 'Las iniciales de tu nombre';

  @override
  String get portraitNoPhoto => 'Sin foto en esta cuenta';

  @override
  String get portraitPhoto => 'Foto';

  @override
  String get portraitPhotoHint => 'La foto de tu cuenta';

  @override
  String get portraitTitle => 'Cómo apareces en el perfil';

  @override
  String get practiceEmptyBody =>
      'Sigue con las escenas. Cuando falles, la pregunta vuelve aquí.';

  @override
  String get practiceEmptyTitle => 'Aún no hay errores guardados';

  @override
  String get practiceIntro =>
      'Vuelve a las preguntas que fallaste. Cada acierto quita la pregunta de la fila.';

  @override
  String get practiceSubtitle => 'Refuerza los pasajes';

  @override
  String get practiceTitle => 'Repasar errores';

  @override
  String profileDaysOnTop(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días en la cima',
      one: '1 día en la cima',
    );
    return '$_temp0';
  }

  @override
  String get profileDaysPerWeek => 'días por semana';

  @override
  String get profileInTheWord => 'En la Palabra';

  @override
  String get profileInTheWordWhisper =>
      'Versículos que guardas y los que ya enviaste.';

  @override
  String get profileLampHelp =>
      'Cada lámpara es una semana: el aceite sube con cada día caminado y la llama crece.';

  @override
  String get profileLastThreeMonths => 'Últimos 3 meses';

  @override
  String profileMonthRank(int rank) {
    return '$rank.º en el ranking del mes';
  }

  @override
  String profileOfSevenDays(int count) {
    return '$count de 7 días';
  }

  @override
  String get profileOpenBible => 'Abrir la Biblia';

  @override
  String profileOpenRef(String ref) {
    return 'Abrir $ref';
  }

  @override
  String profilePrivacyHiddenSemantics(String label) {
    return '$label oculto para la caravana';
  }

  @override
  String profilePrivacyHiddenToast(String label) {
    return '$label queda solo para ti.';
  }

  @override
  String profilePrivacyShownSemantics(String label) {
    return '$label visible para la caravana';
  }

  @override
  String profilePrivacyShownToast(String label) {
    return '$label aparece en tu perfil de la caravana.';
  }

  @override
  String get profileSavedVerses => 'Guardados';

  @override
  String get profileSavedVersesEmpty =>
      'Al leer, toca un versículo y elige Guardar para volver a él después.';

  @override
  String get profileSectionAccuracy => 'Tasa de aciertos';

  @override
  String get profileSectionAccuracyHint =>
      'Porcentaje de aciertos en las escenas';

  @override
  String get profileSectionBibleHint => 'Libros y capítulos leídos';

  @override
  String get profileSectionDaysOnTop => 'Días en la cima';

  @override
  String get profileSectionDaysOnTopHint =>
      'Cuántos días estuviste 1.º en el ranking general';

  @override
  String get profileSectionLastScene => 'Última escena';

  @override
  String get profileSectionLastSceneHint =>
      'Nombre de la última escena completada';

  @override
  String get profileSectionMedals => 'Medallas';

  @override
  String get profileSectionMedalsHint => 'Medallas del camino';

  @override
  String get profileSectionPresence => 'Presencia';

  @override
  String get profileSectionPresenceHint =>
      'Semana, racha e hitos, de Semilla a Fruto';

  @override
  String get profileSectionRanking => 'Ranking y pasos';

  @override
  String get profileSectionRankingHint => 'Posición y pasos totales';

  @override
  String get profileSectionTrailsHint =>
      'Progreso en las rutas y sellos obtenidos';

  @override
  String get profileSharedVerses => 'Enviados';

  @override
  String get profileSharedVersesEmpty =>
      'Los versículos que compartas aparecen aquí — solo la referencia.';

  @override
  String profileSince(String month, int year) {
    return 'Peregrino desde $month de $year';
  }

  @override
  String profileStreakGoalDone(int goal) {
    return 'Compromiso de $goal días cumplido. Sigue firme.';
  }

  @override
  String profileStreakOf(int streak, int goal) {
    return 'Racha de $streak de $goal días';
  }

  @override
  String profileStreakOfGoal(int goal) {
    return 'de $goal';
  }

  @override
  String profileStreakRemaining(int left, int goal) {
    return 'Faltan $left para el compromiso de $goal días.';
  }

  @override
  String get profileStreakStart => 'Una escena hoy enciende el primer día.';

  @override
  String get profileThisWeek => 'Esta semana';

  @override
  String get profileThisWeekLower => 'esta semana';

  @override
  String profileThisWeekSemantics(int count) {
    return 'Esta semana: $count de 7 días caminados';
  }

  @override
  String get profileThreeMonthsAgo => 'hace 3 meses';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileTodayLower => 'hoy';

  @override
  String get profileWdFri => 'V';

  @override
  String get profileWdMon => 'L';

  @override
  String get profileWdSat => 'S';

  @override
  String get profileWdSun => 'D';

  @override
  String get profileWdThu => 'J';

  @override
  String get profileWdTue => 'M';

  @override
  String get profileWdWed => 'X';

  @override
  String get profileWeekHistory => 'Historial de semanas';

  @override
  String profileWeeksWalkedSemantics(int walked, int weeks) {
    return '$walked días caminados en las últimas $weeks semanas';
  }

  @override
  String get profileYourJourney => 'Tu camino';

  @override
  String get profileYourNumbers => 'Tus números';

  @override
  String get profileYourStreak => 'Tu racha';

  @override
  String get questAccuracySubtitle => 'Termina una escena con 80% de aciertos';

  @override
  String get questAccuracyTitle => 'Ojo firme';

  @override
  String questCountOf(int done, int total) {
    return '$done de $total';
  }

  @override
  String get questDailySubtitle => 'Pasos extra además de la escena.';

  @override
  String get questDailyTitle => 'Tareas del día';

  @override
  String get questDone => 'Hecho';

  @override
  String get questDoneLower => 'hecho';

  @override
  String get questMilestone100Subtitle => '100% — sigue caminando';

  @override
  String get questMilestone100Title => 'Camino recorrido';

  @override
  String get questMilestone25Subtitle => '25% de la ruta';

  @override
  String get questMilestone25Title => 'Buen comienzo';

  @override
  String get questMilestone50Subtitle => '50% de la ruta';

  @override
  String get questMilestone50Title => 'A mitad de camino';

  @override
  String get questMilestone75Subtitle => '75% de la ruta';

  @override
  String get questMilestone75Title => 'Casi ahí';

  @override
  String get questMissionSubtitle => 'Completa una escena';

  @override
  String get questMissionTitle => 'Una escena';

  @override
  String questProgressLine(int value, int target, String subtitle) {
    return '$value de $target · $subtitle';
  }

  @override
  String get questReadSubtitle => 'Lee un capítulo';

  @override
  String get questReadTitle => 'En la Palabra';

  @override
  String get questWeeklyDaysSubtitle => 'Camina en 4 días distintos';

  @override
  String get questWeeklyDaysTitle => 'Cuatro días';

  @override
  String get questWeeklyPerfectSubtitle =>
      'Dos escenas con 100% de aciertos en la semana';

  @override
  String get questWeeklyPerfectTitle => 'Dos sin error';

  @override
  String get questWeeklyScenesSubtitle => 'Completa 5 escenas esta semana';

  @override
  String get questWeeklyScenesTitle => 'Cinco escenas';

  @override
  String get questWeeklyTitle => 'Tareas de la semana';

  @override
  String get realmAntigoTestamento => 'Antiguo Testamento';

  @override
  String get realmEyebrowAntigoTestamento => 'La promesa';

  @override
  String get realmEyebrowNovoTestamento => 'El cumplimiento';

  @override
  String get realmEyebrowTeologia => 'El fundamento';

  @override
  String get realmEyebrowVidaCrista => 'El andar';

  @override
  String get realmNovoTestamento => 'Nuevo Testamento';

  @override
  String get realmOther => 'Otros';

  @override
  String get realmTaglineAntigoTestamento =>
      'De la creación a los profetas — el camino de la alianza';

  @override
  String get realmTaglineNovoTestamento =>
      'Cristo, la Iglesia y la esperanza que no falla';

  @override
  String get realmTaglineTeologia =>
      'Hermenéutica, lenguas y la doctrina de la fe';

  @override
  String get realmTaglineVidaCrista =>
      'Discipulado, oración y la historia de la fe';

  @override
  String get realmTeologia => 'Teología';

  @override
  String get realmTeologiaSoonBody =>
      'Hermenéutica, lenguas originales y dogmática.';

  @override
  String get realmVidaCrista => 'Vida cristiana';

  @override
  String get recognitionAMedal => 'Una medalla';

  @override
  String get recognitionAlready => 'Ya lo reconociste';

  @override
  String recognitionAndMore(String a, String b, int count) {
    return '$a, $b y $count más';
  }

  @override
  String recognitionAndTwo(String a, String b) {
    return '$a y $b';
  }

  @override
  String recognitionDaysAgo(int count) {
    return 'Hace $count días';
  }

  @override
  String get recognitionEmptyCard =>
      'Cuando alguien de la caravana toque el corazón, aparece aquí.';

  @override
  String get recognitionEmptySheet =>
      'Aún nadie reconoció tu camino.\nEn la caravana, otros pueden tocar el corazón.';

  @override
  String get recognitionFailedGive => 'No se pudo reconocer';

  @override
  String get recognitionFailedWithdraw => 'No se pudo retirar';

  @override
  String get recognitionGivenTapWithdraw => 'Reconocida · toca para retirar';

  @override
  String recognitionHeadlineMedal(String name, String title) {
    return '$name reconoció $title';
  }

  @override
  String recognitionHeadlineMedalUnknown(String name) {
    return '$name reconoció una medalla tuya';
  }

  @override
  String recognitionHeadlineWalk(String name) {
    return '$name reconoció tu escena';
  }

  @override
  String get recognitionHomeSeeWho => 'Ver quién te reconoció';

  @override
  String get recognitionHomeTitleMany => 'Reconocieron tu camino';

  @override
  String recognitionHomeTitleSingle(String name) {
    return '$name reconoció tu camino';
  }

  @override
  String get recognitionMedalDone => 'Medalla reconocida';

  @override
  String get recognitionMedalFirstScene => 'Primera escena';

  @override
  String get recognitionMedalInterpretation => 'Interpretación';

  @override
  String get recognitionMedalObservation => 'Observación';

  @override
  String get recognitionMedalUnderstanding => 'Comprensión';

  @override
  String get recognitionRecognizeScene => 'Reconocer la escena';

  @override
  String get recognitionRemoved => 'Reconocimiento retirado';

  @override
  String recognitionSawJourney(int count, String who) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$who vieron tu camino',
      one: '$who vio tu camino',
    );
    return '$_temp0';
  }

  @override
  String recognitionSawYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'te reconoció $count veces',
      one: 'te reconoció',
    );
    return '$_temp0';
  }

  @override
  String get recognitionSceneDone => 'Escena reconocida';

  @override
  String recognitionSceneOf(String date) {
    return 'Escena del $date';
  }

  @override
  String recognitionSemanticsWho(String subtitle) {
    return 'Quién reconoció. $subtitle';
  }

  @override
  String recognitionSummaryCounts(int recog, int people) {
    String _temp0 = intl.Intl.pluralLogic(
      recog,
      locale: localeName,
      other: '$recog reconocimientos',
      one: '1 reconocimiento',
    );
    String _temp1 = intl.Intl.pluralLogic(
      people,
      locale: localeName,
      other: '$people personas',
      one: '1 persona',
    );
    return '$_temp0 de $_temp1';
  }

  @override
  String get recognitionSummaryEmpty =>
      'Escena del día y medallas que otros vieron en ti.';

  @override
  String get recognitionTapToWithdraw => 'Toca de nuevo para retirar';

  @override
  String get recognitionWhichMedal => '¿Qué medalla viste?';

  @override
  String get recognitionWhoTitle => 'Quién reconoció';

  @override
  String get recognitionYesterday => 'Ayer';

  @override
  String get recognitionYourScene => 'Tu escena';

  @override
  String get reminderDailyEyebrow => 'Recordatorio diario';

  @override
  String reminderHour(int hour) {
    return '$hour:00';
  }

  @override
  String get reminderMorning => 'Mañana';

  @override
  String get reminderNight => 'Noche';

  @override
  String get reminderNoon => 'Mediodía';

  @override
  String reminderRemindAt(int hour) {
    return 'Recordar a las $hour:00';
  }

  @override
  String get reminderSubtitle =>
      'Una hora fija afianza el hábito. Mañana te avisamos de la siguiente escena.';

  @override
  String get reminderSubtitleSettings =>
      'Un aviso al día, a la hora que elijas.';

  @override
  String get reminderTitle => '¿A qué hora te lo recordamos?';

  @override
  String get reportCategoryFeedback => 'Explicación confusa';

  @override
  String get reportCategoryInterpretation => 'Interpretación dudosa';

  @override
  String get reportCategoryOther => 'Otro';

  @override
  String get reportCategoryTheological => 'Error teológico';

  @override
  String get reportCategoryTypo => 'Ortografía / texto';

  @override
  String get reportCategoryWrongAnswer => 'La respuesta marcada es incorrecta';

  @override
  String get reportCommentHint => 'Opcional: cuéntanos qué parece estar mal…';

  @override
  String get reportHintFeedback =>
      'La explicación después de la respuesta confunde o se equivoca';

  @override
  String get reportHintInterpretation =>
      'La lectura del texto bíblico parece forzada o imprecisa';

  @override
  String get reportHintOther => 'Otra cosa que no encaja arriba';

  @override
  String get reportHintTheological =>
      'La doctrina, explícita o implícita, parece incorrecta';

  @override
  String get reportHintTypo => 'Error de tipeo, referencia o formato';

  @override
  String get reportHintWrongAnswer =>
      'La opción marcada como correcta parece incorrecta';

  @override
  String get reportIntro =>
      'Ayuda a mejorar la ruta — error teológico, interpretación, respuesta o texto.';

  @override
  String get reportSend => 'Enviar reporte';

  @override
  String get reportSendError => 'No se pudo enviar. Inténtalo de nuevo.';

  @override
  String get reportSending => 'Enviando…';

  @override
  String get reportSignInRequired =>
      'Inicia sesión con Google para enviar el reporte.';

  @override
  String get reportTitle => 'Reportar un problema';

  @override
  String get resetAwareness => 'Entiendo que perderé mi progreso';

  @override
  String get resetBody =>
      'Se borrarán todos los pasos, la racha y el progreso. La introducción volverá a aparecer. No se puede deshacer.';

  @override
  String get resetConfirm => 'Confirmar';

  @override
  String resetConfirmCountdown(int seconds) {
    return 'Confirmar · ${seconds}s';
  }

  @override
  String get resetTitle => 'Borrar progreso';

  @override
  String get roomErrorCreate =>
      'No se pudo crear el grupo. Inténtalo de nuevo.';

  @override
  String get roomErrorCreateFirst =>
      'Crea el grupo antes de invitar a alguien.';

  @override
  String roomErrorFull(int limit) {
    return 'Este grupo ya tiene $limit personas.';
  }

  @override
  String roomErrorFullAskLeader(int limit) {
    return 'Este grupo ya tiene $limit personas. Pide al líder que abra otro grupo.';
  }

  @override
  String get roomErrorInvalidCode => 'Código inválido o grupo no encontrado.';

  @override
  String get roomErrorLostGroup => 'No encontramos el grupo en el que estabas.';

  @override
  String get roomErrorSignInCreate => 'Entra con Google para crear un grupo.';

  @override
  String get roomErrorSignInJoin => 'Entra con Google para entrar a un grupo.';

  @override
  String get roomFallbackName => 'Grupo';

  @override
  String get roomKindAmigos => 'Amigos';

  @override
  String get roomKindCelula => 'Célula';

  @override
  String get roomKindDiscipulado => 'Discipulado';

  @override
  String get roomKindEbd => 'Escuela bíblica';

  @override
  String get roomKindFamilia => 'Familia';

  @override
  String get roomLeaderAmigos => 'Anfitrión';

  @override
  String get roomLeaderCelula => 'Líder';

  @override
  String get roomLeaderDiscipulado => 'Discipulador';

  @override
  String get roomLeaderEbd => 'Profesor';

  @override
  String get roomLeaderFamilia => 'Responsable';

  @override
  String get roomNameHintAmigos => 'Ej.: Amigos de la uni';

  @override
  String get roomNameHintCelula => 'Ej.: Célula Norte';

  @override
  String get roomNameHintDiscipulado => 'Ej.: Discipulado del jueves';

  @override
  String get roomNameHintEbd => 'Ej.: Escuela de jóvenes';

  @override
  String get roomNameHintFamilia => 'Ej.: Familia Souza';

  @override
  String get roomStudyFallbackTitle => 'Estudio de la semana';

  @override
  String sealsAllRevealed(int done, int total) {
    return '$done de $total — todos los sellos revelados.';
  }

  @override
  String sealsCountFact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sellos — hecho y verso, en el texto.',
      one: '1 sello — hecho y verso, en el texto.',
    );
    return '$_temp0';
  }

  @override
  String get sealsEmptyHint => 'Hecho y verso de quien el texto ya mostró.';

  @override
  String get sealsSemanticsLocked => 'Sello aún cerrado';

  @override
  String sealsSemanticsNamed(String name) {
    return 'Sello $name';
  }

  @override
  String sealsStartsAt(String name) {
    return 'Aún en el texto — empieza en $name.';
  }

  @override
  String sealsStillInText(int done, int total, String name) {
    return '$done de $total — aún en el texto: $name';
  }

  @override
  String get sealsTitle => 'Sellos';

  @override
  String get seasonChallengeDoneBody =>
      'Desafío de la temporada concluido. Bien caminado.';

  @override
  String get seasonChallengeEmptyBody =>
      'El próximo llega con la nueva temporada litúrgica.';

  @override
  String get seasonChallengeEmptyTitle => 'Ningún desafío de temporada ahora';

  @override
  String get seasonChallengeInProgress => 'Desafío de la temporada en curso';

  @override
  String get seasonChallengeInvite => 'Invitar al desafío';

  @override
  String seasonChallengePathPercent(int percent) {
    return '$percent% del camino';
  }

  @override
  String get seasonChallengeSeeProgress => 'Ver progreso';

  @override
  String seasonChallengeShareBody(String title, String footer) {
    return '🕯️ Entré al desafío $title en Stway.\n\n¿Caminamos juntos en esta temporada?\n\n$footer';
  }

  @override
  String get seasonChallengeTitle => 'Desafío de la temporada';

  @override
  String seasonDayLine(int day, String title) {
    return 'Día $day · $title';
  }

  @override
  String seasonDayOf(String day, int total) {
    return 'Día $day de $total';
  }

  @override
  String seasonDaysWalked(int done, int total) {
    return '$done / $total días caminados';
  }

  @override
  String get seasonEnded => 'Temporada terminada';

  @override
  String get seasonFreeTrialLine =>
      'Gratis: los 3 primeros días · después, Peregrino+';

  @override
  String get seasonNotTodayYet => 'Todavía no es hoy';

  @override
  String get seasonProFromDay4 => 'Peregrino+ a partir del día 4';

  @override
  String get seasonReviewEmpty =>
      'Aún no hay preguntas de esta semana en el aparato. Abre un día primero.';

  @override
  String get seasonReviewMissionIntro =>
      'Tres preguntas de los textos que ya estudiaste.';

  @override
  String get seasonReviewMissionTitle => 'Repaso de la semana';

  @override
  String get seasonReviewPreparing => 'Preparando…';

  @override
  String get seasonReviewStart => '3 preguntas de repaso';

  @override
  String seasonStartsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Empieza en $count días',
      one: 'Empieza en 1 día',
    );
    return '$_temp0';
  }

  @override
  String seasonTodayInsight(String insight) {
    return 'Hoy: $insight';
  }

  @override
  String get seasonWalkAdvento2026Day01Insight => 'Dios se acercó';

  @override
  String get seasonWalkAdvento2026Day01Title => 'El Verbo se hizo carne';

  @override
  String get seasonWalkAdvento2026Day02Insight => 'Dios es el centro, no yo';

  @override
  String get seasonWalkAdvento2026Day02Title => 'En el principio';

  @override
  String get seasonWalkAdvento2026Day03Insight => 'Fuimos hechos para reflejar';

  @override
  String get seasonWalkAdvento2026Day03Title => 'Imagen';

  @override
  String get seasonWalkAdvento2026Day04Insight =>
      'La fe camina cuando Dios llama';

  @override
  String get seasonWalkAdvento2026Day04Title => 'Llamado';

  @override
  String get seasonWalkAdvento2026Day05Insight =>
      'La promesa es mayor que el miedo';

  @override
  String get seasonWalkAdvento2026Day05Title => 'Estrellas';

  @override
  String get seasonWalkAdvento2026Day06Insight => 'Dios proveerá el cordero';

  @override
  String get seasonWalkAdvento2026Day06Title => 'Moriah';

  @override
  String get seasonWalkAdvento2026Day07Insight => 'Dios levanta un libertador';

  @override
  String get seasonWalkAdvento2026Day07Title => 'Moisés';

  @override
  String get seasonWalkAdvento2026Day08Insight => 'La sangre guarda la casa';

  @override
  String get seasonWalkAdvento2026Day08Title => 'Pascua';

  @override
  String get seasonWalkAdvento2026Day09Insight => 'El Reino tiene voz';

  @override
  String get seasonWalkAdvento2026Day09Title => 'El Rey en el monte';

  @override
  String get seasonWalkAdvento2026Day10Insight => 'El Reino cabe en el vacío';

  @override
  String get seasonWalkAdvento2026Day10Title => 'Pobres de espíritu';

  @override
  String get seasonWalkAdvento2026Day11Insight =>
      'Hay consuelo para quien llora';

  @override
  String get seasonWalkAdvento2026Day11Title => 'Los que lloran';

  @override
  String get seasonWalkAdvento2026Day12Insight => 'Shalom es misión';

  @override
  String get seasonWalkAdvento2026Day12Title => 'Pacificadores';

  @override
  String get seasonWalkAdvento2026Day13Insight =>
      'El cielo se abre sobre el Hijo';

  @override
  String get seasonWalkAdvento2026Day13Title => 'Bautismo';

  @override
  String get seasonWalkAdvento2026Day14Insight => 'El monte enseña el Reino';

  @override
  String get seasonWalkAdvento2026Day14Title => 'Sermón';

  @override
  String get seasonWalkAdvento2026Day15Insight => 'Orar es pedir el Reino';

  @override
  String get seasonWalkAdvento2026Day15Title => 'Padre nuestro';

  @override
  String get seasonWalkAdvento2026Day16Insight => 'Nada me faltará';

  @override
  String get seasonWalkAdvento2026Day16Title => 'Mi pastor';

  @override
  String get seasonWalkAdvento2026Day17Insight => 'Cristo bajó hasta la cruz';

  @override
  String get seasonWalkAdvento2026Day17Title => 'Humildad';

  @override
  String get seasonWalkAdvento2026Day18Insight =>
      'El Reino se escucha en historia';

  @override
  String get seasonWalkAdvento2026Day18Title => 'Parábolas';

  @override
  String get seasonWalkAdvento2026Day19Insight => 'El Reino toca el cuerpo';

  @override
  String get seasonWalkAdvento2026Day19Title => 'Milagros';

  @override
  String get seasonWalkAdvento2026Day20Insight =>
      'El tesoro arrastra el corazón';

  @override
  String get seasonWalkAdvento2026Day20Title => 'Ansiedad';

  @override
  String get seasonWalkAdvento2026Day21Insight => 'El pan anticipa la entrega';

  @override
  String get seasonWalkAdvento2026Day21Title => 'Cena';

  @override
  String get seasonWalkAdvento2026Day22Insight => 'El Rey reina clavado';

  @override
  String get seasonWalkAdvento2026Day22Title => 'Cruz';

  @override
  String get seasonWalkAdvento2026Day23Insight => 'La espera no fue en vano';

  @override
  String get seasonWalkAdvento2026Day23Title => 'Resurrección';

  @override
  String get seasonWalkAdvento2026Day24Insight => 'El séptimo día es un don';

  @override
  String get seasonWalkAdvento2026Day24Title => 'Descanso';

  @override
  String get seasonWalkAdvento2026Day25Insight => 'Regocijaos en el Señor';

  @override
  String get seasonWalkAdvento2026Day25Title => 'Alegría';

  @override
  String get seasonWalkAdvento2026Day26Insight =>
      'Quien tiene hambre será saciado';

  @override
  String get seasonWalkAdvento2026Day26Title => 'Hambre de justicia';

  @override
  String get seasonWalkAdvento2026Subtitle =>
      'Espera del Verbo · una escena por día';

  @override
  String get seasonWalkAdvento2026Title => 'Adviento 2026';

  @override
  String seasonWeek(int week) {
    return 'Semana $week';
  }

  @override
  String get seasonWeekInsightsHeader => 'Los 7 “Hoy:” de esta semana';

  @override
  String get seasonWeekReview => 'Repaso de la semana';

  @override
  String get seasonWeekReviewPro => 'Repaso de la semana · Peregrino+';

  @override
  String seasonWeekReviewTitle(int week) {
    return 'Repaso de la semana $week';
  }

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutSubtitle =>
      'Aprende la Biblia en escenas cortas, a tu ritmo.';

  @override
  String get settingsAboutTitle => 'Acerca de Stway';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsAppearanceTitle => 'Apariencia';

  @override
  String get settingsBackupInvalid => 'Copia de seguridad no válida.';

  @override
  String get settingsBackupSheetBody =>
      'Exporta el progreso como texto, o copia una copia de seguridad y toca restaurar.';

  @override
  String get settingsBackupSubject => 'Copia de seguridad de Stway';

  @override
  String get settingsCheck => 'Verificar';

  @override
  String get settingsCheckingUpdate => 'Buscando actualización…';

  @override
  String get settingsCreditsRowSubtitle => 'Textos bíblicos y estudio';

  @override
  String get settingsCreditsSubtitle =>
      'Textos bíblicos y herramientas de estudio usados en Stway.';

  @override
  String get settingsCreditsTitle => 'Traducciones y créditos';

  @override
  String get settingsDailyReminder => 'Recordatorio diario';

  @override
  String settingsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get settingsDeleteProgress => 'Borrar progreso';

  @override
  String get settingsDeleteProgressSubtitle =>
      'Borra el progreso para siempre · pide confirmación';

  @override
  String settingsDeviceId(String id) {
    return 'Dispositivo · $id';
  }

  @override
  String get settingsDeviceOnly => 'Solo en este dispositivo';

  @override
  String get settingsExport => 'Exportar';

  @override
  String get settingsFontExtra => 'Extra';

  @override
  String get settingsFontLarge => 'Grande';

  @override
  String get settingsFontMedium => 'Mediano';

  @override
  String get settingsFontSmall => 'Pequeño';

  @override
  String get settingsGenesisTitle => 'Génesis 1–11';

  @override
  String get settingsGroupAccountData => 'Cuenta y datos';

  @override
  String get settingsGroupDevice => 'En este dispositivo';

  @override
  String get settingsGroupProgress => 'Progreso';

  @override
  String get settingsInCloud => 'En la nube';

  @override
  String settingsLastBackup(String date) {
    return 'Última copia · $date';
  }

  @override
  String settingsLastShort(String date) {
    return 'Última · $date';
  }

  @override
  String get settingsManualBackup => 'Copia de seguridad manual';

  @override
  String get settingsManualBackupSubtitle => 'Exportar o restaurar el progreso';

  @override
  String get settingsPaceIntense => 'Intenso';

  @override
  String get settingsPaceLight => 'Ligero';

  @override
  String get settingsPaceSteady => 'Firme';

  @override
  String get settingsPasteBackupFirst =>
      'Copia primero una copia de seguridad al portapapeles.';

  @override
  String get settingsPlusTeaser => 'Más espacio para tu compañía';

  @override
  String get settingsProgressInCloud => 'Progreso en la nube';

  @override
  String get settingsProgressRestored => 'Progreso restaurado.';

  @override
  String settingsReminderAt(int hour) {
    return 'A las $hour:00 · toca para cambiar';
  }

  @override
  String get settingsRemindersTitle => 'Recordatorios';

  @override
  String get settingsReplayIntro => 'Ver la introducción';

  @override
  String get settingsReplayIntroSubtitle =>
      'La presentación del inicio, otra vez';

  @override
  String get settingsRestoreFromClipboard => 'Restaurar desde el portapapeles';

  @override
  String get settingsRhythmSubtitle => 'Cuántas escenas caben en tu día.';

  @override
  String get settingsRhythmTitle => 'Ritmo diario';

  @override
  String get settingsSampleVerse =>
      'En el principio creó Dios los cielos y la tierra.';

  @override
  String get settingsSaveName => 'Guardar nombre';

  @override
  String settingsSavedInCloud(String date) {
    return 'Guardado en la nube · $date';
  }

  @override
  String settingsScenes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escenas',
      one: '1 escena',
    );
    return '$_temp0';
  }

  @override
  String settingsScenesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escenas al día',
      one: '1 escena al día',
    );
    return '$_temp0';
  }

  @override
  String get settingsSignInAgain =>
      'Inicia sesión de nuevo para sincronizar el progreso.';

  @override
  String get settingsSignOut => 'Cerrar sesión';

  @override
  String get settingsSignOutFailed =>
      'No se pudo cerrar sesión. Inténtalo de nuevo.';

  @override
  String get settingsSignOutSubtitle =>
      'Limpia este dispositivo · el progreso queda en la nube';

  @override
  String settingsSignedInAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String get settingsSounds => 'Sonidos';

  @override
  String get settingsSoundsSubtitle => 'Efectos en las escenas';

  @override
  String get settingsStreakGoalHint =>
      'Hasta cuántos días quieres llevar tu racha.';

  @override
  String get settingsStreakGoalLabel => 'Compromiso de racha';

  @override
  String settingsStudyAttribution(String attribution) {
    return 'Estudio (Strong) — $attribution';
  }

  @override
  String get settingsSubscriptionActive => 'Suscripción activa';

  @override
  String get settingsSubtitle => 'Cuenta, apariencia y recordatorios';

  @override
  String get settingsSupport => 'Ayuda a continuar';

  @override
  String get settingsTextSize => 'Tamaño del texto';

  @override
  String get settingsTextSizeHint => 'El versículo de abajo cambia con él.';

  @override
  String get settingsThemeAuto => 'Automático';

  @override
  String get settingsThemeCaptionAuto => 'Cambia con la hora';

  @override
  String get settingsThemeCaptionDark => 'Siempre oscuro';

  @override
  String get settingsThemeCaptionLight => 'Siempre claro';

  @override
  String get settingsThemeCaptionMedium => 'Siempre en penumbra';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsThemeHint => 'Un tema fijo, o automático según la hora.';

  @override
  String get settingsThemeLabel => 'Tema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeMedium => 'Medio';

  @override
  String get settingsThemeSemantics => 'Tema de la pantalla';

  @override
  String get settingsThemeSemanticsHint => 'Toca o desliza para elegir';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String settingsUpToDate(String version) {
    return 'Tienes la versión más reciente · $version';
  }

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsYourName => 'Tu nombre';

  @override
  String shellReferralBonus(int count, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tus invitaciones sumaron +$steps pasos',
      one: 'Tu invitación sumó +$steps pasos',
    );
    return '$_temp0';
  }

  @override
  String get shellTogetherSubtitle => 'Compañía · Caravana · Grupos';

  @override
  String get shellTrailsSubtitle => 'El mapa del camino';

  @override
  String shellWeekTogetherBonus(int steps) {
    return 'La compañía ganó +$steps pasos en el camino';
  }

  @override
  String get splashPreparing => 'Preparando tu camino…';

  @override
  String get splashSlogan => 'La Biblia, escena a escena';

  @override
  String get streakDayEmpty => 'sin escena';

  @override
  String get streakDayFrozen => 'protegido por el hielo';

  @override
  String streakDaySemantics(String day, String status) {
    return '$day: $status';
  }

  @override
  String streakDayTodaySemantics(String day, String status) {
    return 'Hoy, $day: $status';
  }

  @override
  String get streakRepairAction => 'Reparar';

  @override
  String streakRepairBody(int broken, int restored) {
    String _temp0 = intl.Intl.pluralLogic(
      broken,
      locale: localeName,
      other: 'Tenías $broken días. Restáurala a $restored — 1 vez este mes.',
      one: 'Tenías 1 día. Restáurala a $restored — 1 vez este mes.',
    );
    return '$_temp0';
  }

  @override
  String streakRepairCanReturn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días aún pueden volver',
      one: '1 día aún puede volver',
    );
    return '$_temp0';
  }

  @override
  String streakRepairContinueWith(int count) {
    return 'Sigue con $count · 1 vez este mes';
  }

  @override
  String get streakRepairDismiss => 'Dejarla';

  @override
  String streakRepairDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha restaurada · $count días',
      one: 'Racha restaurada · 1 día',
    );
    return '$_temp0';
  }

  @override
  String get streakRepairTitle => 'Reparar racha';

  @override
  String streakShareDays(int count, int steps, String signature) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '🔥 ¡$count días en Stway!\n\nEstoy aprendiendo la Biblia en escenas cortas — $steps pasos hasta ahora.$signature\n\nDescarga Stway y ven conmigo.',
      one:
          '🔥 ¡1 día en Stway!\n\nEstoy aprendiendo la Biblia en escenas cortas — $steps pasos hasta ahora.$signature\n\nDescarga Stway y ven conmigo.',
    );
    return '$_temp0';
  }

  @override
  String streakShareStart(String signature) {
    return '🔥 Empecé a aprender la Biblia con Stway.$signature\n\nDescarga Stway y ven conmigo.';
  }

  @override
  String streakShareSteps(int steps, String signature) {
    return '🔥 Estoy aprendiendo la Biblia en Stway — $steps pasos hasta ahora.$signature\n\nDescarga Stway y ven conmigo.';
  }

  @override
  String get streakShareSubject => 'Mi racha en Stway';

  @override
  String get streakShareTooltip => 'Compartir racha';

  @override
  String get strongKindConjunction => 'Conjunción';

  @override
  String get strongKindGreek => 'Griego';

  @override
  String get strongKindHebrew => 'Hebreo';

  @override
  String get strongKindParticle => 'Partícula';

  @override
  String get strongKindPrefix => 'Prefijo';

  @override
  String get strongKindPronoun => 'Pronombre';

  @override
  String get strongKindPunctuation => 'Puntuación';

  @override
  String get strongKindSuffix => 'Sufijo';

  @override
  String get strongNoteConjunction =>
      'Conjunción prefijada (vav). El sentido está en el verbo o el nombre que une.';

  @override
  String get strongNoteParticle =>
      'Partícula gramatical del sistema STEP, no un número Strong clásico.';

  @override
  String get strongNotePrefix =>
      'Preposición o artículo inseparable — se pega a la palabra siguiente. No es entrada del Strong clásico.';

  @override
  String get strongNotePronoun =>
      'Pronombre sufijado: quién recibe o posee lo que dice la palabra.';

  @override
  String get strongNotePunctuation =>
      'Marca de lectura del texto hebreo, no una palabra.';

  @override
  String get strongNoteSuffix =>
      'Terminación gramatical, no una entrada de diccionario.';

  @override
  String get suggestionAuthorEmail => 'Correo';

  @override
  String get suggestionAuthorEmailHint => 'nombre@email.com';

  @override
  String get suggestionAuthorHintContact =>
      'Indica teléfono, correo o Instagram.';

  @override
  String get suggestionAuthorHintEmail => 'Revisa el correo.';

  @override
  String get suggestionAuthorHintInstagram => 'Revisa el Instagram.';

  @override
  String get suggestionAuthorHintName =>
      'Escribe el nombre — al menos 2 letras.';

  @override
  String get suggestionAuthorHintPhone =>
      'Revisa el teléfono, con código de área.';

  @override
  String get suggestionAuthorInstagramHint => '@usuario';

  @override
  String get suggestionAuthorName => 'Nombre';

  @override
  String get suggestionAuthorNameHint => 'Cómo se presenta la persona';

  @override
  String get suggestionAuthorPhone => 'Teléfono';

  @override
  String get suggestionAuthorSent =>
      'Sugerencia enviada. Gracias por recomendar al autor.';

  @override
  String get suggestionAuthorSubtitle => '¿Quién falta todavía en el mapa?';

  @override
  String get suggestionAuthorTitle => 'Sugerir un autor';

  @override
  String get suggestionHintAntigoTestamento =>
      'Ej.: Salmos, Éxodo, los profetas…';

  @override
  String get suggestionHintNovoTestamento =>
      'Ej.: el Sermón del Monte, Romanos, Hechos…';

  @override
  String get suggestionHintOther =>
      'Ej.: un tema, un libro o una pregunta que aún falta…';

  @override
  String get suggestionHintTeologia => 'Ej.: Trinidad, hermenéutica, hebreo…';

  @override
  String get suggestionHintVidaCrista =>
      'Ej.: oración, ayuno, la historia de la iglesia…';

  @override
  String get suggestionSend => 'Enviar sugerencia';

  @override
  String get suggestionSendError => 'No se pudo enviar. Inténtalo de nuevo.';

  @override
  String get suggestionSending => 'Enviando…';

  @override
  String get suggestionSignInToSend =>
      'Inicia sesión para enviar la sugerencia.';

  @override
  String get suggestionTrailHintBoth => 'Elige un área y describe la ruta.';

  @override
  String get suggestionTrailHintRealm => 'Elige dónde encaja esta ruta.';

  @override
  String get suggestionTrailHintText => 'Describe la ruta — al menos 4 letras.';

  @override
  String get suggestionTrailPlaceholder => 'Elige un área y describe la ruta…';

  @override
  String get suggestionTrailRealmLabel => 'Dónde encaja';

  @override
  String get suggestionTrailSent => 'Sugerencia enviada. Gracias.';

  @override
  String get suggestionTrailSubtitle => '¿Qué falta todavía en el mapa?';

  @override
  String get suggestionTrailTextLabel => 'La ruta';

  @override
  String get suggestionTrailTitle => 'Sugerir una ruta';

  @override
  String tomorrowDayOf(int streak, int goal) {
    return 'Día $streak de $goal';
  }

  @override
  String tomorrowLine(String title) {
    return 'Mañana: $title';
  }

  @override
  String get tomorrowNextTrail => 'Siguiente ruta';

  @override
  String get tomorrowNextTrailOnMap => 'La siguiente ruta ya está en el mapa.';

  @override
  String get tomorrowSceneWaits => 'La escena te espera.';

  @override
  String get tomorrowSevenDays => 'Siete días. El hábito pegó.';

  @override
  String get tomorrowStoryContinues => 'La historia sigue en el texto.';

  @override
  String get tomorrowTodayYouSaw => 'Hoy viste';

  @override
  String tomorrowYesterday(String text) {
    return 'Ayer: $text';
  }

  @override
  String get trailMapCrossing => 'Travesía';

  @override
  String get trailMapLocked => 'Bloqueada';

  @override
  String get trailMapScene => 'Escena';

  @override
  String trailMapSeal(String name) {
    return 'Sello de $name';
  }

  @override
  String get trailsAreasHeading => 'Las áreas';

  @override
  String get trailsCleared => 'Completada';

  @override
  String trailsContinueSemantics(String title) {
    return 'Continuar · $title';
  }

  @override
  String get trailsDonateBody =>
      'Una contribución voluntaria para las próximas rutas.';

  @override
  String get trailsDonateCta => 'Donar';

  @override
  String get trailsDonateTitle => 'Ayuda a continuar';

  @override
  String trailsDoneOfTotal(int done, int total) {
    return '$done de $total';
  }

  @override
  String get trailsDownloading => 'Descargando…';

  @override
  String get trailsEmptyBody =>
      'El contenido se descarga la primera vez que abres la app. Si la conexión falla, toca para intentarlo de nuevo.';

  @override
  String get trailsEmptyTitle => 'Las escenas aún no llegaron';

  @override
  String get trailsHorizonBody => 'Se están preparando nuevas rutas.';

  @override
  String get trailsHorizonEyebrow => 'En el horizonte';

  @override
  String get trailsInProgress => 'En curso';

  @override
  String trailsLabeledScenesOf(String label, int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$label · $done de $total escenas',
      one: '$label · $done de 1 escena',
    );
    return '$_temp0';
  }

  @override
  String get trailsLearnMore => 'Más información';

  @override
  String trailsModeAllSealed(String mode) {
    return '$mode completada · los tres modos de esta ruta están sellados';
  }

  @override
  String trailsModeChip(String mode) {
    return 'Modo $mode';
  }

  @override
  String trailsModeCleared(String mode) {
    return '$mode completada';
  }

  @override
  String trailsModeNextHint(String mode, String next) {
    return '$mode completada · el siguiente modo es $next';
  }

  @override
  String trailsModeReplayHint(String cleared, String active) {
    return '$cleared completada · el progreso de abajo es del modo $active';
  }

  @override
  String trailsModesCleared(String modes) {
    return '$modes completadas';
  }

  @override
  String trailsRealmOpenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abiertas',
      one: '1 abierta',
    );
    return '$_temp0';
  }

  @override
  String trailsRealmTrailCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rutas',
      one: '1 ruta',
    );
    return '$_temp0';
  }

  @override
  String trailsRealmTrailsDone(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done de $total rutas',
      one: '$done de 1 ruta',
    );
    return '$_temp0';
  }

  @override
  String trailsScenesOf(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done de $total escenas',
      one: '$done de 1 escena',
    );
    return '$_temp0';
  }

  @override
  String trailsScenesShort(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done/$total escenas',
      one: '$done/1 escena',
    );
    return '$_temp0';
  }

  @override
  String trailsStage(String roman) {
    return 'Etapa $roman';
  }

  @override
  String trailsStreakAtRisk(String countdown) {
    return 'La racha termina en $countdown';
  }

  @override
  String trailsTrailNumber(String roman) {
    return 'Ruta $roman';
  }

  @override
  String get updateCheckDisabled => 'Verificación desactivada.';

  @override
  String get updateCheckFailed => 'No se pudo verificar ahora.';

  @override
  String get updateDefaultMessage =>
      'Hay una nueva versión de Stway lista, con mejoras y correcciones.';

  @override
  String get updateEyebrow => 'Actualización';

  @override
  String get updateFirebaseUnavailable => 'Firebase no disponible.';

  @override
  String get updateForceTitle => 'Esta versión necesita actualizarse';

  @override
  String get updateInStore => 'En la tienda';

  @override
  String get updateNoneInCloud =>
      'No hay ninguna versión publicada en la nube.';

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get updateSoftTitle => 'Nueva versión disponible';

  @override
  String get updateStoreOpenFailed =>
      'No se pudo abrir la tienda. Inténtalo de nuevo.';

  @override
  String get verseStudyAttribution =>
      'Léxico y texto etiquetado: STEPBible / Tyndale House Cambridge (CC BY 4.0). Referencias cruzadas: openbible.info (CC BY). Definiciones traducidas automáticamente al portugués.';

  @override
  String get verseStudyCopied => 'Copiado';

  @override
  String get verseStudyCrossRefs => 'Referencias cruzadas';

  @override
  String get verseStudyDefinition => 'Definición';

  @override
  String get verseStudyEmptyBody =>
      'El léxico Strong, la gramática y cada vez que aparece en las Escrituras se abren aquí.';

  @override
  String get verseStudyEmptyTitle => 'Toca una palabra original';

  @override
  String get verseStudyEyebrow => 'Estudiar';

  @override
  String get verseStudyFirst => 'primera';

  @override
  String get verseStudyGoToText => 'Ir al texto';

  @override
  String get verseStudyInThisBook =>
      'En este libro — las apariciones cerca de este versículo.';

  @override
  String get verseStudyInThisVerse => 'En este versículo';

  @override
  String get verseStudyLast => 'última';

  @override
  String get verseStudyLemma => 'Lema';

  @override
  String get verseStudyLoadFailed => 'No se pudo cargar el estudio.';

  @override
  String get verseStudyLoading => 'Abriendo el léxico…';

  @override
  String get verseStudyNeedsRestart =>
      'Cierra y vuelve a abrir la app para cargar el estudio.';

  @override
  String get verseStudyNoCrossRefs =>
      'Sin conexiones catalogadas para este versículo.';

  @override
  String get verseStudyNoData =>
      'Sin datos de los originales para este versículo.';

  @override
  String get verseStudyNoOtherHits => 'Sin otras apariciones en este rango.';

  @override
  String get verseStudyNotLiteral =>
      'La Tradução Brasileira no traduce esta forma al pie de la letra en este versículo.';

  @override
  String verseStudyOccurrencesIn(String book) {
    return 'Apariciones en $book';
  }

  @override
  String get verseStudyOnlyHere => 'Solo en este versículo en el índice.';

  @override
  String get verseStudyOtherBooks => 'En otros libros';

  @override
  String get verseStudyOtherBooksBody =>
      'La primera aparición en cada libro donde la palabra es más frecuente.';

  @override
  String get verseStudyParticleNearby =>
      'Esta partícula aparece miles de veces. Abajo, las formas cerca de este versículo.';

  @override
  String verseStudyParticleNote(int count) {
    return 'Partícula gramatical · $count formas en el canon. El sentido está en el nombre o el verbo que acompaña.';
  }

  @override
  String verseStudySpan(int count, String first, String last) {
    return '$count lugares · de $first a $last';
  }

  @override
  String get verseStudyTabLinks => 'Conexiones';

  @override
  String verseStudyTabLinksCount(int count) {
    return 'Conexiones · $count';
  }

  @override
  String get verseStudyTabUses => 'Usos';

  @override
  String verseStudyTabUsesCount(int count) {
    return 'Usos · $count';
  }

  @override
  String get verseStudyTabWord => 'Palabra';

  @override
  String get verseStudyThisForm => 'En esta forma';

  @override
  String get verseStudyVerseUnavailable =>
      'Versículo no disponible en esta traducción.';

  @override
  String get waveCta => 'Saludar';

  @override
  String get widgetBehindCaravan =>
      'Quedándote atrás en la caravana — camina hoy';

  @override
  String get widgetGoalDone => 'Meta completada';

  @override
  String widgetProgressScenes(int done, int goal) {
    String _temp0 = intl.Intl.pluralLogic(
      goal,
      locale: localeName,
      other: '$done/$goal escenas',
      one: '$done/1 escena',
    );
    return '$_temp0';
  }

  @override
  String widgetScenesLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count escenas hoy',
      one: 'Falta 1 escena hoy',
    );
    return '$_temp0';
  }

  @override
  String widgetTodayTitle(String title) {
    return 'Hoy: $title';
  }

  @override
  String widgetTomorrowTitle(String title) {
    return 'Mañana: $title';
  }

  @override
  String get widgetTrailWaitsTomorrow => 'La ruta espera mañana';
}
