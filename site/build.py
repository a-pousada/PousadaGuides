#!/usr/bin/env python3
"""
site/build.py -- monta o site estático dos PousadaGuides (GitHub Pages).

    python3 site/build.py                 # usa os PDFs de dist/ e gera _site/
    python3 site/build.py --serve         # gera e abre um servidor local na porta 8000

O que ele faz:
  1. Lê site/guides.json e extrai capítulos, versão e data direto dos .tex
  2. Renderiza site/src/index.html (cards dos guias) e uma página de leitura
     por guia em _site/<id>/ (link curto e bonito: /PousadaGuides/bitcoin/#p=12)
  3. Copia os PDFs de dist/ para _site/pdf/ (mesma origem => leitura no navegador)
  4. Baixa e auto-hospeda o PDF.js e as fontes IBM Plex (zero CDN de terceiros)

Usa só a biblioteca padrão do Python 3.
"""
import argparse
import html
import io
import json
import pathlib
import re
import shutil
import sys
import tarfile
import urllib.request
import zlib
from datetime import date

ROOT = pathlib.Path(__file__).resolve().parent.parent
SITE = ROOT / "site"
SRC = SITE / "src"
CACHE = SITE / ".cache"

PDFJS_VERSION = "4.10.38"
FONTS = {
    # pacote fontsource -> pesos/estilos usados no CSS
    "ibm-plex-sans": ["400-normal", "400-italic", "500-normal", "600-normal", "700-normal"],
    "ibm-plex-sans-condensed": ["600-normal", "700-normal"],
    "ibm-plex-mono": ["400-normal", "500-normal", "600-normal"],
}
SUBSETS = ["latin", "latin-ext"]

ICONS = {
    "book": '<path d="M12 6.5C10.3 5 7.7 4.5 4 4.5v13c3.7 0 6.3.5 8 2 1.7-1.5 4.3-2 8-2v-13c-3.7 0-6.3.5-8 2Z"/><path d="M12 6.5v13"/>',
    "download": '<path d="M12 4v11"/><path d="m7 10 5 5 5-5"/><path d="M5 20h14"/>',
    "printer": '<path d="M7 9V4h10v5"/><rect x="4" y="9" width="16" height="7" rx="1.5"/><path d="M7 14h10v6H7z"/>',
    "share": '<circle cx="18" cy="5" r="2.5"/><circle cx="6" cy="12" r="2.5"/><circle cx="18" cy="19" r="2.5"/><path d="m8.2 10.8 7.6-4.4M8.2 13.2l7.6 4.4"/>',
    "arrow": '<path d="M5 12h14"/><path d="m13 6 6 6-6 6"/>',
    "github": '<path d="M9 19c-4.3 1.4-4.3-2.5-6-3m12 5v-3.5c0-1 .1-1.4-.5-2 2.8-.3 5.5-1.4 5.5-6a4.6 4.6 0 0 0-1.3-3.2 4.2 4.2 0 0 0-.1-3.2s-1.1-.3-3.5 1.3a12.3 12.3 0 0 0-6.2 0C6.5 2.8 5.4 3.1 5.4 3.1a4.2 4.2 0 0 0-.1 3.2A4.6 4.6 0 0 0 4 9.5c0 4.6 2.7 5.7 5.5 6-.6.6-.6 1.2-.5 2V21"/>',
    "discord": '<path d="M8.5 16.5c-1.4.6-2.6 1.4-3.5 2-1.6-1.3-3-6.5-2.5-11 1.5-1.1 3-1.8 4.5-2l.7 1.5a14 14 0 0 1 8.6 0L17 5.5c1.5.2 3 .9 4.5 2 .5 4.5-.9 9.7-2.5 11-.9-.6-2.1-1.4-3.5-2"/><path d="M7.5 15.5c3 1.3 6 1.3 9 0"/><circle cx="9" cy="11.5" r="1.2"/><circle cx="15" cy="11.5" r="1.2"/>',
    "rss": '<path d="M5 11a8 8 0 0 1 8 8"/><path d="M5 5a14 14 0 0 1 14 14"/><circle cx="6" cy="18" r="1.2"/>',
    "shield": '<path d="M12 3 5 6v6c0 4.4 3 7.6 7 9 4-1.4 7-4.6 7-9V6l-7-3Z"/><path d="m9 12 2 2 4-4"/>',
    "code": '<path d="m8 8-4 4 4 4"/><path d="m16 8 4 4-4 4"/><path d="m14 5-4 14"/>',
    "users": '<circle cx="9" cy="8" r="3.2"/><path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6"/><path d="M16 4.6a3.2 3.2 0 0 1 0 6.3M18 14.3c1.8.8 3 2.6 3 4.7"/>',
    "zap": '<path d="M13 3 5 14h6l-1 7 8-11h-6l1-7Z"/>',
    "link": '<path d="M10 14a4 4 0 0 0 5.7 0l3-3a4 4 0 0 0-5.7-5.7l-1 1"/><path d="M14 10a4 4 0 0 0-5.7 0l-3 3a4 4 0 0 0 5.7 5.7l1-1"/>',
    "list": '<path d="M9 6h11M9 12h11M9 18h11"/><circle cx="4.5" cy="6" r="1"/><circle cx="4.5" cy="12" r="1"/><circle cx="4.5" cy="18" r="1"/>',
    "chev": '<path d="m9 6 6 6-6 6"/>',
    "eye": '<path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12Z"/><circle cx="12" cy="12" r="3"/>',
}


