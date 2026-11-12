#!/usr/bin/env python3
"""
Advento 2026 — gera os posts das 26 cenas e as legendas.

  python3 marketing/tools/advento_cards.py            # tudo
  python3 marketing/tools/advento_cards.py --day 1    # só um dia (teste)

Lê marketing/advento-2026/dias.json (curadoria) e puxa o texto do
versículo da Almeida do app (trilha_app/assets/data/bible_jfaal.json),
para a citação sair sempre igual à Bíblia do STWAY.

Saída em marketing/out/advento-2026/ (fora do git):
  story/dia-NN.png  1080x1920  (stories, status do WhatsApp, Reels capa)
  feed/dia-NN.png   1080x1350  (feed 4:5)
  anuncio-story.png / anuncio-feed.png  (convite antes do dia 1)
  legendas.md  (legenda + hashtags de cada dia)
  whatsapp-diario.md  (mensagem curta do dia para líderes encaminharem)
"""
import argparse
import json
import re
from datetime import date, timedelta
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]
APP = ROOT / "trilha_app" / "assets"
FONTS = APP / "fonts"
ART = APP / "art"
DATA = ROOT / "marketing" / "advento-2026" / "dias.json"
OUT = ROOT / "marketing" / "out" / "advento-2026"

NIGHT = (8, 16, 24)
NIGHT_MID = (16, 32, 56)
CREAM = (244, 235, 221)
INK = (28, 22, 14)
ACCENT = (244, 168, 12)
ACCENT_BRIGHT = (246, 194, 74)
MUTED = (186, 196, 214)

MONTHS = ["janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho",
          "agosto", "setembro", "outubro", "novembro", "dezembro"]
WEEKDAYS = ["segunda", "terça", "quarta", "quinta", "sexta", "sábado", "domingo"]


def font(name, size):
    return ImageFont.truetype(str(FONTS / f"{name}.ttf"), size)


# ---------------------------------------------------------------- Bíblia

BOOKS = {
    "Gn": "Gênesis", "Êx": "Êxodo", "Sl": "Salmos", "Mt": "Mateus", "Mc": "Marcos",
    "Lc": "Lucas", "Jo": "João", "Fp": "Filipenses",
}


def load_bible():
    data = json.loads((APP / "data" / "bible_jfaal.json").read_text(encoding="utf-8"))
    return {b["abbrev"]: b for b in data}


def verse_text(bible, ref):
    m = re.fullmatch(r"(\S+) (\d+):(\d+)(?:-(\d+))?", ref)
    if not m:
        raise ValueError(f"ref inválida: {ref}")
    abbrev, ch, v1, v2 = m.group(1), int(m.group(2)), int(m.group(3)), int(m.group(4) or m.group(3))
    verses = bible[abbrev]["chapters"][ch - 1][v1 - 1:v2]
    if not verses:
        raise ValueError(f"versículo não encontrado: {ref}")
    text = " ".join(v.strip() for v in verses)
    # Fala dentro do versículo: aspas retas viram ‘ ’ (as de fora são “ ”).
    parts = text.split('"')
    return "".join(p + ("‘" if i % 2 == 0 else "’") for i, p in enumerate(parts[:-1])) + parts[-1]


def ref_label(ref):
    abbrev, rest = ref.split(" ", 1)
    name = BOOKS.get(abbrev, abbrev)
    if abbrev == "Sl":
        name = "Salmo"
    return f"{name} {rest.replace('-', '–')}"


# ---------------------------------------------------------------- desenho

def wrap(draw, text, fnt, width):
    words, lines, cur = text.split(), [], ""
    for w in words:
        trial = f"{cur} {w}".strip()
        if draw.textlength(trial, font=fnt) <= width or not cur:
            cur = trial
        else:
            lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def fit_lines(draw, text, name, size, width, max_lines, min_size):
    """Diminui a fonte até o texto caber em max_lines."""
    while True:
        fnt = font(name, size)
        lines = wrap(draw, text, fnt, width)
        if len(lines) <= max_lines or size <= min_size:
            return fnt, lines
        size -= 2


def text_block(draw, lines, fnt, cx, y, fill, spacing=1.18):
    lh = int(fnt.size * spacing)
    for ln in lines:
        w = draw.textlength(ln, font=fnt)
        draw.text((cx - w / 2, y), ln, font=fnt, fill=fill)
        y += lh
    return y


def block_height(lines, fnt, spacing=1.18):
    return int(fnt.size * spacing) * len(lines)


