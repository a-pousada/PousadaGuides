#!/usr/bin/env python3
"""
site/optimize_images.py -- gera as imagens leves (WebP/JPG) usadas pelo site.

Rode sempre que adicionar um guia novo ou trocar capas/mascotes/banners:

    python3 site/optimize_images.py

Requer Pillow (pip install pillow). O resultado fica versionado em
site/src/img/ para que o build do site (site/build.py) rode só com a
biblioteca padrão do Python.
"""
import json
import pathlib

from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parent.parent
SITE = ROOT / "site"
OUT = SITE / "src" / "img"

TEAL = (1, 66, 74, 255)  # pgTeal


def fit(img, max_w=None, max_h=None):
    w, h = img.size
    s = 1.0
    if max_w:
        s = min(s, max_w / w)
    if max_h:
        s = min(s, max_h / h)
    if s < 1.0:
        img = img.resize((round(w * s), round(h * s)), Image.Resampling.LANCZOS)
    return img


def save_webp(img, path, q=82):
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, "WEBP", quality=q, method=6)
    print(f"  {path.relative_to(ROOT)}  {img.size[0]}x{img.size[1]}  {path.stat().st_size // 1024} KB")


def save_jpg(img, path, q=86):
    path.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(path, "JPEG", quality=q, optimize=True, progressive=True)
    print(f"  {path.relative_to(ROOT)}  {img.size[0]}x{img.size[1]}  {path.stat().st_size // 1024} KB")


def main():
    cfg = json.loads((SITE / "guides.json").read_text(encoding="utf-8"))

    print("Guias:")
    for g in cfg["guides"]:
        gid, folder = g["id"], ROOT / g["folder"]
        cover = ROOT / "docs" / "previews" / f"{gid}-capa.png"
        save_webp(fit(Image.open(cover).convert("RGB"), max_w=640), OUT / "covers" / f"{gid}.webp")
        avatar = folder / "assets" / f"{gid}-avatar.png"
        if avatar.exists():
            save_webp(fit(Image.open(avatar).convert("RGBA"), max_w=192), OUT / "mascots" / f"{gid}-avatar.webp", q=88)
        mascot = folder / "assets" / f"{gid}-capa.png"
        if mascot.exists():
            save_webp(fit(Image.open(mascot).convert("RGBA"), max_h=900), OUT / "mascots" / f"{gid}.webp", q=84)
        banner = ROOT / "docs" / f"banner-{gid}.png"
        if banner.exists():
            save_jpg(fit(Image.open(banner), max_w=1200), OUT / "og" / f"{gid}.jpg")

    print("Comuns:")
    save_webp(fit(Image.open(ROOT / "assets" / "teacher.png").convert("RGBA"), max_h=960), OUT / "teacher.webp", q=84)
    save_webp(fit(Image.open(ROOT / "assets" / "pousadinha.png").convert("RGBA"), max_h=520), OUT / "pousadinha.webp", q=84)
    save_webp(fit(Image.open(ROOT / "assets" / "pousadinha-avatar.png").convert("RGBA"), max_w=192), OUT / "pousadinha-avatar.webp", q=88)
    save_webp(fit(Image.open(ROOT / "assets" / "logo-symbol-cream.png").convert("RGBA"), max_w=240), OUT / "logo-symbol-cream.webp", q=90)
    save_webp(fit(Image.open(ROOT / "assets" / "goat.png").convert("RGBA"), max_w=96), OUT / "goat.webp", q=90)
    save_jpg(fit(Image.open(ROOT / "docs" / "social-preview.png"), max_w=1200), OUT / "og" / "home.jpg")

    # Favicons: símbolo creme sobre quadrado arredondado teal
    sym = Image.open(ROOT / "assets" / "logo-symbol-cream.png").convert("RGBA")
    for size, name in ((512, "icon-512.png"), (180, "apple-touch-icon.png"), (32, "favicon-32.png")):
        ss = size * 4
        canvas = Image.new("RGBA", (ss, ss), (0, 0, 0, 0))
        from PIL import ImageDraw
        ImageDraw.Draw(canvas).rounded_rectangle((0, 0, ss - 1, ss - 1), radius=int(ss * 0.22), fill=TEAL)
        s = fit(sym, max_w=int(ss * 0.78), max_h=int(ss * 0.78))
        canvas.alpha_composite(s, ((ss - s.size[0]) // 2, (ss - s.size[1]) // 2))
        canvas = canvas.resize((size, size), Image.Resampling.LANCZOS)
        p = OUT / name
        canvas.save(p, "PNG", optimize=True)
        print(f"  {p.relative_to(ROOT)}  {size}x{size}")


if __name__ == "__main__":
    main()
