import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pilgrim_chest.dart';
import '../models/pilgrim_medal_models.dart' show PilgrimMedalTier;
import '../services/progress_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'anan_speech.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'confetti_overlay.dart';
import 'chest_art.dart';
import 'medal_art.dart';
import 'ui_primitives.dart';
import '../l10n/app_language.dart';

/// Baú do dia — recompensa cosmética variável, 1x/dia, ao completar a
/// cena de hoje. Nunca dá passos/XP: não compete com o Cofre de medalhas
/// (que fica intocado como conquista de longo prazo). A incerteza é só de
/// apresentação — a recompensa em si sempre vem (piso garantido por pity
/// em [PilgrimChestRoll]).
///
/// A folha mostra o baú fechado chamando, com o Anan ao lado; "Abrir o
/// baú" leva à tela cheia, onde a tampa estoura e o Anan solta confete.
Future<void> showDailyChestSheet(BuildContext context) {
  ActHaptics.tap();
  return showAppSheet<void>(
    context,
    useRootNavigator: true,
    builder: (ctx) => const _DailyChestSheet(),
  );
}

const _prefsOfferedDay = 'daily_chest_offered_day';

/// O baú chega sozinho uma vez por dia, quando fica pronto. Depois disso
/// ele espera na linha "Mais para hoje".
Future<bool> takeDailyChestOffer() async {
  final prefs = await SharedPreferences.getInstance();
  final today = DateTime.now().toIso8601String().substring(0, 10);
  if (prefs.getString(_prefsOfferedDay) == today) return false;
  await prefs.setString(_prefsOfferedDay, today);
  return true;
}

/// Laboratório: a folha automática volta a aparecer hoje.
Future<void> resetDailyChestOffer() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_prefsOfferedDay);
}

class _DailyChestSheet extends StatefulWidget {
  const _DailyChestSheet();

  @override
  State<_DailyChestSheet> createState() => _DailyChestSheetState();
}

