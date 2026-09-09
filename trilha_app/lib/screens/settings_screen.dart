import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/question_bank.dart';
import '../data/trail_repository.dart';
import '../models/caravan_profile_prefs.dart';
import '../models/difficulty.dart';
import '../services/app_update_service.dart';
import '../services/backend_service.dart';
import '../services/bible_service.dart';
import '../services/bible_study_service.dart';
import '../services/companion_service.dart';
import '../services/league_service.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/subscription_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/layout_utils.dart';
import '../widgets/app_update_sheet.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/hero_card_atmosphere.dart';
import '../widgets/immersive_background.dart';
import '../widgets/lantern_glyph.dart';
import '../widgets/top_bar.dart';
import '../widgets/ui_primitives.dart';
import '../widgets/user_avatar.dart';
import 'login_screen.dart';
import 'paywall_screen.dart';
import 'onboarding_screen.dart';

const _genesisTrailSlug = 'genesis-1-11';

/// Abre ajustes como página empurrada (engrenagem no perfil).
void openSettings(BuildContext context) {
  final progress = context.read<ProgressService>();
  final mode = progress.settings.appearanceMode;
  final appearance = AppearanceStyle.resolve(mode);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (ctx) => Appearance(
        mode: mode,
        style: appearance,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: ImmersiveBackground(
            appearance: appearance,
            child: SettingsScreen(
              topBar: TopBar(
                inline: true,
                immersive: true,
                dark: appearance.onDark,
                title: 'Ajustes',
                subtitle: 'Conta · Preferências',
                leadingGlyph: CinematicGlyph.tune,
                chromeAccent: AppColors.slate,
                onBack: () => Navigator.pop(ctx),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class SettingsScreen extends StatefulWidget {
  final Widget? topBar;

  const SettingsScreen({super.key, this.topBar});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  bool _confirmReset = false;
  bool _nameDirty = false;
  List<DifficultyMeta>? _difficulties;
  List<String> _genesisMissionSlugs = const [];
  late final AnimationController _entrance;
  String? _versionLabel;
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _loadDifficulties();
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

  Future<void> _loadDifficulties() async {
    final items = await QuestionBank.instance.getDifficulties();
    final trail = await TrailRepository().getTrailBySlug(_genesisTrailSlug);
    if (mounted) {
      setState(() {
        _difficulties = items;
        _genesisMissionSlugs = trail?.missionSlugs ?? const [];
      });
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

        _reveal(0, _accountBlock(progress, a)),
        const SizedBox(height: AppSpace.section),
        _reveal(
          1,
          _groupedCard(
            a,
            title: 'O ritmo',
            glyph: CinematicGlyph.lamp,
            children: [
              Text(
                'Quantos passos você quer dar hoje.',
                style: AppTypography.body(
                  size: 13,
                  height: 1.35,
                  color: a.textMuted(0.65),
                ),
              ),
              const SizedBox(height: 12),
              _RhythmPath(progress: progress),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.section),
        _reveal(
          2,
          _groupedCard(
            a,
            title: 'O olhar',
            glyph: CinematicGlyph.book,
            children: [
              Text(
                'Gênesis 1–11 · o primeiro caminho',
                style: AppTypography.body(
                  size: 13,
                  height: 1.35,
                  color: a.textMuted(0.65),
                ),
              ),
              const SizedBox(height: 12),
              _difficultyPicker(progress),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.section),
        _reveal(
          3,
          _groupedCard(
            a,
            title: 'O céu',
            glyph: CinematicGlyph.sun,
            children: [
              _skyPicker(progress),
              _SettingsDivider(a),
              _fieldLabel(a, 'Tamanho do texto'),
              const SizedBox(height: 10),
              _fontScalePicker(progress, a),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.section),
        _reveal(
          4,
          _groupedCard(
            a,
            title: 'Lembretes',
            glyph: CinematicGlyph.mail,
            children: [
              _toggle(
                a,
                'Sons',
                'Efeitos nas lições',
                progress.settings.sound,
                (v) {
                  progress.updateSettings(progress.settings.copyWith(sound: v));
                  SoundService.instance.setEnabled(v);
                },
                glyph: CinematicGlyph.echo,
              ),
              _SettingsDivider(a, compact: true),
              _toggle(
                a,
                'Notificações',
                'Meta, missões e prática',
                progress.settings.notifications,
                (v) async {
                  await progress.markNotificationsPrompted(enabled: v);
                  if (v) {
                    await NotificationService.instance.requestOsPermission();
                  }
                  await NotificationService.instance.syncFromProgress(progress);
                },
                glyph: CinematicGlyph.mail,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.section),
        _reveal(
          5,
          _groupedCard(
            a,
            title: 'Privacidade',
            glyph: CinematicGlyph.shield,
            children: [
              Text(
                'O que outros veem no seu card da caravana.',
                style: AppTypography.body(
                  size: 13,
                  height: 1.35,
                  color: a.textMuted(0.65),
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              for (var i = 0; i < CaravanProfileSection.values.length; i++) ...[
                if (i > 0) _SettingsDivider(a, compact: true),
                _caravanProfileToggle(
                  progress,
                  a,
                  CaravanProfileSection.values[i],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpace.section),
        _reveal(6, _backupBlock(a, sync, progress)),
        const SizedBox(height: AppSpace.section),
        _reveal(7, _aboutBlock(a)),

        const SizedBox(height: AppSpace.section),
        _reveal(
          10,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: SectionLabel(
                  'Zona de perigo',
                  color: AppColors.error.withValues(alpha: 0.85),
                ),
              ),
              if (!_confirmReset)
                Column(
                  children: [
                    GhostCta(
                      label: 'Rever introdução',
                      leading: CinematicGlyph.path,
                      expanded: true,
                      onTap: () async {
                        if (!mounted) return;
                        await Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute<void>(
                            builder: (_) => const OnboardingScreen(),
                          ),
                          (_) => false,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpace.sm),
                    GhostCta(
                      label: 'Resetar progresso',
                      leading: CinematicGlyph.fall,
                      danger: true,
                      expanded: true,
                      onTap: () => setState(() => _confirmReset = true),
                    ),
                  ],
                )
              else
                GlassCard(
                  padding: AppMetrics.cardPadding,
                  child: Column(
                    children: [
                      Text(
                        'Tem certeza? Todos os passos, dias caminhando e progresso serão apagados. A introdução volta a aparecer.',
                        style: AppTypography.body(
                          size: 13,
                          weight: FontWeight.w700,
                          color: AppColors.error,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: AppSpace.md),
                      Row(
                        children: [
                          Expanded(
                            child: GhostCta(
                              label: 'Cancelar',
                              onTap: () =>
                                  setState(() => _confirmReset = false),
                            ),
                          ),
                          const SizedBox(width: AppSpace.sm),
                          Expanded(
                            child: FilledButton(
                              onPressed: () async {
                                final backend = context.read<BackendService>();
                                final league = context.read<LeagueService>();
                                await progress.resetProgress();
                                await backend.saveNow(
                                  progress,
                                  LeagueService.weekKey(),
                                  league: league,
                                );
                                if (!mounted) return;
                                setState(() => _confirmReset = false);
                                await Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const OnboardingScreen(),
                                  ),
                                  (_) => false,
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.md,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Confirmar',
                                style: AppTypography.cta(
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
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
    return Text(
      title,
      style: AppTypography.body(
        size: 13,
        weight: FontWeight.w700,
        color: a.textMuted(0.72),
      ),
    );
  }

  void _saveName(ProgressService progress) {
    FocusScope.of(context).unfocus();
    progress.setUserName(_nameController.text);
    setState(() => _nameDirty = false);
    HapticFeedback.lightImpact();
  }

  Widget _fontScalePicker(ProgressService progress, AppearanceStyle a) {
    const steps = <(double, String)>[
      (0.9, 'Peq.'),
      (1.0, 'Médio'),
      (1.15, 'Grande'),
      (1.3, 'Extra'),
    ];
    final current = progress.settings.fontScale;

    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Builder(
              builder: (context) {
                final (scale, label) = steps[i];
                final selected = (current - scale).abs() < 0.01;
                return AppChoiceTile(
                  selected: selected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    progress.updateSettings(
                      progress.settings.copyWith(fontScale: scale),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'A',
                        style: AppTypography.title(
                          size: 12 + (scale * 6),
                          weight: FontWeight.w900,
                          height: 1,
                          color: selected
                              ? AppColors.inkOnAccent
                              : a.textMuted(0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: AppTypography.label(
                          size: 9,
                          letterSpacing: 0.3,
                          color: selected
                              ? AppColors.inkOnAccent.withValues(alpha: 0.8)
                              : a.textMuted(0.55),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _difficultyPicker(ProgressService progress) {
    final items = _difficulties;
    final selectedId = progress.difficultyForTrail(_genesisTrailSlug);

    if (items == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final meta = items[i];
              final locked = !progress.isDifficultyUnlocked(
                _genesisTrailSlug,
                meta.difficulty,
              );
              final selected = selectedId == meta.difficulty.id && !locked;
              final cleared = progress.hasClearedMode(
                _genesisTrailSlug,
                meta.difficulty.id,
              );
              return _ModeStation(
                meta: meta,
                locked: locked,
                selected: selected,
                cleared: cleared,
                onTap: () => _onDifficultyTap(context, progress, meta, locked),
              );
            },
          ),
        ],
      ],
    );
  }

  void _onDifficultyTap(
    BuildContext context,
    ProgressService progress,
    DifficultyMeta meta,
    bool locked,
  ) {
    if (locked) {
      HapticFeedback.selectionClick();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Conclua o modo anterior para liberar ${meta.label}.',
            style: AppTypography.body(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
      );
      return;
    }
    HapticFeedback.selectionClick();
    final prev = progress.difficultyForTrail(_genesisTrailSlug);
    progress.setTrailDifficulty(
      _genesisTrailSlug,
      meta.difficulty.id,
      missionSlugs: _genesisMissionSlugs,
    );
    if (prev != null &&
        prev != meta.difficulty.id &&
        _genesisMissionSlugs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Progresso da trilha reiniciado neste modo.',
            style: AppTypography.body(color: AppColors.textOnDark),
          ),
          backgroundColor: AppColors.nightElevated,
        ),
      );
    }
  }

  Widget _skyPicker(ProgressService progress) {
    final selected = progress.settings.appearanceMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final mode in AppearanceMode.values) ...[
          if (mode.index > 0) const SizedBox(height: 8),
          _SkyStation(
            mode: mode,
            selected: selected == mode,
            onTap: () {
              HapticFeedback.selectionClick();
              progress.updateSettings(
                progress.settings.copyWith(appearanceMode: mode),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _cloudCard(AppearanceStyle a) {
    final backend = context.watch<BackendService>();
    final signedIn = backend.isSignedIn;
    final providerLabel = backend.isAppleSignedIn
        ? 'Conta Apple conectada'
        : backend.isGoogleSignedIn
        ? 'Conta Google conectada'
        : 'Conta desconectada';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: signedIn ? AppColors.teal : a.textMuted(0.4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                providerLabel,
                style: AppTypography.title(size: 14, color: a.text),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          signedIn
              ? (backend.userEmail ??
                    'Progresso sincronizado automaticamente com a nuvem.')
              : 'Faça login novamente para sincronizar a nuvem.',
          style: AppTypography.body(
            size: 12,
            height: 1.35,
            color: a.textMuted(0.78),
          ),
        ),
        if (signedIn && backend.userDisplayName != null) ...[
          const SizedBox(height: AppSpace.xs),
          Text(
            backend.userDisplayName!,
            style: AppTypography.body(
              size: 13,
              weight: FontWeight.w700,
              color: a.text,
            ),
          ),
        ],
        if (signedIn) ...[
          const SizedBox(height: AppSpace.md),
          GhostCta(
            label: 'Sair da conta',
            leading: CinematicGlyph.lock,
            expanded: true,
            onTap: backend.isGoogleBusy ? null : () => _signOutGoogle(backend),
          ),
        ],
        if (backend.isActive && backend.lastCloudSaveAt != null) ...[
          const SizedBox(height: AppSpace.sm),
          Text(
            'Última sync · ${_shortDate(backend.lastCloudSaveAt!)}',
            style: AppTypography.body(size: 11, color: a.textMuted(0.55)),
          ),
        ],
      ],
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
  }) {
    final tone = accent ?? AppColors.accent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: 40,
            accent: value ? tone : a.textMuted(0.45),
            glowing: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: AppTypography.body(size: 12, color: a.textMuted(0.62)),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }

  Widget _caravanProfileToggle(
    ProgressService progress,
    AppearanceStyle a,
    CaravanProfileSection section,
  ) {
    final prefs = progress.caravanProfilePrefs;
    final visible = prefs.isVisible(section);
    final glyph = switch (section) {
      CaravanProfileSection.presence => CinematicGlyph.spark,
      CaravanProfileSection.ranking => CinematicGlyph.podium,
      CaravanProfileSection.daysAsLeader => CinematicGlyph.crown,
      CaravanProfileSection.lastMission => CinematicGlyph.path,
      CaravanProfileSection.accuracy => CinematicGlyph.target,
      CaravanProfileSection.bible => CinematicGlyph.book,
      CaravanProfileSection.trails => CinematicGlyph.mountain,
      CaravanProfileSection.medals => CinematicGlyph.gem,
    };
    return _toggle(a, section.label, section.subtitle, visible, (v) {
      HapticFeedback.selectionClick();
      progress.updateCaravanProfilePrefs(prefs.copyWithSection(section, v));
    }, glyph: glyph);
  }

  Widget _groupedCard(
    AppearanceStyle a, {
    required String title,
    required CinematicGlyph glyph,
    required List<Widget> children,
    Color? accent,
  }) {
    return GlassCard(
      padding: AppMetrics.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardHeader(
            label: title,
            glyph: glyph,
            accent: accent ?? a.sectionLabel,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _accountBlock(ProgressService progress, AppearanceStyle a) {
    final subscription = context.watch<SubscriptionService>();
    final backend = context.watch<BackendService>();
    final plus = subscription.isPeregrinoPlus;

    return GlassCard(
      elevated: plus,
      accent: plus,
      child: Stack(
        children: [
          if (plus)
            const Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.22,
                  child: HeroCardAtmosphere(mood: HeroCardMood.alive),
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProfileHeader(
                a: a,
                nameController: _nameController,
                nameDirty: _nameDirty,
                photoUrl: backend.userPhotoUrl,
                onSaveName: () => _saveName(progress),
              ),
              const SizedBox(height: 14),
              _cloudCard(a),
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const PaywallScreen(),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: plus ? AppGradients.gold : null,
                      color: plus
                          ? null
                          : AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: plus
                            ? Colors.white.withValues(alpha: 0.45)
                            : AppColors.accent.withValues(alpha: 0.55),
                      ),
                      boxShadow: plus ? AppMetrics.accentGlow() : null,
                    ),
                    child: Row(
                      children: [
                        CinematicIcon(
                          glyph: CinematicGlyph.crown,
                          size: 36,
                          accent: plus
                              ? AppColors.inkOnAccent
                              : AppColors.accent,
                          glowing: false,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Peregrino+',
                                style: AppTypography.title(
                                  size: 15,
                                  color: plus ? AppColors.inkOnAccent : a.text,
                                ),
                              ),
                              Text(
                                plus
                                    ? 'Assinatura ativa'
                                    : 'Mais espaço para companhia',
                                style: AppTypography.body(
                                  size: 12,
                                  color: plus
                                      ? AppColors.inkOnAccent.withValues(
                                          alpha: 0.75,
                                        )
                                      : a.textMuted(0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          plus ? 'Ativo' : 'Ver',
                          style: AppTypography.body(
                            size: 13,
                            weight: FontWeight.w800,
                            color: plus
                                ? AppColors.inkOnAccent
                                : AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _backupBlock(
    AppearanceStyle a,
    SyncService sync,
    ProgressService progress,
  ) {
    return _groupedCard(
      a,
      title: 'Dados',
      glyph: CinematicGlyph.copy,
      children: [
        Text(
          'Exporte um backup ou importe da área de transferência.',
          style: AppTypography.body(
            size: 13,
            height: 1.35,
            color: a.textMuted(0.65),
          ),
        ),
        if (sync.deviceId != null) ...[
          const SizedBox(height: AppSpace.sm),
          Text(
            'Dispositivo · ${sync.deviceId}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.body(
              size: 11,
              weight: FontWeight.w600,
              color: a.textMuted(0.5),
            ),
          ),
        ],
        if (sync.lastSyncAt != null) ...[
          const SizedBox(height: 2),
          Text(
            'Último backup · ${_shortDate(sync.lastSyncAt!)}',
            style: AppTypography.body(
              size: 11,
              weight: FontWeight.w600,
              color: a.textMuted(0.5),
            ),
          ),
        ],
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            Expanded(
              child: GhostCta(
                label: 'Exportar',
                leading: CinematicGlyph.share,
                onTap: () => _exportProgress(progress, sync),
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: GhostCta(
                label: 'Importar',
                leading: CinematicGlyph.copy,
                onTap: () => _importProgress(progress, sync),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _aboutBlock(AppearanceStyle a) {
    return _groupedCard(
      a,
      title: 'Sobre',
      glyph: CinematicGlyph.spark,
      children: [
        Text(
          'Aprenda a Bíblia em missões curtas, no seu ritmo.',
          style: AppTypography.body(
            size: 13,
            height: 1.4,
            color: a.textMuted(0.65),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        Text(
          _versionLabel == null ? 'Versão…' : 'Versão $_versionLabel',
          style: AppTypography.body(
            size: 13,
            weight: FontWeight.w700,
            color: a.text.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        GhostCta(
          label: _checkingUpdate ? 'Verificando…' : 'Verificar atualizações',
          leading: CinematicGlyph.rise,
          expanded: true,
          onTap: _checkingUpdate ? null : _checkForUpdates,
        ),
        const SizedBox(height: AppSpace.md),
        Text(
          'Traduções bíblicas',
          style: AppTypography.label(
            size: 10,
            color: a.textMuted(0.55),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        for (final t in BibleService.catalog.where((t) => t.available))
          if (t.attribution != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.xs),
              child: Text(
                '${t.shortName} — ${t.attribution}',
                style: AppTypography.body(
                  size: 11,
                  height: 1.35,
                  color: a.textMuted(0.5),
                ),
              ),
            ),
          ],
        const SizedBox(height: AppSpace.sm),
        Text(
          'Estudo (Strong)',
          style: AppTypography.label(
            size: 10,
            color: a.textMuted(0.55),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          BibleStudyService.attribution,
          style: AppTypography.body(
            size: 11,
            height: 1.35,
            color: a.textMuted(0.5),
          ),
        ),
      ],
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  final AppearanceStyle a;
  final bool compact;

  const _SettingsDivider(this.a, {this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 6 : 14),
      child: Divider(
        height: 1,
        thickness: 1,
        color: a.cardBorder.withValues(alpha: 0.55),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppearanceStyle a;
  final TextEditingController nameController;
  final bool nameDirty;
  final String? photoUrl;
  final VoidCallback onSaveName;

  const _ProfileHeader({
    required this.a,
    required this.nameController,
    required this.nameDirty,
    required this.onSaveName,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(
          name: nameController.text,
          photoUrl: photoUrl,
          radius: 28,
          borderColor: AppColors.accent.withValues(alpha: 0.55),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Como te chamamos',
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.8,
                  color: a.textMuted(0.55),
                ),
              ),
              TextField(
                controller: nameController,
                maxLength: 24,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSaveName(),
                style: AppTypography.title(size: 20, color: a.text),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Seu nome no caminho',
                  hintStyle: AppTypography.title(
                    size: 20,
                    color: a.textMuted(0.35),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  suffixIcon: nameDirty
                      ? IconButton(
                          onPressed: onSaveName,
                          icon: const Icon(Icons.check_rounded),
                          color: AppColors.accent,
                          tooltip: 'Salvar',
                        )
                      : null,
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RhythmPath extends StatelessWidget {
  final ProgressService progress;

  const _RhythmPath({required this.progress});

  @override
  Widget build(BuildContext context) {
    final goal = progress.settings.dailyGoal;
    return Row(
      children: [
        for (final n in [1, 2, 3]) ...[
          if (n > 1) const SizedBox(width: 8),
          Expanded(
            child: _RhythmTile(
              steps: n,
              selected: goal == n,
              onTap: () {
                HapticFeedback.selectionClick();
                progress.updateSettings(
                  progress.settings.copyWith(dailyGoal: n),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _RhythmTile extends StatelessWidget {
  final int steps;
  final bool selected;
  final VoidCallback onTap;

  const _RhythmTile({
    required this.steps,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final lanternW = steps == 1 ? 28.0 : 18.0;
    final lanternH = steps == 1 ? 40.0 : 28.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(6, 12, 6, 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.12)
              : a.cardFillSoft,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.9)
                : a.cardBorder,
            width: selected ? 1.75 : 1.25,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < steps; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    CustomPaint(
                      size: Size(lanternW, lanternH),
                      painter: LanternPainter(
                        lit: selected,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              steps == 1 ? '1 passo' : '$steps passos',
              style: AppTypography.label(
                size: 11,
                letterSpacing: 0.4,
                color: selected ? AppColors.accent : a.textMuted(0.72),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeStation extends StatelessWidget {
  final DifficultyMeta meta;
  final bool locked;
  final bool selected;
  final bool cleared;
  final VoidCallback onTap;

  const _ModeStation({
    required this.meta,
    required this.locked,
    required this.selected,
    required this.cleared,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final accent = DifficultyVisuals.accentFor(meta.difficulty);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: locked
              ? a.cardFillSoft.withValues(alpha: 0.45)
              : selected
              ? DifficultyVisuals.chipFill(accent, alpha: 0.28)
              : a.cardFillSoft,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: locked
                ? a.cardBorder.withValues(alpha: 0.35)
                : selected
                ? accent.withValues(alpha: 0.9)
                : a.cardBorder,
            width: selected ? 1.75 : 1.25,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Opacity(
              opacity: locked ? 0.45 : 1,
              child: CinematicIcon(
                glyph: locked
                    ? CinematicGlyph.lock
                    : DifficultyVisuals.glyphFor(meta.difficulty),
                size: 40,
                accent: locked ? a.textMuted(0.5) : accent,
                glowing: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Opacity(
                opacity: locked ? 0.5 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    if (meta.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        meta.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          size: 12,
                          color: a.textMuted(selected ? 0.78 : 0.58),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (locked)
              Text(
                'Bloqueado',
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.4,
                  color: a.textMuted(0.45),
                ),
              )
            else if (selected)
              SoftBadge(
                text: 'Atual',
                glyph: CinematicGlyph.check,
                accent: accent,
              )
            else if (cleared)
              Text(
                'Feito',
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.4,
                  color: a.textMuted(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SkyStation extends StatelessWidget {
  final AppearanceMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _SkyStation({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  String get _caption => switch (mode) {
    AppearanceMode.morning => 'Céu claro',
    AppearanceMode.afternoon => 'Luz baixa',
    AppearanceMode.night => 'Céu escuro',
    AppearanceMode.automatic => 'Segue o horário',
  };

  Color get _accent => switch (mode) {
    AppearanceMode.morning => AppColors.accent,
    AppearanceMode.afternoon => AppColors.ember,
    AppearanceMode.night => AppColors.orchid,
    AppearanceMode.automatic => AppColors.slate,
  };

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final accent = _accent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: selected
              ? AppMetrics.accentFill(color: accent, alpha: 0.22)
              : a.cardFillSoft,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected
                ? AppMetrics.accentBorder(color: accent, alpha: 0.85)
                : a.cardBorder,
            width: selected ? 1.75 : 1.25,
          ),
        ),
        child: Row(
          children: [
            CinematicIcon(
              glyph: mode.glyph,
              size: 40,
              accent: accent,
              glowing: false,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title(size: 16, color: a.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.body(
                      size: 12,
                      color: a.textMuted(selected ? 0.78 : 0.58),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              SoftBadge(
                text: 'Atual',
                glyph: CinematicGlyph.check,
                accent: accent,
              ),
          ],
        ),
      ),
    );
  }
}