def icon(name, cls="ic"):
    return (f'<svg class="{cls}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" '
            f'stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">{ICONS[name]}</svg>')


# ---------------------------------------------------------------------------
#  LaTeX -> texto
# ---------------------------------------------------------------------------
def tex_arg(src, cmd):
    m = re.search(r"\\" + cmd + r"\{((?:[^{}]|\{[^{}]*\})*)\}", src)
    return clean_tex(m.group(1)) if m else ""


def clean_tex(s):
    s = re.sub(r"\\(?:emph|textbf|textit|texttt|mbox)\{([^{}]*)\}", r"\1", s)
    s = s.replace(r"\&", "&").replace(r"\%", "%").replace(r"\#", "#").replace(r"\_", "_")
    s = s.replace("---", "—").replace("--", "–").replace("~", " ")
    s = re.sub(r"\\[a-zA-Z]+\*?", "", s)
    s = s.replace("{", "").replace("}", "")
    return re.sub(r"\s+", " ", s).strip()


def guide_meta(g):
    tex = (ROOT / g["tex"]).read_text(encoding="utf-8")
    return {
        "subtitle": tex_arg(tex, "guiasubtitulo"),
        "category": tex_arg(tex, "guiacategoria"),
        "version": tex_arg(tex, "guiaversao"),
        "date": tex_arg(tex, "guiadata"),
        "author": tex_arg(tex, "guiaautor"),
        "license": tex_arg(tex, "guialicenca"),
        "chapters": [clean_tex(c) for c in re.findall(r"^\\chapter\{(.+?)\}\s*$", tex, re.M)],
    }


def pdf_page_count(path):
    """Conta páginas mesmo com object streams comprimidos (só stdlib)."""
    try:
        data = path.read_bytes()
    except OSError:
        return None
    pat = re.compile(rb"/Type\s*/Page(?![a-zA-Z])")
    n = len(pat.findall(data))
    for m in re.finditer(rb"stream\r?\n", data):
        start = m.end()
        end = data.find(b"endstream", start)
        if end < 0:
            continue
        try:
            n += len(pat.findall(zlib.decompress(data[start:end])))
        except zlib.error:
            pass
    return n or None


# ---------------------------------------------------------------------------
#  Vendor (PDF.js + fontes) -- baixado uma vez e cacheado em site/.cache
# ---------------------------------------------------------------------------
def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "PousadaGuides-site-build"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()


def npm_tarball(pkg, version=None):
    name = pkg.split("/")[-1]
    key = CACHE / f"{name}-{version or 'latest'}.tgz"
    if not key.exists():
        if version is None:
            meta = json.loads(fetch(f"https://registry.npmjs.org/{pkg}/latest"))
            url = meta["dist"]["tarball"]
        else:
            url = f"https://registry.npmjs.org/{pkg}/-/{name}-{version}.tgz"
        print(f"  baixando {url}")
        CACHE.mkdir(parents=True, exist_ok=True)
        key.write_bytes(fetch(url))
    return tarfile.open(fileobj=io.BytesIO(key.read_bytes()), mode="r:gz")


def extract(tar, member, dest):
    f = tar.extractfile(member)
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_bytes(f.read())


