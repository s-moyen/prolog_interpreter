OCAMLC = ocamlc
CMO = .cmo
CMA = .cma

default: term_mod unify query inferatrice

term_mod:
	$(OCAMLC) -o bin/term -a src/term.mli 
	mv src/term.cmi bin/term.cmi
	$(OCAMLC) -I bin/ -c src/term.ml -o bin/term

unify_mod:
	$(OCAMLC) -o bin/unify -a src/unify.mli 
	mv src/unify.cmi bin/unify.cmi
	$(OCAMLC) -I bin/ -c src/unify.ml -o bin/unify


test: term_mod unify_mod
	$(OCAMLC) -I bin/ -c src/test.mli -o bin/test.cmi

.PHONY clean:
	rm -f bin/*.cmo bin/*.cmi bin/term bin/unify