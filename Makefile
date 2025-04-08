CLEAN_FILES := $(foreach file,GPATH GRTAGS GTAGS TAGS,test/fixture/gtags/$(file))

INSTALL_ARGS :=

SHELLCHECK_OPTS := -s bash -e SC1090
SHELLCHECK_DOCKER_IMAGE := koalaman/shellcheck:stable

RUBOCOP_CONFIG_FILE := .rubocop.yml
RUBOCOP_DOCKER_IMAGE := ruby:3

TEST_RUNNER := test/support/runner.sh
TEST_FILES := $(wildcard test/*-test.sh)
TEST_BASH_FILES := $(wildcard test/bash*-test.sh)
TEST_BASH_DOCKER_IMAGES := bash!5 bash!4.4
TEST_DEBIAN_FILES := test/gtags-test.sh test/yaml2json-test.sh
TEST_DEBIAN_DOCKER_IMAGE := debian!11

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
lint: lint-shellcheck lint-rubocop

.PHONY: lint-docker
lint-docker: lint-shellcheck-docker lint-rubocop-docker

.PHONY: lint-shellcheck
lint-shellcheck: SHELL := bash
lint-shellcheck:
	shellcheck $$(< .shellcheck-files)

.PHONY: lint-shellcheck-docker
lint-shellcheck-docker: SHELL := bash
lint-shellcheck-docker:
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/dotfiles:ro" \
	    -w /dotfiles \
	    -e SHELLCHECK_OPTS="$(SHELLCHECK_OPTS)" \
	    $(SHELLCHECK_DOCKER_IMAGE) \
	    $$(< .shellcheck-files)

.PHONY: lint-rubocop
lint-rubocop: SHELL := bash
lint-rubocop:
	rubocop --config $(CURDIR)/$(RUBOCOP_CONFIG_FILE) $$(< .rubocop-files)

.PHONY: lint-rubocop-docker
lint-rubocop-docker:
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/dotfiles:ro" \
	    -w /dotfiles \
	    $(RUBOCOP_DOCKER_IMAGE) \
	    sh -c "$(subst $(newline),; ,$(test_rubocop_docker_cmds))"

.PHONY: test
test:
	$(TEST_RUNNER) $(TEST_FILES)

.PHONY: test-docker
test-docker: test-bash-docker test-debian-docker

.PHONY: test-bash-docker
test-bash-docker: $(TEST_BASH_DOCKER_IMAGES)

.PHONY: $(TEST_BASH_DOCKER_IMAGES)
$(TEST_BASH_DOCKER_IMAGES):
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/dotfiles:ro" \
	    -w /dotfiles \
	    -e SHELL=/usr/local/bin/bash \
	    $(subst !,:,$@) \
	    bash -c "$(subst $(newline),; ,$(test_bash_docker_cmds))"

.PHONY: test-debian-docker
test-debian-docker:
	docker run \
	    --rm \
	    -t \
	    -v "$(CURDIR):/dotfiles:ro" \
	    -v "$(CURDIR)/test/fixture:/dotfiles/test/fixture" \
	    -w /dotfiles \
	    -e SHELL=/bin/bash \
	    $(subst !,:,$(TEST_DEBIAN_DOCKER_IMAGE)) \
	    bash -c "$(subst $(newline),; ,$(test_debian_docker_cmds))"

define newline


endef

define test_rubocop_docker_cmds
set -x
gem install rubocop
rubocop --config /dotfiles/$(RUBOCOP_CONFIG_FILE) $$(tr '\n' ' ' < .rubocop-files)
endef

define test_bash_docker_cmds
set -x
./install.sh -f $(INSTALL_ARGS)
$(TEST_RUNNER) $(TEST_BASH_FILES)
endef

define test_debian_docker_cmds
set -x
apt-get update
apt-get install --yes --no-install-recommends --quiet make universal-ctags python3-pygments global ruby
./install.sh -f $(INSTALL_ARGS)
bash --login -c '$(TEST_RUNNER) $(TEST_DEBIAN_FILES)'
endef

define help_text
Targets:

  help                    Show this guide

  clean                   Remove test artifacts

  install                 Install dotfiles; for more options, see \`make install INSTALL_ARGS=-h\`

  lint                    Run linters on source files
  lint-docker             Run linters on source files in a Docker container
  lint-shellcheck         Run ShellCheck on source files
  lint-shellcheck-docker  Run ShellCheck on source files in a Docker container
  lint-rubocop            Run RuboCop on source files
  lint-rubocop-docker     Run RuboCop on source files in a Docker container

  test                    Run tests (requires install) (select: TEST_FILES=test/*-test.sh)
  test-docker             Run tests in Docker containers
  test-bash-docker        Run Bash specific tests in Docker containers
  test-debian-docker      Run tests requiring complex dependencies in a Docker container
endef
