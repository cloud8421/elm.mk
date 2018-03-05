# GENERAL PLUMBING

NPM_BIN = ./node_modules/.bin

# ELM COMPILER

ELM_VERSION = 0.18
ELM = $(NPM_BIN)/elm

# MAIN TARGETS

all: $(ELM)
.PHONY: all

repl: $(ELM)
	$(ELM) repl
.PHONY: repl

# SUPPORT TARGETS

$(ELM):
	npm install --no-save elm@${ELM_VERSION}
