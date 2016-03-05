require "minitest/autorun"

require_relative "../lib/paru"

class FilterTest < MiniTest::Test

    def setup
    end

    def filter input
        pandoc2json_with_identity = Paru::Pandoc.new do
            from "markdown" 
            to "json"
            filter "examples/filters/identity.rb"
        end

        json2pandoc = Paru::Pandoc.new do
            from "json"
            to "markdown"
            standalone
        end

        filtered_input = pandoc2json_with_identity << input
        json2pandoc << filtered_input
    end

    def reformat input
        pandoc2pandoc = Paru::Pandoc.new do
            from "markdown"
            to "markdown"
            standalone
        end

        pandoc2pandoc << input
    end

    def assert_filtered_input_equals_input dir
        Dir.glob("test/pandoc_input/#{dir}/*.md") do |path|

            input = reformat (File.read path)
            output = ""
           
            assert_output nil, "" do
                output = filter input
            end
                
            assert_equal input, output, "Failure filtering #{path}" 
        end
    end

    def test_inline_elements
        assert_filtered_input_equals_input "inline"
    end

    def test_block_elements
        assert_filtered_input_equals_input "block"
    end

    def test_metadata_elements
        assert_filtered_input_equals_input "metadata"
    end
end
