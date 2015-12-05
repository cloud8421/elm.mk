.PHONY: install server watch
ELM_ENTRY = src/Main.elm
DEVD_VERSION = 0.3
WELLINGTON_VERSION = 1.0.2
OS := $(shell uname)

ifeq ($(OS),Darwin)
	DEVD_URL = "https://github.com/cortesi/devd/releases/download/v${DEVD_VERSION}/devd-${DEVD_VERSION}-osx64.tgz"
else
	DEVD_URL = "https://github.com/cortesi/devd/releases/download/v${DEVD_VERSION}/devd-${DEVD_VERSION}-linux64.tgz"
endif

ifeq ($(OS),Darwin)
	WELLINGTON_URL = "https://github.com/wellington/wellington/releases/download/v${WELLINGTON_VERSION}/wt_v${WELLINGTON_VERSION}_darwin_amd64.tar.gz"
else
	WELLINGTON_URL = "https://github.com/wellington/wellington/releases/download/v${WELLINGTON_VERSION}/wt_v${WELLINGTON_VERSION}_linux_amd64.tar.gz"
endif

ifeq ($(OS),Darwin)
	GOAT_URL = "https://s3-ap-northeast-1.amazonaws.com/yosssi/goat/darwin_amd64/goat"
else
	GOAT_URL = "https://s3-ap-northeast-1.amazonaws.com/yosssi/goat/linux_amd64/goat"
endif

all: build/main.js build/main.css build/index.html build/interop.js

install: src bin build \
				 elm-package.json \
				 src/Main.elm src/interop.js styles/main.scss index.html \
				 bin/goat goat.json \
				 bin/devd bin/wellington

server:
	bin/devd -w build -l build/

watch:
	bin/goat

build bin src styles:
	mkdir -p $@

styles/main.scss: styles
	test -s $@ || touch $@

src/Main.elm: src
	test -s $@ || echo "$$main_elm" > $@

src/interop.js: src
	test -s $@ || echo "$$interop_js" > $@

index.html:
	test -s $@ || echo "$$index_html" > $@

bin/devd:
	curl ${DEVD_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C bin/ --strip 1
	rm $@.tgz

bin/wellington:
	curl ${WELLINGTON_URL} -L -o $@.tgz
	tar -xzf $@.tgz -C bin/ --strip 1
	rm $@.tgz

bin/goat:
	curl ${GOAT_URL} -L -o $@
	chmod +x $@

goat.json:
	echo "$$goat_config" > $@

elm-package.json:
	echo "$$elm_package_json" > $@

build/main.css: styles/main.scss
	bin/wt compile -b build/ $?

build/main.js: src/*.elm
	elm make $(ELM_ENTRY) --warn --output $@

build/interop.js: src/interop.js
	cp $? $@

build/index.html: index.html
	cp $? $@

define goat_config
{
  "watchers": [
    {
      "extension": "elm",
      "tasks": [
        {
          "command": "make build/main.js"
        }
      ]
    },
    {
      "extension": "scss",
      "tasks": [
        {
          "command": "make build/main.css"
        }
      ]
    },
    {
      "extension": "html",
      "tasks": [
        {
          "command": "make build/index.html"
        }
      ]
    }
  ]
}
endef
export goat_config

define main_elm
module Main where

import Html exposing (div, button, text)
import Html.Events exposing (onClick)
import StartApp.Simple as StartApp

main =
  StartApp.start { model = model, view = view, update = update }

model = 0

view address model =
  div []
    [ button [ onClick address Decrement ] [ text "-" ]
    , div [] [ text (toString model) ]
    , button [ onClick address Increment ] [ text "+" ]
    ]

type Action = Increment | Decrement

update action model =
  case action of
    Increment -> model + 1
    Decrement -> model - 1
endef
export main_elm

define elm_package_json
{
    "version": "1.0.0",
    "summary": "helpful summary of your project, less than 80 characters",
    "repository": "https://github.com/user/project.git",
    "license": "BSD3",
    "source-directories": [
        "src"
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
