# GENERAL PLUMBING

BIN := bin
ELM_SRC := src
SCSS_SRC := styles
ELM_SRC_FILES = $(shell find $(ELM_SRC) -type f -name '*.elm' 2>/dev/null)
SCSS_SRC_FILES = $(shell find $(SCSS_SRC) -type f -name '*.scss' 2>/dev/null)
BUILD := build
OS := $(shell uname)

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
curl := curl --silent

# DEV TOOLS

DEVD := $(BIN)/devd
ELM := $(BIN)/elm
MO := $(BIN)/mo
MODD := $(BIN)/modd
WT := $(BIN)/wt

DEVD_VERSION := 0.8
ELM_VERSION := 0.18.0
MO_VERSION := 2.0.4
MODD_VERSION := 0.5
WT_VERSION := 1.0.4

MO_URL := "https://raw.githubusercontent.com/tests-always-included/mo/${MO_VERSION}/mo"

ifeq ($(OS),Darwin)
	DEVD_URL := "https://github.com/cortesi/devd/releases/download/v${DEVD_VERSION}/devd-${DEVD_VERSION}-osx64.tgz"
	ELM_URL := "https://dl.bintray.com/elmlang/elm-platform/${ELM_VERSION}/darwin-x64.tar.gz"
	MODD_URL := "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-osx64.tgz"
	WT_URL := "https://github.com/wellington/wellington/releases/download/v${WT_VERSION}/wt_v${WT_VERSION}_darwin_amd64.tar.gz"
else
	DEVD_URL := "https://github.com/cortesi/devd/releases/download/v${DEVD_VERSION}/devd-${DEVD_VERSION}-linux64.tgz"
	ELM_URL := "https://dl.bintray.com/elmlang/elm-platform/${ELM_VERSION}/linux-x64.tar.gz"
	MODD_URL := "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-linux64.tgz"
	WT_URL := "https://github.com/wellington/wellington/releases/download/v${WT_VERSION}/wt_v${WT_VERSION}_linux_amd64.tar.gz"
endif

DEVD_OPTIONS := -m $(BUILD) -f /index.html

# MAIN TARGETS

SUPPORT_TARGETS := Makefile \
	.gitignore \
	elm-package.json \
	modd.conf

TOOL_TARGETS := $(BIN) \
	$(DEVD) \
	$(ELM) \
	$(MO) \
	$(MODD) \
	$(WT)

APPLICATION_TARGETS := index.html \
	$(ELM_SRC)/Types.elm \
	$(ELM_SRC)/State.elm \
	$(ELM_SRC)/View.elm \
	$(ELM_SRC)/Main.elm \
	boot.js \
	$(SCSS_SRC)/main.scss

BUILD_TARGETS := $(BUILD)/main.js \
								 $(BUILD)/boot.js \
								 $(BUILD)/main.css \
								 $(BUILD)/index.html

COMPILE_TARGETS := $(TOOL_TARGETS) $(SUPPORT_TARGETS) $(APPLICATION_TARGETS) $(BUILD_TARGETS)

all: $(COMPILE_TARGETS) ##@Dev Compiles entire project
.PHONY: all

help: ##@Other Displays this help text
	@perl -e '$(help_fun)' $(MAKEFILE_LIST)
.PHONY: help

repl: $(ELM) ##@Dev Opens an Elm repl session
	$(ELM) repl
.PHONY: repl

serve: $(COMPILE_TARGETS) ##@Dev Serves build at http://localhost:8000
	$(DEVD) $(DEVD_OPTIONS)
.PHONY: serve

watch: $(COMPILE_TARGETS) ##@Dev Starts the dev watcher (with live-reload server at http://localhost:8000)
	$(MODD)

# TOOL TARGETS

$(BIN):
	mkdir -p $@

$(DEVD):
	${curl} ${DEVD_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C bin/ --strip 1
	rm $@.tgz

$(ELM):
	${curl} ${ELM_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C bin/ --strip 1
	rm $@.tgz

$(MO):
	${curl} $(MO_URL) -L -o $@
	chmod +x $@

$(MODD):
	${curl} ${MODD_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C bin/ --strip 1
	rm $@.tgz

$(WT):
	${curl} ${WT_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C bin/
	rm $@.tgz

# SUPPORT TARGETS

Makefile:
	$(call lazy_tpl,"$$Makefile")

.gitignore:
	$(call lazy_tpl,"$$gitignore")

elm-package.json:
	$(call lazy_tpl,"$$elm_package_json")

modd.conf: $(MO)
	echo "$$modd_config" | build=$(BUILD) elm_src=$(ELM_SRC) scss_src=$(SCSS_SRC) $(MO) > $@

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

boot.js:
	$(call lazy_tpl,"$$boot_js")

$(SCSS_SRC):
	mkdir -p $@

$(SCSS_SRC)/main.scss: $(SCSS_SRC)
	$(call lazy_tpl,"$$main_scss")

# BUILD TARGETS

$(BUILD):
	mkdir -p $@

$(BUILD)/index.html: $(BUILD) index.html $(MO)
	main_js=/main.js boot_js=/boot.js main_css=/main.css $(MO) index.html > $@

$(BUILD)/main.js: $(BUILD) $(ELM_SRC_FILES) $(ELM)
	$(ELM)-make $(ELM_SRC)/Main.elm --yes --warn --output $@

$(BUILD)/boot.js: boot.js $(BUILD)
	cp $< $@

$(BUILD)/main.css: $(BUILD) $(SCSS_SRC_FILES) $(WT)
	$(WT) compile -b $(BUILD)/ $(SCSS_SRC)/main.scss

# TEMPLATES

define help_text
Elm.mk - a simple toolchain for Elm projects\n\nAvailable tasks:\n\n
endef
export help_text

define Makefile
include elm.mk
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
  <link rel="stylesheet" href="{{main_css}}">
</head>
<body>
  <main id="app">
    <h1>Loading...</h1>
  </main>
</body>
<script type="text/javascript" src="{{main_js}}"></script>
<script type="text/javascript" src="{{boot_js}}"></script>
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

define boot_js
window.onload = function() {
  var container = document.getElementById("app");
  Elm.Main.embed(container);
};
endef
export boot_js

define main_scss
body {
  color: #130f40;
}
endef
export main_scss

define modd_config
{{elm_src}}/**/*.elm {
  prep: make {{build}}/main.js
}
boot.js {
  prep: make {{build}}/boot.js
}
{{scss_src}}/**/*.scss {
  prep: make {{build}}/main.css
}
index.html {
  prep: make {{build}}/index.html
}
{{build}}/** {
  daemon: $(DEVD) $(DEVD_OPTIONS)
}
endef
export modd_config
