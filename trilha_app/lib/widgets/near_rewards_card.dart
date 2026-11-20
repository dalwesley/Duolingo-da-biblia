import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/entry_trails.dart';
import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/caravan_pilgrim_profile.dart';
import '../models/pilgrim_medals.dart';
import '../models/trail.dart';
import '../screens/paywall_screen.dart';
import '../screens/trail_map_screen.dart';
import '../services/analytics_service.dart';
import '../services/backend_service.dart';
import '../services/progress_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/plus_access.dart';
import '../utils/trail_progress.dart';
import 'act_feel.dart';
import 'cinematic_icon.dart';
import 'free_slot_gate.dart';
import 'medal_unlock_sheet.dart';

/// Um prêmio perto: título, quanto falta, o quanto já foi (0–1) e para
/// onde o toque leva.
class _Near {
  final CinematicGlyph glyph;
  final Color accent;
  final String title;

  /// Nível da medalha (Bronze, Prata…), abaixo do nome.
  final String? tag;
  final String line;
  final double progress;

  /// Quanto falta, na unidade do prêmio: ordena a lista.
  final int remaining;
  final String kind;
  final Future<void> Function(BuildContext context) open;

  const _Near({
    required this.glyph,
    required this.accent,
    required this.title,
    this.tag,
    required this.line,
    required this.progress,
    required this.remaining,
    required this.kind,
    required this.open,
  });
}

/// O que está perto em cada gaveta do Cofre.
enum NearKind { postcards, medals, seals }

/// "Quase lá" dentro do Cofre: os prêmios a poucos passos da gaveta aberta
/// (medalha, selo de personagem, álbum de postais quase cheio), como uma
/// prateleira iluminada. Some quando nada está perto.
class NearRewardsCard extends StatefulWidget {
  final NearKind kind;

  /// Linha fina com o prêmio mais perto (vitrine do Cofre); false mostra os
  /// tíquetes (coleção completa).
  final bool slim;

  const NearRewardsCard({super.key, required this.kind, this.slim = false});

  static String _kindKey(NearKind k) => switch (k) {
    NearKind.postcards => 'album',
    NearKind.medals => 'medal',
    NearKind.seals => 'seal',
  };

  static const maxItems = 3;

  /// Álbum entra quando faltam até tantos postais.
  static const albumWithin = 3;

  @override
  State<NearRewardsCard> createState() => _NearRewardsCardState();
}

class _NearRewardsCardState extends State<NearRewardsCard> {
  late final Future<List<Trail>> _trails = TrailRepository().getTrails();

