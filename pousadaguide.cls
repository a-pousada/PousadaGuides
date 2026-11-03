%% =====================================================================
%%  pousadaguide.cls  --  Sistema visual dos guias "PousadaGuide"
%%  Comunidade Pousada
%%
%%  Motor: XeLaTeX ou LuaLaTeX (usa fontspec + fontes OpenType).
%%  Fontes: IBM Plex Sans / Sans Condensed / Mono (pacote `plex-otf`,
%%          incluso no TeX Live e no bundle do Tectonic).
%%
%%  Opções da classe:
%%    print   -> fundo branco (para impressão), sem a faixa lateral
%%    nostrip -> remove a faixa lateral teal das páginas internas
%% =====================================================================
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{pousadaguide}[2026/11/01 v1.0 PousadaGuide visual system]

\RequirePackage{iftex}
\RequireTUTeX % aborta se não for XeLaTeX/LuaLaTeX

% ---------------------------------------------------------------------
%  Opções
% ---------------------------------------------------------------------
\newif\ifpg@print   \pg@printfalse
\newif\ifpg@strip   \pg@striptrue
\DeclareOption{print}{\pg@printtrue\pg@stripfalse}
\DeclareOption{nostrip}{\pg@stripfalse}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{book}}
\ProcessOptions\relax

\LoadClass[11pt,a4paper,oneside,openany]{book}

% ---------------------------------------------------------------------
%  Pacotes
% ---------------------------------------------------------------------
\RequirePackage[brazilian]{babel}
\RequirePackage{fontspec}
\RequirePackage[table]{xcolor}
\RequirePackage{graphicx}
\RequirePackage[a4paper,top=28mm,bottom=26mm,left=26mm,right=22mm,
                headheight=14pt,headsep=9mm,footskip=12mm]{geometry}
\RequirePackage{tikz}
\usetikzlibrary{calc,positioning,shapes.geometric}
\RequirePackage[most]{tcolorbox}
\RequirePackage{titlesec}
\RequirePackage{titletoc}
\RequirePackage{fancyhdr}
\RequirePackage{eso-pic}
\RequirePackage{enumitem}
\RequirePackage{booktabs}
\RequirePackage{tabularx}
\RequirePackage{array}
\RequirePackage{listings}
\RequirePackage{fontawesome5}
\RequirePackage{lastpage}
\RequirePackage{etoolbox}
\RequirePackage{microtype}
\RequirePackage{xurl}
\RequirePackage{hyperref}
\RequirePackage{bookmark}

% ---------------------------------------------------------------------
%  Paleta  (extraída da logo e da mascote Pousadinha)
% ---------------------------------------------------------------------
% Identidade (logo)
\definecolor{pgTeal}{HTML}{01424A}      % teal da logo  -> cor primária
\definecolor{pgCream}{HTML}{F3EBD5}     % creme da logo -> contraste
% Profundidades do teal (terminal / blocos escuros)
\definecolor{pgAbyss}{HTML}{01323A}
\definecolor{pgVoid}{HTML}{00222A}
% Acentos "hacker" (circuitos da roupa da Pousadinha)
\definecolor{pgGlow}{HTML}{5FE3C9}      % ciano dos circuitos (sobre escuro)
\definecolor{pgSignal}{HTML}{14857A}    % ciano escurecido (sobre claro)
% Acentos quentes (jaqueta e óculos da Pousadinha)
\definecolor{pgKhaki}{HTML}{D6C38F}
\definecolor{pgBrass}{HTML}{A8823F}
\definecolor{pgLeather}{HTML}{6B4A2F}
% Neutros
\definecolor{pgInk}{HTML}{14292C}       % texto principal
\definecolor{pgMuted}{HTML}{5F7774}     % texto secundário
\definecolor{pgFog}{HTML}{7FA29E}       % texto secundário sobre escuro
\definecolor{pgPaper}{HTML}{FAF6EC}     % fundo da página
\definecolor{pgPaperLight}{HTML}{FFFDF7}% fundo de cartões
\definecolor{pgPaperDark}{HTML}{F1EBDA} % linhas alternadas / blocos
% Estados
\definecolor{pgAmber}{HTML}{D9962B}
\definecolor{pgAlert}{HTML}{C9483E}

\ifpg@print
  \colorlet{pgPaper}{white}
  \colorlet{pgPaperLight}{white}
\fi
\pagecolor{pgPaper}
\color{pgInk}

% ---------------------------------------------------------------------
%  Tipografia
% ---------------------------------------------------------------------
\setmainfont{IBMPlexSans}[
  Extension=.otf, UprightFont=*-Regular, BoldFont=*-SemiBold,
  ItalicFont=*-Italic, BoldItalicFont=*-SemiBoldItalic]
\setsansfont{IBMPlexSans}[
  Extension=.otf, UprightFont=*-Regular, BoldFont=*-SemiBold,
  ItalicFont=*-Italic, BoldItalicFont=*-SemiBoldItalic]
\setmonofont{IBMPlexMono}[
  Extension=.otf, UprightFont=*-Regular, BoldFont=*-SemiBold,
  ItalicFont=*-Italic, BoldItalicFont=*-SemiBoldItalic,
  Scale=MatchLowercase]
\newfontfamily\pgmono{IBMPlexMono}[
  Extension=.otf, UprightFont=*-Regular, BoldFont=*-Bold,
  ItalicFont=*-Italic, BoldItalicFont=*-BoldItalic]
\newfontfamily\pgmonolight{IBMPlexMono}[Extension=.otf, UprightFont=*-Light]
\newfontfamily\pgdisplay{IBMPlexSansCondensed}[
  Extension=.otf, UprightFont=*-Bold, BoldFont=*-Bold]
\newfontfamily\pgdisplaylight{IBMPlexSansCondensed}[
  Extension=.otf, UprightFont=*-Regular]

\linespread{1.12}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0.55em plus 0.2em minus 0.1em}
\setlength{\emergencystretch}{2em}
\raggedbottom

