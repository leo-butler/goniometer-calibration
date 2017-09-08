### setting default paths of external programs
## 64-bit enabled octave:
OCTAVE?=/opt/octave-4.2.0
BLENDER?=/opt/blender-2.49b-linux-glibc236-py26-x86_64/

export PATH:= $(OCTAVE)/bin:$(PATH)
export PATH:= $(BLENDER):$(PATH)

### check existance of external programs
EXECUTABLES = octave
EXECUTABLES = blender

K:= $(foreach exec,$(EXECUTABLES),\
	$(if $(shell PATH=$(PATH) which $(exec)),some string,$(error "No $(exec) in PATH")))



OCTAVE_TAGS	:= octave.tags
TAGS_REGEXP	:=$(shell perl -wnl -e '!/[ \t]*--/ and print' $(OCTAVE_TAGS))
TAGS_FILE	:= TAGS
INTERSECTION_LINE_TGZ := intersection_line.tar.gz
INTERSECTION_LINE_DEPS:= Makefile objectivefn.m line_estimator_error.m make_almost_planar_data.m line_plot.m octave.tags randstate.m ifelse.m read_goniometer_data.m goniometer.m
DATA		:= dir-/deg_0.csv dir+/deg_0-xyz.csv dir-/deg-45.csv dir-/deg+45.csv dir/deg-45.csv dir/deg+45.csv dir+/deg+45-xyz.csv dir+/deg-45-zyx.csv
RES             := data/mc+gc5.dat
RES             += figures/direction-vector-dist-pooled-equal.svg figures/euler-angle-dist.svg figures/gc-radius.svg figures/mc-euler-angle-dist.svg figures/mc-radius.svg



.PHONY: all
all: res

.PHONY: res
res: res/data/pool_estimate_01_00.blend
res: res/data/pool_estimate_02_00.blend
res: res/data/pool_estimate_03_00.blend
res: res/data/pool_estimate_04_00.blend
res: res/figures/direction-vector-dist-pooled-equal.svg
res: res/figures/euler-angle-dist.svg
res: res/figures/gc-radius.svg
res: res/figures/mc-euler-angle-dist.svg
res: res/figures/mc-radius.svg
res: res/data/mc+gc5.dat
	sed -i '/# Created by Octave/d' $< # remove header (containing timestamp) for consistent checksums

$(addprefix res%,$(RES)) : $(DATA) # res% instead of res/ for multi-res rule
	octave-cli gc_eval.m            `# CLS-eval, plots` \
		"dir-/deg[+-]*.csv"     `# clockwise` \
		"dir+/deg[+-]*.csv"     `# anti-clockwise` \
		"dir[-+]/deg[+-]*.csv"  `# pooled-a` \
		"dir/deg[+-]*.csv"      `# pooled-b`

res/data/pool%estimate_01.bdat \
res/data/pool%estimate_02.bdat \
res/data/pool%estimate_03.bdat \
res/data/pool%estimate_04.bdat : res/data/mc+gc5.dat
	octave-cli octave2blender.m $<

res/data/%_00.blend : res/data/%.bdat blender_vis/points_cam01.blend
	blender -b $(word 2,$^) -P render_gonio-dat.py  -- -i $< -o $@ -r 0 -g .7  -b .9 -s .001

.PHONY: TAGS
TAGS:
	etags --language=none --regex=@$(OCTAVE_TAGS) -o $(TAGS_FILE) *.m

.PNONY: intersection-line
intersection-line:
	tar cvfz $(INTERSECTION_LINE_TGZ) $(INTERSECTION_LINE_DEPS)

.PHONY: clean
clean:
	rm -f *.aux *.log *.dvi *.blg *.bbl _region_.* Comments.* *~ *date
