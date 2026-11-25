import 'package:flutter/material.dart';

import '../data/trail_art.dart';
import '../data/trail_repository.dart';
import '../l10n/app_language.dart';
import '../models/trail.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cloud_mascot.dart';
import 'cinematic_icon.dart';
import 'pilgrim_profile_sections.dart';
import 'postcard.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Cenas do catálogo por slug — a mesma cena pode estar em mais de uma
/// trilha (costurada); fica a primeira.
class SceneLookup {
  final Map<String, ({Trail trail, Mission mission})> _bySlug;

  SceneLookup(List<Trail> trails)
    : _bySlug = {
        for (final t in trails.reversed)
          for (final mod in t.modules)
            for (final m in mod.missions) m.slug: (trail: t, mission: m),
      };

  ({Trail trail, Mission mission})? operator [](String slug) => _bySlug[slug];

  String? artOf(String slug) {
    final hit = _bySlug[slug];
    return hit == null
        ? null
        : TrailArt.ofScene(hit.trail.slug, hit.mission.slug);
  }

  Postcard? postcardOf(String slug, {String? day}) {
    final hit = _bySlug[slug];
    if (hit == null) return null;
    final hook = (hit.mission.hookRef ?? '').trim();
    return Postcard(
      slug: slug,
      title: hit.mission.localizedTitle,
      ref: RegExp(r'\d').hasMatch(hook) ? hook : '',
      insight: (hit.mission.localizedCentralInsight ?? '').trim(),
      art: TrailArt.ofScene(hit.trail.slug, slug),
      on: DateTime.tryParse(day ?? '') ?? DateTime.now(),
    );
  }

  static Future<SceneLookup>? _cache;
  static int _cacheLen = -1;

  /// Catálogo já fica em memória no repositório; o índice é refeito só
  /// quando o tamanho muda.
  static Future<SceneLookup> load() async {
    final trails = await TrailRepository().getTrails();
    if (_cache == null || _cacheLen != trails.length) {
      _cacheLen = trails.length;
      _cache = Future.value(SceneLookup(trails));
    }
    return _cache!;
  }
}

