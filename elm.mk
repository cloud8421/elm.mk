.PHONY: install server watch clean test help
ELM_ENTRY = src/Main.elm
ELM_FILES = $(shell find src -type f -name '*.elm')
NODE_BIN_DIRECTORY = node_modules/.bin
DEVD_VERSION = 0.3
WELLINGTON_VERSION = 1.0.2
MODD_VERSION = 0.3
ELM_TEST_VERSION = 0.16
OS := $(shell uname)
INSTALL_TARGETS = src bin build \
									Makefile \
									elm-package.json \
									src/Main.elm src/interop.js styles/main.scss index.html \
									bin/modd modd.conf \
									bin/devd bin/wt \
									.gitignore \
									$(CUSTOM_INSTALL_TARGETS)
COMPILE_TARGETS = build/main.js \
									build/main.css \
									build/index.html \
									build/interop.js \
									$(CUSTOM_COMPILE_TARGETS)
TEST_TARGETS = $(NODE_BIN_DIRECTORY)/elm-test test/TestRunner.elm

ifeq ($(OS),Darwin)
	DEVD_URL = "https://github.com/cortesi/devd/releases/download/v${DEVD_VERSION}/devd-${DEVD_VERSION}-osx64.tgz"
	WELLINGTON_URL = "https://github.com/wellington/wellington/releases/download/v${WELLINGTON_VERSION}/wt_v${WELLINGTON_VERSION}_darwin_amd64.tar.gz"
	MODD_URL = "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-osx64.tgz"
else
	DEVD_URL = "https://github.com/cortesi/devd/releases/download/v${DEVD_VERSION}/devd-${DEVD_VERSION}-linux64.tgz"
	WELLINGTON_URL = "https://github.com/wellington/wellington/releases/download/v${WELLINGTON_VERSION}/wt_v${WELLINGTON_VERSION}_linux_amd64.tar.gz"
	MODD_URL = "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-linux64.tgz"
endif

all: $(COMPILE_TARGETS) ## Compiles project files

install: $(INSTALL_TARGETS) ## Installs prerequisites and generates file/folder structure

server: ## Runs a local server for development
	bin/devd -w build -l build/

watch: ## Watches files for changes, runs a local dev server and triggers live reload
	bin/modd

clean: ## Removes compiled files
	rm build/*

test: $(TEST_TARGETS) ## Runs unit tests via elm-test
	$(NODE_BIN_DIRECTORY)/elm-test test/TestRunner.elm

help: ## Prints a help guide
	@echo "Available tasks:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build bin src styles:
	mkdir -p $@

Makefile:
	test -s $@ || echo "$$Makefile" > $@

styles/main.scss: styles
	test -s $@ || touch $@

src/Main.elm: src
	test -s $@ || echo "$$main_elm" > $@

src/interop.js: src
	test -s $@ || echo "$$interop_js" > $@

test/TestRunner.elm:
	$(NODE_BIN_DIRECTORY)/elm-test init --yes
	mkdir -p test
	mv *.elm test/

index.html:
	test -s $@ || echo "$$index_html" > $@

bin/devd:
	curl ${DEVD_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C bin/ --strip 1
	rm $@.tgz

bin/wt:
	curl ${WELLINGTON_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C bin/
	rm $@.tgz

bin/modd:
	curl ${MODD_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C bin/ --strip 1
	rm $@.tgz

modd.conf:
	echo "$$modd_config" > $@

elm-package.json:
	echo "$$elm_package_json" > $@

node_modules/.bin/elm-test:
	npm install elm-test@${ELM_TEST_VERSION}

.gitignore:
	echo "$$gitignore" > $@

build/main.css: styles/*.scss
	bin/wt compile -b build/ styles/main.scss

build/main.js: $(ELM_FILES)
	elm make $(ELM_ENTRY) --yes --warn --output $@

build/interop.js: src/interop.js
	cp $? $@

build/index.html: index.html
	cp $? $@

define Makefile
include elm.mk
endef
export Makefile

define modd_config
src/**/*.elm {
  prep: make build/main.js
}
src/**/*.js {
  prep: make build/interop.js
}
styles/**/*.scss {
  prep: make build/main.css
}
index.html {
  prep: make build/index.html
}
build/** {
  daemon: make server
}
endef
export modd_config

define main_elm
module Main where

import Html exposing (div, text, Html)
import StartApp as StartApp
import Task exposing (Task)
import Effects exposing (Effects, Never)

type Action = NoOp
type alias Model = Int

noFx : a -> ( a, Effects b )
noFx model =
  (model, Effects.none)

model : Model
model = 0

view : Signal.Address Action -> Model -> Html
view address model =
  div
    []
    [ model |> toString |> text ]

update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    NoOp -> noFx model

app : StartApp.App Model
app =
  StartApp.start { init = noFx model
                 , view = view
                 , update = update
                 , inputs = []
                 }

main : Signal Html
main =
  app.html

port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks
endef
export main_elm

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
        "elm-lang/core": "3.0.0 <= v < 4.0.0",
        "evancz/elm-effects": "2.0.1 <= v < 3.0.0",
        "evancz/elm-html": "4.0.2 <= v < 5.0.0",
        "evancz/elm-http": "3.0.0 <= v < 4.0.0",
        "evancz/start-app": "2.0.2 <= v < 3.0.0"
    },
    "elm-version": "0.16.0 <= v < 0.17.0"
}
endef
export elm_package_json

define interop_js
window.onload = function() {
  var app = Elm.fullscreen(Elm.Main, {});
};
endef
export interop_js

define index_html
<!DOCTYPE HTML>
<html>
<head>
  <meta charset="UTF-8">
  <title>Elm Project</title>
  <link rel="stylesheet" href="/main.css">
</head>
<body>
</body>
  <script type="text/javascript" src="main.js"></script>
  <script type="text/javascript" src="interop.js"></script>
</html>
endef
export index_html

define gitignore
elm-stuff
elm.js
/build/*
/bin/*
endef
export gitignore
