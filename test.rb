require 'minitest/autorun'
require 'minitest/spec'
require 'minitest/pride'

describe "Roots test" do
  describe "tool targets" do
    it "elm" do
      File.exist?("dummy/node_modules/.bin/elm").must_equal true
    end

    it "bin/mo" do
      File.exist?("dummy/bin/mo").must_equal true
      File.executable?("dummy/bin/mo").must_equal true
    end
  end

  describe "support targets" do
    it ".gitignore" do
      contents = File.open("dummy/.gitignore")
        .map(&:strip)
        .entries

      contents.wont_be_empty
      contents.must_include "elm-stuff"
      contents.must_include "node_modules"
      contents.must_include "elm.js"
    end

    it "Makefile" do
      contents = File.open("dummy/Makefile")
        .map(&:strip)
        .entries

      contents.wont_be_empty
      contents.must_include "include roots.mk"
    end

    it "elm-package.json" do
      contents = File.open("dummy/elm-package.json")
        .map(&:strip)
        .entries

      contents.wont_be_empty
      contents
        .find { |l| l.include? "elm-lang/html" }
        .wont_be_nil
    end
  end

  describe "application targets" do
    it "index.html" do
      contents = File.open("dummy/index.html")
        .map(&:strip)
        .entries

      contents.wont_be_empty
      contents
        .find { |l| l.include? "Loading..." }
        .wont_be_nil
    end
  end
end
