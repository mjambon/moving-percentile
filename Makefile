.PHONY: default demo clean

default: demo

demo:
	ocamlopt -o demo -annot \
    percentile.mli percentile.ml \
    moving_average.mli moving_average.ml \
    moving_variance.mli moving_variance.ml \
    moving_percentile.mli moving_percentile.ml \
    demo_main.ml
	./demo < data/various.csv > data/various.out.csv

clean:
	rm -f *~ *.cm[ioxa] *.cmx[as] *.o *.a *.annot demo
