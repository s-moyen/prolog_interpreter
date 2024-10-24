OCAMLC = ocamlc
CMO = .cmo
CMA = .cma

default: term_mod unify_mod query_mod 
	$(OCAMLC) -o bin/main -I bin/ src/main.ml bin/term.cmo bin/unify.cmo bin/query.cmo

term_mod:
	$(OCAMLC) -o bin/term -a src/term.mli 
	mv src/term.cmi bin/term.cmi
	$(OCAMLC) -I bin/ -c src/term.ml -o bin/term

unify_mod: term_mod
	$(OCAMLC) -I bin/ -o bin/unify -a src/term.mli src/unify.mli 
	mv src/unify.cmi bin/unify.cmi
	$(OCAMLC) -I bin/ -c src/unify.ml -o bin/unify

query_mod:
	$(OCAMLC) -I bin/ -o bin/query -a src/query.mli 
	mv src/query.cmi bin/query.cmi
	$(OCAMLC) -I bin/ -c src/query.ml -o bin/query

test: term_mod unify_mod
	$(OCAMLC) -I bin/ -c src/test.ml -o bin/test.cmo

.PHONY clean:
	rm -f bin/*.cmo bin/*.cmi bin/term bin/unify