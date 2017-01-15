#!/bin/bash

# see https://github.com/lehmannro/assert.sh

# Test is very minimal. It checks for the existence of expected files, skipping
# those which are instrumental to the build process. For example, we can safely skip
# testing the existence of the SASS compiler if we test the existence of the compiled
# css file.

set -e

. ./assert.sh

function fileExists() {
  ls $1
}

files="bin/modd elm-package.json modd.conf \
       index.html styles/main.scss src/boot.js \
       src/Main.elm src/Types.elm src/State.elm src/View.elm \
       build/index.html build/boot.js build/main.js build/main.css \
       build/images/test.jpg build/images/test.png \
       dist/main.min.js dist/boot.min.js dist/main.min.css dist/index.html"

for file in $files
do
  assert_raises "ls dummy/$file" 0
done

assert_end examples
