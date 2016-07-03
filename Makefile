.PHONY: default demo clean

default: demo

demo:
	ocamlopt -o demo -annot \
    moving_percentile.mli moving_percentile.ml demo_main.ml
	./demo < data/uniform.csv > uniform.out

clean:
	rm -f *~ *.cm[ioxa] *.cmx[as] *.o *.a *.annot *.out demo
