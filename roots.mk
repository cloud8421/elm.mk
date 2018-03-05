# GENERAL PLUMBING

NPM_BIN = ./node_modules/.bin

# ELM COMPILER

ELM_VERSION = 0.18
ELM = $(NPM_BIN)/elm

all: $(ELM)
.PHONY: all

$(ELM):
	npm install --no-save elm@${ELM_VERSION}
