import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/difficulty.dart';
import '../models/user_intent.dart';
import '../services/app_update_service.dart';
import '../services/backend_service.dart';
import '../services/bible_service.dart';
import '../services/bible_study_service.dart';
import '../services/companion_service.dart';
import '../services/corner_service.dart';
import '../services/league_service.dart';
import '../services/medal_engagement_service.dart';
import '../services/moderation_service.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../utils/content_filter.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/trail_progress.dart';
import '../widgets/relic_panel.dart';
import '../widgets/app_report_sheet.dart';
import '../widgets/app_sheet.dart';
import '../widgets/shell_tab_scope.dart';
import '../utils/layout_utils.dart';
import '../widgets/act_feel.dart';
import '../widgets/app_update_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/coming_soon_trails_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/juntos_chrome.dart';
import '../widgets/appearance_selector.dart';
import '../widgets/language_flag.dart';
import '../widgets/language_selector.dart';
import '../widgets/intent_selector.dart';
import '../widgets/mode_selector.dart';
import '../widgets/reminder_prompt_sheet.dart';
import '../widgets/reset_progress_sheet.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/user_avatar.dart';
import 'login_screen.dart';
import 'paywall_screen.dart';
import 'onboarding_screen.dart';
import 'plus_lab_screen.dart';
import 'support_screen.dart';

const _genesisTrailSlug = 'genesis-1-11';

