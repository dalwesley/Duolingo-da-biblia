#!/usr/bin/env python3
"""Gera as capturas da App Store a partir de prints crus.

iPhone 6,5" (1284×2778): raw/      -> out/
iPad 13"   (2064×2752): raw-ipad/ -> out-ipad/  (com --ipad)

Uso:
  1. Coloque os prints crus em store/ios/raw/ com os nomes de SLIDES abaixo
     (qualquer tamanho de iPhone serve; PNG ou JPG).
  2. python3 store/ios/make_screenshots.py
     Prints de Android: corte as barras do sistema, que a Apple não aceita.
     Redmi Note 8 (1080×2340): --crop-top 80 --crop-bottom 130
     Galaxy Tab A7 (1200×2000): --ipad --crop-top 44 --crop-bottom 70
  3. Envie store/ios/out/*.png no App Store Connect, na ordem 01..10 (extra-* são alternativas).

Print faltando em raw/? O slide é pulado (ou use --demo para usar os
frames do site como placeholder, só para ver o layout).
"""
import argparse
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent.parent
FONTS = REPO / "trilha_app" / "assets" / "fonts"
SITE_IMG = REPO / "site" / "img"

W, H = 1284, 2778
K = 1.0  # escala de texto e margens (iPad usa 1.3)

# Cores do app (trilha_app/lib/theme/app_colors.dart)
BG_TOP = (11, 26, 46)
BG_BOTTOM = (4, 9, 16)
GLOW = (74, 158, 255)
ACCENT = (247, 187, 1)
TEXT = (240, 244, 250)
TEXT_SOFT = (168, 186, 210)
FRAME = (38, 58, 88)

# *palavra* = destaque em amarelo
# extra-*: alternativas; a loja aceita no máximo 10 por tamanho de tela.
SLIDES = [
    {
        "file": "01-introducao",
        "demo": "gesto-07-bonus.webp",
        "title": "Um hábito que *cabe no dia*",
        "sub": "Escolha seu ritmo. Poucos minutos, todo dia.",
    },
    {
        "file": "02-hoje",
        "demo": "gesto-03-escolha.webp",
        "title": "Sua missão *de hoje*",
        "sub": "A próxima cena já está pronta, com sequência e meta.",
    },
    {
        "file": "03-verdadeiro-falso",
        "demo": "gesto-01-verdadeiro-falso.webp",
        "title": "*Verdadeiro* ou falso",
        "sub": "O que o texto afirma, sem achismo.",
    },
    {
        "file": "04-toque",
        "demo": "gesto-02-toque.webp",
        "title": "*Toque* a palavra que falta",
        "sub": "Tirada do próprio versículo.",
    },
    {
        "file": "05-escolha",
        "demo": "gesto-03-escolha.webp",
        "title": "Só uma é *fiel ao texto*",
        "sub": "Escolha a resposta que o versículo sustenta.",
    },
    {
        "file": "06-ordem",
        "demo": "gesto-04-ordem.webp",
        "title": "Os fatos *em ordem*",
        "sub": "Na sequência em que a Bíblia conta.",
    },
    {
        "file": "07-complete",
        "demo": "gesto-05-complete.webp",
        "title": "*Complete* o versículo",
        "sub": "Uma lacuna, e o texto fica na memória.",
    },
    {
        "file": "08-conecte",
        "demo": "gesto-06-conecte.webp",
        "title": "*Conecte* os textos",
        "sub": "A ponte entre o versículo e o sentido.",
    },
    {
        "file": "09-profundidades",
        "demo": "gesto-04-ordem.webp",
        "title": "O mesmo texto, *mais fundo*",
        "sub": "Observação, Compreensão e Interpretação.",
    },
    {
        "file": "10-strong",
        "demo": "gesto-06-conecte.webp",
        "title": "O hebraico e o grego *por baixo*",
        "sub": "Toque a palavra e veja o original, com Strong.",
    },
    {
        "file": "extra-motivo",
        "demo": "gesto-07-bonus.webp",
        "title": "O que te *traz aqui?*",
        "sub": "Seu motivo abre o caminho.",
    },
    {
        "file": "extra-amanha",
        "demo": "gesto-07-bonus.webp",
        "title": "Firme o *compromisso*",
        "sub": "Sequência de 7, 14 ou 30 dias e lembrete na hora certa.",
    },
    {
        "file": "extra-trilhas",
        "demo": "gesto-05-complete.webp",
        "title": "A Bíblia, *cena a cena*",
        "sub": "Trilha por trilha, do Gênesis em diante.",
    },
    {
        "file": "extra-juntos",
        "demo": "gesto-01-verdadeiro-falso.webp",
        "title": "Estude *junto*",
        "sub": "Companhia, Caravana e Grupos com a sua igreja.",
    },
    {
        "file": "extra-leitura",
        "demo": "gesto-07-bonus.webp",
        "title": "A Bíblia inteira, *sem internet*",
        "sub": "Almeida e Tradução Brasileira, com leitura em voz alta.",
    },
]


def font(name, size):
    return ImageFont.truetype(str(FONTS / name), size)


