#!/usr/bin/env python3
"""Stamp the real STWAY wordmark (Exo 2 + stroke chevron A, Flutter layout)."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

FONT = "/tmp/stway-fonts/Exo2-Black.ttf"
ASSETS = Path("/Users/dalwesleyduarte/.cursor/projects/Users-dalwesleyduarte-dev-new/assets")
DEST = Path("/Users/dalwesleyduarte/dev/stway-marketing/instagram/semana-3")
ACCENT = (247, 187, 1, 255)
WHITE = (255, 255, 255, 255)

POSTS = [
    "01-terca-setembro.png",
    "02-quarta-palco.png",
    "03-quinta-gestos.png",
    "03b-decida.png",
    "03c-toque.png",
    "03d-escolha.png",
    "03e-ordene.png",
    "03f-complete.png",
    "03g-conecte.png",
    "04-sexta-modos.png",
    "05-sabado-enquete.png",
    "06-domingo-teste.png",
    "07-frase-mae.png",
]


def exo(size: float) -> ImageFont.FreeTypeFont:
    font = ImageFont.truetype(FONT, size=int(round(size)))
    font.set_variation_by_axes([900])
    return font


def glyph_size(draw, font, ch):
    b = draw.textbbox((0, 0), ch, font=font, anchor="lt")
    return b[2] - b[0], b[3] - b[1]


def _spans(row, thresh=40):
    spans = []
    x, w = 0, len(row)
    while x < w:
        if row[x] > thresh:
            x0 = x
            while x < w and row[x] > thresh:
                x += 1
            spans.append((x0, x - 1))
        else:
            x += 1
    return spans


def exo2_chevron_a(font_size):
    """Exo 2 Black A with the crossbar removed — same letter as STWY, gold, no bar."""
    # Rasterize large so the inner cut is clean, then scale to the requested size.
    src = max(480, int(font_size * 2))
    font = exo(src)
    probe = ImageDraw.Draw(Image.new("RGBA", (8, 8)))
    b = probe.textbbox((0, 0), "A", font=font)
    pad = 8
    im = Image.new("RGBA", (b[2] - b[0] + pad * 2, b[3] - b[1] + pad * 2), (0, 0, 0, 0))
    ImageDraw.Draw(im).text((pad - b[0], pad - b[1]), "A", font=font, fill=ACCENT)
    w, h = im.size
    rows = []
    for y in range(h):
        rows.append(_spans([im.getpixel((x, y))[3] for x in range(w)]))
    two = [y for y, s in enumerate(rows) if len(s) >= 2]
    if not two:
        out = im.crop(im.getbbox())
    else:
        clusters = [[two[0]]]
        for y in two[1:]:
            if y <= clusters[-1][-1] + 2:
                clusters[-1].append(y)
            else:
                clusters.append([y])
        y_top = clusters[0][-1]
        inner_top = (rows[y_top][0][1], rows[y_top][1][0])
        if len(clusters) > 1:
            y_bot = clusters[-1][0]
            inner_bot = (rows[y_bot][0][1], rows[y_bot][1][0])
        else:
            y_bot, inner_bot = h - 1, inner_top
        px = im.load()
        n = max(1, y_bot - y_top)
        for y in range(y_top, y_bot + 1):
            t = (y - y_top) / float(n)
            x0 = int(round(inner_top[0] + (inner_bot[0] - inner_top[0]) * t))
            x1 = int(round(inner_top[1] + (inner_bot[1] - inner_top[1]) * t))
            if x1 <= x0:
                x1 = x0 + 1
            for x in range(x0, x1 + 1):
                if 0 <= x < w:
                    px[x, y] = (0, 0, 0, 0)
        out = im.crop(im.getbbox())
    if font_size != src:
        # match cap height of a glyph at font_size
        ref = exo(font_size)
        rb = probe.textbbox((0, 0), "A", font=ref)
        target_h = max(1, rb[3] - rb[1])
        tw = max(1, int(round(out.width * (target_h / out.height))))
        out = out.resize((tw, target_h), Image.Resampling.LANCZOS)
    return out


def render_wordmark(font_size=280, letter_spacing=None):
    """STWY in Exo 2 Black; A is the same glyph in gold, without the crossbar."""
    if letter_spacing is None:
        letter_spacing = font_size * (6 / 48)
    font = exo(font_size)
    probe = ImageDraw.Draw(Image.new("RGBA", (8, 8)))
    s_w, s_h = glyph_size(probe, font, "S")
    t_w, t_h = glyph_size(probe, font, "T")
    w_w, w_h = glyph_size(probe, font, "W")
    y_w, y_h = glyph_size(probe, font, "Y")
    letter_h = max(s_h, t_h, w_h, y_h)
    a_im = exo2_chevron_a(font_size)
    gap_w = letter_spacing * 0.55
    gap_a = letter_spacing * 0.28
    pad = int(font_size * 0.08)
    total_w = int(
        pad * 2 + s_w + letter_spacing + t_w + gap_w + w_w + gap_a + a_im.width + gap_a + y_w
    )
    total_h = int(pad * 2 + max(letter_h, a_im.height) + 4)
    img = Image.new("RGBA", (total_w, total_h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    x = float(pad)
    y_text = pad
    draw.text((x, y_text), "S", font=font, fill=WHITE, anchor="lt")
    x += s_w + letter_spacing
    draw.text((x, y_text), "T", font=font, fill=WHITE, anchor="lt")
    x += t_w + gap_w
    draw.text((x, y_text), "W", font=font, fill=WHITE, anchor="lt")
    x += w_w + gap_a
    ay = int(y_text + (letter_h - a_im.height) / 2)
    img.paste(a_im, (int(x), ay), a_im)
    x += a_im.width + gap_a
    draw.text((x, y_text), "Y", font=font, fill=WHITE, anchor="lt")
    return img.crop(img.getbbox())


def stamp(src: Path, dest: Path, wm: Image.Image) -> None:
    im = Image.open(src).convert("RGBA")
    w, h = im.size
    target_w = int(w * 0.32)
    scaled = wm.resize(
        (target_w, max(1, int(round(wm.height * (target_w / wm.width))))),
        Image.Resampling.LANCZOS,
    )
    left = int(w * 0.07)
    top = int(h * 0.055)
    im.paste(scaled, (left, top), scaled)
    dest.parent.mkdir(parents=True, exist_ok=True)
    im.convert("RGB").save(dest, "PNG", optimize=True)
    print(f"ok {dest.name}")


def main() -> None:
    wm = render_wordmark()
    preview = Path("/Users/dalwesleyduarte/dev/new/tmp_wordmark.png")
    bg = Image.new("RGB", (wm.width + 80, wm.height + 80), (4, 9, 16))
    bg.paste(wm, (40, 40), wm)
    bg.save(preview)
    for name in POSTS:
        stamp(ASSETS / name, DEST / name, wm)


if __name__ == "__main__":
    main()