/// Abre ajustes como página empurrada (engrenagem no perfil).
void openSettings(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) {
        final progress = ctx.watch<ProgressService>();
        final mode = progress.settings.appearanceMode;
        final appearance = AppearanceStyle.resolve(mode);
        return Appearance(
          mode: mode,
          style: appearance,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: ImmersiveBackground(
              appearance: appearance,
              frameChild: false,
              child: SettingsScreen(
                onOpenProfile: () => Navigator.pop(ctx),
                topBar: TopBar(
                  inline: true,
                  immersive: true,
                  dark: appearance.onDark,
                  title: context.l10n.settingsTitle,
                  subtitle: context.l10n.settingsSubtitle,
                  leadingGlyph: CinematicGlyph.tune,
                  chromeAccent: appearance.chrome,
                  onBack: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class SettingsScreen extends StatefulWidget {
  final Widget? topBar;
  final VoidCallback? onOpenProfile;

  const SettingsScreen({super.key, this.topBar, this.onOpenProfile});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin, ShellTabFreezeMixin {
  final _nameController = TextEditingController();
  bool _nameDirty = false;
  List<String> _genesisMissionSlugs = const [];
  late final AnimationController _entrance;
  String? _versionLabel;
  bool _checkingUpdate = false;

  /// 0 = Preferências (o que se ajusta), 1 = Conta e sobre.
  int _tab = 0;
  final _scroll = ScrollController();
  final _sectionKeys = {
    for (final s in _SettingsSection.values) s: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: AppMotion.scene)
      ..forward();
    _loadGenesisMissions();
    _loadVersionLabel();
    _nameController.addListener(_onNameChanged);
  }

  Future<void> _loadVersionLabel() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _versionLabel = '${info.version} (${info.buildNumber})');
  }

  Future<void> _checkForUpdates() async {
    if (_checkingUpdate) return;
    setState(() => _checkingUpdate = true);
    try {
      final status = await AppUpdateService.check(ignoreSnooze: true);
      if (!mounted) return;
      setState(() => _versionLabel = status.localLabel);

      if (status.updateAvailable) {
        await showAppUpdateSheet(context, status);
        return;
      }

      if (!mounted) return;
      final msg = !status.remoteReachable
          ? status.message
          : context.l10n.settingsUpToDate(status.localLabel);
      showAppToastFor(
        context,
        message: msg,
        glyph: status.remoteReachable
            ? CinematicGlyph.check
            : CinematicGlyph.wrong,
        tone: status.remoteReachable ? AppToastTone.accent : AppToastTone.warn,
      );
    } finally {
      if (mounted) setState(() => _checkingUpdate = false);
    }
  }

  void _onNameChanged() {
    if (!mounted) return;
    final current = context.read<ProgressService>().userName;
    final dirty = _nameController.text.trim() != current;
    if (dirty != _nameDirty) setState(() => _nameDirty = dirty);
  }

  Future<void> _loadGenesisMissions() async {
    final trail = await TrailRepository().getTrailBySlug(_genesisTrailSlug);
    if (mounted) {
      setState(() => _genesisMissionSlugs = trail?.missionSlugs ?? const []);
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _scroll.dispose();
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  Widget _reveal(int index, Widget child) {
    // Mesma árvore antes e depois da entrada: devolver o filho sem o
    // wrapper no fim remontava o card inteiro (estado e animações dele).
    // drive() não prende listener no controller (CurvedAnimation prenderia
    // um por build).
    final start = (0.08 * index).clamp(0.0, 0.6);
    final end = (start + 0.36).clamp(0.0, 1.0);
    final curve = _entrance.drive(
      CurveTween(curve: Interval(start, end, curve: AppMotion.enter)),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: curve.drive(
          Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return freezeTab(() => _buildSettings(context));
  }

  Widget _buildSettings(BuildContext context) {
    final listen = tabListens;
    final progress = listen
        ? context.watch<ProgressService>()
        : context.read<ProgressService>();
    final sync = listen
        ? context.watch<SyncService>()
        : context.read<SyncService>();
    final a = Appearance.of(context);

    // Mantém o campo alinhado ao progresso (ex.: nome restaurado do Google),
    // sem sobrescrever enquanto o usuário edita.
    if (!_nameDirty && _nameController.text != progress.userName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _nameDirty) return;
        if (_nameController.text == progress.userName) return;
        _nameController.text = progress.userName;
        setState(() => _nameDirty = false);
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = contentGutterOf(constraints.maxWidth);
        final fixed = topBarStaysFixed(widget.topBar);
        final topInset = MediaQuery.viewPaddingOf(context).top + AppSpace.sm;
        final list = ListView(
          controller: _scroll,
          padding: EdgeInsets.fromLTRB(
            0,
            fixed
                ? AppSpace.afterTopBar
                : widget.topBar == null
                ? AppSpace.sm
                : topInset,
            0,
            scrollPaddingBelowNav(context),
          ),
          physics: const ClampingScrollPhysics(),
          children: [
            if (widget.topBar != null && !fixed) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.screen,
                ),
                child: widget.topBar!,
              ),
              const SizedBox(height: AppSpace.afterTopBar),
            ],
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpace.screen + gutter,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _reveal(0, _tabs()),
                  const SizedBox(height: AppSpace.lg),
                  ..._tab == 0
                      ? _preferencesTab(progress, a)
                      : _accountAboutTab(progress, sync, a),
                ],
              ),
            ),
          ],
        );
        if (!fixed) return list;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpace.screen,
                topInset,
                AppSpace.screen,
                0,
              ),
              child: widget.topBar!,
            ),
            Expanded(child: list),
          ],
        );
      },
    );
  }

  Widget _tabs() {
    return AppSegmentedTabs(
      index: _tab,
      onChanged: (i) {
        if (i == _tab) return;
        ActHaptics.tap();
        setState(() => _tab = i);
        // A outra aba começa do topo, não no meio do que se rolou aqui.
        if (_scroll.hasClients) _scroll.jumpTo(0);
      },
      items: [
        (
          label: context.l10n.settingsTabPreferences,
          glyph: CinematicGlyph.tune,
          mark: null,
          alert: false,
        ),
        (
          label: context.l10n.settingsTabAccountAbout,
          glyph: CinematicGlyph.shield,
          mark: null,
          alert: false,
        ),
      ],
    );
  }

  /// Preferências: como você estuda, em que ritmo, e o que se vê e ouve.
  List<Widget> _preferencesTab(ProgressService progress, AppearanceStyle a) {
    final mode = _currentStudyMode(progress);
    final intent = progress.settings.intent;
    return [
      // Sua jornada — ritmo, modo e motivo.
      _reveal(
        2,
        _groupedCard(
          a,
          title: context.l10n.settingsRhythmTitle,
          subtitle: context.l10n.settingsRhythmSubtitle,
          children: [
            _RhythmPath(progress: progress),
            const _SettingsDivider(),
            _fieldLabel(a, context.l10n.settingsStreakGoalLabel),
            const SizedBox(height: AppSpace.xs),
            _fieldHint(a, context.l10n.settingsStreakGoalHint),
            const SizedBox(height: AppSpace.md),
            _streakGoalPicker(progress),
            const _SettingsDivider(compact: true),
            _navRow(
              a,
              context.l10n.modeSheetEyebrow,
              mode.labelPt,
              glyph: DifficultyVisuals.glyphFor(mode),
              accent: DifficultyVisuals.accentFor(mode),
              onTap: () => showModeSheet(
                context,
                trailSlug: _genesisTrailSlug,
                trailTitle: context.l10n.settingsGenesisTitle,
                missionSlugs: _genesisMissionSlugs,
                tint: DifficultyVisuals.accentFor(mode),
              ),
            ),
            const _SettingsDivider(compact: true),
            _navRow(
              a,
              context.l10n.settingsIntentLabel,
              intent?.title ?? context.l10n.settingsIntentNone,
              glyph: intent?.glyph ?? CinematicGlyph.path,
              accent: intent?.accent,
              onTap: () => showIntentSheet(context, tint: intent?.accent),
            ),
          ],
        ),
      ),

      // Neste aparelho — o que se vê e o que se ouve.
      const SizedBox(height: AppSpace.xl),
      _reveal(
        3,
        KeyedSubtree(
          key: _sectionKeys[_SettingsSection.aparencia],
          child: _appearanceCard(progress, a),
        ),
      ),
      const SizedBox(height: AppSpace.md),
      _reveal(
        5,
        KeyedSubtree(
          key: _sectionKeys[_SettingsSection.lembretes],
          child: _remindersCard(progress, a),
        ),
      ),
    ];
  }

  /// Modo ativo da trilha de referência (Gênesis 1–11).
  TrailDifficulty _currentStudyMode(ProgressService progress) {
    final id =
        TrailProgress.resolvedDifficultyId(
          _genesisTrailSlug,
          progress.difficultyForTrail(_genesisTrailSlug),
        ) ??
        TrailDifficulty.semente.id;
    return TrailDifficulty.fromId(id) ?? TrailDifficulty.semente;
  }

  /// Conta e sobre: quem você é e seus dados; o que apaga, à parte; o
  /// Stway em poucas linhas, versão e termos no pé.
  List<Widget> _accountAboutTab(
    ProgressService progress,
    SyncService sync,
    AppearanceStyle a,
  ) {
    return [
      _reveal(1, _passportCard(progress, a)),
      const SizedBox(height: AppSpace.md),
      _reveal(
        2,
        KeyedSubtree(
          key: _sectionKeys[_SettingsSection.conta],
          child: _accountCard(a, sync),
        ),
      ),
      const SizedBox(height: AppSpace.md),
      _reveal(3, _dangerCard(a, progress)),
      const SizedBox(height: AppSpace.xl),
      _reveal(4, _aboutBlock(a)),
      _reveal(5, _footer(a)),
    ];
  }

  /// Lembrete e sons: só os interruptores. Ligar o lembrete abre a
  /// escolha do horário; com ele ligado, tocar na linha muda a hora.
  Widget _remindersCard(ProgressService progress, AppearanceStyle a) {
    final on = progress.settings.notifications;
    return _groupedCard(
      a,
      title: context.l10n.settingsRemindersTitle,
      children: [
        _toggle(
          a,
          context.l10n.settingsDailyReminder,
          on
              ? context.l10n.settingsReminderAt(progress.settings.reminderHour)
              : context.l10n.commonOff,
          on,
          (v) =>
              v ? _pickReminderHour(progress) : _setReminder(progress, false),
          onRowTap: on ? () => _pickReminderHour(progress) : null,
          glyph: CinematicGlyph.bell,
        ),
        const _SettingsDivider(compact: true),
        _toggle(
          a,
          context.l10n.settingsSounds,
          context.l10n.settingsSoundsSubtitle,
          progress.settings.sound,
          (v) {
            ActHaptics.tap();
            progress.updateSettings(progress.settings.copyWith(sound: v));
            SoundService.instance.setEnabled(v);
          },
          glyph: CinematicGlyph.echo,
        ),
      ],
    );
  }

  /// Idioma da interface. O conteúdo (trilhas, Bíblia) ainda é só pt-BR.
  Future<void> _pickReminderHour(ProgressService progress) async {
    ActHaptics.tap();
    final hour = await showReminderHourSheet(context);
    if (hour == null || !mounted) return;
    await progress.updateSettings(
      progress.settings.copyWith(reminderHour: hour),
    );
    await _setReminder(progress, true);
  }

  Future<void> _setReminder(ProgressService progress, bool enabled) async {
    await progress.markNotificationsPrompted(enabled: enabled);
    if (enabled) {
      await NotificationService.instance.requestOsPermission();
    }
    await NotificationService.instance.syncFromProgress(progress);
  }

  String _shortDate(DateTime dt) {
    final local = dt.toLocal();
    final tag = Localizations.localeOf(context).toLanguageTag();
    return '${DateFormat.yMd(tag).format(local)} · '
        '${DateFormat.Hm(tag).format(local)}';
  }

  Widget _fieldLabel(AppearanceStyle a, String title) {
    return Text(title, style: AppTypography.title(size: 14, color: a.text));
  }

  Widget _fieldHint(AppearanceStyle a, String text) {
    return Text(
      text,
      style: AppTypography.body(size: 12, height: 1.35, color: a.textSecondary),
    );
  }

  /// Escolhas do onboarding: 3 dias (quem veio criar sequência), 7 / 14 / 30.
  static const _streakGoals = [3, 7, 14, 30];

  Widget _streakGoalPicker(ProgressService progress) {
    final current = progress.settings.streakGoal;
    return _SegmentTrack(
      semanticsLabel: context.l10n.settingsStreakGoalLabel,
      items: [
        for (final days in _streakGoals)
          (
            label: context.l10n.settingsDays(days),
            mark: null,
            selected: current == days,
            onTap: () {
              if (current == days) return;
              ActHaptics.tap();
              progress.updateSettings(
                progress.settings.copyWith(streakGoal: days),
              );
            },
          ),
      ],
    );
  }

  void _saveName(ProgressService progress) {
    FocusScope.of(context).unfocus();
    if (!ContentFilter.isAllowed(_nameController.text)) {
      showAppToastFor(
        context,
        message: context.l10n.contentNameNotAllowed,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    progress.setUserName(_nameController.text);
    setState(() => _nameDirty = false);
    ActHaptics.light();
  }

  List<(double, String)> get _fontSteps => [
    (0.9, context.l10n.settingsFontSmall),
    (1.0, context.l10n.settingsFontMedium),
    (1.15, context.l10n.settingsFontLarge),
    (1.3, context.l10n.settingsFontExtra),
  ];

  /// Tema e idioma abrem os portais (mesma forma do modo e do motivo);
  /// o tamanho do texto muda direto no card.
  Widget _appearanceCard(ProgressService progress, AppearanceStyle a) {
    final mode = progress.settings.appearanceMode;
    final lang = progress.settings.language;
    return _groupedCard(
      a,
      title: context.l10n.settingsAppearanceTitle,
      children: [
        _navRow(
          a,
          context.l10n.settingsThemeLabel,
          '${mode.label} · ${mode.caption(context.l10n)}',
          glyph: mode.glyph,
          accent: mode.accent,
          onTap: () => showAppearanceSheet(context),
        ),
        const _SettingsDivider(compact: true),
        _navRow(
          a,
          context.l10n.languageTitle,
          lang.label(context.l10n),
          glyph: CinematicGlyph.flag,
          leading: SizedBox(
            width: AppMetrics.leadingIcon,
            child: Center(
              child: LanguageFlag.forAppLanguage(lang, width: 26, height: 18),
            ),
          ),
          onTap: () => showLanguageSheet(context),
        ),
        const _SettingsDivider(),
        _fieldLabel(a, context.l10n.settingsTextSize),
        const SizedBox(height: AppSpace.xs),
        _fieldHint(a, context.l10n.settingsTextSizeHint),
        const SizedBox(height: AppSpace.md),
        _fontScalePicker(progress),
        const SizedBox(height: AppSpace.md),
        const _FontPreview(),
      ],
    );
  }

  /// Sheet de escolha — o conteúdo reage ao progresso enquanto está aberta.
  Future<void> _openPickerSheet({
    required String eyebrow,
    required String title,
    required String subtitle,
    required CinematicGlyph glyph,
    required Widget Function(ProgressService progress) body,
  }) {
    ActHaptics.tap();
    return showAppSheet<void>(
      context,
      builder: (sheetContext) => AppSheetPanel(
        child: Builder(
          builder: (ctx) {
            final progress = ctx.watch<ProgressService>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSheetHeader(
                  eyebrow: eyebrow,
                  title: title,
                  subtitle: subtitle,
                ),
                const SizedBox(height: AppSpace.lg),
                body(progress),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Linha que abre uma escolha — rótulo, valor atual e seta.
  Widget _navRow(
    AppearanceStyle a,
    String label,
    String value, {
    required CinematicGlyph glyph,
    required VoidCallback? onTap,
    Color? accent,
    Color? labelColor,
    Widget? leading,
    Widget? trailing,
  }) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Row(
              children: [
                leading ??
                    CinematicIcon(
                      glyph: glyph,
                      size: AppMetrics.leadingIcon,
                      accent: accent ?? a.chrome,
                      glowing: false,
                    ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.title(
                          size: 14,
                          color: labelColor ?? a.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: AppTypography.body(
                          size: 12,
                          color: a.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ?? ListChevron(color: a.textFaint),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fontScalePicker(ProgressService progress) {
    final steps = _fontSteps;
    final current = progress.settings.fontScale;

    return _SegmentTrack(
      semanticsLabel: context.l10n.settingsTextSize,
      items: [
        for (final step in steps)
          (
            label: step.$2,
            mark: null,
            selected: (current - step.$1).abs() < 0.01,
            onTap: () {
              ActHaptics.tap();
              progress.updateSettings(
                progress.settings.copyWith(fontScale: step.$1),
              );
            },
          ),
      ],
    );
  }

  Widget _passportCard(ProgressService progress, AppearanceStyle a) {
    final backend = context.watch<BackendService>();
    final sub = context.watch<SubscriptionService>();
    final promoUntil = sub.isPeregrinoPlus ? null : sub.launchFreeUntil;
    final signedIn = backend.isSignedIn;
    return GlassCard(
      glow: 0.6,
      tint: a.chrome,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SectionLabel(context.l10n.settingsAccount),
              const Spacer(),
              SoftBadge(
                text: signedIn
                    ? context.l10n.settingsInCloud
                    : context.l10n.settingsDeviceOnly,
                glyph: signedIn ? CinematicGlyph.check : CinematicGlyph.wrong,
                accent: signedIn ? AppRoles.success : AppRoles.risk,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          _ProfileHeader(
            a: a,
            nameController: _nameController,
            nameDirty: _nameDirty,
            photoUrl: backend.userPhotoUrl,
            seed: backend.uid,
            portraitStyle: progress.settings.portraitStyle,
            signedIn: signedIn,
            email: signedIn
                ? (backend.userEmail ?? backend.userDisplayName)
                : null,
            lastSync: backend.isActive ? backend.lastCloudSaveAt : null,
            onOpenProfile: widget.onOpenProfile,
            onSaveName: () => _saveName(progress),
          ),
          // Sem loja configurada e sem promoção de lançamento, sem faixa.
          if (sub.showsPlus) ...[
            const SizedBox(height: AppSpace.lg),
            _PlusStrip(
              paid: sub.isPeregrinoPlus,
              paidLine: sub.isPeregrinoPlus
                  ? '${plusPlanLabel(context.l10n, sub)} · '
                        '${plusStatusLabel(context.l10n, sub)}'
                  : null,
              promoLine: promoUntil == null
                  ? null
                  : context.l10n.settingsPlusLaunchFree(
                      DateFormat(
                        'd MMM',
                        context.l10n.localeName,
                      ).format(promoUntil).replaceAll('.', ''),
                    ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (_) => const PaywallScreen()),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _signOutGoogle(BackendService backend) async {
    final ok = await backend.signOutGoogle();
    if (!mounted) return;
    if (!ok) {
      showAppToastFor(
        context,
        message: backend.lastError ?? context.l10n.settingsSignOutFailed,
        glyph: CinematicGlyph.wrong,
        tone: AppToastTone.warn,
      );
      return;
    }
    await context.read<SubscriptionService>().logOut();
    if (!mounted) return;
    await _leaveToLogin();
  }

  Future<void> _confirmDeleteAccount(BackendService backend) async {
    MedalEngagementService.instance.cancelPending();
    ScaffoldMessenger.of(context).clearSnackBars();
    final confirmed = await showDeleteAccountSheet(
      context,
      subscriptionNote: context.read<SubscriptionService>().isConfigured,
    );
    if (!confirmed || !mounted) return;

    final result = await backend.deleteAccount();
    if (!mounted) return;
    if (!result.ok) {
      // Sem erro = a pessoa fechou o login de confirmação.
      if (result.error != null) {
        showAppToastFor(
          context,
          message: result.error!,
          glyph: CinematicGlyph.wrong,
          tone: AppToastTone.warn,
        );
      }
      return;
    }
    // A pessoa lê o aviso antes de cair na tela de entrar.
    final done = context.l10n.deleteAccountDone;
    await context.read<SubscriptionService>().logOut();
    if (!mounted) return;
    await showAppToastFor(context, message: done);
    if (!mounted) return;
    await _leaveToLogin();
  }

  /// Volta à tela de entrar sem herdar nada da conta que saiu.
  Future<void> _leaveToLogin() async {
    final progress = context.read<ProgressService>();
    // O reset zera capítulos e dispara a checagem de medalhas.
    // Sem isso, a folha de conquista abre na tela de entrar.
    MedalEngagementService.instance.cancelPending();
    ScaffoldMessenger.of(context).clearSnackBars();
    await progress.resetMemoryToDefaults();
    if (!mounted) return;
    await context.read<LeagueService>().resetForLogout();
    // Limpa códigos locais de companhia/sala (evita herdar na próxima conta).
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('companionCodes');
    await prefs.remove('activeRoomCode');
    if (!mounted) return;
    context.read<CompanionService>().markCloudUnsynced();
    if (!mounted) return;
    context.read<CornerService>().markCloudUnsynced();
    if (!mounted) return;
    MedalEngagementService.instance.cancelPending();
    ScaffoldMessenger.of(context).clearSnackBars();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: AppMotion.gentle,
      ),
      (route) => false,
    );
  }

  Future<void> _exportProgress(
    ProgressService progress,
    SyncService sync,
  ) async {
    final league = context.read<LeagueService>();
    final json = sync.exportJson(progress, league: league);
    await SharePlus.instance.share(
      ShareParams(text: json, subject: context.l10n.settingsBackupSubject),
    );
    await sync.markSynced();
  }

  Future<void> _importProgress(
    ProgressService progress,
    SyncService sync,
  ) async {
    final backend = context.read<BackendService>();
    final league = context.read<LeagueService>();
    final data = await Clipboard.getData('text/plain');
    final text = data?.text;
    if (text == null || text.isEmpty) {
      if (mounted) {
        showAppToastFor(
          context,
          message: context.l10n.settingsPasteBackupFirst,
          glyph: CinematicGlyph.copy,
          tone: AppToastTone.warn,
        );
      }
      return;
    }
    final parsed = sync.parseImport(text);
    if (parsed == null) {
      if (mounted) {
        showAppToastFor(
          context,
          message: context.l10n.settingsBackupInvalid,
          glyph: CinematicGlyph.wrong,
          tone: AppToastTone.warn,
        );
      }
      return;
    }
    await progress.applyFromCloud(parsed);
    await league.applyFromCloud(parsed);
    progress.bindCacheUid(backend.uid);
    progress.markCloudHydrated();
    await backend.saveNow(progress, LeagueService.weekKey(), league: league);
    await sync.markSynced();
    if (mounted) {
      showAppToastFor(context, message: context.l10n.settingsProgressRestored);
    }
  }

  Widget _toggle(
    AppearanceStyle a,
    String label,
    String desc,
    bool value,
    ValueChanged<bool> onChanged, {
    CinematicGlyph glyph = CinematicGlyph.spark,
    VoidCallback? onRowTap,
  }) {
    // Linha inteira alterna o switch (ou abre [onRowTap]); leitor de tela lê
    // rótulo + estado juntos.
    return MergeSemantics(
      child: InkWell(
        onTap: onRowTap ?? () => onChanged(!value),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 52),
          child: Row(
            children: [
              CinematicIcon(
                glyph: glyph,
                size: AppMetrics.leadingIcon,
                accent: value ? a.chrome : a.textFaint,
                glowing: false,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTypography.title(size: 14, color: a.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: AppTypography.body(
                        size: 12,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _SettingsSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }

  /// Título do card — traço neutro, como nos cards do perfil.
  Widget _cardTitle(String title) {
    return Semantics(
      header: true,
      child: RelicChapter(title: title, divided: false),
    );
  }

  Widget _groupedCard(
    AppearanceStyle a, {
    required String title,
    required List<Widget> children,
    String? subtitle,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardTitle(title),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              subtitle,
              style: AppTypography.body(
                size: 13,
                height: 1.4,
                color: a.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpace.lg),
          ...children,
        ],
      ),
    );
  }

  Future<void> _confirmResetProgress(ProgressService progress) async {
    // A folha de conquista usa o navigator da raiz. Cancela antes do
    // reset para ela não abrir por cima dos ajustes.
    MedalEngagementService.instance.cancelPending();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();

    final confirmed = await showResetProgressSheet(context);
    if (!confirmed || !mounted) return;

    MedalEngagementService.instance.cancelPending();
    ScaffoldMessenger.of(context).clearSnackBars();

    final backend = context.read<BackendService>();
    final league = context.read<LeagueService>();
    await progress.resetProgress();
    // O reset notifica a casca e reagendaria a checagem da medalha.
    MedalEngagementService.instance.cancelPending();
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    await backend.saveNow(progress, LeagueService.weekKey(), league: league);
    if (!mounted) return;
    MedalEngagementService.instance.cancelPending();
    ScaffoldMessenger.of(context).clearSnackBars();
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
      (_) => false,
    );
  }

  /// Backup, bloqueios e sair — o que se usa no dia a dia. Sair não apaga
  /// nada (o progresso fica na nuvem), então não leva vermelho.
  Widget _accountCard(AppearanceStyle a, SyncService sync) {
    final backend = context.watch<BackendService>();
    final last = sync.lastSyncAt;
    return _groupedCard(
      a,
      title: context.l10n.settingsAccount,
      children: [
        _navRow(
          a,
          context.l10n.settingsManualBackup,
          last == null
              ? context.l10n.settingsManualBackupSubtitle
              : context.l10n.settingsLastShort(_shortDate(last)),
          glyph: CinematicGlyph.share,
          onTap: () => _openBackupSheet(sync),
        ),
        if (backend.isSignedIn) ...[
          const _SettingsDivider(compact: true),
          _navRow(
            a,
            context.l10n.settingsBlockedPeople,
            context.l10n.settingsBlockedPeopleSubtitle(
              context.watch<ModerationService>().blocked.length,
            ),
            glyph: CinematicGlyph.lock,
            onTap: _openBlockedSheet,
          ),
          const _SettingsDivider(compact: true),
          _navRow(
            a,
            context.l10n.settingsSignOut,
            context.l10n.settingsSignOutSubtitle,
            glyph: CinematicGlyph.back,
            onTap: backend.isGoogleBusy ? null : () => _signOutGoogle(backend),
          ),
        ],
      ],
    );
  }

  /// O que apaga de vez — card próprio, em vermelho e sempre com
  /// confirmação, longe das linhas do dia a dia.
  Widget _dangerCard(AppearanceStyle a, ProgressService progress) {
    final backend = context.watch<BackendService>();
    return _groupedCard(
      a,
      title: context.l10n.settingsDangerTitle,
      subtitle: context.l10n.settingsDangerSubtitle,
      children: [
        _navRow(
          a,
          context.l10n.settingsDeleteProgress,
          context.l10n.settingsDeleteProgressSubtitle,
          glyph: CinematicGlyph.fall,
          accent: AppRoles.risk,
          labelColor: AppRoles.risk,
          onTap: () => _confirmResetProgress(progress),
        ),
        if (backend.isSignedIn) ...[
          const _SettingsDivider(compact: true),
          _navRow(
            a,
            context.l10n.settingsDeleteAccount,
            context.l10n.settingsDeleteAccountSubtitle,
            glyph: CinematicGlyph.close,
            accent: AppRoles.risk,
            labelColor: AppRoles.risk,
            onTap: backend.isGoogleBusy
                ? null
                : () => _confirmDeleteAccount(backend),
          ),
        ],
      ],
    );
  }

  /// Quem eu bloqueei, com desbloquear ao lado de cada nome.
  Future<void> _openBlockedSheet() {
    return _openPickerSheet(
      eyebrow: context.l10n.settingsAccount,
      title: context.l10n.settingsBlockedPeople,
      subtitle: context.l10n.moderationReportHint,
      glyph: CinematicGlyph.lock,
      body: (_) => Builder(
        builder: (ctx) {
          final a = Appearance.of(ctx);
          final moderation = ctx.watch<ModerationService>();
          final people = moderation.blocked.entries.toList()
            ..sort(
              (x, y) => x.value.toLowerCase().compareTo(y.value.toLowerCase()),
            );
          if (people.isEmpty) {
            return Text(
              ctx.l10n.settingsBlockedEmpty,
              textAlign: TextAlign.center,
              style: AppTypography.body(size: 14, color: a.textSecondary),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final person in people)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.sm),
                  child: Row(
                    children: [
                      UserAvatar(
                        name: person.value,
                        seed: person.key,
                        style: PortraitStyle.letter,
                        radius: AppMetrics.avatarSm,
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Text(
                          person.value.isEmpty
                              ? ctx.l10n.moderationUnknownName
                              : person.value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 14,
                            weight: FontWeight.w700,
                            color: a.text,
                          ),
                        ),
                      ),
                      TextCta(
                        label: ctx.l10n.moderationUnblock,
                        onTap: () => moderation.unblock(person.key),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openBackupSheet(SyncService sync) {
    return _openPickerSheet(
      eyebrow: context.l10n.settingsAccount,
      title: context.l10n.settingsManualBackup,
      subtitle: context.l10n.settingsBackupSheetBody,
      glyph: CinematicGlyph.share,
      body: (p) => Builder(
        builder: (ctx) {
          final a = Appearance.of(ctx);
          final s = ctx.watch<SyncService>();
          final meta = [
            if (s.lastSyncAt != null)
              context.l10n.settingsLastBackup(_shortDate(s.lastSyncAt!)),
            if (s.deviceId != null) context.l10n.settingsDeviceId(s.deviceId!),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              CopperCta(
                label: context.l10n.settingsExport,
                leading: CinematicGlyph.share,
                trailing: null,
                showGlow: false,
                onTap: () => _exportProgress(p, sync),
              ),
              const SizedBox(height: AppSpace.sm),
              GhostCta(
                label: context.l10n.settingsRestoreFromClipboard,
                leading: CinematicGlyph.copy,
                expanded: true,
                onTap: () => _importProgress(p, sync),
              ),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: AppSpace.md),
                for (final line in meta)
                  Text(
                    line,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      size: 11,
                      weight: FontWeight.w600,
                      color: a.textFaint,
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _openCreditsSheet(List<String> credits) {
    return _openPickerSheet(
      eyebrow: context.l10n.settingsAbout,
      title: context.l10n.settingsCreditsTitle,
      subtitle: context.l10n.settingsCreditsSubtitle,
      glyph: CinematicGlyph.scroll,
      body: (_) => Builder(
        builder: (ctx) {
          final a = Appearance.of(ctx);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final line in credits)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.sm),
                  child: Text(
                    line,
                    style: AppTypography.body(
                      size: 13,
                      height: 1.4,
                      color: a.textSecondary,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Sobre: conhecer o Stway, rever a introdução e créditos; doação no fim.
  /// Versão e termos ficam no rodapé ([_footer]).
  Widget _aboutBlock(AppearanceStyle a) {
    final credits = [
      for (final t in BibleService.catalog.where((t) => t.available))
        if (t.attribution != null) '${t.shortName} — ${t.attribution}',
      context.l10n.settingsStudyAttribution(BibleStudyService.attribution),
    ];
    return _groupedCard(
      a,
      title: context.l10n.settingsAboutTitle,
      subtitle: context.l10n.settingsAboutSubtitle,
      children: [
        _navRow(
          a,
          context.l10n.settingsAboutPage,
          context.l10n.settingsAboutPageSubtitle,
          glyph: CinematicGlyph.path,
          onTap: openAboutPage,
        ),
        const _SettingsDivider(compact: true),
        _navRow(
          a,
          context.l10n.settingsReplayIntro,
          context.l10n.settingsReplayIntroSubtitle,
          glyph: CinematicGlyph.scroll,
          onTap: () async {
            if (!mounted) return;
            await Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
              (_) => false,
            );
          },
        ),
        const _SettingsDivider(compact: true),
        _navRow(
          a,
          context.l10n.settingsCreditsTitle,
          context.l10n.settingsCreditsRowSubtitle,
          glyph: CinematicGlyph.book,
          onTap: () => _openCreditsSheet(credits),
        ),
        const _SettingsDivider(compact: true),
        _navRow(
          a,
          context.l10n.settingsReportProblem,
          context.l10n.settingsReportProblemSubtitle,
          glyph: CinematicGlyph.flag,
          onTap: () => showAppReportSheet(context),
        ),
        if (kDebugMode) ...[
          const _SettingsDivider(compact: true),
          _navRow(
            a,
            'Laboratório Peregrino+',
            'Só em desenvolvimento',
            glyph: CinematicGlyph.tune,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PlusLabScreen()),
            ),
          ),
        ],
        // Apoio só por compra no app; sem loja, o botão some.
        if (context.watch<SubscriptionService>().supportConfigured) ...[
          const SizedBox(height: AppSpace.lg),
          CopperCta(
            label: context.l10n.settingsSupport,
            leading: CinematicGlyph.gift,
            trailing: null,
            dense: true,
            showGlow: false,
            onTap: () => openSupport(context),
          ),
        ],
      ],
    );
  }

  /// Rodapé: termos e privacidade como links; a versão embaixo, e tocar
  /// nela procura atualização.
  Widget _footer(AppearanceStyle a) {
    final l10n = context.l10n;
    final linkStyle = AppTypography.body(
      size: 12,
      weight: FontWeight.w700,
      color: a.textSecondary,
    );
    final versionLine = _checkingUpdate
        ? l10n.settingsCheckingUpdate
        : '${l10n.settingsVersion} ${_versionLabel ?? '…'} · ${l10n.settingsCheck}';
    Widget link(String label, VoidCallback? onTap) => Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
            child: Center(widthFactor: 1, child: Text(label, style: linkStyle)),
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.lg, bottom: AppSpace.sm),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              link(l10n.legalTerms, () => openSitePage(termsPageUrl)),
              Text('·', style: linkStyle.copyWith(color: a.textFaint)),
              link(l10n.legalPrivacy, () => openSitePage(privacyPageUrl)),
            ],
          ),
          link(versionLine, _checkingUpdate ? null : _checkForUpdates),
        ],
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  final bool compact;

  const _SettingsDivider({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? AppSpace.xs : AppSpace.lg,
      ),
      child: const ListDivider(),
    );
  }
}

/// Seções dos ajustes — âncoras de rolagem. Sem cor própria: os cards são
/// neutros, cada um com seu título; o espaço maior entre blocos agrupa.
enum _SettingsSection { jornada, aparencia, lembretes, conta }

/// Interruptor dos ajustes — "ligado" é estado ([AppRoles.success]), não a
/// ação principal; o mesmo tom em todas as linhas.
class _SettingsSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Switch.adaptive(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppRoles.selected,
      activeTrackColor: AppRoles.success,
      inactiveThumbColor: a.textSecondary,
      inactiveTrackColor: a.insetFill,
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppRoles.success
            : a.cardBorder,
      ),
    );
  }
}

/// Faixa Peregrino+ dentro do passaporte. Sempre com a identidade do Plus
/// (coroa e rótulo dourados) e o estado escrito: sem assinatura traz o
/// botão "Assinar"; na promoção, "Grátis"; assinante, "Ativo" + o plano.
class _PlusStrip extends StatelessWidget {
  final bool paid;

  /// Linha da promoção de lançamento ("Grátis no lançamento até…").
  final String? promoLine;

  /// Assinante: "Anual · Renova em…".
  final String? paidLine;
  final VoidCallback onTap;

  const _PlusStrip({
    required this.paid,
    required this.onTap,
    this.promoLine,
    this.paidLine,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final promo = !paid && promoLine != null;
    final offer = !paid && !promo;
    final line = paid
        ? paidLine ?? l10n.settingsSubscriptionActive
        : promo
        ? promoLine!
        : l10n.settingsPlusTeaser;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            color: AppMetrics.accentFill(alpha: paid ? 0.14 : 0.08),
            border: Border.all(
              color: AppMetrics.accentBorder(alpha: paid ? 0.7 : 0.45),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyph.plus,
                    size: AppMetrics.iconLg,
                    accent: AppRoles.reward,
                    glowing: paid,
                    framed: false,
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionLabel('Peregrino+', color: AppRoles.reward),
                        const SizedBox(height: 2),
                        Text(
                          line,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.body(
                            size: 13,
                            weight: FontWeight.w700,
                            color: a.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  if (paid)
                    SoftBadge(
                      text: l10n.commonActive,
                      glyph: CinematicGlyph.check,
                      solid: true,
                    )
                  else if (promo)
                    SoftBadge(
                      text: l10n.settingsPlusFreeBadge,
                      accent: AppRoles.reward,
                    )
                  else
                    ListChevron(color: a.textFaint),
                ],
              ),
              if (offer) ...[
                const SizedBox(height: AppSpace.md),
                CopperCta(
                  label: l10n.settingsPlusSubscribe,
                  leading: CinematicGlyph.plus,
                  dense: true,
                  expanded: true,
                  onTap: onTap,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Amostra viva do tamanho do texto — a escala global do app já a aumenta.
class _FontPreview extends StatelessWidget {
  const _FontPreview();

  @override
  Widget build(BuildContext context) {
    return InsetPanel(
      child: Text(
        context.l10n.settingsSampleVerse,
        textAlign: TextAlign.center,
        style: AppTypography.verse(
          size: 18,
          height: 1.4,
          color: Appearance.of(context).text,
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppearanceStyle a;
  final TextEditingController nameController;
  final bool nameDirty;
  final String? photoUrl;
  final String? seed;
  final PortraitStyle portraitStyle;
  final bool signedIn;
  final String? email;
  final DateTime? lastSync;
  final VoidCallback? onOpenProfile;
  final VoidCallback onSaveName;

  const _ProfileHeader({
    required this.a,
    required this.nameController,
    required this.nameDirty,
    required this.onSaveName,
    required this.portraitStyle,
    required this.signedIn,
    this.email,
    this.lastSync,
    this.onOpenProfile,
    this.photoUrl,
    this.seed,
  });

  String _whisperDate(BuildContext context, DateTime dt) {
    final local = dt.toLocal();
    final tag = Localizations.localeOf(context).toLanguageTag();
    return '${DateFormat.Md(tag).format(local)} · '
        '${DateFormat.Hm(tag).format(local)}';
  }

  @override
  Widget build(BuildContext context) {
    final name = nameController.text;
    final caption = signedIn
        ? (email?.trim().isNotEmpty == true
              ? context.l10n.settingsSignedInAs(email!)
              : context.l10n.settingsProgressInCloud)
        : context.l10n.settingsSignInAgain;
    final syncLine = lastSync == null
        ? null
        : context.l10n.settingsSavedInCloud(_whisperDate(context, lastSync!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JuntosHalo(
              size: AppMetrics.avatarLg * 2,
              lit: signedIn,
              color: AppRoles.presence,
              child: UserAvatar(
                name: name,
                photoUrl: photoUrl,
                seed: seed,
                style: portraitStyle,
                radius: AppMetrics.avatarLg,
                borderColor: AppMetrics.accentBorder(
                  color: a.chrome,
                  alpha: 0.6,
                ),
                onTap: onOpenProfile,
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameController,
                    maxLength: 24,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onSaveName(),
                    cursorColor: a.text,
                    style: AppTypography.display(
                      size: 20,
                      weight: FontWeight.w800,
                      color: a.text,
                      height: 1.1,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      // Sem o lápis o nome parecia texto fixo.
                      suffixIcon: nameDirty
                          ? null
                          : CinematicIcon(
                              glyph: CinematicGlyph.pencil,
                              size: AppMetrics.iconSm,
                              accent: a.textFaint,
                              framed: false,
                            ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      hintText: context.l10n.settingsYourName,
                      hintStyle: AppTypography.display(
                        size: 20,
                        weight: FontWeight.w800,
                        color: a.textFaint,
                        height: 1.1,
                      ),
                      isDense: true,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                  if (nameDirty)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpace.xs,
                        bottom: AppSpace.xs,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CopperCta(
                          label: context.l10n.settingsSaveName,
                          dense: true,
                          expanded: false,
                          trailing: CinematicGlyph.check,
                          showGlow: false,
                          onTap: onSaveName,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(size: 12, color: a.textSecondary),
                  ),
                  if (syncLine != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      syncLine,
                      style: AppTypography.body(size: 11, color: a.textFaint),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Escolha em trilho — o segmentado único do app ([AppSegmentedTabs]).
class _SegmentTrack extends StatelessWidget {
  final List<({String label, Widget? mark, bool selected, VoidCallback onTap})>
  items;
  final String? semanticsLabel;

  const _SegmentTrack({required this.items, this.semanticsLabel});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: semanticsLabel,
      child: AppSegmentedTabs(
        index: items.indexWhere((i) => i.selected),
        accent: AppRoles.presence,
        onChanged: (i) => items[i].onTap(),
        items: [
          for (final item in items)
            (label: item.label, glyph: null, mark: item.mark, alert: false),
        ],
      ),
    );
  }
}

class _RhythmPath extends StatelessWidget {
  final ProgressService progress;

  const _RhythmPath({required this.progress});

  static const _options = <({int steps, String time})>[
    (steps: 1, time: '~3 min'),
    (steps: 2, time: '~6 min'),
    (steps: 3, time: '~9 min'),
  ];

  static String _paceLabel(AppLocalizations l10n, int steps) => switch (steps) {
    1 => l10n.settingsPaceLight,
    2 => l10n.settingsPaceSteady,
    _ => l10n.settingsPaceIntense,
  };

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final goal = progress.settings.dailyGoal;
    final selectedIndex = _options.indexWhere((o) => o.steps == goal);

    final litIndex = selectedIndex < 0 ? 0 : selectedIndex;

    return Column(
      children: [
        SizedBox(
          height: 44,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final start = w / 6;
              final span = w * 2 / 3;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: start,
                    width: span,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        color: a.progressTrack,
                      ),
                    ),
                  ),
                  Positioned(
                    left: start,
                    width: span * (litIndex / (_options.length - 1)),
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        color: a.selected.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (final option in _options)
                        Expanded(
                          child: Center(
                            child: _RhythmNode(
                              steps: option.steps,
                              selected: goal == option.steps,
                              onTap: () {
                                ActHaptics.tap();
                                progress.updateSettings(
                                  progress.settings.copyWith(
                                    dailyGoal: option.steps,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final option in _options)
              Expanded(
                // O nó acima já anuncia a escolha ao leitor de tela.
                child: ExcludeSemantics(
                  child: GestureDetector(
                    onTap: () {
                      ActHaptics.tap();
                      progress.updateSettings(
                        progress.settings.copyWith(dailyGoal: option.steps),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: _RhythmCaption(
                      steps: option.steps,
                      pace: _paceLabel(context.l10n, option.steps),
                      time: option.time,
                      selected: goal == option.steps,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _RhythmNode extends StatelessWidget {
  final int steps;
  final bool selected;
  final VoidCallback onTap;

  const _RhythmNode({
    required this.steps,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: context.l10n.settingsScenesPerDay(steps),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        // Alvo de toque ≥ 44 mesmo com o nó pequeno.
        child: SizedBox(width: 52, height: 44, child: Center(child: _dot(a))),
      ),
    );
  }

  Widget _dot(AppearanceStyle a) {
    return AnimatedContainer(
      duration: AppMotion.standard,
      curve: AppMotion.enter,
      width: selected ? 40 : 32,
      height: selected ? 40 : 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? a.selected : a.cardFill,
        border: Border.all(
          color: selected ? a.selected : a.cardBorder,
          width: selected ? 2 : 1.4,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Text(
        '$steps',
        style: AppTypography.title(
          size: selected ? 18 : 14,
          weight: FontWeight.w900,
          color: selected ? a.onSelected : a.text,
        ),
      ),
    );
  }
}

class _RhythmCaption extends StatelessWidget {
  final int steps;
  final String pace;
  final String time;
  final bool selected;

  const _RhythmCaption({
    required this.steps,
    required this.pace,
    required this.time,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final label = context.l10n.settingsScenes(steps);
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.title(
            size: 12,
            color: selected ? a.selected : a.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$pace · $time',
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.body(
            size: 11,
            color: selected ? a.textSecondary : a.textFaint,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: AppMotion.standard,
          height: 2,
          width: selected ? 28 : 0,
          decoration: BoxDecoration(
            color: a.selected,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
        ),
      ],
    );
  }
}
