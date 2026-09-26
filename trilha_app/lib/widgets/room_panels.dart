import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/trail_repository.dart';
import '../models/study_room.dart';
import '../models/trail.dart';
import '../models/trail_catalog.dart';
import '../data/mission_study.dart';
import '../services/bible_service.dart';
import '../services/league_service.dart';
import '../services/room_service.dart';
import '../services/session_composer.dart';
import '../theme/app_theme.dart';
import '../utils/appearance.dart';
import '../utils/trail_visuals.dart';
import 'act_feel.dart';
import 'app_sheet.dart';
import 'cinematic_icon.dart';
import 'hero_card_atmosphere.dart';
import 'immersive_background.dart';
import 'portrait_face.dart';
import 'ui_primitives.dart';

/// Peças da aba Grupos: estudo da semana, quem precisa de um chamado e as
/// sheets do líder (tipo/nome, escolher estudo, menu, passar liderança).

/// Dias sem estudar a partir dos quais a pessoa aparece em "Chamar".
const int kRoomCallAfterDays = 3;

// ───────────────────────── Estudo da semana ─────────────────────────

class RoomStudyCard extends StatelessWidget {
  final StudyRoom room;
  final RoomStudy? study;
  final List<RoomMember> members;
  final bool isLeader;
  final VoidCallback onPick;
  final VoidCallback onOpen;