def background():
    bg = Image.new("RGB", (W, H))
    px = bg.load()
    for y in range(H):
        t = y / (H - 1)
        c = tuple(round(BG_TOP[i] + (BG_BOTTOM[i] - BG_TOP[i]) * t) for i in range(3))
        for x in range(W):
            px[x, y] = c
    glow = Image.new("L", (W, H), 0)
    ImageDraw.Draw(glow).ellipse((-200, H * 0.23, W + 200, H * 0.68), fill=70)
    glow = glow.filter(ImageFilter.GaussianBlur(220 * K))
    bg.paste(Image.new("RGB", (W, H), GLOW), (0, 0), glow)
    return bg


def tokens(text):
    """'a *b c* d' -> [('a', False), ('b c', True), ('d', False)] — destaque não quebra"""
    out, hot = [], False
    for part in text.split("*"):
        if hot and part.strip():
            out.append((part.strip(), True))
        else:
            out += [(w, False) for w in part.split()]
        hot = not hot
    return out


def wrap(words, fnt, max_w, draw):
    lines, cur = [], []
    for w in words:
        test = " ".join(x for x, _ in cur + [w])
        if cur and draw.textlength(test, font=fnt) > max_w:
            lines.append(cur)
            cur = [w]
        else:
            cur.append(w)
    if cur:
        lines.append(cur)
    return lines


def draw_centered_line(draw, line, fnt, y, hot_color, cold_color):
    space = draw.textlength(" ", font=fnt)
    total = sum(draw.textlength(w, font=fnt) for w, _ in line) + space * (len(line) - 1)
    x = (W - total) / 2
    for w, hot in line:
        draw.text((x, y), w, font=fnt, fill=hot_color if hot else cold_color)
        x += draw.textlength(w, font=fnt) + space


def render(slide, shot):
    img = background()
    draw = ImageDraw.Draw(img)

    def k(v):
        return round(v * K)

    title_f = font("Exo2-ExtraBold.ttf", k(112))
    sub_f = font("Nunito-SemiBold.ttf", k(50))
    y = k(190)
    for line in wrap(tokens(slide["title"]), title_f, W - k(160), draw):
        draw_centered_line(draw, line, title_f, y, ACCENT, TEXT)
        y += k(132)
    y += k(26)
    for line in wrap([(w, False) for w in slide["sub"].split()], sub_f, W - k(200), draw):
        draw_centered_line(draw, line, sub_f, y, TEXT_SOFT, TEXT_SOFT)
        y += k(66)
    y += k(70)

    # Print: cabe inteiro entre o texto e a margem de baixo
    avail_h = H - y - k(130)
    scale = min(avail_h / shot.height, (W - k(274)) / shot.width)
    sw, sh = round(shot.width * scale), round(shot.height * scale)
    shot = shot.convert("RGB").resize((sw, sh), Image.LANCZOS)
    x = (W - sw) // 2
    radius = round(sw * 0.06)
    border = k(8)

    shadow = Image.new("L", (W, H), 0)
    ImageDraw.Draw(shadow).rounded_rectangle(
        (x - border, y - border + k(30), x + sw + border, y + sh + border + k(30)),
        radius=radius + border, fill=170,
    )
    img.paste((0, 0, 0), (0, 0), shadow.filter(ImageFilter.GaussianBlur(k(45))))
    ImageDraw.Draw(img).rounded_rectangle(
        (x - border, y - border, x + sw + border, y + sh + border),
        radius=radius + border, fill=FRAME,
    )
    mask = Image.new("L", (sw, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, sw - 1, sh - 1), radius=radius, fill=255)
    img.paste(shot, (x, y), mask)
    return img


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--demo", action="store_true", help="usa frames do site como placeholder")
    ap.add_argument("--crop-top", type=int, default=0, help="px a cortar em cima (barra de status)")
    ap.add_argument("--crop-bottom", type=int, default=0, help="px a cortar embaixo (barra de navegação)")
    ap.add_argument("--ipad", action="store_true", help='iPad 13" (2064×2752): raw-ipad/ -> out-ipad/')
    args = ap.parse_args()

    global W, H, K
    if args.ipad:
        W, H, K = 2064, 2752, 1.3
        raw, out = ROOT / "raw-ipad", ROOT / "out-ipad"
    else:
        raw, out = ROOT / "raw", ROOT / "out"
    out.mkdir(exist_ok=True)
    made = 0
    for s in SLIDES:
        src = next((p for ext in ("png", "jpg", "jpeg", "PNG") if (p := raw / f"{s['file']}.{ext}").exists()), None)
        if src is None and args.demo:
            src = SITE_IMG / s["demo"]
        if src is None:
            print(f"pulado: raw/{s['file']}.png não existe")
            continue
        shot = Image.open(src)
        if not str(src).startswith(str(SITE_IMG)):
            shot = shot.crop((0, args.crop_top, shot.width, shot.height - args.crop_bottom))
        render(s, shot).save(out / f"{s['file']}.png", optimize=True)
        print(f"ok: {out.name}/{s['file']}.png  ({src.name})")
        made += 1
    if not made:
        sys.exit("nenhum print em raw/ — veja o topo do arquivo")


if __name__ == "__main__":
    main()
