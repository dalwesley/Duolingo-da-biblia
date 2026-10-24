import 'dart:ui' show Color;

/// Tema de uma anotação — a cor pinta o versículo no leitor.
///
/// O [id] vai para o banco; nunca renomear (só acrescentar).
enum BibleNoteTag {
  promessa('promessa', Color(0xFFE0A526)),
  profecia('profecia', Color(0xFF8E6CCF)),
  jesus('jesus', Color(0xFFD2453A)),
  deus('deus', Color(0xFF3D7BD9)),
  familia('familia', Color(0xFF4FA36B)),
  oracao('oracao', Color(0xFF2E9FA6)),
  mandamento('mandamento', Color(0xFFE07B39)),
  pessoal('pessoal', Color(0xFFC0699A));

  final String id;
  final Color color;

  const BibleNoteTag(this.id, this.color);

  static BibleNoteTag? fromId(String? id) {
    for (final t in values) {
      if (t.id == id) return t;
    }
    return null;
  }
}

/// Anotação de um versículo ("abbrev:capítulo:versículo").
///
/// Apagar grava uma lápide ([deleted]) com novo [updatedAtMs]: o merge da
/// nuvem é por chave e a mais recente vence, então a nota não ressuscita.
class BibleNote {
  final BibleNoteTag? tag;
  final String text;
  final int updatedAtMs;

  const BibleNote({
    required this.tag,
    required this.text,
    required this.updatedAtMs,
  });

  bool get deleted => tag == null && text.isEmpty;

  Map<String, dynamic> toJson() => {
    'tag': tag?.id ?? '',
    'text': text,
    'at': updatedAtMs,
  };

  static BibleNote? fromJson(dynamic v) {
    if (v is! Map) return null;
    final at = v['at'];
    return BibleNote(
      tag: BibleNoteTag.fromId(v['tag']?.toString()),
      text: v['text']?.toString() ?? '',
      updatedAtMs: at is num ? at.toInt() : int.tryParse('$at') ?? 0,
    );
  }
}