def vendor(out):
    v = out / "vendor"
    tar = npm_tarball("pdfjs-dist", PDFJS_VERSION)
    for name, dst in (("package/build/pdf.min.mjs", "pdfjs/pdf.min.mjs"),
                      ("package/build/pdf.worker.min.mjs", "pdfjs/pdf.worker.min.mjs"),
                      ("package/web/pdf_viewer.css", "pdfjs/pdf_viewer.css"),
                      ("package/LICENSE", "pdfjs/LICENSE")):
        extract(tar, name, v / dst)

    css = []
    for pkg, variants in FONTS.items():
        tar = npm_tarball(f"@fontsource/{pkg}")
        family = {"ibm-plex-sans": "IBM Plex Sans", "ibm-plex-sans-condensed": "IBM Plex Sans Condensed",
                  "ibm-plex-mono": "IBM Plex Mono"}[pkg]
        for var in variants:
            weight, style = var.split("-")
            for sub in SUBSETS:
                fname = f"{pkg}-{sub}-{weight}-{style}.woff2"
                try:
                    extract(tar, f"package/files/{fname}", v / "fonts" / fname)
                except KeyError:
                    continue
                rng = ("U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,U+0304,U+0308,U+0329,"
                       "U+2000-206F,U+20AC,U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD") if sub == "latin" else \
                      "U+0100-02BA,U+02BD-02C5,U+02C7-02CC,U+02CE-02D7,U+02DD-02FF,U+0304,U+0308,U+0329,U+1D00-1DBF,U+1E00-1E9F,U+1EF2-1EFF,U+2020,U+20A0-20AB,U+20AD-20C0,U+2113,U+2C60-2C7F,U+A720-A7FF"
                css.append(f"@font-face{{font-family:'{family}';font-style:{style};font-weight:{weight};"
                           f"font-display:swap;src:url(../vendor/fonts/{fname}) format('woff2');unicode-range:{rng}}}")
    (out / "css").mkdir(parents=True, exist_ok=True)
    (out / "css" / "fonts.css").write_text("\n".join(css) + "\n", encoding="utf-8")


# ---------------------------------------------------------------------------
#  Templates
# ---------------------------------------------------------------------------
def render(tpl, **kw):
    def sub(m):
        return str(kw[m.group(1)])
    return re.sub(r"\{\{(\w+)\}\}", sub, tpl)


def card(g, cfg):
    esc = html.escape
    chapters = "".join(f'<li><span class="n">{i:02d}</span>{esc(c)}</li>' for i, c in enumerate(g["chapters"], 1))
    tags = "".join(f'<span class="tag">{esc(t)}</span>' for t in g.get("tags", []))
    share_url = f'{cfg["base_url"]}/{g["id"]}/'
    return f'''
    <article class="guide-card reveal" id="guia-{g["id"]}" style="--d:{g["index"] * 90}ms">
      <a class="cover" href="{g["id"]}/" aria-label="Ler o {esc(g["title"])} online">
        <img src="img/covers/{g["id"]}.webp" width="640" height="905" alt="Capa do PousadaGuide #{g["num"]} — {esc(g["title"])}" loading="lazy" decoding="async">
        <span class="cover-num">#{g["num"]}</span>
        <span class="cover-cta">{icon("eye")} Ler online</span>
      </a>
      <div class="card-body">
        <div class="card-top">
          <span class="chip">{esc(g["category"])}</span>
          <span class="mono muted">{esc(g["version"])} · {g["pages"]} págs</span>
        </div>
        <h3><span class="emoji" aria-hidden="true">{g["emoji"]}</span> {esc(g["title"])}</h3>
        <p class="desc">{esc(g["subtitle"])}</p>
        <div class="tags">{tags}</div>
        <details class="chapters">
          <summary>{icon("list")} {len(g["chapters"])} capítulos {icon("chev", "ic chev")}</summary>
          <ol>{chapters}</ol>
        </details>
        <div class="actions">
          <a class="btn btn-primary" href="{g["id"]}/">{icon("book")} Ler online</a>
          <a class="btn btn-ghost" href="pdf/{g["pdf"]}" download title="Baixar PDF (tela)">{icon("download")}<span>PDF</span></a>
          <a class="btn btn-ghost icon-only" href="pdf/{g["print"]}" download title="Baixar versão para impressão" aria-label="Versão para impressão">{icon("printer")}</a>
          <button class="btn btn-ghost icon-only" type="button" data-share="{share_url}" data-title="PousadaGuide #{g["num"]} — {esc(g["title"])}" title="Copiar link do guia" aria-label="Compartilhar">{icon("share")}</button>
        </div>
      </div>
    </article>'''