class _DailyChestSheetState extends State<_DailyChestSheet>
    with SingleTickerProviderStateMixin {
  /// Ciclo do baú chamando: pulinho, a tampa espia, brilho na fechadura.
  late final AnimationController _idle;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _idle.stop();
    } else if (!_idle.isAnimating) {
      _idle.repeat();
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  void _open() {
    ActHaptics.confirm();
    final nav = Navigator.of(context);
    nav.pop();
    nav.push(DailyChestRevealScreen.route());
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final stageHeight = (MediaQuery.sizeOf(context).height * 0.36).clamp(
      260.0,
      400.0,
    );

    return AppSheetPanel(
      tint: AppRoles.reward,
      padding: const EdgeInsets.fromLTRB(
        AppSpace.md,
        AppSpace.md,
        AppSpace.md,
        AppSpace.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // O Anan dá a notícia; o palco fica só com o baú.
          AnanSideSpeech(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.chestOfferTitle,
                  style: AppTypography.title(
                    size: 18,
                    height: 1.15,
                    color: AnanSpeechBubble.ink,
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  context.l10n.chestOfferBody,
                  style: AppTypography.body(
                    size: 14,
                    color: AnanSpeechBubble.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: SizedBox(
              height: stageHeight,
              child: AnimatedBuilder(
                animation: _idle,
                builder: (context, _) =>
                    _ClosedStage(height: stageHeight, t: _idle.value),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
            child: CopperCta(
              label: context.l10n.chestOpen,
              trailing: CinematicGlyph.gift,
              onTap: _open,
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.commonNotNow,
                style: AppTypography.body(
                  size: 14,
                  weight: FontWeight.w700,
                  color: a.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Palco da folha: só o baú fechado no meio, chamando, entre moedas e
/// estrelas.
class _ClosedStage extends StatelessWidget {
  final double height;
  final double t;

  const _ClosedStage({required this.height, required this.t});

  /// 0→1→0 dentro da janela [from, to] do ciclo.
  double _bump(double from, double to) {
    if (t < from || t > to) return 0;
    return math.sin((t - from) / (to - from) * math.pi);
  }

  @override
  Widget build(BuildContext context) {
    final chestWidth = height * 0.66;
    final hop = _bump(0.0, 0.12);
    final peek = _bump(0.05, 0.17);
    final glint = t >= 0.22 && t <= 0.4 ? (t - 0.22) / 0.18 : 0.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: ChestSkyPainter(
              accent: AppRoles.reward,
              pulse: t,
              shine: 0.7 + 0.5 * peek,
              focus: const Offset(0.5, 0.6),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: height * 0.08,
          child: Center(
            child: Transform.translate(
              offset: Offset(0, -hop * height * 0.05),
              child: Transform.scale(
                scaleX: 1 + 0.04 * hop,
                scaleY: 1 - 0.03 * hop,
                alignment: Alignment.bottomCenter,
                child: CustomPaint(
                  size: Size(chestWidth, chestWidth * ChestPainter.aspect),
                  painter: ChestPainter(
                    lid: 0.16 * peek,
                    glow: AppRoles.reward,
                    glint: glint,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tela cheia da abertura. O baú chega fechado e a pessoa abre na mão:
/// cada toque sacode o baú e a fresta de luz cresce; no décimo a tampa
/// estoura e mostra o tesouro. Aí o baú sai de cena, a medalha toma o
/// centro com o nome grande, os raios viram a cor do nível e o Anan, lá
/// no alto, solta confete.
class DailyChestRevealScreen extends StatefulWidget {
  const DailyChestRevealScreen({super.key});

  static Route<void> route() => PageRouteBuilder<void>(
    transitionDuration: AppMotion.slow,
    reverseTransitionDuration: AppMotion.standard,
    pageBuilder: (context, animation, secondary) =>
        const DailyChestRevealScreen(),
    transitionsBuilder: (context, animation, secondary, child) =>
        FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: AppMotion.enter),
          child: child,
        ),
  );

  @override
  State<DailyChestRevealScreen> createState() => _DailyChestRevealScreenState();
}

class _DailyChestRevealScreenState extends State<DailyChestRevealScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _kick;
  late final AnimationController _burst;
  late final AnimationController _swap;
  late final AnimationController _pulse;
  bool _opening = false;

  /// Toques dados (chave das faíscas) e a carga do baú, que esvazia se a
  /// pessoa para: abrir pede toques seguidos e rápidos.
  int _hits = 0;
  double _charge = 0;
  DateTime _lastHit = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _drain;
  PilgrimChestReward? _reward;

  /// Toques até a tampa estourar: a expectativa cresce a cada um.
  static const _tapsToOpen = 10;

  /// Pausa antes de a carga começar a cair, e quanto cai por segundo.
  static const _drainDelay = Duration(milliseconds: 800);
  static const _drainPerSecond = 3.0;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(vsync: this, duration: AppMotion.slow);
    _kick = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _burst = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _swap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _drain = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_opening || _reward != null || _charge <= 0) return;
      if (DateTime.now().difference(_lastHit) < _drainDelay) return;
      setState(() => _charge = math.max(0, _charge - _drainPerSecond / 10));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_arrive());
    });
  }

  @override
  void dispose() {
    _drain?.cancel();
    _intro.dispose();
    _kick.dispose();
    _burst.dispose();
    _swap.dispose();
    _pulse.dispose();
    super.dispose();
  }

  bool get _calm => MediaQuery.disableAnimationsOf(context);

  /// O baú chega fechado. Nada é sorteado ainda: sair daqui deixa o baú
  /// para depois.
  Future<void> _arrive() async {
    if (!_calm) _pulse.repeat();
    await _intro.forward();
  }

  /// Um toque em qualquer lugar da tela carrega o baú.
  void _hit() {
    if (_opening || _reward != null) return;
    _lastHit = DateTime.now();
    setState(() {
      _hits++;
      _charge = math.min(_tapsToOpen.toDouble(), _charge + 1);
    });
    if (_charge >= _tapsToOpen) {
      unawaited(_open());
      return;
    }
    // A vibração cresce com a tensão do baú.
    _charge < _tapsToOpen * 0.5 ? ActHaptics.light() : ActHaptics.confirm();
    _kick.forward(from: 0);
  }

  Future<void> _open() async {
    if (_opening || _reward != null) return;
    setState(() {
      _opening = true;
      _charge = _tapsToOpen.toDouble();
    });
    ActHaptics.success();
    unawaited(SoundService.instance.playStreak());
    final opened = context.read<ProgressService>().openDailyChest();
    await _burst.forward();
    final reward = await opened;
    if (!mounted) return;
    final isTopTier =
        reward.tier == PilgrimMedalTier.gold ||
        reward.tier == PilgrimMedalTier.mirra;
    ActHaptics.success();
    if (isTopTier) unawaited(SoundService.instance.playComplete());
    setState(() => _reward = reward);
    await _swap.forward();
    // Libera o voltar do sistema.
    if (mounted) setState(() {});
  }

  static double _phase(double t, double from, double to, [Curve? curve]) {
    final v = ((t - from) / (to - from)).clamp(0.0, 1.0);
    return curve == null ? v : curve.transform(v);
  }

  @override
  Widget build(BuildContext context) {
    final reward = _reward;
    final pad = MediaQuery.paddingOf(context);

    return PopScope(
      canPop: !_opening || _swap.isCompleted,
      child: Material(
        color: AppColors.night,
        // A tela toda é o alvo: toques rápidos, contados ao encostar.
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: _reward == null ? (_) => _hit() : null,
                child: LayoutBuilder(
                  builder: (context, c) {
                    final w = c.maxWidth;
                    final h = c.maxHeight;
                    final ananSize = math.min(w * 0.34, 140.0);
                    final ananTop = pad.top + h * 0.04;
                    final ananBottom = ananTop + ananSize * CloudMascot.aspect;
                    // O recado do Anan fica logo abaixo dele, antes do baú.
                    const bubbleSpace = 112.0;
                    final bubbleTop = ananBottom + 10;
                    final stageTop = bubbleTop + bubbleSpace + 12;
                    // O baú usa a tela até as bolinhas; o texto da recompensa só
                    // chega depois que ele sai.
                    final chestBottom = h - pad.bottom - 96;
                    final chestWidth = math.max(
                      120.0,
                      math.min(
                        math.min(w * 0.72, 320.0),
                        (chestBottom - stageTop) / ChestPainter.aspect,
                      ),
                    );
                    final chestHeight = chestWidth * ChestPainter.aspect;
                    final chestTop =
                        stageTop +
                        (chestBottom - stageTop - chestHeight) * 0.42;
                    // Na recompensa a medalha fica entre o balão e o botão; o
                    // centro aproximado guia os raios.
                    final medalCenter =
                        (bubbleTop + 160 + h - pad.bottom - 100) / 2;

                    return AnimatedBuilder(
                      animation: Listenable.merge([
                        _intro,
                        _kick,
                        _burst,
                        _swap,
                        _pulse,
                      ]),
                      builder: (context, _) {
                        final k = _kick.value;
                        final kick = math.sin(k * math.pi);
                        final tension = _charge / _tapsToOpen;
                        final b = _burst.value;
                        // Antes do primeiro toque o baú pula de leve, chamando.
                        final idleT = (_pulse.value * 3) % 1;
                        final invite =
                            _hits == 0 && _intro.isCompleted && idleT < 0.1
                            ? math.sin(idleT / 0.1 * math.pi)
                            : 0.0;
                        final x = _swap.value;
                        final breath =
                            (math.sin(_pulse.value * math.pi * 4) + 1) / 2;
                        final tierAccent = reward != null
                            ? tierColor(reward.tier)
                            : AppRoles.reward;
                        final accent = Color.lerp(
                          AppRoles.reward,
                          tierAccent,
                          _phase(x, 0, 0.4),
                        )!;
                        // A fresta cresce a cada toque e salta no impacto.
                        final lid = b > 0
                            ? 0.35 +
                                  0.65 * _phase(b, 0, 0.55, Curves.easeOutBack)
                            : (0.14 * tension + 0.12 * kick).clamp(0.0, 0.34);
                        final shakeAngle =
                            math.sin(k * math.pi * 6) *
                            (1 - k) *
                            (0.05 + 0.06 * tension);
                        // O baú sai: encolhe, desce e some.
                        final leave = _phase(x, 0, 0.35, AppMotion.exit);
                        final medalIn = _phase(
                          x,
                          0.2,
                          0.75,
                          Curves.easeOutBack,
                        );
                        final copy = _phase(x, 0.5, 1, AppMotion.enter);
                        final burstFlash = b > 0 && b < 0.22
                            ? (1 - b / 0.22) * 0.5
                            : 0.0;
                        final swapFlash = x > 0 && x < 0.25
                            ? (1 - x / 0.25) * 0.45
                            : 0.0;
                        final hop = x > 0.15 && x < 0.55
                            ? math.sin((x - 0.15) / 0.4 * math.pi)
                            : 0.0;
                        final arriveCopy =
                            _intro.value * (1 - _phase(b, 0, 0.3));

                        return Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: ChestSkyPainter(
                                  accent: accent,
                                  pulse: _pulse.value,
                                  shine:
                                      0.5 +
                                      0.4 * tension +
                                      0.3 * kick +
                                      0.8 * b,
                                  focus: Offset(
                                    0.5,
                                    (chestTop +
                                            chestHeight * 0.5 +
                                            (medalCenter -
                                                    chestTop -
                                                    chestHeight * 0.5) *
                                                _phase(x, 0, 0.4)) /
                                        h,
                                  ),
                                  rays:
                                      _phase(b, 0.05, 0.6, AppMotion.enter) *
                                      (1 + 0.3 * medalIn),
                                  floor: false,
                                ),
                              ),
                            ),
                            Positioned(
                              top: ananTop - hop * 22 - kick * 8,
                              left: (w - ananSize) / 2,
                              child: Opacity(
                                opacity: _intro.value,
                                child: CloudMascot(
                                  face: b > 0.3
                                      ? CloudFace.sucesso
                                      : CloudFace.feliz,
                                  size: ananSize,
                                ),
                              ),
                            ),
                            if (leave < 1)
                              Positioned(
                                top:
                                    chestTop +
                                    leave * chestHeight * 0.35 -
                                    invite * chestHeight * 0.06,
                                left: (w - chestWidth) / 2,
                                child: Opacity(
                                  opacity: 1 - leave,
                                  child: Semantics(
                                    button: true,
                                    label: context.l10n.chestOpen,
                                    onTap: reward == null ? _open : null,
                                    child: Transform.rotate(
                                      angle: shakeAngle,
                                      alignment: Alignment.bottomCenter,
                                      child: Transform.scale(
                                        scale:
                                            (0.6 +
                                                0.4 *
                                                    AppMotion.pop.transform(
                                                      _intro.value,
                                                    )) *
                                            (1 +
                                                0.07 * kick +
                                                0.03 * tension * (1 - b)) *
                                            (1 - 0.4 * leave),
                                        alignment: Alignment.bottomCenter,
                                        child: CustomPaint(
                                          size: Size(chestWidth, chestHeight),
                                          painter: ChestPainter(
                                            lid: lid,
                                            glow: accent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // Faíscas a cada toque.
                            if (_hits > 0 && reward == null)
                              Positioned(
                                top: chestTop,
                                left: (w - chestWidth) / 2,
                                width: chestWidth,
                                height: chestHeight * 0.9,
                                child: ActSparkBurst(
                                  key: ValueKey(_hits),
                                  active: true,
                                  color: AppColors.accentBright,
                                ),
                              ),
                            // A recompensa: o Anan conta no balão o que saiu, a
                            // medalha no meio e o botão embaixo.
                            if (reward != null)
                              Positioned.fill(
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    AppSpace.xl,
                                    bubbleTop,
                                    AppSpace.xl,
                                    pad.bottom + AppSpace.xl,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Opacity(
                                        opacity: copy,
                                        child: AnanSpeechBubble(
                                          padding: const EdgeInsets.fromLTRB(
                                            20,
                                            16,
                                            20,
                                            18,
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SoftBadge(
                                                text: _headline(reward.tier),
                                                accent: Color.lerp(
                                                  tierAccent,
                                                  Colors.black,
                                                  0.25,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: AppSpace.sm,
                                              ),
                                              Text(
                                                reward.title,
                                                textAlign: TextAlign.center,
                                                style: AppTypography.display(
                                                  size: 30,
                                                  weight: FontWeight.w900,
                                                  color: AnanSpeechBubble.ink,
                                                ).copyWith(height: 1.05),
                                              ),
                                              const SizedBox(
                                                height: AppSpace.xs,
                                              ),
                                              Text(
                                                reward.message,
                                                textAlign: TextAlign.center,
                                                style: AppTypography.body(
                                                  size: 15,
                                                  height: 1.4,
                                                  color: AnanSpeechBubble.muted,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpace.lg),
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (context, box) {
                                            final medalSize = math.min(
                                              w * 0.56,
                                              box.maxHeight / 1.25 * 0.95,
                                            );
                                            return Center(
                                              child: Opacity(
                                                opacity: _phase(x, 0.2, 0.4),
                                                child: Transform.scale(
                                                  scale: 0.3 + 0.7 * medalIn,
                                                  child: Transform.rotate(
                                                    angle: (1 - medalIn) * -0.5,
                                                    child: DecoratedBox(
                                                      // Luz do nível atrás: a
                                                      // medalha descola dos raios.
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: tierAccent
                                                                .withValues(
                                                                  alpha:
                                                                      0.35 +
                                                                      0.15 *
                                                                          breath,
                                                                ),
                                                            blurRadius:
                                                                medalSize *
                                                                0.35,
                                                            spreadRadius:
                                                                medalSize *
                                                                0.02,
                                                          ),
                                                        ],
                                                      ),
                                                      child: MedalArt(
                                                        ribbons: true,
                                                        metal: _medalMetal(
                                                          reward.tier,
                                                        ),
                                                        ribbon: _medalRibbon(
                                                          reward.tier,
                                                        ),
                                                        mark:
                                                            ChestMark.forReward(
                                                              reward.id,
                                                            ),
                                                        size: medalSize,
                                                        shine:
                                                            (_pulse.value * 2) %
                                                            1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: AppSpace.lg),
                                      Opacity(
                                        opacity: copy,
                                        child: CopperCta(
                                          label: context.l10n.commonContinue,
                                          onTap: copy < 0.5
                                              ? null
                                              : () => Navigator.pop(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (burstFlash + swapFlash > 0)
                              Positioned.fill(
                                child: IgnorePointer(
                                  child: ColoredBox(
                                    color: Colors.white.withValues(
                                      alpha: burstFlash + swapFlash,
                                    ),
                                  ),
                                ),
                              ),
                            // O Anan fala: o recado num balão com a ponta para ele.
                            if (reward == null)
                              Positioned(
                                top: bubbleTop,
                                left: AppSpace.xl,
                                right: AppSpace.xl,
                                child: IgnorePointer(
                                  child: Opacity(
                                    opacity: arriveCopy,
                                    child: AnanSpeechBubble(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        14,
                                        20,
                                        16,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            context.l10n.chestOfferTitle,
                                            textAlign: TextAlign.center,
                                            style: AppTypography.title(
                                              size: 18,
                                              height: 1.15,
                                              color: AnanSpeechBubble.ink,
                                            ),
                                          ),
                                          const SizedBox(height: AppSpace.xs),
                                          Text(
                                            context.l10n.chestTapHint,
                                            textAlign: TextAlign.center,
                                            style: AppTypography.body(
                                              size: 14,
                                              color: AnanSpeechBubble.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (reward == null)
                              Positioned(
                                top: chestTop + chestHeight + AppSpace.xl,
                                left: 0,
                                right: 0,
                                child: Opacity(
                                  opacity: arriveCopy,
                                  child: _TapProgress(value: tension),
                                ),
                              ),
                            // O Anan solta o confete lá de cima.
                            if (reward != null)
                              Positioned.fill(
                                child: ConfettiOverlay(
                                  active: true,
                                  cinematic: true,
                                  source: Offset(0.5, (ananBottom - 8) / h),
                                  sourceSpan: ananSize * 0.7 / w,
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            // Sair sem abrir: o baú espera na Hoje.
            if (_reward == null && !_opening)
              Positioned(
                top: MediaQuery.paddingOf(context).top + AppSpace.sm,
                right: AppSpace.sm,
                child: IconButton(
                  tooltip: context.l10n.commonClose,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const CinematicIcon(
                    glyph: CinematicGlyph.close,
                    size: AppMetrics.iconLg,
                    accent: AppColors.textMutedDark,
                    framed: false,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Metal da medalha: o do app, e a mirra do baú em ouro claro.
  static Color _medalMetal(PilgrimMedalTier tier) =>
      tier == PilgrimMedalTier.mirra
      ? AppColors.accentBright
      : MedalArt.metalFor(tier);

  /// A mais rara troca o azul das fitas pela violeta do raro.
  static Color _medalRibbon(PilgrimMedalTier tier) => switch (tier) {
    PilgrimMedalTier.mirra => AppColors.medalAurora,
    PilgrimMedalTier.gold => AppColors.coral,
    _ => AppColors.primary,
  };

  /// Quão rara é a recompensa — o nível vira palavra que se entende.
  String _headline(PilgrimMedalTier tier) => switch (tier) {
    PilgrimMedalTier.bronze => context.l10n.chestRarityUncommon,
    PilgrimMedalTier.silver => context.l10n.chestRarityRare,
    PilgrimMedalTier.gold => context.l10n.chestRarityVeryRare,
    PilgrimMedalTier.mirra => context.l10n.chestRarityUltra,
    _ => context.l10n.chestRarityCommon,
  };
}

/// Quantos toques faltam: uma barra fina que enche a cada toque no baú.
class _TapProgress extends StatelessWidget {
  final double value;

  const _TapProgress({required this.value});

  @override
  Widget build(BuildContext context) {
    final fraction = value.clamp(0.0, 1.0);
    return Center(
      child: SizedBox(
        width: 140,
        height: 4,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.textMutedDark.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedFractionallySizedBox(
              duration: AppMotion.quick,
              curve: Curves.easeOutCubic,
              widthFactor: fraction,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppRoles.reward,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppRoles.reward.withValues(alpha: 0.35),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