/// Topo do perfil: um cartão só — a pintura da cena escolhida (ou a mais
/// recente) de ponta a ponta e, sobre o pé escurecido, retrato, nome,
/// título e selos. A posição fica no canto de cima.
class PilgrimProfileTop extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final String? seed;
  final PortraitStyle style;
  final VoidCallback? onEditPortrait;

  /// Cena cuja pintura vira a capa; sem ela (ou sem arte), gradiente.
  final String? coverScene;

  /// Quem olha ainda não fez a cena: a capa fica suave (sem spoiler).
  final bool coverVeiled;

  /// Dono: abre a galeria para trocar a capa.
  final VoidCallback? onChangeCover;

  /// Pódio (1–3) acende em metal; 0 = fora do ranking.
  final int rank;
  final String? epithet;
  final String? sinceLabel;
  final bool supporter;
  final bool pilgrim;
  final bool pioneer;

  /// Ação no canto da capa (coração de reconhecer).
  final Widget? coverAction;

  /// Números da caminhada, na faixa de vidro colada ao pé da pintura.
  final List<PilgrimStat> stats;

  /// Rodapé dentro do mesmo cartão, abaixo dos números (a semana da
  /// sequência na vitrine da caravana).
  final Widget? footer;

  const PilgrimProfileTop({
    super.key,
    required this.name,
    this.photoUrl,
    this.seed,
    this.style = PortraitStyle.photo,
    this.onEditPortrait,
    this.coverScene,
    this.coverVeiled = false,
    this.onChangeCover,
    this.rank = 0,
    this.epithet,
    this.sinceLabel,
    this.supporter = false,
    this.pilgrim = false,
    this.pioneer = false,
    this.coverAction,
    this.stats = const [],
    this.footer,
  });

  /// Pintura das cenas é 3:2 (640×427) — o cartão segue a proporção dela, então a
  /// arte aparece inteira, sem recorte (zoom).
  static const _aspect = 2 / 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final podium = rank > 0 && rank <= 3;
    final tone = podium ? pilgrimRankAccent(rank) : AppRoles.presence;
    final epithetText = (epithet ?? '').trim();
    final since = (sinceLabel ?? '').trim();
    final night = AppearanceStyle.resolve(AppearanceMode.night);
    const white = Colors.white;

    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: tone.withValues(alpha: podium ? 0.75 : 0.35),
          width: podium ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: tone.withValues(alpha: podium ? 0.35 : 0.18),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg - 1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: _aspect,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _CoverArt(scene: coverScene, veiled: coverVeiled, tone: tone),
                  // Pé escuro: o texto pousa ali em qualquer pintura.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.18),
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.55),
                          if (stats.isEmpty)
                            Colors.black.withValues(alpha: 0.82)
                          else
                            _StatBar.fill,
                        ],
                        stops: const [0, 0.28, 0.62, 1],
                      ),
                    ),
                  ),
                  if (rank > 0)
                    Positioned(
                      top: AppSpace.md,
                      left: AppSpace.md,
                      child: _RankChip(rank: rank, tone: tone),
                    ),
                  Positioned(
                    top: AppSpace.sm,
                    right: AppSpace.sm,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onChangeCover != null)
                          _CoverButton(
                            label: l10n.profileCoverChange,
                            onTap: onChangeCover!,
                          ),
                        if (coverAction != null) ...[
                          const SizedBox(width: AppSpace.xs),
                          _Frost(child: coverAction!),
                        ],
                      ],
                    ),
                  ),
                  Positioned(
                    left: AppSpace.md,
                    right: AppSpace.md,
                    bottom: AppSpace.md,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color.lerp(tone, white, 0.5)!, tone],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: tone.withValues(alpha: 0.5),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                          child: UserAvatar(
                            name: name,
                            photoUrl: photoUrl,
                            seed: seed,
                            style: style,
                            radius: 34,
                            editable: onEditPortrait != null,
                            onTap: onEditPortrait,
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    AppTypography.display(
                                      size: 28,
                                      color: white,
                                      height: 1.05,
                                    ).copyWith(
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                              ),
                              if (epithetText.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  epithetText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.body(
                                    size: 13,
                                    weight: FontWeight.w800,
                                    color: podium
                                        ? Color.lerp(tone, white, 0.25)!
                                        : white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                              if (since.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  since,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.body(
                                    size: 12,
                                    weight: FontWeight.w600,
                                    color: white.withValues(alpha: 0.72),
                                  ),
                                ),
                              ],
                              if (pioneer || pilgrim || supporter) ...[
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: AppSpace.xs,
                                  runSpacing: AppSpace.xs,
                                  children: [
                                    if (pioneer || pilgrim)
                                      SoftBadge(
                                        text: pioneer
                                            ? l10n.pioneerBadge
                                            : l10n.pilgrimBadge,
                                        glyph: CinematicGlyph.plus,
                                        accent: AppRoles.reward,
                                      ),
                                    if (supporter)
                                      SoftBadge(
                                        text: l10n.supporterBadge,
                                        glyph: CinematicGlyph.gift,
                                        accent: AppRoles.reward,
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (stats.isNotEmpty) _StatBar(stats: stats, tone: tone),
            if (footer case final f?)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.md,
                  AppSpace.sm,
                  AppSpace.md,
                  AppSpace.md,
                ),
                decoration: BoxDecoration(
                  color: Color.lerp(_StatBar.fill, tone, 0.10),
                  border: Border(
                    top: BorderSide(color: white.withValues(alpha: 0.08)),
                  ),
                ),
                child: f,
              ),
          ],
        ),
      ),
    );

    // Texto sobre arte escura: sempre na tinta da noite, em qualquer visual.
    return Appearance(style: night, mode: AppearanceMode.night, child: card);
  }
}

class _CoverArt extends StatelessWidget {
  final String? scene;
  final bool veiled;
  final Color tone;

  const _CoverArt({
    required this.scene,
    required this.veiled,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    final fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(tone, AppColors.night, 0.35)!,
            Color.lerp(tone, AppColors.night, 0.8)!,
          ],
        ),
      ),
    );
    final slug = scene;
    if (slug == null) return fallback;
    return Stack(
      fit: StackFit.expand,
      children: [
        fallback,
        FutureBuilder<SceneLookup>(
          future: SceneLookup.load(),
          builder: (context, snap) {
            final art = snap.data?.artOf(slug);
            return AnimatedOpacity(
              opacity: art == null ? 0 : 1,
              duration: const Duration(milliseconds: 320),
              child: art == null
                  ? const SizedBox.shrink()
                  : veiled
                  ? ColorFiltered(
                      colorFilter: sceneTeaseFilter,
                      child: Image.asset(
                        art,
                        fit: BoxFit.cover,
                        cacheWidth: sceneTeaseDecodeWidth,
                        gaplessPlayback: true,
                      ),
                    )
                  : SceneArtImage(art, veiled: false),
            );
          },
        ),
      ],
    );
  }
}