  /// Usa o context do State, não o da linha: o "Sair" muda a lista e a
  /// linha tocada pode sumir antes de o mapa abrir.
  Future<void> _openTrail(String slug, {required List<Trail> trails}) async {
    final trail = trails.where((t) => t.slug == slug).firstOrNull;
    if (trail == null) return;
    final sub = context.read<SubscriptionService>();
    // Grátis: paywall / folha com push (não replacement) — o Perfil fica.
    if (PlusAccess.trailIsPlus(trail) && !sub.plusFeaturesOpen) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const PaywallScreen(source: 'profile_near'),
        ),
      );
      return;
    }
    if (!await ensureFreeSlotAllows(
      context,
      trail,
      trails: trails,
      replaceRoute: false,
    )) {
      return;
    }
    if (!mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => TrailMapScreen(slug: slug)));
  }

  List<_Near> _items(ProgressService p, String uid, List<Trail> trails) {
    final l10n = context.l10n;
    final items = <_Near>[];
    final completed = p.completedMissions;

    // Medalhas: as trilhas mais perto do próximo nível.
    final profile = CaravanPilgrimProfile.fromProgress(progress: p, uid: uid);
    final ctx = PilgrimMedalEvalContext.fromProgress(p);
    for (final m in PilgrimMedals.nearestLockedList(
      profile: profile,
      catalog: trails,
      ctx: ctx,
    )) {
      items.add(
        _Near(
          glyph: m.track.glyph,
          accent: tierColor(m.nextLevel.tier),
          title: m.track.title,
          tag: tierLabel(m.nextLevel.tier),
          line: m.remainingLabel,
          progress: m.target <= 0 ? 0 : m.current / m.target,
          remaining: m.remaining,
          kind: 'medal',
          open: (context) async {
            for (final vault in PilgrimMedals.evaluateVaults(
              profile: profile,
              catalog: trails,
              ctx: ctx,
            )) {
              for (final track in vault.tracks) {
                if (track.track.id == m.track.id) {
                  await showTrackDetailSheet(context, track);
                  return;
                }
              }
            }
          },
        ),
      );
    }

    // Selo de personagem: a cena dele é a próxima da trilha (aberta).
    for (final seal in CharacterSeals.all) {
      if (completed.contains(seal.missionSlug)) continue;
      final trail = trails.where((t) => t.slug == seal.trailSlug).firstOrNull;
      if (trail == null ||
          !TrailProgress.isTrailUnlocked(
            trail,
            trails,
            completed,
            clearedTrailModes: p.clearedTrailModes,
          ) ||
          TrailProgress.getCurrentMission(trail, completed)?.slug !=
              seal.missionSlug) {
        continue;
      }
      items.add(
        _Near(
          glyph: seal.glyph,
          accent: AppRoles.reward,
          title: l10n.profileNearSeal(seal.name),
          line: l10n.profileNearSealLine(trail.localizedTitle),
          progress: 0.9,
          remaining: 1,
          kind: 'seal',
          open: (_) => _openTrail(trail.slug, trails: trails),
        ),
      );
    }

    // Álbum de postais quase cheio.
    final revealed = {...p.missionCompletedOn.keys, ...p.postcardsOn.keys};
    for (final t in trails) {
      if (t.comingSoon || t.missionSlugs.isEmpty) continue;
      final total = t.missionSlugs.length;
      final done = t.missionSlugs.where(revealed.contains).length;
      final left = total - done;
      if (done == 0 || left <= 0 || left > NearRewardsCard.albumWithin) {
        continue;
      }
      items.add(
        _Near(
          glyph: CinematicGlyph.gem,
          accent: AppRoles.reward,
          title: l10n.profileNearAlbum(t.localizedTitle),
          line: l10n.profileNearAlbumLine(done, total, left),
          progress: done / total,
          remaining: left,
          kind: 'album',
          open: (_) => _openTrail(t.slug, trails: trails),
        ),
      );
    }

    items.sort((a, b) => a.remaining.compareTo(b.remaining));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ProgressService>();
    final uid = context.read<BackendService>().uid ?? '';
    return FutureBuilder<List<Trail>>(
      future: _trails,
      builder: (context, snap) {
        final trails = snap.data;
        if (trails == null || trails.isEmpty) return const SizedBox.shrink();
        final key = NearRewardsCard._kindKey(widget.kind);
        final items = _items(
          p,
          uid,
          trails,
        ).where((i) => i.kind == key).take(NearRewardsCard.maxItems).toList();
        if (items.isEmpty) return const SizedBox.shrink();
        final a = Appearance.of(context);
        if (widget.slim) return _NearLine(item: items.first);
        // "Quase lá": tíquetes de prêmio, um ao lado do outro (rolam se
        // houver mais de um).
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const CinematicIcon(
                    glyph: CinematicGlyph.spark,
                    size: 13,
                    accent: AppRoles.reward,
                    framed: false,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.l10n.profileNearTitle.toUpperCase(),
                    style: AppTypography.label(
                      size: 10.5,
                      letterSpacing: 1.2,
                      weight: FontWeight.w900,
                      color: a.ink(AppRoles.reward),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              if (items.length == 1)
                _NearCoin(item: items.first, order: 0)
              else
                SizedBox(
                  height: _NearCoin.height,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpace.sm),
                    itemBuilder: (context, i) => SizedBox(
                      width: 250,
                      child: _NearCoin(item: items[i], order: i),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Uma linha: anel pequeno com a medalha, "Quase lá: Álbum Oração ·
/// faltam 3" e a seta. Fica no pé da vitrine, sem pesar.
class _NearLine extends StatelessWidget {
  final _Near item;

  const _NearLine({required this.item});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = a.ink(item.accent);
    final progress = item.progress.clamp(0.0, 1.0);
    return Semantics(
      button: true,
      label: '${context.l10n.profileNearTitle}: ${item.title} · ${item.line}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ActHaptics.tap();
          AnalyticsService.instance.logEvent('profile_near_open', {
            'kind': item.kind,
            'remaining': item.remaining,
          });
          item.open(context);
        },
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpace.sm),
          child: Row(
            children: [
              SizedBox(
                width: 26,
                height: 26,
                child: CustomPaint(
                  painter: _CoinRingPainter(
                    value: progress,
                    tone: ink,
                    track: a.progressTrack,
                    thin: true,
                  ),
                  child: Center(
                    child: CinematicIcon(
                      glyph: item.glyph,
                      size: 12,
                      accent: ink,
                      framed: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${context.l10n.profileNearTitle}  ',
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w900,
                          color: a.ink(AppRoles.reward),
                        ),
                      ),
                      TextSpan(
                        text: '${item.title} · ${item.line}',
                        style: AppTypography.body(
                          size: 12,
                          weight: FontWeight.w700,
                          color: a.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              CinematicIcon(
                glyph: CinematicGlyph.chevron,
                size: 12,
                accent: a.textFaint,
                framed: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tíquete do prêmio perto: a medalha de metal no anel de progresso à
/// esquerda, nome, nível e quanto falta à direita.
class _NearCoin extends StatelessWidget {
  final _Near item;
  final int order;

  const _NearCoin({required this.item, required this.order});

  static const height = 78.0;

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final ink = a.ink(item.accent);
    final still = MediaQuery.disableAnimationsOf(context);
    final progress = item.progress.clamp(0.0, 1.0);
    final tag = item.tag;
    return Semantics(
      button: true,
      label: '${item.title}${tag == null ? '' : ' · $tag'} · ${item.line}',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.md),
          onTap: () {
            ActHaptics.tap();
            AnalyticsService.instance.logEvent('profile_near_open', {
              'kind': item.kind,
              'remaining': item.remaining,
            });
            item.open(context);
          },
          child: Ink(
            height: height,
            padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              gradient: LinearGradient(
                colors: [
                  ink.withValues(alpha: 0.18),
                  Colors.white.withValues(alpha: 0.03),
                ],
              ),
              border: Border.all(color: ink.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 62,
                  height: 62,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: still ? progress : 0, end: progress),
                    duration: Duration(milliseconds: 900 + order * 150),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, child) => CustomPaint(
                      painter: _CoinRingPainter(
                        value: t,
                        tone: ink,
                        track: a.progressTrack,
                      ),
                      child: child,
                    ),
                    child: Center(
                      child: _MetalCoin(
                        glyph: item.glyph,
                        metal: item.accent,
                        order: order,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title(
                                size: 14,
                                color: a.text,
                              ),
                            ),
                          ),
                          if (tag != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              tag.toUpperCase(),
                              style: AppTypography.label(
                                size: 9.5,
                                letterSpacing: 0.8,
                                weight: FontWeight.w900,
                                color: ink,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.line,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body(
                          size: 12,
                          height: 1.25,
                          weight: FontWeight.w700,
                          color: a.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
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
}

/// Medalha de metal: aro com gradiente, face com relevo, ícone cunhado e
/// um brilho que atravessa de tempos em tempos.
class _MetalCoin extends StatefulWidget {
  final CinematicGlyph glyph;
  final Color metal;
  final int order;

  const _MetalCoin({
    required this.glyph,
    required this.metal,
    required this.order,
  });

  @override
  State<_MetalCoin> createState() => _MetalCoinState();
}

class _MetalCoinState extends State<_MetalCoin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _shine.stop();
    } else if (!_shine.isAnimating) {
      // Cada moeda brilha num tempo diferente.
      _shine.value = (widget.order * 0.27) % 1;
      _shine.repeat();
    }
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const size = 44.0;
    final m = widget.metal;
    final light = Color.lerp(m, Colors.white, 0.55)!;
    final dark = Color.lerp(m, Colors.black, 0.45)!;
    final deep = Color.lerp(m, Colors.black, 0.68)!;
    final coin = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Aro: luz em cima à esquerda, sombra embaixo.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, m, dark],
        ),
        boxShadow: [
          BoxShadow(
            color: m.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Face: côncava, mais clara no centro.
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.35),
            radius: 0.9,
            colors: [light, m, dark],
            stops: const [0, 0.55, 1],
          ),
          border: Border.all(color: deep.withValues(alpha: 0.5), width: 1),
        ),
        alignment: Alignment.center,
        child: CinematicIcon(
          glyph: widget.glyph,
          size: 20,
          accent: deep,
          framed: false,
        ),
      ),
    );
    // Camada própria: o brilho em loop não repinta o anel borrado em volta.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _shine,
        child: coin,
        builder: (context, child) {
          // Brilho passa no primeiro terço do ciclo; o resto é pausa.
          final t = (_shine.value * 3).clamp(0.0, 1.0);
          if (t >= 1 || t <= 0) return child!;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment(-1.6 + t * 3.2, -1),
              end: Alignment(-0.6 + t * 3.2, 1),
              colors: [
                Colors.white.withValues(alpha: 0),
                Colors.white.withValues(alpha: 0.65),
                Colors.white.withValues(alpha: 0),
              ],
            ).createShader(rect),
            child: child,
          );
        },
      ),
    );
  }
}

class _CoinRingPainter extends CustomPainter {
  final double value;
  final Color tone;
  final Color track;
  final bool thin;

  _CoinRingPainter({
    required this.value,
    required this.tone,
    required this.track,
    this.thin = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 4;
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = track,
    );
    if (value <= 0) return;
    final sweep = 2 * math.pi * value;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = tone.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = tone,
    );
  }

  @override
  bool shouldRepaint(covariant _CoinRingPainter old) =>
      old.value != value || old.tone != tone || old.track != track;
}
