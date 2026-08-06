# Encaminha para o Makefile da raiz do monorepo.
# Assim `make aab` funciona de dentro de trilha_app/.

.PHONY: %
%:
	@$(MAKE) -C .. $@
