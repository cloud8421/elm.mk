# GENERAL PLUMBING

BIN := ./bin
NPM_BIN := ./node_modules/.bin
ELM_SRC := ./src
ELM_SRC_FILES = $(shell find $(ELM_SRC) -type f -name '*.elm' 2>/dev/null)
BUILD := ./build

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

# MUSTACHE TEMPLATES

MO := $(BIN)/mo
MO_URL := "https://raw.githubusercontent.com/tests-always-included/mo/master/mo"

# ELM COMPILER

ELM_VERSION := 0.18
ELM := $(NPM_BIN)/elm

# MAIN TARGETS

SUPPORT_TARGETS := Makefile \
	.gitignore \
	elm-package.json

TOOL_TARGETS := $(MO) $(ELM)

APPLICATION_TARGETS := index.html \
	$(ELM_SRC)/Types.elm \
	$(ELM_SRC)/State.elm \
	$(ELM_SRC)/View.elm \
	$(ELM_SRC)/Main.elm

BUILD_TARGETS := $(BUILD)/main.js \
								 $(BUILD)/index.html

COMPILE_TARGETS := $(TOOL_TARGETS) $(SUPPORT_TARGETS) $(APPLICATION_TARGETS) $(BUILD_TARGETS)

all: $(COMPILE_TARGETS) ##@Main Compiles entire project
.PHONY: all

help: ##@Other Displays this help text
	@perl -e '$(help_fun)' $(MAKEFILE_LIST)
.PHONY: help

repl: $(ELM) ##@Main Opens an Elm repl session
	$(ELM) repl
.PHONY: repl

# TOOL TARGETS

$(BIN):
	mkdir -p $@

$(MO): $(BIN)
	curl $(MO_URL) -L -o $@
	chmod +x $@

$(ELM):
	@npm install --silent --no-save elm@${ELM_VERSION}

# SUPPORT TARGETS

Makefile:
	$(call lazy_tpl,"$$Makefile")

.gitignore:
	$(call lazy_tpl,"$$gitignore")

elm-package.json:
	$(call lazy_tpl,"$$elm_package_json")

# APPLICATION TARGETS

$(ELM_SRC):
	mkdir -p $@

index.html:
	$(call lazy_tpl,"$$index_html")

$(ELM_SRC)/Types.elm: $(ELM_SRC)
	$(call lazy_tpl,"$$elm_types")

$(ELM_SRC)/State.elm: $(ELM_SRC)
	$(call lazy_tpl,"$$elm_state")

$(ELM_SRC)/View.elm: $(ELM_SRC)
	$(call lazy_tpl,"$$elm_view")

$(ELM_SRC)/Main.elm: $(ELM_SRC)
	$(call lazy_tpl,"$$elm_main")

# BUILD TARGETS

$(BUILD):
	mkdir -p $@

$(BUILD)/index.html: $(BUILD) index.html
	main_js=/main.js $(MO) index.html > $@

$(BUILD)/main.js: $(BUILD) $(ELM_SRC_FILES)
	$(ELM)-make $(ELM_SRC)/Main.elm --yes --warn --output $@

# TEMPLATES

define help_text
Roots - a simple toolchain for Elm projects\n\nAvailable tasks:\n\n
endef
export help_text

define Makefile
include roots.mk
endef
export Makefile

define gitignore
node_modules
elm-stuff
elm.js
endef
export gitignore

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

define index_html
<!DOCTYPE HTML>
<html>
<head>
  <meta charset="UTF-8">
  <title>Elm Project</title>
</head>
<body>
  <h1>Loading...</h1>
</body>
<script type="text/javascript" src="{{main_js}}"></script>
</html>
endef
export index_html

define elm_types
module Types exposing (..)


type Msg
    = NoOp


type alias Model =
    Int

endef
export elm_types

define elm_state
module State exposing (..)

import Types exposing (..)


init : ( Model, Cmd Msg )
init =
    0 ! []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

endef
export elm_state

define elm_view
module View exposing (..)

import Html exposing (Html, div, text)
import Types exposing (..)


root : Model -> Html Msg
root model =
    div []
        [ model |> toString |> text ]

endef
export elm_view

define elm_main
module Main exposing (..)

import Html
import Platform.Sub as Sub
import State
import Types exposing (..)
import View


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = State.init
        , view = View.root
        , update = State.update
        , subscriptions = subscriptions
        }

endef
export elm_main
