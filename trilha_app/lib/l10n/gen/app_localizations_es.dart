// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get adventPrizeClosed =>
      'El plazo del regalo terminó. El camino sigue abierto.';

  @override
  String adventPrizeConfirmed(int done, int total) {
    return '$done de $total escenas confirmadas';
  }

  @override
  String get adventPrizeEarnedGroup => 'Tu grupo llegó junto a la Navidad.';

  @override
  String get adventPrizeEarnedPair =>
      'Tú y tu dupla llegaron juntos a la Navidad.';

  @override
  String get adventPrizeEarnedSolo =>
      'Caminaste todo el Adviento, un paso por día.';

  @override
  String adventPrizeEarnedTitle(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mes',
    );
    return 'Ganaste $_temp0 de Peregrino+';
  }

  @override
  String get adventPrizeKept =>
      'Tus meses quedan guardados y empiezan cuando termine tu suscripción.';

  @override
  String get adventPrizeKicker => 'Regalo de Adviento';

  @override
  String adventPrizeMonths(int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mes',
    );
    return '$_temp0';
  }

  @override
  String get adventPrizeNeedsLogin =>
      'Entra con tu cuenta para que el regalo valga.';

  @override
  String adventPrizePlusUntil(String date) {
    return 'Peregrino+ hasta el $date';
  }

  @override
  String adventPrizePromise(int days, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mes',
    );
    return 'Camina los $days días de Adviento y gana hasta $_temp0 de Peregrino+.';
  }

  @override
  String adventPrizeRosterBefore(String date) {
    return 'La dupla y el grupo valen si están formados hasta el final del 1.er día ($date).';
  }

  @override
  String adventPrizeRosterGroup(int count) {
    return 'Caminas en grupo. Si $count del grupo terminan, cada uno que termine gana 3 meses.';
  }

  @override
  String get adventPrizeRosterPair =>
      'Caminas en dupla. Si los dos terminan, cada uno gana 2 meses.';

  @override
  String get adventPrizeRosterSolo =>
      'En esta estación caminas solo. Al terminar, ganas 1 mes.';

  @override
  String adventPrizeShareLine(int days, int months) {
    String _temp0 = intl.Intl.pluralLogic(
      months,
      locale: localeName,
      other: '$months meses',
      one: '1 mes',
    );
    return 'Quien camina los $days días gana hasta $_temp0 de Peregrino+. En dupla o en grupo, gana más.';
  }

  @override
  String adventPrizeStepADay(String date, int max) {
    return 'Un paso por día; cada escena vale desde su propio día. ¿Perdiste un día? Puedes hacerlo después, hasta $max escenas por día, hasta el $date.';
  }

  @override
  String adventPrizeTierGroup(int count) {
    return 'Terminar con $count+ de tu grupo';
  }

  @override
  String get adventPrizeTierPair => 'Terminar con tu dupla de Compañía';

  @override
  String get adventPrizeTierSolo => 'Terminar solo';

  @override
  String get adventPrizeUnconfirmed =>
      'Algunos días no se confirmaron (sin internet, demasiado rápido o por encima del límite del día). Rehaz la escena con conexión para que cuente en el regalo.';

  @override
  String get adventPrizeWaitingOthers =>
      'Cuando tu dupla o tu grupo termine, tu regalo sube.';

  @override
  String get appReportCategoryAccount => 'Cuenta y progreso';

  @override
  String get appReportCategoryBug => 'Algo no funciona';

  @override
  String get appReportCategoryOther => 'Otro';

  @override
  String get appReportCategorySubscription => 'Suscripción y compras';

  @override
  String get appReportCategorySuggestion => 'Sugerencia';

  @override
  String get appReportCommentHint => 'Qué estabas haciendo y qué salió mal…';

  @override
  String get appReportHintAccount =>
      'Inicio de sesión, sincronización o progreso perdido';

  @override
  String get appReportHintBug =>
      'Una pantalla se trabó, un botón no responde, algo desaparece o se cierra';

  @override
  String get appReportHintOther => 'Otra cosa que no encaja arriba';

  @override
  String get appReportHintSubscription =>
      'Peregrino+, cobro o restaurar una compra';

  @override
  String get appReportHintSuggestion => 'Una idea para mejorar Stway';

  @override
  String get appReportIntro =>
      'Cuéntanos qué pasó. La versión de la app y el dispositivo van junto para que podamos reproducirlo.';

  @override
  String get appReportSent => 'Reporte enviado. Gracias.';

  @override
  String get appReportTitle => 'Reportar un problema';

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
      'No se pudo iniciar sesión con Google. Inténtalo de nuevo.';

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
  String get bibleBookFinished => 'Concluido';

  @override
  String bibleBookFinishedOn(String date) {
    return 'Concluido el $date';
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
  String get bibleCompareCopiedAll => 'Comparación copiada';

  @override
  String get bibleCompareCopyAll => 'Copiar todo';

  @override
  String get bibleCompareGreek => 'Griego';

  @override
  String get bibleCompareHebrew => 'Hebreo';

  @override
  String get bibleCompareLoading => 'Buscando este versículo en cada versión…';

  @override
  String get bibleCompareMissing => 'Esta versión no incluye este versículo.';

  @override
  String get bibleCompareNextVerse => 'Siguiente versículo';

  @override
  String get bibleCompareOriginalMissing =>
      'El original de este versículo todavía no está en la app.';

  @override
  String get bibleComparePrevVerse => 'Versículo anterior';

  @override
  String get bibleCompareReading => 'leyendo';

  @override
  String get bibleCompareStudyCta => 'Estudiar palabra por palabra';

  @override
  String bibleCompareVerseOf(int verse, int total) {
    return 'Versículo $verse de $total';
  }

  @override
  String get bibleDonate => 'Donar';

  @override
  String get bibleHeroContinueReading => 'Continuar lectura';

  @override
  String get bibleHeroFreshBlurb =>
      'Jesús, la Palabra hecha carne — un buen comienzo.';

  @override
  String get bibleHeroStartHere => 'Continuar lectura';

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
  String bibleListenVoiceMissing(String language) {
    return 'Tu dispositivo no tiene la voz en $language. Instálala en los ajustes de voz (texto a voz) del dispositivo para escuchar esta versión.';
  }

  @override
  String get bibleLoadError => 'No fue posible abrir la Biblia.';

  @override
  String get bibleNewTestament => 'Nuevo Testamento';

  @override
  String get bibleNoteDelete => 'Borrar nota';

  @override
  String get bibleNoteHint => '¿Qué te dice este versículo? (opcional)';

  @override
  String get bibleNoteSave => 'Guardar nota';

  @override
  String get bibleNoteSaved => 'Nota guardada';

  @override
  String get bibleNoteShare => 'Compartir nota';

  @override
  String get bibleNoteTagDeus => 'Dios habla';

  @override
  String get bibleNoteTagFamilia => 'Familia';

  @override
  String get bibleNoteTagJesus => 'Jesús habla';

  @override
  String get bibleNoteTagMandamento => 'Mandamiento';

  @override
  String get bibleNoteTagOracao => 'Oración';

  @override
  String get bibleNoteTagPessoal => 'Personal';

  @override
  String get bibleNoteTagProfecia => 'Profecía';

  @override
  String get bibleNoteTagPromessa => 'Promesa';

  @override
  String get bibleNoteTheme => 'Tema';

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
  String get bibleReaderPreviewRef => 'Salmos 119:105';

  @override
  String get bibleReaderPreviewVerse =>
      'Tu palabra es luz para mis pies; siempre alumbra mi camino.';

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
  String get bibleShareIncludeNote => 'Incluir mi nota';

  @override
  String bibleShareNoteBy(String name) {
    return 'Nota de $name';
  }

  @override
  String get bibleShareNoteMine => 'Mi nota';

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
  String bibleShelfChapters(int read, int total) {
    return '$read de $total capítulos';
  }

  @override
  String bibleShelfSemantics(int read, int total) {
    return 'Estante de la Biblia: $read de $total capítulos leídos';
  }

  @override
  String get bibleTabReading => 'Planes';

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
  String get bibleVerseCompare => 'Comparar versiones';

  @override
  String get bibleVerseCompareDetail =>
      'Portugués, inglés, español y el original';

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
  String get bibleVerseNote => 'Anotar';

  @override
  String get bibleVerseNoted => 'Anotado';

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
  String get bibleVoiceEnglish => 'inglés';

  @override
  String get bibleVoicePortuguese => 'portugués';

  @override
  String get bibleVoiceSpanish => 'español';

  @override
  String get bookFinishedBody =>
      'Capítulo a capítulo, hasta el final. El sello queda en tu Biblia con la fecha de hoy.';

  @override
  String get bookFinishedEyebrow => 'Libro concluido';

  @override
  String bookFinishedTitle(String book) {
    return 'Terminaste $book';
  }

  @override
  String get canonEvangelhosBlurb => 'La vida de Jesús';

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
  String get canonHistoricosBlurb => 'La historia de Israel';

  @override
  String get canonHistoricosTitle => 'Históricos';

  @override
  String get canonPaulinasBlurb => 'Romanos a Filemón';

  @override
  String get canonPaulinasTitle => 'Cartas paulinas';

  @override
  String get canonPentateucoBlurb => 'La Ley';

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
  String get caravanAlbumOnTheWay => 'En camino';

  @override
  String caravanAnanArrived(String month) {
    return '¡Llegamos! La postal de $month es tuya.';
  }

  @override
  String caravanAnanArrivedNeed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¡Llegamos! $count escenas más y la postal es tuya.',
      one: '¡Llegamos! 1 escena más y la postal es tuya.',
    );
    return '$_temp0';
  }

  @override
  String caravanAnanFast(int day) {
    return '¡Qué paso! A este ritmo llegamos el día $day, mucho antes de fin de mes.';
  }

  @override
  String caravanAnanFinal(int days, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '¡Últimos $days días!',
      one: '¡Último día!',
    );
    String _temp1 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Faltan $left escenas',
      one: 'Falta 1 escena',
    );
    return '$_temp0 $_temp1 para la llegada — vamos juntos.';
  }

  @override
  String caravanAnanNeedYou(int count, String month) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escenas más y la postal de $month también es tuya.',
      one: '1 escena más y la postal de $month también es tuya.',
    );
    return '$_temp0';
  }

  @override
  String get caravanAnanSaying1 => 'Aquí nadie camina solo.';

  @override
  String get caravanAnanSaying2 => 'Un paso a la vez también es camino.';

  @override
  String get caravanAnanSaying3 => 'Yo voy adelante — solo sigue la nube.';

  @override
  String get caravanAnanSaying4 =>
      'Cada escena tuya es parte del camino de todos.';

  @override
  String get caravanAnanSaying5 => 'Quien camina acompañado llega más lejos.';

  @override
  String caravanAnanStalled(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'La caravana está parada hace $days días.',
      one: 'La caravana paró ayer.',
    );
    return '$_temp0 Una escena tuya pone a todos en marcha otra vez.';
  }

  @override
  String get caravanAnanStart =>
      '¡La etapa empezó! Cada escena tuya ilumina un tramo del camino.';

  @override
  String get caravanArrival => 'Llegada';

  @override
  String get caravanClaimedAnan => 'Hasta aquí nos ayudó el Señor.';

  @override
  String get caravanGoalClaim => 'Revelar la postal';

  @override
  String caravanGoalCount(int done, int goal, int mine) {
    String _temp0 = intl.Intl.pluralLogic(
      mine,
      locale: localeName,
      other: '$mine son tuyas',
      one: '1 es tuya',
      zero: 'ninguna tuya aún',
    );
    return '$done de $goal escenas · $_temp0';
  }

  @override
  String caravanGoalHeadline(String month) {
    return 'Juntos hasta la postal de $month';
  }

  @override
  String caravanGoalTitle(String month) {
    return 'Etapa de $month';
  }

  @override
  String caravanHereToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasaron hoy',
      one: '1 pasó hoy',
    );
    return '$_temp0';
  }

  @override
  String get caravanLeading => 'Vas al frente de la caravana';

  @override
  String caravanNextToPass(int steps, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps pasos hasta $name',
      one: '1 paso hasta $name',
    );
    return '$_temp0';
  }

  @override
  String get caravanPostcardArrived => 'Hasta aquí nos ayudó el Señor';

  @override
  String caravanPostcardInsight(int count) {
    return 'Nadie camina solo: la caravana hizo $count escenas juntos.';
  }

  @override
  String caravanPostcardTitle(String month) {
    return 'Caravana de $month';
  }

  @override
  String get caravanPostcardsSection => 'Caravana';

  @override
  String get caravanPreviewBody =>
      'Toca un ojo para mostrar u ocultar. Cambia al instante, aquí abajo.';

  @override
  String get caravanPreviewCardCaption =>
      'Mira tu perfil como lo ven los demás y elige qué aparece.';

  @override
  String get caravanPreviewTitle => 'Cómo te ve la caravana';

  @override
  String get caravanSeeAll => 'Ver toda la caravana';

  @override
  String get caravanSeePostcard => 'Ver la postal';

  @override
  String get caravanStop1 => '1.er descanso';

  @override
  String get caravanStop2 => '2.º descanso';

  @override
  String caravanStopToast(String stop) {
    return '¡$stop! Apareció una parte de la postal.';
  }

  @override
  String get caravanWholeEnd => 'Fin de la caravana';

  @override
  String get caravanWholeTitle => 'La caravana del mes';

  @override
  String caravanYouRank(int rank, int total) {
    return 'Estás en el $rank.º de $total';
  }

  @override
  String get categoryApocalipseBlurb =>
      'El libro de Apocalipsis, escrito por Juan el Evangelista.';

  @override
  String get categoryApocalipseTitle => 'Apocalipsis o Revelación';

  @override
  String get categoryConhecerADeusBlurb =>
      'Dios viene antes de todo: el Creador, el nombre YO SOY, la santidad, el pastor y el Verbo hecho carne. Cinco escenas para acercarse a él.';

  @override
  String get categoryConhecerADeusTitle => 'Conocer a Dios';

  @override
  String get categoryCristologiaBlurb =>
      'Quién es Jesús: Dios y hombre, profeta, sacerdote y rey. La ruta recorre su persona y su obra: encarnación, cruz, resurrección y señorío.';

  @override
  String get categoryCristologiaTitle => 'Cristología';

  @override
  String get categoryDiscipuladoBlurb =>
      'Seguir a Jesús cada día: el Sermón del Monte, la familia, la misión y el recomienzo. Fe que se hace camino.';

  @override
  String get categoryDiscipuladoTitle => 'Discipulado';

  @override
  String get categoryEntenderABibliaBlurb =>
      'Un panorama de la historia bíblica: creación, caída, promesa, liberación, el Siervo, la resurrección y la nueva creación — siete escenas de todo el arco.';

  @override
  String get categoryEntenderABibliaTitle => 'Entender la Biblia';

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
  String get categoryHermeneuticaBlurb =>
      'Cómo leer la Biblia con atención y fidelidad. El texto en su contexto, el tipo de libro y el lugar de Cristo en toda la historia, sin forzar un versículo aislado.';

  @override
  String get categoryHermeneuticaTitle => 'Hermenéutica';

  @override
  String get categoryHistoriaIgrejaBlurb =>
      'Cómo nos llegó la fe: la vida en común en Hechos, la persecución, los concilios y credos, y la Reforma que volvió al Evangelio.';

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
  String get categoryLinguasBlurb =>
      'Un primer camino en el hebreo y el griego de la Biblia: alfabeto, raíces y cómo nace una traducción. El objetivo es leer con más cuidado, no reemplazar la Biblia en tu idioma.';

  @override
  String get categoryLinguasTitle => 'Lenguas originales';

  @override
  String get categoryOracaoBlurb =>
      'El Padre Nuestro como escuela de oración, la perseverancia y la ayuda del Espíritu. Y el ayuno como forma de rendir el deseo ante el Padre.';

  @override
  String get categoryOracaoTitle => 'Oración';

  @override
  String get categoryPanoramaBlurb =>
      'Los puntos altos de cada libro en pocas escenas. Para conocer el libro entero antes de ir capítulo a capítulo.';

  @override
  String get categoryPanoramaTitle => 'Panorama';

  @override
  String get categoryParabolasMilagresBlurb =>
      'La enseñanza y las señales de Jesús. Las parábolas muestran cómo es el reino; los milagros revelan quién es él — pan, vista, la tormenta, vida — en eco del Antiguo Testamento.';

  @override
  String get categoryParabolasMilagresTitle => 'Parábolas y milagros';

  @override
  String get categoryPazNoDiaBlurb =>
      'Un respiro en medio del día: echa la ansiedad en el Padre y sigue con confianza. Cinco escenas cortas para el corazón inquieto.';

  @override
  String get categoryPazNoDiaTitle => 'Paz en el día';

  @override
  String get categoryPentateucoBlurb =>
      'Los cinco primeros libros de la Biblia — la Torá, el Libro de la Ley, en orden cronológico.';

  @override
  String get categoryPentateucoTitle => 'Pentateuco';

  @override
  String get categoryPersonagensBlurb =>
      'Vidas que cargan la historia: Abraham, Moisés, David, los profetas, María, Pedro, Pablo. Cada ruta sigue a una persona por varios libros, con sus fallos, y el modo en que esa vida apunta a Cristo.';

  @override
  String get categoryPersonagensTitle => 'Personajes';

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
  String get categoryPromessaCumprimentoBlurb =>
      'Promesas que Dios hace en el Antiguo Testamento y el modo en que Jesús las cumple. Descendencia, Pascua, el hijo de David, el siervo sufriente y el nuevo pacto, leídos junto al Evangelio.';

  @override
  String get categoryPromessaCumprimentoTitle => 'Promesa y cumplimiento';

  @override
  String get categorySistematicaBlurb =>
      'La doctrina reunida desde toda la Biblia: Dios, el ser humano, la salvación, el Espíritu, la iglesia y el fin de la historia — y el hilo que lo une todo, de la creación a la nueva creación.';

  @override
  String get categorySistematicaTitle => 'Sistemática y dogmática';

  @override
  String get categoryTemasBiblicosBlurb =>
      'Hilos que cruzan toda la Escritura: pacto, reino, presencia de Dios, santidad, justicia, exilio y regreso. Cada ruta acompaña un tema, de Génesis a Apocalipsis.';

  @override
  String get categoryTemasBiblicosTitle => 'Temas bíblicos';

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
  String celebrationSeeYouTomorrow(int hour) {
    return 'Te veo mañana a las ${hour}h';
  }

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
  String get challengeSoonBody =>
      'Estamos preparando el desafío: llamas a alguien y ambos hacen la misma escena hasta el domingo. Espera: cuando abra, te enteras aquí.';

  @override
  String get challengeSoonItemCall => 'Llama a alguien de la Caravana';

  @override
  String get challengeSoonItemScene =>
      'La misma escena para ambos, hasta el domingo';

  @override
  String get challengeSoonItemWin => 'Gana quien acierte más';

  @override
  String get challengeSoonJoined =>
      '¡Listo! Te avisaremos cuando abra el desafío.';

  @override
  String get challengeSoonTitle => 'El desafío está llegando';

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
  String get chestLockedShort => 'Cerrado';

  @override
  String get chestMapaMessage =>
      'Una curiosidad guardada: cada capítulo leído suma en tu ruta.';

  @override
  String get chestMapaTitle => 'Mapa del día';

  @override
  String get chestOfferBody =>
      'Terminaste la escena de hoy. Ábrelo y mira lo que el camino guardó.';

  @override
  String get chestOfferTitle => 'Llegó tu cofre del día';

  @override
  String get chestOpen => 'Abrir el cofre';

  @override
  String get chestOpenShort => 'Abrir';

  @override
  String get chestOpened => 'Abierto';

  @override
  String get chestPassoMessage =>
      'Un día más caminando — eso es lo que forma a un peregrino.';

  @override
  String get chestPassoTitle => 'Paso firme';

  @override
  String get chestRarityCommon => 'Común';

  @override
  String get chestRarityRare => 'Rara';

  @override
  String get chestRarityUltra => 'Rarísima';

  @override
  String get chestRarityUncommon => 'Poco común';

  @override
  String get chestRarityVeryRare => 'Muy rara';

  @override
  String get chestReadyShort => 'Listo para abrir';

  @override
  String get chestRewards => 'Recompensas';

  @override
  String get chestTapHint =>
      'Toca varias veces seguidas hasta llenar la barra y abrir el cofre';

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
  String get comingSoonComingHeader => 'Lo que viene';

  @override
  String get comingSoonEyebrow => 'Muy pronto';

  @override
  String get comingSoonMeanwhileCaravan =>
      'Mientras tanto, sigue en la Caravana: cada escena suma pasos en la semana.';

  @override
  String get comingSoonMeanwhileCompanion =>
      'Mientras tanto, invita a alguien a caminar contigo en Compañía y sigue en la Caravana.';

  @override
  String get comingSoonNotifyMe => 'Quiero que me avisen';

  @override
  String get comingSoonSaving => 'Guardando…';

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
  String get companionCallSubtitle =>
      'Un solo lugar: llamar a otra persona deshace la invitación anterior.';

  @override
  String get companionCallTitle => 'Llamar a caminar juntos';

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
      other: '$count días atrás en el camino',
      one: '1 día atrás en el camino',
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
      'Se está quedando atrás en nuestra compañía';

  @override
  String get companionDelayLostHeadline => 'Todavía hay lugar a mi lado';

  @override
  String get companionDelayLostInsight => 'Pero se puede seguir juntos';

  @override
  String get companionErrorAlreadyHave => 'Ya tienes una compañía.';

  @override
  String get companionErrorCreateInvite => 'No se pudo crear la invitación.';

  @override
  String get companionErrorInvalidCode =>
      'Código inválido o la compañía ya está completa.';

  @override
  String get companionErrorLeave =>
      'No se pudo salir de la compañía. Revisa tu conexión.';

  @override
  String get companionErrorLoad =>
      'No se pudo actualizar tu compañía. Revisa la conexión.';

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
  String companionInviteBody(String name) {
    return '$name te invitó a caminar juntos';
  }

  @override
  String companionInviteCalled(String name) {
    return 'Llamaste a $name. Cuando acepte, empieza la compañía.';
  }

  @override
  String get companionInviteGone => 'Esta invitación ya no está abierta.';

  @override
  String get companionInviteLabel => 'Invitación de compañía';

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
  String companionSheetPromptBodyDay2(int steps) {
    return 'Dos días de racha. Estudia con una persona — no con trescientos. Ganan +$steps pasos en la semana juntos.';
  }

  @override
  String companionSheetPromptBodyTomorrow(String scene) {
    return 'Mañana: $scene. Invita a alguien para llegar juntos.';
  }

  @override
  String get companionSheetPromptTitle => 'Invita a alguien a caminar';

  @override
  String get companionSheetPromptTitleDay2 => 'Camina con alguien';

  @override
  String get companionSoonBody =>
      'Estamos preparando la compañía: alguien que camine contigo, un día a la vez. Espera: cuando abra, te enteras aquí.';

  @override
  String get companionSoonItemNudge =>
      'Un saludo le recuerda a quien aún no caminó';

  @override
  String get companionSoonItemPair => 'Una persona camina contigo';

  @override
  String get companionSoonItemToday => 'Ambos ven quién ya caminó hoy';

  @override
  String get companionSoonJoined =>
      '¡Listo! Te avisaremos cuando abra la compañía.';

  @override
  String get companionSoonTitle => 'La compañía está llegando';

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
  String get contentNameNotAllowed =>
      'Ese nombre no se puede usar. Elige otro.';

  @override
  String get contentTextNotAllowed =>
      'Ese mensaje tiene palabras que no se pueden usar.';

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
    return 'Elige a alguien de la caravana en el mismo modo e invítalo al desafío. Cada uno hace la próxima escena de su ruta; quien llegue hasta el domingo gana +$count pasos.';
  }

  @override
  String get cornerBoardEmptyTitle => 'Ningún desafío aún';

  @override
  String get cornerBoardFilterEmpty => 'Ninguno aún';

  @override
  String get cornerBoardIdle =>
      'Ningún desafío esta semana. Invita a alguien de la caravana.';

  @override
  String get cornerBoardPickCta => 'Elegir a quién desafiar';

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
  String get cornerDifferentMode => 'No están en el mismo modo.';

  @override
  String get cornerHoldAccept => 'Mantén pulsado para aceptar';

  @override
  String get cornerHoldInvite => 'Mantén pulsado para invitar';

  @override
  String cornerIncomingFrom(String name) {
    return '$name te invitó a un desafío.';
  }

  @override
  String get cornerIncomingFromAnon => 'Alguien te invitó a un desafío.';

  @override
  String get cornerIncomingTitle => 'Invitación al desafío';

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
  String get cornerNoCorner => 'Ninguna ruta en curso para el desafío.';

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
  String get cornerPickCta => 'Desafiar';

  @override
  String get cornerPickEmpty => 'Nadie en la caravana aún.';

  @override
  String get cornerPickSubtitle =>
      'Solo puedes desafiar a quien está en el mismo modo que tú. Cada uno hace su próxima escena.';

  @override
  String get cornerPickTitle => '¿A quién vas a desafiar?';

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
    return 'Cada uno en su próxima escena hasta el domingo. +$count pasos para cada uno que llegue.';
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
  String get deleteAccountAwareness =>
      'Entiendo que se borrarán mi cuenta y mis datos';

  @override
  String get deleteAccountBody =>
      'Se borrarán tu cuenta, el progreso guardado en la nube y tu lugar en rankings, grupos y compañías. La app puede pedirte que inicies sesión de nuevo para confirmar que eres tú. No se puede deshacer.';

  @override
  String get deleteAccountDone => 'Cuenta eliminada';

  @override
  String get deleteAccountFailed =>
      'No se pudo eliminar la cuenta. Inténtalo de nuevo.';

  @override
  String get deleteAccountSubscriptionNote =>
      'Eliminar la cuenta no cancela la suscripción a Peregrino+. Cancélala en la App Store o en Google Play.';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountWrongUser =>
      'Inicia sesión con la misma cuenta que quieres eliminar.';

  @override
  String dustAwayManyFreeze(String name, int daysAway) {
    String _temp0 = intl.Intl.pluralLogic(
      daysAway,
      locale: localeName,
      other: '$daysAway días sin caminar',
      one: '1 día sin caminar',
    );
    return '$name, $_temp0. El hielo aún cubre 1 falta — sigue el camino.';
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
    return '$name, la ruta espera. Una escena basta para continuar.';
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
    return 'Últimas $countdown. Sigue el camino — el hielo aún cubre 1 día.';
  }

  @override
  String dustEveningNoFreeze2(String countdown) {
    return 'La noche cierra. Faltan $countdown — sigue el camino ahora.';
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
    return 'Faltan $countdown. Sigue el camino — el hielo cubre 1 día.';
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
  String entryForkBody(String plusTrail, String freeTrail) {
    return 'El camino sigue en $plusTrail, con Peregrino+. O sigue gratis por $freeTrail.';
  }

  @override
  String get entryForkEyebrow => 'Próximo paso';

  @override
  String entryForkFree(String trail) {
    return 'Seguir gratis por $trail';
  }

  @override
  String entryForkPlus(String trail) {
    return 'Seguir en $trail con Peregrino+';
  }

  @override
  String get entryForkTitle => '¿Hacia dónde seguir ahora?';

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
  String get entryMissionEntradaBiblia01CentralInsight =>
      'La historia empieza en Dios';

  @override
  String get entryMissionEntradaBiblia01HookNote =>
      'Toda la Biblia parte de aquí: un solo Dios, un mundo hecho por él.';

  @override
  String get entryMissionEntradaBiblia01Intro =>
      'La historia empieza con Dios haciendo un mundo bueno.';

  @override
  String get entryMissionEntradaBiblia01Objective =>
      'Ver la creación como el punto de partida de toda la Biblia.';

  @override
  String get entryMissionEntradaBiblia01Title => 'Creación';

  @override
  String get entryMissionEntradaBiblia02CentralInsight =>
      'La ruptura empieza en la desconfianza';

  @override
  String get entryMissionEntradaBiblia02HookNote =>
      'El problema de la Biblia empieza con desconfiar de la palabra de Dios.';

  @override
  String get entryMissionEntradaBiblia02Intro =>
      'Una pregunta de la serpiente, y todo se rompe.';

  @override
  String get entryMissionEntradaBiblia02Objective =>
      'Entender la caída como el problema que el resto de la Biblia resuelve.';

  @override
  String get entryMissionEntradaBiblia02Title => 'La caída';

  @override
  String get entryMissionEntradaBiblia03CentralInsight =>
      'Dios responde con una promesa';

  @override
  String get entryMissionEntradaBiblia03HookNote =>
      'Después de la caída, Dios no se rinde: empieza la respuesta con una familia.';

  @override
  String get entryMissionEntradaBiblia03Intro =>
      'Dios llama a un hombre para bendecir a todas las familias.';

  @override
  String get entryMissionEntradaBiblia03Objective =>
      'Ver en Abraham el comienzo del plan de Dios para todos los pueblos.';

  @override
  String get entryMissionEntradaBiblia03Title => 'Promesa';

  @override
  String get entryMissionEntradaBiblia04CentralInsight =>
      'La salvación viene del Señor';

  @override
  String get entryMissionEntradaBiblia04HookNote =>
      'El éxodo se vuelve el molde de la salvación en la Biblia: Dios libera a quien no puede salvarse.';

  @override
  String get entryMissionEntradaBiblia04Intro =>
      'Entre el ejército y el mar, Dios abre un camino.';

  @override
  String get entryMissionEntradaBiblia04Objective =>
      'Entender el éxodo como el retrato de la salvación que la Biblia repite.';

  @override
  String get entryMissionEntradaBiblia04Title => 'Liberación';

  @override
  String get entryMissionEntradaBiblia05CentralInsight =>
      'Alguien carga la culpa en nuestro lugar';

  @override
  String get entryMissionEntradaBiblia05HookNote =>
      'Siglos antes de Jesús, Isaías describe a un Siervo que carga la culpa del pueblo.';

  @override
  String get entryMissionEntradaBiblia05Intro =>
      'Un profeta ve a alguien herido en lugar de los demás.';

  @override
  String get entryMissionEntradaBiblia05Objective =>
      'Ver cómo los profetas apuntan a un Salvador que sufre.';

  @override
  String get entryMissionEntradaBiblia05Title => 'El Siervo';

  @override
  String get entryMissionEntradaBiblia06CentralInsight =>
      'La muerte no tiene la última palabra';

  @override
  String get entryMissionEntradaBiblia06HookNote =>
      'Todo lo anterior converge aquí: Jesús vence la muerte que entró con la caída.';

  @override
  String get entryMissionEntradaBiblia06Intro =>
      'La tumba está vacía. La historia da un giro.';

  @override
  String get entryMissionEntradaBiblia06Objective =>
      'Entender la resurrección como el centro de la historia bíblica.';

  @override
  String get entryMissionEntradaBiblia06Title => 'Resurrección';

  @override
  String get entryMissionEntradaBiblia07CentralInsight =>
      'Dios hace nuevas todas las cosas';

  @override
  String get entryMissionEntradaBiblia07HookNote =>
      'La Biblia abre con un jardín y cierra con una ciudad. Dios rehace lo que la caída rompió.';

  @override
  String get entryMissionEntradaBiblia07Intro =>
      'La historia termina donde empezó: Dios con su pueblo.';

  @override
  String get entryMissionEntradaBiblia07Objective =>
      'Ver el final de la Biblia como la restauración del comienzo.';

  @override
  String get entryMissionEntradaBiblia07Title => 'Nueva creación';

  @override
  String get entryMissionEntradaDeus01CentralInsight =>
      'Dios viene antes de todo';

  @override
  String get entryMissionEntradaDeus01HookNote =>
      'La primera frase de la Biblia no habla de nosotros: habla de Dios, que crea.';

  @override
  String get entryMissionEntradaDeus01Intro =>
      'Antes de todo, Dios. La Biblia empieza por quién es él.';

  @override
  String get entryMissionEntradaDeus01Objective =>
      'Ver que conocer a Dios empieza por él, no por nosotros.';

  @override
  String get entryMissionEntradaDeus01Title => 'En el principio, Dios';

  @override
  String get entryMissionEntradaDeus02CentralInsight =>
      'Dios se da a conocer por su nombre';

  @override
  String get entryMissionEntradaDeus02HookNote =>
      'Moisés pregunta quién lo envía. Dios responde con un nombre que no depende de nadie.';

  @override
  String get entryMissionEntradaDeus02Intro =>
      'En la zarza, Dios le dice su nombre a un fugitivo.';

  @override
  String get entryMissionEntradaDeus02Objective =>
      'Entender lo que el nombre YO SOY revela sobre Dios.';

  @override
  String get entryMissionEntradaDeus02Title => 'YO SOY';

  @override
  String get entryMissionEntradaDeus03CentralInsight => 'Dios es santo';

  @override
  String get entryMissionEntradaDeus03HookNote =>
      'Dios no es una versión más grande de nosotros. La santidad es lo que lo separa de todo.';

  @override
  String get entryMissionEntradaDeus03Intro =>
      'Isaías ve al Señor en el trono, y el templo tiembla.';

  @override
  String get entryMissionEntradaDeus03Objective =>
      'Ver por qué la santidad de Dios cambia a quien se acerca a él.';

  @override
  String get entryMissionEntradaDeus03Title => 'Santo, santo, santo';

  @override
  String get entryMissionEntradaDeus04CentralInsight =>
      'El Santo cuida de cerca';

  @override
  String get entryMissionEntradaDeus04HookNote =>
      'David llama pastor al Dios del trono. El Santo no se queda lejos.';

  @override
  String get entryMissionEntradaDeus04Intro =>
      'El Dios santo también cuida de cerca.';

  @override
  String get entryMissionEntradaDeus04Objective =>
      'Unir la santidad de Dios con su cuidado en el día a día.';

  @override
  String get entryMissionEntradaDeus04Title => 'El Señor es mi pastor';

  @override
  String get entryMissionEntradaDeus05CentralInsight =>
      'En Jesús, Dios se acercó';

  @override
  String get entryMissionEntradaDeus05HookNote =>
      'Juan empieza como Génesis: «En el principio». Ahora el Creador viene a vivir entre nosotros.';

  @override
  String get entryMissionEntradaDeus05Intro =>
      'En Jesús, Dios se acerca más que nunca.';

  @override
  String get entryMissionEntradaDeus05Objective =>
      'Ver en Jesús la forma más clara de conocer a Dios.';

  @override
  String get entryMissionEntradaDeus05Title => 'El Verbo se hizo carne';

  @override
  String get entryTrailAnsiedadeDescription =>
      'Cinco escenas para echar el mañana en el Padre — y seguir en el canon.';

  @override
  String get entryTrailAnsiedadeModuleTitle => 'Echar la ansiedad';

  @override
  String get entryTrailAnsiedadeTitle => 'Ansiedad';

  @override
  String get entryTrailConhecerADeusDescription =>
      'Cinco escenas del Creador al Verbo hecho carne — y seguir en los Evangelios.';

  @override
  String get entryTrailConhecerADeusModuleTitle => 'Dios se acerca';

  @override
  String get entryTrailConhecerADeusTitle => 'Conocer a Dios';

  @override
  String get entryTrailEntenderABibliaDescription =>
      'Siete escenas de la creación a la nueva creación — y de vuelta a Génesis 1–11.';

  @override
  String get entryTrailEntenderABibliaModuleTitle => 'Una sola historia';

  @override
  String get entryTrailEntenderABibliaTitle => 'Entender la Biblia';

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
  String get exerciseHintShowHint => 'Toca para ver la pista';

  @override
  String get exerciseHintShowQuestion => 'Toca para ver la pregunta';

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
  String get exerciseZoomLarger => 'Letra más grande';

  @override
  String get exerciseZoomSmaller => 'Letra más pequeña';

  @override
  String get exerciseZoomStage => 'Ampliar texto';

  @override
  String get explainAnswerLabel => 'Respuesta correcta';

  @override
  String get explainErrorsEmptyBody =>
      'Cuando falles una pregunta, aparecerá aquí con la respuesta correcta y el porqué.';

  @override
  String get explainErrorsEmptyTitle => 'Ningún error guardado';

  @override
  String explainErrorsEntry(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errores guardados, con las explicaciones',
      one: '1 error guardado, con la explicación',
    );
    return '$_temp0';
  }

  @override
  String get explainErrorsTitle => 'Errores explicados';

  @override
  String explainYourAnswer(String text) {
    return 'Tu respuesta: $text';
  }

  @override
  String get exploreSoonBody =>
      'Estamos pensando en herramientas para ver cuándo, dónde y con quién ocurrió cada escena. Marca lo que más quieres usar: eso decide qué llega primero.';

  @override
  String get exploreSoonEntryBadge => 'Pronto';

  @override
  String get exploreSoonEntryTitle =>
      'Atlas: línea del tiempo, lugares y personajes';

  @override
  String get exploreSoonItemAtlas =>
      'Mapas y lugares: ciudades, viajes y dónde ocurrió cada escena';

  @override
  String get exploreSoonItemCharacters =>
      'Personajes: quién es quién, familias e historias';

  @override
  String get exploreSoonItemTimeline =>
      'Línea del tiempo: reyes, profetas e imperios lado a lado';

  @override
  String get exploreSoonJoined => '¡Hecho! Te avisaremos cuando abra.';

  @override
  String get exploreSoonMeanwhile =>
      'Mientras tanto, en la Biblia, toca un versículo y luego \"Estudiar este versículo\" para ver la palabra original y sus conexiones con otros textos.';

  @override
  String get exploreSoonPickHeader => '¿Qué quieres usar?';

  @override
  String get exploreSoonTitle => 'El Atlas de la Biblia está llegando';

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
  String get groupCallShareCta => 'Compartir · código QR y código';

  @override
  String get groupCallSubtitle =>
      'La invitación aparece en la app. O comparte el código QR y el código.';

  @override
  String get groupCallTitle => 'Invitar personas';

  @override
  String get groupCreateCta => 'Crear grupo';

  @override
  String groupDaysAway(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'caminó hace $count días',
      one: 'caminó ayer',
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
  String get groupMemberDidStudy => 'Hizo el estudio de la semana';

  @override
  String get groupMenuClearStudy => 'Quitar estudio de la semana';

  @override
  String get groupMenuClose => 'Cerrar el grupo';

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
  String get groupMenuPickStudy => 'Elegir estudio de la semana';

  @override
  String get groupMenuSetGoal => 'Definir meta de la semana';

  @override
  String get groupMenuSwapStudy => 'Cambiar estudio de la semana';

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
  String get groupPickerSearchEmpty => 'Ninguna ruta con ese nombre.';

  @override
  String get groupPickerSearchHint => 'Buscar ruta o libro';

  @override
  String get groupPickerTabMine => 'Tus rutas';

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
  String get groupSeatIdle => 'aún no caminó esta semana';

  @override
  String groupSeatMakeLeader(String name) {
    return 'Pasar el liderazgo a $name';
  }

  @override
  String groupSeatMakeLeaderBody(String name) {
    return '$name marcará el estudio y la meta y saludará al grupo. Tú sigues en la lista.';
  }

  @override
  String get groupSeatNever => 'aún no caminó';

  @override
  String get groupSeatSteps => 'Pasos';

  @override
  String get groupSeatStudyDone => 'Hecho';

  @override
  String get groupSeatStudyNotYet => 'Aún no';

  @override
  String get groupSeatToday => 'caminó hoy';

  @override
  String get groupSeatViewProfile => 'Ver perfil';

  @override
  String get groupSeatWeek => 'caminó esta semana';

  @override
  String get groupSetupKindLabel => 'Para qué es el grupo';

  @override
  String groupSetupLimitHint(int limit) {
    return 'Hasta $limit personas. ¿Grupo grande? Abre otro: el discipulado ocurre en grupos pequeños.';
  }

  @override
  String get groupSetupNameLabel => 'Nombre';

  @override
  String get groupStudyDoneTapAgain => 'Ya la hiciste · toca para repasar';

  @override
  String get groupStudySwap => 'Cambiar';

  @override
  String get groupStudyTapToOpen => 'Toca para estudiar';

  @override
  String groupStudyTrailLine(String trail, int n, int total) {
    return '$trail · escena $n de $total';
  }

  @override
  String get groupWeekStudy => 'Estudio de la semana';

  @override
  String get groupsSoonBody =>
      'Estamos preparando los grupos para células, discipulado y escuela dominical. Espera: cuando abran, te enteras aquí.';

  @override
  String get groupsSoonItemLeader => 'El líder ve quién ya lo hizo';

  @override
  String get groupsSoonItemStudy => 'Un estudio por semana para el grupo';

  @override
  String get groupsSoonItemTogether =>
      'Todos caminan juntos, con una meta semanal';

  @override
  String get groupsSoonJoined =>
      '¡Listo! Te avisaremos cuando abran los grupos.';

  @override
  String get groupsSoonTitle => 'Los grupos están llegando';

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
  String get guidedPlanActsSubtitle => 'Nace la iglesia, un capítulo al día';

  @override
  String get guidedPlanActsTitle => 'Hechos en 28 días';

  @override
  String get guidedPlanAllDays => 'Día a día';

  @override
  String guidedPlanDayOf(int day, int total) {
    return 'Día $day de $total';
  }

  @override
  String guidedPlanDayShort(int day) {
    return 'Día $day';
  }

  @override
  String guidedPlanDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get guidedPlanDaysUnit => 'días';

  @override
  String guidedPlanFinished(String plan) {
    return 'Terminaste «$plan».';
  }

  @override
  String get guidedPlanFirstDays => 'Primeros días';

  @override
  String guidedPlanFreeNote(int count) {
    return 'Los primeros $count días son gratis; después, Peregrino+.';
  }

  @override
  String get guidedPlanGenesisSubtitle =>
      'De la creación a José, dos capítulos al día';

  @override
  String get guidedPlanGenesisTitle => 'Génesis en 25 días';

  @override
  String get guidedPlanGospelsSubtitle => 'Mateo, Marcos, Lucas y Juan';

  @override
  String get guidedPlanGospelsTitle => 'Evangelios en 30 días';

  @override
  String guidedPlanMeta(String subtitle, int minutes) {
    return '$subtitle · ~$minutes min/día';
  }

  @override
  String guidedPlanMinutesPerDay(int minutes) {
    return '~$minutes min/día';
  }

  @override
  String get guidedPlanNewTestamentSubtitle =>
      'De Mateo a Apocalipsis, unos 3 capítulos al día';

  @override
  String get guidedPlanNewTestamentTitle => 'Nuevo Testamento en 90 días';

  @override
  String get guidedPlanPsalmsSubtitle =>
      'Un capítulo de Proverbios y algunos Salmos al día';

  @override
  String get guidedPlanPsalmsTitle => 'Salmos y Proverbios en 31 días';

  @override
  String get guidedPlanStart => 'Empezar plan';

  @override
  String get heroEndAllBody =>
      'Nuevas rutas llegan pronto. Mientras tanto, repasa lo pendiente o lee la Biblia.';

  @override
  String get heroEndAllTitle => 'Recorriste todas las rutas';

  @override
  String get heroEndPlusBody =>
      'Las próximas rutas son de Peregrino+. La Biblia sigue abierta para leer.';

  @override
  String get heroEndPlusCta => 'Conocer Peregrino+';

  @override
  String get heroEndPlusTitle => 'Recorriste todas las rutas abiertas';

  @override
  String get homeAddName => 'Pon tu nombre';

  @override
  String get homeBibleOfflineSubtitle => 'Lee sin internet';

  @override
  String homeCarouselPosition(int index, int total) {
    return '$index de $total';
  }

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
      other: 'Faltan $count escenas para la meta de hoy',
      one: 'Falta 1 escena para la meta de hoy',
    );
    return '$_temp0';
  }

  @override
  String get homeGoalMet => 'Meta del día cumplida';

  @override
  String get homeGreetingAfternoon => 'Buenas tardes';

  @override
  String get homeGreetingEvening => 'Buenas noches';

  @override
  String get homeGreetingMorning => 'Buenos días';

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
  String get homeHeroPlusLine => 'Esta ruta sigue en Peregrino+';

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
  String homeLiturgyReadCaption(String ref) {
    return 'Leer $ref';
  }

  @override
  String get homeMoodAlive => 'Al día';

  @override
  String get homeMoodDusty => 'Racha en riesgo';

  @override
  String get homeMoodFrozen => 'Protegida por el hielo';

  @override
  String get homeMoreSeeLess => 'Ver menos';

  @override
  String homeMoreSeeMore(int count) {
    return 'Ver más · $count';
  }

  @override
  String get homeMoreToday => 'Más para hoy';

  @override
  String homeOpenProfile(String name) {
    return 'Abrir el perfil de $name';
  }

  @override
  String get homeQuestsExtraCaption => 'Pasos extra';

  @override
  String homeReviewMistakesCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preguntas para rehacer',
      one: '1 pregunta para rehacer',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewTitle => 'Repasar errores';

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
  String get homeSupportAgainBody =>
      'Tu sello sigue. Un nuevo apoyo ayuda a mantener Stway gratis.';

  @override
  String get homeSupportAgainCta => 'Apoyar de nuevo';

  @override
  String get homeSupportAgainTitle => 'Vuelve a apoyar';

  @override
  String get homeSupportBody =>
      'Tu apoyo mantiene Stway gratis para quien no puede pagar.';

  @override
  String get homeSupportCta => 'Apoyar Stway';

  @override
  String get homeSupportTitle => 'Ayuda a continuar';

  @override
  String get homeTrailDoneBody => 'Elige la siguiente y sigue aprendiendo.';

  @override
  String get homeTrailDoneTitle => 'Ruta completada';

  @override
  String homeWeeklyReviewCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escenas para repasar',
      one: '1 escena para repasar',
    );
    return '$_temp0';
  }

  @override
  String get homeWordInScene => 'En esta escena';

  @override
  String homeWordRead(String reference) {
    return 'Leer $reference';
  }

  @override
  String get homeWordWord => 'Palabra';

  @override
  String get intentBadgeHere => 'Estás aquí';

  @override
  String get intentBannerHint => 'Toca para cambiar de motivo';

  @override
  String intentBannerSemantics(String name, String tagline) {
    return 'Tu motivo: $name. $tagline.';
  }

  @override
  String intentCtaChoose(String name) {
    return 'Elegir $name';
  }

  @override
  String intentCtaContinue(String name) {
    return 'Continuar con $name';
  }

  @override
  String get intentHabitBlurb =>
      'Una escena al día: la racha nace de volver mañana.';

  @override
  String get intentHabitSkill1 => 'Volver';

  @override
  String get intentHabitSkill2 => 'Persistir';

  @override
  String get intentHabitSkill3 => 'Crecer';

  @override
  String get intentKnowBlurb =>
      'Acércate: quién es Él, y qué cambia eso en ti.';

  @override
  String get intentKnowSkill1 => 'Acercarse';

  @override
  String get intentKnowSkill2 => 'Adorar';

  @override
  String get intentKnowSkill3 => 'Confiar';

  @override
  String get intentNoneTagline => 'Toca para elegir';

  @override
  String get intentNoneTitle => 'Aún sin elegir';

  @override
  String intentOpensTrail(String trail) {
    return 'Abre: $trail';
  }

  @override
  String intentOrdinal(String ordinal) {
    return 'Motivo $ordinal';
  }

  @override
  String intentOrdinalBadge(String ordinal, String badge) {
    return 'Motivo $ordinal · $badge';
  }

  @override
  String get intentPeaceBlurb =>
      'Un respiro en medio del día: echa la ansiedad y sigue.';

  @override
  String get intentPeaceSkill1 => 'Respirar';

  @override
  String get intentPeaceSkill2 => 'Echar';

  @override
  String get intentPeaceSkill3 => 'Descansar';

  @override
  String get intentRuleFootnote =>
      'Define tu ruta de entrada · después la app sigue la última que recorriste';

  @override
  String get intentSheetEyebrow => 'Tu motivo';

  @override
  String get intentSheetTitle => '¿Qué te trae aquí?';

  @override
  String get intentSwitch => 'Cambiar';

  @override
  String get intentUnderstandBlurb =>
      'Una sola historia: desde el principio al hilo que une la Biblia.';

  @override
  String get intentUnderstandSkill1 => 'Leer';

  @override
  String get intentUnderstandSkill2 => 'Conectar';

  @override
  String get intentUnderstandSkill3 => 'Guardar';

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
  String get inviteSomeone => 'Alguien';

  @override
  String get inviteTrailGiftLine =>
      'Quien acepte elige una ruta de Peregrino+ y la recorre completa, sin pagar. Es tu pase de este mes.';

  @override
  String get inviteTrailGiftShareLine =>
      '🎁 Al aceptar, ganas una ruta de Peregrino+ por mi cuenta. Tú eliges cuál.';

  @override
  String get inviteTrailGiftTitle => 'Una ruta de regalo';

  @override
  String get journeyAntigoTestamentoBody =>
      'De Génesis a Malaquías: la creación, los patriarcas, la Ley, la conquista, los reyes, los salmos, la sabiduría y los profetas. Cada libro es una ruta, del Pentateuco al silencio entre los Testamentos.';

  @override
  String get journeyBeyondHorizon => 'Aún más allá del horizonte';

  @override
  String journeyLockedFinish(String trail) {
    return 'Termina $trail para abrir';
  }

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
  String get journeyNovoTestamentoBody =>
      'De Mateo a Apocalipsis: la vida de Jesús en los Evangelios, el nacimiento de la iglesia en Hechos, las cartas a las primeras comunidades y la esperanza del regreso de Cristo.';

  @override
  String get journeyNow => 'Ahora';

  @override
  String journeyPhase(String nn) {
    return 'Fase $nn';
  }

  @override
  String get journeyPlusCtaDetail => 'con Peregrino+';

  @override
  String journeyScenesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count escenas',
      one: 'Falta 1 escena',
    );
    return '$_temp0';
  }

  @override
  String get journeySoonHint =>
      'Próximamente · esta ruta aún se está escribiendo.';

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
  String get juntosCallFromCaravan => 'Llamar a alguien de la Caravana';

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
      'Cada escena nueva suma pasos. El día 1 empieza de cero.';

  @override
  String get juntosCaravanMonthCloses => 'Cierra en';

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
  String juntosChallengeExplainerBody(String reward) {
    return 'Mismo modo, cada uno en su próxima escena, hasta el domingo. Quien llegue gana $reward — si los dos llegan, los dos ganan.';
  }

  @override
  String get juntosChallengeExplainerTitle => '¿Quién llega antes del domingo?';

  @override
  String get juntosChallengeStep1 => 'Mismo\nmodo';

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
      'El grupo queda inactivo para todos: el código deja de funcionar y no se registra nada más. Miembros, propósito y respuestas quedan guardados, y puedes reabrirlo después.';

  @override
  String get juntosCloseRoomTitle => '¿Cerrar el grupo?';

  @override
  String get juntosCompanionEmptyBody =>
      'Invita a alguien a caminar contigo. El día en que los dos estudian, el hilo se enciende y la racha crece.';

  @override
  String get juntosCompanionEmptyTitle => 'Ninguna compañía aún';

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
  String get juntosCreateInviteError =>
      'No se pudo crear la invitación. Inténtalo de nuevo.';

  @override
  String get juntosCreateRoom => 'Crear grupo';

  @override
  String get juntosDeclineInviteError =>
      'No se pudo rechazar la invitación. Inténtalo de nuevo.';

  @override
  String get juntosEditRoomTitle => 'Editar grupo';

  @override
  String juntosFirstMilestone(int count) {
    return 'Primer hito: $count días juntos';
  }

  @override
  String get juntosGuestBody =>
      'La Caravana, la compañía y los grupos viven en tu cuenta. Entra para ver quién camina contigo.';

  @override
  String get juntosGuestCta => 'Entrar';

  @override
  String get juntosGuestTitle => 'Camina junto';

  @override
  String get juntosHaveCode => 'Tengo un código';

  @override
  String juntosInboxNews(int count) {
    return 'Novedades · $count';
  }

  @override
  String get juntosInviteAdventBody =>
      'Juntos, el regalo crece. Quien termina las escenas gana Peregrino+:';

  @override
  String get juntosInviteAdventTitle => 'Invita a alguien al Adviento';

  @override
  String get juntosInviteCompanion => 'Invitar a un compañero';

  @override
  String get juntosInviteReferralCap =>
      'Cada persona que se suscriba es 1 mes más, hasta 12 meses al año.';

  @override
  String get juntosInviteReferralEyebrow =>
      'Una invitación que se vuelve regalo';

  @override
  String get juntosInviteReferralHow =>
      'Vale la invitación de la Compañía y del grupo.';

  @override
  String get juntosInviteReferralTitle => 'Invita a alguien a caminar contigo';

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
  String juntosLevelSteady(int count, int total, String next) {
    return '$count de $total semanas firmes para $next';
  }

  @override
  String juntosLevelTitle(String tier) {
    return 'Tu nivel · $tier';
  }

  @override
  String get juntosLevelTop => 'Llegaste al nivel más alto';

  @override
  String juntosLevelWeek(int count, int goal) {
    return 'Esta semana: $count de $goal escenas nuevas';
  }

  @override
  String get juntosLevelWeekDone => 'Semana firme asegurada';

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
  String juntosNextMilestone(int count) {
    return 'Próximo hito: $count días';
  }

  @override
  String juntosOnlineSemantics(String countLabel) {
    return '$countLabel. Ver quién está por aquí';
  }

  @override
  String get juntosOpenInvite => 'Invitación abierta';

  @override
  String get juntosOpenInviteMissing => 'Falta una persona del otro lado';

  @override
  String get juntosOrInviteCompanion => 'O invitar a un compañero';

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
  String get juntosRoomJoinError =>
      'No se pudo entrar al grupo. Inténtalo de nuevo.';

  @override
  String juntosRoomJoined(String name) {
    return 'Entraste en $name.';
  }

  @override
  String get juntosRoomJoinedGeneric => 'Entraste al grupo.';

  @override
  String get juntosRoomOptions => 'Opciones del grupo';

  @override
  String juntosRoomShareText(
    String name,
    String url,
    String code,
    String storeUrl,
  ) {
    return 'Únete al grupo \"$name\" en Stway.\nToca o apunta la cámara:\n$url\n\nCódigo: $code\n\nLa lista muestra quién caminó esta semana.\n\n¿Aún no tienes la app? Descárgala: $storeUrl';
  }

  @override
  String get juntosRoomStudySet => 'Estudio marcado para el grupo';

  @override
  String get juntosRoomStudySetError =>
      'No se pudo marcar el estudio. Inténtalo de nuevo.';

  @override
  String get juntosRoomWeekLabel => 'Semana del grupo';

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
  String get juntosShowQrShare => 'Compartir';

  @override
  String get juntosSomeone => 'Alguien';

  @override
  String get juntosStudyToday => 'Estudiar hoy';

  @override
  String get juntosStudyingNow => 'Por aquí hoy';

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
  String get juntosThisWeek => 'Esta semana';

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
  String juntosWeekTogetherBonus(int count) {
    return 'La compañía ganó +$count pasos en el camino';
  }

  @override
  String get juntosWho => '¿Quién?';

  @override
  String get languageCaptionDevice => 'Usa el idioma del aparato.';

  @override
  String get languageCaptionEn => 'Inglés (Estados Unidos).';

  @override
  String get languageCaptionEs => 'Español (España).';

  @override
  String get languageCaptionPt => 'Portugués de Brasil.';

  @override
  String get languageDevice => 'Del dispositivo';

  @override
  String get languageHint =>
      'El contenido de las rutas y la Biblia siguen en portugués por ahora.';

  @override
  String get languageSheetTitle => '¿En qué idioma hablamos?';

  @override
  String get languageShortDevice => 'Auto';

  @override
  String get languageShortEn => 'EN';

  @override
  String get languageShortEs => 'ES';

  @override
  String get languageShortPt => 'PT';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get leagueActiveToday => 'Caminó · por aquí';

  @override
  String leagueBonusEncourage(int count) {
    return '+$count pasos de ánimo';
  }

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
  String get leagueLevelUpTitle => 'Subiste de nivel';

  @override
  String leaguePromotedLevelOnly(String tier) {
    return 'Ahora en el nivel $tier';
  }

  @override
  String leaguePromotedTitle(String tier) {
    return 'Subiste a $tier';
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
  String leagueStudying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count por aquí',
      one: '1 por aquí',
      zero: '0 por aquí',
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
  String leagueWalkedSeen(String walk, String seen) {
    return 'Caminó $walk · visto $seen';
  }

  @override
  String get leagueWalkedToday => 'Caminó hoy';

  @override
  String get legalPrivacy => 'Privacidad';

  @override
  String get legalTerms => 'Términos de uso';

  @override
  String get lessonAnanHelpLabel => 'Pedir ayuda a Anan';

  @override
  String get lessonAnanStuck => '¿Ayuda?';

  @override
  String get lessonAnanTeach => 'Tócame';

  @override
  String get lessonBackToQuestion => 'Volver a la pregunta';

  @override
  String get lessonBonus => 'Bonus';

  @override
  String get lessonBoss => 'Travesía';

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
  String get lessonExploreSoonCta => '¿Dónde y cuándo ocurrió esto?';

  @override
  String get lessonFactsLabel => 'Lo que dice el texto';

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
  String get lessonLifeDone => 'Hecho';

  @override
  String get lessonLifeEyebrow => 'Práctica de hoy';

  @override
  String get lessonLifeLater => 'Después';

  @override
  String get lessonLifeSubtitle => 'Vive el texto fuera de la app';

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
  String get lessonPassageTitle => 'Texto de la escena';

  @override
  String lessonPlusGrantedBy(String name) {
    return '$name te liberó esta escena de Peregrino+.';
  }

  @override
  String get lessonPractice => 'Práctica';

  @override
  String lessonQuestionProgress(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get lessonStrongTeachBody =>
      'Abre Estudiar en el versículo del escenario. Ves la palabra en el original — sin salir de la escena.';

  @override
  String get lessonStrongTeachCta => 'Abrir Estudiar';

  @override
  String get lessonStrongTeachTitle => 'Toca la referencia';

  @override
  String get lessonStudyRefCta => 'Estudiar';

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
  String get loginEntering => 'Entrando…';

  @override
  String get loginGoogleError => 'Falló el acceso con Google';

  @override
  String get loginGuestBody =>
      'Tu primera escena está hecha. Entra para guardar tus pasos y seguir con la siguiente.';

  @override
  String get loginGuestGateBody =>
      'Con la cuenta tus pasos quedan guardados y puedes suscribirte y caminar junto a otras personas.';

  @override
  String get loginGuestTitle => 'Guarda tu caminata';

  @override
  String get loginHydrateError =>
      'No se pudo cargar tu progreso. Revisa la conexión e inténtalo de nuevo.';

  @override
  String get loginLoadingBody => 'Cargando tus pasos, tu racha y tus escenas…';

  @override
  String get loginReconnect => 'Intentar reconectar';

  @override
  String get loginTermsNotice =>
      'Al entrar, aceptas los términos de uso y la política de privacidad.';

  @override
  String get loginTitle => 'Entra para continuar';

  @override
  String get loginWithApple => 'Continuar con Apple';

  @override
  String get loginWithGoogle => 'Continuar con Google';

  @override
  String get mascotAllClear => 'Todo claro. Vuelve mañana para continuar.';

  @override
  String get mascotBossHigh => 'La travesía quedó atrás. Sigue el mapa.';

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
  String get mascotHeadlinePerfect => 'Todo bien · bono de pasos';

  @override
  String get mascotHeadlineReplay => 'Volviste al texto';

  @override
  String get mascotHeadlineScene => 'Escena concluida';

  @override
  String get mascotKickerBoss => 'Travesía final';

  @override
  String get mascotKickerPerfect => 'Escena limpia';

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
  String get medalFormationPerfect25Hint => '25 escenas con 100% de aciertos';

  @override
  String get medalFormationPerfect25Title => 'Todo correcto';

  @override
  String get medalFormationPerfect3Title => 'Pasos nítidos';

  @override
  String get medalFounderHint => 'Probaste Stway antes del lanzamiento';

  @override
  String get medalFounderTitle => 'Explorador';

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
  String get medalMemoryVerse3Title => 'Versículos en el corazón';

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
  String get medalPathStreak7Title => 'Semana firme';

  @override
  String get medalPerfectBossHint =>
      'Ganaste una travesía con 100% de aciertos';

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
  String get medalVaultTitle => 'Medallas';

  @override
  String get medalWalkingInLightHint =>
      'Mantuviste 85%+ de aciertos (mín. 50 preguntas)';

  @override
  String get medalWalkingInLightTitle => 'Andando en la luz';

  @override
  String get medalWitnessShare10Title => 'Sembrador';

  @override
  String get medalWitnessShare3Title => 'Palabra llevada';

  @override
  String get medalWitnessShare50Title => 'Voz en la caravana';

  @override
  String get medalWordChapters100Title => 'Lector constante';

  @override
  String get medalWordChapters25Title => 'Lector atento';

  @override
  String get medalWordChapters3Title => 'Palabra abierta';

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
  String get moderationAlsoBlock => 'Bloquear también';

  @override
  String get moderationBlock => 'Bloquear';

  @override
  String moderationBlockConfirm(String name) {
    return 'Bloquear a $name';
  }

  @override
  String get moderationBlockFailed =>
      'No se pudo bloquear. Inténtalo de nuevo.';

  @override
  String moderationBlockHint(String name) {
    return '$name desaparece de tus rankings y ya no puede invitarte, desafiarte ni reconocerte.';
  }

  @override
  String moderationBlocked(String name) {
    return 'Bloqueaste a $name.';
  }

  @override
  String get moderationCommentHint => 'Cuéntanos qué pasó (opcional)';

  @override
  String get moderationMenuLabel => 'Denunciar o bloquear';

  @override
  String get moderationMenuSubtitle => '¿Qué quieres hacer?';

  @override
  String get moderationReasonHarassment => 'Acoso o amenaza';

  @override
  String get moderationReasonOffensiveName => 'Nombre ofensivo';

  @override
  String get moderationReasonOffensivePhoto => 'Foto inapropiada';

  @override
  String get moderationReasonOther => 'Otro motivo';

  @override
  String get moderationReasonSpam => 'Spam o estafa';

  @override
  String get moderationReport => 'Denunciar';

  @override
  String get moderationReportFailed => 'No se pudo enviar. Inténtalo de nuevo.';

  @override
  String get moderationReportHint =>
      'Nombre, foto o actitud inapropiada. El equipo lo revisa en 24 horas.';

  @override
  String get moderationReportSent =>
      'Denuncia enviada. Gracias por cuidar la caravana.';

  @override
  String moderationReportTitle(String name) {
    return 'Denunciar a $name';
  }

  @override
  String get moderationSend => 'Enviar denuncia';

  @override
  String get moderationUnblock => 'Desbloquear';

  @override
  String moderationUnblockHint(String name) {
    return '$name vuelve a aparecer para ti.';
  }

  @override
  String moderationUnblocked(String name) {
    return 'Desbloqueaste a $name.';
  }

  @override
  String get moderationUnknownName => 'Peregrino';

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
  String get morphExplainAbsolute =>
      'Absoluto = forma libre del nombre, sin un “de…” pegado.';

  @override
  String get morphExplainAdjective =>
      'Adjetivo = califica el nombre (“bueno”, “grande”, “santo”).';

  @override
  String get morphExplainAdverb =>
      'Adverbio = modifica la acción (“aún”, “mucho”, “allí”).';

  @override
  String get morphExplainAorist =>
      'Aoristo = acción vista como un punto (sin duración).';

  @override
  String get morphExplainArticle =>
      'Artículo = marca lo determinado (“el”, “la”) en hebreo.';

  @override
  String get morphExplainCohortative =>
      'Cohortativo = “vamos…” / deseo en 1ª persona (“hagamos”).';

  @override
  String get morphExplainConjunction =>
      'Conjunción = une frases o palabras (“y”, “pero”, “que”).';

  @override
  String get morphExplainConstruct =>
      'Constructo = “de…” — une dos nombres (casa de David).';

  @override
  String get morphExplainDetermined =>
      'Determinado = forma marcada como definida (“el/la”).';

  @override
  String get morphExplainDivineName =>
      'Nombre divino = referencia a Dios en el original.';

  @override
  String get morphExplainDual =>
      'Dual = exactamente dos (ojos, manos, o un par).';

  @override
  String get morphExplainFem =>
      'Femenino = género gramatical en el original (no es “hembra” en español).';

  @override
  String get morphExplainFuture => 'Futuro = acción aún por venir.';

  @override
  String get morphExplainHifil =>
      'Hifil = causativo (“hacer que alguien haga”, “hacer acontecer”).';

  @override
  String get morphExplainHitpael =>
      'Hitpael = reflexivo o recíproco (“hacerse a sí”, “unos a otros”).';

  @override
  String get morphExplainHofal => 'Hofal = pasiva del hifil (“fue causado a”).';

  @override
  String get morphExplainImperative => 'Imperativo = orden o pedido directo.';

  @override
  String get morphExplainImperfectGk =>
      'Imperfecto griego = acción continua o repetida en el pasado.';

  @override
  String get morphExplainImperfectHeb =>
      'Imperfecto = acción en curso, habitual o futura.';

  @override
  String get morphExplainInfAbsolute =>
      'Infinitivo absoluto = énfasis (“ciertamente hará”, “hacer de hecho”).';

  @override
  String get morphExplainInfConstruct =>
      'Infinitivo constructo = forma verbal que se une a otra palabra (“al hacer”).';

  @override
  String get morphExplainJussive =>
      'Yusivo = deseo u orden suave en 3ª persona (“que él…”).';

  @override
  String get morphExplainMasc =>
      'Masculino = género gramatical en el original (no es “macho” en español).';

  @override
  String get morphExplainNeuter =>
      'Neutro = género gramatical sin masculino ni femenino (común en griego).';

  @override
  String get morphExplainNifal =>
      'Nifal = voz pasiva o reflexiva (“fue hecho”, “se hizo”).';

  @override
  String get morphExplainNoun =>
      'Sustantivo = nombra persona, lugar, cosa o idea.';

  @override
  String get morphExplainObjectMarker =>
      'Marcador de objeto = señala el complemento directo en hebreo (casi no se traduce).';

  @override
  String get morphExplainParticiple =>
      'Participio = acción como cualidad o estado continuo (“el que hace”).';

  @override
  String get morphExplainParticle =>
      'Partícula = palabra pequeña que amarra el sentido (no es el núcleo del versículo).';

  @override
  String get morphExplainPerfect =>
      'Perfecto = acción vista como completa (a menudo en el pasado).';

  @override
  String get morphExplainPerson1 =>
      '1.ª persona = yo / nosotros — quien habla.';

  @override
  String get morphExplainPerson2 =>
      '2.ª persona = tú / vosotros — a quien se habla.';

  @override
  String get morphExplainPerson3 =>
      '3.ª persona = él / ella / ellos — de quien se habla.';

  @override
  String get morphExplainPiel =>
      'Piel = acción intensa o causativa (“hacer de verdad”, “intensificar”).';

  @override
  String get morphExplainPl =>
      'Plural = más de uno. En algunos nombres (como Elohim), puede marcar majestad, no cantidad.';

  @override
  String get morphExplainPrep =>
      'Preposición = une el sentido (“en”, “para”, “con”, “sobre”).';

  @override
  String get morphExplainPresent => 'Presente = acción ahora o habitual.';

  @override
  String get morphExplainPronominal =>
      'Pronominal = el sufijo funciona como pronombre (“mi”, “nuestro”, “de ellos”).';

  @override
  String get morphExplainProper =>
      'Propio = nombre de persona, lugar o título específico.';

  @override
  String get morphExplainPual =>
      'Pual = pasiva del piel (“fue hecho con intensidad”).';

  @override
  String get morphExplainQal =>
      'Qal = acción simple, el sentido básico del verbo.';

  @override
  String get morphExplainSing =>
      'Singular = uno solo — una persona, cosa o acción.';

  @override
  String get morphExplainSuffix =>
      'Sufijo = terminación pegada a la palabra (a menudo “mi”, “tu”, “su”).';

  @override
  String get morphExplainVerb =>
      'Verbo = la acción o el estado en el versículo.';

  @override
  String get morphExplainWayyiqtol =>
      'Wayyiqtol = narrativa secuencial (“y entonces…”), típica de las historias.';

  @override
  String get morphExplainWeqatal =>
      'Weqatal = secuencia en perfecto — continúa la línea narrativa o instructiva.';

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
  String get myTrailsGift => 'Regalo';

  @override
  String get myTrailsPrincipal => 'Principal';

  @override
  String get myTrailsSecondary => 'Secundaria';

  @override
  String get nameSheetSubtitle =>
      'Aparece en el saludo y para quien camina contigo.';

  @override
  String get nameSheetTitle => '¿Cómo te llamamos?';

  @override
  String get navBible => 'Biblia';

  @override
  String navTabWithNews(String tab) {
    return '$tab, con novedades';
  }

  @override
  String get navTogether => 'Juntos';

  @override
  String get navTrails => 'Explorar';

  @override
  String get nextStepDeepenCta => 'Empezar';

  @override
  String nextStepDeepenLineCaminhada(int percent) {
    return 'Fuiste firme: $percent% a la primera. Ahora las mismas escenas preguntan por qué.';
  }

  @override
  String nextStepDeepenLineProfundezas(int percent) {
    return 'Fuiste firme: $percent% a la primera. Ahora las mismas escenas preguntan qué revela el texto.';
  }

  @override
  String nextStepDeepenTitle(String trail, String mode) {
    return '$trail en $mode';
  }

  @override
  String get nextStepEyebrow => 'Tu próximo paso';

  @override
  String get nextStepLater => 'Ahora no';

  @override
  String get nextStepReinforceCta => 'Practicar';

  @override
  String nextStepReinforceLine(int correct, int total) {
    return 'Acertaste $correct de $total. Son 5 preguntas de tus últimas escenas.';
  }

  @override
  String get nextStepReinforcePlusCta => 'Practicar con Peregrino+';

  @override
  String get nextStepWeakChoice => 'Practicar elegir la mejor respuesta';

  @override
  String get nextStepWeakComplete => 'Practicar completar el versículo';

  @override
  String get nextStepWeakConnect => 'Practicar unir textos';

  @override
  String get nextStepWeakInterpret => 'Practicar interpretar el texto';

  @override
  String get nextStepWeakOrder => 'Practicar el orden de los hechos';

  @override
  String nextStepWeakOther(String gesture) {
    return 'Practicar “$gesture”';
  }

  @override
  String get nextStepWeakTap => 'Practicar la palabra exacta';

  @override
  String get nextStepWeakText => 'Practicar encontrar la respuesta en el texto';

  @override
  String get nextStepWeakTrueFalse => 'Practicar verificar afirmaciones';

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
      one: 'Guardaste un versículo. ¿Qué tal revisarlo ahora?',
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
  String get notifMedalNearTitle => 'Una medalla está cerca';

  @override
  String notifMemoryBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count versículos en el mazo. Memorizar fija lo que leíste.',
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
          'Tienes $count errores para reforzar. Un refuerzo corto fija lo que viste.',
      one: 'Tienes 1 error para reforzar. Un refuerzo corto fija lo que viste.',
    );
    return '$_temp0';
  }

  @override
  String notifPlanDayBody(String title) {
    return '$title: el grupo empieza el día junto.';
  }

  @override
  String notifPlanDayTitle(int n, int total) {
    return 'Abrió el día $n de $total';
  }

  @override
  String notifPlanEveningBody(String title) {
    return '$title: todavía hay tiempo hoy.';
  }

  @override
  String notifPlanEveningTitle(int n) {
    return 'Falta el día $n del propósito';
  }

  @override
  String get notifPracticeTitle => 'Hora de practicar';

  @override
  String notifQuestsLeftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aún faltan $count tareas del día.',
      one: 'Queda 1 tarea. Una más y el día cierra.',
    );
    return '$_temp0';
  }

  @override
  String get notifReadingPlanBody => 'Tu lectura bíblica de hoy te espera.';

  @override
  String notifReadingPlanGuidedBody(int day, String plan) {
    return 'El día $day de «$plan» te espera.';
  }

  @override
  String get notifReadingPlanTitle => 'Hora de leer';

  @override
  String get notifResumeTitle => 'Hora de continuar';

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
  String notifWalkStartsBody(int total) {
    return 'Día 1 de $total: hoy la estación abre para todos.';
  }

  @override
  String notifWalkStartsTitle(String title) {
    return '$title comenzó';
  }

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
  String get notifWeeklyReviewBody =>
      'Repasa el “Hoy:” de las escenas que hiciste.';

  @override
  String get notifWeeklyReviewTitle => 'Tu repaso de la semana está listo';

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
  String nudgeWriteHint(String name) {
    return 'Escribe a $name';
  }

  @override
  String get nudgeWriteOwn => 'Escribir el mío';

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
  String get onboardingAnanHelloBody =>
      'Mi nombre significa “nube”. Como la nube que guió al pueblo de Dios por el desierto, caminaré contigo por los senderos de Stway.';

  @override
  String get onboardingAnanHelloTitle => '¡Hola! Soy Anan.';

  @override
  String get onboardingAnanLater => 'Empezar jornada';

  @override
  String get onboardingAnanSetupNow => 'Ajustar jornada';

  @override
  String get onboardingAnanSetupQuestion => '¿Qué deseas hacer ahora?';

  @override
  String get onboardingAnanWayBody =>
      'ST viene de step, que significa paso, y WAY significa camino.\n\nY toda caminata empieza con un simple paso.';

  @override
  String get onboardingAnanWayTitle =>
      'El nombre Stway tiene todo que ver con esta caminata.';

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
  String get onboardingHaveAccount => 'Ya tengo cuenta';

  @override
  String get onboardingHoldToCommit => 'Mantén pulsado para fijar';

  @override
  String get onboardingHolding => 'Fijando…';

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
  String oneTrailBody(String walking, String target) {
    return 'Estás caminando en $walking. Para empezar $target, termina $walking o sal de ella.';
  }

  @override
  String get oneTrailEyebrow => 'Una ruta a la vez';

  @override
  String oneTrailKeep(String trail) {
    return 'Seguir en $trail';
  }

  @override
  String oneTrailLeave(String trail) {
    return 'Salir de $trail';
  }

  @override
  String get oneTrailPlusLine =>
      'Con Peregrino+, caminas en varias rutas a la vez, sin perder lo que ya hiciste.';

  @override
  String get oneTrailTitle => 'Ya estás en una ruta';

  @override
  String get paywallAlreadyPlus => 'Ya eres Peregrino+';

  @override
  String get paywallAppleEula => 'Términos de Apple (EULA)';

  @override
  String get paywallAutoRenew =>
      'Se renueva automáticamente al mismo precio hasta que canceles. Cancela cuando quieras en App Store o Google Play, al menos 24 horas antes de la renovación.';

  @override
  String get paywallBestValue => 'Mejor valor';

  @override
  String get paywallBillingIssue =>
      'Hubo un problema con el pago. Actualízalo en la tienda para no perder el acceso.';

  @override
  String get paywallBuyOnce => 'Comprar';

  @override
  String get paywallCancelAnytime => 'Cancela cuando quieras.';

  @override
  String paywallEndsOn(String date) {
    return 'Cancelada. Tu acceso dura hasta el $date.';
  }

  @override
  String get paywallFounderBadge => 'Lanzamiento';

  @override
  String paywallFounderBody(String price) {
    return 'Un precio de lanzamiento para quien llega primero a Stway. Pagas $price al año mientras renueves.';
  }

  @override
  String paywallFounderDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'quedan $days días',
      one: 'queda 1 día',
      zero: 'último día',
    );
    return '$_temp0';
  }

  @override
  String paywallFounderLimitCap(int cap) {
    return 'Solo para las primeras $cap personas.';
  }

  @override
  String paywallFounderLimitUntil(String date, int cap) {
    return 'Solo hasta el $date o hasta que se agoten las $cap plazas.';
  }

  @override
  String get paywallFounderNote => 'El precio se queda mientras renueves.';

  @override
  String paywallFounderRemaining(int cap) {
    return 'de $cap plazas restantes';
  }

  @override
  String get paywallFounderTitle => 'El precio de lanzamiento';

  @override
  String get paywallFreeForever =>
      'La Biblia, libro a libro, y las rutas de entrada siguen gratis — una ruta a la vez. Siempre.';

  @override
  String get paywallHeadline => 'Mantén tu ritmo';

  @override
  String paywallLaunchFreeBody(String date) {
    return 'Todo Peregrino+ está abierto hasta el $date. Después, tú decides si quieres continuar.';
  }

  @override
  String get paywallLaunchFreeTitle => 'Gratis en el lanzamiento';

  @override
  String get paywallLifetimeActive => 'De por vida: no vence.';

  @override
  String get paywallManage => 'Gestionar suscripción';

  @override
  String get paywallManageHint =>
      'Cambiar de plan o cancelar se hace en App Store o Google Play.';

  @override
  String get paywallMoreComing => 'Y muchos otros beneficios están en camino.';

  @override
  String get paywallOffersFailed =>
      'No pudimos cargar los planes. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get paywallPerkBadgeBody =>
      'Un sello exclusivo en tu perfil y en la Caravana.';

  @override
  String get paywallPerkBadgeTitle => 'Sello de Peregrino';

  @override
  String get paywallPerkGiftBody =>
      'Cada mes, regala 1 ruta completa de Peregrino+ a quien elijas. Quien la recibe no paga nada.';

  @override
  String get paywallPerkGiftTitle =>
      'Tu suscripción le abre el camino a alguien';

  @override
  String get paywallPerkManyTrailsBody =>
      'En el gratis es una ruta a la vez. Con Peregrino+, caminas en cuantas quieras, cada una a su ritmo.';

  @override
  String get paywallPerkManyTrailsTitle => 'Varias rutas a la vez';

  @override
  String get paywallPerkPlansBody =>
      'Los Evangelios en 30 días, el Nuevo Testamento en 90 y otros caminos.';

  @override
  String get paywallPerkPlansTitle => 'Planes de lectura';

  @override
  String get paywallPerkPostcardsBody =>
      'Comparte la revelación de tu postal en video, lista para estados e historias.';

  @override
  String get paywallPerkPostcardsTitle => 'Postal animada';

  @override
  String get paywallPerkRecognitionBody =>
      'Mira quién reconoció tu camino y tus medallas.';

  @override
  String get paywallPerkRecognitionTitle => 'Reconocimiento';

  @override
  String get paywallPerkReinforceBody =>
      'Ves dónde tropiezas. Después, una práctica a tu medida.';

  @override
  String get paywallPerkReinforceTitle => 'Lo que más fallas';

  @override
  String get paywallPerkSeasonBody =>
      'El Adviento, la Navidad, la Pascua y las próximas temporadas cuando lleguen: una escena por día y un repaso cada semana.';

  @override
  String get paywallPerkSeasonTitle => 'Rutas de temporada';

  @override
  String get paywallPerkThemesBody =>
      'Sermón del Monte, La Promesa, Oración, Familia, Historia de la Iglesia y otras rutas — completas desde la 1ª escena.';

  @override
  String get paywallPerkThemesTitle => 'Rutas por tema';

  @override
  String get paywallPerkYearReviewBody =>
      'El resumen completo: la Biblia que encendiste, tus hitos, tu perfil del año y el video para compartir.';

  @override
  String get paywallPerkYearReviewTitle => 'Tu año entero';

  @override
  String get paywallPitch =>
      'Tu apoyo mantiene Stway gratis para quien no puede pagar.\nY además recibes los beneficios de abajo.';

  @override
  String get paywallPlanAnnual => 'Anual';

  @override
  String get paywallPlanFounder => 'Pionero';

  @override
  String get paywallPlanLifetime => 'De por vida';

  @override
  String get paywallPlanMonthly => 'Mensual';

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
  String paywallPricePerMonthShort(String price) {
    return '$price/mes';
  }

  @override
  String paywallPricePerYearShort(String price) {
    return '$price/año';
  }

  @override
  String paywallPriceWeekly(String price) {
    return '$price a la semana';
  }

  @override
  String paywallPromoSubscribeNote(String date) {
    return 'Puedes suscribirte ya: el plan empieza hoy, según las reglas de la tienda, sin esperar al $date.';
  }

  @override
  String get paywallPurchaseAlreadyOwned =>
      'Esta cuenta de la tienda ya tiene Peregrino+. Toca Restaurar compra.';

  @override
  String get paywallPurchaseFailed => 'No se pudo completar la compra.';

  @override
  String get paywallPurchaseNoAccess =>
      'La compra se hizo, pero Peregrino+ no llegó a esta cuenta. Toca Restaurar compra.';

  @override
  String get paywallPurchasePending =>
      'Pago en proceso. Peregrino+ se abre en cuanto la tienda lo confirme.';

  @override
  String paywallRenewsOn(String date) {
    return 'Se renueva el $date.';
  }

  @override
  String get paywallRestore => 'Restaurar compra';

  @override
  String get paywallRestoreDone =>
      'Suscripción restaurada. ¡Qué bueno tenerte de vuelta!';

  @override
  String get paywallRestoreFailed => 'No se pudo restaurar la compra.';

  @override
  String get paywallRestoreNone =>
      'No hay suscripción activa en esta cuenta de la tienda.';

  @override
  String paywallSave(int percent) {
    return 'Ahorra $percent%';
  }

  @override
  String paywallStartTrial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Empezar $count días gratis',
      one: 'Empezar 1 día gratis',
    );
    return '$_temp0';
  }

  @override
  String get paywallSubscribe => 'Suscribirme';

  @override
  String get paywallThanks => 'Gracias por apoyar Stway.';

  @override
  String paywallTimelineChargeBody(String price) {
    return 'Empieza el cobro: $price. Cancela antes y no pagas nada.';
  }

  @override
  String paywallTimelineDay(int day, String date) {
    return 'Día $day · $date';
  }

  @override
  String get paywallTimelineReminderBody =>
      'Te avisamos que la prueba está terminando.';

  @override
  String paywallTimelineTitle(int days) {
    return 'Cómo funciona la prueba gratis de $days días';
  }

  @override
  String get paywallTimelineToday => 'Hoy';

  @override
  String get paywallTimelineTodayBody =>
      'Todo Peregrino+ desbloqueado, sin pagar nada.';

  @override
  String get paywallTitheLink => 'Ver el manifiesto';

  @override
  String get paywallTitheOffer =>
      'El 10% de los ingresos netos de Peregrino+ va a misiones y traducción de la Biblia.';

  @override
  String get paywallTithePaid =>
      'Tu suscripción también sostiene el campo: el 10% de los ingresos netos va a misiones y traducción de la Biblia.';

  @override
  String get paywallTitle => 'Peregrino+';

  @override
  String paywallTrialDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días gratis',
      one: '1 día gratis',
    );
    return '$_temp0';
  }

  @override
  String paywallTrialUntil(String date) {
    return 'Prueba gratis hasta el $date. Después, se renueva sola.';
  }

  @override
  String get paywallUnavailable =>
      'La suscripción aún no está disponible en esta versión.';

  @override
  String get paywallWelcomeBody =>
      'Tu apoyo mantiene Stway gratis para quien no puede pagar.';

  @override
  String get paywallWelcomeTitle => '¡Eres Peregrino+!';

  @override
  String get paywallYourPlan => 'Tu plan';

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
  String get pilgrimBadge => 'Peregrino';

  @override
  String pilgrimBooksDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count terminados',
      one: '1 terminado',
    );
    return '$_temp0';
  }

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
  String get pilgrimCollections => 'Cofre';

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
  String pilgrimMoreBooks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count libros',
      one: '+1 libro',
    );
    return '$_temp0';
  }

  @override
  String pilgrimMoreTrails(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count rutas',
      one: '+1 ruta',
    );
    return '$_temp0';
  }

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
  String get pilgrimRankPodium => 'En el podio';

  @override
  String get pilgrimRankRunnerUp => 'Subcampeón';

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
  String get pilgrimTrails => 'Rutas';

  @override
  String pilgrimTrailsInProgress(int count) {
    return '$count en curso';
  }

  @override
  String get pilgrimYourTrail => 'Tu ruta';

  @override
  String get pilgrimYourTrails => 'Tus rutas';

  @override
  String get pioneerBadge => 'Pionero';

  @override
  String get planAllRead => 'Todo leído';

  @override
  String get planAlreadyRead => 'Ya leídos';

  @override
  String get planAnswerCta => 'Responder';

  @override
  String get planAnswerDelete => 'Borrar';

  @override
  String get planAnswerDeleteBody => 'Desaparece para todo el grupo.';

  @override
  String get planAnswerDeleteTitle => '¿Borrar esta respuesta?';

  @override
  String get planAnswerEmpty => 'Nadie más respondió todavía.';

  @override
  String get planAnswerError => 'No se pudo enviar. Inténtalo de nuevo.';

  @override
  String get planAnswerHint =>
      'Mantén pulsada una respuesta para denunciarla o borrarla.';

  @override
  String get planAnswerSaved => 'Respuesta enviada.';

  @override
  String get planAnswerSend => 'Enviar';

  @override
  String get planAnswerSheetHint =>
      'Escribe pocas líneas. Solo el grupo lo ve.';

  @override
  String planAnswersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas ya respondieron.',
      one: '1 persona ya respondió.',
      zero: 'Nadie respondió todavía.',
    );
    return '$_temp0';
  }

  @override
  String get planAnswersLocked => 'Responde para ver lo que escribió el grupo.';

  @override
  String get planAnswersLockedPrivate =>
      'Tu respuesta queda entre tú y el líder.';

  @override
  String get planAnswersNowOpen =>
      'Quien responda ve las respuestas del grupo.';

  @override
  String get planAnswersNowPrivate => 'Ahora solo tú ves las respuestas.';

  @override
  String get planAnswersPrivateNote =>
      'En este grupo, las respuestas quedan con el líder.';

  @override
  String planAnswersTitle(int n) {
    return 'Respuestas del día $n';
  }

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
  String planApproxMinutesPerDay(String duration) {
    return '~$duration';
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
  String planAutoTitle(String what, int count) {
    return '$what en $count días';
  }

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
  String planCatchUpHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días para recuperar',
      one: '1 día para recuperar',
    );
    return '$_temp0';
  }

  @override
  String get planCatchUpTag => 'Recuperar';

  @override
  String planChain(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cadena de $count días',
      one: 'Cadena de 1 día',
    );
    return '$_temp0';
  }

  @override
  String get planChainBody =>
      'Cuando la mitad del grupo cumple el día en su fecha, la cadena crece.';

  @override
  String get planChainZero => 'Empiecen la cadena';

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
  String get planCloseReveal => 'Cerrar y revelar';

  @override
  String get planClosing => 'Cerrando…';

  @override
  String get planClosingBannerTitle => 'El propósito del grupo fue cerrado';

  @override
  String planCoverDay(int n, int total) {
    return 'Día $n de $total';
  }

  @override
  String get planCoverNoneToday => 'Nadie fue hoy todavía';

  @override
  String planCoverStarts(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Empieza en $days días',
      one: 'Empieza mañana',
      zero: 'Empieza hoy',
    );
    return '$_temp0';
  }

  @override
  String planCoverToday(int done, int total) {
    return '$done de $total ya fueron hoy';
  }

  @override
  String planCoverTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caminan juntos',
      one: '1 camina aquí',
    );
    return '$_temp0';
  }

  @override
  String get planDailyReading => 'Lectura al día';

  @override
  String planDateRange(int count, String from, String to) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0 · del $from al $to';
  }

  @override
  String planDayDate(int n, String date) {
    return 'Día $n · $date';
  }

  @override
  String planDayDone(int n) {
    return 'Día $n hecho';
  }

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
  String get planDayEditNote => 'Mensaje de quien guía (opcional)';

  @override
  String get planDayEditQuestion => 'Pregunta';

  @override
  String get planDayEmpty => 'Sin escena ni capítulo este día';

  @override
  String planDayNoteLine(String text) {
    return 'Mensaje: $text';
  }

  @override
  String planDayNumber(int day) {
    return 'Día $day';
  }

  @override
  String planDayQuestionLine(String text) {
    return 'Pregunta: $text';
  }

  @override
  String get planDeadlineBody =>
      'Dividimos lo que falta en porciones iguales hasta el plazo — en el orden de la Biblia o en el orden de los acontecimientos. Los capítulos que ya leíste se omiten.';

  @override
  String planDeadlineMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '1 mes',
    );
    return '$_temp0';
  }

  @override
  String get planDeadlineQuestion =>
      '¿En cuánto tiempo quieres leer la Biblia?';

  @override
  String planDeadlineYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count años',
      one: '1 año',
    );
    return '$_temp0';
  }

  @override
  String planDeadlineYearsMonths(String years, String months) {
    return '$years y $months';
  }

  @override
  String get planDone => 'Hecho';

  @override
  String planEditorCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días con algo para hacer',
      one: '1 día con algo para hacer',
      zero: 'Ningún día en el período',
    );
    return '$_temp0';
  }

  @override
  String get planEditorDayOpen => 'Ya abrió';

  @override
  String planEditorDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get planEditorDuration => 'Duración';

  @override
  String get planEditorDurationBody =>
      'Cuántas semanas camina junto el grupo. Tú eliges el día de inicio; el final cierra la última semana.';

  @override
  String planEditorDurationSeason(String name) {
    return 'Sigue las fechas de $name: un día del propósito para cada día de la estación.';
  }

  @override
  String planEditorDurationTrail(String name) {
    return 'Sigue la ruta $name: un día del propósito para cada escena.';
  }

  @override
  String get planEditorEnd => 'Termina';

  @override
  String get planEditorHideDays => 'Ocultar los días';

  @override
  String get planEditorHowLong => 'Por cuánto tiempo';

  @override
  String planEditorNameDefault(int count) {
    return 'Propósito de $count días';
  }

  @override
  String get planEditorNeedContent =>
      'Elige la escena de la ruta o el capítulo de la Biblia para empezar.';

  @override
  String get planEditorQuestion => 'Pregunta del día';

  @override
  String planEditorReadingEnds(int n) {
    return 'El libro termina el día $n; después, sin capítulo.';
  }

  @override
  String planEditorReadingPreview(String first, String last) {
    return 'Día 1: $first · último día: $last';
  }

  @override
  String get planEditorRename => 'Editar el nombre';

  @override
  String get planEditorRestHint =>
      'Toca un día para dejarlo de descanso: ese día no abre nada.';

  @override
  String get planEditorRestShort => 'Días de la semana con propósito';

  @override
  String get planEditorSave => 'Guardar';

  @override
  String get planEditorSaveError => 'No se pudo guardar el propósito.';

  @override
  String get planEditorSaveNew => 'Empezar el propósito';

  @override
  String get planEditorSaved => 'Propósito guardado. El grupo ya lo ve.';

  @override
  String planEditorShowDays(int count) {
    return 'Ver la pregunta de cada día ($count)';
  }

  @override
  String get planEditorStart => 'Empieza';

  @override
  String get planEditorTitleEdit => 'Editar propósito';

  @override
  String get planEditorTitleNew => 'Nuevo propósito';

  @override
  String planEditorWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas',
      one: '1 semana',
    );
    return '$_temp0';
  }

  @override
  String get planEditorWhatDaily => 'Lo que el grupo hace cada día';

  @override
  String get planEmptyCta => 'Crear el propósito';

  @override
  String get planEmptyLabel => 'Propósito del grupo';

  @override
  String get planEmptyLeaderBody =>
      'Elige la ruta, el libro y las fechas. Cada día el grupo recibe una escena, un capítulo y una pregunta.';

  @override
  String get planEmptyLeaderTitle => '¿Cuál será el propósito del grupo?';

  @override
  String planEmptyMemberBody(String leader) {
    return '$leader elige la ruta, el libro y las fechas. Después, el día de cada uno aparece aquí.';
  }

  @override
  String get planEmptyMemberTitle => 'El propósito aún no empezó';

  @override
  String get planEndBody =>
      'Los días que faltan se quitan y el propósito termina hoy. Lo que el grupo ya hizo sigue contando.';

  @override
  String get planEndConfirm => 'Terminar';

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
  String get planEndTitle => '¿Terminar el propósito?';

  @override
  String get planEstimate => 'Estimación';

  @override
  String get planFinished => 'Plan completado';

  @override
  String planFirstDay(String items) {
    return 'El día 1: $items';
  }

  @override
  String get planGoScene => 'Abrir la escena';

  @override
  String get planHearthEnds => 'Termina en';

  @override
  String planHearthEndsIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Termina en $days días',
      one: 'Termina mañana',
      zero: 'Termina hoy',
    );
    return '$_temp0';
  }

  @override
  String get planHearthLabel => 'Quién camina junto';

  @override
  String get planHearthStarts => 'Empieza en';

  @override
  String get planInviteBody =>
      'Tú eliges cuándo empieza y cuándo termina. Cada día el grupo recibe algo para hacer junto: un capítulo, una escena y una pregunta.';

  @override
  String get planInviteTitle => 'Crear un propósito';

  @override
  String get planItemManual => 'Marcar el día como hecho';

  @override
  String get planItemManualBody =>
      'Hoy es solo tú y Dios. Márcalo cuando termines.';

  @override
  String get planItemQuestion => 'Pregunta del día';

  @override
  String planItemRead(String ref) {
    return 'Leer $ref';
  }

  @override
  String planItemScene(String title) {
    return 'Escena: $title';
  }

  @override
  String get planJoin => 'Me apunto';

  @override
  String get planJoined => 'Estás dentro';

  @override
  String planJoinedCount(int count, int total) {
    return '$count de $total están dentro';
  }

  @override
  String planJoinedToast(String when) {
    return 'Estás dentro. El día 1 abre $when.';
  }

  @override
  String planLabelDay(int n, int total) {
    return 'Propósito · Día $n de $total';
  }

  @override
  String get planLabelEnded => 'Propósito terminado';

  @override
  String planLabelStartsIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Propósito · empieza en $days días',
      one: 'Propósito · empieza mañana',
      zero: 'Propósito · empieza hoy',
    );
    return '$_temp0';
  }

  @override
  String get planLastDayDone => 'Era el último día del propósito.';

  @override
  String get planLockedGuidedBody =>
      'Tus 3 días gratis de este plan terminaron. Continúa con Peregrino+; la Biblia entera sigue gratis.';

  @override
  String get planMarkDayRead => 'Marcar la lectura del día';

  @override
  String get planMenuAnswersOpen => 'Abrir respuestas al grupo';

  @override
  String get planMenuAnswersPrivate => 'Cerrar respuestas (solo el líder ve)';

  @override
  String get planMenuCreate => 'Crear propósito';

  @override
  String get planMenuEdit => 'Editar propósito';

  @override
  String get planMenuEnd => 'Terminar el propósito';

  @override
  String planMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get planModeDaily => 'Tiempo al día';

  @override
  String get planModeDeadline => 'Plazo';

  @override
  String planNextOpens(int n, String when) {
    return 'El día $n abre $when.';
  }

  @override
  String get planNextReading => 'Próxima lectura';

  @override
  String planNotStartedBody(int days, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Empieza en $days días, $date.',
      one: 'Empieza mañana, $date.',
    );
    return '$_temp0 El primer día, la escena y el capítulo del grupo aparecen aquí.';
  }

  @override
  String get planNotStartedTitle => 'El propósito aún no empezó';

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
  String planPerDay(int count) {
    return '$count por día';
  }

  @override
  String get planPickReadingChapter => 'Capítulo';

  @override
  String get planPickReadingSave => 'Empezar aquí';

  @override
  String get planPickReadingSubtitle => 'El grupo lee en orden desde aquí.';

  @override
  String get planPickReadingTitle => 'Libro y capítulo de inicio';

  @override
  String get planPickSceneTitle => 'Escena de inicio';

  @override
  String planPortionMeta(int minutes, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~$minutes min · $count capítulos',
      one: '~$minutes min · 1 capítulo',
    );
    return '$_temp0';
  }

  @override
  String planProgressBible(int percent) {
    return '$percent% de la Biblia leída';
  }

  @override
  String planProgressGuided(int percent) {
    return '$percent% del plan';
  }

  @override
  String planPulseDone(int done, int total, int n) {
    return '$done de $total ya cumplieron el día $n';
  }

  @override
  String planPulseNone(int n) {
    return 'Nadie cumplió el día $n todavía. Sé el primero.';
  }

  @override
  String get planPulseTitle => 'Hoy en el grupo';

  @override
  String planQ1(String ref) {
    return '¿Qué muestra $ref sobre quién es Dios?';
  }

  @override
  String planQ10(String ref) {
    return '¿Qué promesa o advertencia aparece en $ref?';
  }

  @override
  String planQ2(String ref) {
    return '¿Qué frase de $ref se quedó contigo hoy?';
  }

  @override
  String planQ3(String ref) {
    return '¿Qué te pide $ref esta semana?';
  }

  @override
  String planQ4(String ref) {
    return '¿Dónde te ves en $ref?';
  }

  @override
  String planQ5(String ref) {
    return '¿Qué te sorprendió en $ref?';
  }

  @override
  String planQ6(String ref) {
    return '¿Por qué te hace agradecer $ref?';
  }

  @override
  String planQ7(String ref) {
    return '¿Qué pregunta llevarías al grupo sobre $ref?';
  }

  @override
  String planQ8(String ref) {
    return '¿Cómo apunta $ref a Jesús?';
  }

  @override
  String planQ9(String ref) {
    return '¿Qué quieres pedirle a Dios después de leer $ref?';
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
  String get planReminderBody =>
      'Un aviso al día, a la hora que elijas, hasta la lectura del día.';

  @override
  String get planReminderHeader => 'Recordatorio diario';

  @override
  String planReminderHour(String hour) {
    return '$hour h';
  }

  @override
  String get planReminderOff => 'Apagado';

  @override
  String get planRestToday => 'Hoy es día de descanso';

  @override
  String get planReveal => 'Ver la revelación';

  @override
  String get planRevealConstantBody => 'Cumplió más días en su fecha.';

  @override
  String planRevealEyebrow(String room) {
    return 'Propósito · $room';
  }

  @override
  String get planRevealFaithfulBody =>
      'Cumplieron todos los días. Cada uno gana el sello.';

  @override
  String planRevealFaithfulCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas cumplieron todos los días del propósito.',
      one: '1 persona cumplió todos los días del propósito.',
    );
    return '$_temp0';
  }

  @override
  String get planRevealFaithfulNone =>
      'Esta vez nadie cumplió todos los días. El próximo propósito es una nueva oportunidad.';

  @override
  String get planRevealFaithfulTitle => 'Fieles en el propósito';

  @override
  String planRevealGroupLine(int pct) {
    return 'El grupo cumplió el $pct% de los días del propósito.';
  }

  @override
  String get planRevealGroupPct =>
      'de los días del propósito, el grupo cumplió junto';

  @override
  String get planRevealYourSeal =>
      'Ganaste el sello Fiel. Queda junto a tu nombre en el grupo.';

  @override
  String planSeatAnswerDay(int n) {
    return 'Día $n';
  }

  @override
  String planSeatAnswersHidden(String name) {
    return 'Responde los mismos días para ver lo que escribió $name.';
  }

  @override
  String get planSeatAnswersLabel => 'Respuestas';

  @override
  String get planSeatDays => 'Días del propósito';

  @override
  String get planSeatIn => 'Dentro';

  @override
  String get planSeatLabel => 'Propósito';

  @override
  String get planSeatNotIn => 'Aún no';

  @override
  String get planSectionDeadline => 'Terminar en';

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
  String planSourceChangedFollows(String name, int now) {
    return '$name: $now días. La duración y las preguntas siguen la nueva elección.';
  }

  @override
  String planSourceChangedLonger(String name, int now, int before) {
    return '$name es más larga que la elección anterior: $now días en vez de $before. La duración y las preguntas siguen la nueva elección.';
  }

  @override
  String planSourceChangedSame(String name, int now) {
    return '$name tiene la misma duración que la elección anterior: $now días. Las preguntas siguen la nueva elección.';
  }

  @override
  String planSourceChangedShorter(String name, int now, int before) {
    return '$name es más corta que la elección anterior: $now días en vez de $before. La duración y las preguntas siguen la nueva elección.';
  }

  @override
  String get planSourceFromTomorrow =>
      'El propósito ya empezó: el cambio vale desde mañana.';

  @override
  String get planSourcePick => 'Elegir';

  @override
  String get planSourceQuestionBody =>
      'Cada día el grupo responde una pregunta, sacada de la escena del día o, sin escena, del capítulo. Elige para ver cada día y cambiar la que quieras.';

  @override
  String get planSourceQuestionNone =>
      'Elige la escena o el capítulo: la pregunta sale de ellos.';

  @override
  String get planSourceQuestionOff =>
      'Apagada: el grupo hace la escena y lee el capítulo, sin pregunta para responder.';

  @override
  String get planSourceReading => 'Capítulo de la Biblia';

  @override
  String get planSourceReadingEmpty =>
      'El grupo aún no tiene lectura. Elige un libro y el capítulo de inicio.';

  @override
  String planSourceReadingFrom(String book, int from) {
    return '$book, desde el capítulo $from';
  }

  @override
  String get planSourceReadingScenes =>
      'Sigue las escenas: cada día trae el capítulo del pasaje de la escena del día.';

  @override
  String get planSourceRemove => 'Quitar';

  @override
  String planSourceRestart(String date) {
    return 'El propósito vuelve a empezar en el día 1, el $date. Quien ya entró sigue dentro.';
  }

  @override
  String get planSourceScene => 'Escena de la ruta';

  @override
  String planSourceSceneCount(int scenes, int days) {
    return 'Una escena por día: $scenes de $days días tienen escena.';
  }

  @override
  String get planSourceSceneEmpty =>
      'El grupo aún no tiene estudio. Elige la escena de inicio de la ruta.';

  @override
  String planSourceSceneFrom(String trail, String title) {
    return '$trail · desde “$title”';
  }

  @override
  String planSourceSeason(String name) {
    return '$name · cada día trae la escena del día de la estación, en la misma fecha.';
  }

  @override
  String get planStartAnother => 'Empezar otro propósito';

  @override
  String planStartCta(String duration) {
    return 'Empezar plan · $duration/día';
  }

  @override
  String get planStepRead => 'Lectura';

  @override
  String get planStepScene => 'Escena';

  @override
  String get planSuggestGeneral => 'General';

  @override
  String get planSuggestLife => 'Para la vida';

  @override
  String get planSuggestText => 'Sobre el texto';

  @override
  String get planSuggestTitle => 'Sugerencias';

  @override
  String get planSwitchBody =>
      'El plan actual terminará. Los capítulos ya leídos siguen marcados en la Biblia.';

  @override
  String get planSwitchTitle => '¿Cambiar de plan?';

  @override
  String get planTimePerDay => 'Tiempo por día';

  @override
  String get planTitle => 'Plan de lectura';

  @override
  String get planTodayDoneBody =>
      'Porción de hoy completada. Vuelve mañana — o sigue explorando la Biblia libremente.';

  @override
  String get planTomorrow => 'mañana';

  @override
  String get planWaitReveal => 'Quien guía va a revelar cómo le fue al grupo.';

  @override
  String planYouDid(int done, int total) {
    return 'Cumpliste $done de $total días';
  }

  @override
  String get plansCatalogBody =>
      'Cada día viene listo; si faltas uno, sigues donde quedaste.';

  @override
  String get plansCatalogHeader => 'Planes de lectura';

  @override
  String get plansGuidedPlusNote =>
      'La Biblia entera es siempre gratis. Los guiados empiezan con 3 días gratis; después, Peregrino+.';

  @override
  String get plansWholeBibleTitle => 'Biblia completa';

  @override
  String get plusBillingHomeAction => 'Ver mi plan';

  @override
  String get plusBillingHomeBody =>
      'La tienda no pudo cobrar. Actualiza el pago para no perder el acceso cuando venza el plan.';

  @override
  String get plusBillingHomeTitle => 'Problema con el pago de Peregrino+';

  @override
  String get plusEndedHomeBody =>
      'Tus repasos, planes guiados y las rutas de temporada te esperan. La Biblia y las escenas siguen gratis, como siempre.';

  @override
  String get plusEndedHomeTitle => 'Tu Peregrino+ terminó';

  @override
  String get plusGraceHomeBody =>
      'Aún tienes unos días de acceso mientras la tienda confirma. Abre para ver tu plan.';

  @override
  String get plusGraceHomeTitle => 'Tu Peregrino+ venció hace poco';

  @override
  String get plusLockedSheetBody =>
      'Esta ruta es parte de Peregrino+. La Biblia, libro a libro, y las rutas de entrada siguen gratis — una ruta a la vez.';

  @override
  String get plusLockedSheetCta => 'Conocer Peregrino+';

  @override
  String get plusNoticeContinue => 'Continuar con Peregrino+';

  @override
  String plusNoticeEndedBody(String date) {
    return 'El lanzamiento terminó el $date. Gracias por caminar con nosotros desde el inicio.';
  }

  @override
  String get plusNoticeEndedTitle => 'Peregrino+ gratis terminó';

  @override
  String plusNoticeEndingBody(String date) {
    return 'Dura hasta el $date. Después, tú eliges si quieres continuar.';
  }

  @override
  String get plusNoticeEndingTitle => 'Tu Peregrino+ gratis está terminando';

  @override
  String get plusNoticeFreeBible => 'La Biblia, libro a libro';

  @override
  String get plusNoticeFreeHeader => 'Sigue gratis, siempre';

  @override
  String get plusNoticeFreeLearning =>
      'Repaso semanal, errores explicados y cómo crece tu lectura';

  @override
  String get plusNoticeFreeScenes =>
      'Una ruta a la vez, en los 3 modos — y las rutas de entrada';

  @override
  String get plusNoticeFreeSocial => 'Caravana y compañía';

  @override
  String get plusNoticeFreeSocialCaravan => 'Caravana';

  @override
  String get plusNoticeFreeStreak => 'Tu racha diaria y los recordatorios';

  @override
  String get plusNoticeLockedHeader => 'Solo con Peregrino+';

  @override
  String plusNoticeLockedHeaderSoon(String date) {
    return 'Desde el $date, solo con Peregrino+';
  }

  @override
  String plusOfferDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count días',
      one: 'Falta 1 día',
    );
    return '$_temp0';
  }

  @override
  String plusOfferFromPrice(String price) {
    return 'Después, desde $price/mes. Cancela cuando quieras.';
  }

  @override
  String get plusOfferScenesBody =>
      'Estás creando un hábito. Peregrino+ te ayuda a no parar y mantiene Stway gratis para quien no puede pagar.';

  @override
  String plusOfferScenesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escenas concluidas',
      one: '1 escena concluida',
    );
    return '$_temp0';
  }

  @override
  String plusOfferTryFree(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Probar $count días gratis',
      one: 'Probar 1 día gratis',
    );
    return '$_temp0';
  }

  @override
  String get plusOfferWinbackBody =>
      'Tu Peregrino+ terminó, pero tus repasos, planes y las rutas de temporada siguen aquí. Volver es un toque — y mantiene Stway gratis para quien no puede pagar.';

  @override
  String get plusOfferWinbackTitle => 'Tu Peregrino+ te extraña';

  @override
  String get plusPerksHeader => 'Con Peregrino+';

  @override
  String plusPerksMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Y $count beneficios más',
      one: 'Y 1 beneficio más',
    );
    return '$_temp0';
  }

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
  String get postcardEyebrow => 'Nueva postal';

  @override
  String get postcardRedo => 'Repetir la escena';

  @override
  String get postcardReveal => 'Revelar la postal';

  @override
  String get postcardSavedNew => 'Nueva postal guardada';

  @override
  String postcardShareChip(int index, int total, String trail) {
    return 'Postal $index de $total · $trail';
  }

  @override
  String postcardShareFrom(String name) {
    return 'De: $name';
  }

  @override
  String get postcardShareImage => 'Imagen';

  @override
  String get postcardShareRendering => 'Preparando el video…';

  @override
  String get postcardShareSheetTitle => '¿Cómo quieres enviar la postal?';

  @override
  String get postcardShareTagline => 'Una postal de mi camino';

  @override
  String postcardShareText(String insight, String ref) {
    return '$insight\n$ref\n\nUna postal de mi camino en Stway.';
  }

  @override
  String get postcardShareTo => 'Para: ti';

  @override
  String get postcardShareVideo => 'Postal animada';

  @override
  String get postcardShareVideoFailed =>
      'No se pudo crear el video. Envié la imagen.';

  @override
  String get postcardShareVideoPlus => 'Peregrino+';

  @override
  String get postcardTapHint => 'Toca la postal para revelarla';

  @override
  String get postcardYouWereHere => 'Estuviste aquí';

  @override
  String postcardsCount(int done, int total) {
    return '$done de $total';
  }

  @override
  String get postcardsEmptyBody =>
      'Completa una escena para revelar la primera.';

  @override
  String get postcardsEmptyTitle => 'Tus postales viven aquí';

  @override
  String get postcardsTitle => 'Postales';

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
  String get profileAccuracyBody =>
      'Respuestas correctas al primer intento, por modo y por gesto.';

  @override
  String get profileAccuracyEmpty =>
      'Responde algunas escenas para ver aquí tus aciertos por modo y por gesto.';

  @override
  String profileAccuracyFewGestures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Con $count respuestas en al menos dos gestos, aparecen tu punto fuerte y lo que reforzar.',
      one:
          'Con 1 respuesta en al menos dos gestos, aparecen tu punto fuerte y lo que reforzar.',
    );
    return '$_temp0';
  }

  @override
  String profileAccuracyLine(int percent, int correct, int total) {
    return '$percent% · $correct de $total';
  }

  @override
  String get profileAccuracyNoAnswers => 'Sin respuestas aún';

  @override
  String get profileAccuracyStrongest => 'Punto fuerte';

  @override
  String get profileAccuracyToStrengthen => 'Para reforzar';

  @override
  String profileBestStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mejor racha: $count días',
      one: 'Mejor racha: 1 día',
    );
    return '$_temp0';
  }

  @override
  String profileBooksFinished(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'libros concluidos',
      one: 'libro concluido',
    );
    return '$_temp0';
  }

  @override
  String get profileCoverBody =>
      'Elige la pintura de una escena que ya hiciste. Quien abra tu perfil verá esta portada.';

  @override
  String get profileCoverChange => 'Cambiar portada';

  @override
  String get profileCoverEmpty =>
      'Haz tu primera escena para ganar una pintura de portada.';

  @override
  String get profileCoverLatest => 'Más reciente';

  @override
  String get profileCoverTitle => 'Portada del perfil';

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
  String get profileGroupSealsBody =>
      'Ganados en el cierre de tu grupo, en las semanas en que hiciste todo lo que marcó el líder.';

  @override
  String profileGrowthSteady(String mode, int pct) {
    return 'Tu lectura está firme: $pct% de aciertos en $mode.';
  }

  @override
  String profileGrowthUp(String mode, int from, int to) {
    return 'Tu lectura creció: en $mode acertabas $from% y ahora $to%.';
  }

  @override
  String get profileGrowthWaiting =>
      'Sigue caminando: en unas semanas verás aquí cómo creció tu lectura.';

  @override
  String get profileInTheWord => 'En la Palabra';

  @override
  String get profileInTheWordWhisper =>
      'Versículos que guardas, anotas y los que ya enviaste.';

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
  String profileMonthWalked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días en el mes',
      one: '1 día en el mes',
      zero: 'Ningún día en el mes',
    );
    return '$_temp0';
  }

  @override
  String profileNearAlbum(String trail) {
    return 'Álbum $trail';
  }

  @override
  String profileNearAlbumLine(int done, int total, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'faltan $left',
      one: 'falta 1',
    );
    return '$done de $total postales · $_temp0';
  }

  @override
  String profileNearSeal(String name) {
    return 'Sello de $name';
  }

  @override
  String profileNearSealLine(String trail) {
    return 'En la próxima escena de $trail';
  }

  @override
  String get profileNearTitle => 'Casi ahí';

  @override
  String get profileNotes => 'Notas';

  @override
  String get profileNotesAll => 'Todas';

  @override
  String get profileNumbersPrivacyLabel =>
      'Tu marcador (posición, días en la cima y acierto)';

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
  String get profilePlusGestureNudge =>
      'Punto fuerte, qué reforzar y la práctica a medida son de Peregrino+.';

  @override
  String get profilePlusGestureNudgeCta => 'Conocer';

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
  String get profileSectionGroupSeals => 'Sellos de grupo';

  @override
  String get profileSectionGroupSealsHint =>
      'Sellos \"Fiel en la semana\" de los grupos';

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
  String get profileSectionQuestsHint => 'Tareas de la semana en curso';

  @override
  String get profileSectionRanking => 'Ranking y pasos';

  @override
  String get profileSectionRankingHint => 'Posición y pasos totales';

  @override
  String get profileSectionStudyHint =>
      'Acierto por profundidad, semanas y gestos';

  @override
  String get profileSectionTrailsHint =>
      'Progreso en las rutas y sellos obtenidos';

  @override
  String get profileSectionWordHint =>
      'Cuántos favoritos y notas (el texto queda contigo)';

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
  String get profileStatStreak => 'Días seguidos';

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
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: 'Faltan $left días para cumplir el compromiso de $goal días.',
      one: 'Falta 1 día para cumplir el compromiso de $goal días.',
    );
    return '$_temp0';
  }

  @override
  String get profileStreakStart => 'Una escena hoy enciende el primer día.';

  @override
  String profileStudyErrors(int count) {
    return 'Ver errores ($count)';
  }

  @override
  String get profileStudyErrorsNone => 'Errores explicados';

  @override
  String get profileStudyTitle => 'Mi estudio';

  @override
  String get profileThisWeek => 'Esta semana';

  @override
  String profileThisWeekSemantics(int count) {
    return 'Esta semana: $count de 7 días caminados';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileTodayLower => 'hoy';

  @override
  String get profileWeekHistory => 'Historial de semanas';

  @override
  String profileWeeksWalkedSemantics(int walked, int weeks) {
    return '$walked días caminados en las últimas $weeks semanas';
  }

  @override
  String profileWordFavorites(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count favoritos',
      one: '1 favorito',
    );
    return '$_temp0';
  }

  @override
  String profileWordNotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notas',
      one: '1 nota',
    );
    return '$_temp0';
  }

  @override
  String profileWordShared(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count compartidos',
      one: '1 compartido',
    );
    return '$_temp0';
  }

  @override
  String get profileYourJourney => 'Tu camino';

  @override
  String get promiseTrail01Intro =>
      'Todo empieza con una promesa: tierra, descendencia y bendición para todas las familias de la tierra. Sigue ese hilo de Abraham a Cristo.';

  @override
  String get promiseTrail01Note =>
      'Dios promete a un hombre sin hijos que, por medio de él, todas las familias de la tierra serán bendecidas.';

  @override
  String get promiseTrail01Title => 'En ti, todas las familias';

  @override
  String get promiseTrail02Intro =>
      'Abram todavía no tiene hijo. Dios lo saca afuera y le manda mirar el cielo.';

  @override
  String get promiseTrail02Note =>
      'Abram creyó, y le fue contado por justicia. Pablo volverá a este versículo.';

  @override
  String get promiseTrail02Title => 'Cuenta las estrellas';

  @override
  String get promiseTrail03Intro =>
      'El hijo de la promesa sube el monte. La promesa parece en peligro.';

  @override
  String get promiseTrail03Note =>
      'En el Moriah, Dios provee el cordero en lugar del hijo y confirma la promesa con juramento.';

  @override
  String get promiseTrail03Title => 'El Señor proveerá';

  @override
  String get promiseTrail04Intro =>
      'Siglos después, la familia de Abraham es un pueblo esclavo en Egipto. Parece que la promesa murió. Dios no olvidó.';

  @override
  String get promiseTrail04Note =>
      'Dios se presenta como el Dios de Abraham, de Isaac y de Jacob: la promesa antigua mueve el rescate.';

  @override
  String get promiseTrail04Title => 'Dios se acuerda';

  @override
  String get promiseTrail05Intro =>
      'Libre de Egipto, el pueblo llega al Sinaí. La promesa toma forma de alianza.';

  @override
  String get promiseTrail05Note =>
      'Israel será un reino de sacerdotes: la bendición de Abraham pasa por un pueblo para alcanzar a las naciones.';

  @override
  String get promiseTrail05Title => 'Un pueblo para las naciones';

  @override
  String get promiseTrail06Intro =>
      'Ya en la tierra, Josué vuelve a contar la historia y llama al pueblo a escoger a quién servir.';

  @override
  String get promiseTrail06Note =>
      'La tierra fue dada; la fidelidad del pueblo fallará. La promesa necesitará a alguien mayor que Israel.';

  @override
  String get promiseTrail06Title => 'En la tierra prometida';

  @override
  String get promiseTrail07Intro =>
      'El pueblo falla, pero Dios no se rinde. Ahora la promesa se concentra en un rey: David.';

  @override
  String get promiseTrail07Note =>
      'Dios escoge al menor de los hijos de Isaí. De la línea de David vendrá el rey cuyo trono no tendrá fin (2 Samuel 7).';

  @override
  String get promiseTrail07Title => 'El rey escogido';

  @override
  String get promiseTrail08Intro =>
      'Los profetas anuncian a alguien que carga la culpa de otros.';

  @override
  String get promiseTrail08Note =>
      'Como en el Moriah, alguien toma el lugar de otro: el Siervo es herido por nuestras rebeliones.';

  @override
  String get promiseTrail08Title => 'El Siervo herido';

  @override
  String get promiseTrail09Intro =>
      'El pacto del Sinaí fue roto. Dios promete otro.';

  @override
  String get promiseTrail09Note =>
      'Dios promete escribir la ley en el corazón y perdonar el pecado. Jesús llamará a la copa de la cena el nuevo pacto.';

  @override
  String get promiseTrail09Title => 'Un nuevo pacto';

  @override
  String get promiseTrail10Intro =>
      'Mateo abre el Nuevo Testamento con Jesús, hijo de David, hijo de Abraham. El hilo llega a una persona.';

  @override
  String get promiseTrail10Note =>
      'Emanuel, Dios con nosotros: el hijo prometido a Abraham y el rey prometido a David son el mismo.';

  @override
  String get promiseTrail10Title => 'Hijo de David, hijo de Abraham';

  @override
  String get promiseTrail11Intro =>
      'El cumplimiento llega pequeño: en un pesebre, anunciado a pastores.';

  @override
  String get promiseTrail11Note =>
      'El gran gozo es para todo el pueblo: eco de la bendición prometida a todas las familias de la tierra.';

  @override
  String get promiseTrail11Title => 'Gozo para todo el pueblo';

  @override
  String get promiseTrail12Intro =>
      'Pablo cierra el hilo: la promesa hecha a Abraham llega a quien cree.';

  @override
  String get promiseTrail12Note =>
      'En Cristo, la bendición de Abraham alcanza a las naciones por la fe. Y la promesa aún apunta a la nueva creación.';

  @override
  String get promiseTrail12Title => 'La bendición llega a ti';

  @override
  String get promiseTrailMapCardBody =>
      'Mira qué quedó firme en cada parte del hilo y qué pide repaso.';

  @override
  String get promiseTrailMapFirm => 'Firme';

  @override
  String promiseTrailMapReview(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count errores para repasar',
      one: '1 error para repasar',
    );
    return '$_temp0';
  }

  @override
  String get promiseTrailMapReviewCta => 'Repasar';

  @override
  String get promiseTrailMapReviewIntro =>
      'Los errores de este bloque, otra vez. Sin prisa.';

  @override
  String promiseTrailMapReviewTitle(String block) {
    return 'Repaso: $block';
  }

  @override
  String get promiseTrailMapSheetBody =>
      'Cada bloque muestra los errores que aún están en tu repaso. Repásalos y el bloque queda firme.';

  @override
  String get promiseTrailMapSynthesis => 'Síntesis';

  @override
  String get promiseTrailMapTitle => 'Mapa de la Promesa';

  @override
  String get promiseTrailModule1 => 'La promesa hecha';

  @override
  String get promiseTrailModule2 => 'La promesa guardada';

  @override
  String get promiseTrailModule3 => 'La promesa anunciada';

  @override
  String get promiseTrailModule4 => 'La promesa cumplida';

  @override
  String get promiseTrailQ1A => 'El cordero que Dios provee';

  @override
  String get promiseTrailQ1B => 'La obediencia que salva';

  @override
  String get promiseTrailQ1C => 'El monte como lugar de culto';

  @override
  String get promiseTrailQ1Correct =>
      'Dios provee el cordero en el Moriah; Juan señala a Jesús como el Cordero.';

  @override
  String get promiseTrailQ1Hint => 'Mira quién provee y qué es provisto.';

  @override
  String get promiseTrailQ1Question =>
      '¿Qué comunica Génesis 22:8 que se une a Juan 1:29?';

  @override
  String get promiseTrailQ1WrongB =>
      'Abraham obedece, pero quien provee el cordero es Dios.';

  @override
  String get promiseTrailQ1WrongC =>
      'Juan no habla del monte: habla del Cordero que quita el pecado.';

  @override
  String get promiseTrailQ2A => 'La ley del Sinaí repetida';

  @override
  String get promiseTrailQ2B => 'El nuevo pacto en la sangre de Jesús';

  @override
  String get promiseTrailQ2C => 'Un pacto solo para los profetas';

  @override
  String get promiseTrailQ2Correct =>
      'Jeremías promete un nuevo pacto; en la cena, Jesús dice que viene en su sangre.';

  @override
  String get promiseTrailQ2Hint =>
      'Busca la palabra que los dos textos repiten.';

  @override
  String get promiseTrailQ2Question =>
      '¿Qué comunica Jeremías 31:31 que se une a Lucas 22:20?';

  @override
  String get promiseTrailQ2WrongA =>
      'Jeremías dice que no será como el pacto hecho con los padres.';

  @override
  String get promiseTrailQ2WrongC =>
      'El pacto es con la casa de Israel; Jesús lo da a los discípulos en la copa.';

  @override
  String get promiseTrailQ3A => 'La bendición queda solo con Israel';

  @override
  String get promiseTrailQ3B => 'La bendición viene por la circuncisión';

  @override
  String get promiseTrailQ3C => 'El evangelio llega a las naciones por la fe';

  @override
  String get promiseTrailQ3Correct =>
      'Pablo lee Génesis 12 como el evangelio anunciado a Abraham: las naciones bendecidas por la fe.';

  @override
  String get promiseTrailQ3Hint => 'Mira quién es bendecido y por qué camino.';

  @override
  String get promiseTrailQ3Question =>
      '¿Qué comunica Génesis 12:3 que se une a Gálatas 3:8?';

  @override
  String get promiseTrailQ3WrongA =>
      'La promesa ya decía todas las familias de la tierra.';

  @override
  String get promiseTrailQ3WrongB =>
      'Pablo dice que Dios justifica a las naciones por la fe.';

  @override
  String get promiseTrailSynthIntro =>
      'Tres puentes para unir lo prometido con lo cumplido.';

  @override
  String get promiseTrailSynthNote =>
      'Desde el principio, la bendición prometida a Abraham era para todas las naciones.';

  @override
  String get promiseTrailSynthObjective =>
      'Unir la promesa a Abraham con su cumplimiento en Cristo.';

  @override
  String get promiseTrailSynthTitle => 'Travesía: la promesa entera';

  @override
  String get promiseTrailTrailDescription =>
      'De Abraham a Cristo en 12 escenas: el hilo que cose la Biblia. Cada escena también cuenta en su ruta de origen.';

  @override
  String get promiseTrailTrailTitle => 'La Promesa';

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
  String get realmVidaCrista => 'Vida cristiana';

  @override
  String get recognitionAMedal => 'Una medalla';

  @override
  String get recognitionAlready => 'Ya lo reconociste';

  @override
  String recognitionCardHearts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count corazones en tu camino',
      one: '1 corazón en tu camino',
    );
    return '$_temp0';
  }

  @override
  String recognitionDaysAgo(int count) {
    return 'Hace $count días';
  }

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
  String recognitionHeartOnMedal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count corazones en esta medalla',
      one: '1 corazón en esta medalla',
    );
    return '$_temp0';
  }

  @override
  String get recognitionHomeSeeWho => 'Ver quién te reconoció';

  @override
  String get recognitionHomeTitleAnonymous => 'Alguien reconoció tu camino';

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
  String get recognitionSceneDone => 'Escena reconocida';

  @override
  String recognitionSceneOf(String date) {
    return 'Escena del $date';
  }

  @override
  String get recognitionSummaryEmpty =>
      'Escena del día y medallas que otros vieron en ti.';

  @override
  String get recognitionTapToWithdraw => 'Toca de nuevo para retirar';

  @override
  String get recognitionWhichMedal => '¿Qué medalla viste?';

  @override
  String get recognitionWhoLockedBody => 'Peregrino+ muestra quién fue.';

  @override
  String get recognitionWhoTitle => 'Quién reconoció';

  @override
  String get recognitionYesterday => 'Ayer';

  @override
  String get recognitionYourScene => 'Tu escena';

  @override
  String referralBankedLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses de Plus guardados por invitaciones',
      one: '1 mes de Plus guardado por invitaciones',
    );
    return '$_temp0';
  }

  @override
  String get referralInviteLine =>
      'Si la persona se suscribe a Peregrino+, ganas 1 mes de Peregrino+ gratis.';

  @override
  String referralRewardGranted(String name) {
    return '$name se suscribió a Peregrino+ con tu invitación. ¡Ganaste 1 mes de Plus!';
  }

  @override
  String get referralRewardGrantedAnon =>
      'Alguien se suscribió a Peregrino+ con tu invitación. ¡Ganaste 1 mes de Plus!';

  @override
  String referralRewardKept(String name) {
    return '$name se suscribió a Peregrino+ con tu invitación. Tu mes ganado queda guardado para cuando termine tu Plus.';
  }

  @override
  String get referralRewardKeptAnon =>
      'Alguien se suscribió a Peregrino+ con tu invitación. Tu mes ganado queda guardado para cuando termine tu Plus.';

  @override
  String reinforceCta(String gesture) {
    return 'Reforzar $gesture';
  }

  @override
  String get reinforceEmpty =>
      'Todavía no hay preguntas de este gesto en las escenas que hiciste.';

  @override
  String reinforceMissionIntro(String gesture) {
    return 'Preguntas de $gesture de las escenas que ya hiciste.';
  }

  @override
  String reinforceMissionTitle(String gesture) {
    return 'Refuerzo: $gesture';
  }

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
  String get reminderPromptEyebrow => 'Hasta mañana';

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
  String get reviewSlotTaken =>
      'El repaso de hoy ya se hizo — este queda para mañana.';

  @override
  String get roomCloseWeek => 'Cerrar la semana y revelar';

  @override
  String get roomCloseWeekBusy => 'Cerrando…';

  @override
  String get roomCloseWeekConfirmBody =>
      'Quien hizo todo hasta ahora gana el sello. Puedes cerrar otra vez antes del domingo si más gente termina.';

  @override
  String get roomCloseWeekConfirmTitle => '¿Cerrar la semana ahora?';

  @override
  String get roomCloseWeekFailed =>
      'No se pudo cerrar la semana. Inténtalo de nuevo.';

  @override
  String get roomCloseWeekHint =>
      'Hazlo en la reunión: el grupo ve junto quién fue fiel esta semana.';

  @override
  String roomClosedNotice(String room, String name, String date) {
    return 'El grupo «$room» fue cerrado por $name el $date.';
  }

  @override
  String roomClosedNoticeAnon(String room, String date) {
    return 'El grupo «$room» fue cerrado por el líder el $date.';
  }

  @override
  String roomClosedNoticeMine(String room, String date) {
    return 'Cerraste el grupo «$room» el $date. Todo sigue guardado.';
  }

  @override
  String get roomClosingBannerBody =>
      'Mira cómo le fue al grupo y quién ganó el sello.';

  @override
  String get roomClosingBannerTitle => 'Se cerró la semana del grupo';

  @override
  String get roomErrorClosedJoin => 'Este grupo fue cerrado por el líder.';

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
  String get roomErrorLoad => 'No se pudo abrir tu grupo. Revisa la conexión.';

  @override
  String get roomErrorLostGroup => 'No encontramos el grupo en el que estabas.';

  @override
  String get roomErrorSignInCreate => 'Entra con Google para crear un grupo.';

  @override
  String get roomErrorSignInJoin => 'Entra con Google para entrar a un grupo.';

  @override
  String get roomFallbackName => 'Grupo';

  @override
  String roomFormingBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faltan $count personas',
      one: 'Falta 1 persona',
    );
    return '$_temp0 para que el grupo empiece. Hasta entonces, propósito, semana y regalos del grupo esperan.';
  }

  @override
  String get roomFormingCompanion => '¿Solo ustedes dos? Caminen en Compañía';

  @override
  String get roomFormingInvite => 'Llamar personas';

  @override
  String roomFormingTitle(int count) {
    return 'El grupo empieza con $count';
  }

  @override
  String get roomKindAmigos => 'Círculo';

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
  String roomLeaderWeekDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get roomLeaderWeekScene => 'escena';

  @override
  String get roomLeaderWeekTitle => 'Seguimiento de la semana';

  @override
  String get roomNameHintAmigos => 'Ej.: Círculo de la uni';

  @override
  String get roomNameHintCelula => 'Ej.: Célula Norte';

  @override
  String get roomNameHintDiscipulado => 'Ej.: Discipulado del jueves';

  @override
  String get roomNameHintEbd => 'Ej.: Escuela de jóvenes';

  @override
  String get roomNameHintFamilia => 'Ej.: Familia Souza';

  @override
  String get roomReadingBook => 'Libro';

  @override
  String get roomReadingChange => 'Cambiar';

  @override
  String get roomReadingDone => 'Lectura hecha esta semana · toca para releer';

  @override
  String get roomReadingFrom => 'Del capítulo';

  @override
  String get roomReadingLabel => 'Lectura de la semana';

  @override
  String get roomReadingOrOther => 'O elige otro texto';

  @override
  String get roomReadingPickBody =>
      'Elige capítulos de la Biblia para que el grupo lea antes de la reunión.';

  @override
  String get roomReadingPickTitle => 'Marcar la lectura de la semana';

  @override
  String roomReadingPickerSubtitle(int max) {
    return 'Hasta $max capítulos de un libro.';
  }

  @override
  String roomReadingProgressTap(int done, int total) {
    return '$done de $total leídos esta semana · toca para leer';
  }

  @override
  String get roomReadingSameAsStudy => 'El mismo texto del estudio';

  @override
  String roomReadingSameAsStudyBody(String reading, String study) {
    return '$reading — el pasaje de “$study”. El grupo lee el capítulo y hace la escena.';
  }

  @override
  String get roomReadingSave => 'Marcar para el grupo';

  @override
  String get roomReadingSaved => 'Lectura marcada para el grupo';

  @override
  String get roomReadingTo => 'Hasta el capítulo';

  @override
  String roomReadingTooFast(int minutes) {
    return 'Capítulo marcado. Para contar en la lectura del grupo, léelo con calma (unos $minutes min) o escucha el audio, y termínalo otra vez.';
  }

  @override
  String get roomReopen => 'Reabrir el grupo';

  @override
  String get roomReopenFailed =>
      'No se pudo reabrir el grupo. Inténtalo de nuevo.';

  @override
  String get roomRevealAgain => 'Ver la revelación otra vez';

  @override
  String get roomRevealAnanHigh =>
      '¡Qué caminata! El grupo fue firme, junto, de principio a fin.';

  @override
  String get roomRevealAnanLow =>
      'Cada paso cuenta. Viene una nueva oportunidad de caminar juntos.';

  @override
  String get roomRevealAnanMid =>
      'Caminamos juntos. Ahora toca dar el siguiente paso.';

  @override
  String get roomRevealAnanSeal =>
      '¡El sello Fiel es tuyo! Ya brilla junto a tu nombre.';

  @override
  String get roomRevealConstantBody =>
      'Estuvo con la Palabra la mayor cantidad de días.';

  @override
  String get roomRevealConstantTitle => 'Más constante';

  @override
  String get roomRevealDone => 'Amén';

  @override
  String roomRevealEyebrow(String room) {
    return 'Cierre · $room';
  }

  @override
  String get roomRevealFaithfulBody =>
      'Hicieron todo lo que marcó el líder. Cada uno gana el sello.';

  @override
  String roomRevealFaithfulCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas hicieron todo lo que marcó el líder.',
      one: '1 persona hizo todo lo que marcó el líder.',
    );
    return '$_temp0';
  }

  @override
  String get roomRevealFaithfulNone =>
      'Esta vez nadie completó todo. La próxima semana empieza el lunes.';

  @override
  String get roomRevealFaithfulSeal =>
      'Cada una lleva el sello Fiel a su perfil.';

  @override
  String get roomRevealFaithfulTitle => 'Fieles en la semana';

  @override
  String get roomRevealGiftCta => 'Dar un pase de sendero a alguien';

  @override
  String get roomRevealGiftHint =>
      'Tu pase del mes abre un sendero de Peregrino+ completo para quien elijas.';

  @override
  String get roomRevealGiftPickBody =>
      'Elige el sendero. Después envía el enlace a quien quieras premiar.';

  @override
  String get roomRevealGiftPickTitle => '¿Qué sendero?';

  @override
  String get roomRevealGroupHigh => '¡Qué caminata!';

  @override
  String roomRevealGroupLine(int pct) {
    return 'El grupo hizo el $pct% de lo que marcó el líder esta semana.';
  }

  @override
  String get roomRevealGroupLow => 'Cada paso cuenta';

  @override
  String get roomRevealGroupMid => 'Caminamos juntos';

  @override
  String get roomRevealGroupPct =>
      'de lo que marcó el líder, el grupo hizo junto';

  @override
  String get roomRevealGrownBody =>
      'Acertó más esta semana que en sus propias semanas anteriores.';

  @override
  String get roomRevealGrownTitle => 'Quien más creció';

  @override
  String get roomRevealShareCta => 'Enviar el resumen al grupo';

  @override
  String get roomRevealTapHint => 'Toca para revelar';

  @override
  String get roomRevealTitle => 'La semana del grupo';

  @override
  String get roomRevealYourSeal =>
      'Ganaste el sello Fiel en la semana. Aparece junto a tu nombre en el grupo.';

  @override
  String roomSealCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sellos Fiel',
      one: '1 sello Fiel',
    );
    return '$_temp0';
  }

  @override
  String roomShareConstant(String names) {
    return 'Más constante: $names';
  }

  @override
  String roomShareFaithful(String names) {
    return 'Fieles (ganaron el sello): $names';
  }

  @override
  String roomShareFooter(String link) {
    return 'Caminamos juntos en STWAY: $link';
  }

  @override
  String roomShareGrown(String names) {
    return 'Quien más creció: $names';
  }

  @override
  String get roomStudyFallbackTitle => 'Estudio de la semana';

  @override
  String sceneAddress(String collection, String trail, int number) {
    return '$collection › $trail › Escena $number';
  }

  @override
  String get sceneStudyCta => 'Para profundizar';

  @override
  String get sceneStudyKeyword => 'Palabra clave';

  @override
  String get sceneStudyLinks => 'Conexiones en la Biblia';

  @override
  String get sceneStudyThink => 'Para pensar';

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
  String seasonCardJoined(int count) {
    return '$count peregrinos ya entraron';
  }

  @override
  String seasonCardWalkedToday(int count) {
    return '$count hoy';
  }

  @override
  String seasonCardWalking(int count) {
    return '$count peregrinos caminando';
  }

  @override
  String seasonDayLine(int day, String title) {
    return 'Día $day · $title';
  }

  @override
  String seasonDayOf(String day, int total) {
    return 'Día $day de $total';
  }

  @override
  String seasonDayTrailLocked(int day, String trail) {
    return 'Día $day · $trail';
  }

  @override
  String seasonDaysWalked(int done, int total) {
    return '$done / $total días caminados';
  }

  @override
  String get seasonEnded => 'Temporada terminada';

  @override
  String get seasonGiftTag => 'Regalo de lanzamiento';

  @override
  String seasonOpensIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Abre en $days días',
      one: 'Abre mañana',
      zero: 'Abre hoy',
    );
    return '$_temp0';
  }

  @override
  String seasonPlusFromDay(int day) {
    return 'Peregrino+ desde el día $day.';
  }

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
      'El Rey prometido nace pequeño';

  @override
  String get seasonWalkAdvento2026Day26Title => 'La pequeña Belén';

  @override
  String get seasonWalkAdvento2026Subtitle =>
      'Espera del Verbo · una escena por día';

  @override
  String seasonWeek(int week) {
    return 'Semana $week';
  }

  @override
  String get seasonWeekInsightsHeader => 'Los 7 “Hoy:” de esta semana';

  @override
  String get seasonWeekReview => 'Repaso de la semana';

  @override
  String seasonWeekReviewTitle(int week) {
    return 'Repaso de la semana $week';
  }

  @override
  String get setPieceCrossingEyebrow => 'Travesía';

  @override
  String get setPieceSeasonEyebrow => 'Nueva temporada';

  @override
  String get setPieceStreakEyebrow => 'Racha';

  @override
  String get setPieceStreakGoalLine =>
      'Compromiso cumplido. Volviste todos los días.';

  @override
  String setPieceStreakLine(int count) {
    return '$count días de racha en el camino.';
  }

  @override
  String setPieceStreakTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get setPieceTrailEyebrow => 'Ruta completada';

  @override
  String setPieceTrailLine(String mode) {
    return 'Llegaste al final en el modo $mode.';
  }

  @override
  String get setPieceTrailLineBase => 'Llegaste al final de esta ruta.';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutPage => 'Conoce Stway';

  @override
  String get settingsAboutPageSubtitle => 'Nombre, misión, visión y valores';

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
  String get settingsBlockedEmpty => 'No has bloqueado a nadie.';

  @override
  String get settingsBlockedPeople => 'Personas bloqueadas';

  @override
  String settingsBlockedPeopleSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personas',
      one: '1 persona',
      zero: 'Nadie bloqueado',
    );
    return '$_temp0';
  }

  @override
  String get settingsCheckUpdate => 'Buscar actualización';

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
  String get settingsDangerSubtitle => 'No se puede deshacer.';

  @override
  String get settingsDangerTitle => 'Borrar datos';

  @override
  String get settingsDataTitle => 'Tus datos';

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
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsDeleteAccountSubtitle =>
      'Borra la cuenta y los datos en la nube · pide confirmación';

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
  String get settingsGuestSignIn => 'Entrar y guardar mi caminata';

  @override
  String get settingsInCloud => 'En la nube';

  @override
  String get settingsIntentHint =>
      'Define tu ruta de entrada. Después, la app sigue la última ruta que recorriste.';

  @override
  String get settingsIntentLabel => 'Tu motivo';

  @override
  String get settingsIntentNone => 'Aún sin elegir';

  @override
  String settingsLastBackup(String date) {
    return 'Última copia · $date';
  }

  @override
  String settingsLastShort(String date) {
    return 'Última · $date';
  }

  @override
  String get settingsManifesto => 'Nuestro manifiesto';

  @override
  String get settingsManifestoSubtitle => 'En qué creemos y el diezmo de Stway';

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
  String get settingsPlusFreeBadge => 'Gratis';

  @override
  String settingsPlusLaunchFree(String date) {
    return 'Gratis en el lanzamiento hasta el $date';
  }

  @override
  String get settingsPlusSubscribe => 'Suscribirme a Peregrino+';

  @override
  String get settingsPlusTeaser =>
      'Rutas de temporada, planes de lectura y repaso de la semana';

  @override
  String get settingsProgressInCloud => 'Progreso en la nube';

  @override
  String get settingsProgressRestored => 'Progreso restaurado.';

  @override
  String get settingsRateApp => 'Valorar STWAY';

  @override
  String get settingsRateAppSubtitle => 'Deja tu valoración en la tienda';

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
  String get settingsReportProblem => 'Reportar un problema';

  @override
  String get settingsReportProblemSubtitle => '¿Algo no funcionó? Cuéntanos';

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
  String get settingsTabAbout => 'Acerca';

  @override
  String get settingsTabAccount => 'Cuenta';

  @override
  String get settingsTabPreferences => 'Preferencias';

  @override
  String get settingsTextSize => 'Tamaño del texto';

  @override
  String get settingsTextSizeHint => 'El versículo de abajo cambia con él.';

  @override
  String get settingsThemeAuto => 'Automático';

  @override
  String get settingsThemeBlurbAuto =>
      'Mañana, tarde y noche siguen la hora de tu día.';

  @override
  String get settingsThemeBlurbDark =>
      'Cielo de noche: menos brillo para leer antes de dormir.';

  @override
  String get settingsThemeBlurbLight =>
      'Papel claro y cielo de mañana: ideal para leer de día.';

  @override
  String get settingsThemeBlurbMedium =>
      'Media luz azul: descansa la vista sin apagar la pantalla.';

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
  String settingsThemeOrdinal(String ordinal) {
    return 'Tema $ordinal';
  }

  @override
  String get settingsThemeSheetTitle => '¿Cómo quieres ver la app?';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String settingsUpToDate(String version) {
    return 'Tienes la versión más reciente · $version';
  }

  @override
  String get settingsVersion => 'Versión';

  @override
  String get settingsWhatsNew => 'Novedades';

  @override
  String get settingsWhatsNewSubtitle => 'Lo que llegó en esta versión';

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
  String get storeRatingBody =>
      'Tu valoración en la tienda ayuda a otras personas a encontrar el camino. Toma menos de un minuto.';

  @override
  String get storeRatingCta => 'Valorar en la tienda';

  @override
  String get storeRatingEyebrow => 'Valorar';

  @override
  String get storeRatingOpenFailed => 'No se pudo abrir la tienda ahora.';

  @override
  String get storeRatingTitle => '¿Qué tal valorar STWAY?';

  @override
  String get streakDayEmpty => 'sin escena';

  @override
  String get streakDayFrozen => 'protegido por el hielo';

  @override
  String get streakDayRepaired => 'recuperado';

  @override
  String streakDaySemantics(String day, String status) {
    return '$day: $status';
  }

  @override
  String streakDayTodaySemantics(String day, String status) {
    return 'Hoy, $day: $status';
  }

  @override
  String get streakRepairAction => 'Recuperar';

  @override
  String streakRepairBody(int broken, int restored) {
    String _temp0 = intl.Intl.pluralLogic(
      broken,
      locale: localeName,
      other:
          'Por eso tu racha de $broken días empezó de nuevo. Si la recuperas, vuelve a $restored días. Puedes hacerlo 1 vez al mes.',
      one:
          'Por eso tu racha de 1 día empezó de nuevo. Si la recuperas, vuelve a $restored días. Puedes hacerlo 1 vez al mes.',
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
  String streakRepairDismiss(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedarme con $count días',
      one: 'Quedarme con 1 día',
    );
    return '$_temp0';
  }

  @override
  String streakRepairDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha de vuelta · $count días',
      one: 'Racha de vuelta · 1 día',
    );
    return '$_temp0';
  }

  @override
  String get streakRepairTitle => 'Ayer quedó en blanco';

  @override
  String streakRepairTitleDay(String day) {
    return 'El $day quedó en blanco';
  }

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
  String studyAnswersOf(int correct, int total) {
    return '$correct de $total respuestas';
  }

  @override
  String studyDepthAnswers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas',
      one: '1 respuesta',
    );
    return '$_temp0';
  }

  @override
  String get studyDepthNext => 'tu próximo paso';

  @override
  String get studyDepthNone => 'ninguna aún';

  @override
  String get studyDepthTitle => 'Profundidad';

  @override
  String get studyDepthToExplore => 'por explorar';

  @override
  String get studyFirstTry => 'a la primera';

  @override
  String get studyGesturesTapHint => 'Toca un gesto para practicar solo ese.';

  @override
  String get studyGesturesTitle => 'Tus gestos';

  @override
  String get studyWeeksEmpty =>
      'Juega una escena y la barra de esta semana se enciende aquí.';

  @override
  String get studyWeeksTitle => 'Últimas semanas';

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
  String get suggestionTrailHintBoth =>
      'Elige una colección y describe la ruta.';

  @override
  String get suggestionTrailHintRealm => 'Elige dónde encaja esta ruta.';

  @override
  String get suggestionTrailHintText => 'Describe la ruta — al menos 4 letras.';

  @override
  String get suggestionTrailPlaceholder =>
      'Elige una colección y describe la ruta…';

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
  String supportAmount(String price) {
    return 'Apoyar con $price';
  }

  @override
  String get supportBody =>
      'Stway es gratis para todos. Tu apoyo paga servidores y nuevas rutas. No desbloquea nada en la app: es un regalo, y recibes el sello de apoyo.';

  @override
  String get supportFinePrint =>
      'Pago único por App Store o Google Play. No es una suscripción.';

  @override
  String get supportHeadline => 'Ayuda a Stway a continuar';

  @override
  String get supportThanksBody =>
      'Tu apoyo ayuda a más personas a caminar en la Palabra. El sello de apoyo ya está en tu perfil.';

  @override
  String get supportThanksTitle => '¡Gracias!';

  @override
  String get supportTitle => 'Apoyar Stway';

  @override
  String get supporterBadge => 'Apoyo';

  @override
  String get takeawaysReviewLabel => 'Para repasar';

  @override
  String takeawaysRow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encontraste $count cosas en el texto',
      one: 'Encontraste 1 cosa en el texto',
    );
    return '$_temp0';
  }

  @override
  String get takeawaysRowReviewOnly => 'Mira qué repasar en el texto';

  @override
  String get takeawaysSubtitle =>
      'Cada frase viene de una pregunta que respondiste. Toca para abrir el versículo.';

  @override
  String get takeawaysTitle => 'Lo que viste en el texto';

  @override
  String get todayPostcardSlideHint => 'Tu postal';

  @override
  String get todayShareInsight => 'Compartir esta frase';

  @override
  String get todayShareNudgeA => 'Alguien cerca de ti necesita oír esto.';

  @override
  String get todayShareNudgeB => 'Comparte la Palabra. Cambia vidas.';

  @override
  String get todayShareNudgeC => 'Lleva esta frase a alguien hoy.';

  @override
  String get todayShareNudgeMark => 'Palabra';

  @override
  String get todaySharePostcard => 'Compartir postal';

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
  String get trailGiftCardBody =>
      'Tu pase del mes la libera entera para quien elijas.';

  @override
  String get trailGiftCardTitle => 'Regalar esta ruta a alguien';

  @override
  String get trailGiftCodeSubtitle =>
      'Pega el mensaje con el enlace del pase o escribe el código de 8 letras.';

  @override
  String get trailGiftEyebrow => 'Pase de ruta';

  @override
  String get trailGiftFailed =>
      'No fue posible abrir el pase. Inténtalo de nuevo.';

  @override
  String get trailGiftGivePickSubtitle =>
      'Quien la reciba la recorre entera, sin pagar y sin plazo.';

  @override
  String get trailGiftGivePickTitle => '¿Qué ruta vas a liberar?';

  @override
  String get trailGiftInvalid => 'Este pase no existe. Revisa el enlace.';

  @override
  String get trailGiftMonthChoose => 'Elegir la ruta yo';

  @override
  String get trailGiftMonthOpen =>
      'Invitaste a alguien a la Compañía, y el pase de este mes fue junto con la invitación. Quien acepte gana una ruta de Peregrino+ y elige cuál. Si prefieres, elige tú la ruta ahora.';

  @override
  String get trailGiftMonthOpenLink =>
      'Tu pase de este mes está listo y nadie lo recibió todavía. Quien abra el enlace elige la ruta.';

  @override
  String get trailGiftMonthPick => 'Elegir la ruta por esa persona';

  @override
  String get trailGiftMonthReady =>
      'Tienes 1 pase este mes. Envíalo a alguien: elige una ruta de Peregrino+ y la recorre entera, sin pagar y sin plazo.';

  @override
  String trailGiftMonthReserved(String trail) {
    return 'Tu pase de este mes está guardado para $trail. Nadie lo recibió todavía.';
  }

  @override
  String get trailGiftMonthReshare => 'Compartir de nuevo';

  @override
  String get trailGiftMonthSend => 'Enviar el pase';

  @override
  String get trailGiftMonthSwap => 'Cambiar la ruta';

  @override
  String get trailGiftMonthTitle =>
      'Tu suscripción le abre el camino a alguien';

  @override
  String get trailGiftMonthTrial =>
      'Después de la prueba gratis, liberas 1 ruta de Peregrino+ por mes para quien quieras.';

  @override
  String get trailGiftNeedsAccount =>
      'Entra en tu cuenta para recibir el pase. Se abre solo justo después.';

  @override
  String get trailGiftNotNeeded =>
      'Ya tienes esta ruta. El pase queda para otra persona.';

  @override
  String get trailGiftOwn => 'Este pase es tuyo. Compártelo con alguien.';

  @override
  String trailGiftPending(String trail) {
    return 'Termina $trail, que recibiste, para recibir otro pase. Este pase sigue con quien lo envió.';
  }

  @override
  String get trailGiftPickSubtitle =>
      'Elige qué ruta de Peregrino+ es tuya. Queda abierta completa, sin plazo.';

  @override
  String trailGiftPickTitle(String name) {
    return '$name te regaló una ruta';
  }

  @override
  String get trailGiftProfileCaption =>
      'Pega el enlace o escribe el código de 8 letras';

  @override
  String get trailGiftProfileTitle => '¿Recibiste un pase de sendero?';

  @override
  String trailGiftReceivedBody(String name) {
    return '$name liberó esta ruta para ti. Es tuya, completa y sin plazo.';
  }

  @override
  String get trailGiftSendFailed =>
      'No fue posible crear el pase. Inténtalo de nuevo.';

  @override
  String get trailGiftShareCta => 'Compartir el pase';

  @override
  String trailGiftShareOpenText(String link, String code) {
    return 'Te regalo una ruta de Peregrino+ en Stway 🎁 Tú eliges cuál, y es tuya, entera. Ábrela con el enlace: $link\n\n¿Aún no tienes la app? Instálala, entra y toca “¿Recibiste un pase de sendero?” en el Perfil. Código: $code';
  }

  @override
  String get trailGiftShareSubject => 'Una ruta de Stway para ti';

  @override
  String trailGiftShareText(String trail, String link, String code) {
    return 'Te liberé la ruta $trail en Stway 🎁 Es tuya, entera. Ábrela con el enlace: $link\n\n¿Aún no tienes la app? Instálala, entra y toca “¿Recibiste un pase de sendero?” en el Perfil. Código: $code';
  }

  @override
  String get trailGiftSheetBody =>
      'Quien lo reciba recorre esta ruta completa, sin pagar y sin plazo. Tienes 1 pase al mes.';

  @override
  String trailGiftSheetSwap(String trail) {
    return 'Tu pase de este mes está reservado para $trail y nadie lo ha recibido aún. ¿Compartir esta ruta en su lugar?';
  }

  @override
  String get trailGiftSheetSwapOpen =>
      'Tu pase de este mes está en tu invitación de compañía y nadie la aceptó aún. ¿Compartir esta ruta en su lugar?';

  @override
  String trailGiftSheetUsed(String trail, String name) {
    return 'Este mes liberaste $trail para $name. Un nuevo pase llega el día 1.';
  }

  @override
  String get trailGiftSomeone => 'Alguien';

  @override
  String get trailGiftTaken => 'Otra persona ya recibió este pase.';

  @override
  String get trailMapCrossing => 'Travesía';

  @override
  String trailMapGoToScene(String scene) {
    return 'Ir a $scene';
  }

  @override
  String trailMapSceneLockedBody(String scene) {
    return 'Termina «$scene» para abrir esta escena. Van en orden: cada una prepara la siguiente.';
  }

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
  String get trailsDoorIntroBible =>
      'La Biblia entera, libro por libro. El Antiguo Testamento guarda la promesa; el Nuevo muestra el cumplimiento en Jesús. En el Panorama, los puntos altos de cada libro en pocas escenas.';

  @override
  String get trailsDoorIntroHowItWorks =>
      'Cada ruta tiene etapas y escenas cortas. Al terminar una ruta, se abre la siguiente.';

  @override
  String get trailsDoorIntroLabel => 'Antes de empezar';

  @override
  String get trailsDoorIntroLife =>
      'La fe en el día a día. Discipulado, oración e historia de la iglesia: cómo seguir a Jesús hoy, cómo orar y cómo la fe llegó hasta nosotros.';

  @override
  String get trailsDoorIntroStudy =>
      'Herramientas para leer la Biblia con más cuidado: hermenéutica, hebreo y griego, doctrina y la persona de Cristo, siempre a partir del propio texto.';

  @override
  String get trailsDoorIntroThemes =>
      'La Biblia leída por hilos, no por libros: las personas que la cargan, la promesa y su cumplimiento, los grandes temas y las parábolas. Cada ruta sigue un hilo por varios libros.';

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
  String get trailsHubBibleBody => 'Antiguo y Nuevo Testamento, y el Panorama.';

  @override
  String get trailsHubStudy => 'Estudio';

  @override
  String get trailsHubStudyBody => 'Hermenêutica, lenguas y doctrina.';

  @override
  String get trailsHubThemes => 'Temas';

  @override
  String get trailsHubThemesBody => 'Sabiduría y los hilos de la Biblia.';

  @override
  String get trailsInProgress => 'En curso';

  @override
  String get trailsJourneySoonBody => 'Estas rutas aún se están preparando.';

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
  String get trailsLeaveAllAwareness =>
      'Entiendo que perderé el progreso, las medallas y los sellos de mis rutas abiertas';

  @override
  String get trailsLeaveAllBody =>
      'Todo de tus rutas abiertas desaparece — escenas, modos, cofres, medallas, sellos y postales. Las rutas terminadas, tus pasos y racha se mantienen. No se puede deshacer.';

  @override
  String get trailsLeaveAllCta => 'Salir de todas las rutas';

  @override
  String get trailsLeaveAllDone =>
      'Listo. Elige una ruta para empezar de nuevo.';

  @override
  String get trailsLeaveAllTitle => '¿Salir de todas las rutas?';

  @override
  String get trailsLeaveAwareness =>
      'Entiendo que perderé el progreso, las medallas y los sellos de esta ruta';

  @override
  String get trailsLeaveBody =>
      'Todo de esta ruta desaparece — escenas, modos, cofres, medallas, sellos y postales. Tus pasos y racha se mantienen. No se puede deshacer.';

  @override
  String get trailsLeaveCta => 'Salir de la ruta';

  @override
  String get trailsLeaveTitle => '¿Salir de la ruta?';

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
  String trailsOpenMore(String first, int count) {
    return '$first y $count más';
  }

  @override
  String get trailsOpenSubtitle => 'Elige por dónde seguir.';

  @override
  String get trailsOpenTitle => 'Tus rutas abiertas';

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
  String get trailsShelfBible => 'Biblia';

  @override
  String get trailsShelfThemes => 'Temáticos';

  @override
  String trailsStage(String roman) {
    return 'Etapa $roman';
  }

  @override
  String get trailsSuggestedStart => 'Sugerencia para empezar';

  @override
  String trailsTrailNumber(String roman) {
    return 'Ruta $roman';
  }

  @override
  String ttsNoVoices(String language) {
    return 'No hay voz en $language instalada. Instálala en los ajustes de texto a voz del dispositivo.';
  }

  @override
  String get ttsSectionVoice => 'Voz de la lectura';

  @override
  String get ttsSpeedFast => 'Rápido';

  @override
  String get ttsSpeedNormal => 'Normal';

  @override
  String get ttsSpeedSlow => 'Lento';

  @override
  String get ttsTest => 'Probar voz';

  @override
  String get ttsTestStop => 'Detener';

  @override
  String get ttsVoiceAuto => 'Automática';

  @override
  String get ttsVoiceFemale => 'femenina';

  @override
  String ttsVoiceHint(String language) {
    return 'Voces instaladas en este dispositivo para $language.';
  }

  @override
  String get ttsVoiceMale => 'masculina';

  @override
  String ttsVoiceNumbered(int number) {
    return 'Voz $number';
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
  String get vaultSeeAll => 'Ver colección completa';

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
  String verseStudyGlossCount(String gloss, int count) {
    return '$gloss · $count×';
  }

  @override
  String get verseStudyGoToText => 'Ir al texto';

  @override
  String get verseStudyInThisBook => 'En este libro — en orden canónico.';

  @override
  String get verseStudyInThisVerse => 'En este versículo';

  @override
  String get verseStudyLast => 'última';

  @override
  String get verseStudyLemma => 'Lema';

  @override
  String get verseStudyListenLemma => 'Oír el original';

  @override
  String get verseStudyLoadFailed => 'No se pudo cargar el estudio.';

  @override
  String get verseStudyLoading => 'Abriendo el léxico…';

  @override
  String get verseStudyMorphTap => 'Toca un término para explicarlo';

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
  String verseStudyOriginalForm(String lang) {
    return 'Forma en $lang';
  }

  @override
  String get verseStudyOtherBooks => 'En otros libros';

  @override
  String get verseStudyOtherBooksBody =>
      'La primera aparición en cada libro, en orden canónico.';

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
  String get verseStudyTranslations => 'Cómo lo traduce la TB';

  @override
  String verseStudyTranslationsAlso(String list) {
    return 'También: $list';
  }

  @override
  String get verseStudyTranslationsBody =>
      'La misma palabra original aparece con estos sentidos en la Tradução Brasileira.';

  @override
  String verseStudyTranslationsHere(String word) {
    return 'Aquí: $word';
  }

  @override
  String get verseStudyVerseUnavailable =>
      'Versículo no disponible en esta traducción.';

  @override
  String get verseStudyViewInterlinear => 'Interlineal';

  @override
  String get verseStudyViewVerse => 'Versículo';

  @override
  String get walkCountdownDays => 'días';

  @override
  String get walkCountdownHours => 'horas';

  @override
  String get walkCountdownLabel => 'Abre en';

  @override
  String get walkCountdownMinutes => 'min';

  @override
  String get walkCountdownSeconds => 'seg';

  @override
  String get walkCrowdEmpty => 'Nadie entró todavía.\nSé el primero.';

  @override
  String get walkCrowdHeader => 'Quién caminará junto';

  @override
  String get walkCrowdListSubtitle => 'Toca a alguien para ver su perfil.';

  @override
  String walkTogetherDayOf(int day, int total) {
    return 'Día $day de $total';
  }

  @override
  String walkTogetherDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días al mismo ritmo',
      one: '1 día al mismo ritmo',
    );
    return '$_temp0';
  }

  @override
  String get walkTogetherInvite => 'Invitar a alguien';

  @override
  String get walkTogetherJoin => 'Cuenten conmigo';

  @override
  String get walkTogetherKicker => 'Estación';

  @override
  String get walkTogetherOpen => 'Abrir el calendario';

  @override
  String walkTogetherPitch(int count) {
    return '$count días · una escena por día.';
  }

  @override
  String walkTogetherShareSubject(String title) {
    return '$title · Stway';
  }

  @override
  String walkTogetherShareText(
    String name,
    String title,
    String pitch,
    String start,
    String url,
  ) {
    return '$name te invita a la estación $title en Stway.\n\n$pitch\nEmpieza el $start.\n\n¿Vienes?\n\n¿Aún no tienes la app?\n$url';
  }

  @override
  String walkTogetherStartsIn(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Empieza en $days días',
      one: 'Empieza mañana',
      zero: 'Empieza hoy',
    );
    return '$_temp0';
  }

  @override
  String walkTogetherToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hicieron el día de hoy',
      one: '1 hizo el día de hoy',
      zero: 'nadie hizo el día aún',
    );
    return '$_temp0';
  }

  @override
  String walkTogetherWalkers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count peregrinos',
      one: '1 peregrino',
      zero: 'Nadie aún',
    );
    return '$_temp0';
  }

  @override
  String get waveCta => 'Saludar';

  @override
  String get waveKindCheer => 'Ánimo, el grupo está contigo';

  @override
  String get waveKindMiss => 'Te extrañamos';

  @override
  String get waveKindPlan => '¿Entras al propósito con nosotros?';

  @override
  String get waveKindPray => 'Estoy orando por ti';

  @override
  String get waveKindStudy => 'Ven a estudiar con el grupo';

  @override
  String waveSheetSubtitle(String name) {
    return 'Elige el mensaje. Le llega a $name como notificación.';
  }

  @override
  String get webRedeemDone =>
      'Peregrino+ activado. La suscripción del sitio ya está en tu cuenta.';

  @override
  String webRedeemExpired(String email) {
    return 'El enlace venció. Se envió uno nuevo a $email.';
  }

  @override
  String get webRedeemFailed =>
      'No se pudo activar la suscripción del sitio. Inténtalo de nuevo en un momento.';

  @override
  String get webRedeemInvalid =>
      'Este enlace de activación ya no es válido. Si ya lo usaste, Peregrino+ está en tu cuenta.';

  @override
  String get webRedeemNeedsAccount =>
      'Inicia sesión y toca el enlace otra vez para activar el Peregrino+ del sitio.';

  @override
  String get webRedeemOtherAccount =>
      'Esta suscripción del sitio ya está vinculada a otra cuenta de Stway.';

  @override
  String get weeklyReviewDoneBody =>
      'Repaso hecho. La próxima semana hay otro.';

  @override
  String weeklyReviewEmptyBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Haz al menos $count escenas nuevas en la semana para tener el repaso.',
      one: 'Haz al menos 1 escena nueva en la semana para tener el repaso.',
    );
    return '$_temp0';
  }

  @override
  String get weeklyReviewEmptyTitle => 'Todavía no hay repaso';

  @override
  String weeklyReviewHeadline(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escenas esta semana',
      one: '1 escena esta semana',
    );
    return '$_temp0';
  }

  @override
  String get weeklyReviewInsightsHeader => 'El “Hoy:” de cada escena';

  @override
  String get weeklyReviewIntro =>
      'Toca una escena para releer su “Hoy:” y, al final, responde 3 preguntas sobre ellas.';

  @override
  String get weeklyReviewMissionIntro =>
      'Tres preguntas de las escenas de esta semana.';

  @override
  String get weeklyReviewMissionTitle => 'Repaso de la semana';

  @override
  String get weeklyReviewNoQuestions =>
      'No encontré las preguntas de estas escenas en el dispositivo. Inténtalo de nuevo con internet.';

  @override
  String get weeklyReviewPreparing => 'Preparando…';

  @override
  String weeklyReviewRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String weeklyReviewSceneLine(String trail, String scene) {
    return '$trail · $scene';
  }

  @override
  String get weeklyReviewSeePlus => 'Conocer Peregrino+';

  @override
  String get weeklyReviewStart => 'Responder 3 preguntas';

  @override
  String get weeklyReviewTitle => 'Repaso de la semana';

  @override
  String weeklyReviewTodayInsight(String insight) {
    return 'Hoy: $insight';
  }

  @override
  String get weeklyReviewTodayNext => 'Siguiente escena';

  @override
  String weeklyReviewTodayPage(int index, int total) {
    return '$index de $total';
  }

  @override
  String get weeklyReviewTodayPrev => 'Escena anterior';

  @override
  String get whatsNew148Advent =>
      'Regalo de Adviento: camina los 26 días (29/11 al 24/12) y gana hasta 3 meses de Peregrino+. Solo, 1 mes; con tu Compañía, 2; con 3 o más de tu grupo, 3. ¿Perdiste un día? Puedes hacerlo después.';

  @override
  String get whatsNew148Plan =>
      'Propósito del grupo: el día de hoy, lectura y escena, las respuestas de cada uno. El líder decide si el grupo ve las respuestas.';

  @override
  String get whatsNew148Share =>
      'Comparte la frase y la postal del día directo desde Hoy.';

  @override
  String get whatsNew148Study =>
      'Estudiar el versículo: modo interlineal, escuchar la palabra en el original y ver cómo la traduce la versión.';

  @override
  String get whatsNew149Explore =>
      'La pestaña Rutas ahora es Explorar: AT, NT y Temas en colecciones, y los 66 libros de la Biblia capítulo a capítulo.';

  @override
  String get whatsNew149Free =>
      'Ahora gratis: el repaso de la semana, los errores explicados y tu línea de crecimiento en el Perfil.';

  @override
  String get whatsNew149Invite =>
      'Invitación que se vuelve regalo: si alguien entra por tu invitación y se suscribe a Peregrino+, ganas 1 mes de Peregrino+ gratis.';

  @override
  String get whatsNewEyebrow => 'Novedades';

  @override
  String get whatsNewTitle => 'El camino trae cosas nuevas';

  @override
  String get widgetBackToTrail => 'Vuelve a la ruta';

  @override
  String get widgetGoalDone => 'Meta completada';

  @override
  String get widgetKeepStreak => 'Mantén tu racha';

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
  String get widgetShortAway => 'Vuelve hoy';

  @override
  String get widgetShortSafe => 'Hecho hoy';

  @override
  String get widgetStartStreak => 'Empieza tu racha';

  @override
  String get widgetStreakSafe => 'Racha asegurada hoy';

  @override
  String widgetTodayTitle(String title) {
    return 'Hoy: $title';
  }

  @override
  String widgetTomorrowTitle(String title) {
    return 'Mañana: $title';
  }

  @override
  String get widgetWeekdayInitials => 'L,M,X,J,V,S,D';

  @override
  String get wordStatBooks => 'Libros';

  @override
  String get wordStatChapters => 'Capítulos';

  @override
  String get wordStatFavorites => 'Favoritos';

  @override
  String get wordStatNotes => 'Notas';

  @override
  String yearReviewAdventWord(int total) {
    return 'de $total días de Adviento';
  }

  @override
  String yearReviewAnanBook(String book) {
    return '$book fue tu casa este año.';
  }

  @override
  String get yearReviewAnanDays =>
      'Cada cuadrito encendido fue un día en que volviste.';

  @override
  String get yearReviewAnanFeats =>
      'Ese es el camino de quien toma en serio la Palabra.';

  @override
  String get yearReviewAnanGrowth =>
      'Eso no es suerte. Es lectura que se quedó en ti.';

  @override
  String get yearReviewAnanMap => 'Cada luz es un libro que abriste este año.';

  @override
  String get yearReviewAnanMode => 'Aquí es donde tu mirada está más afilada.';

  @override
  String get yearReviewAnanStanding =>
      'No se trata de ganarle a nadie. Se trata de no parar.';

  @override
  String get yearReviewAnanTogether =>
      'Caminar juntos hace el camino más ligero.';

  @override
  String get yearReviewBookEyebrow => 'El libro donde más estuviste';

  @override
  String yearReviewBooksFinishedWord(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'libros concluidos',
      one: 'libro concluido',
    );
    return '$_temp0';
  }

  @override
  String get yearReviewCardDays => 'días en el camino';

  @override
  String get yearReviewCardPostcards => 'postales';

  @override
  String get yearReviewCardStreak => 'días seguidos';

  @override
  String yearReviewChaptersWord(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'capítulos leídos en la Biblia',
      one: 'capítulo leído en la Biblia',
    );
    return '$_temp0';
  }

  @override
  String get yearReviewCollectionEyebrow => 'Tu colección';

  @override
  String yearReviewCollectionTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count escenas se volvieron postales',
      one: '1 escena se volvió postal',
    );
    return '$_temp0';
  }

  @override
  String yearReviewCompanionWord(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'días lado a lado con $name',
      one: 'día lado a lado con $name',
    );
    return '$_temp0';
  }

  @override
  String get yearReviewDaypartAfternoon => 'Camina por la tarde';

  @override
  String get yearReviewDaypartDawn => 'Camina de madrugada';

  @override
  String get yearReviewDaypartMorning => 'Camina por la mañana';

  @override
  String get yearReviewDaypartNight => 'Camina por la noche';

  @override
  String yearReviewDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return 'en $_temp0 de camino';
  }

  @override
  String get yearReviewDaysEyebrow => 'Tu año, día a día';

  @override
  String yearReviewDaysWord(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'días en el camino',
      one: 'día en el camino',
    );
    return '$_temp0';
  }

  @override
  String yearReviewEndBody(String next) {
    return 'Cada postal es un paso tuyo con Dios. ¡Que venga $next!';
  }

  @override
  String get yearReviewEyebrow => 'Resumen del año';

  @override
  String get yearReviewFeatsEyebrow => 'Hitos del año';

  @override
  String get yearReviewFirst => 'La primera';

  @override
  String yearReviewGroupLine(String name) {
    return 'Caminando con el grupo $name';
  }

  @override
  String get yearReviewGrowthEyebrow => 'Creciste';

  @override
  String yearReviewGrowthLine(String mode, int from, int to) {
    return 'Acierto a la primera en $mode: de $from% a $to%';
  }

  @override
  String get yearReviewGrowthWord => 'puntos más de acierto';

  @override
  String get yearReviewLatest => 'La más reciente';

  @override
  String get yearReviewLocked =>
      'El resto de tu resumen del año está en Peregrino+';

  @override
  String get yearReviewMapEyebrow => 'Tu Biblia encendida';

  @override
  String get yearReviewMapFinished => 'concluido';

  @override
  String get yearReviewMapPostcard => 'con postal';

  @override
  String get yearReviewMapRead => 'leído en la Biblia';

  @override
  String yearReviewMapTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count libros encendidos de 66',
      one: '1 libro encendido de 66',
    );
    return '$_temp0';
  }

  @override
  String get yearReviewModeEyebrow => 'Donde más aciertas';

  @override
  String get yearReviewModeWord => 'de acierto a la primera';

  @override
  String get yearReviewOpen => 'Ver el resumen del año';

  @override
  String yearReviewPerfectWord(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'escenas sin fallar nada',
      one: 'escena sin fallar nada',
    );
    return '$_temp0';
  }

  @override
  String get yearReviewPersonaAdvent => 'Peregrino de Adviento';

  @override
  String get yearReviewPersonaAdventLine =>
      'Esperaste la Navidad caminando, día tras día.';

  @override
  String get yearReviewPersonaConstant => 'Peregrino constante';

  @override
  String get yearReviewPersonaConstantLine =>
      'Volviste día tras día. Así se camina.';

  @override
  String get yearReviewPersonaExplorer => 'Explorador de las Escrituras';

  @override
  String get yearReviewPersonaExplorerLine =>
      'Recorriste la Biblia de punta a punta.';

  @override
  String yearReviewPersonaEyebrow(String year) {
    return 'Quién fuiste en $year';
  }

  @override
  String get yearReviewPersonaGroup => 'Fiel del grupo';

  @override
  String get yearReviewPersonaGroupLine =>
      'Hiciste el camino con otros y no dejaste a nadie atrás.';

  @override
  String get yearReviewPersonaGrower => 'Aprendiz que crece';

  @override
  String get yearReviewPersonaGrowerLine =>
      'Hoy entiendes lo que no entendías al comienzo del año.';

  @override
  String get yearReviewPersonaPilgrim => 'Peregrino en camino';

  @override
  String get yearReviewPersonaPilgrimLine =>
      'Todo camino empieza con los primeros pasos. Los tuyos ya están dados.';

  @override
  String get yearReviewPersonaReader => 'Lector de la Palabra';

  @override
  String get yearReviewPersonaReaderLine =>
      'Leíste capítulo por capítulo, sin prisa.';

  @override
  String get yearReviewPhraseEyebrow => 'La frase que quedó';

  @override
  String yearReviewPostcards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count postales',
      one: '1 postal',
    );
    return '$_temp0';
  }

  @override
  String yearReviewPostcardsWord(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'postales en el camino',
      one: 'postal en el camino',
    );
    return '$_temp0';
  }

  @override
  String yearReviewRecognitionsWord(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'veces que alguien reconoció tu camino',
      one: 'vez que alguien reconoció tu camino',
    );
    return '$_temp0';
  }

  @override
  String yearReviewSealsWord(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'sellos Fiel en el grupo',
      one: 'sello Fiel en el grupo',
    );
    return '$_temp0';
  }

  @override
  String get yearReviewShareCta => 'Compartir mi año';

  @override
  String get yearReviewShareEyebrow => 'Tu año en una tarjeta';

  @override
  String get yearReviewShareSlide => 'Compartir';

  @override
  String yearReviewShareText(String year, String link) {
    return 'Mi camino por la Biblia en $year, escena a escena, en STWAY: $link';
  }

  @override
  String get yearReviewStandingEyebrow => 'En la Caravana';

  @override
  String yearReviewStandingLine(String month, int pct, int total) {
    return 'En $month, estuviste entre el $pct% que más caminó, de $total peregrinos.';
  }

  @override
  String yearReviewStandingTop(int pct) {
    return 'Top $pct%';
  }

  @override
  String get yearReviewTap => 'Toca para continuar';

  @override
  String yearReviewTitle(String year) {
    return 'Tu camino en $year';
  }

  @override
  String get yearReviewTogetherEyebrow => 'No caminaste solo';

  @override
  String yearReviewTopMonthLine(String month) {
    return 'Mes más fuerte: $month';
  }

  @override
  String yearReviewTrailsWord(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'senderos completos',
      one: 'sendero completo',
    );
    return '$_temp0';
  }

  @override
  String yearReviewVersesWord(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'versículos guardados de memoria',
      one: 'versículo guardado de memoria',
    );
    return '$_temp0';
  }

  @override
  String get yearReviewVideoCta => 'Compartir en video';

  @override
  String get yearReviewVideoRendering => 'Armando el video de tu año…';

  @override
  String yearReviewYearStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días seguidos',
      one: '1 día',
    );
    return 'Racha más larga: $_temp0';
  }
}
