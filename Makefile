CLEAN_FILES := $(foreach file,GPATH GRTAGS GTAGS TAGS,test/fixture/gtags/$(file))

INSTALL_ARGS :=

SHELLCHECK_OPTS := -s bash -e SC1090
SHELLCHECK_DOCKER_IMAGE := koalaman/shellcheck:stable

TEST_RUNNER := test/support/runner.sh
TEST_FILES := $(wildcard test/*-test.sh)
TEST_BASH_DOCKER_IMAGES := bash!5 bash!4.4
TEST_GTAGS_DOCKER_IMAGE := debian!11

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
test-docker: test-bash-docker test-gtags-docker

.PHONY: test-bash-docker
test-bash-docker: $(TEST_BASH_DOCKER_IMAGES)

.PHONY: $(TEST_BASH_DOCKER_IMAGES)
$(TEST_BASH_DOCKER_IMAGES):
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/dotfiles" \
	    -w /dotfiles \
	    -e SHELL=/usr/local/bin/bash \
	    $(subst !,:,$@) \
	    bash -c "$(subst $(newline),; ,$(test_bash_docker_cmds))"

.PHONY: test-gtags-docker
test-gtags-docker:
	docker run \
	  --rm \
	  -t \
	    -v "$(CURDIR):/dotfiles" \
	    -w /dotfiles \
	    -e SHELL=/bin/bash \
	    $(subst !,:,$(TEST_GTAGS_DOCKER_IMAGE)) \
	    bash -c "$(subst $(newline),; ,$(test_gtags_docker_cmds))"

define newline


endef

define test_bash_docker_cmds
set -x
./install.sh -f $(INSTALL_ARGS)
$(TEST_RUNNER) $(TEST_FILES)
endef

define test_gtags_docker_cmds
set -x
apt-get update
apt-get install --yes --no-install-recommends --quiet make universal-ctags python3-pygments global
./install.sh -f $(INSTALL_ARGS)
bash --login -c '$(TEST_RUNNER) test/gtags-test.sh'
endef

define help_text
Targets:

  help                Show this guide
  clean               Remove test artifacts
  install             Install dotfiles; for more options, see \`make install INSTALL_ARGS=-h\`
  lint                Run ShellCheck on source files
  lint-docker         Run ShellCheck on source files in a Docker container
  test                Run tests (requires install) (select: TEST_FILES=test/*-test.sh)
  test-docker         Run tests in Docker containers
  test-bash-docker    Run Bash specific tests in Docker containers
  test-gtags-docker   Run Bash specific tests in Docker containers
endef
