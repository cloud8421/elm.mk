require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'

describe "Roots test" do
  describe "tool targets" do
    it "executables" do
      ["bin/mo", "bin/elm", "bin/wt", "bin/devd", "bin/modd"].each do |bin|
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
    end

    it "Makefile" do
      contents = File.readlines_stripped("dummy/Makefile")

      contents.wont_be_empty
      contents.must_include "include roots.mk"
    end

    it "elm-package.json" do
      contents = File.readlines_stripped("dummy/elm-package.json")

      contents.wont_be_empty
      contents.must_have_at_least_one_matching(/elm-lang\/html/)
    end
  end

  describe "application targets" do
    it "index.html" do
      contents = File.readlines_stripped("dummy/index.html")

      contents.wont_be_empty
      contents.must_have_at_least_one_matching(/Loading.../)
    end

    it "elm source files" do
      ["Main.elm", "Types.elm", "State.elm", "View.elm"].each do |file|
        contents = File.readlines_stripped("dummy/src/#{file}")

        module_name = file.split(".").first

        contents.wont_be_empty
        contents.first.must_include("module #{module_name}")
      end
    end
  end

  describe "build targets" do
    it "build/index.html" do
      contents = File.readlines_stripped("dummy/build/index.html")

      contents.wont_be_empty
      contents.must_have_at_least_one_matching(/\/main\.js/)
      contents.must_have_at_least_one_matching(/\/boot\.js/)
    end

    it "build/main.js" do
      contents = File.readlines_stripped("dummy/build/main.js")

      contents.wont_be_empty
    end

    it "build/boot.js" do
      contents = File.readlines_stripped("dummy/build/boot.js")

      contents.wont_be_empty
      contents.must_have_at_least_one_matching(/Elm\.Main\.embed/)
    end
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

