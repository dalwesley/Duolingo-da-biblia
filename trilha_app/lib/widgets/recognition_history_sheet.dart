import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pilgrim_medals.dart';
import '../models/recognition.dart';
import '../l10n/app_language.dart';
import '../l10n/l10n_global.dart';
import '../screens/paywall_screen.dart';
import '../services/moderation_service.dart';
import '../services/recognition_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import 'user_avatar.dart';
import 'user_moderation_sheet.dart';

/// Quem reconheceu. [medalIds] limita à medalha do coração tocado.
/// Sem Peregrino+, a folha mostra o que foi visto e esconde o nome.
Future<void> showRecognitionHistorySheet(
  BuildContext context, {
  Set<String>? medalIds,
}) async {
  final service = context.read<RecognitionService>();
  unawaited(service.refreshRecent());
  await showAppSheet<void>(
    context,
    builder: (_) => _RecognitionHistorySheet(medalIds: medalIds),
  );
}

class _RecognitionHistorySheet extends StatelessWidget {
  final Set<String>? medalIds;

  const _RecognitionHistorySheet({this.medalIds});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = context.watch<RecognitionService>();
    final plus = context.watch<SubscriptionService>().plusFeaturesOpen;
    final items = [
      for (final item in service.received)
        if (medalIds == null ||
            (item.kind == RecognitionKind.medal &&
                medalIds!.contains(item.subjectKey)))
          item,
    ];
    final groups = groupRecognitionsBySender(items);
    final loading = service.recentLoading && items.isEmpty;
    final revealNames = plus || items.isEmpty;

    // Com os nomes, a pessoa é o conteúdo. A contagem fica para quem
    // ainda não vê quem foi.
    final summary = items.isEmpty
        ? l10n.recognitionSummaryEmpty
        : revealNames
        ? null
        : l10n.recognitionCardHearts(items.length);

    final body = loading
        ? const Padding(
            padding: EdgeInsets.all(AppSpace.xxxl),
            child: AppSpinner(),
          )
        : items.isEmpty
        ? _EmptySheet(message: l10n.recognitionEmptySheet)
        : !revealNames
        ? _LockedWho(items: items)
        : ListView.separated(
            shrinkWrap: true,
            primary: false,
            padding: const EdgeInsets.only(bottom: AppSpace.xs),
            itemCount: groups.length,
            separatorBuilder: (_, _) =>
                const ListDivider(indent: 14, endIndent: 14),
            itemBuilder: (context, i) => _Reveal(
              index: i,
              child: _SenderCard(group: groups[i]),
            ),
          );

