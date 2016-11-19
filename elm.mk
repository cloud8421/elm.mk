.PHONY: install server watch clean test help
ELM_ENTRY = src/Main.elm
ELM_FILES = $(shell find src -type f -name '*.elm')
NODE_BIN_DIRECTORY = node_modules/.bin
DEVD_VERSION = 0.6
WELLINGTON_VERSION = 1.0.4
MODD_VERSION = 0.4
ELM_TEST_VERSION = 0.17.3
UGLIFY_JS_VERSION = 2.7.4
OS := $(shell uname)
BUILD_FOLDER = build
DIST_FOLDER = dist
INSTALL_TARGETS = src bin $(BUILD_FOLDER) \
									Makefile \
									elm-package.json \
									src/Main.elm src/interop.js styles/main.scss index.html \
									bin/modd modd.conf \
									bin/devd bin/wt \
									bin/mo \
									.gitignore \
									$(CUSTOM_INSTALL_TARGETS)
COMPILE_TARGETS = $(BUILD_FOLDER) \
									$(BUILD_FOLDER)/main.js \
									$(BUILD_FOLDER)/main.css \
									$(BUILD_FOLDER)/index.html \
									$(BUILD_FOLDER)/interop.js \
									$(CUSTOM_COMPILE_TARGETS)
DIST_TARGETS = $(DIST_FOLDER) \
							 $(DIST_FOLDER)/main.min.js \
							 $(DIST_FOLDER)/interop.min.js \
							 $(DIST_FOLDER)/main.min.css \
							 $(DIST_FOLDER)/index.html
TEST_TARGETS = $(NODE_BIN_DIRECTORY)/elm-test tests/Main.elm
SERVER_OPTS = -w $(BUILD_FOLDER) -l $(BUILD_FOLDER)/ $(CUSTOM_SERVER_OPTS)

MO_URL = "https://raw.githubusercontent.com/tests-always-included/mo/master/mo"
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
	bin/devd $(SERVER_OPTS)

watch: ## Watches files for changes, runs a local dev server and triggers live reload
	bin/modd

clean: ## Removes compiled files
	rm $(BUILD_FOLDER)/*

test: $(TEST_TARGETS) ## Runs unit tests via elm-test
	$(NODE_BIN_DIRECTORY)/elm-test

prod: $(DIST_TARGETS) ## Minifies build folders for production usage

help: ## Prints a help guide
	@echo "Available tasks:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

$(BUILD_FOLDER) $(DIST_FOLDER) bin src styles:
	mkdir -p $@

Makefile:
	test -s $@ || echo "$$Makefile" > $@

styles/main.scss: styles
	test -s $@ || touch $@

src/Main.elm: src
	test -s $@ || echo "$$main_elm" > $@

src/interop.js: src
	test -s $@ || echo "$$interop_js" > $@

tests/Main.elm:
	$(NODE_BIN_DIRECTORY)/elm-test init --yes

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

bin/mo:
	curl $(MO_URL) -L -o $@
	chmod +x $@

modd.conf:
	echo "$$modd_config" > $@

elm-package.json:
	echo "$$elm_package_json" > $@

$(NODE_BIN_DIRECTORY)/elm-test:
	npm install elm-test@${ELM_TEST_VERSION}

$(NODE_BIN_DIRECTORY)/uglifyjs:
	npm install uglify-js@${UGLIFY_JS_VERSION}

.gitignore:
	echo "$$gitignore" > $@

$(BUILD_FOLDER)/main.css: styles/*.scss
	bin/wt compile -b $(BUILD_FOLDER)/ styles/main.scss

$(BUILD_FOLDER)/main.js: $(ELM_FILES)
	elm make $(ELM_ENTRY) --yes --warn --output $@

$(BUILD_FOLDER)/interop.js: src/interop.js
	cp $? $@

$(BUILD_FOLDER)/index.html: index.html
	main_css=/main.css main_js=/main.js interop_js=/interop.js bin/mo index.html > $@

$(DIST_FOLDER)/main.min.css: styles/*.scss
	bin/wt compile -s compressed -b $(DIST_FOLDER)/ styles/main.scss
	mv $(DIST_FOLDER)/main.css $@

$(DIST_FOLDER)/main.min.js: $(BUILD_FOLDER)/main.js $(NODE_BIN_DIRECTORY)/uglifyjs
	$(NODE_BIN_DIRECTORY)/uglifyjs --compress --mangle --output $@ -- $(BUILD_FOLDER)/main.js

$(DIST_FOLDER)/interop.min.js: $(BUILD_FOLDER)/interop.js $(NODE_BIN_DIRECTORY)/uglifyjs
	$(NODE_BIN_DIRECTORY)/uglifyjs --compress --mangle --output $@ -- $(BUILD_FOLDER)/interop.js

$(DIST_FOLDER)/index.html: index.html
	main_css=/main.min.css main_js=/main.min.js interop_js=/interop.min.js bin/mo index.html > $@

define Makefile

include elm.mk
endef
export Makefile

define modd_config
src/**/*.elm {
  prep: make $(BUILD_FOLDER)/main.js
}
src/**/*.js {
  prep: make $(BUILD_FOLDER)/interop.js
}
styles/**/*.scss {
  prep: make $(BUILD_FOLDER)/main.css
}
index.html {
  prep: make $(BUILD_FOLDER)/index.html
}
$(BUILD_FOLDER)/** {
  daemon: make server
}
endef
export modd_config

define main_elm
module Main exposing (..)

import Html exposing (div, text, Html)
import Platform.Sub as Sub


type Msg
    = NoOp


type alias Model =
    Int


model : Model
model =
    0


view : Model -> Html Msg
view model =
    div []
        [ model |> toString |> text ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program Never Model Msg
main =
    Html.program
        { init = ( model, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
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
        "elm-lang/core": "5.0.0 <= v < 6.0.0",
        "elm-lang/html": "2.0.0 <= v < 3.0.0",
        "elm-lang/http": "1.0.0 <= v < 2.0.0"
    },
    "elm-version": "0.18.0 <= v < 0.19.0"
}
endef
export elm_package_json

define interop_js
window.onload = function() {
  var app = Elm.Main.fullscreen();
};
endef
export interop_js

define index_html
<!DOCTYPE HTML>
<html>
<head>
  <meta charset="UTF-8">
  <title>Elm Project</title>
  <link rel="stylesheet" href="{{main_css}}">
</head>
<body>
</body>
  <script type="text/javascript" src="{{main_js}}"></script>
  <script type="text/javascript" src="{{interop_js}}"></script>
</html>
endef
export index_html

define gitignore
elm-stuff
elm.js
/$(BUILD_FOLDER)/*
/bin/*
endef
export gitignore
