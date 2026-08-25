#!/usr/bin/env python3
"""Gera o banco V2 a partir de trails.json — 18 perguntas por missão."""
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / 'trilha_app' / 'assets' / 'data' / 'trails.json'
OUT_DIR = ROOT / 'perguntas-v2'
SECTION_MAP_PATH = OUT_DIR / 'section_slug_map.json'
REPORT_PATH = ROOT / 'RELATORIO-GERACAO.md'

DIFFICULTIES = ['semente', 'caminhada', 'profundezas']
SKILLS = {'semente': 'observe', 'caminhada': 'understand', 'profundezas': 'interpret'}
TYPE_ORDER = ['true_false', 'tap', 'choice', 'order', 'complete', 'connect']
SHORT = {'semente': 'sem', 'caminhada': 'cam', 'profundezas': 'pro'}

STOP = {
    'a', 'o', 'as', 'os', 'um', 'uma', 'uns', 'umas', 'e', 'ou', 'mas', 'que',
    'de', 'da', 'do', 'das', 'dos', 'em', 'no', 'na', 'nos', 'nas', 'por',
    'para', 'com', 'sem', 'se', 'ao', 'à', 'às', 'aos', 'lhe', 'lhes', 'me',
    'te', 'nos', 'vos', 'eu', 'tu', 'ele', 'ela', 'eles', 'elas', 'este',
    'esta', 'isso', 'isto', 'aquele', 'aquela', 'como', 'quando', 'então',
    'pois', 'porque', 'porquanto', 'porém', 'também', 'já', 'não', 'sim',
    'mais', 'muito', 'sua', 'seu', 'seus', 'suas', 'meu', 'minha',
}

VERSE_REF_START = (
    'mateus ', 'gênesis ', 'genesis ', 'romanos ', 'lucas ', 'atos ', 'joão ',
    'joao ', 'marcos ', 'êxodo ', 'exodo ', 'levítico ', 'levitico ', 'números ',
    'numeros ', 'deuteronômio ', 'deuteronomio ', 'salmo ', 'salmos ',
    'apocalipse ', 'hebreus ', 'tiago ', 'pedro ', '1 ', '2 ', 'i ', 'ii ',
)

BOILERPLATE_START = (
    'revise ', 'esta missão', 'o que este conceito revela', 'este texto chama',
    'referência:',
)


def normalize_spaces(text):
    if not text:
        return ''
    text = str(text).replace('…', '...').replace('...', ' ')
    return re.sub(r'\s+', ' ', text).strip()


def looks_like_verse_ref(value):
    lower = (value or '').lower().strip()
    if not lower:
        return False
    if not re.search(r'\d', lower):
        return False
    if len(lower) > 55:
        return False
    return lower.startswith(VERSE_REF_START) or bool(re.match(r'^\d+\s', lower))


def clip(text, limit):
    value = normalize_spaces(text)
    if len(value) <= limit:
        return value
    cut = value[:limit].rsplit(' ', 1)[0].rstrip(' ,;:')
    return cut or value[:limit]


def stable_rot(key, n):
    if n <= 1:
        return 0
    digest = hashlib.md5(key.encode('utf-8')).hexdigest()
    return int(digest, 16) % n


def rotate_options(texts, correct_text, salt, feedback_wrong):
    items = []
    seen = set()
    for t in texts:
        key = t.strip()
        low = key.lower()
        if not key or low in seen:
            continue
        seen.add(low)
        items.append(key)
    if correct_text not in items:
        items.insert(0, correct_text)
    rot = stable_rot(salt, len(items))
    items = items[rot:] + items[:rot]
    options = [{'id': chr(ord('a') + i), 'text': clip(t, 80)} for i, t in enumerate(items)]
    correct_id = next(o['id'] for o in options if o['text'].lower() == clip(correct_text, 80).lower())
    wrong = {}
    messages = list(feedback_wrong.values()) if isinstance(feedback_wrong, dict) else list(feedback_wrong)
    mi = 0
    for o in options:
        if o['id'] == correct_id:
            continue
        wrong[o['id']] = messages[mi % len(messages)] if messages else 'Releia o trecho.'
        mi += 1
    return options, correct_id, wrong


