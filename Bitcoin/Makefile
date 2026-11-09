# PousadaGuide #03 -- Bitcoin Guide
# make          -> compila bitcoin.tex
# make print    -> versão para impressão (fundo branco)
DOC ?= bitcoin

pdf:
	@if command -v latexmk >/dev/null; then latexmk $(DOC).tex; \
	else tectonic $(DOC).tex; fi

print:
	@sed 's/\\documentclass{pousadaguide}/\\documentclass[print]{pousadaguide}/' $(DOC).tex > $(DOC)-print.tex
	@if command -v latexmk >/dev/null; then latexmk $(DOC)-print.tex; \
	else tectonic $(DOC)-print.tex; fi
	@rm -f $(DOC)-print.tex

clean:
	-latexmk -C 2>/dev/null; rm -f *.aux *.log *.out *.toc *.fls *.fdb_latexmk *.xdv *.synctex.gz

.PHONY: pdf print clean