    // A lista encolhe com o conteúdo e só passa a rolar perto de metade
    // da tela. Sem isso a folha estica e o Fechar fica num vazio.
    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.5,
            ),
            child: body,
          ),
          const SizedBox(height: AppSpace.lg),
          CopperCta(
            label: l10n.commonClose,
            dense: true,
            leading: null,
            trailing: null,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

/// Sem Peregrino+: o que foi visto, sem o nome de quem tocou.
class _LockedWho extends StatelessWidget {
  final List<Recognition> items;

  const _LockedWho({required this.items});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final seen = <String>{};
    final chips = <Recognition>[
      for (final item in items)
        if (seen.add('${item.kind.name}:${item.subjectKey}')) item,
    ];

    return ListView(
      shrinkWrap: true,
      primary: false,
      padding: const EdgeInsets.only(bottom: AppSpace.xs),
      children: [
        Text(
          l10n.recognitionWhoLockedBody,
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 14,
            height: 1.4,
            color: a.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [for (final item in chips) _SubjectChip(item: item)],
        ),
        const SizedBox(height: AppSpace.lg),
        CopperCta(
          label: l10n.weeklyReviewSeePlus,
          dense: true,
          leading: CinematicGlyph.plus,
          trailing: null,
          onTap: () {
            final nav = Navigator.of(context);
            nav.pop();
            nav.push(
              MaterialPageRoute<void>(
                builder: (_) => const PaywallScreen(source: 'recognition'),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Uma pessoa, no mesmo desenho da lista da trilha: rosto, nome,
/// discos do que ela viu e o número à direita.
class _SenderCard extends StatelessWidget {
  final RecognitionSenderGroup group;

  const _SenderCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final first = group.items.first;
    final medals = <RecognizableMedal>[];
    final walks = <Recognition>[];
    final unknown = <Recognition>[];
    for (final item in group.items) {
      if (item.kind == RecognitionKind.walk) {
        walks.add(item);
        continue;
      }
      final face = medalById(item.subjectKey);
      if (face == null) {
        unknown.add(item);
      } else {
        medals.add(face);
      }
    }
    final whenText = whenLabel(first.createdAt);
    final today = whenText == l10n.commonToday;
    final discs = <({CinematicGlyph glyph, Color accent})>[
      for (final medal in medals)
        (glyph: medal.glyph, accent: tierColor(medal.tier)),
      for (final _ in walks)
        (glyph: CinematicGlyph.path, accent: AppRoles.presence),
      for (final _ in unknown)
        (glyph: CinematicGlyph.gem, accent: AppColors.medalGold),
    ];
    final caption = medals.length == 1 && walks.isEmpty && unknown.isEmpty
        ? medals.first.coinTitle
        : walks.length == 1 && medals.isEmpty && unknown.isEmpty
        ? walks.first.subjectLabel
        : unknown.length == 1 && medals.isEmpty && walks.isEmpty
        ? unknown.first.subjectLabel
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 0, 12),
      child: Row(
        children: [
          UserAvatar(
            name: group.name,
            seed: first.fromUid,
            style: PortraitStyle.letter,
            radius: AppMetrics.avatarMd,
            borderColor: AppRoles.presence,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.title(size: 14, color: a.text),
                ),
                const SizedBox(height: 4),
                _SeenLine(discs: discs, caption: caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${group.items.length}',
                style: AppTypography.title(
                  size: 18,
                  weight: FontWeight.w900,
                  color: a.text,
                ),
              ),
              if (whenText != null)
                Text(
                  whenText,
                  style: AppTypography.label(
                    size: 10,
                    letterSpacing: 0.2,
                    weight: FontWeight.w800,
                    color: today ? AppRoles.presence : a.textFaint,
                  ),
                ),
            ],
          ),
          IconButtonTheme(
            data: IconButtonThemeData(
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: const Size(32, 32),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            child: UserModerationButton(
              uid: first.fromUid,
              name: group.name,
              source: UserReportSource.recognition,
              onDone: (outcome) {
                if (outcome == ModerationOutcome.blocked && context.mounted) {
                  context.read<RecognitionService>().refreshRecent();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Discos do que a pessoa viu, no mesmo tamanho da linha de medalhas da trilha.
class _SeenLine extends StatelessWidget {
  final List<({CinematicGlyph glyph, Color accent})> discs;
  final String? caption;

  const _SeenLine({required this.discs, this.caption});

  @override
  Widget build(BuildContext context) {
    const size = 24.0;
    const overlap = 16.0;
    final shown = discs.take(3).toList();
    final extra = discs.length - shown.length;
    final slots = shown.length + (extra > 0 ? 1 : 0);
    if (slots == 0 && caption == null) return const SizedBox.shrink();

    return Row(
      children: [
        if (slots > 0)
          SizedBox(
            width: size + (slots - 1) * overlap,
            height: size,
            child: Stack(
              children: [
                for (var i = 0; i < shown.length; i++)
                  Positioned(
                    left: i * overlap,
                    child: _Disc(
                      glyph: shown[i].glyph,
                      accent: shown[i].accent,
                    ),
                  ),
                if (extra > 0)
                  Positioned(
                    left: shown.length * overlap,
                    child: _Disc(
                      glyph: CinematicGlyph.gem,
                      accent: AppColors.medalGold,
                      overlay: '+$extra',
                    ),
                  ),
              ],
            ),
          ),
        if (caption != null) ...[
          if (slots > 0) const SizedBox(width: 8),
          Expanded(
            child: Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.body(
                size: 12,
                weight: FontWeight.w700,
                color: Appearance.of(context).textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Disc extends StatelessWidget {
  final CinematicGlyph glyph;
  final Color accent;
  final String? overlay;

  const _Disc({required this.glyph, required this.accent, this.overlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Appearance.of(context).cardFill,
        border: Border.all(color: accent, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: overlay != null
          ? Text(
              overlay!,
              style: AppTypography.label(
                size: 10,
                letterSpacing: 0,
                weight: FontWeight.w900,
                color: accent,
              ),
            )
          : CinematicIcon(
              glyph: glyph,
              size: AppMetrics.chipIcon,
              accent: accent,
              framed: false,
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
      accent: lit ? AppRoles.heart : Appearance.of(context).textFaint,
      glowing: lit,
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
    return EmptyState(title: lines.first, body: rest.isEmpty ? null : rest);
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
