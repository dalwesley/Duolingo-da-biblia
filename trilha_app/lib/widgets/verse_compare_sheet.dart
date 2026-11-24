import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_language.dart';
import '../services/analytics_service.dart';
import '../services/bible_service.dart';
import '../services/bible_study_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'act_feel.dart';
import 'anan_speech.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'cloud_mascot.dart';
import 'ui_primitives.dart';
import 'verse_study_sheet.dart';

/// Um versículo em todas as traduções do app + o original (hebraico/grego).
///
/// Lista limpa: a versão em leitura (barra lateral), o original palavra por
/// palavra (toque abre o estudo) e as outras versões. Segurar um bloco copia;
/// copiar tudo e compartilhar ficam no título; setas andam pelo capítulo.
Future<void> showVerseCompareSheet(
  BuildContext context, {
  required int bookIndex,
  required String bookName,
  required int chapter,
  required int verse,
  void Function(int bookIndex, int chapter, int verse)? onOpenRef,
}) async {
  unawaited(
    AnalyticsService.instance.logEvent('verse_compare_open', {
      'book_index': bookIndex,
    }),
  );
  await showAppSheet<void>(
    context,
    builder: (_) => _VerseCompareSheet(
      bookIndex: bookIndex,
      bookName: bookName,
      chapter: chapter,
      verse: verse,
      onOpenRef: onOpenRef,
    ),
  );
  // As outras traduções pesam ~15 MB cada; só a ativa fica na memória.
  BibleService.instance.releaseExtras();
}

typedef _Row = ({BibleTranslation translation, String? text});

class _Original {
  final bool hebrew;
  final List<({String surface, String translit})> words;

  const _Original({required this.hebrew, required this.words});

  String get text => words.map((w) => w.surface).join(' ');
}

class _Payload {
  final List<_Row> rows;
  final int verseCount;

  const _Payload({required this.rows, required this.verseCount});
}

/// Cor de cada língua do texto (poço do código e barra da versão ativa).
Color _languageTone(String language) => switch (language) {
  'en' => AppColors.cedar,
  'es' => AppColors.clay,
  _ => AppRoles.navBible,
};

class _VerseCompareSheet extends StatefulWidget {
  final int bookIndex;
  final String bookName;
  final int chapter;
  final int verse;
  final void Function(int bookIndex, int chapter, int verse)? onOpenRef;

  const _VerseCompareSheet({
    required this.bookIndex,
    required this.bookName,
    required this.chapter,
    required this.verse,
    this.onOpenRef,
  });

  @override
  State<_VerseCompareSheet> createState() => _VerseCompareSheetState();
}

class _VerseCompareSheetState extends State<_VerseCompareSheet> {
  late int _verse = widget.verse;
  late Future<_Payload> _payload;
  late Future<_Original?> _original;

  String get _ref => '${widget.bookName} ${widget.chapter}:$_verse';

  @override
  void initState() {
    super.initState();
    _payload = _loadPayload(_verse);
    _original = _loadOriginal(_verse);
  }

  void _step(int delta, int verseCount) {
    final next = _verse + delta;
    if (next < 1 || next > verseCount) return;
    ActHaptics.tap();
    setState(() {
      _verse = next;
      _payload = _loadPayload(next);
      _original = _loadOriginal(next);
    });
  }

  /// Ativa primeiro; depois PT → EN → ES, a padrão de cada língua antes (JFAAL
  /// antes da TB). TB entra: comparar é o lugar dela.
  Future<_Payload> _loadPayload(int verse) async {
    final bible = BibleService.instance;
    final active = bible.translationId;
    final order = [
      BibleService.byId(active),
      for (final lang in BibleService.textLanguages)
        for (final t in [
          ...BibleService.translationsIn(
            lang,
          ).where((t) => t.id == BibleService.effectiveId('', lang)),
          ...BibleService.translationsIn(
            lang,
          ).where((t) => t.id != BibleService.effectiveId('', lang)),
        ])
          if (t.available && t.id != active) t,
    ];

    // Em paralelo: cada tradução parseia no seu isolate.
    Future<_Row> load(BibleTranslation t) async {
      try {
        final text = await bible.verseIn(
          t.id,
          widget.bookIndex,
          widget.chapter,
          verse,
        );
        return (translation: t, text: text);
      } catch (e) {
        debugPrint('[STWAY:Compare] ${t.id} failed: $e');
        return (translation: t, text: null);
      }
    }

    final rows = await Future.wait([for (final t in order) load(t)]);
    var verseCount = verse;
    try {
      final books = await bible.books();
      verseCount = books[widget.bookIndex].chapters[widget.chapter - 1].length;
    } catch (_) {}
    return _Payload(rows: rows, verseCount: verseCount);
  }

