SHELL := bash  # required for `help` target
INSTALL_ARGS ?=

.PHONY: help
help:
	@echo -e '$(subst $(newline),\n,$(help_text))'

.PHONY: install
install:
	./install.sh $(INSTALL_ARGS)

.PHONY: clean
clean:
	cd test && rm -f GPATH GRTAGS GTAGS

.PHONY: test
test:
	cd test && for t in *_test.sh; do "./$$t"; done

define newline


endef

define help_text
Targets:

  help     Show this guide.
  clean    Remove test artifacts.
  install  Install dotfiles. For more options, see `make install INSTALL_ARGS=-h`.
  test     Run tests (requires install).
endef
