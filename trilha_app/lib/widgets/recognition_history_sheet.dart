import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recognition.dart';
import '../services/recognition_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';

/// Lista quem reconheceu o quê — Home (depois de Entendi) e Perfil.
Future<void> showRecognitionHistorySheet(BuildContext context) async {
  final service = context.read<RecognitionService>();
  unawaited(service.refreshRecent());
  await showAppSheet<void>(
    context,
    builder: (_) => const _RecognitionHistorySheet(),
  );
}

/// Atalho no perfil: rostos de quem reconheceu e o último gesto — abre o
/// histórico completo.
class RecognitionHistoryCard extends StatelessWidget {
  const RecognitionHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final items = context.watch<RecognitionService>().recent;
    final groups = groupRecognitionsBySender(items);
    final latest = items.isEmpty ? null : items.first;
    const radius = AppRadii.xl;

    final subtitle = items.isEmpty
        ? 'Quando alguém da caravana tocar no coração, aparece aqui.'
        : _peopleLine(groups);

    return Semantics(
      button: true,
      label: 'Quem reconheceu. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          splashColor: AppColors.clay.withValues(alpha: 0.12),
          highlightColor: AppColors.clay.withValues(alpha: 0.06),
          onTap: () {
            ActHaptics.tap();
            showRecognitionHistorySheet(context);
          },
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: a.cardFill,
              border: Border.all(
                color: AppColors.clay.withValues(
                  alpha: items.isEmpty ? 0.18 : 0.32,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.clayDeep.withValues(
                    alpha: items.isEmpty ? 0.10 : 0.22,
                  ),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                children: [
                  // Calor vindo do coração, no canto de cima.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(-0.85, -1.1),
                            radius: 1.3,
                            colors: [
                              AppColors.clay.withValues(
                                alpha: items.isEmpty ? 0.08 : 0.18,
                              ),
                              AppColors.clay.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.lg,
                      AppSpace.lg,
                      AppSpace.lg,
                      AppSpace.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _HeartSeal(size: 44, lit: items.isNotEmpty),
                            const SizedBox(width: AppSpace.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quem reconheceu',
                                    style: AppTypography.title(
                                      size: 16,
                                      color: a.text,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.body(
                                      size: 12,
                                      height: 1.35,
                                      weight: FontWeight.w600,
                                      color: a.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpace.sm),
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.clay.withValues(alpha: 0.14),
                              ),
                              child: ListChevron(
                                color: AppColors.clay,
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                        if (latest != null) ...[
                          const SizedBox(height: AppSpace.md),
                          InsetPanel(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpace.md,
                              10,
                              AppSpace.md,
                              10,
                            ),
                            child: Row(
                              children: [
                                _FaceStack(groups: groups),
                                const SizedBox(width: AppSpace.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        latest.headline,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.body(
                                          size: 13,
                                          weight: FontWeight.w700,
                                          color: a.text,
                                        ),
                                      ),
                                      if (whenLabel(latest.createdAt)
                                          case final whenText?) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          whenText,
                                          style: AppTypography.label(
                                            size: 10,
                                            letterSpacing: 0.6,
                                            color: AppColors.clay.withValues(
                                              alpha: 0.85,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _peopleLine(List<RecognitionSenderGroup> groups) {
    final names = groups.map((g) => g.name).toList();
    final who = switch (names.length) {
      1 => names[0],
      2 => '${names[0]} e ${names[1]}',
      _ => '${names[0]}, ${names[1]} e mais ${names.length - 2}',
    };
    return '$who ${names.length == 1 ? 'viu' : 'viram'} sua caminhada';
  }
}

class _RecognitionHistorySheet extends StatelessWidget {
  const _RecognitionHistorySheet();

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final service = context.watch<RecognitionService>();
    final items = service.recent;
    final groups = groupRecognitionsBySender(items);
    final loading = service.recentLoading && items.isEmpty;

    final summary = items.isEmpty
        ? 'Cena do dia e medalhas que outros viram em você.'
        : '${items.length} ${items.length == 1 ? 'reconhecimento' : 'reconhecimentos'}'
              ' de ${groups.length} ${groups.length == 1 ? 'pessoa' : 'pessoas'}';

    return AppSheetPanel(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpace.xs),
            AppSheetHeader(
              leading: _HeartSeal(size: 64, lit: items.isNotEmpty),
              title: 'Quem reconheceu',
              subtitle: summary,
              center: true,
            ),
            const SizedBox(height: AppSpace.lg),
            Flexible(
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(AppSpace.xxxl),
                      child: AppSpinner(color: AppColors.clay),
                    )
                  : items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      child: Text(
                        'Ainda ninguém reconheceu sua caminhada.\n'
                        'Na caravana, outros podem tocar no coração.',
                        textAlign: TextAlign.center,
                        style: AppTypography.body(
                          size: 14,
                          height: 1.45,
                          color: a.textSecondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: AppSpace.lg),
                      itemCount: groups.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpace.sm),
                      itemBuilder: (context, i) => _Reveal(
                        index: i,
                        child: _SenderCard(group: groups[i]),
                      ),
                    ),
            ),
            CopperCta(
              label: 'Fechar',
              dense: true,
              leading: null,
              trailing: null,
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Uma pessoa e tudo o que ela reconheceu — o rosto primeiro, os gestos
/// embaixo.
class _SenderCard extends StatelessWidget {
  final RecognitionSenderGroup group;

  const _SenderCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final first = group.items.first;
    final count = group.items.length;
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        color: a.text.withValues(alpha: 0.04),
        border: Border.all(color: a.text.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                name: group.name,
                seed: first.fromUid,
                style: PortraitStyle.letter,
                radius: 20,
                borderColor: AppColors.clay.withValues(alpha: 0.55),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      count == 1
                          ? 'reconheceu você'
                          : 'reconheceu você $count vezes',
                      style: AppTypography.body(
                        size: 12,
                        weight: FontWeight.w600,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (whenLabel(first.createdAt) case final whenText?)
                Text(
                  whenText,
                  style: AppTypography.label(
                    size: 10,
                    letterSpacing: 0.6,
                    color: AppColors.clay.withValues(alpha: 0.85),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final item in group.items) _SubjectChip(item: item),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final Recognition item;

  const _SubjectChip({required this.item});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final medal = item.kind == RecognitionKind.medal;
    final tone = medal ? AppColors.medalGold : AppColors.clay;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.pill),
        color: tone.withValues(alpha: 0.12),
        border: Border.all(color: tone.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CinematicIcon(
            glyph: medal ? CinematicGlyph.gem : CinematicGlyph.path,
            size: 13,
            accent: tone,
            framed: false,
          ),
          const SizedBox(width: 5),
          Text(
            item.subjectLabel,
            style: AppTypography.body(
              size: 12,
              weight: FontWeight.w700,
              color: a.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// Coração em selo: aceso (com brilho) quando já houve reconhecimento.
class _HeartSeal extends StatelessWidget {
  final double size;
  final bool lit;

  const _HeartSeal({required this.size, required this.lit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.clay.withValues(alpha: lit ? 0.38 : 0.18),
            AppColors.clayDeep.withValues(alpha: lit ? 0.22 : 0.10),
          ],
        ),
        border: Border.all(
          color: AppColors.clay.withValues(alpha: lit ? 0.6 : 0.3),
          width: 1.5,
        ),
        boxShadow: lit
            ? [
                BoxShadow(
                  color: AppColors.clay.withValues(alpha: 0.35),
                  blurRadius: size * 0.4,
                ),
              ]
            : null,
      ),
      child: CinematicIcon(
        glyph: CinematicGlyph.heart,
        size: size * 0.46,
        accent: AppColors.clay.withValues(alpha: lit ? 1 : 0.6),
        framed: false,
      ),
    );
  }
}

/// Rostos sobrepostos de quem reconheceu (até 3, depois "+N").
class _FaceStack extends StatelessWidget {
  final List<RecognitionSenderGroup> groups;

  const _FaceStack({required this.groups});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    const size = 28.0;
    const step = size * 0.64;
    final shown = groups.take(3).toList();
    final extra = groups.length - shown.length;
    final slots = shown.length + (extra > 0 ? 1 : 0);
    return SizedBox(
      width: size + (slots - 1) * step,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: i * step,
              child: UserAvatar(
                name: shown[i].name,
                seed: shown[i].items.first.fromUid,
                style: PortraitStyle.letter,
                radius: size / 2,
                borderColor: a.cardFill,
              ),
            ),
          if (extra > 0)
            Positioned(
              left: shown.length * step,
              child: Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(a.cardFill, AppColors.clay, 0.25),
                  border: Border.all(color: a.cardFill, width: 1.5),
                ),
                child: Text(
                  '+$extra',
                  style: AppTypography.label(size: 10, color: AppColors.clay),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Entrada em cascata dos cartões da folha.
class _Reveal extends StatelessWidget {
  final int index;
  final Widget child;

  const _Reveal({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final delay = (index.clamp(0, 6)) * 60;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + delay),
      curve: Interval(delay / (320 + delay), 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 14),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// "Hoje", "Ontem", "Há 3 dias" ou a data.
String? whenLabel(DateTime? at) {
  if (at == null) return null;
  final now = DateTime.now();
  final local = at.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Hoje';
  if (diff == 1) return 'Ontem';
  if (diff < 7) return 'Há $diff dias';
  final dd = local.day.toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  return '$dd/$mm/${local.year}';
}