  Future<_Original?> _loadOriginal(int verse) async {
    try {
      final study = await BibleStudyService.instance.studyVerse(
        widget.bookIndex,
        widget.chapter,
        verse,
      );
      final tokens = study.tokens.where((t) => t.surface.trim().isNotEmpty);
      if (tokens.isEmpty) return null;
      return _Original(
        hebrew: tokens.first.strong.toUpperCase().startsWith('H'),
        words: [
          for (final t in tokens)
            (surface: t.surface.trim(), translit: t.translit.trim()),
        ],
      );
    } catch (e) {
      // Banco de estudo indisponível (ex.: plugin sem restart): sem original.
      debugPrint('[STWAY:Compare] original failed: $e');
      return null;
    }
  }

  /// Segurar um bloco: copia só aquela versão.
  Future<void> _copyOne(String label, String text) async {
    final message = context.l10n.bibleVerseCopied;
    await Clipboard.setData(ClipboardData(text: '$text\n— $_ref ($label)'));
    ActHaptics.light();
    if (!mounted) return;
    await showAppToastFor(
      context,
      message: message,
      glyph: CinematicGlyph.copy,
    );
  }

  Future<String> _allText(List<_Row> rows) async {
    final l10n = context.l10n;
    final original = await _original;
    return [
      _ref,
      '',
      for (final r in rows)
        if (r.text != null) '${r.translation.shortName} — ${r.text}',
      if (original != null) ...[
        '',
        '${original.hebrew ? l10n.bibleCompareHebrew : l10n.bibleCompareGreek}'
            ' — ${original.text}',
      ],
      '',
      l10n.bibleShareTextFooter,
    ].join('\n');
  }

  Future<void> _copyAll(List<_Row> rows) async {
    final message = context.l10n.bibleCompareCopiedAll;
    final text = await _allText(rows);
    await Clipboard.setData(ClipboardData(text: text));
    ActHaptics.light();
    if (!mounted) return;
    await showAppToastFor(
      context,
      message: message,
      glyph: CinematicGlyph.copy,
    );
  }

  Future<void> _shareAll(List<_Row> rows) async {
    ActHaptics.tap();
    final text = await _allText(rows);
    await SharePlus.instance.share(ShareParams(text: text, subject: _ref));
  }