% ---------------------------------------------------------------------
%  Metadados do guia
% ---------------------------------------------------------------------
\newcommand\pg@titulo{PousadaGuide}
\newcommand\pg@subtitulo{}
\newcommand\pg@numero{00}
\newcommand\pg@versao{v1.0}
\newcommand\pg@autor{Bakalhau}
\newcommand\pg@data{\today}
\newcommand\pg@slug{guia}
\newcommand\pg@url{}
\newcommand\pg@categoria{guia}
\newcommand\pg@licenca{GNU AGPLv3}
\newcommand\pg@links{}

\newcommand\guiatitulo[1]{\renewcommand\pg@titulo{#1}}
\newcommand\guiasubtitulo[1]{\renewcommand\pg@subtitulo{#1}}
\newcommand\guianumero[1]{\renewcommand\pg@numero{#1}}
\newcommand\guiaversao[1]{\renewcommand\pg@versao{#1}}
\newcommand\guiaautor[1]{\renewcommand\pg@autor{#1}}
\newcommand\guiadata[1]{\renewcommand\pg@data{#1}}
\newcommand\guiaslug[1]{\renewcommand\pg@slug{#1}}
\newcommand\guiaurl[1]{\renewcommand\pg@url{#1}}
\newcommand\guiacategoria[1]{\renewcommand\pg@categoria{#1}}
\newcommand\guialicenca[1]{\renewcommand\pg@licenca{#1}}
\newcommand\guialinks[1]{\renewcommand\pg@links{#1}}

% Imagens (podem ser trocadas no preâmbulo do guia)
\graphicspath{{assets/}{../assets/}}
\newcommand\pg@logoCream{logo-symbol-cream}
\newcommand\pg@logoTeal{logo-symbol-teal}
\newcommand\pg@mascote{pousadinha}
\newcommand\pg@avatar{pousadinha-avatar}
\newcommand\pg@goat{goat}
\newcommand\pg@mascoteh{.66\paperheight}
\newcommand\pg@mascotex{-50mm}
\newcommand\pg@mascotey{-6mm}
\newcommand\guiamascote[1]{\renewcommand\pg@mascote{#1}}
\newcommand\guiaavatar[1]{\renewcommand\pg@avatar{#1}}
\newcommand\guiagoat[1]{\renewcommand\pg@goat{#1}}
\newcommand\guiamascotepos[3]{%
  \renewcommand\pg@mascoteh{#1}%
  \renewcommand\pg@mascotex{#2}%
  \renewcommand\pg@mascotey{#3}}

% PDF: metadados preenchidos no início do documento
\AtBeginDocument{%
  \hypersetup{
    pdftitle={PousadaGuide \#\pg@numero\space -- \pg@titulo},
    pdfauthor={\pg@autor},
    pdfsubject={\pg@subtitulo},
    pdfkeywords={Pousada, PousadaGuide, \pg@categoria},
    pdfcreator={pousadaguide.cls \pg@versao},
  }%
}
\hypersetup{
  unicode=true,
  colorlinks=true,
  linkcolor=pgSignal,
  urlcolor=pgSignal,
  citecolor=pgSignal,
  filecolor=pgSignal,
  bookmarksnumbered=true,
  bookmarksopen=true,
  bookmarksopenlevel=1,
  pdfdisplaydoctitle=true,
  pdfpagemode=UseOutlines,
  pdfstartview=FitH,
  pdflang=pt-BR,
}
\urlstyle{tt}

% ---------------------------------------------------------------------
%  Utilitários numéricos (hex e dois dígitos)
% ---------------------------------------------------------------------
\ExplSyntaxOn
\NewExpandableDocumentCommand \pgHex { m }
  { \int_compare:nNnT {#1} < {16} {0} \int_to_Hex:n {#1} }
\NewExpandableDocumentCommand \pgTwo { m }
  { \int_compare:nNnT {#1} < {10} {0} \int_eval:n {#1} }
\NewDocumentCommand \pgtags { m }
  { \clist_map_inline:nn {#1} { \pgtag{##1}\hspace{2pt} } }
\ExplSyntaxOff

% ---------------------------------------------------------------------
%  Motivos gráficos reutilizáveis
% ---------------------------------------------------------------------
% Cantoneiras estilo HUD:  \pg@hud{sw}{ne}{cor}{tamanho}
\newcommand\pg@hud[4]{%
  \coordinate (hudSW) at (#1);
  \coordinate (hudNE) at (#2);
  \coordinate (hudNW) at (hudSW |- hudNE);
  \coordinate (hudSE) at (hudNE |- hudSW);
  \draw[#3, line width=.9pt] ($(hudSW)+(0,#4)$) -- (hudSW) -- ($(hudSW)+(#4,0)$);
  \draw[#3, line width=.9pt] ($(hudNE)-(0,#4)$) -- (hudNE) -- ($(hudNE)-(#4,0)$);
  \draw[#3, line width=.9pt] ($(hudNW)-(0,#4)$) -- (hudNW) -- ($(hudNW)+(#4,0)$);
  \draw[#3, line width=.9pt] ($(hudSE)+(0,#4)$) -- (hudSE) -- ($(hudSE)-(#4,0)$);
}
% Sem hifenização (títulos)
\newcommand\pg@nohyph{\hyphenpenalty=10000\exhyphenpenalty=10000\raggedright}
% Cursor de terminal
\newcommand\pgcursor[1][pgGlow]{\textcolor{#1}{\rule[-.12em]{.52em}{1em}}}
% Prompt
\newcommand\pgprompt{\textcolor{pgSignal}{\pgmono\bfseries>\_}}

% ---------------------------------------------------------------------
%  Faixa lateral das páginas internas
% ---------------------------------------------------------------------
\newif\ifpg@decor \pg@decortrue
\newcommand\pg@stripdraw{%
  \begin{tikzpicture}[x=1mm,y=1mm]
    \useasboundingbox (0,0) rectangle (\paperwidth,\paperheight);
    \fill[pgTeal] (0,0) rectangle (5.5,\paperheight);
    \fill[pgGlow] (5.5,0) rectangle (6.1,\paperheight);
    \foreach \y in {20,30,...,280}{\fill[pgGlow,opacity=.35] (1.2,\y) rectangle (2.2,\y+.4);}
    \node[rotate=90, anchor=west, inner sep=0, text=pgGlow,
          font=\pgmono\fontsize{5.5}{6}\selectfont]
      at (3.7,18) {POUSADAGUIDE\,//\,\#\pg@numero\,//\,\pg@slug};
  \end{tikzpicture}}
\AddToShipoutPictureBG{%
  \ifpg@strip\ifpg@decor\AtPageLowerLeft{\pg@stripdraw}\fi\fi}

% ---------------------------------------------------------------------
%  Cabeçalho e rodapé
% ---------------------------------------------------------------------
\newcommand\pg@footer{%
  \fancyfoot[L]{\raisebox{-.5mm}{\includegraphics[height=3.2mm]{\pg@logoTeal}}%
    \hspace{2mm}{\pgmono\fontsize{7}{8}\selectfont\color{pgMuted}%
    POUSADA\textcolor{pgSignal}{\,//\,}COMUNIDADE}}%
  \fancyfoot[R]{\pgmono\fontsize{8}{9}\selectfont\color{pgMuted}%
    [\,\textcolor{pgTeal}{\bfseries\thepage}\,/\,\pageref*{LastPage}\,]}}

\fancypagestyle{pgmain}{%
  \fancyhf{}%
  \fancyhead[L]{\pgmono\fontsize{7.5}{9}\selectfont\color{pgMuted}%
    \textcolor{pgSignal}{\faTerminal}\hspace{1.5mm}%
    pousadaguide\textcolor{pgSignal}{://}\pg@slug}%
  \fancyhead[R]{\pgmono\fontsize{7.5}{9}\selectfont\color{pgMuted}\leftmark}%
  \pg@footer
  \renewcommand\headrule{{\color{pgTeal!22}\hrule height .5pt}}%
  \renewcommand\footrulewidth{0pt}}
\fancypagestyle{plain}{%
  \fancyhf{}\pg@footer
  \renewcommand\headrulewidth{0pt}\renewcommand\footrulewidth{0pt}}
\pagestyle{pgmain}

\renewcommand\chaptermark[1]{\markboth{#1}{}}
\iffalse
  \markboth{\ifnum\c@secnumdepth>\m@ne\ifx\@mainmatter\@empty\else
     \fi\fi #1}{}}
\fi
\renewcommand\sectionmark[1]{}

% ---------------------------------------------------------------------
%  Capítulos  (bloco teal no topo da página)
% ---------------------------------------------------------------------
\newlength\pg@chapH \setlength\pg@chapH{70mm}
\def\pg@chapcomment{}
\newcommand\comentario[1]{\gdef\pg@chapcomment{#1}} % "// subtítulo" do capítulo

\newcommand\pg@chapterblock[3]{% #1 rótulo  #2 título  #3 número fantasma
  \begin{tikzpicture}[remember picture, overlay]
    \coordinate (pgNW) at ([xshift=-1mm,yshift=1mm]current page.north west);
    \coordinate (pgSE) at ([xshift=1mm,yshift=-\pg@chapH]current page.north east);
    \fill[pgTeal] (pgNW) rectangle (pgSE);
    \begin{scope}
      \clip (pgNW) rectangle (pgSE);
      \draw[pgCream, opacity=.05, line width=.3pt, step=6mm]
        (pgNW) grid (pgSE);
      \node[anchor=south east, inner sep=0, text=pgGlow, opacity=.13,
            font=\pgmono\bfseries\fontsize{118}{118}\selectfont]
        at ([xshift=-12mm,yshift=-9mm]pgSE) {#3};
    \end{scope}
    \fill[pgGlow] (pgSE -| pgNW) rectangle ([yshift=-1.1mm]pgSE);
    \pg@hud{$(pgSE -| pgNW)+(14mm,9mm)$}{$(pgNW -| pgSE)+(-12mm,-10mm)$}%
           {pgGlow!70!pgTeal}{4mm}
    \node[anchor=north west, inner sep=0, text=pgGlow,
          font=\pgmono\bfseries\fontsize{9}{11}\selectfont]
      (pgLbl) at ([xshift=26mm,yshift=-22mm]current page.north west) {#1};
    \node[anchor=north west, inner sep=0, text=pgCream, text width=140mm,
          align=left, font=\pgdisplay\fontsize{30}{33}\selectfont]
      (pgTtl) at ([yshift=-4mm]pgLbl.south west) {\pg@nohyph#2\par};
    \ifx\pg@chapcomment\@empty\else
      \node[anchor=north west, inner sep=0, text=pgFog, text width=140mm,
            align=left, font=\pgmono\fontsize{9}{11}\selectfont]
        at ([yshift=-3.5mm]pgTtl.south west)
        {\textcolor{pgGlow}{//}~\pg@chapcomment};
    \fi
  \end{tikzpicture}%
  \gdef\pg@chapcomment{}%
}
\newcommand\pg@chapnum[1]{%
  \pg@chapterblock{>\_~CAPÍTULO~\pgTwo{\value{chapter}}}{#1}%
                  {0x\pgHex{\value{chapter}}}}
\newcommand\pg@chapnonum[1]{\pg@chapterblock{>\_~\MakeUppercase{\pg@slug}}{#1}{>\_}}

\titleformat{\chapter}[block]{}{}{0pt}{\pg@chapnum}
\titleformat{name=\chapter,numberless}[block]{}{}{0pt}{\pg@chapnonum}
\newlength\pg@chapBefore
\setlength\pg@chapBefore{\dimexpr\pg@chapH-28mm-11pt\relax}
\titlespacing*{\chapter}{0pt}{\pg@chapBefore}{11mm}

% ---------------------------------------------------------------------
%  Seções
% ---------------------------------------------------------------------
\setcounter{secnumdepth}{1}
\setcounter{tocdepth}{1}
\renewcommand\thesection{\pgTwo{\value{chapter}}.\arabic{section}}

\newcommand\pg@secnum{%
  \tikz[baseline=(n.base)]\node[fill=pgTeal, text=pgGlow, inner xsep=2.2mm,
     inner ysep=1.4mm, font=\pgmono\bfseries\normalsize](n){\thesection};}
\titleformat{\section}
  {\pgmono\bfseries\fontsize{15.5}{19}\selectfont\color{pgTeal}}
  {\pg@secnum}{3mm}{}
  [\vspace{1.2mm}{\color{pgTeal!25}\titlerule[.6pt]}]
\titlespacing*{\section}{0pt}{7mm}{3mm}

\titleformat{\subsection}
  {\pgmono\bfseries\fontsize{12.5}{15}\selectfont\color{pgInk}}
  {}{0pt}{\textcolor{pgSignal}{>>}\hspace{2.5mm}}
\titlespacing*{\subsection}{0pt}{5mm}{1.5mm}

\titleformat{\subsubsection}
  {\pgmono\bfseries\fontsize{10.5}{13}\selectfont\color{pgTeal}}
  {}{0pt}{\textcolor{pgMuted}{//}\hspace{2mm}}
\titlespacing*{\subsubsection}{0pt}{4mm}{1mm}

\titleformat{\paragraph}[runin]
  {\pgmono\bfseries\small\color{pgTeal}}{}{0pt}{}[\textcolor{pgSignal}{:}]

% ---------------------------------------------------------------------
%  Sumário
% ---------------------------------------------------------------------
\addto\captionsbrazilian{\renewcommand\contentsname{Índice}}
\pretocmd{\tableofcontents}{\begingroup\setlength{\parskip}{0pt}\linespread{1.02}\selectfont}{}{}
\apptocmd{\tableofcontents}{\endgroup}{}{}
\titlecontents{chapter}[0pt]
  {\addvspace{2.8pt}\pgmono\bfseries\color{pgTeal}}
  {\makebox[16mm][l]{\textcolor{pgSignal}{0x\pgHex{\thecontentslabel}}}}
  {\makebox[16mm][l]{\textcolor{pgSignal}{>\_}}}
  {\hfill\contentspage}
\titlecontents{section}[16mm]
  {\addvspace{0pt}\color{pgInk}}
  {\contentslabel[{\pgmono\small\color{pgMuted}\thecontentslabel}]{12mm}}
  {}
  {\titlerule*[.7em]{\textcolor{pgTeal!35}{.}}\pgmono\small\contentspage}

% ---------------------------------------------------------------------
%  Listas
% ---------------------------------------------------------------------
\newcommand\pg@two[1]{\ifnum#1<10 0\fi\number#1}
\newcommand\pgtwo[1]{\expandafter\pg@two\csname c@#1\endcsname}
\AddEnumerateCounter{\pgtwo}{\pg@two}{00}
\setlist{itemsep=.25em, topsep=.4em, parsep=0pt}
\setlist[itemize,1]{label={\textcolor{pgSignal}{\pgmono\bfseries >}}, leftmargin=6mm}
\setlist[itemize,2]{label={\textcolor{pgMuted}{\pgmono -}}, leftmargin=5mm}
\setlist[enumerate,1]{label={\textcolor{pgSignal}{\pgmono\bfseries\pgtwo*.}},
                      leftmargin=9mm}
\setlist[enumerate,2]{label={\textcolor{pgMuted}{\pgmono\alph*)}}, leftmargin=6mm}
\setlist[description]{font={\pgmono\bfseries\color{pgTeal}}}

% Checklist:  \begin{checklist} \item ... \feito ... \end{checklist}
\newlist{checklist}{itemize}{1}
\setlist[checklist]{label={\textcolor{pgMuted}{\pgmono[\,\,]}}, leftmargin=9mm}
\newcommand\feito{\item[\textcolor{pgSignal}{\pgmono\bfseries[x]}]}
\newcommand\opcional{\item[\textcolor{pgAmber}{\pgmono\bfseries[?]}]}

% ---------------------------------------------------------------------
%  Elementos em linha
% ---------------------------------------------------------------------
% Código em linha:  \cmd{sudo apt update}   (argumento verbatim)
\newtcbox{\pg@cmdbox}{on line, enhanced, sharp corners, boxrule=0pt,
  frame hidden, colback=pgTeal!9, left=2pt, right=2pt, top=1pt, bottom=1pt,
  fontupper=\pgmono\small\color{pgTeal}}
\NewDocumentCommand\cmd{v}{\pg@cmdbox{#1}}

% Tecla:  \kbd{Ctrl}+\kbd{Shift}+\kbd{T}
\newtcbox{\kbd}{on line, enhanced, arc=1.2pt, colback=pgPaperLight,
  colframe=pgMuted!70, boxrule=.45pt, bottomrule=1.3pt,
  left=2.5pt, right=2.5pt, top=.6pt, bottom=.6pt,
  fontupper=\pgmono\bfseries\fontsize{7.5}{8}\selectfont\color{pgInk}}

% Etiqueta:  \pgtag{open source}   \pgtag[pgAmber]{pago}
\newtcbox{\pg@tagbox}[1][pgTeal]{on line, enhanced, sharp corners,
  boxrule=0pt, frame hidden, colback=#1!13, left=3pt, right=3pt, top=1.2pt,
  bottom=1.2pt, fontupper=\pgmono\bfseries\fontsize{6.5}{7}\selectfont\color{#1!85!black}}
\NewDocumentCommand\pgtag{O{pgTeal} m}{\pg@tagbox[#1]{\MakeUppercase{#2}}}

% Link:  \pglink{https://...}   ou   \pglink[texto]{https://...}
\NewDocumentCommand\pglink{o m}{%
  \href{#2}{{\pgmono\small\IfValueTF{#1}{#1}{\nolinkurl{#2}}}%
  \hspace{1.5pt}\raisebox{.1ex}{\scriptsize\faExternalLink*}}}

% Marcadores de tabela
\newcommand\ok{\textcolor{pgSignal}{\faCheck}}
\newcommand\nope{\textcolor{pgAlert}{\faTimes}}
\newcommand\meio{\textcolor{pgAmber}{\faMinus}}
% Avaliação:  \estrelas{4}
\newcommand\estrelas[1]{{\color{pgBrass}\scriptsize%
  \foreach \s in {1,...,5}{\ifnum\s>#1\relax\faStar[regular]\else\faStar\fi\,}}}
% Ícone Pousadinha GOAT (os melhores / recomendações máximas)
\newcommand\goat{\raisebox{-.24\height}{\includegraphics[height=1.35em]{\pg@goat}}}
\newcommand\selogoat{\goat\hspace{2pt}\pgtag[pgBrass]{goat}}

% Divisor
\newcommand\divisor{\par\vspace{3mm}\noindent
  \begin{tikzpicture}
    \draw[pgTeal!30, line width=.6pt] (0,0) -- (.44\linewidth,0);
    \node[diamond, fill=pgSignal, inner sep=1.6pt] at (.5\linewidth,0) {};
    \node[text=pgTeal!50, font=\pgmono\scriptsize] at (.5\linewidth,0) {};
    \draw[pgTeal!30, line width=.6pt] (.56\linewidth,0) -- (\linewidth,0);
  \end{tikzpicture}\par\vspace{2mm}}

% ---------------------------------------------------------------------
%  Caixas (tcolorbox)
% ---------------------------------------------------------------------
\tcbset{
  pg/base/.style={enhanced, breakable, sharp corners, boxrule=0pt,
    frame hidden, before skip=11pt, after skip=11pt,
    left=4.5mm, right=4.5mm, top=3mm, bottom=3mm},
  pg/tab/.style 2 args={% aba de rótulo no canto superior esquerdo
    overlay unbroken and first={%
      \node[anchor=north west, fill=#1, text=#2, inner xsep=2.4mm,
            inner ysep=1.3mm, font=\pgmono\bfseries\fontsize{7.5}{8}\selectfont]
        at (frame.north west) {\pg@tabtext};}},
}

% Callouts:  \begin{dica}[título opcional] ... \end{dica}
% \pg@callout{nome}{cor}{cor do texto da aba}{ícone}{RÓTULO}
\newcommand\pg@callout[5]{%
  \NewTColorBox{#1}{O{}}{pg/base,
    colback=#2!7!pgPaperLight,
    borderline west={3pt}{0pt}{#2},
    top=9mm,
    code={\def\pg@tabtext{#4\hspace{1.6mm}#5%
      \if\relax\detokenize{##1}\relax\else\hspace{1.6mm}::\hspace{1.6mm}##1\fi}},
    pg/tab={#2}{#3}}}
\pg@callout{nota}{pgTeal}{pgCream}{\faInfoCircle}{INFO}
\pg@callout{dica}{pgSignal}{white}{\faLightbulb}{DICA}
\pg@callout{atencao}{pgAmber}{pgVoid}{\faExclamationTriangle}{ATENÇÃO}
\pg@callout{perigo}{pgAlert}{white}{\faSkull}{PERIGO}
\pg@callout{legenda}{pgTeal}{pgCream}{\faCompass}{LEGENDA DO GUIA}

% TL;DR
\NewTColorBox{tldr}{O{}}{pg/base, colback=pgPaperLight,
  borderline={.7pt}{0pt}{pgSignal, dash pattern=on 3pt off 2pt},
  top=9mm, code={\def\pg@tabtext{\faBolt\hspace{1.6mm}TL;DR}},
  pg/tab={pgSignal}{white}}

% Missão (objetivos do capítulo)
\NewTColorBox{missao}{O{o que você vai aprender}}{pg/base,
  colback=pgTeal, coltext=pgCream, top=12mm, bottom=5mm, left=7mm, right=7mm,
  overlay unbroken and first={%
    \begin{scope}
      \clip (frame.south west) rectangle (frame.north east);
      \draw[pgCream, opacity=.05, step=5mm] (frame.south west) grid (frame.north east);
    \end{scope}
    \node[anchor=north west, text=pgGlow, inner sep=0,
          font=\pgmono\bfseries\fontsize{8}{9}\selectfont]
      at ([xshift=7mm,yshift=-4.5mm]frame.north west)
      {\faCrosshairs\hspace{1.8mm}MISSION\_BRIEFING.txt};
    \node[anchor=north east, text=pgFog, inner sep=0,
          font=\pgmono\fontsize{8}{9}\selectfont]
      at ([xshift=-7mm,yshift=-4.5mm]frame.north east) {// #1};
    \pg@hud{$(frame.south west)+(2mm,2mm)$}{$(frame.north east)-(2mm,2mm)$}{pgGlow}{3mm}},
  before upper={\setlist[itemize,1]{label={\textcolor{pgGlow}{\pgmono\bfseries[+]}},
      leftmargin=9mm}}}

% Pousadinha fala
\NewTColorBox{pousadinha}{O{Pousadinha diz}}{pg/base, unbreakable,
  colback=pgKhaki!20!pgPaperLight, borderline={.6pt}{0pt}{pgKhaki},
  left=29mm, top=4mm, bottom=4mm, height from=27mm to 2000mm,
  overlay unbroken and first={%
    \coordinate (pgAv) at ([xshift=14.5mm,yshift=-13.5mm]frame.north west);
    \fill[pgTeal] (pgAv) circle (10mm);
    \begin{scope}
      \clip (pgAv) circle (10mm);
      \node[inner sep=0] at ([yshift=-1mm]pgAv) {\includegraphics[width=21mm]{\pg@avatar}};
    \end{scope}
    \draw[pgGlow, line width=1.1pt] (pgAv) circle (10mm);
    \draw[pgKhaki, line width=.5pt] (pgAv) circle (11.3mm);},
  before upper={{\pgmono\bfseries\fontsize{7.5}{9}\selectfont\color{pgBrass}%
      \MakeUppercase{#1}\textcolor{pgSignal}{\,>\_}}\par\vspace{1mm}}}

% Passo a passo:  \begin{passo}{Título} ... \end{passo}
\newcounter{pgpasso}[section]
\NewTColorBox{passo}{m}{pg/base, unbreakable, colback=pgPaperLight,
  borderline={.5pt}{0pt}{pgTeal!20}, left=19mm, top=3.5mm, bottom=3.5mm,
  before skip=6pt, after skip=6pt, height from=16mm to 2000mm,
  code={\stepcounter{pgpasso}},
  overlay={%
    \fill[pgTeal] (frame.south west) rectangle ([xshift=13mm]frame.north west);
    \node[anchor=north, text=pgGlow, inner sep=0,
          font=\pgmono\bfseries\fontsize{15}{16}\selectfont]
      at ([xshift=6.5mm,yshift=-4mm]frame.north west) {\pgTwo{\value{pgpasso}}};
    \node[anchor=north, text=pgFog, inner sep=0,
          font=\pgmono\fontsize{5.5}{6}\selectfont]
      at ([xshift=6.5mm,yshift=-10.5mm]frame.north west) {PASSO};},
  before upper={{\pgmono\bfseries\color{pgTeal}#1}\par\vspace{.6mm}}}

% Ficha de ferramenta:
%   \begin{ferramenta}[recomendado,logo=zenbrowser]{Nome}{https://url}{tag1, tag2}
%   \begin{ferramenta}[goat,logo=qbittorrent]{Nome}{https://url}{tag1, tag2}
%   descrição
%   \end{ferramenta}
\newcommand\pglogo[1]{%
  \raisebox{-1.1mm}{\includegraphics[width=4.4mm,height=4.4mm]{logos/#1.png}}\hspace{1.5mm}}
\newcommand\pg@badge{}
\newcommand\pg@toollogo{}
\newcommand\pg@toollogoB{}
\tcbset{
  logo/.code={\def\pg@toollogo{#1}},
  logo2/.code={\def\pg@toollogoB{#1}},
  recomendado/.code={\def\pg@badge{%
    \node[anchor=east, fill=pgKhaki, text=pgVoid, inner xsep=2mm, inner ysep=1mm,
      font=\pgmono\bfseries\fontsize{7}{8}\selectfont]
      at ([xshift=-3mm,yshift=-4.5mm]frame.north east) {\faStar\hspace{1.2mm}RECOMENDADO};}},
  goat/.code={\def\pg@badge{%
    \node[anchor=east, fill=pgKhaki, text=pgVoid, inner xsep=2.2mm, inner ysep=1mm,
      font=\pgmono\bfseries\fontsize{7}{8}\selectfont] (pgbdg)
      at ([xshift=-3mm,yshift=-4.5mm]frame.north east) {\faCrown\hspace{1.2mm}GOAT // RECOMENDADO};
    \node[anchor=east, inner sep=0]
      at ([xshift=-1.6mm]pgbdg.west) {\includegraphics[height=7.6mm]{\pg@goat}};}},
  evite/.code={\def\pg@badge{%
    \node[anchor=east, fill=pgAlert, text=white, inner xsep=2.2mm, inner ysep=1mm,
      font=\pgmono\bfseries\fontsize{7}{8}\selectfont]
      at ([xshift=-3mm,yshift=-4.5mm]frame.north east) {\faBan\hspace{1.2mm}NÃO USAR // EVITE};}}
}
\NewTColorBox{ferramenta}{O{} m m m}{pg/base, unbreakable,
  colback=pgPaperLight, borderline={.6pt}{0pt}{pgTeal!45},
  left=4.5mm, right=4.5mm, top=11.5mm, bottom=3.5mm,
  code={\def\pg@badge{}\def\pg@toollogo{}\def\pg@toollogoB{}}, #1,
  overlay unbroken and first={%
    \fill[pgTeal] (frame.north west) rectangle ([yshift=-9mm]frame.north east);
    \fill[pgGlow] ([yshift=-9mm]frame.north west) rectangle ([yshift=-9.5mm]frame.north east);
    \ifx\pg@toollogo\@empty
      \node[anchor=west, text=pgCream, inner sep=0,
            font=\pgmono\bfseries\fontsize{11}{13}\selectfont]
        at ([xshift=4.5mm,yshift=-4.5mm]frame.north west)
        {\textcolor{pgGlow}{>}\hspace{2mm}#2};
    \else
      \node[anchor=west, inner sep=0] (pgtlogo)
        at ([xshift=3.8mm,yshift=-4.5mm]frame.north west)
        {\includegraphics[width=6.2mm,height=6.2mm]{logos/\pg@toollogo.png}};
      \ifx\pg@toollogoB\@empty
        \node[anchor=west, text=pgCream, inner sep=0,
              font=\pgmono\bfseries\fontsize{11}{13}\selectfont]
          at ([xshift=2.2mm]pgtlogo.east)
          {\textcolor{pgGlow}{>}\hspace{1.5mm}#2};
      \else
        \node[anchor=west, inner sep=0] (pgtlogoB)
          at ([xshift=1.4mm]pgtlogo.east)
          {\includegraphics[width=6.2mm,height=6.2mm]{logos/\pg@toollogoB.png}};
        \node[anchor=west, text=pgCream, inner sep=0,
              font=\pgmono\bfseries\fontsize{11}{13}\selectfont]
          at ([xshift=2.2mm]pgtlogoB.east)
          {\textcolor{pgGlow}{>}\hspace{1.5mm}#2};
      \fi
    \fi
    \pg@badge},
  before upper={{\pgtags{#4}}\hfill\pglink{#3}\par\vspace{.6mm}},
}
% Terminal (código de shell):  \begin{terminal}[título da janela] ... \end{terminal}
\lstdefinestyle{pgterm}{
  basicstyle=\pgmono\fontsize{8.6}{11.5}\selectfont\color{pgCream},
  columns=fullflexible, keepspaces=true, breaklines=true,
  breakatwhitespace=false, showstringspaces=false, upquote=true,
  extendedchars=true, tabsize=2,
  postbreak=\mbox{\textcolor{pgFog}{\ensuremath{\hookrightarrow}}\space},
  commentstyle=\color{pgFog}\itshape, morecomment=[l]{\#},
  stringstyle=\color{pgKhaki}, morestring=[b]", morestring=[b]',
  literate={\$}{{\textcolor{pgGlow}{\$}}}1
           {~}{{\textcolor{pgKhaki}{\textasciitilde}}}1
           {á}{{á}}1 {à}{{à}}1 {ã}{{ã}}1 {â}{{â}}1 {é}{{é}}1 {ê}{{ê}}1
           {í}{{í}}1 {ó}{{ó}}1 {õ}{{õ}}1 {ô}{{ô}}1 {ú}{{ú}}1 {ç}{{ç}}1
           {Á}{{Á}}1 {É}{{É}}1 {Ç}{{Ç}}1 {Ã}{{Ã}}1 {Õ}{{Õ}}1,
}
\NewTCBListing{terminal}{O{bash}}{enhanced, breakable, listing only,
  sharp corners, boxrule=0pt, frame hidden, colback=pgVoid,
  left=4.5mm, right=4.5mm, top=9.5mm, bottom=3mm,
  before skip=10pt, after skip=10pt,
  listing options={style=pgterm},
  overlay unbroken and first={%
    \fill[pgAbyss] (frame.north west) rectangle ([yshift=-6.5mm]frame.north east);
    \fill[pgGlow] (frame.north west) rectangle ([yshift=-.7mm]frame.north east);
    \foreach \c [count=\i] in {pgAlert,pgKhaki,pgGlow}
      \fill[\c] ([xshift=2.5mm+\i*3.2mm,yshift=-4.4mm]frame.north west)
         rectangle ++(1.7mm,1.7mm);
    \node[text=pgFog, font=\pgmono\fontsize{7}{8}\selectfont, inner sep=0]
      at ([yshift=-3.6mm]frame.north) {#1};
    \node[anchor=east, text=pgFog, font=\pgmono\fontsize{7}{8}\selectfont, inner sep=0]
      at ([xshift=-4mm,yshift=-3.6mm]frame.north east) {\faTerminal};}}

% Código-fonte claro:  \begin{codigo}[language=JavaScript]{arquivo.js} ... \end{codigo}
\lstdefinelanguage{JavaScript}{
  morekeywords={break,case,catch,class,const,continue,debugger,default,delete,
    do,else,export,extends,finally,for,function,if,import,in,instanceof,let,new,
    return,super,switch,this,throw,try,typeof,var,void,while,with,yield,async,
    await,of,true,false,null,undefined},
  sensitive=true, morecomment=[l]{//}, morecomment=[s]{/*}{*/},
  morestring=[b]", morestring=[b]', morestring=[b]`}
\lstdefinestyle{pgcode}{
  basicstyle=\pgmono\fontsize{8.4}{11.2}\selectfont\color{pgInk},
  columns=fullflexible, keepspaces=true, breaklines=true,
  showstringspaces=false, upquote=true, extendedchars=true, tabsize=2,
  keywordstyle=\color{pgSignal}\bfseries,
  stringstyle=\color{pgBrass},
  commentstyle=\color{pgMuted}\itshape,
  numbers=left, numberstyle=\pgmono\fontsize{6.5}{8}\selectfont\color{pgTeal!40},
  numbersep=4mm, xleftmargin=4mm,
  literate={á}{{á}}1 {à}{{à}}1 {ã}{{ã}}1 {â}{{â}}1 {é}{{é}}1 {ê}{{ê}}1
           {í}{{í}}1 {ó}{{ó}}1 {õ}{{õ}}1 {ô}{{ô}}1 {ú}{{ú}}1 {ç}{{ç}}1,
}
\NewTCBListing{codigo}{O{} m}{enhanced, breakable, listing only,
  sharp corners, boxrule=0pt, frame hidden, colback=pgPaperDark,
  borderline north={.6pt}{0pt}{pgTeal!30}, borderline south={.6pt}{0pt}{pgTeal!30},
  left=4mm, right=4mm, top=9mm, bottom=2.5mm,
  before skip=10pt, after skip=10pt,
  listing options={style=pgcode, #1},
  overlay unbroken and first={%
    \node[anchor=north west, fill=pgTeal, text=pgCream, inner xsep=2.4mm,
          inner ysep=1.3mm, font=\pgmono\bfseries\fontsize{7.5}{8}\selectfont]
      at (frame.north west) {\faFileCode[regular]\hspace{1.6mm}#2};}}

% ---------------------------------------------------------------------
%  Tabelas:  \begin{tabela}{lXc} \cab{A} & \cab{B} \\ ... \end{tabela}
% ---------------------------------------------------------------------
\newcommand\cab[1]{\leavevmode{\pgmono\bfseries\fontsize{8}{9}\selectfont\color{pgCream}\MakeUppercase{#1}}}
\newenvironment{tabela}[1]{%
  \par\vspace{2mm}\noindent
  \renewcommand\arraystretch{1.45}%
  \setlength\tabcolsep{2.6mm}%
  \arrayrulecolor{pgTeal!35}%
  \rowcolors{2}{pgPaperLight}{pgPaperDark}%
  \small
  \tabularx{\linewidth}{#1}\rowcolor{pgTeal}}
 {\endtabularx\par\vspace{2mm}}

% ---------------------------------------------------------------------
%  Figuras
% ---------------------------------------------------------------------
\RequirePackage{caption}
\captionsetup{font={small,color=pgMuted}, labelfont={sf,bf,color=pgTeal},
  labelsep=period}
\DeclareCaptionLabelFormat{pg}{\pgmono\bfseries FIG.\,\pgTwo{\value{figure}}}
\captionsetup[figure]{labelformat=pg, labelsep=quad}

% ---------------------------------------------------------------------
%  Capa
% ---------------------------------------------------------------------
\newcommand\pg@hexline[3]{% offset  bytes  ascii
  \textcolor{pgFog}{#1}\hspace{3mm}\textcolor{pgCream!80}{#2}%
  \\}

\newcommand\capa{%
  \begingroup
  \thispagestyle{empty}%
  \pgfmathsetseed{1337}%
  \begin{tikzpicture}[remember picture, overlay]
    \coordinate (SW) at ([shift={(-1mm,-1mm)}]current page.south west);
    \coordinate (NE) at ([shift={(1mm,1mm)}]current page.north east);
    \fill[pgTeal] (SW) rectangle (NE);
    \fill[pgAbyss, opacity=.55] (current page.south west) rectangle
       ([yshift=62mm]current page.south east);
    \draw[pgCream, opacity=.045, line width=.3pt, step=6mm] (SW) grid (NE);
    % ruído hexadecimal
    \foreach \i in {1,...,46}{%
      \pgfmathsetmacro\xx{random(95,200)}%
      \pgfmathsetmacro\yy{random(110,285)}%
      \pgfmathsetmacro\hb{random(0,255)}%
      \node[text=pgGlow, opacity=.10, font=\pgmono\fontsize{7}{7}\selectfont]
        at ($(current page.south west)+(\xx mm,\yy mm)$)
        {\pgHex{\hb}};}
    % radar atrás da mascote
    \coordinate (R) at ($(current page.south east)+(-50mm,120mm)$);
    \foreach \r/\o in {28/.22,48/.16,68/.11,88/.08,108/.05,128/.035}
      \draw[pgGlow, opacity=\o, line width=.8pt] (R) circle (\r mm);
    \fill[pgGlow, opacity=.07] (R) -- ++(28:128mm) arc (28:62:128mm) -- cycle;
    \draw[pgGlow, opacity=.10, line width=.5pt]
      ($(R)+(-130mm,0)$) -- ($(R)+(130mm,0)$)
      ($(R)+(0,-130mm)$) -- ($(R)+(0,130mm)$);
    % mascote
    \node[anchor=south, inner sep=0] at ($(current page.south east)+(\pg@mascotex,\pg@mascotey)$)
      {\includegraphics[height=\pg@mascoteh]{\pg@mascote}};
    % moldura HUD
    \pg@hud{$(current page.south west)+(10mm,10mm)$}%
           {$(current page.north east)-(10mm,10mm)$}{pgGlow}{7mm}
    % topo: logo + marca
    \node[anchor=north west, inner sep=0] (logo)
      at ($(current page.north west)+(20mm,-20mm)$)
      {\includegraphics[width=24mm]{\pg@logoCream}};
    \node[anchor=west, inner sep=0, text=pgCream,
          font=\pgmono\bfseries\fontsize{12}{12}\selectfont]
      (brand) at ([xshift=4mm,yshift=2mm]logo.east) {P\,O\,U\,S\,A\,D\,A};
    \node[anchor=north west, inner sep=0, text=pgFog,
          font=\pgmono\fontsize{7}{8}\selectfont]
      at ([yshift=-1.6mm]brand.south west) {comunidade // open knowledge};
    \node[anchor=north east, inner sep=0, text=pgCream, align=right,
          font=\pgmono\fontsize{8}{11}\selectfont]
      at ($(current page.north east)+(-20mm,-21mm)$)
      {\textcolor{pgGlow}{\bfseries GUIDE\,\#\pg@numero}\\
       \pg@versao\,\textcolor{pgFog}{//}\,\pg@categoria};
    % título
    \node[anchor=north west, inner sep=0, text=pgGlow,
          font=\pgmono\bfseries\fontsize{11}{12}\selectfont]
      (kick) at ($(current page.north west)+(20mm,-70mm)$)
      {>\_\hspace{2mm}PousadaGuide};
    \node[anchor=north west, inner sep=0, text=pgCream, text width=112mm,
          align=left, font=\pgdisplay\fontsize{50}{52}\selectfont]
      (ttl) at ([yshift=-5mm]kick.south west)
      {\pg@nohyph\pg@titulo\hspace{3mm}\pgcursor\par};
    \node[anchor=north west, inner sep=0, text=pgCream!85, text width=95mm,
          align=left, font=\pgdisplaylight\fontsize{14}{18}\selectfont]
      (sub) at ([yshift=-6mm]ttl.south west) {\pg@nohyph\pg@subtitulo\par};
    % hexdump (easter egg: "PousadaGuide >_" etc.)
    \node[anchor=south west, inner sep=0, align=left,
          font=\pgmono\fontsize{5.6}{8}\selectfont]
      at ($(current page.south west)+(20mm,112mm)$) {%
      \pg@hexline{00000000}{50 6f 75 73 61 64 61 47 75 69 64 65 20 3e 5f 0a}{PousadaGuide >\_.}%
      \pg@hexline{00000010}{6f 70 65 6e 2e 73 6f 75 72 63 65 2e 34 61 6c 6c}{open.source.4all}%
      \pg@hexline{00000020}{73 74 61 79 2e 73 61 66 65 2e 6f 6e 6c 69 6e 65}{stay.safe.online}};
    % rodapé de informações
    \node[anchor=south west, inner sep=0, align=left, text=pgCream,
          font=\pgmono\fontsize{8}{12}\selectfont]
      at ($(current page.south west)+(20mm,22mm)$) {%
      \textcolor{pgGlow}{\$}~cat guia.info\\
      \textcolor{pgFog}{autor\ \ :}~\pg@autor\\
      \textcolor{pgFog}{data\ \ \ :}~\pg@data\\
      \textcolor{pgFog}{licença:}~\pg@licenca};
  \end{tikzpicture}%
  \null\clearpage
  \endgroup}

% ---------------------------------------------------------------------
%  Contracapa
% ---------------------------------------------------------------------
\newcommand\contracapa{%
  \clearpage
  \begingroup
  \thispagestyle{empty}%
  \begin{tikzpicture}[remember picture, overlay]
    \coordinate (SW) at ([shift={(-1mm,-1mm)}]current page.south west);
    \coordinate (NE) at ([shift={(1mm,1mm)}]current page.north east);
    \fill[pgTeal] (SW) rectangle (NE);
    \draw[pgCream, opacity=.045, line width=.3pt, step=6mm] (SW) grid (NE);
    \coordinate (C) at ($(current page.center)+(0,35mm)$);
    \foreach \r/\o in {32/.16,52/.11,72/.07,92/.045}
      \draw[pgGlow, opacity=\o, line width=.8pt] (C) circle (\r mm);
    \node[inner sep=0] (logo) at (C) {\includegraphics[width=62mm]{\pg@logoCream}};
    \node[below=10mm of logo, text=pgCream, inner sep=0,
          font=\pgmono\bfseries\fontsize{20}{20}\selectfont] (brand)
      {P\,O\,U\,S\,A\,D\,A};
    \node[below=3mm of brand, text=pgGlow, inner sep=0,
          font=\pgmono\fontsize{9}{10}\selectfont] (tag)
      {feito pela comunidade, para a comunidade};
    \node[below=14mm of tag, text=pgCream, align=center, inner sep=0,
          font=\pgmono\fontsize{8.5}{13}\selectfont] {\pg@links};
    \pg@hud{$(current page.south west)+(10mm,10mm)$}%
           {$(current page.north east)-(10mm,10mm)$}{pgGlow}{7mm}
    \node[anchor=south, text=pgFog, align=center, inner sep=0,
          font=\pgmono\fontsize{7}{10}\selectfont]
      at ($(current page.south)+(0,20mm)$)
      {PousadaGuide \#\pg@numero\ \textcolor{pgGlow}{//}\ \pg@titulo\
       \textcolor{pgGlow}{//}\ \pg@versao\\
       distribuído sob \pg@licenca\ \textcolor{pgGlow}{//}\ compartilhe livremente};
  \end{tikzpicture}%
  \null
  \endgroup}

\endinput
