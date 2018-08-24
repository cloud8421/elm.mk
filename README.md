# Elm.mk

[![Build Status](https://travis-ci.org/cloud8421/elm.mk.svg?branch=master)](https://travis-ci.org/cloud8421/elm.mk)

A fast, close-to-zero dependencies toolchain for Elm-based single page applications.

## Philosophy

The main goal of this boilerplate is to **minimise the needs for external dependencies** while providing an effective
development environment. This means that it tries as much as possible to bundle pre-compiled utilities to accomplish the needed tasks.

## Features

- [x] Cross-platform (OS X + Linux 64bit - help with Windows would be nice)
- [x] Elm [StartApp](http://package.elm-lang.org/packages/evancz/start-app/2.0.2/) installation
- [x] Project scaffold generation
- [x] Elm compilation with warnings
- [x] Scss compilation via [Wellington](https://github.com/wellington/wellington)
- [x] Watch and recompile via [modd](https://github.com/cortesi/modd)
- [x] Live reload via [devd](https://github.com/cortesi/devd)
- [x] File generators based on templates

## Setup from scratch

- `mkdir my_new_project && cd my_new_project`
- `curl -o elm.mk https://raw.githubusercontent.com/cloud8421/elm.mk/master/elm.mk`
- `make -f elm.mk`

This will generate the needed folder structure and files. Note that at the end of `make -f elm.mk`, you're left with
an empty `Makefile` that includes `elm.mk`, so that you can extend it for your needs and/or override its behaviour.

## Project workflow

Main commands:

- `make`: compiles the project into `build` (installing dependencies if needed)
- `make dist`: compiles the project into `dist` with production optimisations
- `make serve`: serves the build folder with a local http server
- `make watch`: starts the file watcher and the http server, recompiling files on save
- `make help`: shows all main tasks
- `make config`: shows paths used for project files

Some guidelines:

- Files generated into `build` should not be edited manually.
- Files generated into `dist` should not be edited manually. In addition, they're passed through optimisation steps which make them very difficult to read.
- All other files can be modified.
- Source `.elm` files should be placed in `src`.
- Use `boot.js` to start your Elm application and define all ports-related glue code with the external world. The file gets copied automatically to `build`.
- `scss/main.scss` is the stylesheet main file.
- `index.html` gets copied the way it is into `build`.

It may also be worth checking out the documentation for the software used in this boilerplate (like Devd or Modd), as they provide functionality that it's not covered here.

## Elm.mk development

If you're interested in contributing, please make sure you keep tests up to date.

After cloning this repository, just run `make test` (requires Ruby 2.x in your path, no extra dependencies).

Tests are maintained in `tests.rb`.

## FAQs/Comments

#### Looking for a different version

Try the `legacy` branch.

#### I don't think this should use X, Y is a better fit.
As long as it's easy to install in portable format (i.e. download in the project folder and run), please feel free to state the case for a replacement

#### Why is feature X missing?
Probably because I haven't thought about it.

#### Why Make?
Make is ubiquitous, mostly pre-installed (or very easy to install) and language-agnostic. It takes some time to adjust to it, but it's fast, effective and modular.

#### This make task is not optimal, it's much better if you change it like this!
Please submit a PR, I'm happy to learn

#### I don't know Make, but I'd like to help. Where can I learn more?

- [The official manual](https://www.gnu.org/software/make/manual/)
- [Smashing Magazine Introduction](https://www.smashingmagazine.com/2015/10/building-web-applications-with-make/)
- [O'Reilly book](http://shop.oreilly.com/product/9780596006105.do)
- [Gotchas - great article](http://gromnitsky.users.sourceforge.net/articles/notes-for-new-make-users/)

