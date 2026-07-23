import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/question_bank.dart';
import '../models/difficulty.dart';
import '../services/backend_service.dart';
import '../services/bible_service.dart';
import '../services/bible_study_service.dart';
import '../services/league_service.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/difficulty_visuals.dart';
import '../utils/layout_utils.dart';
import '../widgets/cinematic_icon.dart';
import '../widgets/immersive_background.dart';
import '../widgets/ui_primitives.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

const _genesisTrailSlug = 'genesis-1-11';

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
  bool _nameInitialized = false;
  bool _nameDirty = false;
  List<DifficultyMeta>? _difficulties;
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _loadDifficulties();
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (!mounted) return;
    final current = context.read<ProgressService>().userName;
    final dirty = _nameController.text.trim() != current;
    if (dirty != _nameDirty) setState(() => _nameDirty = dirty);
  }

  Future<void> _loadDifficulties() async {
    final items = await QuestionBank.instance.getDifficulties();
    if (mounted) setState(() => _difficulties = items);
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

    if (!_nameInitialized) {
      _nameInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
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

        _reveal(
          0,
          _ProfileHeader(
            progress: progress,
            a: a,
            nameController: _nameController,
            nameDirty: _nameDirty,
            onSaveName: () => _saveName(progress),
          ),
        ),

        const SizedBox(height: AppSpace.section),
        _reveal(
          1,
          GlassCard(
            padding: AppMetrics.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CardHeader(label: 'Seu caminho'),
                const SizedBox(height: AppSpace.md),
                _fieldLabel(a, 'Ritmo diário'),
                const SizedBox(height: AppSpace.sm),
                _dailyGoalPicker(progress, a),
                _SettingsDivider(a),
                _fieldLabel(a, 'Dificuldade · Gênesis 1–11'),
                const SizedBox(height: AppSpace.sm),
                _difficultyPicker(progress, a),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpace.section),
        _reveal(
          2,
          GlassCard(
            padding: AppMetrics.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CardHeader(label: 'Experiência'),
                const SizedBox(height: AppSpace.md),
                _fieldLabel(a, 'Aparência'),
                const SizedBox(height: AppSpace.sm),
                _themeGrid(progress, a),
                _SettingsDivider(a),
                _fieldLabel(a, 'Tamanho do texto'),
                const SizedBox(height: AppSpace.sm),
                _fontScalePicker(progress, a),
                _SettingsDivider(a),
                _toggle(
                  a,
                  'Sons',
                  'Efeitos nas lições',
                  progress.settings.sound,
                  (v) {
                    progress.updateSettings(
                      progress.settings.copyWith(sound: v),
                    );
                    SoundService.instance.setEnabled(v);
                  },
                ),
                _SettingsDivider(a),
                _toggle(
                  a,
                  'Notificações',
                  'Lembretes de meta, missões e prática',
                  progress.settings.notifications,
                  (v) async {
                    await progress.updateSettings(
                      progress.settings.copyWith(notifications: v),
                    );
                    await NotificationService.instance.syncFromProgress(
                      progress,
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpace.section),
        _reveal(
          3,
          GlassCard(
            padding: AppMetrics.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CardHeader(label: 'Conta'),
                const SizedBox(height: AppSpace.md),
                _cloudCard(a),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpace.section),
        _reveal(
          4,
          GlassCard(
            padding: AppMetrics.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CardHeader(label: 'Backup'),
                const SizedBox(height: AppSpace.sm),
                Text(
                  'Exporte um backup ou importe da área de transferência.',
                  style: AppTypography.body(
                    size: 13,
                    height: 1.35,
                    color: a.textMuted(0.78),
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
                      color: a.textMuted(0.55),
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
                      color: a.textMuted(0.55),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpace.md),
                Row(
                  children: [
                    Expanded(
                      child: _GhostAction(
                        label: 'Exportar',
                        glyph: CinematicGlyph.share,
                        onTap: () => _exportProgress(progress, sync),
                      ),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: _GhostAction(
                        label: 'Importar',
                        glyph: CinematicGlyph.copy,
                        onTap: () => _importProgress(progress, sync),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpace.section),
        _reveal(
          5,
          GlassCard(
            padding: AppMetrics.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CardHeader(label: 'Sobre'),
                const SizedBox(height: AppSpace.sm),
                Text(
                  'Aprenda a Bíblia em missões curtas, no seu ritmo.',
                  style: AppTypography.body(
                    size: 13,
                    height: 1.4,
                    color: a.textMuted(0.78),
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                Text(
                  'Traduções bíblicas',
                  style: AppTypography.label(
                    size: 10,
                    color: a.textMuted(0.65),
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
                          color: a.textMuted(0.55),
                        ),
                      ),
                    ),
                  ],
                const SizedBox(height: AppSpace.md),
                Text(
                  'Estudo (Strong)',
                  style: AppTypography.label(
                    size: 10,
                    color: a.textMuted(0.65),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  BibleStudyService.attribution,
                  style: AppTypography.body(
                    size: 11,
                    height: 1.35,
                    color: a.textMuted(0.55),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpace.section),
        _reveal(
          6,
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
                    _GhostAction(
                      label: 'Rever introdução',
                      glyph: CinematicGlyph.path,
                      expanded: true,
                      onTap: () async {
                        final backend = context.read<BackendService>();
                        final league = context.read<LeagueService>();
                        await progress.setHasSeenOnboarding(false);
                        await backend.saveNow(
                          progress,
                          LeagueService.weekKey(),
                          league: league,
                        );
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
                    _GhostAction(
                      label: 'Resetar progresso',
                      glyph: CinematicGlyph.fall,
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
                            child: _GhostAction(
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
      style: AppTypography.title(size: 14, color: a.text),
    );
  }

  void _saveName(ProgressService progress) {
    FocusScope.of(context).unfocus();
    progress.setUserName(_nameController.text);
    setState(() => _nameDirty = false);
    HapticFeedback.lightImpact();
  }

  Widget _dailyGoalPicker(ProgressService progress, AppearanceStyle a) {
    return _SegmentTrack(
      child: Row(
        children: [1, 2, 3].map((goal) {
          final selected = progress.settings.dailyGoal == goal;
          return Expanded(
            child: _SegmentCell(
              selected: selected,
              onTap: () {
                HapticFeedback.selectionClick();
                progress.updateSettings(
                  progress.settings.copyWith(dailyGoal: goal),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$goal',
                    style: AppTypography.title(
                      size: 17,
                      weight: FontWeight.w900,
                      height: 1,
                      color: selected
                          ? AppColors.inkOnAccent
                          : a.textMuted(0.85),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    goal == 1 ? 'passo' : 'passos',
                    style: AppTypography.label(
                      size: 10,
                      letterSpacing: 0.3,
                      color: selected
                          ? AppColors.inkOnAccent.withValues(alpha: 0.8)
                          : a.textMuted(0.55),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _fontScalePicker(ProgressService progress, AppearanceStyle a) {
    const steps = <(double, String)>[
      (0.9, 'Peq.'),
      (1.0, 'Médio'),
      (1.15, 'Grande'),
      (1.3, 'Extra'),
    ];
    final current = progress.settings.fontScale;

    return _SegmentTrack(
      child: Row(
        children: [
          for (final (scale, label) in steps)
            Expanded(
              child: _SegmentCell(
                selected: (current - scale).abs() < 0.01,
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
                        color: (current - scale).abs() < 0.01
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
                        color: (current - scale).abs() < 0.01
                            ? AppColors.inkOnAccent.withValues(alpha: 0.8)
                            : a.textMuted(0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _difficultyPicker(ProgressService progress, AppearanceStyle a) {
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
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              thickness: 1,
              color: a.cardBorder.withValues(alpha: 0.45),
            ),
          _DifficultyRow(
            meta: items[i],
            selected: selectedId == items[i].difficulty.id,
            onTap: () {
              HapticFeedback.selectionClick();
              progress.setTrailDifficulty(
                _genesisTrailSlug,
                items[i].difficulty.id,
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _themeGrid(ProgressService progress, AppearanceStyle a) {
    final selected = progress.settings.appearanceMode;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final cellW = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: AppearanceMode.values.map((mode) {
            final isSelected = selected == mode;
            return SizedBox(
              width: cellW,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    progress.updateSettings(
                      progress.settings.copyWith(appearanceMode: mode),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppGradients.gold : null,
                      color: isSelected ? null : a.cardFillSoft,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : a.cardBorder.withValues(alpha: 0.55),
                      ),
                    ),
                    child: Row(
                      children: [
                        CinematicIcon(
                          glyph: mode.glyph,
                          size: 18,
                          accent: isSelected
                              ? AppColors.inkOnAccent
                              : a.textMuted(0.8),
                          framed: false,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mode.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.body(
                              size: 12,
                              weight: FontWeight.w800,
                              color: isSelected
                                  ? AppColors.inkOnAccent
                                  : a.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _cloudCard(AppearanceStyle a) {
    final backend = context.watch<BackendService>();
    final google = backend.isGoogleSignedIn;

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
                color: google ? AppColors.teal : a.textMuted(0.4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                google ? 'Conta Google conectada' : 'Conta desconectada',
                style: AppTypography.title(size: 14, color: a.text),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          google
              ? (backend.userEmail ??
                    'Progresso sincronizado automaticamente com a nuvem.')
              : 'Faça login novamente para sincronizar a nuvem.',
          style: AppTypography.body(
            size: 12,
            height: 1.35,
            color: a.textMuted(0.78),
          ),
        ),
        if (google && backend.userDisplayName != null) ...[
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
        if (google) ...[
          const SizedBox(height: AppSpace.md),
          _GhostAction(
            label: 'Sair da conta',
            glyph: CinematicGlyph.lock,
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
    progress.resetMemoryToDefaults();
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
      ShareParams(text: json, subject: 'Backup Steway'),
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
    await backend.saveNow(
      progress,
      LeagueService.weekKey(),
      league: league,
    );
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
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
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
                    color: a.textMuted(0.62),
                  ),
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
}

class _SettingsDivider extends StatelessWidget {
  final AppearanceStyle a;

  const _SettingsDivider(this.a);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Divider(
        height: 1,
        thickness: 1,
        color: a.cardBorder.withValues(alpha: 0.55),
      ),
    );
  }
}

/// Trilho dos segmentos — mesmo padrão da Liga (Companhia / Caravana).
class _SegmentTrack extends StatelessWidget {
  final Widget child;

  const _SegmentTrack({required this.child});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: a.cardFillSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: a.cardBorder.withValues(alpha: 0.65)),
      ),
      child: child,
    );
  }
}

class _SegmentCell extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _SegmentCell({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.gold : null,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accentDark.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

class _DifficultyRow extends StatelessWidget {
  final DifficultyMeta meta;
  final bool selected;
  final VoidCallback onTap;

  const _DifficultyRow({
    required this.meta,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Row(
            children: [
              CinematicIcon(
                glyph: DifficultyVisuals.glyphFor(meta.difficulty),
                size: AppMetrics.leadingIcon,
                accent: selected ? AppColors.accent : a.textMuted(0.75),
                framed: false,
                glowing: false,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.label,
                      style: AppTypography.title(
                        size: 14,
                        color: a.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta.subtitle,
                      style: AppTypography.body(
                        size: 12,
                        height: 1.3,
                        color: a.textMuted(selected ? 0.75 : 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const CinematicIcon(
                  glyph: CinematicGlyph.check,
                  size: 20,
                  accent: AppColors.accent,
                  framed: false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GhostAction extends StatelessWidget {
  final String label;
  final CinematicGlyph? glyph;
  final VoidCallback? onTap;
  final bool danger;
  final bool expanded;

  const _GhostAction({
    required this.label,
    this.glyph,
    this.onTap,
    this.danger = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = danger ? AppColors.error : a.text;
    final border = danger
        ? AppColors.error.withValues(alpha: 0.45)
        : a.cardBorder;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          width: expanded ? double.infinity : null,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: danger
                ? AppColors.error.withValues(alpha: 0.08)
                : a.cardFillSoft,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.max,
            children: [
              if (glyph != null) ...[
                CinematicIcon(
                  glyph: glyph!,
                  size: 16,
                  accent: ink,
                  framed: false,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTypography.body(
                  size: 13,
                  weight: FontWeight.w800,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProgressService progress;
  final AppearanceStyle a;
  final TextEditingController nameController;
  final bool nameDirty;
  final VoidCallback onSaveName;

  const _ProfileHeader({
    required this.progress,
    required this.a,
    required this.nameController,
    required this.nameDirty,
    required this.onSaveName,
  });

  @override
  Widget build(BuildContext context) {
    final missions = progress.completedMissions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatSeal(
                glyph: CinematicGlyph.path,
                value: '${progress.steps}',
                label: progress.steps == 1 ? 'passo' : 'passos',
                accent: AppColors.accent,
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: _StatSeal(
                glyph: CinematicGlyph.flame,
                value: '${progress.streak}',
                label: progress.streak == 1 ? 'dia' : 'dias',
                accent: AppColors.streak,
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: _StatSeal(
                glyph: CinematicGlyph.book,
                value: '$missions',
                label: missions == 1 ? 'missão' : 'missões',
                accent: AppColors.primaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        GlassCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nome no app',
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.8,
                  color: a.textMuted(0.55),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                maxLength: 24,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSaveName(),
                style: AppTypography.body(
                  color: a.text,
                  weight: FontWeight.w700,
                  size: 15,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Como te chamamos?',
                  hintStyle: AppTypography.body(color: a.textMuted(0.4)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  suffixIcon: nameDirty
                      ? IconButton(
                          onPressed: onSaveName,
                          icon: const Icon(Icons.check_rounded),
                          color: AppColors.accent,
                          tooltip: 'Salvar',
                        )
                      : null,
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

class _StatSeal extends StatelessWidget {
  final CinematicGlyph glyph;
  final String value;
  final String label;
  final Color accent;

  const _StatSeal({
    required this.glyph,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpace.md,
        horizontal: AppSpace.xs,
      ),
      child: Column(
        children: [
          CinematicIcon(
            glyph: glyph,
            size: 18,
            accent: accent,
            framed: false,
            glowing: false,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.title(
              size: 16,
              weight: FontWeight.w900,
              color: a.text,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.3,
              color: a.textMuted(0.55),
            ),
          ),
        ],
      ),
    );
  }
}
