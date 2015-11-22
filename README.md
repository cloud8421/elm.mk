# Elm.mk

A minimal Makefile to work on [Elm](http://elm-lang.org) projects that require external js and css. It requires
a working Elm installation.

## Features

- [x] Cross-platform (OS X + Linux 64bit)
- [x] Elm [StartApp](http://package.elm-lang.org/packages/evancz/start-app/2.0.2/) installation
- [x] Project scaffold generation
- [x] Elm compilation with warnings
- [x] Scss compilation via [Wellington](https://github.com/wellington/wellington)
- [x] Watch and recompile via [goat](https://github.com/yosssi/goat)
- [x] Live reload via [devd](https://github.com/cortesi/devd)
- [x] File generators based on templates

## Setup from scratch

- `mkdir my_new_project && cd my_new_project`
- `curl -o Makefile https://raw.githubusercontent.com/cloud8421/elm.mk/master/elm.mk`
- `make install`

## Project workflow

Main commands:

- `make`: compiles the project into `build`
- `make watch`: watches files, compiles into build on save
- `make server`: serves the build folder with a local http server

Some guidelines:

- Files generated into `build` should not be edited manually
- All other files can be modified
- Source `.elm` files should be placed in `src`.
- `src/interop.js` is your entry point: it bootstraps the Elm app and can be extended for other port-based features. Gets copied the way it is into `build`.
- `styles/main.scss` is the stylesheet main file.
- `index.html` gets copied the way it is into `build`