def choose_passage_text(mission):
    raw = normalize_spaces(mission.get('hookVerse') or '')
    raw = raw.strip(' .,:;!?')
    lower = raw.lower()
    if not raw or lower.startswith(BOILERPLATE_START):
        title = re.sub(r'\?$', '', (mission.get('title') or '').strip())
        hook = mission.get('hookRef') or 'esta passagem'
        return f'Deus fala e age com propósito em {hook}' + (f', no passo {title}' if title else '') + '.'
    if len(raw) > 260:
        raw = raw[:260].rsplit(' ', 1)[0].rstrip(' ,;:')
    return raw


def first_clause(passage):
    parts = [p.strip() for p in re.split(r'(?<=[.;:])\s+', passage) if p.strip()]
    clause = parts[0] if parts else passage
    clause = clip(clause.rstrip(' .;:'), 120)
    if clause and clause[-1] not in '.!?':
        clause += '.'
    return clause


def as_assertion(text):
    value = normalize_spaces(text or '').strip(' .;:!?')
    value = value.replace('?', '')
    if not value:
        return 'Deus age com propósito neste trecho.'
    if re.match(r'^(porque|porquanto|pois)\b', value, re.I):
        rest = value.split(None, 1)[1] if ' ' in value else value
        value = rest[0].upper() + rest[1:]
    elif re.match(r'^(o que|qual|quais|quem|como|por que|onde|quando)\b', value, re.I):
        value = f'O texto afirma que {value[0].lower() + value[1:]}'
    if not value.endswith('.'):
        value += '.'
    return value[0].upper() + value[1:]


def infer_central_insight(mission):
    raw = mission.get('centralInsight') or ''
    value = normalize_spaces(raw).strip(' .;:!?').replace('?', '')
    if value and re.match(r'^(o que|qual|quais|quem|como|porque|por que|onde|quando)\b', value, re.I):
        value = ''
    lower = value.lower()
    if lower.startswith(('este texto chama', 'esta missão apresenta', 'o que este conceito', 'este trecho revela', 'esta missão')):
        value = ''
    if value and len(value) <= 140:
        if not value.endswith('.'):
            value += '.'
        return value[0].upper() + value[1:]
    return as_assertion(first_clause(choose_passage_text(mission)))


def infer_learning_objective(mission):
    value = normalize_spaces(mission.get('objective') or '').strip(' .;:!?')
    title = re.sub(r'\?$', '', (mission.get('title') or 'esta passagem').strip())
    if not value or looks_like_verse_ref(value):
        return f'Compreender o sentido central de {title}.'
    if re.match(r'^(o que|qual|quais|quem|como|porque|por que|onde|quando)\b', value, re.I):
        rest = value[0].lower() + value[1:] if value else 'o sentido desta passagem'
        return f'Compreender {rest}.'
    value = re.sub(r'\bque\s+que\b', 'que', value, flags=re.I)
    if not value.endswith('.'):
        value += '.'
    return value[0].upper() + value[1:]


def normalize_section_slug(_trail_slug, mission_slug):
    return (mission_slug or '').strip() or 'missao'


def content_words(passage, min_len=4):
    words = re.findall(r"[A-Za-zÀ-ÿ]+", passage or '')
    out = []
    seen = set()
    for min_l in (min_len, 3, 2, 1):
        for w in words:
            lw = w.lower()
            if len(w) < min_l or lw in STOP or lw in seen:
                continue
            seen.add(lw)
            out.append(w)
        if len(out) >= 3:
            return out
    for w in words:
        lw = w.lower()
        if lw not in seen:
            seen.add(lw)
            out.append(w)
        if len(out) >= 3:
            break
    if len(out) < 3:
        tokens = re.findall(r"[A-Za-zÀ-ÿ]+", passage or '')
        for i in range(len(tokens) - 1):
            phrase = f'{tokens[i]} {tokens[i + 1]}'
            if phrase.lower() not in seen and tokens[i].lower() not in STOP:
                seen.add(phrase.lower())
                out.append(phrase)
            if len(out) >= 3:
                break
    while len(out) < 3 and words:
        extra = words[len(out) % len(words)]
        nxt = words[(len(out) + 1) % len(words)]
        phrase = f'{extra} {nxt}'
        if phrase.lower() not in seen:
            seen.add(phrase.lower())
            out.append(phrase)
        else:
            break
    return out


def blank_template(passage, target):
    pattern = re.compile(rf'(?i)\b{re.escape(target)}\b', re.U)
    template, n = pattern.subn('___', passage, count=1)
    if n == 0:
        template = passage + ' ___'
    return re.sub(r'\s+', ' ', template).strip()


