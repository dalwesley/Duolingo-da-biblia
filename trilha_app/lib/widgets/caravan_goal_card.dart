import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_language.dart';
import '../services/league_service.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'anan_speech.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'postcard.dart';
import 'ui_primitives.dart';
import 'profile_section.dart';

/// Postal da Caravana: a meta coletiva do mês revela uma pintura que quem
/// caminhou guarda no álbum. Ver [CaravanGoalCard].
class CaravanPostcards {
  CaravanPostcards._();

  /// Uma pintura por mês do ano (as das jornadas), em rodízio.
  static const _art = [
    'assets/art/journey_pazNoDia.jpg',
    'assets/art/journey_oracao.jpg',
    'assets/art/journey_sabedoria.jpg',
    'assets/art/journey_promessaCumprimento.jpg',
    'assets/art/journey_parabolasMilagres.jpg',
    'assets/art/journey_personagens.jpg',
    'assets/art/journey_panorama.jpg',
    'assets/art/journey_discipulado.jpg',
    'assets/art/journey_conhecerADeus.jpg',
    'assets/art/journey_temasBiblicos.jpg',
    'assets/art/journey_antigoTestamento.jpg',
    'assets/art/journey_novoTestamento.jpg',
  ];

  /// Um versículo por mês sobre caminhar juntos — vai na faixa e no
  /// carimbo, como a referência dos postais de cena. Por idioma.
  static const _verses = {
    'pt': [
      'Salmos 84:7',
      'Eclesiastes 4:9',
      'Êxodo 13:21',
      'Lucas 24:15',
      'Salmos 133:1',
      'Hebreus 12:1',
      'Isaías 40:31',
      'Rute 1:16',
      'Provérbios 27:17',
      'Hebreus 10:24',
      '1 Samuel 7:12',
      'Lucas 2:44',
    ],
    'en': [
      'Psalm 84:7',
      'Ecclesiastes 4:9',
      'Exodus 13:21',
      'Luke 24:15',
      'Psalm 133:1',
      'Hebrews 12:1',
      'Isaiah 40:31',
      'Ruth 1:16',
      'Proverbs 27:17',
      'Hebrews 10:24',
      '1 Samuel 7:12',
      'Luke 2:44',
    ],
    'es': [
      'Salmos 84:7',
      'Eclesiastés 4:9',
      'Éxodo 13:21',
      'Lucas 24:15',
      'Salmos 133:1',
      'Hebreos 12:1',
      'Isaías 40:31',
      'Rut 1:16',
      'Proverbios 27:17',
      'Hebreos 10:24',
      '1 Samuel 7:12',
      'Lucas 2:44',
    ],
  };

  /// Pintura do postal do mês [month] ("YYYY-MM").
  static String artOf(String month) => _art[_parse(month).$2 - 1];

  /// Nome do mês [month] ("YYYY-MM") no idioma do app ("novembro").
  static String monthName(BuildContext context, String month) {
    final (year, m) = _parse(month);
    return DateFormat.MMMM(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(DateTime(year, m));
  }

  static (int, int) _parse(String month) {
    final parts = month.split('-');
    final year = int.tryParse(parts.first) ?? DateTime.now().year;
    final m = (int.tryParse(parts.length > 1 ? parts[1] : '') ?? 1).clamp(
      1,
      12,
    );
    return (year, m);
  }

  /// Postal do mês [month] ("YYYY-MM"). [scenes] = cenas da caravana
  /// (0 = sem número na frase). [on] = dia em que foi guardado.
  static Postcard of(
    BuildContext context,
    String month, {
    int scenes = 0,
    DateTime? on,
  }) {
    final l10n = context.l10n;
    final (_, m) = _parse(month);
    final verses =
        _verses[Localizations.localeOf(context).languageCode] ?? _verses['pt']!;
    return Postcard(
      slug: 'caravana-$month',
      title: l10n.caravanPostcardTitle(monthName(context, month)),
      ref: verses[m - 1],
      insight: scenes > 0 ? l10n.caravanPostcardInsight(scenes) : '',
      art: _art[m - 1],
      on: on ?? DateTime.now(),
    );
  }
}

/// A etapa do mês: a caravana inteira caminha rumo a um marco (o postal do
/// mês). O caminho desenhado mostra o Anan levando a caravana; dois pousos
/// (fogueiras) revelam pedaços do postal e, na chegada, quem fez
/// [LeagueService.goalMinScenes] cenas guarda o marco no álbum. O Anan diz
/// o ritmo; atrasada, a etapa chama alguém para caminhar junto.
class CaravanGoalCard extends StatefulWidget {
  final int scenes;
  final int goal;
  final int myScenes;

