# GENERAL PLUMBING

BIN := bin
ELM_SRC := src
SCSS_SRC := styles
ELM_SRC_FILES = $(shell find $(ELM_SRC) -type f -name '*.elm' 2>/dev/null)
SCSS_SRC_FILES = $(shell find $(SCSS_SRC) -type f -name '*.scss' 2>/dev/null)
BUILD := build
DIST := dist
NPM_BIN := node_modules/.bin
OS := $(shell uname)

# COLORS/FORMATTING

GREEN  := $(shell tput -Txterm setaf 2)
WHITE  := $(shell tput -Txterm setaf 7)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)
BLANKLINE := ""

# SUPPORT

lazy_tpl = @test -s $@ || echo $1 > $@ # renders a template for the target unless file is there already
help_fun = \
					 %help; \
					 while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
					 print "${help_text}"; \
					 for (sort keys %help) { \
					 print "  ${WHITE}$$_:${RESET}\n\n"; \
					 for (@{$$help{$$_}}) { \
					 $$sep = " " x (13 - length $$_->[0]); \
					 print "    ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
					 }; \
					 print "\n"; }
curl := curl --silent

# DEV TOOLS

DEVD := $(BIN)/devd
ELM := $(BIN)/elm
ELM_FORMAT := $(BIN)/elm-format
ELM_TEST := $(NPM_BIN)/elm-test
MO := $(BIN)/mo
MODD := $(BIN)/modd
WT := $(BIN)/wt
UGLIFYJS := $(NPM_BIN)/uglifyjs

DEVD_VERSION := 0.9
ELM_VERSION := 0.19.0
ELM_FORMAT_VERSION := 0.8.1
ELM_TEST_VERSION := 0.19.0-rev6
MO_VERSION := 2.0.4
MODD_VERSION := 0.8
WT_VERSION := 1.0.4
UGLIFYJS_VERSION := 3.6.0

ELM_TEST_DEFAULT_OPTIONS := --compiler ${ELM}
UGLIFYJS_COMPRESS_OPTIONS := 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe'

MO_URL := "https://raw.githubusercontent.com/tests-always-included/mo/${MO_VERSION}/mo"

ifeq ($(OS),Darwin)
	DEVD_URL := "https://github.com/cortesi/devd/releases/download/v${DEVD_VERSION}/devd-${DEVD_VERSION}-osx64.tgz"
	ELM_URL := "https://github.com/elm/compiler/releases/download/${ELM_VERSION}/binaries-for-mac.tar.gz"
	ELM_FORMAT_URL := "https://github.com/avh4/elm-format/releases/download/${ELM_FORMAT_VERSION}/elm-format-${ELM_FORMAT_VERSION}-mac-x64.tgz"
	MODD_URL := "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-osx64.tgz"
	WT_URL := "https://github.com/wellington/wellington/releases/download/v${WT_VERSION}/wt_v${WT_VERSION}_darwin_amd64.tar.gz"
else
	DEVD_URL := "https://github.com/cortesi/devd/releases/download/v${DEVD_VERSION}/devd-${DEVD_VERSION}-linux64.tgz"
	ELM_URL := "https://github.com/elm/compiler/releases/download/${ELM_VERSION}/binaries-for-linux.tar.gz"
	ELM_FORMAT_URL := "https://github.com/avh4/elm-format/releases/download/${ELM_FORMAT_VERSION}/elm-format-${ELM_FORMAT_VERSION}-linux-x64.tgz"
	MODD_URL := "https://github.com/cortesi/modd/releases/download/v${MODD_VERSION}/modd-${MODD_VERSION}-linux64.tgz"
	WT_URL := "https://github.com/wellington/wellington/releases/download/v${WT_VERSION}/wt_v${WT_VERSION}_linux_amd64.tar.gz"
endif

DEVD_OPTIONS := -m $(BUILD) -f /index.html

# MAIN TARGETS

SUPPORT_TARGETS := Makefile \
	.gitignore \
	elm.json \
	modd.conf

TOOL_TARGETS := $(BIN) \
	$(DEVD) \
	$(ELM) \
	$(ELM_FORMAT) \
	$(MO) \
	$(MODD) \
	$(WT)

APPLICATION_TARGETS := index.html \
	$(ELM_SRC) \
	$(ELM_SRC)/Main.elm \
	boot.js \
	service-worker.js \
	$(SCSS_SRC)/main.scss

