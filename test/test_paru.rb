require "minitest/autorun"

require_relative "../lib/paru/pandoc.rb"
require_relative "../lib/paru/error.rb"

class ParuTest < MiniTest::Test

    def setup
    end

    def run_converter(converter, input_file, output_file, use_output_option = false)
        input = File.read(input_file)
        converted_input = converter << input
        output = File.read(output_file)
        
        if use_output_option
            converted_input = output
        end
        assert_equal output.strip, converted_input.strip
    end

    def test_info()
      info = Paru::Pandoc.info
      assert_match(/\d+\.\d+/, info[:version])
      if Gem.win_platform?
        assert_match(/\\pandoc$/, info[:data_dir])
      else
        assert_match(/\.pandoc$/, info[:data_dir])
      end
    end

    def test_simple_conversion()
        converter = Paru::Pandoc.new do
            from "markdown"
            to "html"
        end

        run_converter converter, "test/pandoc_input/strong_hi.md", "test/pandoc_output/strong_hi.html"
    end

    def test_underscored()
        # Options with underscores following Ruby naming conventions
        converter = Paru::Pandoc.new do
            from "markdown"
            to "html"
            self_contained
            metadata "lang='en'"
        end

        run_converter converter, "test/pandoc_input/hello.md", "test/pandoc_output/self_contained_hello.html"
    end

    def test_simple_conversion_with_spaces()
        converter = Paru::Pandoc.new do
            from "markdown"
            to "html"
            output "test/pandoc_output/strong hi.html"
        end

        run_converter converter, "test/pandoc_input/strong hi.md", "test/pandoc_output/strong hi.html", true
    end

    def test_with_bib()
        converter = Paru::Pandoc.new do
            from "markdown"
            to "html"
            bibliography "test/pandoc_input/bibliography.bib"
        end

        run_converter converter, "test/pandoc_input/simple_cite.md", "test/pandoc_output/simple_cite.html"
    end
    
    def test_with_bib_with_spaces()
        converter = Paru::Pandoc.new do
            from "markdown"
            to "html"
            bibliography "test/pandoc_input/my bibliography.bib"
        end

        run_converter converter, "test/pandoc_input/simple_cite.md", "test/pandoc_output/simple_cite.html"
    end

    def test_pandoc2yaml()
        require_relative '../lib/paru/pandoc2yaml'

        input = "test/pandoc_input/simple_yaml_metadata.md"
        output = File.read "test/pandoc_output/simple_yaml_metadata.yaml"

        result = Paru::Pandoc2Yaml.extract_metadata input
        assert_equal output, result
    end

    def test_convert_file()
        converter = Paru::Pandoc.new do
            from "markdown"
            to "html"
            bibliography "test/pandoc_input/my bibliography.bib"
        end

        output = converter.convert_file "test/pandoc_input/simple_cite.md"
        assert_equal output, File.read("test/pandoc_output/simple_cite.html") 
    end

    def test_throw_error_when_filter_crashes()
        converter = Paru::Pandoc.new do
            from "markdown"
            to "markdown"
            filter "./test/filters/crashing_filter.rb"
        end

        assert_raises Paru::Error do
            converter << "This is *a* string"
        end
    end

    def test_throw_error_when_bibliography_is_missing()
        converter = Paru::Pandoc.new do
            from "markdown"
            to "markdown"
            bibliography "some_non_existing_file.bib"
        end

        assert_raises Paru::Error do
            converter << "This is *a* string"
        end
    end

end