  void _study(String verseText) {
    Navigator.pop(context);
    showVerseStudySheet(
      context,
      bookIndex: widget.bookIndex,
      bookName: widget.bookName,
      chapter: widget.chapter,
      verse: _verse,
      text: verseText,
      source: 'compare',
      onOpenRef: widget.onOpenRef,
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9 - bottom - 40;

    return AppSheetPanel(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: FutureBuilder<_Payload>(
          future: _payload,
          builder: (context, snap) {
            final loading = snap.connectionState != ConnectionState.done;
            final payload = loading ? null : snap.data;
            Widget headerIcon(
              CinematicGlyph glyph,
              String tip,
              VoidCallback? onTap,
            ) {
              return IconButton(
                tooltip: tip,
                visualDensity: VisualDensity.compact,
                onPressed: onTap,
                icon: CinematicIcon(
                  glyph: glyph,
                  size: AppMetrics.iconMd,
                  accent: a.textSecondary,
                  framed: false,
                ),
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 6, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppSheetHeader(
                          eyebrow: context.l10n.bibleVerseCompare,
                          title: _ref,
                          // Carregando, o Anan está no balão embaixo: um só.
                          cloud: payload != null,
                        ),
                      ),
                      if (payload != null) ...[
                        headerIcon(
                          CinematicGlyph.copy,
                          context.l10n.bibleCompareCopyAll,
                          () => _copyAll(payload.rows),
                        ),
                        headerIcon(
                          CinematicGlyph.share,
                          context.l10n.commonShare,
                          () => _shareAll(payload.rows),
                        ),
                      ],
                      headerIcon(
                        CinematicGlyph.close,
                        MaterialLocalizations.of(context).closeButtonTooltip,
                        () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                if (payload != null && payload.verseCount > 1)
                  _VerseStepper(
                    verse: _verse,
                    total: payload.verseCount,
                    onStep: (d) => _step(d, payload.verseCount),
                  ),
                Flexible(
                  child: AnimatedSwitcher(
                    duration: AppMotion.standard,
                    child: payload == null
                        ? const _CompareLoading()
                        : _CompareBody(
                            key: ValueKey(_verse),
                            rows: payload.rows,
                            original: _original,
                            bottomInset: bottom,
                            onCopy: _copyOne,
                            onStudy: () => _study(
                              payload.rows.isEmpty
                                  ? ''
                                  : (payload.rows.first.text ?? ''),
                            ),
                          ),
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

/// ‹  Versículo 3 de 31  › — discreto, anda pelo capítulo sem fechar a folha.
class _VerseStepper extends StatelessWidget {
  final int verse;
  final int total;
  final ValueChanged<int> onStep;

  const _VerseStepper({
    required this.verse,
    required this.total,
    required this.onStep,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    Widget arrow(CinematicGlyph glyph, int delta, String tip, bool on) {
      return IconButton(
        tooltip: tip,
        visualDensity: VisualDensity.compact,
        onPressed: on ? () => onStep(delta) : null,
        icon: Opacity(
          opacity: on ? 1 : 0.25,
          child: CinematicIcon(
            glyph: glyph,
            size: AppMetrics.iconSm,
            accent: a.textSecondary,
            framed: false,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          arrow(
            CinematicGlyph.back,
            -1,
            context.l10n.bibleComparePrevVerse,
            verse > 1,
          ),
          SizedBox(
            width: 150,
            child: Text(
              context.l10n.bibleCompareVerseOf(verse, total),
              textAlign: TextAlign.center,
              style: AppTypography.body(size: 13, color: a.textFaint),
            ),
          ),
          arrow(
            CinematicGlyph.forward,
            1,
            context.l10n.bibleCompareNextVerse,
            verse < total,
          ),
        ],
      ),
    );
  }
}

class _CompareBody extends StatelessWidget {
  final List<_Row> rows;
  final Future<_Original?> original;
  final double bottomInset;
  final Future<void> Function(String label, String text) onCopy;
  final VoidCallback onStudy;

  const _CompareBody({
    super.key,
    required this.rows,
    required this.original,
    required this.bottomInset,
    required this.onCopy,
    required this.onStudy,
  });

  @override
  Widget build(BuildContext context) {
    final active = rows.isEmpty ? null : rows.first;
    final others = rows.length > 1 ? rows.sublist(1) : const <_Row>[];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(22, 6, 22, AppSpace.lg + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (active != null)
            _VersionBlock(row: active, active: true, onCopy: onCopy),
          const SizedBox(height: AppSpace.lg),
          _OriginalBlock(future: original, onCopy: onCopy, onStudy: onStudy),
          for (final r in others) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpace.md),
              child: ListDivider(),
            ),
            _VersionBlock(row: r, active: false, onCopy: onCopy),
          ],
        ],
      ),
    );
  }
}

/// Sigla da versão + língua, na cor da língua: "BSB · EN".
class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final String? note;

  const _Tag({required this.text, required this.color, this.note});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: AppTypography.label(size: 11, color: color),
          ),
          if (note != null)
            TextSpan(
              text: '   $note',
              style: AppTypography.body(size: 12, color: a.textFaint),
            ),
        ],
      ),
    );
  }
}

/// Um bloco de versão. A em leitura ganha só a barra lateral e letra maior.
class _VersionBlock extends StatelessWidget {
  final _Row row;
  final bool active;
  final Future<void> Function(String label, String text) onCopy;

