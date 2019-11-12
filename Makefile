FILES = \
	lib/cut.pl \
	lib/filter.pl \
	lib/libattrib.pl \
	lib/add_column.pl \
	lib/body.pl \
	lib/gxw2consensus.pl \
	lib/libstats.pl \
	lib/tab2feature_gxt.pl \
	lib/modify_column.pl \
	lib/join.pl \
	lib/libset.pl \
	lib/gxw2stats.pl \
	lib/stab2fasta.pl \
	lib/genie_helpers.pl \
	lib/fasta2stab.pl \
	lib/to_upper_case.pl \
	lib/libfile.pl \
	lib/bind.pl \
	lib/libtable.pl \
	lib/transpose.pl \
	nucleosome_prediction.pl

CURR_DIR = $(shell pwd | sed 's/\//\\\//g')

install:
	$(foreach file, $(FILES), \
		mv $(file) tmp; \
		sed 's/EXE_BASE_DIR/$(CURR_DIR)/g' tmp > $(file); \
		rm -f tmp; \
	)
	chmod -R 755 lib bin nucleosome_prediction.pl; \
	chmod 777  models templates; \
	chmod 644 models/* templates/* ; \
