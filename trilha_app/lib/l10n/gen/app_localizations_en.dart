// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authAccountExists =>
      'An account already exists with this email using another sign-in method.';

  @override
  String get authEnableProviders =>
      'Enable providers in Firebase Console: Authentication → Sign-in method → Anonymous and/or Google.';

  @override
  String get authFirebaseNotReady => 'Firebase isn\'t ready yet.';

  @override
  String authGenericError(String code, String message) {
    return 'Auth error ($code): $message';
  }

  @override
  String get authInvalidCredential =>
      'Invalid Google credential. Add the app SHA-1 in Firebase and download google-services.json again.';

  @override
  String get authLoginInProgress => 'Sign-in already in progress.';

  @override
  String get authMissingIdToken =>
      'Google didn\'t return an idToken. Check that the Play SHA-1 is in Firebase.';

  @override
  String get authNetworkReset =>
      'Network error talking to Firebase Auth (connection reset). Try again on stable Wi‑Fi or mobile data.';

  @override
  String get authNoInternet =>
      'No internet connection. Check your Wi‑Fi or mobile data.';

  @override
  String get authTooManyRequests =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get avatarChangePortrait => 'Change portrait';

  @override
  String get avatarOpenProfile => 'Open profile';

  @override
  String bibleBookFallback(int number) {
    return 'Book $number';
  }

  @override
  String bibleBookReadSemantics(String book, int read, int total) {
    return '$book, $read of $total chapters read';
  }

  @override
  String bibleChapterCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters',
      one: '1 chapter',
    );
    return '$_temp0';
  }

  @override
  String bibleChapterCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ch.',
      one: '1 ch.',
    );
    return '$_temp0';
  }

  @override
  String bibleChapterLabel(int chapter) {
    return 'Chapter $chapter';
  }

  @override
  String bibleChapterReadSemantics(int chapter) {
    return 'Chapter $chapter, read';
  }

  @override
  String bibleChaptersReadOf(int read, int total) {
    return '$read of $total read';
  }

  @override
  String get bibleDonate => 'Donate';

  @override
  String get bibleHeroContinueReading => 'Continue reading';

  @override
  String get bibleHeroFreshBlurb =>
      'Jesus, the Word made flesh — a good place to start.';

  @override
  String get bibleHeroStartHere => 'Start here';

  @override
  String get bibleHeroStartReading => 'Start reading';

  @override
  String get bibleIntroAudience => 'For whom';

  @override
  String bibleIntroAuthorByTradition(String author) {
    return '$author · by tradition';
  }

  @override
  String get bibleIntroWhen => 'When';

  @override
  String get bibleIntroWho => 'Who';

  @override
  String get bibleNewTestament => 'New Testament';

  @override
  String get bibleOldTestament => 'Old Testament';

  @override
  String get biblePaperAuto => 'Automatic';

  @override
  String get biblePaperLight => 'Light';

  @override
  String get biblePaperNight => 'Night';

  @override
  String biblePaperSemantics(String paper) {
    return '$paper paper';
  }

  @override
  String get biblePaperSepia => 'Sepia';

  @override
  String get biblePickerBackToBooks => 'Back to books';

  @override
  String get biblePickerTitle => 'Go to';

  @override
  String get bibleReadChapter => 'Read the chapter';

  @override
  String bibleReadOf(int read, int total) {
    return '$read of $total';
  }

  @override
  String get bibleReaderChapterDone => 'Chapter read';

  @override
  String bibleReaderChapterEnd(String book, int chapter) {
    return 'End of $book $chapter';
  }

  @override
  String bibleReaderChapterReadToast(String book, int chapter) {
    return '$book $chapter read';
  }

  @override
  String get bibleReaderCompleteChapter => 'Finish chapter';

  @override
  String get bibleReaderListen => 'Listen';

  @override
  String get bibleReaderNextChapter => 'Next chapter';

  @override
  String bibleReaderOpenFailed(String reference) {
    return 'Couldn\'t open $reference.';
  }

  @override
  String get bibleReaderPaper => 'Paper';

  @override
  String get bibleReaderPrevChapter => 'Previous chapter';

  @override
  String get bibleReaderReadTag => 'read';

  @override
  String get bibleReaderSettings => 'Reading settings';

  @override
  String get bibleReaderStop => 'Stop';

  @override
  String bibleReaderSubtitle(int chapter, String translation) {
    return 'Chapter $chapter · $translation';
  }

  @override
  String get bibleReaderTextSize => 'Text size';

  @override
  String get bibleReaderUpNext => 'Up next';

  @override
  String get bibleReaderVersion => 'Version';

  @override
  String get bibleSavedEmptyBody =>
      'While reading, tap a verse and choose Save to come back to it later.';

  @override
  String get bibleSavedEmptyTitle => 'No saved verses';

  @override
  String get bibleSavedTitle => 'Saved';

  @override
  String get bibleSearchBookHit => 'Book';

  @override
  String get bibleSearchButtonHint => 'Search book, verse or word…';

  @override
  String get bibleSearchButtonSemantics => 'Search book or verse';

  @override
  String get bibleSearchEmpty => 'No results found';

  @override
  String get bibleSearchFieldHint => 'E.g. Apocalipse, amor, fé…';

  @override
  String get bibleSearchSubtitle => 'Books and verses';

  @override
  String get bibleSearchTitle => 'Search';

  @override
  String bibleSectionBooksSemantics(String title, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$title, $count books',
      one: '$title, 1 book',
    );
    return '$_temp0';
  }

  @override
  String get bibleShareAsText => 'Share as text';

  @override
  String get bibleShareImage => 'Share image';

  @override
  String get bibleSharePreparing => 'Preparing…';

  @override
  String get bibleShareTextFooter => 'Via Stway';

  @override
  String get bibleShareTitle => 'Share verse';

  @override
  String bibleShareVia(String ref) {
    return '$ref — via Stway';
  }

  @override
  String get bibleTabReading => 'Reading';

  @override
  String get bibleTapToClose => 'Tap to close';

  @override
  String get bibleTapToOpen => 'Tap to open';

  @override
  String get bibleTitle => 'Bible';

  @override
  String bibleTranslationSoonBody(String name) {
    return 'We don\'t have $name yet. It\'s coming to the app soon. You can support the project to help bring more versions.';
  }

  @override
  String get bibleTranslationSoonTitle => 'Translation coming soon';

  @override
  String get bibleVerseCopied => 'Verse copied';

  @override
  String get bibleVerseCopy => 'Copy';

  @override
  String bibleVerseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses',
      one: '1 verse',
    );
    return '$_temp0';
  }

  @override
  String get bibleVerseListenFromHere => 'Listen from here';

  @override
  String get bibleVerseListenFromHereDetail => 'Read aloud, verse by verse';

  @override
  String get bibleVerseSave => 'Save';

  @override
  String get bibleVerseSaved => 'Saved';

  @override
  String bibleVerseSemantics(int number, String text) {
    return 'Verse $number. $text';
  }

  @override
  String get bibleVerseStudy => 'Study this verse';

  @override
  String get bibleVerseStudyDetail =>
      'Original languages, Strong\'s, concordance and references';

  @override
  String get canonEvangelhosBlurb => 'Matthew to John — the life of Jesus';

  @override
  String get canonEvangelhosTitle => 'Gospels';

  @override
  String get canonGeraisBlurb => 'Hebrews to Jude';

  @override
  String get canonGeraisTitle => 'General letters';

  @override
  String get canonHistoriaNtBlurb => 'Acts of the Apostles';

  @override
  String get canonHistoriaNtTitle => 'History';

  @override
  String get canonHistoricosBlurb => 'Joshua to Esther — the history of Israel';

  @override
  String get canonHistoricosTitle => 'Historical';

  @override
  String get canonPaulinasBlurb => 'Romans to Philemon';

  @override
  String get canonPaulinasTitle => 'Pauline letters';

  @override
  String get canonPentateucoBlurb => 'The Law — Genesis to Deuteronomy';

  @override
  String get canonPentateucoTitle => 'Pentateuch';

  @override
  String get canonPoeticosBlurb => 'Job to Song of Songs';

  @override
  String get canonPoeticosTitle => 'Poetic and wisdom';

  @override
  String get canonProfeciaBlurb => 'Revelation';

  @override
  String get canonProfeciaTitle => 'Prophecy';

  @override
  String get canonProfetasMaioresBlurb => 'Isaiah to Daniel';

  @override
  String get canonProfetasMaioresTitle => 'Major prophets';

  @override
  String get canonProfetasMenoresBlurb => 'Hosea to Malachi';

  @override
  String get canonProfetasMenoresTitle => 'Minor prophets';

  @override
  String get categoryApocalipseBlurb =>
      'The book of Revelation, written by John the Evangelist.';

  @override
  String get categoryApocalipseTitle => 'Revelation';

  @override
  String get categoryCristologiaTitle => 'Christology';

  @override
  String get categoryDiscipuladoTitle => 'Discipleship';

  @override
  String get categoryEpistolasBlurb =>
      'Twenty-one letters to the early churches — thirteen by Paul and eight by other authors.';

  @override
  String get categoryEpistolasTitle => 'Epistles or apostolic letters';

  @override
  String get categoryEvangelhosBlurb =>
      'Birth, ministry, death, resurrection, and ascension of Jesus — Matthew to John.';

  @override
  String get categoryEvangelhosTitle => 'Gospels';

  @override
  String get categoryHermeneuticaTitle => 'Hermeneutics';

  @override
  String get categoryHistoriaIgrejaTitle => 'Church history';

  @override
  String get categoryHistoricosAtBlurb =>
      'The history of Israel from the conquest of the Promised Land to the Babylonian exile.';

  @override
  String get categoryHistoricosAtTitle => 'Historical books';

  @override
  String get categoryHistoricosNtBlurb =>
      'Acts of the Apostles — the outpouring of the Spirit and the spread of the Gospel.';

  @override
  String get categoryHistoricosNtTitle => 'Early church history';

  @override
  String get categoryIntertestamentarioBlurb =>
      'About 400 years of silence between the Old and New Testaments.';

  @override
  String get categoryIntertestamentarioTitle => 'Intertestamental period';

  @override
  String get categoryLinguasTitle => 'Original languages';

  @override
  String get categoryOracaoTitle => 'Prayer';

  @override
  String get categoryPentateucoBlurb =>
      'The first five books of the Bible — the Torah, the Book of the Law, in chronological order.';

  @override
  String get categoryPentateucoTitle => 'Pentateuch';

  @override
  String get categoryPoeticosBlurb =>
      'Poetry, wisdom, proverbs, and songs — arranged by relevance.';

  @override
  String get categoryPoeticosTitle => 'Poetic books';

  @override
  String get categoryProfetasMaioresBlurb =>
      'Isaiah to Daniel — the longer works among the prophetic writings.';

  @override
  String get categoryProfetasMaioresTitle => 'Major prophets';

  @override
  String get categoryProfetasMenoresBlurb =>
      'Hosea to Malachi — twelve books; the name refers to length, not importance.';

  @override
  String get categoryProfetasMenoresTitle => 'Minor prophets';

  @override
  String get categorySistematicaTitle => 'Systematic and dogmatic theology';

  @override
  String get celebrationBackHome => 'Back to home';

  @override
  String get celebrationBackToMap => 'Back to map';

  @override
  String get celebrationCleanScene => 'Clean scene';

  @override
  String celebrationCommitmentBeyond(int goal) {
    return 'Past your $goal-day commitment.';
  }

  @override
  String celebrationCommitmentDone(int goal) {
    return '$goal-day commitment complete!';
  }

  @override
  String celebrationCommitmentLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left to your commitment.',
      one: '1 day left to your commitment.',
    );
    return '$_temp0';
  }

  @override
  String get celebrationEchoKicker => 'Today you saw';

  @override
  String get celebrationHelpContinue => 'Help keep it going';

  @override
  String get celebrationInviteSubtitle =>
      'One companion. No ranking — just presence.';

  @override
  String get celebrationInviteTitle => 'A companion on the trail';

  @override
  String celebrationModeDone(String mode) {
    return '$mode mode complete';
  }

  @override
  String celebrationModeRetryPrompt(String mode, String subtitle) {
    return 'How about answering again in $mode? $subtitle';
  }

  @override
  String celebrationModeReviewCta(String mode) {
    return 'Review a scene in $mode';
  }

  @override
  String celebrationModeSwitchCta(String mode) {
    return 'Switch to $mode';
  }

  @override
  String celebrationModeTryCta(String mode) {
    return 'Try in $mode';
  }

  @override
  String celebrationModeTryPrompt(String mode) {
    return 'Want to try this scene\'s questions in $mode?';
  }

  @override
  String celebrationSceneDoneIn(String mode) {
    return 'Scene complete in $mode';
  }

  @override
  String get celebrationSealKicker => 'Encounter';

  @override
  String get celebrationStatAccuracy => 'Accuracy';

  @override
  String get celebrationStatDay => 'Day';

  @override
  String get celebrationStatDays => 'Days';

  @override
  String get celebrationStatSteps => 'Steps';

  @override
  String celebrationStreakPlusDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+1 day · $count-day streak',
      one: '+1 day · 1-day streak',
    );
    return '$_temp0';
  }

  @override
  String get celebrationStreakStarted => 'Your streak started today.';

  @override
  String get celebrationTomorrowKicker => 'Tomorrow';

  @override
  String get chestBencaoMessage =>
      '\"The Lord bless you and keep you\" — Numbers 6:24.';

  @override
  String get chestBencaoTitle => 'Rare blessing';

  @override
  String get chestDailyTitle => 'Daily chest';

  @override
  String get chestGraoMessage =>
      'Small today, a seed of something greater tomorrow.';

  @override
  String get chestGraoTitle => 'Grain of wheat';

  @override
  String get chestGuardadaMessage =>
      'This moment is worth a verse kept in the heart today.';

  @override
  String get chestGuardadaTitle => 'Word kept';

  @override
  String get chestLampadaMessage =>
      '\"Your word is a lamp to my feet\" — Psalm 119:105.';

  @override
  String get chestLampadaTitle => 'Lit lamp';

  @override
  String get chestLocked => 'Finish today\'s scene to open it';

  @override
  String get chestLockedShort => 'Locked';

  @override
  String get chestMapaMessage =>
      'A kept curiosity: every chapter you read adds to your trail.';

  @override
  String get chestMapaTitle => 'Map of the day';

  @override
  String get chestOpen => 'Open the chest';

  @override
  String get chestOpenShort => 'Open';

  @override
  String get chestOpened => 'Opened';

  @override
  String get chestOpening => 'Opening…';

  @override
  String get chestPassoMessage =>
      'One more day walking — that is what forms a pilgrim.';

  @override
  String get chestPassoTitle => 'Steady step';

  @override
  String get chestReady => 'Today\'s reward is ready';

  @override
  String get chestReadyShort => 'Ready to open';

  @override
  String get chestRevealStarts => 'The reveal starts now.';

  @override
  String get chestRewards => 'Rewards';

  @override
  String get chestSheetTitle => 'Today\'s streak holds a reward.';

  @override
  String chestTierToday(String tier) {
    return 'Today\'s $tier';
  }

  @override
  String get chestVeryRare => 'Very rare';

  @override
  String get chestVozMessage =>
      'Your streak already speaks louder than any word.';

  @override
  String get chestVozTitle => 'Voice of the caravan';

  @override
  String get comebackEyebrow => 'The pilgrim';

  @override
  String comebackSubtitle(String name, int bonus) {
    return '$name, the trail is waiting for you. One scene restarts your streak and earns +$bonus welcome-back steps.';
  }

  @override
  String comebackSubtitleGap(String name, int count, int bonus) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$name, it\'s been $count days without a scene. Just one is enough — and you get +$bonus welcome-back steps.',
      one:
          '$name, it\'s been 1 day without a scene. Just one is enough — and you get +$bonus welcome-back steps.',
    );
    return '$_temp0';
  }

  @override
  String get comebackTitle => 'Your streak is waiting';

  @override
  String get commonActive => 'Active';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCollect => 'Collect';

  @override
  String get commonComingSoon => 'Coming soon';

  @override
  String get commonContinue => 'Continue';

  @override
  String commonDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get commonGotIt => 'Got it';

  @override
  String get commonModule => 'Module';

  @override
  String get commonNextScene => 'Next scene';

  @override
  String get commonNotNow => 'Not now';

  @override
  String get commonOff => 'Off';

  @override
  String commonPlusSteps(int count) {
    return '+$count steps';
  }

  @override
  String get commonSave => 'Save';

  @override
  String get commonScene => 'Scene';

  @override
  String commonScenes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scenes',
      one: '1 scene',
    );
    return '$_temp0';
  }

  @override
  String get commonSendWhatsApp => 'Send on WhatsApp';

  @override
  String get commonShare => 'Share';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonStart => 'Start';

  @override
  String commonSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String get commonToday => 'Today';

  @override
  String get commonTrail => 'Trail';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonYou => 'You';

  @override
  String get companionAwaitingCode =>
      'Waiting for someone to join with the code';

  @override
  String companionDaysTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days walking together',
      one: '1 day walking together',
    );
    return '$_temp0';
  }

  @override
  String companionDaysWithoutStudy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days behind on the walk',
      one: '1 day behind on the walk',
    );
    return '$_temp0';
  }

  @override
  String get companionDelayDustyHeadline => 'Missing you on the trail';

  @override
  String get companionDelayDustyInsight => 'Dust has already covered the path';

  @override
  String get companionDelayFreshHeadline => 'Falling behind';

  @override
  String get companionDelayFreshInsight => 'Falling behind on our walk';

  @override
  String get companionDelayLostHeadline => 'There\'s still room by my side';

  @override
  String get companionDelayLostInsight => 'But we can pick up our walk again';

  @override
  String get companionErrorAlreadyHave => 'You already have a companion.';

  @override
  String get companionErrorCreateInvite => 'Couldn\'t create the invite.';

  @override
  String get companionErrorInvalidCode =>
      'Invalid code or the companion pair is already full.';

  @override
  String get companionErrorSignInCreate =>
      'Sign in with Google to create a companion.';

  @override
  String get companionErrorSignInJoin =>
      'Sign in with Google to join a companion.';

  @override
  String get companionErrorSignInWave => 'Sign in to wave in the app.';

  @override
  String get companionErrorWave => 'Couldn\'t send the wave.';

  @override
  String get companionFallbackName => 'Companion';

  @override
  String get companionNextStepTogether =>
      'Shall we take the next step together?';

  @override
  String companionPartnerAway(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days without studying — the trail misses $name',
      one: '1 day without studying — the trail misses $name',
    );
    return '$_temp0';
  }

  @override
  String companionPartnerAwayAfterStep(String name, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'You already took your step — $name is $_temp0 behind';
  }

  @override
  String companionPartnerNotYet(String name) {
    return 'You already took your step — $name hasn\'t shown up yet';
  }

  @override
  String get companionPresetComeBack =>
      'I\'m waiting for you to clear the trail';

  @override
  String get companionPresetMissed => 'I missed you on the trail';

  @override
  String get companionPresetOnTrail => 'I\'m waiting for you on the trail';

  @override
  String get companionPresetResume => 'We can pick it up — I\'m here';

  @override
  String get companionPresetStepCome => 'I took my step today. Coming?';

  @override
  String get companionPresetWalkToday => 'Let\'s walk together today';

  @override
  String get companionPresetYoursNext =>
      'I already took my step — yours is next';

  @override
  String companionShareDefault(String name) {
    return 'Hey $name 👋\nI already took my steps today in Stway — I\'m waiting for you!\nComing?';
  }

  @override
  String companionShareDusty(String name, int days) {
    return 'Hey $name 👋\nIt\'s been $days days since we last walked together in Stway.\nThe path stays open — I\'m waiting for you!\nComing?';
  }

  @override
  String get companionShareFallbackName => 'you';

  @override
  String companionShareFresh(String name) {
    return 'Hey $name 👋\nI missed you on our walk in Stway.\nI already took my steps today and I\'m waiting for you!\nComing?';
  }

  @override
  String companionShareLost(String name, int days) {
    return 'Hey $name 👋\nThere\'s still room by my side!\nIt\'s been $days days since we last walked together in Stway.\n\nBut we can pick it up — I already took my steps today.\nComing?';
  }

  @override
  String get companionSheetEyebrow => 'Companion';

  @override
  String companionSheetFormedBody(int steps) {
    return 'You walk together now.\nComplete all 7 days of the week: +$steps journey steps for both of you.';
  }

  @override
  String companionSheetFormedBodyNamed(String name, int steps) {
    return 'Now you and $name walk together.\nComplete all 7 days of the week: +$steps journey steps for both of you.';
  }

  @override
  String get companionSheetFormedCta => 'Walk together';

  @override
  String get companionSheetFormedTitle => 'Companion joined';

  @override
  String get companionSheetInviteConfirmSubtitle =>
      'Someone invited you to walk together.\nOne tap — no code to type.';

  @override
  String get companionSheetInviteConfirmTitle => 'Companion invite';

  @override
  String get companionSheetInviteCta => 'Invite a companion';

  @override
  String companionSheetPromptBody(int steps) {
    return 'One companion. Complete all 7 days of the week together — you both get +$steps journey steps.';
  }

  @override
  String companionSheetPromptBodyTomorrow(String scene) {
    return 'Tomorrow: $scene. Invite someone to get there together.';
  }

  @override
  String get companionSheetPromptTitle => 'Invite someone to walk with you';

  @override
  String get companionWalkedTogetherToday => 'You walked together today';

  @override
  String companionWaveFor(String name) {
    return 'You already took your step — wave to $name';
  }

  @override
  String get companionWeekClosed => 'Week closed together';

  @override
  String companionWeekDays(int count) {
    return '$count of 7 days together this week';
  }

  @override
  String companionYourTurn(String name) {
    return '$name already walked — your turn';
  }

  @override
  String cornerAcceptedBy(String name) {
    return '$name accepted the challenge';
  }

  @override
  String get cornerActionFailed => 'Couldn\'t finish that. Try again.';

  @override
  String get cornerArrivedMark => 'Arrived';

  @override
  String cornerBoardEmptyBody(int count) {
    return 'In the caravan, open someone on the same scene and invite them to the challenge. Whoever arrives by Sunday gets +$count steps.';
  }

  @override
  String get cornerBoardEmptyTitle => 'No challenges yet';

  @override
  String get cornerBoardFilterEmpty => 'None yet';

  @override
  String get cornerBoardIdle =>
      'No challenge this week. Invite someone from the caravan.';

  @override
  String get cornerBoardOpenCaravan => 'See the caravan';

  @override
  String get cornerBurstAccepted => 'Challenge accepted';

  @override
  String get cornerBurstLeft => 'You left the challenge';

  @override
  String get cornerBurstSent => 'Invite sent';

  @override
  String get cornerBusyAccept =>
      'You already have a challenge. Finish it or leave it to accept.';

  @override
  String get cornerBusyWeek => 'You already have a challenge this week.';

  @override
  String get cornerCancelled => 'Challenge cancelled';

  @override
  String cornerChallengeWith(String name) {
    return 'Challenge with $name';
  }

  @override
  String get cornerClosedChapter => 'Closed';

  @override
  String get cornerClosesToday => 'Closes today';

  @override
  String get cornerCtaInvite => 'Invite to the challenge';

  @override
  String cornerDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get cornerDeadline => 'By Sunday.';

  @override
  String get cornerDeclinedAnon => 'The invite wasn\'t accepted.';

  @override
  String cornerDeclinedBy(String name) {
    return '$name didn\'t accept this time.';
  }

  @override
  String get cornerDifferentScene => 'You\'re not on the same scene.';

  @override
  String get cornerDifferentTrail => 'You\'re not on the same trail.';

  @override
  String get cornerHoldAccept => 'Hold to accept';

  @override
  String get cornerHoldInvite => 'Hold to invite';

  @override
  String cornerIncomingFrom(String name) {
    return '$name invited you to this scene.';
  }

  @override
  String get cornerIncomingFromAnon => 'Someone invited you to this scene.';

  @override
  String get cornerIncomingTitle => 'Challenge invite';

  @override
  String cornerInviteBody(String name, int count) {
    return 'You and $name do this scene by Sunday.\n+$count steps for each one who arrives.';
  }

  @override
  String cornerInviteBodyAnon(int count) {
    return 'Same scene by Sunday.\n+$count steps for each one who arrives.';
  }

  @override
  String cornerInviteTitle(String mission) {
    return 'Challenge: $mission';
  }

  @override
  String get cornerKicker => 'Challenge';

  @override
  String get cornerLeftMark => 'Left';

  @override
  String get cornerNeedsCloud => 'Sign in with Google to invite someone.';

  @override
  String get cornerNoCorner => 'No scene in common for the challenge.';

  @override
  String get cornerNoneHeadline => 'Nobody arrived this time';

  @override
  String get cornerNoneLine => 'The challenge closed on Sunday.';

  @override
  String get cornerOnTheWay => 'On the way';

  @override
  String get cornerOtherPerson => 'The other person';

  @override
  String get cornerOtherPersonLower => 'the other person';

  @override
  String cornerRecordArrived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed',
      one: '1 completed',
    );
    return '$_temp0';
  }

  @override
  String get cornerRecordChapter => 'Challenges';

  @override
  String cornerRecordTogether(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count together',
      one: '1 together',
    );
    return '$_temp0';
  }

  @override
  String cornerResultLeft(int count) {
    return 'You left · without the +$count steps';
  }

  @override
  String cornerResultNone(String name) {
    return 'With $name · nobody arrived';
  }

  @override
  String cornerResultTheyArrived(String name) {
    return '$name arrived · you didn\'t';
  }

  @override
  String cornerResultTheyLeftMissed(String name) {
    return '$name left · you didn\'t arrive';
  }

  @override
  String cornerResultTogether(String name) {
    return 'With $name · you both arrived';
  }

  @override
  String cornerResultWon(String name, int count) {
    return 'With $name · +$count steps';
  }

  @override
  String cornerSameStretch(int count) {
    return 'Same scene by Sunday. +$count steps for each one who arrives.';
  }

  @override
  String get cornerSendFailed => 'Couldn\'t send the invite. Try again.';

  @override
  String get cornerSomeone => 'Someone';

  @override
  String get cornerStripIdle => 'None this week';

  @override
  String cornerStripInvitedYou(String name) {
    return '$name invited you';
  }

  @override
  String cornerStripLost(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lost',
    );
    return '$_temp0';
  }

  @override
  String cornerStripWaiting(String name) {
    return 'Waiting for $name';
  }

  @override
  String cornerStripWon(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count won',
    );
    return '$_temp0';
  }

  @override
  String get cornerTallyLost => 'Lost';

  @override
  String get cornerTallyTogether => 'Together';

  @override
  String get cornerTallyWon => 'Won';

  @override
  String cornerTheyAhead(String name) {
    return '$name already arrived. You\'re next.';
  }

  @override
  String cornerTheyArrived(String name) {
    return '$name arrived';
  }

  @override
  String cornerTheyLeft(String name) {
    return '$name left. You can still arrive.';
  }

  @override
  String cornerTheyLeftClosed(String name) {
    return '$name left the challenge.';
  }

  @override
  String get cornerTogether => 'You arrived together';

  @override
  String get cornerTogetherLine => 'You both did the scene in time.';

  @override
  String cornerWaitingArrival(String name) {
    return 'You arrived · waiting for $name.';
  }

  @override
  String cornerWaitingOn(String name) {
    return 'Waiting for $name to accept.';
  }

  @override
  String get cornerWaitingOnAnon => 'Waiting for them to accept.';

  @override
  String get cornerWalk => 'Do the scene';

  @override
  String get cornerWhisperEach => 'Every scene you do counts.';

  @override
  String get cornerWhisperTogether => 'Scenes done side by side.';

  @override
  String cornerWithPeer(String name) {
    return 'With $name · by Sunday';
  }

  @override
  String get cornerWithdraw => 'Leave the challenge';

  @override
  String cornerWithdrawBody(String name, int count) {
    return '$name keeps going and can still arrive. You won\'t get the +$count steps.';
  }

  @override
  String get cornerWithdrawConfirm => 'Leave';

  @override
  String cornerWithdrawPending(String name) {
    return 'The invite disappears for $name.';
  }

  @override
  String get cornerWithdrawTitle => 'Leave the challenge?';

  @override
  String get cornerYouArrived => 'You arrived';

  @override
  String get cornerYouLeft => 'You left the challenge.';

  @override
  String get crossingChip => 'Crossing';

  @override
  String dustAwayManyFreeze(String name, int daysAway) {
    String _temp0 = intl.Intl.pluralLogic(
      daysAway,
      locale: localeName,
      other: '$daysAway days without walking',
      one: '1 day without walking',
    );
    return '$name, $_temp0. Freeze still covers 1 miss — pick up the walk.';
  }

  @override
  String dustAwayManyNoFreeze(String name, int daysAway) {
    String _temp0 = intl.Intl.pluralLogic(
      daysAway,
      locale: localeName,
      other: '$daysAway days without walking',
      one: '1 day without walking',
    );
    return '$name, $_temp0. One scene restarts the path.';
  }

  @override
  String dustAwayNoStreak(String name) {
    return '$name, the trail is waiting. One scene is enough to pick up the path.';
  }

  @override
  String dustAwayStreak(String name, int streak) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '$streak streak days are waiting',
      one: '1 streak day is waiting',
    );
    return '$name, $_temp0. One scene and you pick it up.';
  }

  @override
  String dustAwayTwoFreeze(String name) {
    return '$name, two days without walking. Freeze can still save 1 day — come back today.';
  }

  @override
  String dustAwayTwoNoFreeze(String name) {
    return '$name, two days without walking. One scene and you\'re back on the path.';
  }

  @override
  String get dustCanReturn => 'You can come back';

  @override
  String get dustComeBackToday => 'Come back today';

  @override
  String get dustContinueWhere => 'Continue where you left off';

  @override
  String get dustDayEnding => 'The day is ending';

  @override
  String dustEveningFreeze1(String name, String countdown) {
    return '$name, the day is closing. $countdown left — walk, or freeze covers 1 day.';
  }

  @override
  String dustEveningFreeze2(String countdown) {
    return 'Last $countdown. Keep walking — freeze still covers 1 day.';
  }

  @override
  String dustEveningNoFreeze2(String countdown) {
    return 'Night closing in. $countdown left — keep walking now.';
  }

  @override
  String get dustFewHours => 'A few hours left';

  @override
  String get dustHeroGapFreeze =>
      'Yesterday was empty. Do today\'s scene — freeze still saves 1 day.';

  @override
  String get dustHeroGapNoFreeze =>
      'Yesterday was empty. Do today\'s scene so you don\'t lose the streak.';

  @override
  String dustHeroRiskFreeze(int streak, String countdown) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other:
          '$countdown until the $streak-day streak drops. Do today\'s scene — freeze still saves 1 day.',
      one:
          '$countdown until the streak drops. Do today\'s scene — freeze still saves 1 day.',
      zero:
          '$countdown until the streak drops. Do today\'s scene — freeze still saves 1 day.',
    );
    return '$_temp0';
  }

  @override
  String dustHeroRiskNoFreeze(int streak, String countdown) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other:
          '$countdown until the $streak-day streak drops. Do today\'s scene.',
      one: '$countdown until the streak drops. Do today\'s scene.',
      zero: '$countdown until the streak drops. Do today\'s scene.',
    );
    return '$_temp0';
  }

  @override
  String get dustNextSceneWaits => 'The next scene is waiting';

  @override
  String get dustOneDay => 'One day';

  @override
  String dustRiskBodyFreeze1(String name, String countdown) {
    return '$name · $countdown left. One scene protects the streak — freeze covers 1 day.';
  }

  @override
  String dustRiskBodyFreeze3(String countdown) {
    return '$countdown left. Keep walking — freeze covers 1 day.';
  }

  @override
  String dustRiskBodyNoFreeze1(String name, String countdown) {
    return '$name · no freeze. $countdown left. One scene and you stay.';
  }

  @override
  String dustRiskBodyNoFreeze2(int streak, String countdown) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '$streak days at risk. $countdown left — walk now.',
      one: '1 day at risk. $countdown left — walk now.',
    );
    return '$_temp0';
  }

  @override
  String dustRiskBodyNoFreeze3(String countdown) {
    return 'No freeze. $countdown left — walk now.';
  }

  @override
  String dustRiskBodyStreak(int streak, String countdown) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '$streak-day streak still in play. $countdown left.',
      one: '1-day streak still in play. $countdown left.',
    );
    return '$_temp0';
  }

  @override
  String get dustSceneToday => 'One scene today';

  @override
  String get dustSceneTodayWaits => 'Today\'s scene is waiting';

  @override
  String get dustSceneWaits => 'The scene is waiting';

  @override
  String get dustStillTime => 'There\'s still time';

  @override
  String get dustStreakWaits => 'The streak is waiting';

  @override
  String get dustTrailWaits => 'The trail is waiting';

  @override
  String get dustTwoDays => 'Two days';

  @override
  String get dustUiDetail2 => 'Keep walking · one scene is enough';

  @override
  String get dustUiDetail3 => 'The streak is waiting · walk today';

  @override
  String get dustUiFreeze1 => 'Streak at risk · freeze still covers 1 day';

  @override
  String get dustUiFreeze2 => 'There\'s still time · freeze ready';

  @override
  String get dustUiFreeze3 => 'Walk today · freeze covers 1 miss';

  @override
  String get dustUiNoFreeze1 => 'Streak at risk · walk now';

  @override
  String get dustUiNoFreeze2 => 'No freeze · one scene protects';

  @override
  String get dustUiNoFreeze3 => 'The streak is waiting · one scene catches up';

  @override
  String get entryMissionDorAnsia01CentralInsight => 'Treasure pulls the heart';

  @override
  String get entryMissionDorAnsia01HookNote =>
      'The Father\'s care is the argument against anxiety — not the absence of need.';

  @override
  String get entryMissionDorAnsia01Intro =>
      'Where the treasure is, the heart is. Jesus joins Mammon and tomorrow.';

  @override
  String get entryMissionDorAnsia01Objective =>
      'See how Jesus links treasure, lordship, and anxiety.';

  @override
  String get entryMissionDorAnsia01Title => 'Treasures and anxiety';

  @override
  String get entryMissionDorAnsia02CentralInsight =>
      'Christ is enough in hunger and plenty';

  @override
  String get entryMissionDorAnsia02HookNote =>
      'Paul\'s contentment is not stoicism: it is Christ in hunger and plenty.';

  @override
  String get entryMissionDorAnsia02Intro =>
      'Paul learned to be content in every circumstance — in Christ.';

  @override
  String get entryMissionDorAnsia02Objective =>
      'Trade anxiety about having for contentment in Christ.';

  @override
  String get entryMissionDorAnsia02Title => 'Contentment';

  @override
  String get entryMissionDorAnsia03CentralInsight =>
      'There is a shepherd in the valley';

  @override
  String get entryMissionDorAnsia03HookNote =>
      'The shepherd leads — even in the valley. What fades is not the struggle; it is fear and the sense of loneliness.';

  @override
  String get entryMissionDorAnsia03Intro =>
      'I shall not want — Psalm 23 is trust, not magic.';

  @override
  String get entryMissionDorAnsia03Objective =>
      'Read Psalm 23 as care, not as a charm.';

  @override
  String get entryMissionDorAnsia03Title => 'The Lord is my shepherd';

  @override
  String get entryMissionDorAnsia04CentralInsight => 'The bread is for today';

  @override
  String get entryMissionDorAnsia04HookNote =>
      'Jesus teaches asking for the day — not the stockpile. The Kingdom comes before the bread.';

  @override
  String get entryMissionDorAnsia04Intro =>
      'Asking for daily bread is the opposite of anticipating the whole month.';

  @override
  String get entryMissionDorAnsia04Objective =>
      'Pray the day, not the census of fear.';

  @override
  String get entryMissionDorAnsia04Title => 'Our Father';

  @override
  String get entryMissionDorAnsia05CentralInsight => 'The inheritance is kept';

  @override
  String get entryMissionDorAnsia05HookNote =>
      'Hope does not deny suffering. It anchors it in the resurrection. Continue in the Sermon on the Mount.';

  @override
  String get entryMissionDorAnsia05Intro =>
      'Peter anchors sufferers in a kept inheritance — then, the canon.';

  @override
  String get entryMissionDorAnsia05Objective =>
      'Leave the pain trail for the curriculum: Sermon on the Mount.';

  @override
  String get entryMissionDorAnsia05Title => 'Living hope';

  @override
  String get entryMissionDorRecome01CentralInsight =>
      'God still asks where you are';

  @override
  String get entryMissionDorRecome01HookNote =>
      'The first move after the fall is God seeking — not the human hiding successfully.';

  @override
  String get entryMissionDorRecome01Intro =>
      'Distrust breaks communion — and still God asks.';

  @override
  String get entryMissionDorRecome01Objective =>
      'See the fall as a break, not the end of the conversation.';

  @override
  String get entryMissionDorRecome01Title => 'The fall';

  @override
  String get entryMissionDorRecome02CentralInsight =>
      'There is a seed after the door';

  @override
  String get entryMissionDorRecome02EchoQuestion =>
      'He asked. And after the answer, did the story end?';

  @override
  String get entryMissionDorRecome02HookNote =>
      'In the same chapter as the expulsion, God speaks of a seed. Judgment does not cancel the story.';

  @override
  String get entryMissionDorRecome02Intro =>
      'Sin has a cost. The promise does not vanish.';

  @override
  String get entryMissionDorRecome02Objective =>
      'Read consequence and promise in the same text.';

  @override
  String get entryMissionDorRecome02Title => 'Consequences';

  @override
  String get entryMissionDorRecome03CentralInsight =>
      'A fresh start is covenant, not erasing';

  @override
  String get entryMissionDorRecome03EchoQuestion =>
      'There is a seed after the door. Does the world start again by erasing the past?';

  @override
  String get entryMissionDorRecome03HookNote =>
      'The world starts again under covenant, not amnesia. The bow reminds God — and us.';

  @override
  String get entryMissionDorRecome03Intro =>
      'Judgment and a fresh start fit in the same God.';

  @override
  String get entryMissionDorRecome03Objective =>
      'See the flood as judgment that keeps a remnant.';

  @override
  String get entryMissionDorRecome03Title => 'Flood';

  @override
  String get entryMissionDorRecome04CentralInsight =>
      'A fresh start walks outward';

  @override
  String get entryMissionDorRecome04EchoQuestion =>
      'A fresh start is covenant. Is Babel fixed with another tower?';

  @override
  String get entryMissionDorRecome04HookNote =>
      'God does not fix Babel with another tower. He calls a family to be a blessing.';

  @override
  String get entryMissionDorRecome04Intro =>
      'Leaving the land is the fresh-start gesture that blesses others.';

  @override
  String get entryMissionDorRecome04Objective =>
      'Link a fresh start to a call, not to isolation.';

  @override
  String get entryMissionDorRecome04Title => 'Abram\'s call';

  @override
  String get entryMissionDorRecome05CentralInsight =>
      'There is comfort for those who truly mourn';

  @override
  String get entryMissionDorRecome05EchoQuestion =>
      'A fresh start walks outward. Those who mourn what died find what in the Kingdom?';

  @override
  String get entryMissionDorRecome05HookNote =>
      'The Kingdom does not rush grief. It comforts. The canonical trail begins in Genesis 1–11.';

  @override
  String get entryMissionDorRecome05Intro =>
      'Those who mourn what died are blessed. Continue in Genesis 1–11.';

  @override
  String get entryMissionDorRecome05Objective =>
      'Leave the pain trail for the curriculum: Genesis 1–11.';

  @override
  String get entryMissionDorRecome05Title => 'Those who mourn';

  @override
  String get entryTrailAnsiedadeDescription =>
      'Five scenes to cast tomorrow on the Father — then continue in the canon.';

  @override
  String get entryTrailAnsiedadeModuleTitle => 'Casting anxiety';

  @override
  String get entryTrailAnsiedadeTitle => 'Anxiety';

  @override
  String get entryTrailRecomecoDescription =>
      'Five scenes from the fall to the call — and back to Genesis 1–11.';

  @override
  String get entryTrailRecomecoModuleTitle => 'From the break to the call';

  @override
  String get entryTrailRecomecoTitle => 'Fresh start';

  @override
  String get eraChurchBlurb => 'Acts, epistles, and the consummation';

  @override
  String get eraChurchTitle => 'Church and letters';

  @override
  String get eraConquestBlurb => 'Promised land and the cycle of the judges';

  @override
  String get eraConquestTitle => 'Conquest and judges';

  @override
  String get eraDividedBlurb => 'Israel, Judah, and the voice of the prophets';

  @override
  String get eraDividedTitle => 'Kingdoms and prophets';

  @override
  String get eraExileBlurb => 'Babylon and the hope of return';

  @override
  String get eraExileTitle => 'Exile';

  @override
  String get eraExodusBlurb => 'Exit from Egypt, Sinai, and the wilderness';

  @override
  String get eraExodusTitle => 'Exodus and Law';

  @override
  String get eraGospelsBlurb => 'The four Gospels';

  @override
  String get eraGospelsTitle => 'Life of Jesus';

  @override
  String get eraOriginsBlurb => 'Creation, the Flood, and Abraham\'s family';

  @override
  String get eraOriginsTitle => 'Origins and patriarchs';

  @override
  String get eraReturnBlurb => 'Temple, walls, and the last of the prophets';

  @override
  String get eraReturnTitle => 'Return and restoration';

  @override
  String get eraUnitedBlurb => 'Saul, David, and Solomon';

  @override
  String get eraUnitedTitle => 'United monarchy';

  @override
  String get exerciseCheck => 'Check';

  @override
  String get exerciseCueMatch => 'Link each pair.';

  @override
  String get exerciseCueOrder => 'Build the sequence.';

  @override
  String get exerciseCueTap => 'Tap the passage that answers.';

  @override
  String get exerciseFalse => 'False';

  @override
  String get exerciseFalseMark => 'F';

  @override
  String get exerciseHint => 'Hint';

  @override
  String get exerciseHintUsed => 'Hint used';

  @override
  String get exerciseLabelBridge => 'Bridge';

  @override
  String get exerciseLabelClaim => 'Statement';

  @override
  String get exerciseLabelPairs => 'Pairs';

  @override
  String get exerciseLabelQuestion => 'Question';

  @override
  String get exerciseLabelSequence => 'Sequence';

  @override
  String get exerciseLabelWord => 'Word';

  @override
  String get exerciseMatchPair => 'Pair';

  @override
  String get exerciseMatchPick => 'Pick';

  @override
  String get exerciseNoteLabel => 'Context';

  @override
  String get exerciseTitleChoose => 'Choose the answer';

  @override
  String get exerciseTitleComplete => 'Complete the verse';

  @override
  String get exerciseTitleConnect => 'Connect the passages';

  @override
  String get exerciseTitleOrder => 'Put the facts in order';

  @override
  String get exerciseTitleTap => 'Tap the word';

  @override
  String get exerciseTitleTrueFalse => 'Judge the verse';

  @override
  String get exerciseTrue => 'True';

  @override
  String get exerciseTrueMark => 'T';

  @override
  String get exerciseTypeBestInterpretation => 'Interpretation';

  @override
  String get exerciseTypeChoice => 'Choose';

  @override
  String get exerciseTypeClassify => 'Classify';

  @override
  String get exerciseTypeComplete => 'Complete';

  @override
  String get exerciseTypeConnect => 'Connect';

  @override
  String get exerciseTypeExplain => 'Explain';

  @override
  String get exerciseTypeFindInText => 'In the text';

  @override
  String get exerciseTypeInsight => 'Insight';

  @override
  String get exerciseTypeMatch => 'Match';

  @override
  String get exerciseTypeOrder => 'Order';

  @override
  String get exerciseTypeReview => 'Review';

  @override
  String get exerciseTypeTap => 'Tap';

  @override
  String get exerciseTypeTextSupported => 'The text says';

  @override
  String get exerciseTypeTrueFalse => 'True / False';

  @override
  String get exerciseVerbAnswer => 'Answer';

  @override
  String get exerciseVerbJudge => 'Judge';

  @override
  String get feedbackAlmost => 'Almost';

  @override
  String get feedbackAnswer => 'Answer';

  @override
  String get feedbackCheer1 => 'That\'s it.';

  @override
  String get feedbackCheer2 => 'Correct.';

  @override
  String get feedbackCheer3 => 'Well done.';

  @override
  String get feedbackCheer4 => 'Right.';

  @override
  String get feedbackCorrect => 'Correct';

  @override
  String feedbackCorrection(String expected, String got) {
    return '$expected, not $got';
  }

  @override
  String get feedbackEndPartial => 'Finish with partial steps';

  @override
  String get feedbackFollow => 'Go on.';

  @override
  String get feedbackNotYet => 'Not yet';

  @override
  String get feedbackOutOfLamps => 'No lamps left';

  @override
  String get feedbackReadPassage => 'Read the scene text';

  @override
  String get feedbackReportSent => 'Report sent. Thank you.';

  @override
  String get feedbackReportTooltip => 'Report a problem with this question';

  @override
  String get feedbackRequeueHint =>
      'Try again or leave it for the end of the scene.';

  @override
  String get feedbackRereadHint => 'Reread the text and try again.';

  @override
  String get feedbackSeeRightWord => 'See the right word';

  @override
  String get feedbackSeeText => 'See it in the text';

  @override
  String get feedbackSkipToEnd => 'Skip and try at the end';

  @override
  String get feedbackTryAgain => 'Try again.';

  @override
  String get groupCallEmpty => 'No one from the caravan to invite right now.';

  @override
  String groupCallFull(int count) {
    return 'This group already has $count people.';
  }

  @override
  String get groupCallSubtitle =>
      'The invite shows up in the app. Or send the link on WhatsApp.';

  @override
  String get groupCallTitle => 'Invite people';

  @override
  String get groupCaptionNotYet => 'not yet';

  @override
  String get groupCaptionToday => 'today';

  @override
  String get groupCreateCta => 'Create group';

  @override
  String groupDayUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days ',
      one: 'day ',
    );
    return '$_temp0';
  }

  @override
  String groupDaysAway(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days without studying',
      one: '1 day without studying',
    );
    return '$_temp0';
  }

  @override
  String get groupEmptyLeaderBody =>
      'Everyone gets the same scene — even those who haven\'t reached it on the trail yet.';

  @override
  String get groupEmptyLeaderTitle =>
      'Which passage will the group study this week?';

  @override
  String groupEmptyMemberBody(String leader) {
    return '$leader picks the scene the group studies together.';
  }

  @override
  String get groupEmptyMemberTitle =>
      'This week\'s passage hasn\'t arrived yet.';

  @override
  String get groupInviteAccept => 'Accept';

  @override
  String groupInviteBody(String name, String kind) {
    return '$name invited you to the group · $kind.';
  }

  @override
  String get groupInviteCta => 'Invite';

  @override
  String get groupInviteLabel => 'Invite';

  @override
  String get groupInviteSendFailed => 'Couldn\'t send the invite. Try again.';

  @override
  String get groupInviteSending => 'Sending…';

  @override
  String get groupInviteSent => 'Invite sent';

  @override
  String get groupInviteUndo => 'Undo';

  @override
  String get groupInviteUndoFailed => 'Couldn\'t undo the invite. Try again.';

  @override
  String groupLeaderNoteTitle(String title, String name) {
    return '$title $name';
  }

  @override
  String get groupMenuClearStudy => 'Remove study of the week';

  @override
  String get groupMenuClose => 'Close the group';

  @override
  String groupMenuCopyCode(String code) {
    return 'Copy code $code';
  }

  @override
  String get groupMenuEdit => 'Edit name and type';

  @override
  String groupMenuGoal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Weekly goal · $count steps',
      one: 'Weekly goal · 1 step',
    );
    return '$_temp0';
  }

  @override
  String get groupMenuLeadSection => 'Lead the group';

  @override
  String get groupMenuLeave => 'Leave the group';

  @override
  String get groupMenuSetGoal => 'Set weekly goal';

  @override
  String get groupMenuTransfer => 'Hand over leadership';

  @override
  String get groupNewTitle => 'New group';

  @override
  String get groupPickStudyCta => 'Choose the study';

  @override
  String get groupPickerConfirmCta => 'Set for the group';

  @override
  String get groupPickerIntro =>
      'Everyone in the group gets the same scene, even those who haven\'t reached it yet.';

  @override
  String get groupPickerMarkScene => 'Set the scene';

  @override
  String get groupPickerNoteHint =>
      'Optional. E.g.: Read by Wednesday, we\'ll talk on Thursday.';

  @override
  String get groupPickerNoteLabel => 'Note for the group';

  @override
  String get groupPickerPreviewLabel => 'The group will see';

  @override
  String groupRosterSemantics(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name, $count days this week',
      one: '$name, 1 day this week',
    );
    return '$_temp0';
  }

  @override
  String groupSeatAlreadyWaved(String name) {
    return 'You already waved to $name today.';
  }

  @override
  String get groupSeatDaysInWeek => 'Days this week';

  @override
  String get groupSeatIdle => 'hasn\'t studied this week yet';

  @override
  String get groupSeatNever => 'hasn\'t studied yet';

  @override
  String get groupSeatSteps => 'Steps';

  @override
  String get groupSeatStudyDone => 'Done';

  @override
  String get groupSeatStudyNotYet => 'Not yet';

  @override
  String get groupSeatToday => 'studied today';

  @override
  String get groupSeatWeek => 'studied this week';

  @override
  String get groupSetupKindLabel => 'What the group is for';

  @override
  String groupSetupLimitHint(int limit) {
    return 'Up to $limit people. Big group? Start another — discipleship happens in small groups.';
  }

  @override
  String get groupSetupNameLabel => 'Name';

  @override
  String get groupStudyAgain => 'You\'re done · Study again';

  @override
  String get groupStudyCta => 'Study with the group';

  @override
  String groupStudyDoneCount(int done, int total) {
    return '$done of $total done';
  }

  @override
  String get groupStudyNobodyYet => 'Nobody has done it yet. Be the first.';

  @override
  String get groupStudySwap => 'Change';

  @override
  String get groupWeekStudy => 'Study of the week';

  @override
  String growthDayUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days ',
      one: 'day ',
    );
    return '$_temp0';
  }

  @override
  String growthDaysToStage(int count, String stage) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count streak days left to reach $stage',
      one: '1 streak day left to reach $stage',
    );
    return '$_temp0';
  }

  @override
  String growthFreezeUsed(String subtitle) {
    return '$subtitle · freeze already used this week';
  }

  @override
  String growthFruitSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count streak days · it bore fruit',
      one: '1 streak day · it bore fruit',
    );
    return '$_temp0';
  }

  @override
  String get growthHintDayZero => 'day 0';

  @override
  String growthNextIn(String stage, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Next: $stage · $count streak days to go',
      one: 'Next: $stage · 1 streak day to go',
    );
    return '$_temp0';
  }

  @override
  String growthNextMilestone(String stage) {
    return 'Next milestone: $stage';
  }

  @override
  String get growthPerfect => 'Perfect scene';

  @override
  String growthPerfectWith(String subtitle) {
    return 'Perfect scene · $subtitle';
  }

  @override
  String get growthSeedSubtitle => 'Do 1 scene today to become a Sprout';

  @override
  String get growthStageBranch => 'Branch';

  @override
  String get growthStageFruit => 'Fruit';

  @override
  String get growthStageSeed => 'Seed';

  @override
  String get growthStageSprout => 'Sprout';

  @override
  String get growthStageTree => 'Tree';

  @override
  String get growthWhisper =>
      'Each streak day climbs a milestone: Seed, Sprout, Branch, Tree and Fruit.';

  @override
  String get homeBibleOfflineSubtitle => 'Read without internet';

  @override
  String get homeCatalogDownloading => 'Downloading…';

  @override
  String get homeCatalogEmptyBody =>
      'Scenes download on first open. If the connection fails, tap to try again.';

  @override
  String get homeCatalogEmptyTitle => 'The scenes haven\'t arrived yet';

  @override
  String get homeDefaultName => 'Pilgrim';

  @override
  String get homeFreezeSheetBody =>
      'You missed a day, but your streak continues. A freeze covers one miss per week — walk today to keep going.';

  @override
  String get homeFreezeSheetTitle => 'A freeze covered yesterday';

  @override
  String homeGoalLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scenes left for your goal',
      one: '1 scene left for your goal',
    );
    return '$_temp0';
  }

  @override
  String get homeGoalMet => 'Daily goal met';

  @override
  String get homeHeroEcho => 'Echo of yesterday';

  @override
  String homeHeroExtraSteps(int count) {
    return '+$count steps · today\'s extra';
  }

  @override
  String get homeHeroFrozenLine => 'A freeze covered yesterday · streak kept';

  @override
  String get homeHeroMinutes => '~3 min';

  @override
  String get homeHeroProtect => 'Protects your streak · ~3 min';

  @override
  String get homeHeroReady => 'Scene ready';

  @override
  String get homeHeroTomorrow => 'Tomorrow';

  @override
  String homeJuntosNews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count updates',
      one: '1 update',
    );
    return '$_temp0';
  }

  @override
  String get homeLampsHint => 'A mistake puts one out · none left ends it';

  @override
  String homeLampsSemantics(int current, int max) {
    return '$current of $max lamps. Each mistake puts one out.';
  }

  @override
  String get homeLampsTitle => 'Lamps';

  @override
  String get homeMoodAlive => 'On track';

  @override
  String get homeMoodDusty => 'Streak at risk';

  @override
  String get homeMoodFrozen => 'Protected by a freeze';

  @override
  String get homeMoreToday => 'More for today';

  @override
  String homeOpenProfile(String name) {
    return 'Open $name\'s profile';
  }

  @override
  String get homeQuestsExtraCaption => 'Extra steps';

  @override
  String homeReviewCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count to reinforce',
      one: '1 to reinforce',
    );
    return '$_temp0';
  }

  @override
  String get homeReviewTitle => 'Review';

  @override
  String homeSeasonChipDoneSemantics(String season, int day, String dayTitle) {
    return '$season. Day $day done: $dayTitle';
  }

  @override
  String homeSeasonChipOpenSemantics(String season, int day, String dayTitle) {
    return '$season. Day $day: $dayTitle';
  }

  @override
  String homeSeasonChipSemantics(String season) {
    return '$season · open the season reading';
  }

  @override
  String homeSeasonDayDone(int day, String title) {
    return 'Day $day done · $title';
  }

  @override
  String homeSeasonDayLine(int day, String title) {
    return 'Day $day · $title';
  }

  @override
  String homeSeasonDayOf(int day, int total, String title) {
    return 'Day $day of $total · $title';
  }

  @override
  String homeSeasonDayOfDone(int day, int total, String title) {
    return 'Day $day of $total done · $title';
  }

  @override
  String get homeSeeTrails => 'See trails';

  @override
  String get homeStatAtRisk => 'at risk';

  @override
  String get homeStatFreeze => 'freeze';

  @override
  String get homeStatFreezeUsed => 'freeze used';

  @override
  String get homeStatGoal => 'goal';

  @override
  String homeStepsSemantics(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps on the journey',
      one: '1 step on the journey',
    );
    return '$_temp0';
  }

  @override
  String get homeTrailDoneBody => 'Pick the next one and keep learning.';

  @override
  String get homeTrailDoneTitle => 'Trail complete';

  @override
  String get homeWordInScene => 'In this scene';

  @override
  String homeWordRead(String reference) {
    return 'Read $reference';
  }

  @override
  String get homeWordWord => 'Word';

  @override
  String get inviteAcceptCta => 'Accept invite';

  @override
  String inviteCalledYou(String name) {
    return '$name invited you';
  }

  @override
  String inviteCardBody(String name) {
    return '$name invited you to walk together — no competition, just showing up.';
  }

  @override
  String get inviteCardHeadline => 'Walk together';

  @override
  String get inviteCardInstallHint =>
      'Have the app? Tap the invite link.\nNot yet? Download Stway and tap again.';

  @override
  String get inviteCodeCopied => 'Code copied';

  @override
  String get inviteCodeHint => 'Code';

  @override
  String inviteCompanionShareText(String name, String link, String installUrl) {
    return '$name invited you to walk together on Stway.\nNo competition — just showing up.\n\nTap to accept (if you have the app):\n$link\n\nDon\'t have Stway yet? Download it and tap the link again:\n$installUrl';
  }

  @override
  String get inviteCreateFailed => 'Couldn\'t create the invite. Try again.';

  @override
  String get inviteHaveCodeSubtitle =>
      'If you copied the code on WhatsApp, it already shows up here';

  @override
  String get inviteHaveCodeTitle => 'I have a code';

  @override
  String get inviteJoinCta => 'Join';

  @override
  String get inviteLinkHint =>
      'The link opens the app and accepts without typing the code';

  @override
  String get invitePreparing => 'Preparing…';

  @override
  String get inviteReadyTitle => 'Your invite is ready';

  @override
  String inviteRoomShareText(String code, String installUrl) {
    return 'Join me on Stway with the code $code.\n\nDon\'t have the app yet? Download it: $installUrl';
  }

  @override
  String get inviteScanHint => 'Point at the invite QR code';

  @override
  String get inviteScanQr => 'Scan QR';

  @override
  String get inviteShareCta => 'Share invite';

  @override
  String get inviteShareSubject => 'Stway invite — walk together';

  @override
  String get inviteSheetSubtitleCompanion =>
      'Tap the link, show the QR or send the card';

  @override
  String get inviteSheetSubtitleRoom => 'Show the QR or send the code';

  @override
  String get inviteSomeone => 'Someone';

  @override
  String get journalEmpty =>
      'When you lock in a scene, your answer is saved here.';

  @override
  String get journalTitle => 'Study notes';

  @override
  String get journeyBeyondHorizon => 'Still beyond the horizon';

  @override
  String get journeyLockedHint =>
      'Complete the previous trail to unlock this one.';

  @override
  String journeyModeAhead(String mode) {
    return '$mode up next';
  }

  @override
  String journeyModeInProgress(String mode) {
    return '$mode in progress';
  }

  @override
  String get journeyNow => 'Now';

  @override
  String get journeyPlay => 'Play';

  @override
  String journeyScenesLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scenes left',
      one: '1 scene left',
    );
    return '$_temp0';
  }

  @override
  String get journeySoonHint =>
      'Coming soon · this trail is still being written.';

  @override
  String get journeyTravessiaAhead => 'Crossing ahead';

  @override
  String get journeyYouAreHere => 'Where you are';

  @override
  String get juntosAccept => 'Accept';

  @override
  String get juntosBeforeLeaveBody =>
      'Choose who will lead the group after you.';

  @override
  String get juntosBeforeLeaveTitle => 'Before you leave';

  @override
  String get juntosBondNotStudying => 'Not studying';

  @override
  String get juntosBondNotYet => 'Not yet';

  @override
  String get juntosBondYourTurn => 'Your turn';

  @override
  String get juntosCancelInvite => 'Cancel invite';

  @override
  String get juntosCancelInviteError =>
      'Couldn\'t cancel the invite. Try again.';

  @override
  String get juntosCaravanEmptyBody =>
      'The leaderboard shows up once at least one more person is walking. Invite someone to the caravan — or start with a companion.';

  @override
  String get juntosCaravanEmptyTitle => 'The caravan is still small';

  @override
  String get juntosCaravanInviteCta => 'Invite to the caravan';

  @override
  String get juntosCaravanLoadError =>
      'Couldn\'t load the caravan. Pull to refresh.';

  @override
  String get juntosCaravanMonthBody =>
      'Everything counts: scenes, daily tasks, chests and companion. It resets on the 1st — newcomers can lead too.';

  @override
  String get juntosCaravanMonthStep1 => 'Study\na scene';

  @override
  String get juntosCaravanMonthStep2 => 'Add up\nsteps';

  @override
  String get juntosCaravanMonthStep3 => 'See the\npath';

  @override
  String get juntosCaravanMonthTitle => 'Who walked the most this month?';

  @override
  String juntosCaravanPilgrimsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pilgrims in the caravan',
      one: '1 pilgrim in the caravan',
    );
    return '$_temp0';
  }

  @override
  String get juntosCaravanShareSubject => 'Join the caravan on Stway';

  @override
  String juntosCaravanShareText(String name, String url) {
    return '$name is inviting you to the caravan on Stway — learn the Bible in short scenes and walk together on the leaderboard.\n\nGet it: $url';
  }

  @override
  String get juntosCaravanSignInLive =>
      'Sign in with Google to see the caravan live.';

  @override
  String get juntosCaravanTimeout =>
      'The caravan took too long to respond. Pull to refresh.';

  @override
  String get juntosCaravanWeekBody =>
      'Only steps from new scenes, Monday to Sunday. At the end of the week, the top move up a level and the bottom move down.';

  @override
  String get juntosCaravanWeekStep1 => 'Steps\nthis week';

  @override
  String get juntosCaravanWeekStep2 => 'Place on the\nleaderboard';

  @override
  String get juntosCaravanWeekStep3 => 'Move up\nor down';

  @override
  String get juntosCaravanWeekTitle => 'Who moved ahead this week?';

  @override
  String juntosChallengeExplainerBody(String reward) {
    return 'Same scene, by Sunday. Whoever gets there earns $reward — if you both do, you both earn it.';
  }

  @override
  String get juntosChallengeExplainerTitle => 'Who gets there by Sunday?';

  @override
  String get juntosChallengeStep1 => 'Same\nscene';

  @override
  String get juntosChallengeStep2 => 'Get there\nby Sunday';

  @override
  String get juntosChallengeStep3 => '+10 steps\non arrival';

  @override
  String get juntosChoose => 'Choose';

  @override
  String juntosChromeTabAlert(String label) {
    return '$label, new';
  }

  @override
  String get juntosCloseConfirm => 'Close';

  @override
  String get juntosCloseRoomBody =>
      'The group disappears for everyone and the code stops working. This can\'t be undone.';

  @override
  String get juntosCloseRoomTitle => 'Close the group?';

  @override
  String get juntosClosesToday => 'Closes today';

  @override
  String get juntosCodeCopied => 'Code copied';

  @override
  String get juntosCodeLabel => 'Code';

  @override
  String juntosCodeTapToCopy(String code) {
    return 'Code $code. Tap to copy';
  }

  @override
  String get juntosCompanionExplainerBody =>
      'A study companion. On days you both walk, the thread lights up and the streak grows.';

  @override
  String get juntosCompanionExplainerTitle => 'Who walks beside you?';

  @override
  String get juntosCompanionFallback => 'Companion';

  @override
  String get juntosCompanionStep1 => 'You both\nstudy';

  @override
  String get juntosCompanionStep2 => 'The day counts\ntogether';

  @override
  String get juntosCompanionStep3 => 'If one falls behind,\nthe other waves';

  @override
  String get juntosCompanionsOfflineBody =>
      'Sign in with Google to walk with a real person.';

  @override
  String get juntosCompanionsOfflineTitle => 'Companion needs the cloud';

  @override
  String get juntosConnecting => 'Connecting…';

  @override
  String get juntosCopy => 'Copy';

  @override
  String juntosCopyCodeSemantics(String code) {
    return 'Copy code $code';
  }

  @override
  String get juntosCreateInviteError =>
      'Couldn\'t create the invite. Try again.';

  @override
  String get juntosCreateRoom => 'Create group';

  @override
  String juntosDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get juntosDeclineInviteError =>
      'Couldn\'t decline the invite. Try again.';

  @override
  String juntosDemoteZone(String tier) {
    return 'Demotion zone · $tier';
  }

  @override
  String get juntosEditRoomTitle => 'Edit group';

  @override
  String juntosFirstMilestone(int count) {
    return 'First milestone: $count days together';
  }

  @override
  String juntosGapToAbove(int gap, int place) {
    return '$gap behind #$place';
  }

  @override
  String get juntosHaveCode => 'I have a code';

  @override
  String juntosInboxNews(int count) {
    return 'What\'s new · $count';
  }

  @override
  String get juntosInviteCompanion => 'Invite a companion';

  @override
  String get juntosInvitePeople => 'Invite people';

  @override
  String get juntosInviteShort => 'Invite';

  @override
  String get juntosJoin => 'Join';

  @override
  String get juntosJoinError => 'Couldn\'t join. Try again.';

  @override
  String get juntosJoinRoomHint => 'Code you received';

  @override
  String get juntosJoinRoomTitle => 'Join a group';

  @override
  String get juntosLeader => 'Leader';

  @override
  String juntosLeaveAllCompanionsBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $count companionships end. You\'ll have no companion.',
      one: 'The companionship ends. You\'ll have no companion.',
    );
    return '$_temp0';
  }

  @override
  String get juntosLeaveAllCompanionsCta => 'End all companionships';

  @override
  String get juntosLeaveAllCompanionsTitle => 'End all companionships?';

  @override
  String get juntosLeaveAllConfirm => 'End all';

  @override
  String get juntosLeaveCompanionBody =>
      'Your companionship with this person ends. The caravan goes on.';

  @override
  String get juntosLeaveCompanionCta => 'Leave companionship';

  @override
  String get juntosLeaveCompanionTitle => 'Leave the companionship?';

  @override
  String get juntosLeaveConfirm => 'Leave';

  @override
  String get juntosLeaveRoomBody =>
      'You\'ll leave the list. To come back, use the code again.';

  @override
  String get juntosLeaveRoomTitle => 'Leave the group?';

  @override
  String juntosMilestoneLeft(int count, int next) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count to go to the $next milestone',
      one: '1 to go to the $next milestone',
    );
    return '$_temp0';
  }

  @override
  String get juntosMilestones => 'Milestones';

  @override
  String juntosNextMilestone(int count) {
    return 'Next milestone: $count days';
  }

  @override
  String juntosOfTotal(int total) {
    return ' of $total';
  }

  @override
  String juntosOnlineSemantics(String countLabel) {
    return '$countLabel. See who\'s studying';
  }

  @override
  String get juntosOpenInvite => 'Open invite';

  @override
  String get juntosOpenInviteMissing => 'Someone\'s missing on the other side';

  @override
  String get juntosOrInviteCompanion => 'Or invite a companion';

  @override
  String juntosPromoteZone(String tier) {
    return 'Promotion zone · $tier';
  }

  @override
  String get juntosRoomAllStudied => 'The whole group studied this week.';

  @override
  String get juntosRoomBenefitList => 'List';

  @override
  String get juntosRoomBenefitListDetail => 'Who studied';

  @override
  String get juntosRoomBenefitStudy => 'Study';

  @override
  String get juntosRoomBenefitStudyDetail => 'Same scene';

  @override
  String get juntosRoomBenefitWave => 'Wave';

  @override
  String get juntosRoomBenefitWaveDetail => 'Who\'s gone quiet';

  @override
  String get juntosRoomChestAlready => 'Chest already collected this week';

  @override
  String juntosRoomChestClaimed(int count) {
    return 'Group chest · +$count steps';
  }

  @override
  String juntosRoomChestOpen(int count) {
    return 'Open the group chest · +$count steps';
  }

  @override
  String juntosRoomCreated(String code) {
    return 'Group created. Invite someone from the list, or send the code $code.';
  }

  @override
  String get juntosRoomFull =>
      'Group full. For more people, start another group.';

  @override
  String get juntosRoomGoalHint =>
      'Weekly total. Leave blank to remove the goal.';

  @override
  String get juntosRoomGoalLabel => 'Group goal';

  @override
  String juntosRoomGoalProgress(int sum, int goal) {
    return '$sum / $goal steps';
  }

  @override
  String get juntosRoomGoalTitle => 'Group steps goal';

  @override
  String get juntosRoomHalfStudied => 'Half the group has studied.';

  @override
  String get juntosRoomHintClaimed => 'Group chest collected this week.';

  @override
  String get juntosRoomHintHalf =>
      'The chest opens when half the group studies.';

  @override
  String get juntosRoomHintHalfOrGoal =>
      'The chest opens with half the group or the goal.';

  @override
  String get juntosRoomHintInvite =>
      'Invite people who study with you: small group, family, friends.';

  @override
  String get juntosRoomHintStudyToday => 'Study today to open the group chest.';

  @override
  String get juntosRoomJoinError => 'Couldn\'t join the group. Try again.';

  @override
  String juntosRoomJoined(String name) {
    return 'You joined $name.';
  }

  @override
  String get juntosRoomJoinedGeneric => 'You joined the group.';

  @override
  String juntosRoomLeaderLine(String leaderTitle, String leader, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$leaderTitle: $leader · $_temp0';
  }

  @override
  String juntosRoomMissingForHalf(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more people to reach half the group.',
      one: '1 more person to reach half the group.',
    );
    return '$_temp0';
  }

  @override
  String get juntosRoomNotStudiedToday => 'You haven\'t studied today yet.';

  @override
  String get juntosRoomOnlyYou => 'Just you in the group for now.';

  @override
  String get juntosRoomOptions => 'Group options';

  @override
  String get juntosRoomQrSubtitle =>
      'Point the camera or type the code to join';

  @override
  String juntosRoomShareText(
    String name,
    String url,
    String code,
    String storeUrl,
  ) {
    return 'Join the group \"$name\" on Stway.\nTap or point your camera:\n$url\n\nCode: $code\n\nThe list shows who studied this week.\n\nDon\'t have the app yet? Get it: $storeUrl';
  }

  @override
  String get juntosRoomStudySet => 'Study set for the group';

  @override
  String get juntosRoomStudySetError => 'Couldn\'t set the study. Try again.';

  @override
  String get juntosRoomsEmptyBody =>
      'A closed group: small group, discipleship or Sunday school. Set the scene of the week and see who studied — invite in the app or on WhatsApp.';

  @override
  String get juntosRoomsEmptyEyebrow =>
      'Small group · Discipleship · Sunday school';

  @override
  String get juntosRoomsEmptyTitle => 'Who studies with you?';

  @override
  String get juntosRoomsOfflineBody =>
      'The group lives in your account. Sign in with Google to create one or use a code.';

  @override
  String get juntosRoomsOfflineFoot =>
      'Without signing in, the code won\'t work';

  @override
  String get juntosRoomsOfflineTitle => 'Sign in to create the group';

  @override
  String get juntosSeenToday => 'Seen today';

  @override
  String get juntosShowQrShare => 'Show QR and share';

  @override
  String get juntosSomeone => 'Someone';

  @override
  String get juntosStudiedThisWeek => 'studied this week';

  @override
  String get juntosStudyToday => 'Study today';

  @override
  String get juntosStudyingNow => 'Studying now';

  @override
  String get juntosSwitchRoomBody => 'You\'ll leave the group you\'re in now.';

  @override
  String juntosSwitchRoomTitle(String name) {
    return 'Join $name?';
  }

  @override
  String get juntosTabCaravan => 'Caravan';

  @override
  String get juntosTabChallenge => 'Challenge';

  @override
  String get juntosTabCompanion => 'Companion';

  @override
  String get juntosTabGroups => 'Groups';

  @override
  String get juntosThisMonth => 'This month';

  @override
  String get juntosThisWeek => 'This week';

  @override
  String get juntosTie => 'Tie';

  @override
  String get juntosTogetherLegend => 'together';

  @override
  String juntosTogetherOfSeven(int count) {
    return '$count of 7 together';
  }

  @override
  String get juntosTransferBody =>
      'Whoever takes over sets the study and the goal, and waves to the group. You stay on the list.';

  @override
  String juntosTransferDone(String name) {
    return '$name now leads the group';
  }

  @override
  String get juntosTransferError =>
      'Couldn\'t hand over leadership. Try again.';

  @override
  String get juntosTransferTitle => 'Hand over leadership';

  @override
  String get juntosWaiting => 'Waiting';

  @override
  String get juntosWalkedToday => 'Walked today';

  @override
  String juntosWaveAt(String name) {
    return 'Wave at $name';
  }

  @override
  String get juntosWaveError => 'Couldn\'t wave. Try again.';

  @override
  String juntosWavedAt(String name) {
    return 'You waved at $name';
  }

  @override
  String juntosWavedAtYou(String name) {
    return '$name waved at you';
  }

  @override
  String get juntosWeekRankingEmpty =>
      'The weekly leaderboard only shows up with real people in the caravan.';

  @override
  String juntosWeekTogetherBonus(int count) {
    return 'Your companionship earned +$count steps on the journey';
  }

  @override
  String get juntosWho => 'Who?';

  @override
  String get juntosYouLower => 'you';

  @override
  String get languageCaptionDevice => 'Follows your device language.';

  @override
  String get languageCaptionEn => 'English (United States).';

  @override
  String get languageCaptionEs => 'Spanish (Spain).';

  @override
  String get languageCaptionPt => 'Brazilian Portuguese.';

  @override
  String get languageDevice => 'Device';

  @override
  String get languageHint =>
      'Trail content and the Bible are still in Portuguese for now.';

  @override
  String get languageSemantics => 'Interface language';

  @override
  String get languageSemanticsHint => 'Swipe or tap to choose the language';

  @override
  String get languageShortDevice => 'Auto';

  @override
  String get languageShortEn => 'EN';

  @override
  String get languageShortEs => 'ES';

  @override
  String get languageShortPt => 'PT';

  @override
  String get languageTitle => 'Language';

  @override
  String get leagueActiveToday => 'Active today';

  @override
  String leagueBonusEncourage(int count) {
    return '+$count encouragement steps';
  }

  @override
  String leagueDemotedBody(int rank, String tier) {
    return 'You finished #$rank. In the $tier level, you can climb again.';
  }

  @override
  String leagueDemotedTitle(String tier) {
    return 'You dropped to $tier';
  }

  @override
  String leagueDriftDown(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dropped $count places today',
      one: 'Dropped 1 place today',
    );
    return '$_temp0';
  }

  @override
  String get leagueDriftStable => 'Position steady today';

  @override
  String leagueDriftUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved up $count places today',
      one: 'Moved up 1 place today',
    );
    return '$_temp0';
  }

  @override
  String leagueLevelUpBodyOnly(String tier) {
    return 'Now you walk in the\n$tier level';
  }

  @override
  String leagueLevelUpBodyRank(int rank, String tier) {
    return 'Finished #$rank · now you walk in the\n$tier level';
  }

  @override
  String get leagueLevelUpTitle => 'You leveled up';

  @override
  String leaguePromotedLevelOnly(String tier) {
    return 'Now in the $tier level';
  }

  @override
  String leaguePromotedRankLine(int rank, String tier) {
    return 'Finished #$rank · now in the $tier level';
  }

  @override
  String leaguePromotedTitle(String tier) {
    return 'You rose to $tier';
  }

  @override
  String leagueRiskBodyClosing(int rank, String tier) {
    return 'You\'re #$rank in the $tier level. The caravan closes soon.';
  }

  @override
  String leagueRiskBodyHold(int rank, String tier) {
    return 'You\'re #$rank in the $tier level. One step can hold your place.';
  }

  @override
  String leagueRiskNear(String closes) {
    return 'Near the drop · $closes';
  }

  @override
  String leagueRiskZone(String closes) {
    return 'Drop zone · $closes';
  }

  @override
  String get leagueRoleLeader => 'Leader';

  @override
  String get leagueRolePodium => 'Podium';

  @override
  String get leagueRoleVice => 'Runner-up';

  @override
  String leagueSeenDate(String date) {
    return 'Seen $date';
  }

  @override
  String leagueSeenOn(String date) {
    return 'Seen on $date';
  }

  @override
  String get leagueSeenToday => 'Seen today';

  @override
  String leagueSeenTodayWalked(String date) {
    return 'Seen today · walked $date';
  }

  @override
  String leagueStayedBody(int rank, String tier) {
    return 'You finished #$rank in the $tier level. New week — keep walking.';
  }

  @override
  String leagueStudying(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count studying',
      one: '1 studying',
      zero: '0 studying',
    );
    return '$_temp0';
  }

  @override
  String get leagueTierCedro => 'Cedar';

  @override
  String get leagueTierEstrela => 'Star';

  @override
  String get leagueTierOliveira => 'Olive';

  @override
  String get leagueTierSemente => 'Seed';

  @override
  String get leagueTierVideira => 'Vine';

  @override
  String leagueWalkedDate(String date) {
    return 'Walked $date';
  }

  @override
  String leagueWalkedOn(String date) {
    return 'Walked on $date';
  }

  @override
  String leagueWalkedSeen(String walk, String seen) {
    return 'Walked $walk · seen $seen';
  }

  @override
  String get leagueWalkedToday => 'Walked today';

  @override
  String get leagueWeekEndedTitle => 'Caravan week closed';

  @override
  String get lessonBackToQuestion => 'Back to question';

  @override
  String get lessonBonus => 'Bonus';

  @override
  String get lessonBoss => 'Crossing';

  @override
  String lessonCombo(int count) {
    return '×$count';
  }

  @override
  String lessonComboMeterSemantics(int count) {
    return 'Streak $count';
  }

  @override
  String get lessonDuration => '~3 min';

  @override
  String get lessonExitAnyway => 'Leave anyway';

  @override
  String lessonExitBody(int act, int total) {
    return 'You\'re on question $act of $total. If you leave now, this scene\'s steps won\'t count.';
  }

  @override
  String get lessonExitTitle => 'Leave the scene?';

  @override
  String get lessonInsightSubtitle => 'What stayed with you';

  @override
  String lessonIntroBossPulse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Crossing · $count questions',
      one: 'Crossing · 1 question',
    );
    return '$_temp0';
  }

  @override
  String lessonIntroPulse(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~3 min · $count questions',
      one: '~3 min · 1 question',
    );
    return '$_temp0';
  }

  @override
  String lessonLampsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lamps left — each mistake puts one out.',
      one: '1 lamp left — each mistake puts one out.',
      zero: 'No lamps left — each mistake puts one out.',
    );
    return '$_temp0';
  }

  @override
  String get lessonListen => 'Listen to the text';

  @override
  String get lessonListenStop => 'Stop';

  @override
  String get lessonLoadError =>
      'Couldn\'t load this scene\'s questions. Try again.';

  @override
  String get lessonLocked => 'This scene is still locked.';

  @override
  String get lessonMicroSubtitle => 'Complete the verse';

  @override
  String get lessonPassageTitle => 'Scene text';

  @override
  String get lessonPractice => 'Practice';

  @override
  String lessonQuestionProgress(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get lessonVerseFallback => 'Verse';

  @override
  String get liturgyAdvent => 'Advent';

  @override
  String get liturgyAdventSubtitle => 'A season of waiting and preparing';

  @override
  String get liturgyChristmas => 'Christmas';

  @override
  String get liturgyChristmasSubtitle => 'The Word became flesh';

  @override
  String get liturgyEaster => 'Easter';

  @override
  String get liturgyEasterSubtitle => 'Christ is risen';

  @override
  String get liturgyHolyWeek => 'Holy Week';

  @override
  String get liturgyHolyWeekSubtitle =>
      'From the cross to awaiting the resurrection';

  @override
  String get liturgyLent => 'Lent';

  @override
  String get liturgyLentSubtitle => 'Desert, fasting and return';

  @override
  String get liturgyOrdinary => 'Ordinary Time';

  @override
  String get liturgyOrdinarySubtitle => 'Growing in the Word, day by day';

  @override
  String get liturgyPentecost => 'Pentecost';

  @override
  String get liturgyPentecostSubtitle => 'The Spirit is poured out';

  @override
  String liturgyQuestSubtitle(String ref) {
    return 'Read a chapter — focus: $ref';
  }

  @override
  String liturgyQuestTitle(String season) {
    return '$season season';
  }

  @override
  String get loginAppleError => 'Apple sign-in failed';

  @override
  String get loginBody =>
      'Your account keeps your steps, streak and scenes — so nothing is lost between devices.';

  @override
  String get loginEntering => 'Signing in…';

  @override
  String get loginGoogleError => 'Google sign-in failed';

  @override
  String get loginHydrateError =>
      'Couldn\'t load your progress. Check your connection and try again.';

  @override
  String get loginLoadingBody => 'Loading your steps, streak and scenes…';

  @override
  String get loginReconnect => 'Try reconnecting';

  @override
  String get loginRequired => 'You need to sign in to use Stway.';

  @override
  String get loginTitle => 'Sign in to continue';

  @override
  String get loginWithApple => 'Continue with Apple';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get mascotAllClear => 'All clear. Come back tomorrow to continue.';

  @override
  String get mascotBossHigh =>
      'The final challenge is behind you. Follow the map.';

  @override
  String get mascotBossLow =>
      'Crossing done. Worth reinforcing what still shook.';

  @override
  String get mascotCaravanDetailLead =>
      'Hold 1st until Sunday and you advance caravans.';

  @override
  String get mascotCaravanDetailOut =>
      'Every scene moves the caravan. Keep going this week.';

  @override
  String mascotCaravanDetailZone(int rank) {
    return '#$rank now · the top advance on Sunday.';
  }

  @override
  String get mascotCaravanLead => 'You lead the caravan';

  @override
  String mascotCaravanRank(int rank) {
    return '#$rank in the caravan';
  }

  @override
  String get mascotCaravanZone => 'Promotion zone';

  @override
  String get mascotFailedDetail =>
      'The lamps ran out before the end. The scene waits for you — again, slowly.';

  @override
  String get mascotFailedKicker => 'Lights out';

  @override
  String get mascotGood => 'Good scene. The trail waits for you tomorrow.';

  @override
  String get mascotHeadlineBoss => 'Crossing complete';

  @override
  String get mascotHeadlinePerfect => 'All correct · step bonus';

  @override
  String get mascotHeadlineReplay => 'You returned to the text';

  @override
  String get mascotHeadlineScene => 'Scene complete';

  @override
  String get mascotKickerBoss => 'Final crossing';

  @override
  String get mascotKickerPerfect => 'Clean scene';

  @override
  String get mascotKickerReplay => 'Review';

  @override
  String get mascotKickerScene => 'One more scene';

  @override
  String get mascotPerfect => 'No lamps lost. That stays.';

  @override
  String get mascotReinforce =>
      'Scene done. Reinforce what was missing — memory thanks you.';

  @override
  String get mascotReplay =>
      'Returning to the text strengthens what you already walked.';

  @override
  String get medalAccuracyEliteHint =>
      'Kept 95%+ accuracy over 150 questions or more';

  @override
  String get medalAccuracyEliteTitle => 'Sharp aim';

  @override
  String get medalAdventDoorTitle => 'Open door';

  @override
  String get medalAdventHalfHint => 'Walk half the days of Advent';

  @override
  String get medalAdventHalfTitle => 'Halfway there';

  @override
  String get medalAdventLivedTitle => 'Season lived';

  @override
  String get medalAdventSubtitle => 'Waiting and preparation';

  @override
  String get medalAdventTitle => 'Advent';

  @override
  String medalAdventTrackSubtitle(String year) {
    return 'Waiting and preparation — $year';
  }

  @override
  String medalAdventVaultTitle(String year) {
    return 'Advent $year';
  }

  @override
  String get medalAdventWeekHint => 'A seven-day streak in Advent';

  @override
  String get medalAdventWeekTitle => 'Week of waiting';

  @override
  String get medalAllLevelsDone => 'All levels complete.';

  @override
  String get medalBibleBeforeHint =>
      'Read a chapter the same day, before the scene';

  @override
  String get medalBibleBeforeTitle => 'Word first';

  @override
  String get medalComebackHint =>
      'The door was open — you came back after 21 days or more';

  @override
  String get medalComebackTitle => 'Steady return';

  @override
  String get medalFormationPerfect10Title => 'Steady eye';

  @override
  String get medalFormationPerfect1Title => 'Clear scene';

  @override
  String get medalFormationPerfect25Hint => '25 scenes with 100% accuracy';

  @override
  String get medalFormationPerfect25Title => 'Spot on';

  @override
  String get medalFounderHint => 'Joined the app during the testing period';

  @override
  String get medalFounderTitle => 'Pioneer';

  @override
  String get medalHeadlineDiscovery => 'Discovery';

  @override
  String get medalHeadlineJourney => 'Journey medal';

  @override
  String get medalHeadlineLevelUp => 'Level up';

  @override
  String get medalHeadlineLit => 'Medal lit';

  @override
  String get medalHeadlineLocked => 'To unlock';

  @override
  String get medalHeadlineNew => 'New medal';

  @override
  String get medalHeadlineRare => 'Rare';

  @override
  String get medalHeadlineTrail => 'Trail medal';

  @override
  String medalHintAdventDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Walk $count days in Advent',
      one: 'Walk 1 day in Advent',
    );
    return '$_temp0';
  }

  @override
  String medalHintLentDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Walk $count days in Lent',
      one: 'Walk 1 day in Lent',
    );
    return '$_temp0';
  }

  @override
  String medalHintMemorizeVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Master $count verses in memorization',
      one: 'Master 1 verse in memorization',
    );
    return '$_temp0';
  }

  @override
  String medalHintPerfectScenes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Finish $count scenes with 100% accuracy',
      one: 'Finish a scene with 100% accuracy',
    );
    return '$_temp0';
  }

  @override
  String medalHintReadChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Read $count chapters',
      one: 'Read 1 chapter in the Bible',
    );
    return '$_temp0';
  }

  @override
  String medalHintShareVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Share $count verses',
      one: 'Share 1 verse',
    );
    return '$_temp0';
  }

  @override
  String medalHintStreak(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Keep a $count-day streak',
      one: 'Keep a 1-day streak',
    );
    return '$_temp0';
  }

  @override
  String medalHowToEarn(String hint) {
    return 'How to earn: $hint';
  }

  @override
  String get medalJourneyVaultSubtitle =>
      'The spark lights up; the medal stays';

  @override
  String get medalJourneyVaultTitle => 'Journey vault';

  @override
  String get medalLeaderHint => 'Ranked 1st overall for a day';

  @override
  String get medalLeaderTitle => 'Caravan leader';

  @override
  String get medalLentFirstStepTitle => 'First step in the desert';

  @override
  String get medalLentHalfHint => 'Walk half the days of Lent';

  @override
  String get medalLentHalfTitle => 'Middle of the desert';

  @override
  String get medalLentLivedTitle => 'Lent lived';

  @override
  String get medalLentSubtitle => 'Desert, fasting and return';

  @override
  String get medalLentTitle => 'Lent';

  @override
  String medalLentTrackSubtitle(String year) {
    return 'Desert, fasting and return — $year';
  }

  @override
  String medalLentVaultTitle(String year) {
    return 'Lent $year';
  }

  @override
  String get medalMemoryVerse15Title => 'Word kept';

  @override
  String get medalMemoryVerse1Title => 'First verse';

  @override
  String get medalMemoryVerse50Title => 'Living Scripture';

  @override
  String get medalMysteryHint =>
      'They reveal themselves along the way — no hints in the vault.';

  @override
  String medalMysteryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count discoveries',
      one: 'One discovery',
    );
    return '$_temp0';
  }

  @override
  String medalNowTier(String tier) {
    return 'Now at $tier';
  }

  @override
  String get medalPathStreak14Title => 'Two weeks';

  @override
  String get medalPathStreak30Title => 'Steady month';

  @override
  String get medalPathStreak3Title => 'Three steady days';

  @override
  String get medalPerfectBossHint => 'Won a final challenge with 100% accuracy';

  @override
  String get medalPerfectBossTitle => 'Flawless test';

  @override
  String medalProximityAction(int count, String units, String track) {
    return '$units to go · $track';
  }

  @override
  String medalProximityLeft(
    int count,
    String units,
    String tier,
    String track,
  ) {
    return '$units left for $tier in $track';
  }

  @override
  String medalProximityRemaining(int count, String units) {
    return '$units to go';
  }

  @override
  String medalProximityShortLeft(int count, String tier) {
    return '$count left for $tier';
  }

  @override
  String medalProximityShortToward(int current, int target, String tier) {
    return '$current/$target toward $tier';
  }

  @override
  String medalProximityToward(String units, String tier, String track) {
    return '$units toward $tier in $track';
  }

  @override
  String medalRareLeft(int count, String unit, String title) {
    return '$count $unit left for “$title”';
  }

  @override
  String medalRareShortLeft(int count, String title) {
    return '$count left for “$title”';
  }

  @override
  String get medalRareVaultSubtitle =>
      'Exceptional medals — they only appear once you earn them';

  @override
  String get medalRareVaultTitle => 'Rare';

  @override
  String get medalReflectionDeepHint =>
      'Wrote 40 reflections in the scene journal';

  @override
  String get medalReflectionDeepTitle => 'Deep journal';

  @override
  String get medalSeasonFirstWeekTitle => 'First week';

  @override
  String get medalTierAurora => 'Ultra rare';

  @override
  String get medalTierBronze => 'Bronze';

  @override
  String get medalTierDiamond => 'Diamond';

  @override
  String get medalTierGold => 'Gold';

  @override
  String get medalTierIron => 'Iron';

  @override
  String get medalTierMirra => 'Myrrh';

  @override
  String get medalTierPlatinum => 'Platinum';

  @override
  String get medalTierSilver => 'Silver';

  @override
  String get medalTrackComplete => 'Complete';

  @override
  String get medalTrackFormationSubtitle => 'Accuracy and mastery in scenes';

  @override
  String get medalTrackFormationTitle => 'Formation';

  @override
  String get medalTrackMemorySubtitle => 'Verses kept in your heart';

  @override
  String get medalTrackMemoryTitle => 'Memory';

  @override
  String get medalTrackPathSubtitle => 'Streak on your journey';

  @override
  String get medalTrackPathTitle => 'Path';

  @override
  String get medalTrackUnlit => 'Not lit yet';

  @override
  String get medalTrackWitnessSubtitle => 'Sharing the Word';

  @override
  String get medalTrackWitnessTitle => 'Witness';

  @override
  String get medalTrackWordSubtitle => 'Bible reading on your journey';

  @override
  String get medalTrackWordTitle => 'Word';

  @override
  String medalTrailFinalModeHint(String mode) {
    return 'Finish the trail in $mode mode';
  }

  @override
  String get medalTrailFirstSceneHint => 'Finish 1 scene on this trail';

  @override
  String get medalTrailFirstSceneTitle => 'First scene';

  @override
  String get medalTrailFlawlessHint =>
      'Finished a whole trail with 100% in every scene';

  @override
  String get medalTrailFlawlessTitle => 'Flawless trail';

  @override
  String medalTrailModeHint(String mode) {
    return 'Finish $mode mode';
  }

  @override
  String get medalTrailTrackSubtitle => 'Progress on this trail';

  @override
  String medalUnitAdventDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days in Advent',
      one: '1 day in Advent',
    );
    return '$_temp0';
  }

  @override
  String medalUnitChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters',
      one: '1 chapter',
    );
    return '$_temp0';
  }

  @override
  String medalUnitLentDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days in Lent',
      one: '1 day in Lent',
    );
    return '$_temp0';
  }

  @override
  String medalUnitMemorizedVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count memorized verses',
      one: '1 memorized verse',
    );
    return '$_temp0';
  }

  @override
  String medalUnitPerfectScenes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perfect scenes',
      one: '1 perfect scene',
    );
    return '$_temp0';
  }

  @override
  String medalUnitSharedVerses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shared verses',
      one: '1 shared verse',
    );
    return '$_temp0';
  }

  @override
  String medalUnitStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count streak days',
      one: '1 streak day',
    );
    return '$_temp0';
  }

  @override
  String medalVaultAllMedals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $count medals',
      one: '1 medal',
    );
    return '$_temp0';
  }

  @override
  String get medalVaultCompleteBody =>
      'You lit every medal in this vault. Keep walking in the Word.';

  @override
  String get medalVaultCompleteLabel => 'Vault complete';

  @override
  String get medalVaultDiscoveries => 'Discoveries';

  @override
  String get medalVaultEmptyHint =>
      'Every scene you finish brings you closer to a medal. The first one is near.';

  @override
  String get medalVaultMysteryEmpty =>
      'They reveal themselves along the way — no hints.';

  @override
  String get medalVaultMysteryMore => 'Others reveal themselves along the way.';

  @override
  String medalVaultNextSemantics(String message) {
    return 'Next medal: $message';
  }

  @override
  String get medalVaultNextTitle => 'Next medal';

  @override
  String medalVaultRemaining(int count, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count $unit left',
      one: '1 $unit left',
    );
    return '$_temp0';
  }

  @override
  String get medalVaultSeason => 'Season';

  @override
  String get medalVaultTabJourney => 'Journey';

  @override
  String get medalVaultTabTrails => 'Trails';

  @override
  String get medalVaultTitle => 'Medals';

  @override
  String get medalWalkingInLightHint =>
      'Kept 85%+ accuracy (min. 50 questions)';

  @override
  String get medalWalkingInLightTitle => 'Walking in the light';

  @override
  String get medalWitnessShare10Title => 'Sower';

  @override
  String get medalWitnessShare1Title => 'Word carried';

  @override
  String get medalWitnessShare50Title => 'Voice in the caravan';

  @override
  String get medalWordChapters100Title => 'Steady reader';

  @override
  String get medalWordChapters1Title => 'First Word';

  @override
  String get medalWordChapters25Title => 'Attentive reader';

  @override
  String get memoryCard => 'Card';

  @override
  String memoryDoneSummary(int known, int learning) {
    return '$known solid · $learning in progress';
  }

  @override
  String get memoryDoneTitle => 'Session complete';

  @override
  String get memoryKnown => 'I know it';

  @override
  String get memoryNotYet => 'Not yet';

  @override
  String get memoryReveal => 'Reveal';

  @override
  String get memorySubtitle => 'Commit it to memory';

  @override
  String get memoryTitle => 'Memorize';

  @override
  String get modeBadgeCleared => 'Complete';

  @override
  String get modeBadgeCurrent => 'Current';

  @override
  String get modeBadgeHere => 'You are here';

  @override
  String get modeBadgeInProgress => 'In progress';

  @override
  String get modeBadgeLocked => 'Locked';

  @override
  String get modeBadgeReview => 'Review';

  @override
  String get modeBannerHint => 'Tap to change mode';

  @override
  String modeBannerSemantics(String name, String tagline) {
    return 'Study mode: $name. $tagline.';
  }

  @override
  String get modeCaminhadaBlurb =>
      'Connect the facts: causes, context, and the thread of the story.';

  @override
  String get modeCaminhadaLabel => 'Understanding';

  @override
  String get modeCaminhadaSkill1 => 'Relate';

  @override
  String get modeCaminhadaSkill2 => 'Compare';

  @override
  String get modeCaminhadaSkill3 => 'Connect';

  @override
  String get modeCaminhadaTagline => 'What the text conveys';

  @override
  String get modeCaptionCleared => 'complete';

  @override
  String get modeCaptionCurrent => 'current';

  @override
  String get modeCaptionLocked => 'locked';

  @override
  String modeCleared(String name) {
    return '$name complete';
  }

  @override
  String get modeClearedReview => 'Complete · review anytime';

  @override
  String modeCtaContinue(String name) {
    return 'Continue in $name';
  }

  @override
  String modeCtaReview(String name) {
    return 'Review $name';
  }

  @override
  String modeCtaStart(String name) {
    return 'Start in $name';
  }

  @override
  String modeCtaStudy(String name) {
    return 'Study in $name';
  }

  @override
  String modeCurrent(String name) {
    return '$name, current';
  }

  @override
  String modeLockHint(String name) {
    return 'Finish $name to unlock';
  }

  @override
  String modeLocked(String name) {
    return '$name locked';
  }

  @override
  String modeNamed(String name) {
    return '$name mode';
  }

  @override
  String modeOrdinal(String ordinal) {
    return 'Mode $ordinal';
  }

  @override
  String modeOrdinalBadge(String ordinal, String badge) {
    return 'Mode $ordinal · $badge';
  }

  @override
  String get modePickerTitle => 'How do you want\nto study?';

  @override
  String get modePickerTopBar => 'Before you set out';

  @override
  String modePrevAlmostDone(String name) {
    return '$name almost complete';
  }

  @override
  String get modeProfundezasBlurb =>
      'Look for the meaning: what the text reveals about God and for you.';

  @override
  String get modeProfundezasLabel => 'Interpretation';

  @override
  String get modeProfundezasSkill1 => 'Interpret';

  @override
  String get modeProfundezasSkill2 => 'Support';

  @override
  String get modeProfundezasSkill3 => 'Apply';

  @override
  String get modeProfundezasTagline => 'What the text means';

  @override
  String get modeRuleFootnote =>
      'Three readings of the same text · finish a mode to unlock the next';

  @override
  String modeScenesLeft(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count $name scenes left',
      one: '1 $name scene left',
    );
    return '$_temp0';
  }

  @override
  String modeScenesProgress(int done, int total) {
    return '$done of $total scenes';
  }

  @override
  String get modeSementeBlurb =>
      'Notice the words, the facts, and the order they happen in.';

  @override
  String get modeSementeLabel => 'Observation';

  @override
  String get modeSementeSkill1 => 'Recognize';

  @override
  String get modeSementeSkill2 => 'Identify';

  @override
  String get modeSementeSkill3 => 'Sequence';

  @override
  String get modeSementeTagline => 'What the text says';

  @override
  String modeSessionFootnote(String mode) {
    return 'This session only · when you close the app, it goes back to $mode';
  }

  @override
  String get modeSheetEyebrow => 'Study mode';

  @override
  String get modeSheetTitle => 'How do you want to study?';

  @override
  String get modeStartFirstScene => 'Start with the first scene';

  @override
  String get modeSwitch => 'Change';

  @override
  String get morphAbsolute => 'absolute';

  @override
  String get morphAdjective => 'adjective';

  @override
  String get morphAdverb => 'adverb';

  @override
  String get morphAdverbConjAc => 'adverb/conj. (ac)';

  @override
  String get morphArticle => 'article';

  @override
  String get morphBoth => 'both';

  @override
  String get morphCaseAccusative => 'accusative';

  @override
  String get morphCaseDative => 'dative';

  @override
  String get morphCaseGenitive => 'genitive';

  @override
  String get morphCaseNominative => 'nominative';

  @override
  String get morphCaseVocative => 'vocative';

  @override
  String get morphConjConsecutive => 'consecutive conjunction';

  @override
  String get morphConjunction => 'conjunction';

  @override
  String get morphConstruct => 'construct';

  @override
  String get morphDemonstrativeArticle => 'demonstrative article';

  @override
  String get morphDetermined => 'determined';

  @override
  String get morphDivineName => 'divine name';

  @override
  String get morphDual => 'dual';

  @override
  String get morphExtraGentilic => 'gentilic';

  @override
  String get morphExtraLocal => 'local';

  @override
  String get morphExtraProper => 'proper name';

  @override
  String get morphExtraTitle => 'title';

  @override
  String get morphFem => 'fem.';

  @override
  String get morphGenderFeminine => 'feminine';

  @override
  String get morphGenderMasculine => 'masculine';

  @override
  String get morphInConstruct => 'in construct';

  @override
  String get morphInterjection => 'interjection';

  @override
  String get morphLangAramaic => 'Aramaic';

  @override
  String get morphLangGreek => 'Greek';

  @override
  String get morphLangHebrew => 'Hebrew';

  @override
  String get morphMasc => 'masc.';

  @override
  String get morphMoodImperative => 'imperative';

  @override
  String get morphMoodIndicative => 'indicative';

  @override
  String get morphMoodInfinitive => 'infinitive';

  @override
  String get morphMoodOptative => 'optative';

  @override
  String get morphMoodParticiple => 'participle';

  @override
  String get morphMoodSubjunctive => 'subjunctive';

  @override
  String get morphNegativeParticle => 'negative particle';

  @override
  String get morphNeuter => 'neuter';

  @override
  String get morphNoun => 'noun';

  @override
  String get morphNounCommon => 'common';

  @override
  String get morphNounGentilic => 'gentilic';

  @override
  String get morphNounPlace => 'place';

  @override
  String get morphNounProper => 'proper';

  @override
  String get morphNounTitle => 'title';

  @override
  String get morphNumberDual => 'dual';

  @override
  String get morphNumberPlural => 'plural';

  @override
  String get morphNumberSingular => 'singular';

  @override
  String get morphObjectMarker => 'object marker';

  @override
  String get morphParticle => 'particle';

  @override
  String get morphParticleInterrogative => 'interrogative particle';

  @override
  String get morphPerson1 => '1st person';

  @override
  String get morphPerson1p => '1st pl.';

  @override
  String get morphPerson1s => '1st sg.';

  @override
  String get morphPerson2 => '2nd person';

  @override
  String get morphPerson2p => '2nd pl.';

  @override
  String get morphPerson2s => '2nd sg.';

  @override
  String get morphPerson3 => '3rd person';

  @override
  String get morphPerson3p => '3rd pl.';

  @override
  String get morphPerson3s => '3rd sg.';

  @override
  String get morphPhraseConj => 'Conjunction.';

  @override
  String morphPhraseConjGloss(String gloss) {
    return 'Conjunction — $gloss.';
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
    return '$person $number';
  }

  @override
  String get morphPhrasePrep => 'Preposition.';

  @override
  String morphPhrasePrepGloss(String gloss) {
    return 'Preposition — $gloss.';
  }

  @override
  String get morphPhrasePrepSuffix => 'Preposition with pronominal suffix.';

  @override
  String morphPhrasePrepSuffixGloss(String gloss) {
    return 'Preposition with suffix — $gloss.';
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
  String get morphPrep => 'preposition';

  @override
  String get morphPronominalSuffix => 'pronominal suffix';

  @override
  String get morphPronounDemonstrative => 'demonstrative pronoun';

  @override
  String get morphPronounPersonal => 'personal pronoun';

  @override
  String get morphPronounPossessive => 'possessive pronoun';

  @override
  String get morphPronounReciprocal => 'reciprocal/correlative pronoun';

  @override
  String get morphPronounReflexive => 'reflexive pronoun';

  @override
  String get morphPronounRelative => 'relative pronoun';

  @override
  String get morphRelativeParticle => 'relative particle';

  @override
  String get morphSing => 'sg.';

  @override
  String get morphStemHifil => 'hiphil';

  @override
  String get morphStemHitpael => 'hithpael';

  @override
  String get morphStemHofal => 'hophal';

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
  String get morphSuffix => 'suffix';

  @override
  String get morphSuffixDirectional => 'directional';

  @override
  String get morphSuffixNunParagogic => 'paragogic nun';

  @override
  String get morphSuffixParagogic => 'paragogic';

  @override
  String get morphSuffixPronominal => 'pronominal';

  @override
  String get morphTenseAorist => 'aorist';

  @override
  String get morphTenseCohortative => 'cohortative';

  @override
  String get morphTenseFuture => 'future';

  @override
  String get morphTenseImperative => 'imperative';

  @override
  String get morphTenseImperfectGk => 'imperfect';

  @override
  String get morphTenseImperfectHeb => 'imperfect';

  @override
  String get morphTenseInfAbsolute => 'infinitive absolute';

  @override
  String get morphTenseInfConstruct => 'infinitive construct';

  @override
  String get morphTenseJussive => 'jussive';

  @override
  String get morphTenseParticiple => 'participle';

  @override
  String get morphTenseParticiplePassive => 'passive participle';

  @override
  String get morphTensePerfect => 'perfect';

  @override
  String get morphTensePluperfect => 'pluperfect';

  @override
  String get morphTensePresent => 'present';

  @override
  String get morphTenseSecondAorist => '2nd aorist/future';

  @override
  String get morphTenseUndefined => 'undefined tense';

  @override
  String get morphTenseWayyiqtol => 'sequential imperfect (wayyiqtol)';

  @override
  String get morphTenseWeqatal => 'sequential perfect (weqatal)';

  @override
  String get morphVerb => 'verb';

  @override
  String get morphVoiceActive => 'active';

  @override
  String get morphVoiceImpersonal => 'impersonal';

  @override
  String get morphVoiceMidPassDeponent => 'middle-passive deponent';

  @override
  String get morphVoiceMiddle => 'middle';

  @override
  String get morphVoiceMiddleDeponent => 'middle deponent';

  @override
  String get morphVoiceMiddlePassive => 'middle-passive';

  @override
  String get morphVoicePassive => 'passive';

  @override
  String get morphVoicePassiveDeponent => 'passive deponent';

  @override
  String get navBible => 'Bible';

  @override
  String navTabWithNews(String tab) {
    return '$tab, has updates';
  }

  @override
  String get navTogether => 'Together';

  @override
  String get navTrails => 'Trails';

  @override
  String get notifChannelDesc =>
      'Daily goal, scenes, practice, memorization and favorites';

  @override
  String get notifChannelName => 'Stway reminders';

  @override
  String get notifContinueTitle => 'Continue where you left off';

  @override
  String get notifDailyTitle => 'For today';

  @override
  String notifFavoritesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count favorites. Reread one and train your memory.',
      one: 'You saved a verse. Want to revisit it now?',
    );
    return '$_temp0';
  }

  @override
  String get notifFavoritesTitle => 'Your favorites';

  @override
  String get notifGoalDoneBody => 'Goal done. The streak continues tomorrow.';

  @override
  String notifGoalLeftBody(int left) {
    String _temp0 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left scenes left',
      one: '1 scene left',
    );
    return '$_temp0 to finish today\'s goal.';
  }

  @override
  String notifMemoryBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verses in the deck. Memorizing reinforces learning.',
      one: 'A verse is waiting for you. Two minutes is enough.',
    );
    return '$_temp0';
  }

  @override
  String notifMistakesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You have $count mistakes to reinforce. Quick practice, steady mind.',
      one: 'You have 1 mistake to reinforce. Practice now and lock it in.',
    );
    return '$_temp0';
  }

  @override
  String get notifPracticeTitle => 'Time to practice';

  @override
  String notifQuestsLeftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count daily gestures still left.',
      one: '1 gesture left. One more and the day is done.',
    );
    return '$_temp0';
  }

  @override
  String get notifResumeTitle => 'Time to pick it up again';

  @override
  String notifReturningBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$name, it\'s been $_temp0 without studying. One scene restarts the streak.';
  }

  @override
  String get notifSceneWaitingBody =>
      'One scene a day. The streak continues tomorrow.';

  @override
  String get notifSceneWaitingTitle => 'Your scene is waiting';

  @override
  String notifSceneWaitsBody(String name, String title) {
    return '$name, $title is waiting.';
  }

  @override
  String get notifSeeYouTomorrowTitle => 'See you tomorrow';

  @override
  String get notifSignature => 'The Pilgrim';

  @override
  String notifStreakLeftBody(String name, int streak, int left) {
    String _temp0 = intl.Intl.pluralLogic(
      streak,
      locale: localeName,
      other: '$streak days',
      one: '1 day',
    );
    String _temp1 = intl.Intl.pluralLogic(
      left,
      locale: localeName,
      other: '$left scenes left',
      one: '1 scene left',
    );
    return '$name, you\'ve been walking for $_temp0. $_temp1 to keep up.';
  }

  @override
  String get notifTodayGoalTitle => 'Today\'s goal';

  @override
  String get notifTomorrowTitle => 'Tomorrow';

  @override
  String get notifTrialEndingBody =>
      'Manage your Pilgrim+ subscription in settings if you don\'t want to continue.';

  @override
  String get notifTrialEndingTitle => 'Your free trial ends tomorrow';

  @override
  String notifWeeklyLeftBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weekly steps still left. The week is still yours.',
      one: '1 weekly step left. Close the cycle calmly.',
    );
    return '$_temp0';
  }

  @override
  String get notifWeeklyStepsBody => 'There\'s still time to finish the week.';

  @override
  String get notifWeeklyStepsTitle => 'Weekly steps';

  @override
  String get nudgeAlreadySubtitle =>
      'You already waved today. Send it on WhatsApp too, if you like.';

  @override
  String get nudgeCardCta => 'Come back and walk with me on Stway';

  @override
  String nudgeCardDaysAway(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days without studying',
      one: '1 day without studying',
    );
    return '$_temp0';
  }

  @override
  String get nudgeCardHeadline => 'Missed you today';

  @override
  String get nudgeCardWaiting => 'Waiting for you';

  @override
  String nudgeCardWalked(String name) {
    return '$name already walked';
  }

  @override
  String get nudgeCompanionFallback => 'Companion';

  @override
  String get nudgeDefaultMessage => 'I\'m waiting for you on the trail';

  @override
  String nudgeInAppSubtitle(String name) {
    return 'A wave in the app — $name sees it when they open Stway.';
  }

  @override
  String get nudgeSendFailed => 'Couldn\'t send the wave.';

  @override
  String nudgeSent(String name) {
    return 'Wave sent. $name will see it when they open Stway.';
  }

  @override
  String get nudgeShareSubject => 'Shall we walk together?';

  @override
  String get nudgeSignInSubtitle =>
      'Sign in to wave in the app, or send it on WhatsApp.';

  @override
  String nudgeTitle(String name) {
    return 'Wave to $name';
  }

  @override
  String get offlineBody =>
      'The first time you open it, Stway downloads the curriculum from the cloud. It needs internet once — then it stays on your device.';

  @override
  String get offlineDownloadFailed =>
      'Couldn\'t download the scenes. Try again in a moment.';

  @override
  String get offlineDownloading => 'Downloading…';

  @override
  String get offlineNoInternet =>
      'No internet right now. Turn on Wi‑Fi or mobile data and try again.';

  @override
  String get offlineTitle => 'The scenes haven\'t arrived yet';

  @override
  String get onboardingAppearanceBody =>
      'It applies to the whole app.\nYou can change it later in Settings.';

  @override
  String onboardingAppearanceSemantics(String theme) {
    return 'Appearance $theme';
  }

  @override
  String get onboardingAppearanceTitle => 'Choose your appearance.';

  @override
  String get onboardingCommitmentLabel => 'My commitment';

  @override
  String onboardingDayOneOf(int goal) {
    return 'Today  ·  day 1 of $goal';
  }

  @override
  String get onboardingDefaultPromise =>
      'the first scene\nis already on the path.';

  @override
  String get onboardingEveryDay => 'Every day.';

  @override
  String get onboardingFirstSceneMeta =>
      'Read · answer · understand  ·  ~3 min';

  @override
  String get onboardingFirstSceneTitle => 'Who created the world?';

  @override
  String get onboardingFiveLamps => '5 lamps';

  @override
  String get onboardingHabitBody =>
      'Knowing God doesn\'t ask for a marathon.\nIt asks that you come back, every day.';

  @override
  String get onboardingHoldToCommit => 'Hold to commit';

  @override
  String get onboardingHolding => 'Committing…';

  @override
  String get onboardingIntentBody =>
      'Each scene: read, answer, understand.\nYour reason opens the path.';

  @override
  String get onboardingIntentHabitCaption => 'every day';

  @override
  String get onboardingIntentHabitPromise => 'the streak\nstarts today.';

  @override
  String get onboardingIntentHabitTitle => 'Build a streak';

  @override
  String get onboardingIntentKnowCaption => 'up close';

  @override
  String get onboardingIntentKnowPromise =>
      'knowing God\nstarts with one scene.';

  @override
  String get onboardingIntentKnowTitle => 'Know God';

  @override
  String get onboardingIntentPeaceCaption => 'a breath';

  @override
  String get onboardingIntentPeacePromise =>
      'the peace of the day\nstarts here.';

  @override
  String get onboardingIntentPeaceTitle => 'Peace in your day';

  @override
  String get onboardingIntentQuestion => 'What brings you here?';

  @override
  String get onboardingIntentUnderstandCaption => 'for real';

  @override
  String get onboardingIntentUnderstandPromise =>
      'understanding the Bible\nstarts at the beginning.';

  @override
  String get onboardingIntentUnderstandTitle => 'Understand the Bible';

  @override
  String get onboardingKickerAppearance => 'III   ·   Appearance';

  @override
  String get onboardingKickerGoal => 'I   ·   The goal';

  @override
  String get onboardingKickerIntent => 'II   ·   Your reason';

  @override
  String get onboardingKickerJourney => 'V   ·   The journey';

  @override
  String get onboardingKickerTomorrow => 'IV   ·   Tomorrow';

  @override
  String get onboardingMinutes => 'Minutes';

  @override
  String get onboardingNameHint => 'your name';

  @override
  String get onboardingNamePrompt => 'What should we call you';

  @override
  String get onboardingOpening => 'Opening…';

  @override
  String onboardingPaceCaption(int scenes, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      scenes,
      locale: localeName,
      other: '$scenes scenes a day · ~$minutes min',
      one: '1 scene a day · ~$minutes min',
    );
    return '$_temp0';
  }

  @override
  String get onboardingRemindAtLabel => 'We\'ll remind you at';

  @override
  String get onboardingReminderMorning => 'A morning reminder';

  @override
  String get onboardingReminderNight => 'An evening reminder';

  @override
  String get onboardingReminderNoon => 'A midday reminder';

  @override
  String onboardingStreakDays(int count) {
    return '$count days of streak';
  }

  @override
  String get onboardingStreakMonth => 'A full month';

  @override
  String get onboardingStreakTwoWeeks => 'Two weeks of streak';

  @override
  String get onboardingStreakWeek => 'One week of streak';

  @override
  String get onboardingTomorrowBody =>
      'The habit is born when you come back.\nCommit with yourself to a start.';

  @override
  String get onboardingTomorrowWord => 'Tomorrow';

  @override
  String get onboardingYourPace => 'Your pace';

  @override
  String get paywallAlreadyPlus => 'You\'re already Pilgrim+';

  @override
  String get paywallHeadline => 'Go further on the trail';

  @override
  String get paywallPerkSeason =>
      'The season (Advent / Lent) — after the 3 free days';

  @override
  String get paywallPerkWeeklyReview =>
      'Weekly review: the 7 “Today:” notes + 3 questions';

  @override
  String get paywallPitch =>
      'Direct support for the project, with a few extras.';

  @override
  String paywallPriceAnnual(String price) {
    return '$price per year';
  }

  @override
  String paywallPriceLifetime(String price) {
    return '$price one-time payment';
  }

  @override
  String paywallPriceMonthly(String price) {
    return '$price per month';
  }

  @override
  String paywallPriceMonths(int months, String price) {
    return '$price per $months months';
  }

  @override
  String paywallPriceWeekly(String price) {
    return '$price per week';
  }

  @override
  String get paywallPurchaseFailed => 'Couldn\'t complete the purchase.';

  @override
  String get paywallRestore => 'Restore purchase';

  @override
  String get paywallRestoreFailed => 'Couldn\'t restore the purchase.';

  @override
  String get paywallThanks => 'Thank you for supporting Stway.';

  @override
  String get paywallTitle => 'Pilgrim+';

  @override
  String get paywallUnavailable =>
      'Subscription isn\'t available in this version yet.';

  @override
  String get pilgrimAccuracyForming => 'Still growing';

  @override
  String get pilgrimAccuracyGood => 'Good understanding in the scenes';

  @override
  String get pilgrimAccuracySharp => 'A sharp reader of Scripture';

  @override
  String get pilgrimAccuracySteady => 'Walking steadily';

  @override
  String get pilgrimAccuracyTitle => 'Accuracy';

  @override
  String pilgrimChaptersBooks(int chapters, int books) {
    String _temp0 = intl.Intl.pluralLogic(
      chapters,
      locale: localeName,
      other: '$chapters chapters',
      one: '1 chapter',
    );
    String _temp1 = intl.Intl.pluralLogic(
      books,
      locale: localeName,
      other: '$books books',
      one: '1 book',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String pilgrimChaptersWordMedal(int chapters) {
    String _temp0 = intl.Intl.pluralLogic(
      chapters,
      locale: localeName,
      other: '$chapters chapters',
      one: '1 chapter',
    );
    return '$_temp0 · Word medal';
  }

  @override
  String get pilgrimCollections => 'Collections';

  @override
  String pilgrimCompletedOn(String date) {
    return 'Completed on $date';
  }

  @override
  String pilgrimCorrectOf(int correct, int total) {
    return '$correct of $total';
  }

  @override
  String get pilgrimCorrectOnJourney => 'questions right on the journey';

  @override
  String pilgrimCorrectRatio(int correct, int total) {
    return '$correct/$total right';
  }

  @override
  String get pilgrimFallbackName => 'Pilgrim';

  @override
  String pilgrimLastSeen(String when) {
    return 'Last seen · $when';
  }

  @override
  String get pilgrimLastStudyDay => 'Last study day';

  @override
  String get pilgrimLedOverall => 'Has led the overall ranking';

  @override
  String get pilgrimNoReadingYet => 'No reading logged yet';

  @override
  String get pilgrimNoTrailYet => 'No trail in progress yet.';

  @override
  String get pilgrimOnTheJourney => 'on the journey';

  @override
  String get pilgrimPrivacyBody =>
      'Tap the eye on each card to choose what the caravan sees.';

  @override
  String get pilgrimPrivacyTitle => 'Profile privacy';

  @override
  String get pilgrimPrivateBody =>
      'Chose not to share details with the caravan.';

  @override
  String get pilgrimPrivateTitle => 'Private profile';

  @override
  String pilgrimRank(int rank) {
    return '#$rank in the ranking';
  }

  @override
  String get pilgrimRankLeader => 'Ranking leader';

  @override
  String get pilgrimRankListed => 'In the ranking';

  @override
  String get pilgrimRankMonthly => 'Monthly ranking';

  @override
  String pilgrimRankOrdinal(int rank) {
    return '#$rank';
  }

  @override
  String get pilgrimRankPodium => 'On the podium';

  @override
  String get pilgrimRankRunnerUp => 'Runner-up';

  @override
  String get pilgrimRankWeekly => 'Caravan weekly ranking';

  @override
  String get pilgrimSceneFallback => 'Scene';

  @override
  String pilgrimScenesOf(int done, int total) {
    return '$done of $total scenes';
  }

  @override
  String get pilgrimScriptures => 'Scriptures';

  @override
  String get pilgrimSealsAndTrails => 'Seals and trails';

  @override
  String get pilgrimSeen => 'Seen';

  @override
  String get pilgrimStatScenes => 'Scenes';

  @override
  String get pilgrimStatSteps => 'Steps';

  @override
  String get pilgrimStreak => 'Streak';

  @override
  String get pilgrimStreakOngoing => 'Ongoing';

  @override
  String get pilgrimTrail => 'Trail';

  @override
  String pilgrimTrailsInProgress(int count) {
    return '$count in progress';
  }

  @override
  String get pilgrimWalked => 'Walked';

  @override
  String get pilgrimYourTrail => 'Your trail';

  @override
  String get pilgrimYourTrails => 'Your trails';

  @override
  String get planAdjustTime => 'Adjust time';

  @override
  String get planAllRead => 'All read';

  @override
  String get planAlreadyRead => 'Already read';

  @override
  String planApproxDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~$count days',
      one: '~1 day',
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
      other: '~$count months',
      one: '~1 month',
    );
    return '$_temp0';
  }

  @override
  String get planAtYourPace => 'At your pace';

  @override
  String get planBibleFinished => 'You finished the Bible on this plan.';

  @override
  String get planCardDoneToday => 'Today\'s reading done';

  @override
  String get planCardIdle => 'Canonical or chronological, on your time';

  @override
  String planCardToday(int minutes, String order) {
    return '$minutes min today · $order';
  }

  @override
  String planChaptersSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chapters skipped',
      one: '1 chapter skipped',
    );
    return '$_temp0';
  }

  @override
  String get planCreate => 'Create a plan';

  @override
  String planDayDoneToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Today\'s reading done · $count chapters',
      one: 'Today\'s reading done · 1 chapter',
    );
    return '$_temp0';
  }

  @override
  String get planDone => 'Done';

  @override
  String get planEndConfirmAction => 'End';

  @override
  String get planEndConfirmBody =>
      'Your plan progress will be reset. Chapters already marked as read in the Bible stay marked.';

  @override
  String get planEndConfirmTitle => 'End plan?';

  @override
  String get planEndCta => 'End plan';

  @override
  String get planEstimate => 'Estimate';

  @override
  String get planFinished => 'Plan complete';

  @override
  String get planMarkDayRead => 'Mark today\'s reading';

  @override
  String planMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get planOrderAlphabetical => 'Alphabetical order';

  @override
  String get planOrderAlphabeticalShort => 'Alphabetical';

  @override
  String get planOrderCanonical => 'Bible order';

  @override
  String get planOrderCanonicalShort => 'Canonical';

  @override
  String get planOrderChronological => 'Chronological order';

  @override
  String get planOrderChronologicalShort => 'Chronological';

  @override
  String get planPendingChapters => 'Chapters left';

  @override
  String planPortionMeta(int minutes, int count, String order) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '~$minutes min · $count chapters · $order',
      one: '~$minutes min · 1 chapter · $order',
    );
    return '$_temp0';
  }

  @override
  String planReadingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days of reading',
      one: '1 day of reading',
    );
    return '$_temp0';
  }

  @override
  String get planRemaining => 'Remaining';

  @override
  String get planSectionOrder => 'Order';

  @override
  String get planSectionTime => 'Time available';

  @override
  String get planSetupBody =>
      'We build a daily portion that fits that time — in Bible order or in the order events happened. Chapters you\'ve already read are skipped.';

  @override
  String get planSetupQuestion => 'How much time do you have each day?';

  @override
  String planSkippedChaptersToast(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Skipped $count chapters you already read',
      one: 'Skipped 1 chapter you already read',
    );
    return '$_temp0';
  }

  @override
  String planStartCta(int minutes) {
    return 'Start plan · $minutes min/day';
  }

  @override
  String get planTitle => 'Reading plan';

  @override
  String get planTodayChapters => 'Today\'s chapters';

  @override
  String get planTodayDoneBody =>
      'Today\'s portion is done. Come back tomorrow — or keep exploring the Bible freely.';

  @override
  String get portraitAvatar => 'Avatar';

  @override
  String get portraitAvatarHint => 'An illustrated pilgrim';

  @override
  String get portraitEyebrow => 'Portrait';

  @override
  String get portraitLetter => 'Letter';

  @override
  String get portraitLetterHint => 'Your name\'s initials';

  @override
  String get portraitNoPhoto => 'No photo on this account';

  @override
  String get portraitPhoto => 'Photo';

  @override
  String get portraitPhotoHint => 'Your account photo';

  @override
  String get portraitTitle => 'How you appear on your profile';

  @override
  String get practiceEmptyBody =>
      'Keep going with the scenes. When you miss one, the question comes back here.';

  @override
  String get practiceEmptyTitle => 'No saved mistakes yet';

  @override
  String get practiceIntro =>
      'Go back to the questions you missed. Each right answer clears it from the queue.';

  @override
  String get practiceSubtitle => 'Reinforce the passages';

  @override
  String get practiceTitle => 'Review mistakes';

  @override
  String profileDaysOnTop(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days on top',
      one: '1 day on top',
    );
    return '$_temp0';
  }

  @override
  String get profileDaysPerWeek => 'days per week';

  @override
  String get profileInTheWord => 'In the Word';

  @override
  String get profileInTheWordWhisper =>
      'Verses you save and the ones you\'ve sent.';

  @override
  String get profileLampHelp =>
      'Each lamp is a week: the oil rises with every day walked and the flame grows.';

  @override
  String get profileLastThreeMonths => 'Last 3 months';

  @override
  String profileMonthRank(int rank) {
    return '#$rank in this month\'s ranking';
  }

  @override
  String profileOfSevenDays(int count) {
    return '$count of 7 days';
  }

  @override
  String get profileOpenBible => 'Open the Bible';

  @override
  String profileOpenRef(String ref) {
    return 'Open $ref';
  }

  @override
  String profilePrivacyHiddenSemantics(String label) {
    return '$label hidden from the caravan';
  }

  @override
  String profilePrivacyHiddenToast(String label) {
    return '$label stays with you only.';
  }

  @override
  String profilePrivacyShownSemantics(String label) {
    return '$label visible to the caravan';
  }

  @override
  String profilePrivacyShownToast(String label) {
    return '$label shows on your caravan profile.';
  }

  @override
  String get profileSavedVerses => 'Saved';

  @override
  String get profileSavedVersesEmpty =>
      'While reading, tap a verse and choose Save to come back to it later.';

  @override
  String get profileSectionAccuracy => 'Accuracy';

  @override
  String get profileSectionAccuracyHint => 'Share of right answers in scenes';

  @override
  String get profileSectionBibleHint => 'Books and chapters read';

  @override
  String get profileSectionDaysOnTop => 'Days on top';

  @override
  String get profileSectionDaysOnTopHint =>
      'How many days you were #1 in the overall ranking';

  @override
  String get profileSectionLastScene => 'Last scene';

  @override
  String get profileSectionLastSceneHint => 'Name of the last scene completed';

  @override
  String get profileSectionMedals => 'Medals';

  @override
  String get profileSectionMedalsHint => 'Journey medals';

  @override
  String get profileSectionPresence => 'Presence';

  @override
  String get profileSectionPresenceHint =>
      'Week, streak and milestones, from Seed to Fruit';

  @override
  String get profileSectionRanking => 'Ranking and steps';

  @override
  String get profileSectionRankingHint => 'Position and total steps';

  @override
  String get profileSectionTrailsHint => 'Trail progress and seals earned';

  @override
  String get profileSharedVerses => 'Sent';

  @override
  String get profileSharedVersesEmpty =>
      'Verses you share show up here — just the reference.';

  @override
  String profileSince(String month, int year) {
    return 'Pilgrim since $month $year';
  }

  @override
  String profileStreakGoalDone(int goal) {
    return '$goal-day commitment met. Keep going.';
  }

  @override
  String profileStreakOf(int streak, int goal) {
    return 'Streak of $streak of $goal days';
  }

  @override
  String profileStreakOfGoal(int goal) {
    return 'of $goal';
  }

  @override
  String profileStreakRemaining(int left, int goal) {
    return '$left left for the $goal-day commitment.';
  }

  @override
  String get profileStreakStart => 'One scene today lights the first day.';

  @override
  String get profileThisWeek => 'This week';

  @override
  String get profileThisWeekLower => 'this week';

  @override
  String profileThisWeekSemantics(int count) {
    return 'This week: $count of 7 days walked';
  }

  @override
  String get profileThreeMonthsAgo => '3 months ago';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileTodayLower => 'today';

  @override
  String get profileWdFri => 'F';

  @override
  String get profileWdMon => 'M';

  @override
  String get profileWdSat => 'S';

  @override
  String get profileWdSun => 'S';

  @override
  String get profileWdThu => 'T';

  @override
  String get profileWdTue => 'T';

  @override
  String get profileWdWed => 'W';

  @override
  String get profileWeekHistory => 'Week history';

  @override
  String profileWeeksWalkedSemantics(int walked, int weeks) {
    return '$walked days walked in the last $weeks weeks';
  }

  @override
  String get profileYourJourney => 'Your journey';

  @override
  String get profileYourNumbers => 'Your numbers';

  @override
  String get profileYourStreak => 'Your streak';

  @override
  String get questAccuracySubtitle => 'Finish a scene with 80% correct';

  @override
  String get questAccuracyTitle => 'Steady eye';

  @override
  String questCountOf(int done, int total) {
    return '$done of $total';
  }

  @override
  String get questDailySubtitle => 'Extra steps beyond the scene.';

  @override
  String get questDailyTitle => 'Daily tasks';

  @override
  String get questDone => 'Done';

  @override
  String get questDoneLower => 'done';

  @override
  String get questMilestone100Subtitle => '100% — keep walking';

  @override
  String get questMilestone100Title => 'Journey complete';

  @override
  String get questMilestone25Subtitle => '25% of the trail';

  @override
  String get questMilestone25Title => 'Good start';

  @override
  String get questMilestone50Subtitle => '50% of the trail';

  @override
  String get questMilestone50Title => 'Halfway';

  @override
  String get questMilestone75Subtitle => '75% of the trail';

  @override
  String get questMilestone75Title => 'Almost there';

  @override
  String get questMissionSubtitle => 'Complete one scene';

  @override
  String get questMissionTitle => 'One scene';

  @override
  String questProgressLine(int value, int target, String subtitle) {
    return '$value of $target · $subtitle';
  }

  @override
  String get questReadSubtitle => 'Read one chapter';

  @override
  String get questReadTitle => 'In the Word';

  @override
  String get questWeeklyDaysSubtitle => 'Walk on 4 different days';

  @override
  String get questWeeklyDaysTitle => 'Four days';

  @override
  String get questWeeklyPerfectSubtitle =>
      'Two scenes with 100% correct this week';

  @override
  String get questWeeklyPerfectTitle => 'Two perfect';

  @override
  String get questWeeklyScenesSubtitle => 'Complete 5 scenes this week';

  @override
  String get questWeeklyScenesTitle => 'Five scenes';

  @override
  String get questWeeklyTitle => 'Weekly tasks';

  @override
  String get realmAntigoTestamento => 'Old Testament';

  @override
  String get realmEyebrowAntigoTestamento => 'The promise';

  @override
  String get realmEyebrowNovoTestamento => 'The fulfillment';

  @override
  String get realmEyebrowTeologia => 'The foundation';

  @override
  String get realmEyebrowVidaCrista => 'The walk';

  @override
  String get realmNovoTestamento => 'New Testament';

  @override
  String get realmOther => 'Other';

  @override
  String get realmTaglineAntigoTestamento =>
      'From creation to the prophets — the way of the covenant';

  @override
  String get realmTaglineNovoTestamento =>
      'Christ, the Church and the hope that does not fail';

  @override
  String get realmTaglineTeologia =>
      'Hermeneutics, languages and the doctrine of faith';

  @override
  String get realmTaglineVidaCrista =>
      'Discipleship, prayer and the history of faith';

  @override
  String get realmTeologia => 'Theology';

  @override
  String get realmTeologiaSoonBody =>
      'Hermeneutics, original languages and dogmatics.';

  @override
  String get realmVidaCrista => 'Christian life';

  @override
  String get recognitionAMedal => 'A medal';

  @override
  String get recognitionAlready => 'You already recognized this';

  @override
  String recognitionAndMore(String a, String b, int count) {
    return '$a, $b and $count more';
  }

  @override
  String recognitionAndTwo(String a, String b) {
    return '$a and $b';
  }

  @override
  String recognitionDaysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get recognitionEmptyCard =>
      'When someone in the caravan taps the heart, it shows up here.';

  @override
  String get recognitionEmptySheet =>
      'Nobody has recognized your journey yet.\nIn the caravan, others can tap the heart.';

  @override
  String get recognitionFailedGive => 'Couldn\'t recognize';

  @override
  String get recognitionFailedWithdraw => 'Couldn\'t remove it';

  @override
  String get recognitionGivenTapWithdraw => 'Recognized · tap to remove';

  @override
  String recognitionHeadlineMedal(String name, String title) {
    return '$name recognized $title';
  }

  @override
  String recognitionHeadlineMedalUnknown(String name) {
    return '$name recognized one of your medals';
  }

  @override
  String recognitionHeadlineWalk(String name) {
    return '$name recognized your scene';
  }

  @override
  String get recognitionHomeSeeWho => 'See who recognized you';

  @override
  String get recognitionHomeTitleMany => 'People recognized your journey';

  @override
  String recognitionHomeTitleSingle(String name) {
    return '$name recognized your journey';
  }

  @override
  String get recognitionMedalDone => 'Medal recognized';

  @override
  String get recognitionMedalFirstScene => 'First scene';

  @override
  String get recognitionMedalInterpretation => 'Interpretation';

  @override
  String get recognitionMedalObservation => 'Observation';

  @override
  String get recognitionMedalUnderstanding => 'Understanding';

  @override
  String get recognitionRecognizeScene => 'Recognize the scene';

  @override
  String get recognitionRemoved => 'Recognition removed';

  @override
  String recognitionSawJourney(int count, String who) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$who saw your journey',
      one: '$who saw your journey',
    );
    return '$_temp0';
  }

  @override
  String recognitionSawYou(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recognized you $count times',
      one: 'recognized you',
    );
    return '$_temp0';
  }

  @override
  String get recognitionSceneDone => 'Scene recognized';

  @override
  String recognitionSceneOf(String date) {
    return 'Scene of $date';
  }

  @override
  String recognitionSemanticsWho(String subtitle) {
    return 'Who recognized you. $subtitle';
  }

  @override
  String recognitionSummaryCounts(int recog, int people) {
    String _temp0 = intl.Intl.pluralLogic(
      recog,
      locale: localeName,
      other: '$recog recognitions',
      one: '1 recognition',
    );
    String _temp1 = intl.Intl.pluralLogic(
      people,
      locale: localeName,
      other: '$people people',
      one: '1 person',
    );
    return '$_temp0 from $_temp1';
  }

  @override
  String get recognitionSummaryEmpty =>
      'Today\'s scene and medals others saw in you.';

  @override
  String get recognitionTapToWithdraw => 'Tap again to remove';

  @override
  String get recognitionWhichMedal => 'Which medal did you see?';

  @override
  String get recognitionWhoTitle => 'Who recognized you';

  @override
  String get recognitionYesterday => 'Yesterday';

  @override
  String get recognitionYourScene => 'Your scene';

  @override
  String get reminderDailyEyebrow => 'Daily reminder';

  @override
  String reminderHour(int hour) {
    return '$hour:00';
  }

  @override
  String get reminderMorning => 'Morning';

  @override
  String get reminderNight => 'Evening';

  @override
  String get reminderNoon => 'Noon';

  @override
  String reminderRemindAt(int hour) {
    return 'Remind me at $hour:00';
  }

  @override
  String get reminderSubtitle =>
      'A fixed time makes the habit stick. Tomorrow we\'ll let you know about the next scene.';

  @override
  String get reminderSubtitleSettings =>
      'One reminder a day, at the time you choose.';

  @override
  String get reminderTitle => 'What time should we remind you?';

  @override
  String get reportCategoryFeedback => 'Confusing feedback';

  @override
  String get reportCategoryInterpretation => 'Questionable interpretation';

  @override
  String get reportCategoryOther => 'Other';

  @override
  String get reportCategoryTheological => 'Theological error';

  @override
  String get reportCategoryTypo => 'Spelling / text';

  @override
  String get reportCategoryWrongAnswer => 'Marked answer is wrong';

  @override
  String get reportCommentHint => 'Optional: tell us what seems wrong…';

  @override
  String get reportHintFeedback =>
      'The explanation after the answer is confusing or wrong';

  @override
  String get reportHintInterpretation =>
      'The reading of the biblical text seems forced or imprecise';

  @override
  String get reportHintOther => 'Something else that doesn\'t fit above';

  @override
  String get reportHintTheological =>
      'The doctrine, stated or implied, seems incorrect';

  @override
  String get reportHintTypo => 'Typo, reference, or formatting error';

  @override
  String get reportHintWrongAnswer =>
      'The option marked as correct seems wrong';

  @override
  String get reportIntro =>
      'Help improve the trail — theological error, interpretation, answer, or text.';

  @override
  String get reportSend => 'Send report';

  @override
  String get reportSendError => 'Couldn\'t send. Try again.';

  @override
  String get reportSending => 'Sending…';

  @override
  String get reportSignInRequired => 'Sign in with Google to send the report.';

  @override
  String get reportTitle => 'Report a problem';

  @override
  String get resetAwareness => 'I understand I\'ll lose my progress';

  @override
  String get resetBody =>
      'All your steps, your streak and your progress will be erased. The intro will show again. This can\'t be undone.';

  @override
  String get resetConfirm => 'Confirm';

  @override
  String resetConfirmCountdown(int seconds) {
    return 'Confirm · ${seconds}s';
  }

  @override
  String get resetTitle => 'Erase progress';

  @override
  String get roomErrorCreate => 'Couldn\'t create the group. Try again.';

  @override
  String get roomErrorCreateFirst =>
      'Create the group before inviting someone.';

  @override
  String roomErrorFull(int limit) {
    return 'This group already has $limit people.';
  }

  @override
  String roomErrorFullAskLeader(int limit) {
    return 'This group already has $limit people. Ask the leader to open another group.';
  }

  @override
  String get roomErrorInvalidCode => 'Invalid code or group not found.';

  @override
  String get roomErrorLostGroup => 'We couldn\'t find the group you were in.';

  @override
  String get roomErrorSignInCreate => 'Sign in with Google to create a group.';

  @override
  String get roomErrorSignInJoin => 'Sign in with Google to join a group.';

  @override
  String get roomFallbackName => 'Group';

  @override
  String get roomKindAmigos => 'Friends';

  @override
  String get roomKindCelula => 'Cell group';

  @override
  String get roomKindDiscipulado => 'Discipleship';

  @override
  String get roomKindEbd => 'Sunday school';

  @override
  String get roomKindFamilia => 'Family';

  @override
  String get roomLeaderAmigos => 'Host';

  @override
  String get roomLeaderCelula => 'Leader';

  @override
  String get roomLeaderDiscipulado => 'Mentor';

  @override
  String get roomLeaderEbd => 'Teacher';

  @override
  String get roomLeaderFamilia => 'Host';

  @override
  String get roomNameHintAmigos => 'E.g. College friends';

  @override
  String get roomNameHintCelula => 'E.g. North cell';

  @override
  String get roomNameHintDiscipulado => 'E.g. Thursday discipleship';

  @override
  String get roomNameHintEbd => 'E.g. Youth class';

  @override
  String get roomNameHintFamilia => 'E.g. Souza family';

  @override
  String get roomStudyFallbackTitle => 'This week\'s study';

  @override
  String sealsAllRevealed(int done, int total) {
    return '$done of $total — all seals revealed.';
  }

  @override
  String sealsCountFact(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seals — fact and verse, in the text.',
      one: '1 seal — fact and verse, in the text.',
    );
    return '$_temp0';
  }

  @override
  String get sealsEmptyHint =>
      'Fact and verse of those the text has already shown.';

  @override
  String get sealsSemanticsLocked => 'Seal still locked';

  @override
  String sealsSemanticsNamed(String name) {
    return 'Seal $name';
  }

  @override
  String sealsStartsAt(String name) {
    return 'Still in the text — starts at $name.';
  }

  @override
  String sealsStillInText(int done, int total, String name) {
    return '$done of $total — still in the text: $name';
  }

  @override
  String get sealsTitle => 'Seals';

  @override
  String get seasonChallengeDoneBody =>
      'Season challenge complete. Well walked.';

  @override
  String get seasonChallengeEmptyBody =>
      'The next one arrives with the new liturgical season.';

  @override
  String get seasonChallengeEmptyTitle => 'No season challenge right now';

  @override
  String get seasonChallengeInProgress => 'Season challenge in progress';

  @override
  String get seasonChallengeInvite => 'Invite to the challenge';

  @override
  String seasonChallengePathPercent(int percent) {
    return '$percent% of the way';
  }

  @override
  String get seasonChallengeSeeProgress => 'See progress';

  @override
  String seasonChallengeShareBody(String title, String footer) {
    return '🕯️ I joined the $title challenge on Stway.\n\nShall we walk this season together?\n\n$footer';
  }

  @override
  String get seasonChallengeTitle => 'Season challenge';

  @override
  String seasonDayLine(int day, String title) {
    return 'Day $day · $title';
  }

  @override
  String seasonDayOf(String day, int total) {
    return 'Day $day of $total';
  }

  @override
  String seasonDaysWalked(int done, int total) {
    return '$done / $total days walked';
  }

  @override
  String get seasonEnded => 'Season ended';

  @override
  String get seasonFreeTrialLine => 'Free: first 3 days · then Pilgrim+';

  @override
  String get seasonNotTodayYet => 'Not today yet';

  @override
  String get seasonProFromDay4 => 'Pilgrim+ from day 4';

  @override
  String get seasonReviewEmpty =>
      'There are no questions from this week on the device yet. Open a day first.';

  @override
  String get seasonReviewMissionIntro =>
      'Three questions from the texts you\'ve already studied.';

  @override
  String get seasonReviewMissionTitle => 'Week review';

  @override
  String get seasonReviewPreparing => 'Preparing…';

  @override
  String get seasonReviewStart => '3 review questions';

  @override
  String seasonStartsIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Starts in $count days',
      one: 'Starts in 1 day',
    );
    return '$_temp0';
  }

  @override
  String seasonTodayInsight(String insight) {
    return 'Today: $insight';
  }

  @override
  String get seasonWalkAdvento2026Day01Insight => 'God drew near';

  @override
  String get seasonWalkAdvento2026Day01Title => 'The Word became flesh';

  @override
  String get seasonWalkAdvento2026Day02Insight => 'God is the center, not me';

  @override
  String get seasonWalkAdvento2026Day02Title => 'In the beginning';

  @override
  String get seasonWalkAdvento2026Day03Insight => 'We were made to reflect';

  @override
  String get seasonWalkAdvento2026Day03Title => 'Image';

  @override
  String get seasonWalkAdvento2026Day04Insight => 'Faith walks when God calls';

  @override
  String get seasonWalkAdvento2026Day04Title => 'Call';

  @override
  String get seasonWalkAdvento2026Day05Insight =>
      'The promise is bigger than fear';

  @override
  String get seasonWalkAdvento2026Day05Title => 'Stars';

  @override
  String get seasonWalkAdvento2026Day06Insight => 'God will provide the lamb';

  @override
  String get seasonWalkAdvento2026Day06Title => 'Moriah';

  @override
  String get seasonWalkAdvento2026Day07Insight => 'God raises a deliverer';

  @override
  String get seasonWalkAdvento2026Day07Title => 'Moses';

  @override
  String get seasonWalkAdvento2026Day08Insight => 'The blood guards the house';

  @override
  String get seasonWalkAdvento2026Day08Title => 'Passover';

  @override
  String get seasonWalkAdvento2026Day09Insight => 'The Kingdom has a voice';

  @override
  String get seasonWalkAdvento2026Day09Title => 'The King on the mount';

  @override
  String get seasonWalkAdvento2026Day10Insight =>
      'The Kingdom fits in emptiness';

  @override
  String get seasonWalkAdvento2026Day10Title => 'Poor in spirit';

  @override
  String get seasonWalkAdvento2026Day11Insight =>
      'There is comfort for those who mourn';

  @override
  String get seasonWalkAdvento2026Day11Title => 'Those who mourn';

  @override
  String get seasonWalkAdvento2026Day12Insight => 'Shalom is a mission';

  @override
  String get seasonWalkAdvento2026Day12Title => 'Peacemakers';

  @override
  String get seasonWalkAdvento2026Day13Insight => 'Heaven opens over the Son';

  @override
  String get seasonWalkAdvento2026Day13Title => 'Baptism';

  @override
  String get seasonWalkAdvento2026Day14Insight =>
      'The mount teaches the Kingdom';

  @override
  String get seasonWalkAdvento2026Day14Title => 'Sermon';

  @override
  String get seasonWalkAdvento2026Day15Insight =>
      'To pray is to ask for the Kingdom';

  @override
  String get seasonWalkAdvento2026Day15Title => 'Our Father';

  @override
  String get seasonWalkAdvento2026Day16Insight => 'I shall not want';

  @override
  String get seasonWalkAdvento2026Day16Title => 'My shepherd';

  @override
  String get seasonWalkAdvento2026Day17Insight =>
      'Christ went down to the cross';

  @override
  String get seasonWalkAdvento2026Day17Title => 'Humility';

  @override
  String get seasonWalkAdvento2026Day18Insight =>
      'The Kingdom is heard in story';

  @override
  String get seasonWalkAdvento2026Day18Title => 'Parables';

  @override
  String get seasonWalkAdvento2026Day19Insight =>
      'The Kingdom touches the body';

  @override
  String get seasonWalkAdvento2026Day19Title => 'Miracles';

  @override
  String get seasonWalkAdvento2026Day20Insight => 'Treasure pulls the heart';

  @override
  String get seasonWalkAdvento2026Day20Title => 'Anxiety';

  @override
  String get seasonWalkAdvento2026Day21Insight =>
      'The bread anticipates the giving';

  @override
  String get seasonWalkAdvento2026Day21Title => 'Supper';

  @override
  String get seasonWalkAdvento2026Day22Insight =>
      'The King reigns while nailed';

  @override
  String get seasonWalkAdvento2026Day22Title => 'Cross';

  @override
  String get seasonWalkAdvento2026Day23Insight => 'The wait was not in vain';

  @override
  String get seasonWalkAdvento2026Day23Title => 'Resurrection';

  @override
  String get seasonWalkAdvento2026Day24Insight => 'The seventh day is a gift';

  @override
  String get seasonWalkAdvento2026Day24Title => 'Rest';

  @override
  String get seasonWalkAdvento2026Day25Insight => 'Rejoice in the Lord';

  @override
  String get seasonWalkAdvento2026Day25Title => 'Joy';

  @override
  String get seasonWalkAdvento2026Day26Insight =>
      'Those who hunger will be filled';

  @override
  String get seasonWalkAdvento2026Day26Title => 'Hunger for justice';

  @override
  String get seasonWalkAdvento2026Subtitle =>
      'Waiting for the Word · one scene a day';

  @override
  String get seasonWalkAdvento2026Title => 'Advent 2026';

  @override
  String seasonWeek(int week) {
    return 'Week $week';
  }

  @override
  String get seasonWeekInsightsHeader => 'This week\'s 7 “Today:” lines';

  @override
  String get seasonWeekReview => 'Week review';

  @override
  String get seasonWeekReviewPro => 'Week review · Pilgrim+';

  @override
  String seasonWeekReviewTitle(int week) {
    return 'Week $week review';
  }

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAboutPage => 'About Stway';

  @override
  String get settingsAboutPageSubtitle => 'Name, mission, vision, and values';

  @override
  String get settingsAboutSubtitle =>
      'Learn the Bible in short scenes, at your own pace.';

  @override
  String get settingsAboutTitle => 'About Stway';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsBackupInvalid => 'Invalid backup.';

  @override
  String get settingsBackupSheetBody =>
      'Export your progress as text, or copy a backup and tap restore.';

  @override
  String get settingsBackupSubject => 'Stway backup';

  @override
  String get settingsCheck => 'Check';

  @override
  String get settingsCheckingUpdate => 'Checking for updates…';

  @override
  String get settingsCreditsRowSubtitle => 'Bible texts and study';

  @override
  String get settingsCreditsSubtitle =>
      'Bible texts and study tools used in Stway.';

  @override
  String get settingsCreditsTitle => 'Translations and credits';

  @override
  String get settingsDailyReminder => 'Daily reminder';

  @override
  String settingsDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get settingsDeleteProgress => 'Delete progress';

  @override
  String get settingsDeleteProgressSubtitle =>
      'Deletes your progress for good · asks to confirm';

  @override
  String settingsDeviceId(String id) {
    return 'Device · $id';
  }

  @override
  String get settingsDeviceOnly => 'Only on this device';

  @override
  String get settingsExport => 'Export';

  @override
  String get settingsFontExtra => 'Extra large';

  @override
  String get settingsFontLarge => 'Large';

  @override
  String get settingsFontMedium => 'Medium';

  @override
  String get settingsFontSmall => 'Small';

  @override
  String get settingsGenesisTitle => 'Genesis 1–11';

  @override
  String get settingsGroupAccountData => 'Account and data';

  @override
  String get settingsGroupDevice => 'On this device';

  @override
  String get settingsGroupProgress => 'Progress';

  @override
  String get settingsInCloud => 'In the cloud';

  @override
  String settingsLastBackup(String date) {
    return 'Last backup · $date';
  }

  @override
  String settingsLastShort(String date) {
    return 'Last · $date';
  }

  @override
  String get settingsManualBackup => 'Manual backup';

  @override
  String get settingsManualBackupSubtitle => 'Export or restore your progress';

  @override
  String get settingsPaceIntense => 'Intense';

  @override
  String get settingsPaceLight => 'Light';

  @override
  String get settingsPaceSteady => 'Steady';

  @override
  String get settingsPasteBackupFirst =>
      'Copy a backup to the clipboard first.';

  @override
  String get settingsPlusTeaser => 'More room for your companion';

  @override
  String get settingsProgressInCloud => 'Progress in the cloud';

  @override
  String get settingsProgressRestored => 'Progress restored.';

  @override
  String settingsReminderAt(int hour) {
    return 'At $hour:00 · tap to change';
  }

  @override
  String get settingsRemindersTitle => 'Reminders';

  @override
  String get settingsReplayIntro => 'Replay intro';

  @override
  String get settingsReplayIntroSubtitle => 'The opening walkthrough, again';

  @override
  String get settingsRestoreFromClipboard => 'Restore from clipboard';

  @override
  String get settingsRhythmSubtitle => 'How many scenes fit in your day.';

  @override
  String get settingsRhythmTitle => 'Daily pace';

  @override
  String get settingsSampleVerse =>
      'In the beginning, God created the heavens and the earth.';

  @override
  String get settingsSaveName => 'Save name';

  @override
  String settingsSavedInCloud(String date) {
    return 'Saved to the cloud · $date';
  }

  @override
  String settingsScenes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scenes',
      one: '1 scene',
    );
    return '$_temp0';
  }

  @override
  String settingsScenesPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scenes a day',
      one: '1 scene a day',
    );
    return '$_temp0';
  }

  @override
  String get settingsSignInAgain => 'Sign in again to sync your progress.';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutFailed => 'Couldn\'t sign out. Try again.';

  @override
  String get settingsSignOutSubtitle =>
      'Clears this device · your progress stays in the cloud';

  @override
  String settingsSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get settingsSounds => 'Sounds';

  @override
  String get settingsSoundsSubtitle => 'Effects in scenes';

  @override
  String get settingsStreakGoalHint =>
      'How many days you want to keep your streak going.';

  @override
  String get settingsStreakGoalLabel => 'Streak commitment';

  @override
  String settingsStudyAttribution(String attribution) {
    return 'Study (Strong\'s) — $attribution';
  }

  @override
  String get settingsSubscriptionActive => 'Subscription active';

  @override
  String get settingsSubtitle => 'Account, appearance and reminders';

  @override
  String get settingsSupport => 'Help keep it going';

  @override
  String get settingsTextSize => 'Text size';

  @override
  String get settingsTextSizeHint => 'The verse below changes with it.';

  @override
  String get settingsThemeAuto => 'Automatic';

  @override
  String get settingsThemeCaptionAuto => 'Changes with the time of day';

  @override
  String get settingsThemeCaptionDark => 'Always dark';

  @override
  String get settingsThemeCaptionLight => 'Always light';

  @override
  String get settingsThemeCaptionMedium => 'Always dim';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeHint => 'A fixed theme, or automatic by time of day.';

  @override
  String get settingsThemeLabel => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeMedium => 'Medium';

  @override
  String get settingsThemeSemantics => 'Screen theme';

  @override
  String get settingsThemeSemanticsHint => 'Tap or swipe to choose';

  @override
  String get settingsTitle => 'Settings';

  @override
  String settingsUpToDate(String version) {
    return 'You\'re on the latest version · $version';
  }

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsYourName => 'Your name';

  @override
  String shellReferralBonus(int count, int steps) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your invites earned +$steps steps',
      one: 'Your invite earned +$steps steps',
    );
    return '$_temp0';
  }

  @override
  String get shellTogetherSubtitle => 'Companion · Caravan · Groups';

  @override
  String get shellTrailsSubtitle => 'The map of your journey';

  @override
  String shellWeekTogetherBonus(int steps) {
    return 'Your companion earned +$steps steps on the journey';
  }

  @override
  String get splashPreparing => 'Preparing your journey…';

  @override
  String get splashSlogan => 'The Bible, scene by scene';

  @override
  String get streakDayEmpty => 'no scene';

  @override
  String get streakDayFrozen => 'protected by a freeze';

  @override
  String streakDaySemantics(String day, String status) {
    return '$day: $status';
  }

  @override
  String streakDayTodaySemantics(String day, String status) {
    return 'Today, $day: $status';
  }

  @override
  String get streakRepairAction => 'Repair';

  @override
  String streakRepairBody(int broken, int restored) {
    String _temp0 = intl.Intl.pluralLogic(
      broken,
      locale: localeName,
      other: 'You had $broken days. Restore it to $restored — once this month.',
      one: 'You had 1 day. Restore it to $restored — once this month.',
    );
    return '$_temp0';
  }

  @override
  String streakRepairCanReturn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days can still come back',
      one: '1 day can still come back',
    );
    return '$_temp0';
  }

  @override
  String streakRepairContinueWith(int count) {
    return 'Keep going with $count · once this month';
  }

  @override
  String get streakRepairDismiss => 'Let it go';

  @override
  String streakRepairDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Streak restored · $count days',
      one: 'Streak restored · 1 day',
    );
    return '$_temp0';
  }

  @override
  String get streakRepairTitle => 'Repair streak';

  @override
  String streakShareDays(int count, int steps, String signature) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '🔥 $count days on Stway!\n\nI\'m learning the Bible in short scenes — $steps steps so far.$signature\n\nGet Stway and come along.',
      one:
          '🔥 1 day on Stway!\n\nI\'m learning the Bible in short scenes — $steps steps so far.$signature\n\nGet Stway and come along.',
    );
    return '$_temp0';
  }

  @override
  String streakShareStart(String signature) {
    return '🔥 I started learning the Bible with Stway.$signature\n\nGet Stway and come along.';
  }

  @override
  String streakShareSteps(int steps, String signature) {
    return '🔥 I\'m learning the Bible on Stway — $steps steps so far.$signature\n\nGet Stway and come along.';
  }

  @override
  String get streakShareSubject => 'My streak on Stway';

  @override
  String get streakShareTooltip => 'Share streak';

  @override
  String get strongKindConjunction => 'Conjunction';

  @override
  String get strongKindGreek => 'Greek';

  @override
  String get strongKindHebrew => 'Hebrew';

  @override
  String get strongKindParticle => 'Particle';

  @override
  String get strongKindPrefix => 'Prefix';

  @override
  String get strongKindPronoun => 'Pronoun';

  @override
  String get strongKindPunctuation => 'Punctuation';

  @override
  String get strongKindSuffix => 'Suffix';

  @override
  String get strongNoteConjunction =>
      'Prefixed conjunction (vav). The meaning sits in the verb or noun it joins.';

  @override
  String get strongNoteParticle =>
      'A STEP grammatical particle, not a classic Strong number.';

  @override
  String get strongNotePrefix =>
      'Inseparable preposition or article — it attaches to the next word. Not a classic Strong entry.';

  @override
  String get strongNotePronoun =>
      'Suffixed pronoun: who receives or owns what the word says.';

  @override
  String get strongNotePunctuation =>
      'A reading mark in the Hebrew text, not a word.';

  @override
  String get strongNoteSuffix =>
      'A grammatical ending, not a dictionary entry.';

  @override
  String get suggestionAuthorEmail => 'Email';

  @override
  String get suggestionAuthorEmailHint => 'name@email.com';

  @override
  String get suggestionAuthorHintContact => 'Add a phone, email or Instagram.';

  @override
  String get suggestionAuthorHintEmail => 'Check the email.';

  @override
  String get suggestionAuthorHintInstagram => 'Check the Instagram.';

  @override
  String get suggestionAuthorHintName => 'Write the name — at least 2 letters.';

  @override
  String get suggestionAuthorHintPhone =>
      'Check the phone number, with area code.';

  @override
  String get suggestionAuthorInstagramHint => '@username';

  @override
  String get suggestionAuthorName => 'Name';

  @override
  String get suggestionAuthorNameHint => 'How the person introduces themselves';

  @override
  String get suggestionAuthorPhone => 'Phone';

  @override
  String get suggestionAuthorSent =>
      'Suggestion sent. Thanks for recommending the author.';

  @override
  String get suggestionAuthorSubtitle => 'Who\'s still missing from the map?';

  @override
  String get suggestionAuthorTitle => 'Suggest an author';

  @override
  String get suggestionHintAntigoTestamento =>
      'E.g.: Psalms, Exodus, the prophets…';

  @override
  String get suggestionHintNovoTestamento =>
      'E.g.: the Sermon on the Mount, Romans, Acts…';

  @override
  String get suggestionHintOther =>
      'E.g.: a topic, a book or a question that\'s still missing…';

  @override
  String get suggestionHintTeologia =>
      'E.g.: the Trinity, hermeneutics, Hebrew…';

  @override
  String get suggestionHintVidaCrista =>
      'E.g.: prayer, fasting, church history…';

  @override
  String get suggestionSend => 'Send suggestion';

  @override
  String get suggestionSendError => 'Couldn\'t send. Try again.';

  @override
  String get suggestionSending => 'Sending…';

  @override
  String get suggestionSignInToSend => 'Sign in to send the suggestion.';

  @override
  String get suggestionTrailHintBoth =>
      'Choose an area and describe the trail.';

  @override
  String get suggestionTrailHintRealm => 'Choose where this trail fits.';

  @override
  String get suggestionTrailHintText =>
      'Describe the trail — at least 4 letters.';

  @override
  String get suggestionTrailPlaceholder =>
      'Choose an area and describe the trail…';

  @override
  String get suggestionTrailRealmLabel => 'Where it fits';

  @override
  String get suggestionTrailSent => 'Suggestion sent. Thank you.';

  @override
  String get suggestionTrailSubtitle => 'What\'s still missing from the map?';

  @override
  String get suggestionTrailTextLabel => 'The trail';

  @override
  String get suggestionTrailTitle => 'Suggest a trail';

  @override
  String tomorrowDayOf(int streak, int goal) {
    return 'Day $streak of $goal';
  }

  @override
  String tomorrowLine(String title) {
    return 'Tomorrow: $title';
  }

  @override
  String get tomorrowNextTrail => 'Next trail';

  @override
  String get tomorrowNextTrailOnMap => 'The next trail is already on the map.';

  @override
  String get tomorrowSceneWaits => 'The scene is waiting for you.';

  @override
  String get tomorrowSevenDays => 'Seven days. The habit stuck.';

  @override
  String get tomorrowStoryContinues => 'The story continues in the text.';

  @override
  String get tomorrowTodayYouSaw => 'Today you saw';

  @override
  String tomorrowYesterday(String text) {
    return 'Yesterday: $text';
  }

  @override
  String get trailMapCrossing => 'Crossing';

  @override
  String get trailMapLocked => 'Locked';

  @override
  String get trailMapScene => 'Scene';

  @override
  String trailMapSeal(String name) {
    return '$name seal';
  }

  @override
  String get trailsAreasHeading => 'The areas';

  @override
  String get trailsCleared => 'Complete';

  @override
  String trailsContinueSemantics(String title) {
    return 'Continue · $title';
  }

  @override
  String get trailsDonateBody =>
      'A voluntary contribution toward the next trails.';

  @override
  String get trailsDonateCta => 'Donate';

  @override
  String get trailsDonateTitle => 'Help keep it going';

  @override
  String trailsDoneOfTotal(int done, int total) {
    return '$done of $total';
  }

  @override
  String get trailsDownloading => 'Downloading…';

  @override
  String get trailsEmptyBody =>
      'The curriculum downloads the first time you open the app. If the connection drops, tap to try again.';

  @override
  String get trailsEmptyTitle => 'The scenes haven\'t arrived yet';

  @override
  String get trailsHorizonBody => 'New trails are being prepared.';

  @override
  String get trailsHorizonEyebrow => 'On the horizon';

  @override
  String get trailsInProgress => 'In progress';

  @override
  String trailsLabeledScenesOf(String label, int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$label · $done of $total scenes',
      one: '$label · $done of 1 scene',
    );
    return '$_temp0';
  }

  @override
  String get trailsLearnMore => 'Learn more';

  @override
  String trailsModeAllSealed(String mode) {
    return '$mode complete · all three modes of this trail are sealed';
  }

  @override
  String trailsModeChip(String mode) {
    return '$mode mode';
  }

  @override
  String trailsModeCleared(String mode) {
    return '$mode complete';
  }

  @override
  String trailsModeNextHint(String mode, String next) {
    return '$mode complete · the next mode is $next';
  }

  @override
  String trailsModeReplayHint(String cleared, String active) {
    return '$cleared complete · progress below is for $active mode';
  }

  @override
  String trailsModesCleared(String modes) {
    return '$modes complete';
  }

  @override
  String trailsRealmOpenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open',
      one: '1 open',
    );
    return '$_temp0';
  }

  @override
  String trailsRealmTrailCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trails',
      one: '1 trail',
    );
    return '$_temp0';
  }

  @override
  String trailsRealmTrailsDone(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done of $total trails',
      one: '$done of 1 trail',
    );
    return '$_temp0';
  }

  @override
  String trailsScenesOf(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done of $total scenes',
      one: '$done of 1 scene',
    );
    return '$_temp0';
  }

  @override
  String trailsScenesShort(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$done/$total scenes',
      one: '$done/1 scene',
    );
    return '$_temp0';
  }

  @override
  String trailsStage(String roman) {
    return 'Stage $roman';
  }

  @override
  String trailsStreakAtRisk(String countdown) {
    return 'Streak ends in $countdown';
  }

  @override
  String trailsTrailNumber(String roman) {
    return 'Trail $roman';
  }

  @override
  String get updateCheckDisabled => 'Update check is off.';

  @override
  String get updateCheckFailed => 'Couldn\'t check right now.';

  @override
  String get updateDefaultMessage =>
      'A new version of Stway is ready, with improvements and fixes.';

  @override
  String get updateEyebrow => 'Update';

  @override
  String get updateFirebaseUnavailable => 'Firebase unavailable.';

  @override
  String get updateForceTitle => 'This version needs an update';

  @override
  String get updateInStore => 'In the store';

  @override
  String get updateNoneInCloud => 'No version published in the cloud.';

  @override
  String get updateNow => 'Update now';

  @override
  String get updateSoftTitle => 'New version available';

  @override
  String get updateStoreOpenFailed => 'Couldn\'t open the store. Try again.';

  @override
  String get verseStudyAttribution =>
      'Lexicon and tagged text: STEPBible / Tyndale House Cambridge (CC BY 4.0). Cross-references: openbible.info (CC BY). Definitions machine-translated into Portuguese.';

  @override
  String get verseStudyCopied => 'Copied';

  @override
  String get verseStudyCrossRefs => 'Cross-references';

  @override
  String get verseStudyDefinition => 'Definition';

  @override
  String get verseStudyEmptyBody =>
      'The Strong\'s lexicon, the grammar and every place it appears in the Scriptures open here.';

  @override
  String get verseStudyEmptyTitle => 'Tap an original word';

  @override
  String get verseStudyEyebrow => 'Study';

  @override
  String get verseStudyFirst => 'first';

  @override
  String get verseStudyGoToText => 'Go to text';

  @override
  String get verseStudyInThisBook =>
      'In this book — the appearances near this verse.';

  @override
  String get verseStudyInThisVerse => 'In this verse';

  @override
  String get verseStudyLast => 'last';

  @override
  String get verseStudyLemma => 'Lemma';

  @override
  String get verseStudyLoadFailed => 'Couldn\'t load the study.';

  @override
  String get verseStudyLoading => 'Opening the lexicon…';

  @override
  String get verseStudyNeedsRestart =>
      'Close and reopen the app to load the study.';

  @override
  String get verseStudyNoCrossRefs =>
      'No catalogued connections for this verse.';

  @override
  String get verseStudyNoData => 'No original-language data for this verse.';

  @override
  String get verseStudyNoOtherHits => 'No other occurrences in this range.';

  @override
  String get verseStudyNotLiteral =>
      'The Tradução Brasileira doesn\'t render this form literally in this verse.';

  @override
  String verseStudyOccurrencesIn(String book) {
    return 'Occurrences in $book';
  }

  @override
  String get verseStudyOnlyHere => 'Only in this verse in the index.';

  @override
  String get verseStudyOtherBooks => 'In other books';

  @override
  String get verseStudyOtherBooksBody =>
      'The first appearance in each book where the word is most frequent.';

  @override
  String get verseStudyParticleNearby =>
      'This particle appears thousands of times. Below are the forms near this verse.';

  @override
  String verseStudyParticleNote(int count) {
    return 'Grammatical particle · $count forms in the canon. The meaning lies in the noun or verb it goes with.';
  }

  @override
  String verseStudySpan(int count, String first, String last) {
    return '$count places · from $first to $last';
  }

  @override
  String get verseStudyTabLinks => 'Links';

  @override
  String verseStudyTabLinksCount(int count) {
    return 'Links · $count';
  }

  @override
  String get verseStudyTabUses => 'Uses';

  @override
  String verseStudyTabUsesCount(int count) {
    return 'Uses · $count';
  }

  @override
  String get verseStudyTabWord => 'Word';

  @override
  String get verseStudyThisForm => 'This form';

  @override
  String get verseStudyVerseUnavailable =>
      'This verse isn\'t available in this translation.';

  @override
  String get waveCta => 'Wave';

  @override
  String get widgetBehindCaravan => 'Falling behind the caravan — walk today';

  @override
  String get widgetGoalDone => 'Goal complete';

  @override
  String widgetProgressScenes(int done, int goal) {
    String _temp0 = intl.Intl.pluralLogic(
      goal,
      locale: localeName,
      other: '$done/$goal scenes',
      one: '$done/1 scene',
    );
    return '$_temp0';
  }

  @override
  String widgetScenesLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scenes left today',
      one: '1 scene left today',
    );
    return '$_temp0';
  }

  @override
  String widgetTodayTitle(String title) {
    return 'Today: $title';
  }

  @override
  String widgetTomorrowTitle(String title) {
    return 'Tomorrow: $title';
  }

  @override
  String get widgetTrailWaitsTomorrow => 'The trail waits tomorrow';
}
