require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'

describe "Elm.mk test" do
  describe "help" do
    it "has all commands" do
      out, _err = capture_subprocess_io do
        system("make -f dummy/elm.mk help")
      end

      assert_match %r%all%, out
      assert_match %r%repl%, out
      assert_match %r%serve%, out
      assert_match %r%watch%, out
      assert_match %r%help%, out
    end
  end

  describe "config" do
    it "shows relevant paths" do
      out, _err = capture_subprocess_io do
        system("make -f dummy/elm.mk config")
      end

      assert_match %r%src%, out
      assert_match %r%styles%, out
      assert_match %r%build%, out
      assert_match %r%dist%, out
    end
  end

  describe "tool targets" do
    it "executables" do
      ["bin/devd", "bin/elm", "bin/elm-format", "bin/mo", "bin/modd", "bin/wt"].each do |bin|
        File.exist?("dummy/#{bin}").must_equal true
        File.executable?("dummy/#{bin}").must_equal true
      end
    end
  end

  describe "support targets" do
    it ".gitignore" do
      contents = File.readlines_stripped("dummy/.gitignore")

      contents.wont_be_empty
      contents.must_include "elm-stuff"
      contents.must_include "node_modules"
      contents.must_include "elm.js"
      contents.must_include "build"
      contents.must_include "dist"
      contents.must_include "bin"
    end

    it "Makefile" do
      contents = File.readlines_stripped("dummy/Makefile")

      contents.wont_be_empty
      contents.must_include "include elm.mk"
    end

    it "elm.json" do
      contents = File.readlines_stripped("dummy/elm.json")

      contents.wont_be_empty
      contents.must_have_at_least_one_matching(/elm\/html/)
    end

    it "modd.conf" do
      contents = File.readlines_stripped("dummy/modd.conf")

      contents.wont_be_empty
      contents.must_have_at_least_one_matching(/build\/main\.js/)
      contents.must_have_at_least_one_matching(/build\/boot\.js/)
      contents.must_have_at_least_one_matching(/build\/main\.css/)
      contents.must_have_at_least_one_matching(/build\/index\.html/)
      contents.must_have_at_least_one_matching(/devd/)
    end
  end

  describe "application targets" do
    it "index.html" do
      contents = File.readlines_stripped("dummy/index.html")

      contents.wont_be_empty
      contents.must_have_at_least_one_matching(/Loading.../)
    end

    it "elm source files" do
      contents = File.readlines_stripped("dummy/src/Main.elm")

      contents.wont_be_empty
      contents.first.must_include("module Main exposing (main)")
    end
  end

  describe "build targets" do
    it "build/index.html" do
      contents = File.readlines_stripped("dummy/build/index.html")

      contents.wont_be_empty
      contents.must_have_at_least_one_matching(/\/main\.js/)
      contents.must_have_at_least_one_matching(/\/boot\.js/)
      contents.must_have_at_least_one_matching(/\/service-worker\.js/)
      contents.must_have_at_least_one_matching(/\/main\.css/)
    end

    it "build/main.js" do
      contents = File.readlines_stripped("dummy/build/main.js")

      contents.wont_be_empty
    end

    it "build/boot.js" do
      contents = File.readlines_stripped("dummy/build/boot.js")

      contents.wont_be_empty
      contents.must_have_at_least_one_matching(/Elm\.Main\.init/)
    end

    it "build/service-worker.js" do
      contents = File.readlines_stripped("dummy/build/service-worker.js")

      contents.wont_be_empty
      contents.must_have_at_least_one_matching(/v1\.files/)
    end

    it "build/main.css" do
      contents = File.readlines_stripped("dummy/build/main.css")

      contents.wont_be_empty
      contents.must_have_at_least_one_matching(/body/)
    end
  end
end

describe "dist targets" do
  it "uglifyjs" do
    File.exist?("dummy/node_modules/.bin/uglifyjs").must_equal true
    File.executable?("dummy/node_modules/.bin/uglifyjs").must_equal true
  end

  it "dist/index.html" do
    contents = File.readlines_stripped("dummy/dist/index.html")

    contents.wont_be_empty
    contents.must_have_at_least_one_matching(/\/main\.min\.js/)
    contents.must_have_at_least_one_matching(/\/boot\.js/)
    contents.must_have_at_least_one_matching(/\/service-worker\.js/)
    contents.must_have_at_least_one_matching(/\/main\.css/)
  end

  it "dist/main.js" do
    contents = File.readlines_stripped("dummy/dist/main.js")

    contents.wont_be_empty
  end

  it "dist/main.min.js" do
    contents = File.readlines_stripped("dummy/dist/main.min.js")

    contents.wont_be_empty
  end

  it "dist/boot.js" do
    contents = File.readlines_stripped("dummy/dist/boot.js")

    contents.wont_be_empty
    contents.must_have_at_least_one_matching(/Elm\.Main\.init/)
  end

  it "dist/service-worker.js" do
    contents = File.readlines_stripped("dummy/dist/service-worker.js")

    contents.wont_be_empty
    contents.must_have_at_least_one_matching(/v1\.files/)
  end

  it "dist/main.css" do
    contents = File.readlines_stripped("dummy/dist/main.css")

    contents.wont_be_empty
    contents.must_have_at_least_one_matching(/body/)
  end
end

# Extensions and helpers

class File
  def self.readlines_stripped(filename)
    readlines(filename).map(&:strip)
  end
end

module MiniTest::Assertions
  def assert_at_least_one_match(strings, matcher)
    refute strings.grep(matcher).empty?, "Expected #{strings} to have at least one element matching #{matcher.inspect}"
  end
end

Array.infect_an_assertion :assert_at_least_one_match, :must_have_at_least_one_matching, :do_not_flip