def cover(img, size):
    w, h = size
    s = max(w / img.width, h / img.height)
    r = img.resize((int(img.width * s) + 1, int(img.height * s) + 1), Image.LANCZOS)
    x, y = (r.width - w) // 2, (r.height - h) // 2
    return r.crop((x, y, x + w, y + h))


def background(art, size):
    """Pintura ampliada, desfocada e escurecida + degradê noturno."""
    bg = cover(art.convert("RGB"), size).filter(ImageFilter.GaussianBlur(38))
    night = Image.new("RGB", size, NIGHT)
    bg = Image.blend(bg, night, 0.62)
    grad = Image.new("L", (1, size[1]))
    for y in range(size[1]):
        t = y / size[1]
        grad.putpixel((0, y), int(255 * (0.15 + 0.7 * abs(t - 0.45) ** 1.4)))
    grad = grad.resize(size)
    return Image.composite(Image.new("RGB", size, NIGHT), bg, grad)


def postmark(size, day, when):
    """Carimbo do postal: dois círculos, dia e data, ondas ao lado."""
    s = size
    im = Image.new("RGBA", (int(s * 1.9), s), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    col = (*ACCENT, 235)
    d.ellipse((4, 4, s - 4, s - 4), outline=col, width=5)
    d.ellipse((18, 18, s - 18, s - 18), outline=col, width=2)
    f1, f2 = font("Exo2-ExtraBold", int(s * 0.17)), font("Nunito-ExtraBold", int(s * 0.12))
    for txt, f, yy in (("ADVENTO", f2, 0.27), (f"DIA {day}", f1, 0.42), (when.upper(), f2, 0.62)):
        w = d.textlength(txt, font=f)
        d.text(((s - w) / 2, s * yy), txt, font=f, fill=col)
    for i in range(4):
        y = s * (0.3 + i * 0.13)
        pts = [(s + 6 + x, y + 6 * __import__("math").sin(x / 14)) for x in range(0, int(s * 0.85), 3)]
        d.line(pts, fill=col, width=3)
    return im.rotate(-12, resample=Image.BICUBIC, expand=True)


def postal(art, max_w, max_h, pad=22):
    a = art.convert("RGB")
    s = min(max_w / a.width, max_h / a.height)
    a = a.resize((int(a.width * s), int(a.height * s)), Image.LANCZOS)
    a = a.filter(ImageFilter.UnsharpMask(radius=2, percent=60, threshold=2))
    card = Image.new("RGB", (a.width + pad * 2, a.height + pad * 2), CREAM)
    card.paste(a, (pad, pad))
    return card


def paste_shadowed(canvas, card, xy, angle=-2):
    rot = card.convert("RGBA").rotate(angle, resample=Image.BICUBIC, expand=True)
    shadow = Image.new("RGBA", rot.size, (0, 0, 0, 0))
    shadow.paste((0, 0, 0, 150), mask=rot.split()[3])
    shadow = shadow.filter(ImageFilter.GaussianBlur(18))
    x, y = xy
    canvas.paste(shadow, (x + 10, y + 18), shadow)
    canvas.paste(rot, (x, y), rot)
    return rot.size


def anan(height):
    im = Image.open(APP / "mascot" / "cloud_body_feliz.png").convert("RGBA")
    return im.resize((int(im.width * height / im.height), height), Image.LANCZOS)


def footer(canvas, draw, y, w, line2):
    a = anan(92)
    f1, f2 = font("Exo2-ExtraBold", 40), font("Nunito-SemiBold", 28)
    brand = "STWAY"
    tw = max(draw.textlength(brand, font=f1), draw.textlength(line2, font=f2))
    total = a.width + 22 + tw
    x = (w - total) / 2
    canvas.paste(a, (int(x), int(y)), a)
    draw.text((x + a.width + 22, y + 6), brand, font=f1, fill=CREAM)
    draw.text((x + a.width + 22, y + 52), line2, font=f2, fill=MUTED)


# ---------------------------------------------------------------- cartões

def day_card(item, bible, start, fmt):
    W, H = (1080, 1920) if fmt == "story" else (1080, 1350)
    story = fmt == "story"
    art = Image.open(ART / f"scene_{item['slug']}.jpg")
    canvas = background(art, (W, H)).convert("RGBA")
    # O conteúdo nasce numa camada à parte e depois é centralizado entre
    # o topo e o rodapé (a altura muda com o tamanho do versículo).
    layer = Image.new("RGBA", (W, H * 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    cx = W / 2
    when_d = start + timedelta(days=item["day"] - 1)
    when = f"{when_d.day} {MONTHS[when_d.month - 1][:3]}"

    # topo
    y = 60
    kicker = f"ADVENTO · DIA {item['day']} DE 26"
    y = text_block(draw, [kicker], font("Exo2-ExtraBold", 34 if story else 30), cx, y, ACCENT_BRIGHT)
    sub = f"{WEEKDAYS[when_d.weekday()]}, {when_d.day} de {MONTHS[when_d.month - 1]}"
    y = text_block(draw, [sub], font("Nunito-SemiBold", 30 if story else 26), cx, y + 4, MUTED)

    # postal
    card = postal(art, 820 if story else 700, 560 if story else 380)
    y += 40 if story else 26
    pw, ph = paste_shadowed(layer, card, (int(cx - card.width / 2), int(y)))
    pm = postmark(170 if story else 140, item["day"], when)
    layer.paste(pm, (int(cx + card.width / 2 - pm.width * 0.62), int(y - pm.height * 0.22)), pm)
    y += ph + (56 if story else 32)

    # título, versículo, Hoje
    title_f = font("CormorantGaramond-BoldItalic", 92 if story else 74)
    y = text_block(draw, [item["title"]], title_f, cx, y, CREAM, 1.05)
    y += 18 if story else 10

    verse = f"“{verse_text(bible, item['ref'])}”"
    vf, vlines = fit_lines(draw, verse, "CormorantGaramond-MediumItalic",
                           54 if story else 44, W - 180, 6 if story else 4, 34)
    y = text_block(draw, vlines, vf, cx, y, CREAM, 1.2)
    y = text_block(draw, [ref_label(item["ref"])], font("Nunito-Bold", 32 if story else 28), cx, y + 10, ACCENT_BRIGHT)

    # Hoje
    y += 40 if story else 22
    hf = font("Nunito-ExtraBold", 44 if story else 38)
    hoje = f"Hoje: {item['insight']}"
    hw = draw.textlength(hoje, font=hf)
    if hw > W - 160:
        hf = font("Nunito-ExtraBold", 34)
        hw = draw.textlength(hoje, font=hf)
    box = (cx - hw / 2 - 34, y, cx + hw / 2 + 34, y + hf.size + 36)
    draw.rounded_rectangle(box, radius=(hf.size + 36) // 2, fill=ACCENT)
    draw.text((cx - hw / 2, y + 14), hoje, font=hf, fill=(20, 14, 0))
    y += hf.size + 36

    # pergunta do dia (só no story, onde sobra espaço)
    if story:
        qf, qlines = fit_lines(draw, item["question"], "Nunito-SemiBold", 38, W - 220, 3, 30)
        y = text_block(draw, qlines, qf, cx, y + 44, MUTED, 1.3)

    # centraliza entre topo e rodapé
    foot_h = 190 if story else 140
    avail = H - foot_h - 40
    content = layer.crop((0, 0, W, int(y) + 20))
    top = max(20, int((avail - content.height) / 2))
    canvas.paste(content, (0, top), content)

    draw = ImageDraw.Draw(canvas)
    footer(canvas, draw, H - foot_h, W, "Uma cena por dia até o Natal · grátis")
    return canvas.convert("RGB")


def announce_card(days, bible, fmt):
    W, H = (1080, 1920) if fmt == "story" else (1080, 1350)
    story = fmt == "story"
    arts = [Image.open(ART / f"scene_{d['slug']}.jpg") for d in days]
    canvas = background(arts[0], (W, H)).convert("RGBA")
    layer = Image.new("RGBA", (W, H * 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    cx = W / 2

    y = 40
    y = text_block(draw, ["ADVENTO NO STWAY"], font("Exo2-ExtraBold", 38 if story else 32), cx, y, ACCENT_BRIGHT)
    y += 20
    head_f = font("CormorantGaramond-BoldItalic", 104 if story else 84)
    y = text_block(draw, ["26 cenas", "até o Natal"], head_f, cx, y, CREAM, 1.0)
    y += 30 if story else 16

    # mosaico de postais (3 colunas)
    pick = [days[i] for i in (0, 5, 7, 15, 16, 21)]
    cols, gap = 3, 26
    cell_w = (W - 140 - gap * (cols - 1)) // cols
    cell_h = int(cell_w * (0.78 if story else 0.62))
    rows = 2
    angles = [-4, 2, -2, 3, -3, 1]
    for i, d in enumerate(pick):
        r, c = divmod(i, cols)
        card = postal(Image.open(ART / f"scene_{d['slug']}.jpg"), cell_w - 24, cell_h - 24, pad=10)
        x = 70 + c * (cell_w + gap) + (cell_w - card.width) // 2
        yy = y + r * (cell_h + gap) + (cell_h - card.height) // 2
        paste_shadowed(layer, card, (int(x), int(yy)), angles[i])
    y += rows * (cell_h + gap) + (50 if story else 24)

    body_f = font("Nunito-SemiBold", 40 if story else 34)
    body = "De 29 de novembro a 24 de dezembro: uma cena de 5 minutos por dia, da Criação à promessa cumprida em Jesus."
    lines = wrap(draw, body, body_f, W - 200)
    y = text_block(draw, lines, body_f, cx, y, CREAM, 1.3)
    y += 30 if story else 18
    cta_f = font("Nunito-ExtraBold", 42 if story else 36)
    cta = "Grátis · baixe o STWAY"
    cw = draw.textlength(cta, font=cta_f)
    box = (cx - cw / 2 - 40, y, cx + cw / 2 + 40, y + cta_f.size + 40)
    draw.rounded_rectangle(box, radius=(cta_f.size + 40) // 2, fill=ACCENT)
    draw.text((cx - cw / 2, y + 16), cta, font=cta_f, fill=(20, 14, 0))
    y += cta_f.size + 60

    foot_h = 190 if story else 130
    content = layer.crop((0, 0, W, int(y)))
    canvas.paste(content, (0, max(20, int((H - foot_h - 30 - content.height) / 2))), content)
    draw = ImageDraw.Draw(canvas)
    footer(canvas, draw, H - foot_h, W, "Estudo bíblico em cenas de 5 minutos")
    return canvas.convert("RGB")


# ---------------------------------------------------------------- legendas

HASHTAGS = "#advento #natal #biblia #estudobiblico #devocional #palavradedeus #jesus #fe"


def caption(item, bible, start):
    d = start + timedelta(days=item["day"] - 1)
    verse = verse_text(bible, item["ref"])
    return (
        f"Dia {item['day']} do Advento · {item['title']}\n\n"
        f"“{verse}” ({ref_label(item['ref'])})\n\n"
        f"{item['reflection']}\n\n"
        f"{item['question']}\n\n"
        "Uma cena de 5 minutos por dia até o Natal, grátis no STWAY. Link na bio.\n\n"
        f"{HASHTAGS}"
    ), d


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--day", type=int, default=0)
    args = ap.parse_args()

    spec = json.loads(DATA.read_text(encoding="utf-8"))
    start = date.fromisoformat(spec["start"])
    bible = load_bible()
    days = spec["days"]
    todo = [d for d in days if not args.day or d["day"] == args.day]

    for fmt in ("story", "feed"):
        (OUT / fmt).mkdir(parents=True, exist_ok=True)
        for item in todo:
            day_card(item, bible, start, fmt).save(OUT / fmt / f"dia-{item['day']:02d}.png", optimize=True)
        if not args.day:
            announce_card(days, bible, fmt).save(OUT / f"anuncio-{fmt}.png", optimize=True)

    if not args.day:
        parts = ["# Advento 2026 · legendas\n",
                 "Gerado por `marketing/tools/advento_cards.py`. Versículos: Almeida (JFAAL), a mesma Bíblia do app.\n"]
        for item in days:
            text, d = caption(item, bible, start)
            parts.append(f"\n## Dia {item['day']} · {d.day:02d}/{d.month:02d} · {item['title']}\n\n"
                         f"Imagens: `story/dia-{item['day']:02d}.png`, `feed/dia-{item['day']:02d}.png`\n\n"
                         f"```text\n{text}\n```\n")
        (OUT / "legendas.md").write_text("".join(parts), encoding="utf-8")

        # Mensagem curta do dia para líder encaminhar no grupo (com a imagem do story).
        wa = ["# Advento 2026 · mensagem do dia para o WhatsApp\n",
              "Mande ao líder às 6h a imagem `story/dia-NN.png` + o texto. Ele só encaminha no grupo.\n"]
        for item in days:
            d = start + timedelta(days=item["day"] - 1)
            verse = verse_text(bible, item["ref"])
            wa.append(f"\n## Dia {item['day']} · {WEEKDAYS[d.weekday()]}, {d.day:02d}/{d.month:02d}\n\n"
                      f"```text\n🎄 Advento · dia {item['day']} de 26: *{item['title']}*\n\n"
                      f"“{verse}” ({ref_label(item['ref'])})\n\n"
                      f"{item['question']}\n\n"
                      f"A cena de hoje (5 min): stway.com.br/advento\n```\n")
        (OUT / "whatsapp-diario.md").write_text("".join(wa), encoding="utf-8")

    print(f"ok: {len(todo)} dia(s) em {OUT}")


if __name__ == "__main__":
    main()
