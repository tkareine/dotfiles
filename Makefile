CLEAN_FILES ?= $(foreach file,GPATH GRTAGS GTAGS TAGS,test/fixture/gtags/$(file))

INSTALL_ARGS ?=

TEST_FILES ?= $(wildcard test/unit/*_test.sh test/integration/*_test.sh)

.PHONY: help
help: SHELL := bash
help:
	@echo -e "$(subst $(newline),\n,$(help_text))"

.PHONY: install
install:
	./install.sh $(INSTALL_ARGS)

.PHONY: clean
clean:
	rm -f $(CLEAN_FILES)

.PHONY: lint
help: SHELL := bash
lint:
	shellcheck $$(< .shellcheck-files)

.PHONY: test
test:
	$(foreach test,$(TEST_FILES),./$(test)$(newline))

define newline


endef

define help_text
Targets:

  help     Show this guide
  clean    Remove test artifacts
  install  Install dotfiles; for more options, see \`make install INSTALL_ARGS=-h\`
  lint     Run shellcheck on source files
  test     Run tests (requires install)
endef
