# Elm.mk

A minimal Makefile to work on [Elm](http://elm-lang.org) projects that require external js and css.

## Features

- [x] Project scaffold generation
- [x] Elm compilation with warnings
- [x] Scss compilation via [Wellington](https://github.com/wellington/wellington)
- [x] Watch and recompile
- [x] Live reload via [devd](https://github.com/cortesi/devd)
- [ ] File generators based on templates

## Setup from scratch

- `mkdir my_new_project && cd my_new_project`
- `curl -o Makefile https://raw.githubusercontent.com/cloud8421/elm.mk/master/elm.mk`
- `make install`

## Project workflow

By running `make` you will compile the project in `build`. Running `make watch` produces the same effect
while watching files for changes. Requires a working copy of [Watchman](https://facebook.github.io/watchman/).