class _CoverButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CoverButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () {
          ActHaptics.tap();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            color: Colors.black.withValues(alpha: 0.38),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CinematicIcon(
                glyph: CinematicGlyph.pencil,
                size: 14,
                accent: Colors.white,
                framed: false,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Frost extends StatelessWidget {
  final Widget child;

  const _Frost({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: child,
    );
  }
}

class _RankChip extends StatelessWidget {
  final int rank;
  final Color tone;

  const _RankChip({required this.rank, required this.tone});

  @override
  Widget build(BuildContext context) {
    final podium = rank <= 3;
    final ink = podium ? const Color(0xFF241A06) : AppColors.night;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        gradient: LinearGradient(
          colors: [Color.lerp(tone, Colors.white, 0.45)!, tone],
        ),
        boxShadow: [
          BoxShadow(
            color: tone.withValues(alpha: 0.45),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CinematicIcon(
            glyph: rank == 1 ? CinematicGlyph.crown : CinematicGlyph.podium,
            size: 15,
            accent: ink,
            framed: false,
          ),
          const SizedBox(width: 4),
          Text(
            '$rankº',
            style: AppTypography.title(
              size: 14,
              weight: FontWeight.w900,
              color: ink,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Galeria para escolher a capa: "Mais recente" e a pintura de cada cena
/// feita (uma por pintura — cenas sem arte própria repetem a da trilha).
Future<void> showProfileCoverPicker(
  BuildContext context, {
  required List<String> scenes,
  required String? current,
  required ValueChanged<String?> onPick,
}) {
  return showAppSheet<void>(
    context,
    builder: (ctx) =>
        _CoverPickerSheet(scenes: scenes, current: current, onPick: onPick),
  );
}

class _CoverPickerSheet extends StatelessWidget {
  final List<String> scenes;
  final String? current;
  final ValueChanged<String?> onPick;

  const _CoverPickerSheet({
    required this.scenes,
    required this.current,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.78;
    return AppSheetPanel(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: FutureBuilder<SceneLookup>(
          future: SceneLookup.load(),
          builder: (context, snap) {
            final lookup = snap.data;
            final options = <({String slug, String art})>[];
            if (lookup != null) {
              final seenArt = <String>{};
              for (final slug in scenes) {
                final art = lookup.artOf(slug);
                if (art != null && seenArt.add(art)) {
                  options.add((slug: slug, art: art));
                }
              }
            }
            void pick(String? slug) {
              ActHaptics.confirm();
              onPick(slug);
              Navigator.of(context).pop();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSheetHeader(
                  face: CloudFace.feliz,
                  title: l10n.profileCoverTitle,
                  subtitle: options.isEmpty && lookup != null
                      ? l10n.profileCoverEmpty
                      : l10n.profileCoverBody,
                ),
                const SizedBox(height: AppSpace.md),
                if (lookup == null)
                  const SizedBox(height: 160, child: AppSpinner())
                else
                  Flexible(
                    child: GridView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: AppSpace.lg),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppSpace.sm,
                            crossAxisSpacing: AppSpace.sm,
                            childAspectRatio: 4 / 3,
                          ),
                      itemCount: options.length + 1,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return _CoverOption(
                            selected: current == null,
                            label: l10n.profileCoverLatest,
                            art: options.isEmpty ? null : options.first.art,
                            onTap: () => pick(null),
                          );
                        }
                        final o = options[i - 1];
                        final hit = lookup[o.slug];
                        return _CoverOption(
                          selected: current == o.slug,
                          label: hit?.mission.localizedTitle,
                          art: o.art,
                          onTap: () => pick(o.slug),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CoverOption extends StatelessWidget {
  final bool selected;
  final String? label;
  final String? art;
  final VoidCallback onTap;

  const _CoverOption({
    required this.selected,
    required this.label,
    required this.art,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final path = art;
    final text = (label ?? '').trim();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected ? AppRoles.reward : a.cardBorder,
            width: selected ? 3 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.md - 2),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (path != null)
                Image.asset(
                  path,
                  fit: BoxFit.cover,
                  cacheWidth: 360,
                  gaplessPlayback: true,
                )
              else
                ColoredBox(color: a.cardFill),
              if (text.isNotEmpty)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0),
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              if (selected)
                const Positioned(
                  top: 6,
                  right: 6,
                  child: CinematicIcon(
                    glyph: CinematicGlyph.check,
                    size: 22,
                    accent: AppRoles.reward,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Um número do perfil: ícone, valor, rótulo e (opcional) legenda.
class PilgrimStat {
  final CinematicGlyph glyph;
  final Color tone;
  final int value;
  final String suffix;
  final String label;
  final String? caption;

  const PilgrimStat({
    required this.glyph,
    required this.tone,
    required this.value,
    required this.label,
    this.suffix = '',
    this.caption,
  });
}

/// Faixa de números colada ao pé da capa: a pintura escurece até virar a
/// faixa, e cada número acende na sua cor — um placar, não uma grade.
class _StatBar extends StatelessWidget {
  final List<PilgrimStat> stats;
  final Color tone;

  const _StatBar({required this.stats, required this.tone});

  /// Mesmo tom do fim do véu da pintura: emenda sem linha.
  static const fill = Color(0xFF060B14);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.xs,
        AppSpace.xs,
        AppSpace.xs,
        AppSpace.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fill, Color.lerp(fill, tone, 0.10)!],
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0)
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.16),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: _StatCell(stat: stats[i], order: i),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final PilgrimStat stat;
  final int order;

  const _StatCell({required this.stat, required this.order});

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    final lit = stat.value > 0;
    final tone = lit ? stat.tone : Colors.white.withValues(alpha: 0.35);
    final caption = stat.caption;
    return Semantics(
      label:
          '${pilgrimFormatCount(stat.value)}${stat.suffix} ${stat.label}'
          '${caption == null ? '' : ' · $caption'}',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone com halo da própria cor.
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  tone.withValues(alpha: lit ? 0.38 : 0.1),
                  tone.withValues(alpha: 0),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: CinematicIcon(
              glyph: stat.glyph,
              size: 20,
              accent: tone,
              framed: false,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: still ? 1 : 0, end: 1),
              duration: Duration(milliseconds: 800 + order * 140),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) => Text(
                '${pilgrimFormatCount((stat.value * t).round())}'
                '${stat.suffix}',
                maxLines: 1,
                // Sem serifa: a Cormorant desenha 1 como "I".
                style:
                    AppTypography.title(
                      size: 20,
                      weight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ).copyWith(
                      fontFeatures: const [
                        FontFeature.liningFigures(),
                        FontFeature.tabularFigures(),
                      ],
                      shadows: [
                        if (lit)
                          Shadow(
                            color: stat.tone.withValues(alpha: 0.6),
                            blurRadius: 12,
                          ),
                      ],
                    ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                stat.label.toUpperCase(),
                maxLines: 1,
                style: AppTypography.label(
                  size: 9.5,
                  letterSpacing: 0.8,
                  weight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fileira de postais (a obra da pessoa), do mais novo ao mais antigo.
/// Postal de cena que quem olha ainda não fez fica velado: dá vontade de
/// ir lá, sem estragar a revelação.
class PilgrimPostcardStrip extends StatelessWidget {
  /// Cenas, já na ordem (mais nova primeiro), com o dia quando houver.
  final List<({String slug, String? day})> scenes;

  /// Cenas que quem olha já fez (revela o postal). Null = tudo revelado.
  final Set<String>? viewerDone;

  /// Refazer a cena (só o dono).
  final void Function(String slug)? onRedo;

  final int max;

  /// Dentro do cofre a aba já diz "Postais".
  final bool showHeader;

  const PilgrimPostcardStrip({
    super.key,
    required this.scenes,
    this.viewerDone,
    this.onRedo,
    this.max = 12,
    this.showHeader = true,
  });

  static const _width = 116.0;

  @override
  Widget build(BuildContext context) {
    if (scenes.isEmpty) return const SizedBox.shrink();
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return FutureBuilder<SceneLookup>(
      future: SceneLookup.load(),
      builder: (context, snap) {
        final lookup = snap.data;
        if (lookup == null) return const SizedBox.shrink();
        final cards = <Postcard>[];
        for (final s in scenes) {
          final card = lookup.postcardOf(s.slug, day: s.day);
          if (card != null && card.art != null) cards.add(card);
          if (cards.length >= max) break;
        }
        if (cards.isEmpty) return const SizedBox.shrink();
        final height = PostcardView.heightFor(_width, mini: true);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
                child: Row(
                  children: [
                    Expanded(child: SectionLabel(l10n.postcardsTitle)),
                    Text(
                      pilgrimFormatCount(scenes.length),
                      style: AppTypography.title(
                        size: 13,
                        weight: FontWeight.w900,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.sm),
            ],
            SizedBox(
              height: height + 8,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: cards.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpace.sm),
                itemBuilder: (context, i) {
                  final card = cards[i];
                  final open = viewerDone?.contains(card.slug) ?? true;
                  // Leve inclinação alternada: postais soltos, não grade.
                  final tilt = (i.isEven ? -1 : 1) * 0.025;
                  return Transform.rotate(
                    angle: tilt,
                    child: GestureDetector(
                      onTap: open
                          ? () {
                              ActHaptics.tap();
                              showPostcardDetail(
                                context,
                                card,
                                onRedo: onRedo == null
                                    ? null
                                    : () => onRedo!(card.slug),
                              );
                            }
                          : ActHaptics.light,
                      child: PostcardView(
                        postcard: card,
                        width: _width,
                        mini: true,
                        reveal: open ? 1 : 0,
                        postmark: 0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
