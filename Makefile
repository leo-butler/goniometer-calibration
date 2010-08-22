
OCTAVE_TAGS	:= octave.tags
TAGS_REGEXP	:=$(shell perl -wnl -e '!/[ \t]*--/ and print' $(OCTAVE_TAGS))
TAGS_FILE	:= TAGS
INTERSECTION_LINE_TGZ := intersection_line.tar.gz
INTERSECTION_LINE_DEPS:= Makefile objectivefn.m line_estimator_error.m make_almost_planar_data.m line_plot.m octave.tags randstate.m ifelse.m read_goniometer_data.m goniometer.m
SRC		:= gc
SRC_DEPS	:= $(shell sed -n -e '/\\input\|\\include/{s/\(\\input\|\\include.*\){\+\(.\+\)}\+/\2/g;p;}' $(SRC).tex)
LATEX		:= latex
TEX		:= $(LATEX)
BIBTEX		:= bibtex -terse
MAKEINDEX	:= makeindex >/dev/null 2>/dev/null
PID		:= $(shell echo $$$$)


.PHONY: TAGS
TAGS:
	etags --language=none --regex=@$(OCTAVE_TAGS) -o $(TAGS_FILE) *.m

.PNONY: intersection-line
intersection-line:
	tar cvfz $(INTERSECTION_LINE_TGZ) $(INTERSECTION_LINE_DEPS)

.PHONY: bbl
bbl:
	make $(SRC).bbl

.PHONY: dvi
dvi:
	make $(SRC).dvi

.PHONY: pdf
pdf:
	make $(SRC).pdf

%.eps: %.fig
	fig2dev -L eps $< $@

$(SRC).pdf: $(SRC).dvi
	dvipdf $^

$(SRC).dvi: $(SRC).bbl $(SRC).uptodate $(SRC).tex $(SRC_DEPS)
	$(LATEX) $(SRC).tex

%.bbl: %.bib
	sed -e '/^[ ]*MR[CRN]/{d;}' $^ > $*-$(PID).bib
	if ! test -f $*.aux ; then $(LATEX) $*.tex ; fi
	if ! (grep -s 'bibdata' $*.aux) ; then $(LATEX) $*.tex ; fi
	cp $*.aux $*-$(PID).aux
	$(BIBTEX) $*-$(PID) || true
	rm -f $*-$(PID).bib $*-$(PID).aux
	mv $*-$(PID).blg $*.blg
	sed -e 's/\\providecommand{\\MR}.\+/\\renewcommand{\\MR}[1]{}/g' $*-$(PID).bbl > $*.bbl
	rm $*-$(PID).bbl
	touch $*.outofdate

$(SRC).uptodate : $(SRC).outofdate
	touch $(SRC).uptodate
	$(LATEX) $(SRC).tex
	rm -f $(SRC).dvi

%.aux: %.tex
	$(LATEX) $<
	rm -f $*.dvi

%.tex %.fig %.bib: ;

.PHONY: clean
clean:
	rm -f *.aux *.log *.dvi *.blg *.bbl _region_.* Comments.* *~ *date
