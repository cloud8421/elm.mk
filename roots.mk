# GENERAL PLUMBING

NPM_BIN := ./node_modules/.bin

# COLORS

GREEN  := $(shell tput -Txterm setaf 2)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

# SUPPORT

lazy_tpl = @test -s $@ || echo $1 > $@ # renders a template for the target unless file is there already
help_fun = \
					 %help; \
					 while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
					 print "${help_text}"; \
					 for (sort keys %help) { \
					 print "${WHITE}$$_:${RESET}\n"; \
					 for (@{$$help{$$_}}) { \
					 $$sep = " " x (32 - length $$_->[0]); \
					 print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
					 }; \
					 print "\n"; }

# ELM COMPILER

ELM_VERSION := 0.18
ELM := $(NPM_BIN)/elm

# MAIN TARGETS

COMPILE_TARGETS := $(ELM) \
	elm-package.json

all: $(COMPILE_TARGETS) ##@Main Compiles entire project
.PHONY: all

help: ##@Other Displays this help text
	@perl -e '$(help_fun)' $(MAKEFILE_LIST)
.PHONY: help

repl: $(ELM) ##@Main Opens an Elm repl session
	$(ELM) repl
.PHONY: repl

# SUPPORT TARGETS

$(ELM):
	@npm install --silent --no-save elm@${ELM_VERSION}

elm-package.json:
	$(call lazy_tpl,"$$elm_package_json")

# TEMPLATES

define help_text
Roots - a simple toolchain for Elm projects\n\nAvailable tasks:\n\n
endef
export help_text

define elm_package_json
{
    "version": "1.0.0",
    "summary": "helpful summary of your project, less than 80 characters",
    "repository": "https://github.com/user/project.git",
    "license": "BSD3",
    "source-directories": [
        "src",
        "test"
    ],
    "exposed-modules": [],
    "dependencies": {
        "elm-lang/core": "5.0.0 <= v < 6.0.0",
        "elm-lang/html": "2.0.0 <= v < 3.0.0",
        "elm-lang/http": "1.0.0 <= v < 2.0.0"
    },
    "elm-version": "0.18.0 <= v < 0.19.0"
}
endef
export elm_package_json