  const RoomStudyCard({
    super.key,
    required this.room,
    required this.study,
    required this.members,
    required this.isLeader,
    required this.onPick,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final s = study;
    if (s == null) {
      return _EmptyStage(room: room, isLeader: isLeader, onPick: onPick);
    }

    final a = Appearance.of(context);
    final total = members.length;
    final doneList = [
      for (final m in members)
        if (m.didStudy(s)) m,
    ];
    final meDone = doneList.any((m) => m.isUser);
    final verse = s.verse?.trim();

    return GlassCard(
      tint: meDone ? AppColors.teal : AppColors.accent,
      glow: meDone ? 0.3 : 0.75,
      elevated: !meDone,
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 8, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SectionLabel(
                      'Estudo da semana',
                      color: meDone ? AppColors.teal : AppColors.accent,
                    ),
                    const Spacer(),
                    if (isLeader)
                      TextCta(
                        label: 'Trocar',
                        leading: CinematicGlyph.pencil,
                        onTap: onPick,
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        s.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.display(
                          size: 24,
                          height: 1.08,
                          color: a.text,
                        ),
                      ),
                      if (verse != null && verse.isNotEmpty) ...[
                        const SizedBox(height: AppSpace.md),
                        _VerseStage(text: verse, reference: s.verseRef),
                      ] else if (s.verseRef != null &&
                          s.verseRef!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          s.verseRef!,
                          style: AppTypography.body(
                            size: 13,
                            weight: FontWeight.w700,
                            color: AppColors.accent.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                      if (s.note != null && s.note!.isNotEmpty) ...[
                        const SizedBox(height: AppSpace.md),
                        _LeaderNote(
                          title:
                              '${room.kind.leaderTitle} ${_firstName(room.ownerName)}',
                          note: s.note!,
                        ),
                      ],
                      if (total > 0) ...[
                        const SizedBox(height: AppSpace.lg),
                        Row(
                          children: [
                            _FaceRow(people: doneList, size: 24),
                            if (doneList.isNotEmpty)
                              const SizedBox(width: AppSpace.sm),
                            Expanded(
                              child: Text(
                                doneList.isEmpty
                                    ? 'Ninguém fez ainda. Seja o primeiro.'
                                    : '${doneList.length} de $total já fizeram',
                                style: AppTypography.body(
                                  size: 13,
                                  weight: FontWeight.w700,
                                  color: a.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.sm),
                        AppProgressBar(
                          value: (doneList.length / total).clamp(0.0, 1.0),
                          color: AppColors.teal,
                        ),
                      ],
                      const SizedBox(height: AppSpace.lg),
                      if (meDone)
                        GhostCta(
                          label: 'Você já fez · Estudar de novo',
                          leading: CinematicGlyph.check,
                          expanded: true,
                          onTap: onOpen,
                        )
                      else
                        CopperCta(
                          label: 'Estudar com o grupo',
                          onTap: onOpen,
                          leading: CinematicGlyph.book,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Sem estudo marcado: um palco vazio. O líder é convidado a escolher.
class _EmptyStage extends StatelessWidget {
  final StudyRoom room;
  final bool isLeader;
  final VoidCallback onPick;

  const _EmptyStage({
    required this.room,
    required this.isLeader,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GlassCard(
      glow: isLeader ? 0.55 : null,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Estudo da semana', color: AppColors.accent),
          const SizedBox(height: AppSpace.md),
          CustomPaint(
            painter: _DashedFramePainter(color: a.textMuted(0.18)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Column(
                children: [
                  CinematicIcon(
                    glyph: CinematicGlyph.scroll,
                    size: 34,
                    accent: AppColors.accent.withValues(alpha: 0.8),
                    framed: false,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    isLeader
                        ? 'Qual texto o grupo vai estudar nesta semana?'
                        : 'O texto da semana ainda não chegou.',
                    textAlign: TextAlign.center,
                    style: AppTypography.verse(
                      size: 20,
                      fontStyle: FontStyle.italic,
                      color: a.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isLeader
                        ? 'Todos recebem a mesma cena — mesmo quem ainda não chegou nela na trilha.'
                        : '${room.kind.leaderTitle} escolhe a cena que o grupo estuda junto.',
                    textAlign: TextAlign.center,
                    style: AppTypography.body(
                      size: 13,
                      height: 1.35,
                      color: a.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLeader) ...[
            const SizedBox(height: AppSpace.lg),
            CopperCta(
              label: 'Escolher o estudo',
              onTap: onPick,
              leading: CinematicGlyph.book,
              trailing: null,
              dense: true,
            ),
          ],
        ],
      ),
    );
  }
}

/// Trecho da Palavra com fio dourado à esquerda.
class _VerseStage extends StatelessWidget {
  final String text;
  final String? reference;

  const _VerseStage({super.key, required this.text, this.reference});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.hair),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accent,
                  AppColors.accent.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '“${text.replaceAll(RegExp(r'[,;:]\s*…$'), '…')}”',
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.verse(
                    size: 19,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    color: a.text,
                  ),
                ),
                if (reference != null && reference!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  SectionLabel(
                    reference!,
                    size: 10,
                    color: AppColors.accent.withValues(alpha: 0.9),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderNote extends StatelessWidget {
  final String title;
  final String note;

  const _LeaderNote({required this.title, required this.note});

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return InsetPanel(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: CinematicIcon(
              glyph: CinematicGlyph.mail,
              size: 16,
              accent: AppColors.accent.withValues(alpha: 0.85),
              framed: false,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(title, size: 10),
                const SizedBox(height: 3),
                Text(
                  note,
                  style: AppTypography.body(
                    size: 14,
                    height: 1.4,
                    color: a.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Rostos sobrepostos de quem já fez.
class _FaceRow extends StatelessWidget {
  final List<RoomMember> people;
  final double size;

  const _FaceRow({required this.people, this.size = 24});

  @override
  Widget build(BuildContext context) {
    if (people.isEmpty) return const SizedBox.shrink();
    final shown = people.take(5).toList();
    final step = size * 0.64;
    return SizedBox(
      width: size + step * (shown.length - 1),
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < shown.length; i++)
            Positioned(
              left: step * i,
              child: Container(
                width: size,
                height: size,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.nightMid,
                  border: Border.all(color: AppColors.night, width: 1.5),
                ),
                child: PortraitFace(
                  name: shown[i].name,
                  photoUrl: shown[i].photoUrl,
                  seed: shown[i].uid,
                  size: size,
                  style: shown[i].portraitStyle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashedFramePainter extends CustomPainter {
  final Color color;

  const _DashedFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(AppRadii.md),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedFramePainter old) => old.color != color;
}

// ───────────────────────── Pessoa do grupo ─────────────────────────

/// Toque numa pessoa do grupo: quem é, como está e (se for o caso) chamar.
/// Devolve `true` quando a pessoa escolheu chamar.
Future<bool?> showRoomSeatSheet(
  BuildContext context, {
  required RoomMember member,
  required String status,
  required bool isLeader,
  required String leaderTitle,
  required RoomStudy? study,
  required bool canCall,
  required bool alreadyCalled,
}) {
  return showAppSheet<bool>(
    context,
    builder: (ctx) {
      final a = Appearance.of(ctx);
      final today = member.walkedToday();
      final first = _firstName(member.name);
      final quiet =
          !member.walkedThisWeek &&
          (member.daysSinceWalk() == null ||
              member.daysSinceWalk()! >= kRoomCallAfterDays);
      final face = PortraitFace(
        name: member.name,
        photoUrl: member.photoUrl,
        seed: member.uid,
        size: 84,
        style: member.portraitStyle,
      );
      return AppSheetPanel(
        tint: today ? AppColors.accent : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 84,
                height: 84,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.nightMid,
                  boxShadow: today
                      ? [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.4),
                            blurRadius: 22,
                          ),
                        ]
                      : null,
                ),
                foregroundDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: today ? AppColors.accent : a.cardBorder,
                    width: 2,
                  ),
                ),
                child: quiet
                    ? HeroCardColorGrade(mood: HeroCardMood.dusty, child: face)
                    : face,
              ),
            ),
            const SizedBox(height: AppSpace.md),
            AppSheetHeader(
              title: member.isUser ? 'Você' : member.name,
              center: true,
            ),
            if (isLeader) ...[
              const SizedBox(height: 6),
              Center(
                child: SoftBadge(
                  text: leaderTitle,
                  glyph: CinematicGlyph.crown,
                  accent: AppColors.accent,
                ),
              ),
            ],
            const SizedBox(height: AppSpace.sm),
            Text(
              status[0].toUpperCase() + status.substring(1),
              textAlign: TextAlign.center,
              style: AppTypography.body(
                size: 14,
                weight: FontWeight.w700,
                color: today ? AppColors.accent : a.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            _WeekDaysStrip(days: member.weekDays),
            const SizedBox(height: AppSpace.md),
            InsetPanel(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  _SeatStat(
                    value: '${member.daysThisWeek}/7',
                    label: 'Dias na semana',
                    highlight: member.daysThisWeek > 0,
                  ),
                  Container(width: 1, height: 28, color: a.cardBorder),
                  _SeatStat(value: '${member.steps}', label: 'Passos'),
                  Container(width: 1, height: 28, color: a.cardBorder),
                  _SeatStat(
                    value: study == null
                        ? '—'
                        : (member.didStudy(study) ? 'Feito' : 'Ainda não'),
                    label: 'Estudo da semana',
                    highlight: member.didStudy(study),
                  ),
                ],
              ),
            ),
            if (canCall) ...[
              const SizedBox(height: AppSpace.lg),
              CopperCta(
                label: 'Acenar para $first',
                onTap: () => Navigator.pop(ctx, true),
                leading: CinematicGlyph.bell,
                trailing: null,
              ),
            ] else if (alreadyCalled) ...[
              const SizedBox(height: AppSpace.md),
              Text(
                'Você já acenou para $first hoje.',
                textAlign: TextAlign.center,
                style: AppTypography.body(size: 13, color: a.textFaint),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _SeatStat extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;

  const _SeatStat({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.title(
              size: 18,
              weight: FontWeight.w900,
              color: highlight ? AppColors.teal : a.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.label(
              size: 10,
              letterSpacing: 0.3,
              color: a.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

/// Seg → Dom: dia cheio quando a pessoa estudou; hoje com contorno.
class _WeekDaysStrip extends StatelessWidget {
  final List<int> days;

  const _WeekDaysStrip({required this.days});

  static const _labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final today = DateTime.now().weekday;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var d = 1; d <= 7; d++)
          Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: days.contains(d)
                      ? AppColors.accent
                      : d > today
                      ? Colors.transparent
                      : a.cardFillSoft,
                  border: Border.all(
                    color: d == today
                        ? AppColors.accent
                        : days.contains(d)
                        ? AppColors.accent
                        : a.cardBorder,
                    width: d == today ? 2 : 1,
                  ),
                ),
                child: days.contains(d)
                    ? const Center(
                        child: CinematicIcon(
                          glyph: CinematicGlyph.check,
                          size: 14,
                          accent: AppColors.inkOnAccent,
                          framed: false,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 4),
              Text(
                _labels[d - 1],
                style: AppTypography.label(
                  size: 10,
                  letterSpacing: 0.4,
                  color: d == today ? AppColors.accent : a.textFaint,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// ───────────────────────── Tipo e nome do grupo ─────────────────────────

typedef RoomSetup = ({String name, RoomKind kind});

Future<RoomSetup?> showRoomSetupSheet(
  BuildContext context, {
  String title = 'Novo grupo',
  String confirmLabel = 'Criar grupo',
  String initialName = '',
  RoomKind initialKind = RoomKind.celula,
}) {
  return showAppSheet<RoomSetup>(
    context,
    builder: (_) => _RoomSetupSheet(
      title: title,
      confirmLabel: confirmLabel,
      initialName: initialName,
      initialKind: initialKind,
    ),
  );
}

class _RoomSetupSheet extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final String initialName;
  final RoomKind initialKind;

  const _RoomSetupSheet({
    required this.title,
    required this.confirmLabel,
    required this.initialName,
    required this.initialKind,
  });

  @override
  State<_RoomSetupSheet> createState() => _RoomSetupSheetState();
}

class _RoomSetupSheetState extends State<_RoomSetupSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );
  late RoomKind _kind = widget.initialKind;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, (name: name, kind: _kind));
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return AppSheetPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(title: widget.title),
          const SizedBox(height: AppSpace.lg),
          const SectionLabel('Para que é o grupo'),
          const SizedBox(height: AppSpace.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final k in RoomKind.values)
                _KindChip(
                  kind: k,
                  selected: k == _kind,
                  onTap: () => setState(() => _kind = k),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.lg),
          const SectionLabel('Nome'),
          const SizedBox(height: AppSpace.sm),
          TextField(
            controller: _name,
            maxLength: 40,
            textCapitalization: TextCapitalization.sentences,
            style: AppTypography.body(size: 16, color: a.text),
            decoration: InputDecoration(
              hintText: _kind.namePlaceholder,
              counterText: '',
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Até $kRoomMemberLimit pessoas. Grupo grande? Abra outro — '
            'discipulado acontece em grupo pequeno.',
            style: AppTypography.body(
              size: 12,
              height: 1.35,
              color: a.textFaint,
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          ValueListenableBuilder(
            valueListenable: _name,
            builder: (context, value, _) => CopperCta(
              label: widget.confirmLabel,
              onTap: value.text.trim().isEmpty ? null : _submit,
              leading: _kind.glyph,
              trailing: null,
            ),
          ),
        ],
      ),
    );
  }
}

class _KindChip extends StatelessWidget {
  final RoomKind kind;
  final bool selected;
  final VoidCallback onTap;

  const _KindChip({
    required this.kind,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return GestureDetector(
      onTap: () {
        ActHaptics.tap();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.16)
              : a.cardFillSoft,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: selected ? AppColors.accent : a.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CinematicIcon(
              glyph: kind.glyph,
              size: 16,
              accent: selected ? AppColors.accent : a.textSecondary,
              framed: false,
            ),
            const SizedBox(width: 6),
            Text(
              kind.label,
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w800,
                color: selected ? AppColors.accent : a.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Escolher o estudo ─────────────────────────

Future<RoomStudy?> showRoomStudyPicker(BuildContext context) {
  return showAppSheet<RoomStudy>(
    context,
    builder: (_) => const _RoomStudyPicker(),
  );
}

class _RoomStudyPicker extends StatefulWidget {
  const _RoomStudyPicker();

  @override
  State<_RoomStudyPicker> createState() => _RoomStudyPickerState();
}

class _RoomStudyPickerState extends State<_RoomStudyPicker> {
  late final Future<List<Trail>> _trails = TrailRepository().getTrails();
  final _note = TextEditingController();
  Trail? _trail;
  Mission? _mission;

  /// Palco da cena (ref + trecho) — o mesmo que a missão abre.
  ({String? ref, String? verse})? _stage;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _back() => setState(() {
    if (_mission != null) {
      _mission = null;
      _stage = null;
    } else {
      _trail = null;
    }
  });

  Future<void> _pickMission(Mission m) async {
    setState(() {
      _mission = m;
      _stage = null;
    });
    final stage = await _resolveStage(m);
    if (!mounted || _mission?.slug != m.slug) return;
    setState(() => _stage = stage);
  }

  static final _refLike = RegExp(r'\d');

  static Future<({String? ref, String? verse})> _resolveStage(Mission m) async {
    final study =
        MissionStudy.forSlug(m.slug) ??
        MissionStudy.forSlug(m.resolvedBankSection);
    final entrance = SessionComposer.resolveEntrance(
      mission: m,
      studyRef: study?.passageRef,
      studyVerse: study?.passageText,
      studyContext: study?.context,
    );
    var ref = (entrance.ref ?? '').trim();
    var verse = (entrance.verse ?? '').trim();
    // Catálogo sem palco: o subtítulo da cena já é a referência.
    if (ref.isEmpty && _refLike.hasMatch(m.subtitle)) ref = m.subtitle.trim();
    if (ref.isNotEmpty) {
      try {
        final full = await BibleService.instance.passageText(
          ref,
          translationId: BibleService.palcoTranslationId,
        );
        if (full != null && full.trim().isNotEmpty) verse = full.trim();
      } catch (_) {}
    }
    if (verse.isNotEmpty) {
      verse = SessionComposer.clipEntranceVerse(
        verse,
        maxWords: 36,
      ).replaceAll(RegExp(r'[,;:]\s*…$'), '…');
    }
    return (ref: ref.isEmpty ? null : ref, verse: verse.isEmpty ? null : verse);
  }

  void _confirm() {
    final m = _mission;
    if (m == null) return;
    Navigator.pop(
      context,
      RoomStudy(
        missionSlug: m.slug,
        title: m.title,
        verseRef: _stage?.ref ?? m.hookRef,
        verse: _stage?.verse ?? m.hookVerse,
        note: _note.text.trim(),
        week: LeagueService.weekKey(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    // Com teclado aberto (recado), o painel encolhe em vez de transbordar.
    final screen = MediaQuery.sizeOf(context).height;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final top = MediaQuery.paddingOf(context).top;
    final height = (screen * 0.72)
        .clamp(0.0, screen - keyboard - top - 96)
        .toDouble();
    final heading = _mission != null
        ? 'Marcar a cena'
        : (_trail?.title ?? 'Estudo da semana');

    return AppSheetPanel(
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                if (_trail != null)
                  IconButton(
                    onPressed: _back,
                    icon: CinematicIcon(
                      glyph: CinematicGlyph.back,
                      size: 20,
                      accent: a.text,
                      framed: false,
                    ),
                  ),
                Expanded(
                  child: Text(
                    heading,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title(size: 20, color: a.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            Expanded(
              child: _mission != null
                  ? _noteStep(a)
                  : FutureBuilder<List<Trail>>(
                      future: _trails,
                      builder: (context, snap) {
                        if (!snap.hasData) {
                          return const AppSpinner();
                        }
                        final t = _trail;
                        return t == null
                            ? _trailList(snap.data!, a)
                            : _missionList(t, a);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _trailList(List<Trail> all, AppearanceStyle a) {
    final trails = [
      for (final t in all)
        if (!t.comingSoon && t.missionSlugs.isNotEmpty) t,
    ];
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpace.sm),
          child: Text(
            'Todos do grupo recebem a mesma cena, mesmo quem ainda não chegou nela.',
            style: AppTypography.body(size: 13, color: a.textSecondary),
          ),
        ),
        for (final realm in TrailRealm.values)
          if (trails.any((t) => TrailRealm.fromId(t.realmId) == realm)) ...[
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.md, bottom: 4),
              child: SectionLabel(realm.label),
            ),
            for (final t in trails)
              if (TrailRealm.fromId(t.realmId) == realm)
                _PickRow(
                  leading: _TrailDisc(visuals: TrailVisuals.forTrail(t)),
                  title: t.title,
                  subtitle: '${t.missionSlugs.length} cenas',
                  onTap: () => setState(() => _trail = t),
                ),
          ],
      ],
    );
  }

  Widget _missionList(Trail trail, AppearanceStyle a) {
    return ListView(
      children: [
        for (final mod in trail.modules)
          if (mod.missions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.md, bottom: 4),
              child: SectionLabel(mod.title),
            ),
            for (final m in mod.missions)
              _PickRow(
                leading: _SceneNumber(
                  n: trail.missionSlugs.indexOf(m.slug) + 1,
                  accent: TrailVisuals.forTrail(trail).accent,
                ),
                title: m.title,
                subtitle: m.hookRef ?? m.subtitle,
                onTap: () => _pickMission(m),
              ),
          ],
      ],
    );
  }

  Widget _noteStep(AppearanceStyle a) {
    final m = _mission!;
    final stage = _stage;
    return ListView(
      children: [
        SectionLabel('O grupo vai ver'),
        const SizedBox(height: AppSpace.sm),
        InsetPanel(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                m.title,
                style: AppTypography.display(size: 20, color: a.text),
              ),
              const SizedBox(height: AppSpace.md),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                child: stage == null
                    ? const SizedBox(
                        key: ValueKey('loading'),
                        height: 48,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      )
                    : stage.verse != null
                    ? _VerseStage(
                        key: const ValueKey('verse'),
                        text: stage.verse!,
                        reference: stage.ref,
                      )
                    : Text(
                        stage.ref ?? m.subtitle,
                        key: const ValueKey('ref'),
                        style: AppTypography.body(
                          size: 13,
                          color: AppColors.accent.withValues(alpha: 0.9),
                        ),
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        SectionLabel('Recado para o grupo'),
        const SizedBox(height: AppSpace.sm),
        TextField(
          controller: _note,
          maxLength: 160,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          style: AppTypography.body(size: 14, color: a.text),
          decoration: const InputDecoration(
            hintText: 'Opcional. Ex.: Leiam até quarta, conversamos na quinta.',
          ),
        ),
        const SizedBox(height: AppSpace.md),
        CopperCta(
          label: 'Marcar para o grupo',
          onTap: stage == null ? null : _confirm,
          busy: stage == null,
          leading: CinematicGlyph.check,
          trailing: null,
        ),
      ],
    );
  }
}

class _PickRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _PickRow({
    this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 14)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.title(size: 14, color: a.text),
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.body(
                        size: 12,
                        color: a.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            ListChevron(color: a.textFaint),
          ],
        ),
      ),
    );
  }
}

/// Selo da trilha — o mesmo glifo e gradiente do mapa de trilhas.
class _TrailDisc extends StatelessWidget {
  final TrailVisuals visuals;

  const _TrailDisc({required this.visuals});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: visuals.iconGradient,
        boxShadow: [
          BoxShadow(
            color: visuals.glow.withValues(alpha: 0.35),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: CinematicIcon(
          glyph: visuals.glyph,
          size: 20,
          accent: AppColors.inkOnAccent,
          framed: false,
        ),
      ),
    );
  }
}

/// Número da cena na trilha.
class _SceneNumber extends StatelessWidget {
  final int n;
  final Color accent;

  const _SceneNumber({required this.n, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.12),
        border: Border.all(color: accent.withValues(alpha: 0.55)),
      ),
      child: Center(
        child: Text(
          '$n',
          style: AppTypography.title(
            size: 13,
            weight: FontWeight.w900,
            color: accent,
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Menu do grupo ─────────────────────────

enum RoomMenuAction { copyCode, edit, goal, clearStudy, transfer, leave, close }

Future<RoomMenuAction?> showRoomMenu(
  BuildContext context, {
  required StudyRoom room,
  required bool isLeader,
  required bool hasStudy,
  required bool canTransfer,
}) {
  return showAppSheet<RoomMenuAction>(
    context,
    builder: (ctx) {
      Widget item(
        RoomMenuAction action,
        String label,
        CinematicGlyph glyph, {
        bool danger = false,
      }) {
        final a = Appearance.of(ctx);
        final ink = danger ? AppColors.error : a.text;
        return InkWell(
          onTap: () => Navigator.pop(ctx, action),
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: Row(
              children: [
                CinematicIcon(
                  glyph: glyph,
                  size: AppMetrics.leadingIcon,
                  accent: danger ? AppColors.error : AppColors.accent,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.title(size: 14, color: ink),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return AppSheetPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppSheetHeader(title: room.name),
            const SizedBox(height: AppSpace.sm),
            item(
              RoomMenuAction.copyCode,
              'Copiar código ${room.code}',
              CinematicGlyph.copy,
            ),
            if (isLeader) ...[
              const Padding(
                padding: EdgeInsets.only(top: AppSpace.md, bottom: 2),
                child: SectionLabel('Conduzir o grupo'),
              ),
              item(
                RoomMenuAction.edit,
                'Editar nome e tipo',
                CinematicGlyph.pencil,
              ),
              item(
                RoomMenuAction.goal,
                room.weeklyGoalSteps != null
                    ? 'Meta da semana · ${room.weeklyGoalSteps} passos'
                    : 'Definir meta da semana',
                CinematicGlyph.target,
              ),
              if (hasStudy)
                item(
                  RoomMenuAction.clearStudy,
                  'Tirar estudo da semana',
                  CinematicGlyph.close,
                ),
              if (canTransfer)
                item(
                  RoomMenuAction.transfer,
                  'Passar a liderança',
                  CinematicGlyph.crown,
                ),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpace.sm),
              child: Divider(height: 1),
            ),
            item(
              RoomMenuAction.leave,
              'Sair do grupo',
              CinematicGlyph.back,
              danger: true,
            ),
            if (isLeader)
              item(
                RoomMenuAction.close,
                'Encerrar o grupo',
                CinematicGlyph.stop,
                danger: true,
              ),
          ],
        ),
      );
    },
  );
}

/// Escolhe quem assume o grupo.
Future<RoomMember?> showRoomMemberPicker(
  BuildContext context, {
  required String title,
  required String body,
  required List<RoomMember> members,
}) {
  return showAppSheet<RoomMember>(
    context,
    builder: (ctx) {
      final a = Appearance.of(ctx);
      final others = [
        for (final m in members)
          if (!m.isUser) m,
      ];
      return AppSheetPanel(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSheetHeader(title: title, subtitle: body),
              const SizedBox(height: AppSpace.md),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final m in others)
                      InkWell(
                        onTap: () => Navigator.pop(ctx, m),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              PortraitFace(
                                name: m.name,
                                photoUrl: m.photoUrl,
                                seed: m.uid,
                                size: 34,
                                style: m.portraitStyle,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  m.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.title(
                                    size: 14,
                                    color: a.text,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _firstName(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  return parts.isEmpty || parts.first.isEmpty ? name : parts.first;
}

/// Convite que chegou: a pessoa entra no grupo ou recusa, no próprio app.
class RoomIncomingInviteCard extends StatelessWidget {
  final RoomInvite invite;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const RoomIncomingInviteCard({
    super.key,
    required this.invite,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final from = _firstName(invite.fromName);
    return GlassCard(
      glow: 0.7,
      tint: AppColors.accent,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionLabel('Convite', color: AppColors.accent),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              PortraitFace(
                name: invite.fromName,
                photoUrl: invite.fromPhotoUrl,
                seed: invite.fromUid,
                size: 42,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.roomName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title(size: 16, color: a.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$from te chamou para este ${invite.kind.label.toLowerCase()}.',
                      style: AppTypography.body(
                        size: 13,
                        height: 1.3,
                        color: a.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          CopperCta(
            label: 'Entrar no grupo',
            leading: CinematicGlyph.check,
            trailing: null,
            dense: true,
            onTap: onAccept,
          ),
          const SizedBox(height: AppSpace.xs),
          Center(
            child: TextCta(label: 'Agora não', onTap: onDecline),
          ),
        ],
      ),
    );
  }
}

/// Abre ao tocar em Chamar pessoas: escolhe quem da caravana ou manda o link.
Future<void> showRoomCallSheet(
  BuildContext context, {
  required List<LeagueEntry> people,
  required Future<bool> Function(LeagueEntry person) onInvite,
  required Future<bool> Function(LeagueEntry person) onCancel,
  required VoidCallback onShareLink,
}) {
  return showAppSheet<void>(
    context,
    builder: (ctx) => _RoomCallSheet(
      people: people,
      onInvite: onInvite,
      onCancel: onCancel,
      onShareLink: () {
        Navigator.pop(ctx);
        onShareLink();
      },
    ),
  );
}

class _RoomCallSheet extends StatefulWidget {
  final List<LeagueEntry> people;
  final Future<bool> Function(LeagueEntry person) onInvite;
  final Future<bool> Function(LeagueEntry person) onCancel;
  final VoidCallback onShareLink;

  const _RoomCallSheet({
    required this.people,
    required this.onInvite,
    required this.onCancel,
    required this.onShareLink,
  });

  @override
  State<_RoomCallSheet> createState() => _RoomCallSheetState();
}

class _RoomCallSheetState extends State<_RoomCallSheet> {
  final Set<String> _busy = {};
  final Set<String> _invited = {};
  String? _error;

  Future<void> _invite(LeagueEntry person) async {
    final uid = person.uid;
    if (uid == null || _busy.contains(uid) || _isInvited(uid)) return;
    setState(() {
      _busy.add(uid);
      _error = null;
    });
    try {
      final ok = await widget.onInvite(person);
      if (!mounted) return;
      if (ok) {
        setState(() => _invited.add(uid));
      } else {
        setState(() {
          _error =
              context.read<RoomService>().lastError ??
              'Não deu para enviar o convite.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy.remove(uid));
    }
  }

  Future<void> _cancel(LeagueEntry person) async {
    final uid = person.uid;
    if (uid == null || _busy.contains(uid)) return;
    setState(() {
      _busy.add(uid);
      _error = null;
    });
    try {
      final ok = await widget.onCancel(person);
      if (!mounted) return;
      if (ok) {
        setState(() => _invited.remove(uid));
      } else {
        setState(() => _error = 'Não foi possível desfazer o convite.');
      }
    } finally {
      if (mounted) setState(() => _busy.remove(uid));
    }
  }

  bool _isInvited(String? uid) {
    if (uid == null) return false;
    if (_invited.contains(uid)) return true;
    return context.read<RoomService>().pendingTargets.contains(uid);
  }

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    final rooms = context.watch<RoomService>();
    final memberIds = {for (final member in rooms.members) member.uid};
    final people = [
      for (final person in widget.people)
        if (!memberIds.contains(person.uid)) person,
    ];
    final pending = {...rooms.pendingTargets, ..._invited};
    final full = rooms.isFull;
    final maxH = MediaQuery.sizeOf(context).height * 0.72;

    return AppSheetPanel(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSheetHeader(
              title: 'Chamar pessoas',
              subtitle:
                  'O convite aparece no app. Ou mande o link no WhatsApp.',
            ),
            const SizedBox(height: AppSpace.md),
            if (people.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.md),
                child: Text(
                  'Ninguém da caravana para chamar agora.',
                  style: AppTypography.body(
                    size: 13,
                    height: 1.35,
                    color: a.textSecondary,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    for (final person in people)
                      _CaravanInviteRow(
                        person: person,
                        pending: pending.contains(person.uid),
                        busy: _busy.contains(person.uid),
                        enabled: !full,
                        onInvite: () => _invite(person),
                        onCancel: () => _cancel(person),
                      ),
                  ],
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: AppSpace.sm),
              Text(
                _error!,
                style: AppTypography.body(size: 12, color: AppColors.error),
              ),
            ],
            if (full) ...[
              const SizedBox(height: AppSpace.sm),
              Text(
                'Este grupo já tem $kRoomMemberLimit pessoas.',
                style: AppTypography.body(
                  size: 12,
                  weight: FontWeight.w700,
                  color: AppColors.streak,
                ),
              ),
            ],
            const SizedBox(height: AppSpace.md),
            GhostCta(
              label: 'Mandar no WhatsApp',
              leading: CinematicGlyph.share,
              expanded: true,
              onTap: full ? null : widget.onShareLink,
            ),
          ],
        ),
      ),
    );
  }
}

class _CaravanInviteRow extends StatelessWidget {
  final LeagueEntry person;
  final bool pending;
  final bool busy;
  final bool enabled;
  final VoidCallback onInvite;
  final VoidCallback onCancel;

  const _CaravanInviteRow({
    required this.person,
    required this.pending,
    required this.busy,
    required this.enabled,
    required this.onInvite,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final a = Appearance.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          PortraitFace(
            name: person.name,
            photoUrl: person.photoUrl,
            seed: person.uid ?? person.name,
            size: 36,
            style: person.portraitStyle,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              person.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title(size: 14, color: a.text),
            ),
          ),
          if (pending) ...[
            Text(
              busy ? '…' : 'Convidado',
              style: AppTypography.body(
                size: 13,
                weight: FontWeight.w800,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: 4),
            TextCta(label: 'Desfazer', onTap: busy ? null : onCancel),
          ] else
            TextCta(
              label: busy ? 'Enviando…' : 'Convidar',
              color: AppColors.accent,
              onTap: !enabled || busy ? null : onInvite,
            ),
        ],
      ),
    );
  }
}