TEST_TARGETS := $(ELM_TEST) \
	tests/Example.elm

BUILD_TARGETS := $(BUILD) \
	$(BUILD)/main.js \
	$(BUILD)/boot.js \
	$(BUILD)/service-worker.js \
	$(BUILD)/main.css \
	$(BUILD)/index.html

DIST_TARGETS := $(UGLIFYJS) \
	$(DIST) \
	$(DIST)/main.min.js \
	$(DIST)/boot.js \
	$(DIST)/service-worker.js \
	$(DIST)/main.css \
	$(DIST)/index.html

COMPILE_TARGETS := $(TOOL_TARGETS) $(SUPPORT_TARGETS) $(APPLICATION_TARGETS) $(BUILD_TARGETS)

PROD_TARGETS := $(TOOL_TARGETS) $(SUPPORT_TARGETS) $(APPLICATION_TARGETS) $(DIST_TARGETS)

all: $(COMPILE_TARGETS) ##@Dev Compiles entire project
.PHONY: all

prod: $(PROD_TARGETS) ##@Dist Compiles the entire project for production
.PHONY: prod

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

tests: $(TEST_TARGETS) ##@Dev Runs the entire tests suite via elm-test
	$(ELM_TEST) $(ELM_TEST_DEFAULT_OPTIONS)
.PHONY: tests

tests-watch: $(TEST_TARGETS) ##@Dev Starts a watcher to run tests on file change
	$(ELM_TEST) $(ELM_TEST_DEFAULT_OPTIONS) --watch
.PHONY: tests

config: ##@Other Displays the current configuration
	@echo ${BLANKLINE}
	@echo "      ${GREEN}Elm.mk:${RESET} a simple toolchain for Elm projects"
	@echo ${BLANKLINE}
	@echo "     ${YELLOW}Elm src:${RESET} $(ELM_SRC)"
	@echo "    ${YELLOW}Scss src:${RESET} $(SCSS_SRC)"
	@echo "  ${YELLOW}Build dest:${RESET} $(BUILD)"
	@echo "   ${YELLOW}Dist dest:${RESET} $(DIST)"
	@echo ${BLANKLINE}
.PHONY: config

# TOOL TARGETS

$(BIN):
	mkdir -p $@

