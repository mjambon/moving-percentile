.PHONY: default build run install uninstall reinstall clean

default: run

LIBSOURCES = \
  percentile.mli percentile.ml \
  mv_avg.mli mv_avg.ml \
	mv_var.mli mv_var.ml \
	mv_percentile.mli mv_percentile.ml \
  mv_adapt.ml \
  mv_adapt_avg.ml

build:
	ocamlfind ocamlc -a -o moving-percentile.cma -annot $(LIBSOURCES)
	ocamlfind ocamlopt -a -o moving-percentile.cmxa -annot $(LIBSOURCES)
	ocamlfind ocamlopt -o demo -annot moving-percentile.cmxa demo_main.ml

run: build
	./demo < data/various.csv > data/various.out.csv

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
	rm -f *~ *.cm[ioxa] *.cmx[as] *.o *.a *.annot demo
