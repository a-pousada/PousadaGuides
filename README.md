<div align="center">

<a href="#-guias">
  <img src="docs/banner.png" alt="PousadaGuides — guias da comunidade Pousada (clique para ver os guias)" width="100%">
</a>

<br>

[![Build](https://img.shields.io/github/actions/workflow/status/a-pousada/PousadaGuides/build.yml?branch=main&style=for-the-badge&logo=githubactions&logoColor=5FE3C9&label=build&labelColor=00222A&color=01424A)](https://github.com/a-pousada/PousadaGuides/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/a-pousada/PousadaGuides?style=for-the-badge&logo=adobeacrobatreader&logoColor=5FE3C9&label=PDF&labelColor=00222A&color=01424A)](https://github.com/a-pousada/PousadaGuides/releases/latest)
[![Licença](https://img.shields.io/badge/licença-AGPL%203.0-D6C38F?style=for-the-badge&labelColor=00222A)](LICENSE)
[![LaTeX](https://img.shields.io/badge/feito%20em-XeLaTeX-5FE3C9?style=for-the-badge&logo=latex&logoColor=5FE3C9&labelColor=00222A)](pousadaguide.cls)
[![Idioma](https://img.shields.io/badge/idioma-pt--BR-F3EBD5?style=for-the-badge&labelColor=00222A)](#)

**Guias abertos, diretos e seguros da comunidade Pousada.**<br>
Cada guia é um PDF bonito, organizado e revisado pela comunidade — gerado a partir de código LaTeX aberto.

[**📥 Baixar o último PDF**](https://github.com/a-pousada/PousadaGuides/releases/latest) ·
[Guias](#-guias) ·
[Compilar](#%EF%B8%8F-compilar) ·
[Criar um guia](#-criando-um-novo-guia) ·
[Contribuir](#-contribuindo)

</div>

---

## 📚 Guias

| | Guia | Conteúdo | Download |
|:-:|---|---|:-:|
| <a href="#01--piracy-guide"><img src="docs/previews/piracy-capa.png" width="110" alt="Capa Piracy Guide"></a> | [**#01 — Piracy Guide**](#01--piracy-guide)<br><sub>segurança & opsec · v1.1 · 43 páginas</sub> | Como navegar sem armadilhas, baixar com segurança e dominar as melhores ferramentas e Megathreads. Inspirado na Megathread do `r/Piracy` e no FMHY. | [**Tela**](https://github.com/a-pousada/PousadaGuides/releases/latest/download/PousadaGuide-01-Piracy.pdf)<br>[Impressão](https://github.com/a-pousada/PousadaGuides/releases/latest/download/PousadaGuide-01-Piracy-impressao.pdf) |
| — | **#00 — Guia de Exemplo** | Tour por todos os componentes do sistema visual (para quem vai escrever guias). | [PDF](https://github.com/a-pousada/PousadaGuides/releases/latest/download/PousadaGuide-00-Exemplo.pdf) |

> [!TIP]
> A versão de **tela** tem fundo creme (mais confortável para ler). A de **impressão** tem fundo branco e economiza tinta.

### 🏴‍☠️ #01 — Piracy Guide

<a href="https://github.com/a-pousada/PousadaGuides/releases/latest/download/PousadaGuide-01-Piracy.pdf">
  <img src="docs/banner-piracy.png" alt="PousadaGuide #01 — Piracy Guide (Clique para baixar o PDF)" width="100%">
</a>

<p align="center">
  <a href="https://github.com/a-pousada/PousadaGuides/releases/latest/download/PousadaGuide-01-Piracy.pdf"><b>📥 Baixar Guia em PDF (Tela)</b></a> ·
  <a href="https://github.com/a-pousada/PousadaGuides/releases/latest/download/PousadaGuide-01-Piracy-impressao.pdf"><b>🖨️ Versão para Impressão</b></a> ·
  <a href="Piracy/"><b>📁 Ver Pasta do Guia</b></a>
</p>

<table>
<tr>
<td width="33%"><img src="docs/previews/piracy-capa.png" alt="Capa"></td>
<td width="33%"><img src="docs/previews/piracy-sumario.png" alt="Sumário"></td>
<td width="33%"><img src="docs/previews/piracy-ferramentas.png" alt="Fichas de ferramentas"></td>
</tr>
</table>

| Capítulo | O que você aprende |
|---|---|
| **01 · Antes de Zarpar** | Legenda do guia, selo **GOAT** da Pousadinha e as 5 Regras de Ouro contra malware |
| **02 · Navegadores, Bloqueio e DNS** | Zen / LibreWolf / Mullvad Browser, uBlock Origin, DNS over HTTPS e Userscripts |
| **03 · Torrents, Debrid e Downloads** | qBittorrent, TorBox / Real-Debrid / AllDebrid, Disbox, JDownloader 2 e Motrix |
| **04 · Programas Úteis no Geral** | 7-Zip / NanaZip, HatchZip, Hydra Launcher, mpv e VLC |
| **05 · Antivírus, Segurança e OS** | Falsos positivos, extensões seguras, VirusTotal, Linux + Bottles e Windows Sandbox |
| **06 · VPNs e Redes Alternativas** | Proton VPN, Mullvad, WireGuard, Tor e I2P — e as VPNs "grátis" a evitar |
| **07 · O Mapa das Megathreads** | FMHY, r/Piracy, Pirataria.link, índices otaku e comunidades NSFW (+18) |

> [!IMPORTANT]
> O guia tem caráter **educativo e de segurança digital**: ensina a evitar malware, golpes e rastreamento. Você é responsável por respeitar as leis do seu país.

---

## 🛠️ Compilar

Os PDFs são gerados automaticamente pelo GitHub Actions — você só precisa compilar localmente se for editar.

Precisa de **XeLaTeX** (TeX Live) ou **[Tectonic](https://tectonic-typesetting.github.io)**. pdfLaTeX não funciona (fontes OpenType).

```bash
make              # compila todos os guias
make piracy       # só o Piracy Guide  -> Piracy/piracy.pdf
make print        # versões de impressão (fundo branco)
make dist         # PDFs finais em dist/ (igual à Release)
make banner       # regenera o banner do README
make previews     # regenera as prévias de página do README
make clean
```

<details>
<summary><b>NixOS / sem instalar nada</b></summary>

```bash
nix shell nixpkgs#tectonic nixpkgs#poppler-utils -c make dist ENGINE=tectonic
```

</details>

Fontes: **IBM Plex Sans / Sans Condensed / Mono** (pacote `plex-otf`, já incluso no TeX Live e no Tectonic).

### 🚀 Publicando uma versão

```bash
git tag v1.0.0
git push origin v1.0.0
```

O workflow [`build.yml`](.github/workflows/build.yml) compila tudo e cria uma **Release** com os PDFs anexados. Em todo push/PR os PDFs também ficam disponíveis como *artefato* na aba **Actions**.

---

## 🗂️ Estrutura

```
PousadaGuides/
├── pousadaguide.cls        # a classe LaTeX: todo o sistema visual
├── exemplo.tex             # #00 — guia de exemplo com todos os componentes
├── Piracy/                 # #01 — Piracy Guide
│   ├── piracy.tex
│   ├── base.txt            #   anotações/rascunho original do guia
│   └── assets/             #   capa e avatar específicos deste guia
├── assets/                 # recursos compartilhados entre guias
│   ├── logo-*.png          #   logo Pousada (creme/teal)
│   ├── pousadinha*.png     #   mascote padrão + avatar
│   ├── goat.png            #   selo GOAT
│   └── logos/              #   logos dos serviços (128×128, padronizados)
├── art/                    # artes originais em alta e fontes dos logos (SVG/PNG)
├── docs/                   # banners (geral com Teacher e por guia com Pirata), previews
│   ├── banner.png          #   banner geral do projeto (clicável -> lista de guias)
│   ├── banner-piracy.png   #   banner temático #01 (clicável -> download do PDF)
│   ├── social-preview.png  #   card para compartilhamento em redes (1280×640)
│   ├── banner/             #   fontes TikZ dos banners (banner.tex, banner-piracy.tex)
│   └── previews/           #   prévias das páginas para o README
└── .github/workflows/      # build + release automáticos
```

---

## ✍️ Criando um novo guia

> [!TIP]
> **Manual completo para pessoas e agentes de IA:** Consulte o [**AGENTS.md**](AGENTS.md) para o tutorial completo e detalhado de como criar novos temas do zero, padronizar logos, gerar banners temáticos e utilizar todos os componentes da classe [`pousadaguide.cls`](pousadaguide.cls).

1. Crie uma pasta (ex.: `Linux/`) com um link para a classe: `ln -s ../pousadaguide.cls Linux/`
2. Coloque a capa/avatar do guia em `Linux/assets/` (os recursos de `assets/` já são encontrados automaticamente).
3. Escreva o `.tex`:

```latex
\documentclass{pousadaguide}        % [print] para versão de impressão
\guiamascote{linux-capa}            % opcional: mascote da capa
\guiaavatar{linux-avatar}           % opcional: avatar da Pousadinha
\guianumero{02}
\guiatitulo{Linux Guide}
\guiasubtitulo{Do zero ao terminal sem medo.}
\guiaslug{linux-guide}
\guiacategoria{sistemas}
\guiaversao{v1.0}
\guiaautor{Bakalhau}
\guiadata{dezembro de 2026}
\guialicenca{GNU AGPLv3}
\begin{document}
\capa
\tableofcontents
\comentario{subtítulo do capítulo}
\chapter{Introdução}
...
\contracapa
\end{document}
```

4. Adicione os alvos no [`Makefile`](Makefile) (`compile` e `dist`) e uma linha na tabela de guias acima.
5. Crie o banner temático do guia copiando `docs/banner/banner-piracy.tex` para `docs/banner/banner-<tema>.tex` com a mascote do tema e inclua no `make banner`.

### Componentes

| Componente | Uso |
|---|---|
| Ficha de ferramenta | `\begin{ferramenta}[goat,logo=qbittorrent]{Nome}{https://url}{tag1, tag2}…\end{ferramenta}` |
| ↳ selos | `goat`, `recomendado`, `evite` — e `logo=`/`logo2=` com o nome do arquivo em `assets/logos/` |
| Missão (objetivos) | `\begin{missao}[legenda] \begin{itemize}…\end{itemize} \end{missao}` |
| Callouts | `nota`, `dica`, `atencao`, `perigo`, `legenda` — `\begin{dica}[título]…\end{dica}` |
| Resumo | `\begin{tldr}…\end{tldr}` |
| Mascote fala | `\begin{pousadinha}[rótulo]…\end{pousadinha}` |
| Terminal | `\begin{terminal}[título da janela]` … `\end{terminal}` |
| Código | `\begin{codigo}[language=JavaScript]{arquivo.js}` … `\end{codigo}` |
| Passo a passo | `\begin{passo}{Título}…\end{passo}` |
| Tabela | `\begin{tabela}{l X c} \cab{A} & \cab{B} & \cab{C} \\ … \end{tabela}` |
| Checklist | `\begin{checklist} \feito … \item … \opcional … \end{checklist}` |
| Em linha | `\cmd{código}`, `\kbd{Ctrl}`, `\pgtag{open source}`, `\pglink[texto]{url}`, `\pglogo{mpv}` |
| Marcadores | `\goat`, `\ok`, `\nope`, `\meio`, `\estrelas{4}`, `\divisor` |

> [!NOTE]
> `\cmd{}` lê o argumento literalmente — não use dentro de argumentos de outros comandos (ex.: títulos). Em URLs, escape `#` e `%` como `\#` e `\%`.

<details>
<summary><b>🎨 Paleta</b></summary>

| Nome | Hex | Papel |
|---|---|---|
| `pgTeal` | `#01424A` | primária (logo) |
| `pgCream` | `#F3EBD5` | contraste (logo) |
| `pgAbyss` / `pgVoid` | `#01323A` / `#00222A` | terminais e blocos escuros |
| `pgGlow` | `#5FE3C9` | acento sobre fundo escuro |
| `pgSignal` | `#14857A` | acento/links sobre fundo claro |
| `pgKhaki` / `pgBrass` | `#D6C38F` / `#A8823F` | acentos quentes (Pousadinha, destaque) |
| `pgAmber` / `pgAlert` | `#D9962B` / `#C9483E` | atenção / perigo |
| `pgInk` / `pgMuted` | `#14292C` / `#5F7774` | texto |
| `pgPaper` | `#FAF6EC` | fundo da página |

</details>

<details>
<summary><b>🖼️ Logos dos serviços</b></summary>

Os logos ficam em `assets/logos/` como PNG **128×128** transparente, com o desenho recortado e centralizado em 112 px — assim todos aparecem com o mesmo tamanho nas fichas. As fontes originais (SVG/PNG) ficam em `art/logos-src/`. Para adicionar um novo, converta para esse padrão e use `logo=<nome>` na ficha.

</details>

---

## 🤝 Contribuindo

- **Link quebrado, suspeito ou sugestão?** Abra uma [issue de link](https://github.com/a-pousada/PousadaGuides/issues/new?template=link.yml).
- **Quer editar o texto?** Faça um fork, edite o `.tex` e abra um Pull Request — o CI compila o PDF e deixa como artefato para revisão.
- Novos guias são muito bem-vindos! Siga a seção [Criando um novo guia](#-criando-um-novo-guia).

## 📄 Licença

Conteúdo e código sob a licença **[GNU Affero General Public License v3.0 (AGPL-3.0)](LICENSE)**.

<sub>Logos e marcas citados pertencem aos seus respectivos donos e são usados apenas para identificação. Mascote Pousadinha e logo Pousada © Comunidade Pousada.</sub>

<div align="center">
<br>
<img src="assets/logo-symbol-teal.png" height="36" alt="Pousada">
<br>
<sub><code>POUSADA // COMUNIDADE</code></sub>
</div>
