import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/trail_repository.dart';
import '../services/app_update_service.dart';
import '../services/backend_service.dart';
import '../services/bible_service.dart';
import '../services/bible_study_service.dart';
import '../services/companion_service.dart';
import '../services/corner_service.dart';
import '../services/league_service.dart';
import '../services/medal_engagement_service.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../widgets/relic_panel.dart';
import '../widgets/app_sheet.dart';
import '../utils/layout_utils.dart';
import '../widgets/act_feel.dart';
import '../widgets/app_update_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/coming_soon_trails_card.dart';
import '../widgets/immersive_background.dart';
import '../widgets/juntos_chrome.dart';
import '../widgets/mode_selector.dart';
import '../widgets/reminder_prompt_sheet.dart';
import '../widgets/reset_progress_sheet.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/user_avatar.dart';
import 'login_screen.dart';
import 'paywall_screen.dart';
import 'onboarding_screen.dart';

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
              child: SettingsScreen(
                onOpenProfile: () => Navigator.pop(ctx),
                topBar: TopBar(
                  inline: true,
                  immersive: true,
                  dark: appearance.onDark,
                  title: 'Ajustes',
                  subtitle: 'Como você caminha',
                  leadingGlyph: CinematicGlyph.tune,
                  chromeAccent: AppColors.slate,
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
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  bool _nameDirty = false;
  List<String> _genesisMissionSlugs = const [];
  late final AnimationController _entrance;
  String? _versionLabel;
  bool _checkingUpdate = false;
  final _sectionKeys = {
    for (final s in _SettingsSection.values) s: GlobalKey(),
  };

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
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
          : 'Você está na versão mais recente · ${status.localLabel}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: AppTypography.body(size: 13, color: Colors.white),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
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
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    super.dispose();
  }

  Widget _reveal(int index, Widget child) {
    if (_entrance.isCompleted) return child;
    final start = (0.08 * index).clamp(0.0, 0.6);
    final end = (start + 0.36).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    final sync = context.watch<SyncService>();
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

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpace.screen,
        widget.topBar == null
            ? AppSpace.sm
            : MediaQuery.viewPaddingOf(context).top + AppSpace.sm,
        AppSpace.screen,
        scrollPaddingBelowNav(context),
      ),
      physics: const ClampingScrollPhysics(),
      children: [
        if (widget.topBar != null) ...[
          widget.topBar!,
          const SizedBox(height: AppSpace.afterTopBar),
        ],

        _reveal(0, _passportCard(progress, a)),

        // Sua jornada — como você estuda e em que ritmo.
        _reveal(1, _groupLabel(a, 'Sua jornada')),
        _reveal(2, _studyModeCard(progress, a)),
        const SizedBox(height: AppSpace.md),
        _reveal(
          3,
          _groupedCard(
            a,
            title: 'Ritmo diário',
            subtitle: 'Quantas cenas cabem no seu dia.',
            tint: _SettingsSection.jornada.tint,
            children: [
              _RhythmPath(progress: progress),
              const _SettingsDivider(),
              _fieldLabel(a, 'Compromisso de sequência'),
              const SizedBox(height: AppSpace.xs),
              _fieldHint(a, 'Até quantos dias você quer levar sua sequência.'),
              const SizedBox(height: AppSpace.md),
              _streakGoalPicker(progress),
            ],
          ),
        ),

        // Neste aparelho — o que se vê e o que se ouve.
        _reveal(4, _groupLabel(a, 'Neste aparelho')),
        _reveal(
          5,
          KeyedSubtree(
            key: _sectionKeys[_SettingsSection.aparencia],
            child: _appearanceCard(progress, a),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        _reveal(
          6,
          KeyedSubtree(
            key: _sectionKeys[_SettingsSection.lembretes],
            child: _remindersCard(progress, a),
          ),
        ),

        // Conta e dados — backup, sair e resetar num lugar só.
        _reveal(7, _groupLabel(a, 'Conta e dados')),
        _reveal(
          8,
          KeyedSubtree(
            key: _sectionKeys[_SettingsSection.conta],
            child: _accountCard(a, sync, progress),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        _reveal(9, _aboutBlock(a)),
        const SizedBox(height: AppSpace.sm),
      ],
    );
  }

  /// Lembrete e sons: só os interruptores. Ligar o lembrete abre a
  /// escolha do horário; com ele ligado, tocar na linha muda a hora.
  Widget _remindersCard(ProgressService progress, AppearanceStyle a) {
    final tint = _SettingsSection.lembretes.tint;
    final on = progress.settings.notifications;
    return _groupedCard(
      a,
      title: 'Lembretes',
      tint: tint,
      children: [
        _toggle(
          a,
          'Lembrete diário',
          on
              ? 'Às ${progress.settings.reminderHour}h · toque para mudar'
              : 'Desligado',
          on,
          (v) =>
              v ? _pickReminderHour(progress) : _setReminder(progress, false),
          onRowTap: on ? () => _pickReminderHour(progress) : null,
          glyph: CinematicGlyph.bell,
          accent: tint,
        ),
        const _SettingsDivider(compact: true),
        _toggle(
          a,
          'Sons',
          'Efeitos nas cenas',
          progress.settings.sound,
          (v) {
            ActHaptics.tap();
            progress.updateSettings(progress.settings.copyWith(sound: v));
            SoundService.instance.setEnabled(v);
          },
          glyph: CinematicGlyph.echo,
          accent: AppColors.accent,
        ),
      ],
    );
  }

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
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d/$m/${local.year} · $h:$min';
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

  /// Mesmas escolhas do onboarding: 7 / 14 / 30 dias.
  static const _streakGoals = [7, 14, 30];

  Widget _streakGoalPicker(ProgressService progress) {
    final current = progress.settings.streakGoal;
    return _SegmentTrack(
      semanticsLabel: 'Compromisso de sequência',
      items: [
        for (final days in _streakGoals)
          (
            label: '$days dias',
            caption: null,
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
    progress.setUserName(_nameController.text);
    setState(() => _nameDirty = false);
    ActHaptics.light();
  }

  static const _fontSteps = <(double, String)>[
    (0.9, 'Pequeno'),
    (1.0, 'Médio'),
    (1.15, 'Grande'),
    (1.3, 'Extra'),
  ];

  /// Modo de estudo: o mesmo banner do mapa da trilha ([ModeBanner]).
  Widget _studyModeCard(ProgressService progress, AppearanceStyle a) {
    return ModeBanner(
      trailSlug: _genesisTrailSlug,
      trailTitle: 'Gênesis 1–11 · o primeiro caminho',
      missionSlugs: _genesisMissionSlugs,
    );
  }

  /// Céu e tamanho do texto direto no card — muda e já se vê, sem sheet.
  Widget _appearanceCard(ProgressService progress, AppearanceStyle a) {
    final tint = _SettingsSection.aparencia.tint;
    return _groupedCard(
      a,
      title: 'Aparência',
      tint: tint,
      children: [
        _fieldLabel(a, 'Céu'),
        const SizedBox(height: AppSpace.xs),
        _fieldHint(a, 'Um céu fixo, ou deixe seguir o horário do dia.'),
        const SizedBox(height: AppSpace.md),
        _skyPicker(progress),
        const _SettingsDivider(),
        _fieldLabel(a, 'Tamanho do texto'),
        const SizedBox(height: AppSpace.xs),
        _fieldHint(a, 'O versículo abaixo muda junto.'),
        const SizedBox(height: AppSpace.md),
        _fontScalePicker(progress),
        const SizedBox(height: AppSpace.md),
        const _FontPreview(),
      ],
    );
  }

  /// Rótulo de grupo entre cards — organiza a tela em quatro blocos.
  Widget _groupLabel(AppearanceStyle a, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, AppSpace.xl, 4, AppSpace.sm),
      child: Semantics(
        header: true,
        child: SectionLabel(text, color: a.textFaint),
      ),
    );
  }

  /// Sheet de escolha — o conteúdo reage ao progresso enquanto está aberta.
  Future<void> _openPickerSheet({
    required String eyebrow,
    required String title,
    required String subtitle,
    required CinematicGlyph glyph,
    required Color tint,
    required Widget Function(ProgressService progress) body,
  }) {
    ActHaptics.tap();
    return showAppSheet<void>(
      context,
      builder: (sheetContext) => AppSheetPanel(
        tint: tint,
        child: Builder(
          builder: (ctx) {
            final progress = ctx.watch<ProgressService>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSheetHeader(
                  leading: CinematicIcon(
                    glyph: glyph,
                    size: 40,
                    accent: tint,
                    glowing: false,
                  ),
                  eyebrow: eyebrow,
                  eyebrowColor: tint,
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
    required Color accent,
    required VoidCallback? onTap,
    Color? labelColor,
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
                CinematicIcon(
                  glyph: glyph,
                  size: AppMetrics.leadingIcon,
                  accent: accent,
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
                trailing ??
                    CinematicIcon(
                      glyph: CinematicGlyph.chevron,
                      size: 14,
                      accent: a.textFaint,
                      framed: false,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fontScalePicker(ProgressService progress) {
    const steps = _fontSteps;
    final current = progress.settings.fontScale;

    return _SegmentTrack(
      semanticsLabel: 'Tamanho do texto',
      items: [
        for (final step in steps)
          (
            label: step.$2,
            caption: null,
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

  Widget _skyPicker(ProgressService progress) {
    final selected = progress.settings.appearanceMode;
    return _SkySwitch(
      selected: selected,
      onChanged: (mode) {
        if (mode == selected) return;
        progress.updateSettings(
          progress.settings.copyWith(appearanceMode: mode),
        );
      },
    );
  }

  Widget _passportCard(ProgressService progress, AppearanceStyle a) {
    final backend = context.watch<BackendService>();
    final plus = context.watch<SubscriptionService>().isPeregrinoPlus;
    final signedIn = backend.isSignedIn;
    return GlassCard(
      glow: 0.6,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const SectionLabel('Peregrino', color: AppColors.accent),
              const Spacer(),
              SoftBadge(
                text: signedIn ? 'Na nuvem' : 'Só neste aparelho',
                glyph: signedIn ? CinematicGlyph.check : CinematicGlyph.wrong,
                accent: signedIn ? AppColors.teal : AppColors.coral,
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
          const SizedBox(height: AppSpace.lg),
          _PlusStrip(
            plus: plus,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const PaywallScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOutGoogle(BackendService backend) async {
    final progress = context.read<ProgressService>();
    final ok = await backend.signOutGoogle();
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(backend.lastError ?? 'Não foi possível sair')),
      );
      return;
    }
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
        transitionDuration: const Duration(milliseconds: 400),
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
      ShareParams(text: json, subject: 'Backup Stway'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cole o backup na área de transferência primeiro'),
          ),
        );
      }
      return;
    }
    final parsed = sync.parseImport(text);
    if (parsed == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Backup inválido')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Progresso restaurado!')));
    }
  }

  Widget _toggle(
    AppearanceStyle a,
    String label,
    String desc,
    bool value,
    ValueChanged<bool> onChanged, {
    CinematicGlyph glyph = CinematicGlyph.spark,
    Color? accent,
    VoidCallback? onRowTap,
  }) {
    final tone = accent ?? AppColors.accent;
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
                accent: value ? tone : a.textFaint,
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
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeThumbColor: tone,
                activeTrackColor: tone.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Título do card — traço na cor da seção, como nos cards do perfil.
  Widget _cardTitle(String title, Color tint) {
    return Semantics(
      header: true,
      child: RelicChapter(title: title, accent: tint, divided: false),
    );
  }

  Widget _groupedCard(
    AppearanceStyle a, {
    required String title,
    required List<Widget> children,
    String? subtitle,
    Color tint = AppColors.accent,
  }) {
    return GlassCard(
      tint: tint,
      glow: 0.25,
      padding: const EdgeInsets.all(AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cardTitle(title, tint),
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

  /// Backup, sair e resetar — um card, linhas curtas; o perigoso em
  /// vermelho no fim e sempre com confirmação.
  Widget _accountCard(
    AppearanceStyle a,
    SyncService sync,
    ProgressService progress,
  ) {
    final backend = context.watch<BackendService>();
    final tint = _SettingsSection.conta.tint;
    final last = sync.lastSyncAt;
    return _groupedCard(
      a,
      title: 'Conta',
      tint: tint,
      children: [
        _navRow(
          a,
          'Backup manual',
          last == null
              ? 'Exportar ou restaurar o seu caminho'
              : 'Último · ${_shortDate(last)}',
          glyph: CinematicGlyph.share,
          accent: tint,
          onTap: () => _openBackupSheet(sync),
        ),
        const _SettingsDivider(compact: true),
        if (backend.isSignedIn) ...[
          _navRow(
            a,
            'Sair da conta',
            'Limpa este aparelho · o caminho fica na nuvem',
            glyph: CinematicGlyph.back,
            accent: AppColors.error,
            labelColor: AppColors.error,
            onTap: backend.isGoogleBusy ? null : () => _signOutGoogle(backend),
          ),
          const _SettingsDivider(compact: true),
        ],
        _navRow(
          a,
          'Resetar progresso',
          'Apaga o caminho de vez · pede confirmação',
          glyph: CinematicGlyph.fall,
          accent: AppColors.error,
          labelColor: AppColors.error,
          onTap: () => _confirmResetProgress(progress),
        ),
      ],
    );
  }

  Future<void> _openBackupSheet(SyncService sync) {
    return _openPickerSheet(
      eyebrow: 'Conta',
      title: 'Backup manual',
      subtitle:
          'Exporte o caminho como texto, ou copie um backup e toque em restaurar.',
      glyph: CinematicGlyph.share,
      tint: _SettingsSection.conta.tint,
      body: (p) => Builder(
        builder: (ctx) {
          final a = Appearance.of(ctx);
          final s = ctx.watch<SyncService>();
          final meta = [
            if (s.lastSyncAt != null)
              'Último backup · ${_shortDate(s.lastSyncAt!)}',
            if (s.deviceId != null) 'Dispositivo · ${s.deviceId}',
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              CopperCta(
                label: 'Exportar',
                leading: CinematicGlyph.share,
                trailing: null,
                showGlow: false,
                onTap: () => _exportProgress(p, sync),
              ),
              const SizedBox(height: AppSpace.sm),
              GhostCta(
                label: 'Restaurar da área de transferência',
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
      eyebrow: 'Sobre',
      title: 'Traduções e créditos',
      subtitle: 'Textos bíblicos e ferramentas de estudo usados no Stway.',
      glyph: CinematicGlyph.scroll,
      tint: _SettingsSection.conta.tint,
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

  /// Sobre: versão, introdução e créditos em linhas; doação no fim.
  Widget _aboutBlock(AppearanceStyle a) {
    final tint = _SettingsSection.conta.tint;
    final credits = [
      for (final t in BibleService.catalog.where((t) => t.available))
        if (t.attribution != null) '${t.shortName} — ${t.attribution}',
      'Estudo (Strong) — ${BibleStudyService.attribution}',
    ];
    return _groupedCard(
      a,
      title: 'Sobre o Stway',
      subtitle: 'Aprenda a Bíblia em cenas curtas, no seu ritmo.',
      tint: tint,
      children: [
        _navRow(
          a,
          'Versão',
          _checkingUpdate ? 'Procurando atualização…' : (_versionLabel ?? '…'),
          glyph: CinematicGlyph.refresh,
          accent: tint,
          onTap: _checkingUpdate ? null : _checkForUpdates,
          trailing: Text(
            _checkingUpdate ? '' : 'Verificar',
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w800,
              color: a.textSecondary,
            ),
          ),
        ),
        const _SettingsDivider(compact: true),
        _navRow(
          a,
          'Rever introdução',
          'A apresentação do começo, de novo',
          glyph: CinematicGlyph.scroll,
          accent: tint,
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
          'Traduções e créditos',
          'Textos bíblicos e estudo',
          glyph: CinematicGlyph.book,
          accent: tint,
          onTap: () => _openCreditsSheet(credits),
        ),
        const SizedBox(height: AppSpace.lg),
        CopperCta(
          label: 'Ajude a continuar',
          leading: CinematicGlyph.gift,
          trailing: null,
          dense: true,
          showGlow: false,
          onTap: openDonatePage,
        ),
      ],
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

/// Seções dos ajustes — cada uma com cor própria, para o olho achar o
/// lugar pela cor antes de ler.
enum _SettingsSection {
  jornada(AppColors.accent),
  aparencia(AppColors.sky),
  lembretes(AppColors.coral),
  conta(AppColors.slate);

  final Color tint;

  const _SettingsSection(this.tint);
}

/// Faixa Peregrino+ dentro do passaporte.
class _PlusStrip extends StatelessWidget {
  final bool plus;
  final VoidCallback onTap;

  const _PlusStrip({required this.plus, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withValues(alpha: plus ? 0.22 : 0.12),
                AppColors.accent.withValues(alpha: 0.02),
              ],
            ),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: plus ? 0.6 : 0.3),
            ),
          ),
          child: Row(
            children: [
              CinematicIcon(
                glyph: CinematicGlyph.crown,
                size: 30,
                accent: AppColors.accent,
                glowing: plus,
                framed: false,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Peregrino+', color: AppColors.accent),
                    const SizedBox(height: 2),
                    Text(
                      plus
                          ? 'Assinatura ativa no caminho'
                          : 'Mais espaço para a companhia',
                      maxLines: 1,
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
              if (plus)
                const SoftBadge(
                  text: 'Ativo',
                  glyph: CinematicGlyph.check,
                  solid: true,
                )
              else
                ListChevron(color: AppColors.accent.withValues(alpha: 0.9)),
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
        'No princípio, criou Deus os céus e a terra.',
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

  String _whisperDate(DateTime dt) {
    final local = dt.toLocal();
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    final h = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$d/$m · $h:$min';
  }

  @override
  Widget build(BuildContext context) {
    final name = nameController.text;
    final caption = signedIn
        ? (email?.trim().isNotEmpty == true
              ? 'Conectado como ${email!}'
              : 'Progresso na nuvem')
        : 'Entre de novo para sincronizar o caminho.';
    final syncLine = lastSync == null
        ? null
        : 'Salvo na nuvem · ${_whisperDate(lastSync!)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JuntosHalo(
              size: 68,
              lit: signedIn,
              child: UserAvatar(
                name: name,
                photoUrl: photoUrl,
                seed: seed,
                style: portraitStyle,
                radius: 34,
                borderColor: AppColors.accent.withValues(alpha: 0.82),
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
                    cursorColor: AppColors.accent,
                    style: AppTypography.display(
                      size: 20,
                      weight: FontWeight.w800,
                      color: a.text,
                      height: 1.1,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'Seu nome no caminho',
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
                          label: 'Salvar nome',
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

class _SegmentTrack extends StatelessWidget {
  final List<
    ({String label, String? caption, bool selected, VoidCallback onTap})
  >
  items;
  final String? semanticsLabel;

  const _SegmentTrack({required this.items, this.semanticsLabel});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final selectedIndex = items.indexWhere((i) => i.selected);
    return Semantics(
      container: true,
      label: semanticsLabel,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.xs),
        decoration: BoxDecoration(
          color: a.insetFill,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: a.insetBorder),
        ),
        child: LayoutBuilder(
          builder: (context, c) {
            final slot = c.maxWidth / items.length;
            return Stack(
              children: [
                // Pílula ouro que desliza até a escolha.
                if (selectedIndex >= 0)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    left: slot * selectedIndex,
                    width: slot,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                Row(
                  children: [
                    for (final item in items)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: item.selected,
                          inMutuallyExclusiveGroup: true,
                          label: item.caption == null
                              ? item.label
                              : '${item.caption}, ${item.label}',
                          excludeSemantics: true,
                          child: GestureDetector(
                            onTap: item.onTap,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 44),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpace.xs,
                                vertical: AppSpace.sm,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 180),
                                    style: AppTypography.body(
                                      size: 13,
                                      weight: FontWeight.w800,
                                      color: item.selected
                                          ? AppColors.inkOnAccent
                                          : a.textSecondary,
                                    ),
                                    child: Text(
                                      item.label,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (item.caption != null)
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      style: AppTypography.body(
                                        size: 11,
                                        weight: FontWeight.w600,
                                        color: item.selected
                                            ? AppColors.inkOnAccent.withValues(
                                                alpha: 0.78,
                                              )
                                            : a.textFaint,
                                      ),
                                      child: Text(
                                        item.caption!,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
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
    );
  }
}

class _RhythmPath extends StatelessWidget {
  final ProgressService progress;

  const _RhythmPath({required this.progress});

  static const _options = <({int steps, String pace, String time})>[
    (steps: 1, pace: 'Leve', time: '~3 min'),
    (steps: 2, pace: 'Firme', time: '~6 min'),
    (steps: 3, pace: 'Intenso', time: '~9 min'),
  ];

  @override
  Widget build(BuildContext context) {
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
                        color: AppColors.accent.withValues(alpha: 0.22),
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
                        color: AppColors.accent.withValues(alpha: 0.9),
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
                      pace: option.pace,
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
      label: steps == 1 ? '1 cena por dia' : '$steps cenas por dia',
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
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: selected ? 40 : 32,
      height: selected ? 40 : 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.accent : a.cardFill,
        border: Border.all(
          color: selected
              ? AppColors.accent
              : AppColors.accent.withValues(alpha: 0.45),
          width: selected ? 2 : 1.4,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        '$steps',
        style: AppTypography.title(
          size: selected ? 18 : 14,
          weight: FontWeight.w900,
          color: selected ? AppColors.inkOnAccent : a.text,
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
    final label = steps == 1 ? '1 passo' : '$steps passos';
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.title(
            size: 12,
            color: selected ? AppColors.accent : a.text,
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
          duration: const Duration(milliseconds: 220),
          height: 2,
          width: selected ? 28 : 0,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
        ),
      ],
    );
  }
}

/// Switch do céu — quatro estágios, de ponta a ponta do card.
class _SkySwitch extends StatefulWidget {
  final AppearanceMode selected;
  final ValueChanged<AppearanceMode> onChanged;

  const _SkySwitch({required this.selected, required this.onChanged});

  static const modes = AppearanceMode.values;
  static const trackHeight = 100.0;

  @override
  State<_SkySwitch> createState() => _SkySwitchState();
}

class _SkySwitchState extends State<_SkySwitch> with TickerProviderStateMixin {
  static const _modes = _SkySwitch.modes;
  static const _slideDuration = Duration(milliseconds: 520);
  static const _slideCurve = Curves.easeOutCubic;

  late final AnimationController _slide;
  late final AnimationController _life;
  double _downX = 0;
  int _lastSlot = -1;

  int get _index {
    final i = _modes.indexOf(widget.selected);
    return i < 0 ? 0 : i;
  }

  double get _visual => _slide.value;

  AppearanceMode get _visualMode {
    final i = _visual.round().clamp(0, _modes.length - 1);
    return _modes[i];
  }

  String get _caption => _captionFor(_visualMode);

  String _captionFor(AppearanceMode mode) => switch (mode) {
    AppearanceMode.morning => 'Céu claro',
    AppearanceMode.afternoon => 'Luz baixa',
    AppearanceMode.night => 'Céu escuro',
    AppearanceMode.automatic => 'Segue o horário',
  };

  Color _accentFor(AppearanceMode mode) => switch (mode) {
    AppearanceMode.morning => AppColors.accent,
    AppearanceMode.afternoon => AppColors.ember,
    AppearanceMode.night => AppColors.orchid,
    AppearanceMode.automatic => AppColors.slate,
  };

  Color get _accentNow {
    final x = _visual.clamp(0.0, 3.0);
    final i = x.floor().clamp(0, 2);
    final t = Curves.easeInOut.transform(x - i);
    return Color.lerp(_accentFor(_modes[i]), _accentFor(_modes[i + 1]), t)!;
  }

  String _shortLabel(AppearanceMode mode) => switch (mode) {
    AppearanceMode.automatic => 'Auto',
    _ => mode.label,
  };

  double _focus(int i) {
    final d = (_visual - i).abs();
    return (1.0 - d).clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _slide = AnimationController(
      vsync: this,
      duration: _slideDuration,
      lowerBound: 0,
      upperBound: (_modes.length - 1).toDouble(),
      value: _index.toDouble(),
    );
    _life = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _lastSlot = _index;
  }

  @override
  void didUpdateWidget(covariant _SkySwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected == widget.selected) return;
    _lastSlot = _index;
    if (!_slide.isAnimating) {
      _slide.animateTo(
        _index.toDouble(),
        duration: _slideDuration,
        curve: _slideCurve,
      );
    }
  }

  @override
  void dispose() {
    _slide.dispose();
    _life.dispose();
    super.dispose();
  }

  void _commit(int index) {
    final next = _modes[index.clamp(0, _modes.length - 1)];
    if (next != widget.selected) {
      if (_lastSlot != index) ActHaptics.tap();
      widget.onChanged(next);
    }
    _lastSlot = index;
  }

  void _goTo(int index) {
    _slide.animateTo(
      index.toDouble(),
      duration: _slideDuration,
      curve: _slideCurve,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _commit(index);
    });
  }

  void _pickSnap(double localX, double width) {
    if (width <= 0) return;
    final i = (localX / width * _modes.length).floor().clamp(
      0,
      _modes.length - 1,
    );
    _goTo(i);
  }

  void _follow(double localX, double width) {
    if (width <= 0) return;
    final v = ((localX / width) * _modes.length - 0.5).clamp(
      0.0,
      (_modes.length - 1).toDouble(),
    );
    final slot = v.round();
    if (slot != _lastSlot) {
      _lastSlot = slot;
      ActHaptics.tap();
    }
    _slide.stop();
    _slide.value = v;
  }

  void _endDrag() {
    final snap = _visual.round().clamp(0, _modes.length - 1);
    _goTo(snap);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);

    return Column(
      children: [
        Semantics(
          container: true,
          label: 'Céu da tela',
          value: '${widget.selected.label}. ${_captionFor(widget.selected)}',
          hint: 'Toque ou deslize para escolher',
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.05,
            child: SizedBox(
              height: _SkySwitch.trackHeight,
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _downX = d.localPosition.dx,
                    onTap: () => _pickSnap(_downX, w),
                    onHorizontalDragStart: (d) =>
                        _follow(d.localPosition.dx, w),
                    onHorizontalDragUpdate: (d) =>
                        _follow(d.localPosition.dx, w),
                    onHorizontalDragEnd: (_) => _endDrag(),
                    onHorizontalDragCancel: _endDrag,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(color: a.cardBorder, width: 1.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.md - 0.6),
                        child: AnimatedBuilder(
                          animation: _slide,
                          builder: (context, _) {
                            return Stack(
                              children: [
                                Row(
                                  children: [
                                    for (var i = 0; i < _modes.length; i++)
                                      Expanded(
                                        child: _SkyStageSky(
                                          mode: _modes[i],
                                          focus: _focus(i),
                                        ),
                                      ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    for (var i = 0; i < _modes.length; i++)
                                      Expanded(
                                        child: _SkyStageFace(
                                          mode: _modes[i],
                                          label: _shortLabel(_modes[i]),
                                          accent: _accentFor(_modes[i]),
                                          focus: _focus(i),
                                          selected: i == _visual.round(),
                                          life: _life,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        AnimatedBuilder(
          animation: _slide,
          builder: (context, _) {
            return Column(
              children: [
                Text(
                  _visualMode.label,
                  style: AppTypography.title(size: 14, color: _accentNow),
                ),
                const SizedBox(height: 2),
                Text(
                  _caption,
                  style: AppTypography.body(size: 12, color: a.textSecondary),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SkyStageSky extends StatelessWidget {
  final AppearanceMode mode;
  final double focus;

  const _SkyStageSky({required this.mode, required this.focus});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AmbientAtmosphere(phase: AppearanceStyle.resolve(mode).phase),
        IgnorePointer(
          child: ColoredBox(color: Color.fromRGBO(0, 0, 0, 0.46 * (1 - focus))),
        ),
      ],
    );
  }
}

class _SkyStageFace extends StatelessWidget {
  final AppearanceMode mode;
  final String label;
  final Color accent;
  final double focus;
  final bool selected;
  final Animation<double> life;

  const _SkyStageFace({
    required this.mode,
    required this.label,
    required this.accent,
    required this.focus,
    required this.selected,
    required this.life,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(
      Colors.white.withValues(alpha: 0.7),
      accent,
      Curves.easeOut.transform(focus),
    )!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Transform.scale(
                scale: 0.86 + 0.22 * focus,
                child: selected
                    ? AnimatedBuilder(
                        animation: life,
                        builder: (context, _) {
                          return CustomPaint(
                            size: const Size(38, 38),
                            painter: _SkyMarkPainter(
                              mode: mode,
                              color: color,
                              t: life.value,
                              alive: true,
                              amp: 1,
                            ),
                          );
                        },
                      )
                    : CustomPaint(
                        size: const Size(38, 38),
                        painter: _SkyMarkPainter(
                          mode: mode,
                          color: color,
                          t: 0,
                          alive: false,
                          amp: 0,
                        ),
                      ),
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.label(
              size: 11,
              letterSpacing: 0.2,
              color: color,
              weight: focus > 0.55 ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Marcas do switch: sol entre nuvens, sol, lua entre nuvens, ciclo.
class _SkyMarkPainter extends CustomPainter {
  final AppearanceMode mode;
  final Color color;
  final double t;
  final bool alive;
  final double amp;

  _SkyMarkPainter({
    required this.mode,
    required this.color,
    required this.t,
    required this.alive,
    this.amp = 1,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;
    final wave = t * math.pi * 2;
    final breathe = 0.5 + 0.5 * math.sin(wave);
    final drift = math.sin(wave) * amp;
    final drift2 = math.cos(wave) * amp;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    final soft = Paint()
      ..color = color.withValues(alpha: 0.86)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    if (alive) {
      canvas.drawCircle(
        c,
        s * (0.46 + breathe * 0.05 * amp),
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: (0.16 + breathe * 0.12) * amp),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: s * 0.52)),
      );
    }

    switch (mode) {
      case AppearanceMode.morning:
        _sun(
          canvas,
          c + Offset(0, -s * 0.08),
          s * (0.9 + breathe * 0.04 * amp),
          fill,
          spin: wave,
        );
        _cloud(
          canvas,
          c + Offset(-s * 0.08 + drift * s * 0.05, s * 0.18),
          s * 0.72,
          fill,
        );
        _cloud(
          canvas,
          c + Offset(s * 0.18 + drift2 * s * 0.04, s * 0.22),
          s * 0.5,
          soft,
        );
      case AppearanceMode.afternoon:
        _sun(
          canvas,
          c + Offset(0, -s * 0.06),
          s * (0.94 + breathe * 0.05 * amp),
          fill,
          spin: wave * 0.7,
        );
        _cloud(
          canvas,
          c + Offset(s * 0.02 + drift * s * 0.04, s * 0.28),
          s * 0.55,
          soft,
        );
      case AppearanceMode.night:
        _star(
          canvas,
          c + Offset(s * 0.28, -s * 0.28),
          s * (0.08 + breathe * 0.025 * amp),
          Paint()
            ..color = color.withValues(alpha: 0.4 + breathe * 0.6 * amp)
            ..isAntiAlias = true,
        );
        _moon(
          canvas,
          c + Offset(-s * 0.04, -s * 0.08 + drift * s * 0.025),
          s * 0.88,
          fill,
        );
        _cloud(
          canvas,
          c + Offset(-s * 0.06 + drift * s * 0.04, s * 0.2),
          s * 0.7,
          fill,
        );
        _cloud(
          canvas,
          c + Offset(s * 0.2 + drift2 * s * 0.03, s * 0.24),
          s * 0.48,
          soft,
        );
      case AppearanceMode.automatic:
        _clock(canvas, c, s, fill, alive: alive);
    }
  }

  void _sun(Canvas canvas, Offset c, double s, Paint paint, {double spin = 0}) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(spin);
    canvas.drawCircle(Offset.zero, s * 0.16, paint);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4 - math.pi / 2;
      final len = s * (i.isEven ? 0.13 : 0.09);
      final inner = s * 0.22;
      final p1 = Offset(math.cos(a) * inner, math.sin(a) * inner);
      final p2 = Offset(
        math.cos(a) * (inner + len),
        math.sin(a) * (inner + len),
      );
      final perp = Offset(-math.sin(a), math.cos(a)) * s * 0.04;
      canvas.drawPath(
        Path()
          ..moveTo(p1.dx + perp.dx, p1.dy + perp.dy)
          ..lineTo(p2.dx + perp.dx, p2.dy + perp.dy)
          ..lineTo(p2.dx - perp.dx, p2.dy - perp.dy)
          ..lineTo(p1.dx - perp.dx, p1.dy - perp.dy)
          ..close(),
        paint,
      );
    }
    canvas.restore();
  }

  void _cloud(Canvas canvas, Offset c, double s, Paint paint) {
    canvas.drawCircle(c + Offset(-s * 0.18, 0), s * 0.16, paint);
    canvas.drawCircle(c + Offset(s * 0.02, -s * 0.08), s * 0.2, paint);
    canvas.drawCircle(c + Offset(s * 0.2, 0), s * 0.14, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + Offset(0, s * 0.06),
          width: s * 0.62,
          height: s * 0.2,
        ),
        Radius.circular(s * 0.1),
      ),
      paint,
    );
  }

  void _moon(Canvas canvas, Offset c, double s, Paint paint) {
    final moon = Path()..addOval(Rect.fromCircle(center: c, radius: s * 0.2));
    final cut = Path()
      ..addOval(
        Rect.fromCircle(
          center: c + Offset(s * 0.1, -s * 0.05),
          radius: s * 0.17,
        ),
      );
    canvas.drawPath(Path.combine(PathOperation.difference, moon, cut), paint);
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2 - math.pi / 2;
      final p = c + Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
      final b = a + math.pi / 4;
      final q = c + Offset(math.cos(b) * r * 0.35, math.sin(b) * r * 0.35);
      path.lineTo(q.dx, q.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _clock(
    Canvas canvas,
    Offset c,
    double s,
    Paint paint, {
    required bool alive,
  }) {
    final ring = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.07
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    canvas.drawCircle(c, s * 0.32, ring);

    final tick = Paint()
      ..color = paint.color
      ..strokeWidth = s * 0.045
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2 - math.pi / 2;
      final inner = s * 0.24;
      final outer = s * 0.32;
      canvas.drawLine(
        c + Offset(math.cos(a) * inner, math.sin(a) * inner),
        c + Offset(math.cos(a) * outer, math.sin(a) * outer),
        tick,
      );
    }

    final now = DateTime.now();
    final hour =
        ((now.hour % 12) + now.minute / 60) / 12 * math.pi * 2 - math.pi / 2;
    final minute =
        (now.minute + now.second / 60) / 60 * math.pi * 2 - math.pi / 2;
    final second = alive
        ? (now.second + now.millisecond / 1000) / 60 * math.pi * 2 - math.pi / 2
        : minute;

    void hand(double angle, double len, double weight) {
      canvas.drawLine(
        c,
        c + Offset(math.cos(angle) * s * len, math.sin(angle) * s * len),
        Paint()
          ..color = paint.color
          ..strokeWidth = s * weight
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = true,
      );
    }

    hand(hour, 0.16, 0.07);
    hand(minute, 0.24, 0.05);
    if (alive) {
      hand(second, 0.26, 0.03);
    }
    canvas.drawCircle(c, s * 0.035, paint);
  }

  @override
  bool shouldRepaint(covariant _SkyMarkPainter old) =>
      old.mode != mode ||
      old.color != color ||
      old.t != t ||
      old.alive != alive ||
      old.amp != amp;
}
