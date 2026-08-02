import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/memory_verses.dart';
import '../data/mission_study.dart';
import '../models/trail.dart';
import '../services/bible_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/liturgical_calendar.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';

class _WordSnap {
  final String reference;
  final String text;
  final String label;

  const _WordSnap({
    required this.reference,
    required this.text,
    required this.label,
  });
}

/// Âncora espiritual da home — verso curto, sem peso de checklist.
class HomeWordCard extends StatefulWidget {
  final Mission? mission;
  final void Function(String reference)? onOpen;

  const HomeWordCard({super.key, this.mission, this.onOpen});

  @override
  State<HomeWordCard> createState() => _HomeWordCardState();
}

class _HomeWordCardState extends State<HomeWordCard> {
  _WordSnap? _snap;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant HomeWordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mission?.slug != widget.mission?.slug) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final sync = _syncSnap(widget.mission);
    if (mounted) {
      setState(() {
        _snap = sync;
        _loading = false;
      });
    }

    final async = await _asyncSnap(widget.mission);
    if (!mounted || async == null) return;
    final current = _snap;
    final upgrade = current == null ||
        (async.label == 'Nesta lição' && current.label != 'Nesta lição');
    if (upgrade) {
      setState(() => _snap = async);
    }
  }

  static String _norm(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[êéè]'), 'e')
      .replaceAll(RegExp(r'[áàãâ]'), 'a')
      .replaceAll(RegExp(r'[íî]'), 'i')
      .replaceAll(RegExp(r'[óôõ]'), 'o')
      .replaceAll(RegExp(r'[úû]'), 'u')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'\s+'), ' ');

  static _WordSnap? _syncSnap(Mission? mission) {
    if (mission != null) {
      final study = MissionStudy.forSlug(mission.slug);
      if (study != null &&
          study.passageText.trim().isNotEmpty &&
          study.passageRef.trim().isNotEmpty) {
        return _WordSnap(
          reference: study.passageRef,
          text: study.passageText.trim(),
          label: 'Nesta lição',
        );
      }
      for (final q in mission.questions) {
        final ref = q.verseRef;
        if (ref == null || ref.trim().isEmpty) continue;
        final text = MissionStudy.verseText(ref);
        if (text != null && text.trim().isNotEmpty) {
          return _WordSnap(
            reference: ref,
            text: text.trim(),
            label: 'Nesta lição',
          );
        }
      }
    }

    final moment = LiturgicalCalendar.momentFor();
    final litText = MissionStudy.verseText(moment.focusRef);
    if (litText != null && litText.trim().isNotEmpty) {
      return _WordSnap(
        reference: moment.focusRef,
        text: litText.trim(),
        label: moment.title,
      );
    }

    final focus = _norm(moment.focusRef);
    for (final v in MemoryVerseCatalog.curated) {
      if (_norm(v.reference) == focus ||
          focus.contains(_norm(v.reference)) ||
          _norm(v.reference).contains(focus)) {
        return _WordSnap(
          reference: v.reference,
          text: v.text,
          label: moment.season == LiturgicalSeason.ordinary
              ? 'Palavra'
              : moment.title,
        );
      }
    }

    final day = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    final v = MemoryVerseCatalog.curated[day % MemoryVerseCatalog.curated.length];
    return _WordSnap(
      reference: v.reference,
      text: v.text,
      label: 'Palavra',
    );
  }

  static Future<_WordSnap?> _asyncSnap(Mission? mission) async {
    final moment = LiturgicalCalendar.momentFor();
    final candidates = <({String ref, String label})>[
      if (mission != null)
        for (final q in mission.questions)
          if (q.verseRef != null && q.verseRef!.trim().isNotEmpty)
            (ref: q.verseRef!, label: 'Nesta lição'),
      (
        ref: moment.focusRef,
        label: moment.season == LiturgicalSeason.ordinary
            ? 'Palavra'
            : moment.title,
      ),
    ];

    for (final c in candidates) {
      final resolved = await BibleService.instance.resolve(c.ref);
      if (resolved == null) continue;
      final books = await BibleService.instance.books();
      if (resolved.bookIndex < 0 || resolved.bookIndex >= books.length) {
        continue;
      }
      final book = books[resolved.bookIndex];
      final verse = resolved.verseStart ?? 1;
      final text = await BibleService.instance.verseText(
        book.abbrev,
        resolved.chapter,
        verse,
      );
      if (text == null || text.trim().isEmpty) continue;
      return _WordSnap(
        reference: c.ref,
        text: text.trim(),
        label: c.label,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final snap = _snap;

    if (_loading && snap == null) {
      return const SizedBox.shrink();
    }
    if (snap == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onOpen?.call(snap.reference);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppMetrics.cardRadius),
          color: a.cardFill.withValues(alpha: 0.72),
          border: Border.all(color: a.cardBorder.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CinematicIcon(
                  glyph: CinematicGlyph.book,
                  size: 14,
                  accent: AppColors.cedar,
                  framed: false,
                  glowing: false,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    snap.label.toUpperCase(),
                    style: AppTypography.label(
                      size: 10,
                      letterSpacing: 1.4,
                      color: AppColors.cedar.withValues(alpha: 0.95),
                    ),
                  ),
                ),
                Text(
                  snap.reference,
                  style: AppTypography.body(
                    size: 12,
                    weight: FontWeight.w700,
                    color: a.textMuted(0.55),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '“${_clip(snap.text)}”',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.verse(
                size: 18,
                height: 1.35,
                weight: FontWeight.w600,
                color: a.text.withValues(alpha: 0.92),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _clip(String text) {
    final t = text.trim();
    if (t.length <= 160) return t;
    return '${t.substring(0, 157).trimRight()}…';
  }
}
