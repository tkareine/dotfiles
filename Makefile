CLEAN_FILES := $(foreach file,GPATH GRTAGS GTAGS TAGS,test/fixture/gtags/$(file))

INSTALL_ARGS :=

SHELLCHECK_OPTS := -s bash -e SC1090
SHELLCHECK_DOCKER_IMAGE := koalaman/shellcheck:stable

TEST_RUNNER := test/support/runner.sh
TEST_FILES := $(wildcard test/*-test.sh)
TEST_DOCKER_IMAGES := bash!5 bash!4.4

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
lint: SHELL := bash
lint:
	shellcheck $$(< .shellcheck-files)

.PHONY: lint-docker
lint-docker: SHELL := bash
lint-docker:
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/dotfiles" \
	    -w /dotfiles \
	    -e SHELLCHECK_OPTS="$(SHELLCHECK_OPTS)" \
	    $(SHELLCHECK_DOCKER_IMAGE) \
	    $$(< .shellcheck-files)

.PHONY: test
test:
	$(TEST_RUNNER) $(TEST_FILES)

.PHONY: test-docker
test-docker: $(TEST_DOCKER_IMAGES)

.PHONY: $(TEST_DOCKER_IMAGES)
$(TEST_DOCKER_IMAGES):
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/dotfiles" \
	    -w /dotfiles \
	    -e SHELL=/usr/local/bin/bash \
	    $(subst !,:,$@) \
	    bash -c "$(subst $(newline),; ,$(test_docker_cmds))"

define newline


endef

define test_docker_cmds
./install.sh $(INSTALL_ARGS)
$(TEST_RUNNER) $(TEST_FILES)
endef

define help_text
Targets:

  help         Show this guide
  clean        Remove test artifacts
  install      Install dotfiles; for more options, see \`make install INSTALL_ARGS=-h\`
  lint         Run ShellCheck on source files
  lint-docker  Run ShellCheck on source files in a Docker container
  test         Run tests (requires install) (select: TEST_FILES=test/*-test.sh)
  test-docker  Run tests with various Bash versions in Docker containers
endef
