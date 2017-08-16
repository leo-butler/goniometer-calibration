
OCTAVE_TAGS	:= octave.tags
TAGS_REGEXP	:=$(shell perl -wnl -e '!/[ \t]*--/ and print' $(OCTAVE_TAGS))
TAGS_FILE	:= TAGS
INTERSECTION_LINE_TGZ := intersection_line.tar.gz
INTERSECTION_LINE_DEPS:= Makefile objectivefn.m line_estimator_error.m make_almost_planar_data.m line_plot.m octave.tags randstate.m ifelse.m read_goniometer_data.m goniometer.m
DATA		:= dir-/deg_0.csv dir+/deg_0-xyz.csv dir-/deg-45.csv dir-/deg+45.csv dir/deg-45.csv dir/deg+45.csv dir+/deg+45-xyz.csv dir+/deg-45-zyx.csv
RES             := mc+gc5.dat
RES             += direction-vector-dist-pooled-equal.svg euler-angle-dist.svg gc-radius.svg mc-euler-angle-dist.svg mc-radius.svg


.PHONY: all
all: res

.PHONY: res
res: res/mc+gc5.dat
	sed -i 1d $< # remove header (containing timestamp) for consistent checksums

$(addprefix res/,$(RES)) : $(DATA)
	octave-cli gc_eval.m            `# CLS-eval, plots` \
		"dir-/deg[+-]*.csv"     `# clockwise` \
		"dir+/deg[+-]*.csv"     `# anti-clockwise` \
		"dir[-+]/deg[+-]*.csv"  `# pooled-a` \
		"dir/deg[+-]*.csv"      `# pooled-b`

.PHONY: TAGS
TAGS:
	etags --language=none --regex=@$(OCTAVE_TAGS) -o $(TAGS_FILE) *.m

.PNONY: intersection-line
intersection-line:
	tar cvfz $(INTERSECTION_LINE_TGZ) $(INTERSECTION_LINE_DEPS)

.PHONY: clean
clean:
	rm -f *.aux *.log *.dvi *.blg *.bbl _region_.* Comments.* *~ *date