  const CaravanGoalCard({
    super.key,
    required this.scenes,
    required this.goal,
    required this.myScenes,
  });

  @override
  State<CaravanGoalCard> createState() => _CaravanGoalCardState();
}

class _CaravanGoalCardState extends State<CaravanGoalCard> {
  static String _seenKey(String month) => 'caravanStopSeen_$month';
  static String _advanceKey(String month) => 'caravanAdvance_$month';

  /// Dias desde a última vez que a soma da caravana subiu (visto daqui).
  int _sinceAdvance = 0;

  /// Progresso (0–1) e revelação de onde a animação parte: o que a pessoa
  /// viu na última visita. `null` até ler.
  double? _fromProgress;
  double? _fromReveal;

  String get _month => LeagueService.monthKey();
  int get _done =>
      widget.scenes < widget.myScenes ? widget.myScenes : widget.scenes;

  @override
  void initState() {
    super.initState();
    _loadSeen();
  }

  @override
  void didUpdateWidget(covariant CaravanGoalCard old) {
    super.didUpdateWidget(old);
    if (old.scenes != widget.scenes || old.goal != widget.goal) _loadSeen();
  }

  /// Pouso visto por último: a trilha anima dali e, se a caravana passou de
  /// um pouso desde então, o pedaço novo se revela com aviso.
  Future<void> _loadSeen() async {
    final goal = widget.goal;
    final done = _done;
    final stop = LeagueService.goalStop(scenes: done, goal: goal);
    var seen = -1;
    SharedPreferences? prefs;
    var since = 0;
    try {
      prefs = await SharedPreferences.getInstance();
      seen = prefs.getInt(_seenKey(_month)) ?? -1;
      // "soma|dia" da última subida: soma maior = andou hoje.
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final raw = prefs.getString(_advanceKey(_month))?.split('|');
      final lastDone = int.tryParse(raw?.first ?? '') ?? -1;
      final lastDay = DateTime.tryParse(
        raw != null && raw.length > 1 ? raw[1] : '',
      );
      if (done > lastDone || lastDay == null) {
        await prefs.setString(
          _advanceKey(_month),
          '$done|${today.toIso8601String().substring(0, 10)}',
        );
      } else {
        since = today.difference(lastDay).inDays;
      }
    } catch (_) {}
    if (!mounted) return;
    _sinceAdvance = since;
    final stops = LeagueService.goalMilestones;
    setState(() {
      _fromProgress = seen < 0 ? 0 : stops[seen];
      _fromReveal = seen < 0 ? 0 : stops[seen];
    });
    if (stop <= seen) return;
    // Pouso novo (a chegada tem a revelação própria): avisa depois que a
    // trilha andou — e só com a aba à vista; fora dela, fica para depois.
    if (stop < stops.length - 1) {
      await Future<void>.delayed(const Duration(milliseconds: 1400));
      if (!mounted || !TickerMode.valuesOf(context).enabled) return;
    }
    try {
      await prefs?.setInt(_seenKey(_month), stop);
    } catch (_) {}
    if (!mounted || stop >= stops.length - 1) return;
    ActHaptics.success();
    await showAppToastFor(
      context,
      message: context.l10n.caravanStopToast(_stopName(context, stop)),
      glyph: CinematicGlyph.flame,
      face: CloudFace.sucesso,
    );
  }

  static String _stopName(BuildContext context, int i) {
    final l10n = context.l10n;
    return switch (i) {
      0 => l10n.caravanStop1,
      1 => l10n.caravanStop2,
      _ => l10n.caravanArrival,
    };
  }

