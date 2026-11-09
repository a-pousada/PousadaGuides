# =====================================================================
#  PousadaGuides -- build
#
#  make              -> compila todos os guias (Piracy + Privacy + Bitcoin + exemplo)
#  make piracy       -> compila Piracy/piracy.tex
#  make privacy      -> compila Privacy/privacy.tex
#  make bitcoin      -> compila Bitcoin/bitcoin.tex
#  make exemplo      -> compila exemplo.tex
#  make print        -> versões para impressão (fundo branco)
#  make dist         -> gera os PDFs finais em dist/ (o que vai pra release)
#  make banner       -> regenera os banners em docs/ (geral e por guia)
#  make previews     -> regenera as prévias de página em docs/previews/
#  make clean        -> limpa arquivos temporários
#
#  Motor: usa latexmk (TeX Live) se existir, senão tectonic.
#  Force com:  make ENGINE=tectonic
# =====================================================================
ENGINE ?= $(if $(shell command -v latexmk 2>/dev/null),latexmk,tectonic)
PDFTOPPM ?= pdftoppm

# compile <pasta> <arquivo sem .tex>
ifeq ($(ENGINE),latexmk)
compile = cd $(1) && latexmk -xelatex -interaction=nonstopmode $(2).tex
else
compile = cd $(1) && tectonic $(2).tex
endif

# gera a variante [print] de um .tex e compila
print-variant = sed 's/\\documentclass{pousadaguide}/\\documentclass[print]{pousadaguide}/' \
	$(1)/$(2).tex > $(1)/$(2)-print.tex && \
	( $(call compile,$(1),$(2)-print) ); status=$$?; rm -f $(1)/$(2)-print.tex; exit $$status

.PHONY: guias all piracy privacy bitcoin exemplo print dist banner previews clean
guias all: piracy privacy bitcoin exemplo

piracy:
	$(call compile,Piracy,piracy)

privacy:
	$(call compile,Privacy,privacy)

bitcoin:
	$(call compile,Bitcoin,bitcoin)

exemplo:
	$(call compile,.,exemplo)

print:
	$(call print-variant,Piracy,piracy)
	$(call print-variant,Privacy,privacy)
	$(call print-variant,Bitcoin,bitcoin)

dist: guias print
	@mkdir -p dist
	cp Piracy/piracy.pdf         dist/PousadaGuide-01-Piracy.pdf
	cp Piracy/piracy-print.pdf   dist/PousadaGuide-01-Piracy-impressao.pdf
	cp Privacy/privacy.pdf       dist/PousadaGuide-02-Privacy.pdf
	cp Privacy/privacy-print.pdf dist/PousadaGuide-02-Privacy-impressao.pdf
	cp Bitcoin/bitcoin.pdf       dist/PousadaGuide-03-Bitcoin.pdf
	cp Bitcoin/bitcoin-print.pdf dist/PousadaGuide-03-Bitcoin-impressao.pdf
	cp exemplo.pdf               dist/PousadaGuide-00-Exemplo.pdf
	@echo && ls -lh dist

banner:
	$(call compile,docs/banner,banner)
	$(PDFTOPPM) -png -r 144 -singlefile docs/banner/banner.pdf docs/banner
	$(PDFTOPPM) -png -r 72  -singlefile docs/banner/banner.pdf docs/social-preview
	rm -f docs/banner/banner.pdf docs/banner/*.aux docs/banner/*.log
	$(call compile,docs/banner,banner-piracy)
	$(PDFTOPPM) -png -r 144 -singlefile docs/banner/banner-piracy.pdf docs/banner-piracy
	rm -f docs/banner/banner-piracy.pdf docs/banner/*.aux docs/banner/*.log
	$(call compile,docs/banner,banner-privacy)
	$(PDFTOPPM) -png -r 144 -singlefile docs/banner/banner-privacy.pdf docs/banner-privacy
	rm -f docs/banner/banner-privacy.pdf docs/banner/*.aux docs/banner/*.log
	$(call compile,docs/banner,banner-bitcoin)
	$(PDFTOPPM) -png -r 144 -singlefile docs/banner/banner-bitcoin.pdf docs/banner-bitcoin
	rm -f docs/banner/banner-bitcoin.pdf docs/banner/*.aux docs/banner/*.log

previews: piracy privacy bitcoin
	@mkdir -p docs/previews
	$(PDFTOPPM) -png -r 100 -f 1  -l 1  -singlefile Piracy/piracy.pdf docs/previews/piracy-capa
	$(PDFTOPPM) -png -r 100 -f 2  -l 2  -singlefile Piracy/piracy.pdf docs/previews/piracy-sumario
	$(PDFTOPPM) -png -r 100 -f 16 -l 16 -singlefile Piracy/piracy.pdf docs/previews/piracy-ferramentas
	$(PDFTOPPM) -png -r 100 -f 1  -l 1  -singlefile Privacy/privacy.pdf docs/previews/privacy-capa
	$(PDFTOPPM) -png -r 100 -f 2  -l 2  -singlefile Privacy/privacy.pdf docs/previews/privacy-sumario
	$(PDFTOPPM) -png -r 100 -f 8  -l 8  -singlefile Privacy/privacy.pdf docs/previews/privacy-ferramentas
	$(PDFTOPPM) -png -r 100 -f 1  -l 1  -singlefile Bitcoin/bitcoin.pdf docs/previews/bitcoin-capa
	$(PDFTOPPM) -png -r 100 -f 2  -l 2  -singlefile Bitcoin/bitcoin.pdf docs/previews/bitcoin-sumario
	$(PDFTOPPM) -png -r 100 -f 10 -l 10 -singlefile Bitcoin/bitcoin.pdf docs/previews/bitcoin-ferramentas

clean:
	-latexmk -C 2>/dev/null
	rm -f *.aux *.log *.out *.toc *.fls *.fdb_latexmk *.xdv *.synctex.gz exemplo.pdf
	rm -rf dist
	@$(MAKE) -C Piracy clean 2>/dev/null || true
	@$(MAKE) -C Privacy clean 2>/dev/null || true
	@$(MAKE) -C Bitcoin clean 2>/dev/null || true
