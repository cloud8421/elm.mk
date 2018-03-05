# GENERAL PLUMBING

NPM_BIN := ./node_modules/.bin

# COLORS

GREEN  := $(shell tput -Txterm setaf 2)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

# SUPPORT

HELP_FUN = \
					 %help; \
					 while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
					 print "usage: make [target]\n\n"; \
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

all: $(ELM) ##@main Compiles entire project
.PHONY: all

help: ##@other Displays this help text
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)
.PHONY: help

repl: $(ELM) ##@main Opens an Elm repl session
	$(ELM) repl
.PHONY: repl

# SUPPORT TARGETS

$(ELM):
	@npm install --silent --no-save elm@${ELM_VERSION}
