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

    it "elm source files" do
      ["Main.elm", "Types.elm", "State.elm", "View.elm"].each do |file|
        contents = File.open("dummy/src/#{file}")
          .map(&:strip)
          .entries

        module_name = file.split(".").first

        contents.wont_be_empty
        contents.first.include?("module #{module_name}").must_equal true
      end
    end
  end

  describe "build targets" do
    it "build/index.html" do
      contents = File.open("dummy/build/index.html")
        .map(&:strip)
        .entries

      contents.wont_be_empty
      contents
        .find { |l| l.include? "/main.js" }
        .wont_be_nil
      contents
        .find { |l| l.include? "/boot.js" }
        .wont_be_nil
    end

    it "build/main.js" do
      contents = File.open("dummy/build/main.js")
        .map(&:strip)
        .entries

      contents.wont_be_empty
    end

    it "build/boot.js" do
      contents = File.open("dummy/build/boot.js")
        .map(&:strip)
        .entries

      contents.wont_be_empty
      contents
        .find { |l| l.include? "Elm.Main.embed" }
        .wont_be_nil
    end
  end
end