  Future<void> _claim(Postcard card) async {
    ActHaptics.success();
    await context.read<ProgressService>().saveCaravanPostcard(_month);
    if (!mounted) return;
    await showPostcardReveal(
      context,
      card,
      eyebrow: context.l10n.caravanPostcardArrived,
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    // Papel do cartão: no claro, o mesmo papel dos cards de Explorar (a
    // pintura se dissolve no branco); no escuro, o fundo do card.
    final fill = a.onDark
        ? a.cardFill
        : Color.lerp(a.cardFill, Colors.white, 0.45)!;
    final l10n = context.l10n;
    final month = _month;
    final goal = widget.goal;
    final myScenes = widget.myScenes;
    final claimed = context.select(
      (ProgressService p) => p.caravanPostcards.containsKey(month),
    );
    final done = _done;
    final progress = goal <= 0 ? 0.0 : (done / goal).clamp(0.0, 1.0);
    final reveal = LeagueService.goalReveal(scenes: done, goal: goal);
    final need = LeagueService.goalMinScenes - myScenes;
    final card = CaravanPostcards.of(context, month, scenes: done);
    final name = CaravanPostcards.monthName(context, month);
    final pace = LeagueService.goalPace(done: done, goal: goal);
    const tone = AppRoles.navTogether;
    final reduced = AppMotion.reduced(context);
    final fromP = reduced ? progress : (_fromProgress ?? progress);
    final fromR = reduced ? reveal : (_fromReveal ?? reveal);

    // O Anan diz uma coisa só, a que importa agora. Antes da chegada, o
    // que falta para o postal ser seu vem primeiro; depois, o ritmo.
    final mood = LeagueService.goalMood(
      done: done,
      goal: goal,
      daysSinceAdvance: _sinceAdvance,
    );
    // Frase do dia: muda a cada dia, igual para todos no mesmo dia.
    final sayings = [
      l10n.caravanAnanSaying1,
      l10n.caravanAnanSaying2,
      l10n.caravanAnanSaying3,
      l10n.caravanAnanSaying4,
      l10n.caravanAnanSaying5,
    ];
    final saying = sayings[DateTime.now().day % sayings.length];
    final (CloudFace face, String line) = switch (pace.pace) {
      _ when claimed => (CloudFace.sucesso, l10n.caravanClaimedAnan),
      GoalPace.reached when need > 0 => (
        CloudFace.feliz,
        l10n.caravanAnanArrivedNeed(need),
      ),
      GoalPace.reached => (CloudFace.sucesso, l10n.caravanAnanArrived(name)),
      _ when need > 0 => (CloudFace.feliz, l10n.caravanAnanNeedYou(need, name)),
      _ => switch (mood.mood) {
        GoalMood.starting => (CloudFace.feliz, l10n.caravanAnanStart),
        GoalMood.finalStretch => (
          CloudFace.feliz,
          l10n.caravanAnanFinal(mood.days, mood.left),
        ),
        GoalMood.stalled => (
          CloudFace.triste,
          l10n.caravanAnanStalled(mood.days),
        ),
        GoalMood.fast => (
          CloudFace.sucesso,
          l10n.caravanAnanFast(mood.arrivalDay),
        ),
        GoalMood.steady => (CloudFace.feliz, saying),
      },
    };

    final canClaim = pace.pace == GoalPace.reached && need <= 0 && !claimed;
    // A capa: a pintura do postal, embaçada no começo e cada vez mais
    // nítida conforme a caravana anda — o convite é ver o resto. Na
    // proporção da pintura (~2.4:1), com título e contagem no céu (canto
    // de cima) — a paisagem do pé fica à mostra.
    final cover = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 2.4,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ClipRect: o desfoque da pintura não vaza para baixo da capa.
              // A pintura para 3px antes do pé (já cor cheia do degradê): a
              // emenda cai em meio pixel e a pintura aparecia ali como linha.
              Positioned.fill(
                bottom: 3,
                child: ClipRect(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: fromR, end: claimed ? 1 : reveal),
                    duration: reduced
                        ? Duration.zero
                        : const Duration(milliseconds: 1600),
                    curve: const Interval(0.45, 1, curve: Curves.easeOut),
                    builder: (context, r, child) {
                      final sigma = 14.0 * (1 - r);
                      return ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                          sigmaX: sigma,
                          sigmaY: sigma,
                          tileMode: TileMode.decal,
                        ),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      CaravanPostcards.artOf(month),
                      fit: BoxFit.cover,
                      cacheWidth: 720,
                    ),
                  ),
                ),
              ),
              // Pé da pintura afunda no cartão (como no Advento): capa e corpo
              // viram uma peça só.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      fill.withValues(alpha: 0),
                      fill.withValues(alpha: 0.6),
                      fill,
                    ],
                    // Cheio antes do fim: a borda da pintura desfocada não
                    // vira uma linha na emenda.
                    stops: const [0.55, 0.82, 0.97],
                  ),
                ),
              ),
              // Véu no canto de cima à esquerda: o título mora no céu da
              // pintura e precisa ler em qualquer mês e tema.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.centerRight,
                    colors: [
                      fill.withValues(alpha: 0.7),
                      fill.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                top: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: a.onDark
                            ? Colors.black.withValues(alpha: 0.35)
                            : Colors.white.withValues(alpha: 0.75),
                        border: Border.all(color: tone.withValues(alpha: 0.6)),
                      ),
                      child: SectionLabel(
                        l10n.caravanGoalTitle(name),
                        size: 10,
                        color: a.onDark ? tone : a.ink(tone),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                    // Uma linha só, encolhendo se faltar largura: com
                    // a contagem também no céu, duas linhas não cabem.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.caravanGoalHeadline(name),
                        maxLines: 1,
                        softWrap: false,
                        style:
                            AppTypography.display(
                              size: 26,
                              height: 1.05,
                              color: a.text,
                            ).copyWith(
                              shadows: [
                                Shadow(
                                  color: tone.withValues(
                                    alpha: a.onDark ? 0.55 : 0.2,
                                  ),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: fromP * goal, end: done.toDouble()),
                      duration: AppMotion.scene,
                      curve: AppMotion.enter,
                      builder: (context, v, _) => Text(
                        l10n.caravanGoalCount(
                          math.min(v.round(), goal),
                          goal,
                          myScenes,
                        ),
                        style: AppTypography.display(
                          size: 17,
                          weight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: a.onDark
                              ? Color.lerp(tone, Colors.white, 0.55)!
                              : a.ink(tone),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return ProfilePanel(
      accent: tone,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
        // Fundo cheio na cor do cartão: o degradê da capa termina nele.
        child: ColoredBox(
          color: fill,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: claimed ? () => showPostcardDetail(context, card) : null,
                child: cover,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // A trilha e a fala andam juntas: a ponta do balão sai
                    // do Anan, onde quer que a caravana esteja.
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: fromP, end: progress),
                      duration: reduced
                          ? Duration.zero
                          : const Duration(milliseconds: 1200),
                      curve: Curves.easeInOutCubic,
                      builder: (context, v, _) => LayoutBuilder(
                        builder: (context, box) => Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _CaravanTrail(
                              progress: v,
                              tone: tone,
                              ananFace: face,
                              destination: CinematicIcon(
                                glyph: CinematicGlyph.gift,
                                size: 26,
                                accent: v >= 1 ? AppRoles.reward : a.textFaint,
                                framed: false,
                              ),
                            ),
                            _TrailBubble(
                              tailX: _CaravanTrail.ananX(box.maxWidth, v),
                              child: Text(
                                line,
                                style: AppTypography.body(
                                  size: 13,
                                  height: 1.35,
                                  weight: FontWeight.w700,
                                  color: AnanSpeechBubble.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (canClaim || claimed)
                      const SizedBox(height: AppSpace.md),
                    if (canClaim)
                      CopperCta(
                        label: l10n.caravanGoalClaim,
                        leading: CinematicGlyph.gift,
                        trailing: null,
                        onTap: () => _claim(card),
                      )
                    else if (claimed)
                      GhostCta(
                        label: l10n.caravanSeePostcard,
                        leading: CinematicGlyph.gift,
                        expanded: true,
                        onTap: () => showPostcardDetail(context, card),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// O caminho da etapa: uma trilha sinuosa com duas fogueiras (os pousos) e
/// o postal do mês na chegada. O trecho andado ganha cor e o Anan vai à frente
/// da caravana, no ponto em que ela está.
class _CaravanTrail extends StatelessWidget {
  final double progress;
  final Color tone;

  /// O que espera no fim do caminho (o postal do mês).
  final Widget destination;

  /// A cara do Anan: a da fala dele no balão logo abaixo.
  final CloudFace ananFace;

  const _CaravanTrail({
    required this.progress,
    required this.tone,
    required this.destination,
    this.ananFace = CloudFace.feliz,
  });

  /// Onde o Anan está (x) numa trilha de largura [width] em [progress] —
  /// a ponta do balão aponta para ele.
  static double ananX(double width, double progress) {
    final metric = _path(Size(width, _height)).computeMetrics().first;
    return metric
        .getTangentForOffset(metric.length * progress.clamp(0.0, 1.0))!
        .position
        .dx;
  }

  static const destinationWidth = 30.0;
  static const _height = 78.0;
  static const _anan = 42.0;

  static Path _path(Size size) {
    const left = 14.0;
    const right = destinationWidth / 2 + 6;
    final w = size.width - left - right;
    final mid = size.height * 0.56;
    final amp = size.height * 0.1;
    final path = Path()..moveTo(left, mid);
    const steps = 48;
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      path.lineTo(left + w * t, mid - amp * math.sin(t * math.pi * 2.2));
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final stops = LeagueService.goalMilestones;
    final names = [l10n.caravanStop1, l10n.caravanStop2, l10n.caravanArrival];
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, _height);
        final metric = _path(size).computeMetrics().first;
        Offset at(double f) =>
            metric.getTangentForOffset(metric.length * f)!.position;
        final me = at(progress.clamp(0.0, 1.0));
        final end = at(1);
        const destH = destinationWidth;
        final destTop = end.dy - destH / 2;
        return SizedBox(
          height: _height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _TrailPainter(
                    metric: metric,
                    progress: progress,
                    tone: tone,
                    track: a.progressTrack,
                  ),
                ),
              ),
              for (var i = 0; i < stops.length - 1; i++) ...[
                // O Anan em cima do pouso esconde a fogueira (não brigam).
                if ((progress - stops[i]).abs() > 0.1)
                  Positioned(
                    left: at(stops[i]).dx - 11,
                    top: at(stops[i]).dy - 24,
                    child: CinematicIcon(
                      glyph: CinematicGlyph.flame,
                      size: 22,
                      accent: progress >= stops[i] ? tone : a.textFaint,
                      framed: false,
                    ),
                  ),
                Positioned(
                  left: at(stops[i]).dx - 40,
                  top: at(stops[i]).dy + 9,
                  width: 80,
                  child: Text(
                    names[i],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: AppTypography.label(
                      size: 10,
                      letterSpacing: 0,
                      color: progress >= stops[i] ? a.text : a.textFaint,
                    ),
                  ),
                ),
              ],
              // A chegada: o postal do mês, no fim do caminho.
              Positioned(
                left: end.dx - destinationWidth / 2,
                top: destTop,
                child: destination,
              ),
              // O Anan à frente da caravana; na chegada, pousa no postal.
              Positioned(
                left: me.dx - _anan / 2,
                top: progress >= 0.97
                    ? destTop - _anan + 10
                    : me.dy - _anan + 8,
                child: CloudMascot(face: ananFace, size: _anan, react: false),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TrailPainter extends CustomPainter {
  final ui.PathMetric metric;
  final double progress;
  final Color tone;
  final Color track;

  _TrailPainter({
    required this.metric,
    required this.progress,
    required this.tone,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ainda por andar: pegadas tracejadas.
    final dash = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (double d = 0; d < metric.length; d += 12) {
      canvas.drawPath(metric.extractPath(d, d + 5), dash);
    }
    final walked = metric.length * progress.clamp(0.0, 1.0);
    if (walked <= 0) return;
    final done = metric.extractPath(0, walked);
    canvas.drawPath(
      done,
      Paint()
        ..color = tone.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      done,
      Paint()
        ..color = tone
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TrailPainter old) =>
      old.progress != progress || old.tone != tone || old.track != track;
}

/// O balão do Anan sem o Anan: ele está na trilha logo acima, e a ponta do
/// balão sobe até ele ([tailX]).
class _TrailBubble extends StatelessWidget {
  final double tailX;
  final Widget child;

  const _TrailBubble({required this.tailX, required this.child});

  static const _tail = 10.0;
  static const _radius = 18.0;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _TrailBubblePainter(tailX: tailX),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, _tail + 10, 14, 12),
        child: child,
      ),
    );
  }
}

class _TrailBubblePainter extends CustomPainter {
  final double tailX;

  _TrailBubblePainter({required this.tailX});

  @override
  void paint(Canvas canvas, Size size) {
    const t = _TrailBubble._tail;
    const r = _TrailBubble._radius;
    final x = tailX.clamp(r + t, size.width - r - t);
    final body = RRect.fromLTRBR(
      0,
      t,
      size.width,
      size.height,
      const Radius.circular(r),
    );
    final path = Path()
      ..addRRect(body)
      ..moveTo(x - t, t + 1)
      ..lineTo(x, 0)
      ..lineTo(x + t, t + 1)
      ..close();
    final shape = Path.combine(
      PathOperation.union,
      path,
      Path()..addRRect(body),
    );
    canvas.drawPath(
      shape,
      Paint()
        ..color = AnanSpeechBubble.rim.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(shape, Paint()..color = AnanSpeechBubble.fill);
    canvas.drawPath(
      shape,
      Paint()
        ..color = AnanSpeechBubble.rim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_TrailBubblePainter old) => old.tailX != tailX;
}