$(DEVD):
	${curl} ${DEVD_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C bin/ --strip 1
	rm $@.tgz

$(ELM):
	${curl} ${ELM_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C bin/
	rm $@.tgz

$(ELM_FORMAT):
	${curl} ${ELM_FORMAT_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C bin/
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

$(ELM_TEST):
	npm install --no-save elm-test@${ELM_TEST_VERSION}

# SUPPORT TARGETS

Makefile:
	$(call lazy_tpl,"$$Makefile")

.gitignore:
	$(call lazy_tpl,"$$gitignore")

elm.json:
	$(call lazy_tpl,"$$elm_json")

modd.conf: $(MO)
	echo "$$modd_config" | build=$(BUILD) elm_src=$(ELM_SRC) scss_src=$(SCSS_SRC) $(MO) > $@

# APPLICATION TARGETS

$(ELM_SRC):
	mkdir -p $@

index.html:
	$(call lazy_tpl,"$$index_html")

$(ELM_SRC)/Main.elm:
	$(call lazy_tpl,"$$elm_main")

boot.js:
	$(call lazy_tpl,"$$boot_js")

service-worker.js:
	$(call lazy_tpl,"$$service_worker_js")

$(SCSS_SRC):
	mkdir -p $@

$(SCSS_SRC)/main.scss: $(SCSS_SRC)
	$(call lazy_tpl,"$$main_scss")

tests/Example.elm: $(ELM_TEST)
	yes | $(ELM_TEST) init $(ELM_TEST_DEFAULT_OPTIONS) || true

# BUILD TARGETS

$(BUILD):
	mkdir -p $@

$(BUILD)/index.html: index.html $(MO)
	main_js=/main.js boot_js=/boot.js main_css=/main.css service_worker_js=/service-worker.js $(MO) index.html > $@

$(BUILD)/main.js: $(ELM_SRC)/Main.elm $(ELM_SRC_FILES) $(ELM)
	$(ELM) make $(ELM_SRC)/Main.elm --debug --output $@

$(BUILD)/boot.js: boot.js
	cp $< $@

$(BUILD)/service-worker.js: service-worker.js
	cp $< $@

$(BUILD)/main.css: $(SCSS_SRC)/main.scss $(SCSS_SRC_FILES) $(WT)
	$(WT) compile -b $(BUILD)/ $(SCSS_SRC)/main.scss

# DIST TARGETS

$(UGLIFYJS):
	npm install --no-save uglify-js@${UGLIFYJS_VERSION}

$(DIST):
	mkdir -p $@

$(DIST)/index.html: index.html $(MO)
	main_js=/main.min.js boot_js=/boot.js main_css=/main.css service_worker_js=/service-worker.js $(MO) index.html > $@

$(DIST)/main.min.js: $(UGLIFYJS) $(DIST)/main.js
	$(UGLIFYJS) $(DIST)/main.js --compress $(UGLIFYJS_COMPRESS_OPTIONS) | $(UGLIFYJS) --mangle --output=$@

$(DIST)/main.js: $(ELM_SRC)/Main.elm $(ELM_SRC_FILES) $(ELM)
	$(ELM) make $(ELM_SRC)/Main.elm --optimize --output $@

$(DIST)/boot.js: boot.js
	cp $< $@

$(DIST)/service-worker.js: service-worker.js
	cp $< $@

$(DIST)/main.css: $(SCSS_SRC)/main.scss $(SCSS_SRC_FILES) $(WT)
	$(WT) compile -s compressed -b $(DIST)/ $(SCSS_SRC)/main.scss

# TEMPLATES

define help_text
\n  ${GREEN}Elm.mk:${RESET} a simple toolchain for Elm projects\n\n  Available tasks:\n\n
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
$(BUILD)
$(DIST)
$(BIN)
endef
export gitignore

define elm_json
{
    "type": "application",
    "source-directories": [
        "src"
    ],
    "elm-version": "0.19.0",
    "dependencies": {
        "direct": {
            "elm/browser": "1.0.0",
            "elm/core": "1.0.0",
            "elm/html": "1.0.0"
        },
        "indirect": {
            "elm/json": "1.0.0",
            "elm/time": "1.0.0",
            "elm/url": "1.0.0",
            "elm/virtual-dom": "1.0.0"
        }
    },
    "test-dependencies": {
        "direct": {},
        "indirect": {}
    }
}
endef
export elm_json

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
<script>
  if (navigator.serviceWorker && !navigator.serviceWorker.controller) { navigator.serviceWorker.register('{{service_worker_js}}'); }
</script>
</html>
endef
export index_html

define elm_main
module Main exposing (main)

import Browser exposing (Document)
import Html exposing (h1, text)
import Platform.Cmd as Cmd
import Platform.Sub as Sub


type alias Flags =
    Int


type Msg
    = NoOp


type alias Model =
    { count : Int }


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Flags -> ( Model, Cmd Msg )
init initialCount =
    ( { count = initialCount }, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "My new app"
    , body =
        [ h1 [] [ text "it works" ]
        ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
endef
export elm_main

define boot_js
window.onload = function() {
  var container = document.getElementById("app");
  Elm.Main.init({
    node: container,
    flags: 10
  });
};
endef
export boot_js

define main_scss
body {
  color: #130f40;
}
endef
export main_scss

define service_worker_js
// Taken from: https://adactio.com/journal/13540
//
// HTML files: try the network first, then the cache.
// Other files: try the cache first, then the network.
// Both: cache a fresh version if possible.
// (beware: the cache will grow and grow; there's no cleanup)

const cacheName = 'v1.files';

addEventListener('fetch',  fetchEvent => {
  const request = fetchEvent.request;
  if (request.method !== 'GET') {
    return;
  }
  fetchEvent.respondWith(async function() {
    const responseFromFetch = fetch(request);
    fetchEvent.waitUntil(async function() {
      const responseCopy = (await responseFromFetch).clone();
      const myCache = await caches.open(cacheName);
      await myCache.put(request, responseCopy);
    }());
    if (request.headers.get('Accept').includes('text/html')) {
      try {
        return await responseFromFetch;
      }
      catch(error) {
        return caches.match(request);
      }
    } else {
      const responseFromCache = await caches.match(request);
      return responseFromCache || responseFromFetch;
    }
  }());
});
endef
export service_worker_js

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
