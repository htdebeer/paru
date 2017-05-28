require "minitest/autorun"

require_relative "../lib/paru/pandoc.rb"

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
        assert_equal output, converted_input
    end

    def test_info()
      info = Paru::Pandoc.info
      assert_match(/\d+\.\d+/, info[:version])
      assert_match(/\.pandoc$/, info[:data_dir])
    end

    def test_simple_conversion()
        converter = Paru::Pandoc.new do
            from "markdown"
            to "html"
        end

        run_converter converter, "test/pandoc_input/strong_hi.md", "test/pandoc_output/strong_hi.html"
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
end
