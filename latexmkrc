# latexmk: usa XeLaTeX por padrão
$pdf_mode = 5;          # 5 = xelatex
$xelatex = 'xelatex -interaction=nonstopmode -synctex=1 %O %S';
$clean_ext = 'synctex.gz xdv';
