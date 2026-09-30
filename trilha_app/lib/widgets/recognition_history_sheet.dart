import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recognition.dart';
import '../l10n/app_language.dart';
import '../l10n/l10n_global.dart';
import '../services/recognition_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'immersive_background.dart';
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
    final l10n = context.l10n;
    final items = context.watch<RecognitionService>().recent;
    final groups = groupRecognitionsBySender(items);
    final latest = items.isEmpty ? null : items.first;

    final subtitle = items.isEmpty
        ? l10n.recognitionEmptyCard
        : _peopleLine(l10n, groups);

    return Semantics(
      button: true,
      label: l10n.recognitionSemanticsWho(subtitle),
      excludeSemantics: true,
      child: GlassCard(
        tint: items.isEmpty ? null : AppRoles.success,
        onTap: () {
          ActHaptics.tap();
          showRecognitionHistorySheet(context);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _HeartSeal(size: AppMetrics.leadingIcon, lit: items.isNotEmpty),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.recognitionWhoTitle,
                        style: AppTypography.title(size: 16, color: a.text),
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
                ListChevron(color: a.textFaint),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                color: a.textFaint,
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
    );
  }

  static String _peopleLine(
    AppLocalizations l10n,
    List<RecognitionSenderGroup> groups,
  ) {
    final names = groups.map((g) => g.name).toList();
    final who = switch (names.length) {
      1 => names[0],
      2 => l10n.recognitionAndTwo(names[0], names[1]),
      _ => l10n.recognitionAndMore(names[0], names[1], names.length - 2),
    };
    return l10n.recognitionSawJourney(names.length, who);
  }
}

class _RecognitionHistorySheet extends StatelessWidget {
  const _RecognitionHistorySheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = context.watch<RecognitionService>();
    final items = service.recent;
    final groups = groupRecognitionsBySender(items);
    final loading = service.recentLoading && items.isEmpty;

    final summary = items.isEmpty
        ? l10n.recognitionSummaryEmpty
        : l10n.recognitionSummaryCounts(items.length, groups.length);

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
              leading: _HeartSeal(
                size: AppMetrics.iconHero,
                lit: items.isNotEmpty,
              ),
              title: l10n.recognitionWhoTitle,
              subtitle: summary,
              center: true,
            ),
            const SizedBox(height: AppSpace.lg),
            Flexible(
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(AppSpace.xxxl),
                      child: AppSpinner(),
                    )
                  : items.isEmpty
                  ? _EmptySheet(message: l10n.recognitionEmptySheet)
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
              label: l10n.commonClose,
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
    return InsetPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(
                name: group.name,
                seed: first.fromUid,
                style: PortraitStyle.letter,
                radius: AppMetrics.avatarMd,
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
                      context.l10n.recognitionSawYou(count),
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
                    color: a.textFaint,
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
    final medal = item.kind == RecognitionKind.medal;
    return SoftBadge(
      text: item.subjectLabel,
      glyph: medal ? CinematicGlyph.gem : CinematicGlyph.path,
      accent: medal ? AppColors.medalGold : AppRoles.success,
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
    return CinematicIcon(
      glyph: CinematicGlyph.heart,
      size: size,
      accent: lit ? AppRoles.success : Appearance.of(context).textFaint,
      glowing: lit,
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
    const size = AppMetrics.avatarSm * 2;
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
                  color: Color.lerp(a.cardFill, AppRoles.chrome, 0.12),
                  border: Border.all(color: a.cardFill, width: 1.5),
                ),
                child: Text(
                  '+$extra',
                  style: AppTypography.label(size: 10, color: a.textSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Ninguém reconheceu ainda — primeira linha é o título, o resto o apoio.
class _EmptySheet extends StatelessWidget {
  final String message;

  const _EmptySheet({required this.message});

  @override
  Widget build(BuildContext context) {
    final lines = message.split('\n');
    final rest = lines.skip(1).join('\n').trim();
    return EmptyState(
      glyph: CinematicGlyph.people,
      title: lines.first,
      body: rest.isEmpty ? null : rest,
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
      curve: Interval(delay / (320 + delay), 1, curve: AppMotion.enter),
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
  final l = L10n.current;
  final now = DateTime.now();
  final local = at.toLocal();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(local.year, local.month, local.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return l.commonToday;
  if (diff == 1) return l.recognitionYesterday;
  if (diff < 7) return l.recognitionDaysAgo(diff);
  final dd = local.day.toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  return '$dd/$mm/${local.year}';
}
