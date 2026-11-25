import 'profile_privacy.dart';
import '../models/caravan_profile_prefs.dart';
import 'package:flutter/material.dart';

import '../l10n/app_language.dart';
import '../models/room_week.dart';
import '../models/study_room.dart';
import '../services/bible_service.dart';
import '../services/league_service.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'ui_primitives.dart';
import 'immersive_background.dart';
import 'profile_section.dart';

/// Leitura da Bíblia da semana do grupo: o que o líder marcou e quanto a
/// pessoa já leu (capítulos lidos nesta semana).
class RoomReadingCard extends StatelessWidget {
  final RoomReading? reading;
  final bool isLeader;
  final int done;
  final VoidCallback onPick;
  final VoidCallback onOpen;

  const RoomReadingCard({
    super.key,
    required this.reading,
    required this.isLeader,
    required this.done,
    required this.onPick,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    final r = reading;
    if (r == null) {
      // Sem leitura: só o líder vê o convite para marcar.
      if (!isLeader) return const SizedBox.shrink();
      return ProfilePanel(
        accent: AppRoles.lamp,
        onTap: onPick,
        child: Row(
          children: [
            CinematicIcon(
              glyph: CinematicGlyph.book,
              size: AppMetrics.leadingIcon,
              // Leitura da Bíblia = o tom da aba Bíblia.
              accent: AppRoles.navBible,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.roomReadingPickTitle,
                    style: AppTypography.title(size: 15, color: a.text),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    l10n.roomReadingPickBody,
                    style: AppTypography.body(size: 13, color: a.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final complete = done >= r.chapters;
    // O card inteiro abre a leitura; "Trocar" (líder) tem toque próprio.
    return ProfilePanel(
      accent: (complete ? AppRoles.presence : null) ?? AppRoles.lamp,
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: SectionLabel(l10n.roomReadingLabel)),
              if (isLeader)
                TextCta(
                  label: l10n.roomReadingChange,
                  color: a.textSecondary,
                  onTap: onPick,
                ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          // Fonte do título (não a display): numeral antigo virava "ı".
          Text(r.label, style: AppTypography.title(size: 22, color: a.text)),
          const SizedBox(height: AppSpace.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (done / r.chapters).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: a.cardBorder,
              color: AppRoles.presence,
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              CinematicIcon(
                glyph: complete ? CinematicGlyph.check : CinematicGlyph.book,
                size: 14,
                accent: complete ? AppRoles.presence : a.textSecondary,
                framed: false,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  complete
                      ? l10n.roomReadingDone
                      : l10n.roomReadingProgressTap(done, r.chapters),
                  style: AppTypography.body(
                    size: 13,
                    weight: FontWeight.w700,
                    color: complete ? AppRoles.presence : a.textSecondary,
                  ),
                ),
              ),
              CinematicIcon(
                glyph: CinematicGlyph.chevron,
                size: 14,
                accent: a.textSecondary,
                framed: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Líder escolhe a leitura da semana: o mesmo texto do estudo marcado
/// ([study]) ou livro e capítulos à mão (até 10).
///
/// [startOnly]: só livro e capítulo de partida (o propósito lê em sequência
/// a partir dali).
Future<RoomReading?> showRoomReadingPicker(
  BuildContext context, {
  RoomReading? current,
  RoomStudy? study,
  bool startOnly = false,
}) {
  return showAppSheet<RoomReading>(
    context,
    builder: (_) =>
        _ReadingPicker(current: current, study: study, startOnly: startOnly),
  );
}

/// Capítulos da passagem do estudo ("João 1:1–14" → João 1; "Mateus
/// 5–7" → Mateus 5–7). `null` se a referência não resolve.
Future<RoomReading?> readingFromStudy(RoomStudy study) async {
  final ref = (study.verseRef ?? '').trim();
  if (ref.isEmpty) return null;
  final resolved = await BibleService.instance.resolve(ref);
  if (resolved == null) return null;
  final books = await BibleService.instance.books();
  if (resolved.bookIndex < 0 || resolved.bookIndex >= books.length) {
    return null;
  }
  final book = books[resolved.bookIndex];
  var to = resolved.chapter;
  // Só faixa de capítulos ("5–7", sem dois-pontos) vira mais de um.
  final range = RegExp(r'(\d+)\s*[–-]\s*(\d+)\s*$').firstMatch(ref);
  if (range != null && !ref.contains(':')) {
    to = int.parse(range.group(2)!);
  }
  to = to.clamp(
    resolved.chapter,
    (resolved.chapter + RoomReading.maxChapters - 1).clamp(
      resolved.chapter,
      book.chapters.length,
    ),
  );
  return RoomReading(
    bookAbbrev: book.abbrev,
    bookName: book.name,
    from: resolved.chapter,
    to: to,
    week: LeagueService.weekKey(),
  );
}

class _ReadingPicker extends StatefulWidget {
  final RoomReading? current;
  final RoomStudy? study;
  final bool startOnly;

  const _ReadingPicker({this.current, this.study, this.startOnly = false});

  @override
  State<_ReadingPicker> createState() => _ReadingPickerState();
}

class _ReadingPickerState extends State<_ReadingPicker> {
  List<BibleBook> _books = const [];
  int _book = 42; // João
  int _from = 1;
  int _to = 1;

  /// O texto do estudo da semana como leitura (se o estudo tem passagem).
  RoomReading? _fromStudy;

  /// Card "Mesmo texto do estudo" escolhido. Abre marcado quando o estudo
  /// tem passagem (salvo se já há outra leitura salva). Tocar só marca;
  /// quem confirma é o botão. Mexer no livro ou no capítulo desmarca.
  bool _useStudy = false;

  @override
  void initState() {
    super.initState();
    final study = widget.study;
    if (study != null) {
      readingFromStudy(study).then((r) {
        if (!mounted || r == null) return;
        final cur = widget.current;
        setState(() {
          _fromStudy = r;
          // Sem leitura salva, ou a salva é o próprio texto do estudo:
          // abre marcado. Outra leitura já escolhida continua valendo.
          _useStudy =
              cur == null ||
              (cur.bookAbbrev == r.bookAbbrev && cur.from == r.from);
        });
      });
    }
    BibleService.instance.books().then((books) {
      if (!mounted) return;
      final cur = widget.current;
      var index = books.indexWhere((b) => b.abbrev == cur?.bookAbbrev);
      if (index < 0) index = _book.clamp(0, books.length - 1);
      setState(() {
        _books = books;
        _book = index;
        _from = cur?.from ?? 1;
        _to = cur?.to ?? 1;
        _clamp();
      });
    });
  }

  int get _maxChapter =>
      _books.isEmpty ? 1 : _books[_book].chapters.length.clamp(1, 999);

  void _clamp() {
    _from = _from.clamp(1, _maxChapter);
    _to = _to.clamp(_from, _maxChapter);
    if (_to - _from >= RoomReading.maxChapters) {
      _to = _from + RoomReading.maxChapters - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return AppSheetPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            title: widget.startOnly
                ? l10n.planPickReadingTitle
                : l10n.roomReadingPickTitle,
            subtitle: widget.startOnly
                ? l10n.planPickReadingSubtitle
                : l10n.roomReadingPickerSubtitle(RoomReading.maxChapters),
            cloud: false,
          ),
          const SizedBox(height: AppSpace.lg),
          if (_fromStudy != null) ...[
            GlassCard(
              tint: AppRoles.presence,
              borderColor: _useStudy ? a.selected : null,
              glow: _useStudy ? 0.35 : null,
              onTap: () => setState(() => _useStudy = !_useStudy),
              child: Row(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyph.link,
                    size: AppMetrics.leadingIcon,
                    accent: AppColors.cedar,
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.roomReadingSameAsStudy,
                          style: AppTypography.title(size: 15, color: a.text),
                        ),
                        const SizedBox(height: AppSpace.xs),
                        Text(
                          l10n.roomReadingSameAsStudyBody(
                            _fromStudy!.label,
                            widget.study!.title,
                          ),
                          style: AppTypography.body(
                            size: 13,
                            color: a.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  // Marcador sempre visível: vazio = não escolhido.
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _useStudy ? a.selected : Colors.transparent,
                      border: Border.all(
                        color: _useStudy ? a.selected : a.textFaint,
                        width: 2,
                      ),
                    ),
                    child: _useStudy
                        ? Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: a.onDark ? Colors.black : Colors.white,
                          )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.md),
            SectionLabel(l10n.roomReadingOrOther),
            const SizedBox(height: AppSpace.sm),
          ],
          if (_books.isEmpty)
            const Center(child: AppSpinner())
          else ...[
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: _useStudy ? 0.4 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: _book,
                    isExpanded: true,
                    dropdownColor: a.cardFill,
                    decoration: InputDecoration(
                      labelText: l10n.roomReadingBook,
                    ),
                    items: [
                      for (var i = 0; i < _books.length; i++)
                        DropdownMenuItem(value: i, child: Text(_books[i].name)),
                    ],
                    onChanged: (v) => setState(() {
                      _useStudy = false;
                      _book = v ?? _book;
                      _from = 1;
                      _to = 1;
                      _clamp();
                    }),
                  ),
                  const SizedBox(height: AppSpace.md),
                  Row(
                    children: [
                      Expanded(
                        child: _Stepper(
                          label: widget.startOnly
                              ? l10n.planPickReadingChapter
                              : l10n.roomReadingFrom,
                          value: _from,
                          onChanged: (v) => setState(() {
                            _useStudy = false;
                            _from = v;
                            if (_to < _from) _to = _from;
                            _clamp();
                          }),
                        ),
                      ),
                      if (!widget.startOnly) ...[
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: _Stepper(
                            label: l10n.roomReadingTo,
                            value: _to,
                            onChanged: (v) => setState(() {
                              _useStudy = false;
                              _to = v < _from ? _from : v;
                              _clamp();
                            }),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            CopperCta(
              label: widget.startOnly
                  ? l10n.planPickReadingSave
                  : l10n.roomReadingSave,
              expanded: true,
              onTap: () {
                final same = _fromStudy;
                if (_useStudy && same != null) {
                  Navigator.of(context).pop(same);
                  return;
                }
                final book = _books[_book];
                Navigator.of(context).pop(
                  RoomReading(
                    bookAbbrev: book.abbrev,
                    bookName: book.name,
                    from: _from,
                    to: _to,
                    week: LeagueService.weekKey(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    // Rótulo numa linha só em cima; − número + embaixo. Lado a lado, o
    // rótulo quebrava letra por letra em tela estreita.
    return GlassCard(
      padding: AppMetrics.cardPaddingCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.label(size: 12, color: a.textSecondary),
          ),
          Row(
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: AppTypography.title(size: 22, color: a.text),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => onChanged(value + 1),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Só o líder, no fim da lista de pessoas da Semana do grupo: fecha a
/// semana e revela (ou revê a revelação já feita).
class RoomCloseWeekCta extends StatelessWidget {
  final bool closedThisWeek;
  final bool closing;
  final VoidCallback onClose;
  final VoidCallback? onReveal;

  const RoomCloseWeekCta({
    super.key,
    required this.closedThisWeek,
    required this.onClose,
    this.closing = false,
    this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (closedThisWeek && onReveal != null)
          GhostCta(
            label: l10n.roomRevealAgain,
            leading: CinematicGlyph.spark,
            expanded: true,
            onTap: onReveal,
          )
        else
          CopperCta(
            label: closing ? l10n.roomCloseWeekBusy : l10n.roomCloseWeek,
            leading: CinematicGlyph.spark,
            expanded: true,
            onTap: closing ? null : onClose,
          ),
        const SizedBox(height: AppSpace.xs),
        Text(
          l10n.roomCloseWeekHint,
          textAlign: TextAlign.center,
          style: AppTypography.body(size: 12, color: a.textFaint),
        ),
      ],
    );
  }
}

/// Para quem não é líder: a semana foi fechada e a revelação espera.
class RoomClosingBanner extends StatelessWidget {
  final RoomClosing closing;
  final VoidCallback onOpen;

  const RoomClosingBanner({
    super.key,
    required this.closing,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return ProfilePanel(
      accent: AppRoles.reward,
      lit: true,
      onTap: onOpen,
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.spark,
            size: AppMetrics.leadingIcon,
            accent: AppRoles.reward,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  closing.isPlan
                      ? l10n.planClosingBannerTitle
                      : l10n.roomClosingBannerTitle,
                  style: AppTypography.title(size: 15, color: a.text),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  l10n.roomClosingBannerBody,
                  style: AppTypography.body(size: 13, color: a.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Perfil: selos "Fiel na semana" ganhos nos grupos.
class GroupSealsCard extends StatelessWidget {
  final int count;

  const GroupSealsCard({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final l10n = context.l10n;
    return ProfilePanel(
      accent: AppRoles.reward,
      child: Row(
        children: [
          CinematicIcon(
            glyph: CinematicGlyph.shield,
            size: AppMetrics.leadingIcon,
            accent: AppRoles.reward,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.roomSealCount(count),
                  style: AppTypography.title(size: 15, color: a.text),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  l10n.profileGroupSealsBody,
                  style: AppTypography.body(size: 13, color: a.textSecondary),
                ),
              ],
            ),
          ),
          // Só aparece no próprio perfil (fora dele o olho some).
          PrivacyEye(
            sections: const {CaravanProfileSection.groupSeals},
            label: l10n.profileSectionGroupSeals,
          ),
        ],
      ),
    );
  }
}