def build(args):
    cfg_all = json.loads((SITE / "guides.json").read_text(encoding="utf-8"))
    site_cfg = cfg_all["site"]
    base_url = args.base_url.rstrip("/")
    cfg = dict(site_cfg, base_url=base_url)
    dist = pathlib.Path(args.dist)
    out = pathlib.Path(args.out)

    if out.exists():
        shutil.rmtree(out)
    out.mkdir(parents=True)

    # estáticos
    for sub in ("css", "js", "img"):
        shutil.copytree(SRC / sub, out / sub, dirs_exist_ok=True)
    print("Vendor (PDF.js + IBM Plex):")
    vendor(out)

    guides = []
    for i, g in enumerate(cfg_all["guides"]):
        g = dict(g, **guide_meta(g), index=i)
        src_pdf = dist / g["pdf"]
        if not src_pdf.exists():
            print(f"  ! {src_pdf} não encontrado — rode `make dist` antes", file=sys.stderr)
            if not args.allow_missing:
                sys.exit(1)
        else:
            (out / "pdf").mkdir(exist_ok=True)
            shutil.copy2(src_pdf, out / "pdf" / g["pdf"])
            n = pdf_page_count(src_pdf)
            if n:
                g["pages"] = n
            if (dist / g["print"]).exists():
                shutil.copy2(dist / g["print"], out / "pdf" / g["print"])
        guides.append(g)
    if (dist / "PousadaGuide-00-Exemplo.pdf").exists():
        shutil.copy2(dist / "PousadaGuide-00-Exemplo.pdf", out / "pdf" / "PousadaGuide-00-Exemplo.pdf")

    total_pages = sum(g["pages"] for g in guides)
    common = dict(
        BASE_URL=base_url, REPO=site_cfg["repo"], DISCORD=site_cfg["discord"], SUBSTACK=site_cfg["substack"],
        YEAR=date.today().year, SITE_DESC=html.escape(site_cfg["description"]),
        ICON_GITHUB=icon("github"), ICON_DISCORD=icon("discord"), ICON_RSS=icon("rss"), ICON_ARROW=icon("arrow"),
        ICON_BOOK=icon("book"), ICON_DOWNLOAD=icon("download"), ICON_PRINTER=icon("printer"), ICON_SHARE=icon("share"),
        ICON_SHIELD=icon("shield"), ICON_CODE=icon("code"), ICON_USERS=icon("users"), ICON_ZAP=icon("zap"),
        ICON_LINK=icon("link"), ICON_LIST=icon("list"), ICON_EYE=icon("eye"),
    )

    # index
    tpl = (SRC / "index.html").read_text(encoding="utf-8")
    (out / "index.html").write_text(render(
        tpl, **common,
        GUIDE_CARDS="".join(card(g, cfg) for g in guides),
        GUIDE_COUNT=len(guides), TOTAL_PAGES=total_pages, NEXT_NUM=f"{len(guides) + 1:02d}",
        LATEST_TITLE=html.escape(guides[-1]["title"]), LATEST_ID=guides[-1]["id"], LATEST_NUM=guides[-1]["num"],
    ), encoding="utf-8")

    # leitor por guia
    vtpl = (SRC / "viewer.html").read_text(encoding="utf-8")
    nav = [{"id": g["id"], "num": g["num"], "title": g["title"]} for g in guides]
    for g in guides:
        d = out / g["id"]
        d.mkdir()
        (d / "index.html").write_text(render(
            vtpl, **common,
            ID=g["id"], NUM=g["num"], TITLE=html.escape(g["title"]), EMOJI=g["emoji"],
            SUBTITLE=html.escape(g["subtitle"]), CATEGORY=html.escape(g["category"]), VERSION=html.escape(g["version"]),
            PAGES=g["pages"], PDF=g["pdf"], PRINT=g["print"],
            AVATAR=f"mascots/{g['id']}-avatar.webp" if (SRC / "img" / "mascots" / f"{g['id']}-avatar.webp").exists() else "pousadinha-avatar.webp",
            OG_IMAGE=f"{base_url}/img/og/{g['id']}.jpg" if (SRC / "img" / "og" / f"{g['id']}.jpg").exists() else f"{base_url}/img/og/home.jpg",
            NAV_JSON=html.escape(json.dumps(nav, ensure_ascii=False)),
        ), encoding="utf-8")

    # 404, robots, sitemap, .nojekyll
    (out / "404.html").write_text(render((SRC / "404.html").read_text(encoding="utf-8"), **common), encoding="utf-8")
    (out / ".nojekyll").write_text("")
    (out / "robots.txt").write_text(f"User-agent: *\nAllow: /\nSitemap: {base_url}/sitemap.xml\n")
    urls = [f"{base_url}/"] + [f"{base_url}/{g['id']}/" for g in guides]
    (out / "sitemap.xml").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
        + "".join(f"  <url><loc>{u}</loc></url>\n" for u in urls) + "</urlset>\n")

    print(f"\nSite gerado em {out}/  ({len(guides)} guias, {total_pages} páginas)")
    for g in guides:
        print(f"  {base_url}/{g['id']}/   {g['title']}  {g['version']}  {g['pages']} págs  {len(g['chapters'])} caps")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--dist", default=str(ROOT / "dist"))
    ap.add_argument("--out", default=str(ROOT / "_site"))
    ap.add_argument("--base-url", default="https://a-pousada.github.io/PousadaGuides")
    ap.add_argument("--allow-missing", action="store_true", help="não falha se faltar algum PDF")
    ap.add_argument("--serve", action="store_true", help="servir _site/ em http://localhost:8000")
    args = ap.parse_args()
    build(args)
    if args.serve:
        import functools
        import http.server
        handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=args.out)
        print("\nServindo em http://localhost:8000  (Ctrl+C para sair)")
        http.server.ThreadingHTTPServer(("127.0.0.1", 8000), handler).serve_forever()


if __name__ == "__main__":
    main()