def three_fragments(passage):
    text = normalize_spaces(passage)
    parts = [p.strip(' .;:') for p in re.split(r'(?<=[.;:])\s+', text) if p.strip(' .;:')]
    if len(parts) < 3:
        parts = [p.strip() for p in re.split(r',\s*', text) if p.strip()]
    if len(parts) >= 3:
        frags = parts[:3]
    else:
        words = text.split()
        if len(words) < 6:
            words = (words * 6)[:9]
        n = len(words)
        a, b = max(2, n // 3), max(4, (2 * n) // 3)
        if a >= b:
            b = min(n - 1, a + 2)
        frags = [' '.join(words[:a]), ' '.join(words[a:b]), ' '.join(words[b:])]
    cleaned = []
    for frag in frags:
        frag = clip(frag, 80).rstrip(' ,;:')
        frag = re.sub(r'\b(e|de|do|da|o|a|que|em|no|na)\s*$', '', frag, flags=re.I).strip()
        cleaned.append(frag or 'Deus age neste trecho')
    return cleaned


def base_fields(mission, diff):
    hook = mission.get('hookRef') or 'Texto-base'
    return {
        'difficulty': diff,
        'skill': SKILLS[diff],
        'verseRef': hook,
        'learningObjective': infer_learning_objective(mission),
        'evidence': [hook],
    }


def make_true_false_question(mission, diff, _avoid=None):
    passage = choose_passage_text(mission)
    insight = infer_central_insight(mission)
    literal = as_assertion(first_clause(passage))
    if diff == 'semente':
        statement, correct = literal, 'true'
    elif diff == 'caminhada':
        statement = 'O trecho ensina que Deus não age nesta história.'
        correct = 'false'
    else:
        statement = as_assertion(f'A passagem sustenta que {insight.rstrip(".")}')
        correct = 'true'
    statement = statement.replace('?', '')
    wrong = 'true' if correct == 'false' else 'false'
    q = {
        **base_fields(mission, diff),
        'type': 'true_false',
        'question': statement,
        'prompt': statement,
        'cue': statement,
        'feedbackCorrect': 'Certo: a afirmação é firme no texto.',
        'feedbackWrong': {wrong: 'A afirmação não corresponde ao que o texto realmente comunica.'},
        'options': [{'id': 'true', 'text': 'Verdadeiro'}, {'id': 'false', 'text': 'Falso'}],
        'correctOptionId': correct,
        'correctAnswer': correct,
        'passageText': passage,
    }
    return q


def make_gap_question(mission, diff, kind, avoid_word=None):
    passage = choose_passage_text(mission)
    words = content_words(passage)
    target = next((w for w in words if w.lower() != (avoid_word or '').lower()), words[0])
    others = [w for w in words if w.lower() != target.lower()]
    while len(others) < 2:
        others.append(words[len(others) % len(words)])
    # keep original casing from the passage
    option_texts = [target, others[0], others[1]]
    template = blank_template(passage, target)
    hook = mission.get('hookRef') or 'a passagem'
    if kind == 'tap':
        question = f'Em {hook}, toque a palavra que falta em "{template}"?'
        fb_ok = 'Exato: a palavra certa está no texto-base.'
        fb_bad = ['A palavra está no texto, mas não completa o sentido desta frase.', 'Releia o versículo e escolha a palavra que faz sentido no contexto.']
    else:
        question = f'Complete a frase: "{template}"'
        fb_ok = 'Certo: esta palavra completa a ideia do texto.'
        fb_bad = ['Essa palavra não combina com o sentido do trecho.', 'O contexto pede outra leitura do texto.']
    options, correct_id, wrong = rotate_options(
        option_texts, target, f"{mission.get('slug')}-{diff}-{kind}", {'b': fb_bad[0], 'c': fb_bad[1]},
    )
    return {
        **base_fields(mission, diff),
        'type': kind,
        'question': question,
        'prompt': question,
        'cue': question,
        'feedbackCorrect': fb_ok,
        'feedbackWrong': wrong,
        'passageText': passage,
        'template': template,
        'options': options,
        'correctOptionId': correct_id,
        'correctAnswer': correct_id,
        '_blank': target,
    }


def make_choice_question(mission, diff, _avoid=None):
    passage = choose_passage_text(mission)
    insight = infer_central_insight(mission)
    hook = mission.get('hookRef') or 'a passagem'
    fact = clip(as_assertion(first_clause(passage)).rstrip('.'), 80)
    if diff == 'semente':
        stem = f'Qual afirmação é feita diretamente pelo texto em {hook}?'
        correct = fact
        wrongs = [
            'O trecho descreve um processo sem nenhum agente.',
            'A passagem omite qualquer ação ou palavra de Deus.',
            'O texto atribui o que acontece ao acaso.',
        ]
    elif diff == 'caminhada':
        stem = f'Qual ideia melhor conecta {hook} ao contexto da missão?'
        correct = clip(insight.rstrip('.'), 80)
        wrongs = [
            'O texto se fecha em si e não pede resposta de fé.',
            'Deus permanece distante da vida humana neste trecho.',
            'A mensagem central é a autonomia completa do ser humano.',
        ]
    else:
        stem = f'Qual leitura interpreta melhor o sentido de {hook}?'
        correct = clip(insight.rstrip('.'), 80)
        wrongs = [
            'O trecho reduz a fé a um detalhe sem peso espiritual.',
            'A passagem ensina que a ação humana substitui a de Deus.',
            'O sentido do texto é que Deus se ausenta da história.',
        ]
    options, correct_id, wrong = rotate_options(
        [correct] + wrongs,
        correct,
        f"{mission.get('slug')}-{diff}-choice",
        {
            'b': 'Essa leitura não se sustenta no texto.',
            'c': 'O texto aponta para uma realidade maior que esta opção sugere.',
            'd': 'Leia novamente o trecho e compare com a mensagem central.',
        },
    )
    return {
        **base_fields(mission, diff),
        'type': 'choice',
        'question': stem,
        'prompt': stem,
        'cue': stem,
        'feedbackCorrect': 'Certo: o trecho sustenta essa leitura com clareza.',
        'feedbackWrong': wrong,
        'passageText': passage,
        'options': options,
        'correctOptionId': correct_id,
        'correctAnswer': correct_id,
    }


def make_order_question(mission, diff, _avoid=None):
    passage = choose_passage_text(mission)
    fragments = three_fragments(passage)
    options = [{'id': chr(ord('a') + i), 'text': fragments[i]} for i in range(3)]
    hook = mission.get('hookRef') or 'a passagem'
    if diff == 'semente':
        stem = f'Qual sequência mostra a ordem dos fatos em {hook}?'
    elif diff == 'caminhada':
        stem = f'Como se encadeiam os eventos de {hook}?'
    else:
        stem = f'Qual sequência revela o sentido de {hook}?'
    return {
        **base_fields(mission, diff),
        'type': 'order',
        'question': stem,
        'prompt': stem,
        'cue': stem,
        'feedbackCorrect': 'Certo: essa é a sequência que o texto mostra.',
        'feedbackWrong': {
            'b': 'A ordem está deslocada: o texto não apresenta o evento assim.',
            'c': 'Releia a sequência da passagem antes de responder.',
        },
        'passageText': passage,
        'options': options,
        'correctOrder': ['a', 'b', 'c'],
        'correctOptionId': 'a',
        'correctAnswer': 'a',
    }


def short_bridge(text, max_words=6):
    words = re.findall(r"[A-Za-zÀ-ÿ0-9]+", (text or '').rstrip('.'))
    if not words:
        return 'Deus age com propósito'
    return ' '.join(words[:max_words])


def make_connect_question(mission, diff, _avoid=None):
    insight = infer_central_insight(mission)
    hook = mission.get('hookRef') or 'Texto-base'
    passage = choose_passage_text(mission)
    passage_a = clip(passage, 150)
    if diff == 'semente':
        correct = short_bridge(insight)
        wrongs = ['Acaso sem propósito', 'Homem acima de Deus']
    elif diff == 'caminhada':
        correct = short_bridge(f'{insight} e a resposta humana')
        wrongs = ['Nenhuma resposta de fé', 'Deus irrelevante na trama']
    else:
        correct = short_bridge(insight)
        wrongs = ['Detalhe sem aplicação', 'Deus fora do centro']
    question = f'O que {hook} comunica que se liga a este contexto?'
    options, correct_id, wrong = rotate_options(
        [correct] + wrongs,
        correct,
        f"{mission.get('slug')}-{diff}-connect",
        {
            'b': 'Essa opção quebra a conexão da passagem com a missão.',
            'c': 'O texto aponta para uma leitura mais profunda e mais fiel.',
        },
    )
    return {
        **base_fields(mission, diff),
        'type': 'connect',
        'question': question,
        'prompt': question,
        'cue': question,
        'feedbackCorrect': 'Certo: o texto se liga ao sentido central da missão.',
        'feedbackWrong': wrong,
        'passageText': passage_a,
        'passageA': {'ref': hook, 'text': passage_a},
        'passageB': {'ref': 'Contexto', 'text': clip(insight, 120)},
        'options': options,
        'correctOptionId': correct_id,
        'correctAnswer': correct_id,
    }


def build_mission_questions(trail, mission):
    section = normalize_section_slug(trail['slug'], mission.get('slug'))
    questions = []
    for diff in DIFFICULTIES:
        used_stems = set()
        tap_q = make_gap_question(mission, diff, 'tap')
        avoid = tap_q.pop('_blank', None)
        builders = {
            'true_false': lambda: make_true_false_question(mission, diff),
            'tap': lambda: tap_q,
            'choice': lambda: make_choice_question(mission, diff),
            'order': lambda: make_order_question(mission, diff),
            'complete': lambda: make_gap_question(mission, diff, 'complete', avoid),
            'connect': lambda: make_connect_question(mission, diff),
        }
        for kind in TYPE_ORDER:
            q = builders[kind]()
            q.pop('_blank', None)
            q['trail'] = trail['slug']
            q['section'] = section
            q['id'] = f"{trail['slug']}-{SHORT[diff]}-{section}-{(TYPE_ORDER.index(kind) + 1):02d}"
            stem = (q.get('question') or '').lower().strip()
            if stem in used_stems:
                q['question'] = f"{q['question']} ({kind})"
                q['prompt'] = q['question']
                q['cue'] = q['question']
            used_stems.add((q.get('question') or '').lower().strip())
            q['feedbackWrong'] = dict(sorted((q.get('feedbackWrong') or {}).items()))
            questions.append(q)
    return questions


def load_trails():
    return json.loads(SOURCE.read_text(encoding='utf-8'))


def main():
    trails = load_trails()
    relevant = []
    for trail in trails:
        slug = trail.get('slug')
        if slug == 'teste' or trail.get('comingSoon') or trail.get('isActive') is False:
            continue
        if trail.get('realm') in {'antigo-testamento', 'novo-testamento', 'vida-crista', 'teologia'}:
            relevant.append(trail)

    OUT_DIR.mkdir(exist_ok=True)
    keep_names = {'section_slug_map.json'}
    map_data = {}
    report_lines = ['# Relatório de geração V2\n\n## Resumo\n']
    total_questions = 0

    for trail in relevant:
        trail_slug = trail['slug']
        trail_questions = []
        for module in trail.get('modules') or []:
            for mission in module.get('missions') or []:
                if not mission.get('slug'):
                    continue
                map_data[mission['slug']] = normalize_section_slug(trail_slug, mission['slug'])
                trail_questions.extend(build_mission_questions(trail, mission))
        out_name = f'{trail_slug}.json'
        keep_names.add(out_name)
        (OUT_DIR / out_name).write_text(json.dumps(trail_questions, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
        total_questions += len(trail_questions)
        report_lines.append(f'- {trail_slug}: {len(trail_questions)} perguntas')

    for path in OUT_DIR.glob('*.json'):
        if path.name not in keep_names:
            path.unlink()

    SECTION_MAP_PATH.write_text(json.dumps(map_data, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    report_lines.append(f'\nTotal de trilhas: {len(relevant)}')
    report_lines.append(f'Total de perguntas geradas: {total_questions}')
    report_lines.append('\n## Observações\n')
    report_lines.append('- Trilhas ativas (não `comingSoon`) de AT, NT, vida cristã e teologia; JSON stale removido.')
    report_lines.append('- V/F usa afirmação do versículo (semente/profundezas verdadeiras; caminhada falsa e verificável).')
    report_lines.append('- Tap e complete abrem palavras distintas do mesmo passageText; opções só do versículo.')
    report_lines.append('- Order parte o próprio texto; connect nomeia a ponte a partir do insight da missão.')
    REPORT_PATH.write_text('\n'.join(report_lines) + '\n', encoding='utf-8')
    print(f'Generated {len(relevant)} trails and {total_questions} questions.')


if __name__ == '__main__':
    main()