  const _VersionBlock({
    required this.row,
    required this.active,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final t = row.translation;
    final tone = a.ink(_languageTone(t.language));
    final text = row.text;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Tag(
          text: '${t.shortName} · ${t.language.toUpperCase()}',
          color: tone,
          note: active ? context.l10n.bibleCompareReading : null,
        ),
        const SizedBox(height: 6),
        Text(
          text ?? context.l10n.bibleCompareMissing,
          style: text == null
              ? AppTypography.body(size: 14, color: a.textFaint)
              : AppTypography.verse(
                  size: active ? 22 : 19,
                  height: 1.4,
                  color: active ? a.text : a.text.withValues(alpha: 0.86),
                ),
        ),
      ],
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: text == null ? null : () => onCopy(t.shortName, text),
      child: active
          ? IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 3,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      color: tone,
                      borderRadius: BorderRadius.circular(AppRadii.hair),
                    ),
                  ),
                  Expanded(child: content),
                ],
              ),
            )
          : content,
    );
  }
}

/// Original: palavras com a transliteração embaixo (hebraico da direita para
/// a esquerda). Tocar numa palavra ou no link abre o estudo.
class _OriginalBlock extends StatelessWidget {
  final Future<_Original?> future;
  final Future<void> Function(String label, String text) onCopy;
  final VoidCallback onStudy;

  const _OriginalBlock({
    required this.future,
    required this.onCopy,
    required this.onStudy,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final tone = a.ink(AppColors.sand);
    return FutureBuilder<_Original?>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(AppSpace.sm),
            child: AppSpinner(inline: true),
          );
        }
        final o = snap.data;
        if (o == null) {
          return Row(
            children: [
              const CloudMascot(face: CloudFace.triste, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.bibleCompareOriginalMissing,
                  style: AppTypography.body(
                    size: 13,
                    height: 1.35,
                    color: a.textFaint,
                  ),
                ),
              ),
            ],
          );
        }
        final language = o.hebrew
            ? context.l10n.bibleCompareHebrew
            : context.l10n.bibleCompareGreek;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPress: () => onCopy(language, o.text),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Tag(text: language.toUpperCase(), color: tone),
              const SizedBox(height: 8),
              Wrap(
                textDirection: o.hebrew ? TextDirection.rtl : TextDirection.ltr,
                spacing: 14,
                runSpacing: 10,
                children: [
                  for (final w in o.words)
                    _Word(
                      surface: w.surface,
                      translit: w.translit,
                      hebrew: o.hebrew,
                      onTap: onStudy,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: onStudy,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.bibleCompareStudyCta,
                          style: AppTypography.body(
                            size: 13,
                            weight: FontWeight.w700,
                            color: tone,
                          ),
                        ),
                        const SizedBox(width: 6),
                        CinematicIcon(
                          glyph: CinematicGlyph.forward,
                          size: 14,
                          accent: tone,
                          framed: false,
                        ),
                      ],
                    ),
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

class _Word extends StatelessWidget {
  final String surface;
  final String translit;
  final bool hebrew;
  final VoidCallback onTap;

  const _Word({
    required this.surface,
    required this.translit,
    required this.hebrew,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            surface,
            textDirection: hebrew ? TextDirection.rtl : TextDirection.ltr,
            style: AppTypography.original(
              hebrew: hebrew,
              size: hebrew ? 24 : 19,
              height: 1.25,
              color: a.text,
            ),
          ),
          if (translit.isNotEmpty)
            Text(
              translit,
              style: AppTypography.body(
                size: 11,
                color: a.textFaint,
              ).copyWith(fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}

/// Anan avisa que está buscando o versículo nas versões (leva ~1 s na 1ª vez).
class _CompareLoading extends StatelessWidget {
  const _CompareLoading();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, AppSpace.xl, 28, AppSpace.xl),
      child: AnanSpeech(
        face: CloudFace.carregando,
        ananSize: 72,
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        child: Text(
          context.l10n.bibleCompareLoading,
          textAlign: TextAlign.center,
          style: AppTypography.body(
            size: 15,
            height: 1.35,
            weight: FontWeight.w600,
            color: AnanSpeechBubble.ink,
          ),
        ),
      ),
    );
  }
}
