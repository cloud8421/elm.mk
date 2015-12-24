# Elm.mk

A minimal Makefile to work on [Elm](http://elm-lang.org) projects that require external js and css. It requires
a working Elm installation.

## Philosophy

The main goal of this boilerplate is to **minimise the needs for external dependencies** while providing an effective
development environment. This means that it tries as much as possible to bundle pre-compiled utilities to accomplish the needed tasks.

## Features

- [x] Cross-platform (OS X + Linux 64bit - help with Windows would be nice)
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
- Use `src/interop.js` to start your Elm application and define all ports-related glue code with the external world. The file gets copied automatically to `build`.
- `styles/main.scss` is the stylesheet main file.
- `index.html` gets copied the way it is into `build`

It may also be worth checking out the documentation for the software used in this boilerplate (like Devd), as they provide functionality that it's not covered here.

## FAQs/Comments

- I don't think this should use X, Y is a better fit.
- As long as it's easy to install in portable format (i.e. download in the project folder and run), please feel free to state the case for a replacement

- Why is feature X missing?
- Probably because I haven't thought about it.

- Why Make?
- Make is ubiquitous, mostly pre-installed (or very easy to install) and language-agnostic. It takes some time to adjust to it, but it's fast, effective and modular.

- I don't know Make, but I'd like to help. Where can I learn more?
- Smashing Magazine has a very good introduction and there are good books out there. They mostly focus on usage with C, but they should work out fine.
