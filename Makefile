.PHONY: default build run install uninstall reinstall clean

default: run

LIBSOURCES = \
  mv_naive_percentile.mli mv_naive_percentile.ml \
  mv_naive_mean.mli mv_naive_mean.ml \
  mv_avg.mli mv_avg.ml \
	mv_var.mli mv_var.ml \
	mv_percentile.mli mv_percentile.ml \
  mv_adapt.ml \
  mv_adapt_avg.ml

build:
	ocamlfind ocamlc -a -o moving-percentile.cma -bin-annot $(LIBSOURCES)
	ocamlfind ocamlopt -a -o moving-percentile.cmxa -bin-annot $(LIBSOURCES)
	ocamlfind ocamlopt -o perc -bin-annot moving-percentile.cmxa perc_main.ml
	ocamlfind ocamlopt -o adapt -bin-annot moving-percentile.cmxa adapt_main.ml

run: build
	./perc < data/various.csv > data/various.out.csv
	./adapt > data/adapt.out.csv

META: META.in
	cp META.in META

install: META
	ocamlfind install moving-percentile META \
		`ls *.cm[ioxa] *.cmx[as] *.o *.a *.mli | grep -F -v '_main.'`

uninstall:
	ocamlfind remove moving-percentile

reinstall:
	$(MAKE) uninstall; $(MAKE) install

clean:
	rm -f *~ *.cm[ioxa] *.cmx[as] *.o *.a *.annot perc adapt
