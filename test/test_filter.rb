require "minitest/autorun"

require_relative "../lib/paru"

class FilterTest < MiniTest::Unit::TestCase

    def setup
    end

    def filter input
        pandoc2json_with_identity = Paru::Pandoc.new do
            from "markdown" 
            to "json"
            filter "../examples/filters/identity.rb"
        end

        json2pandoc = Paru::Pandoc.new do
            from "json"
            to "markdown"
            standalone
        end

        json2pandoc << pandoc2json_with_identity << input
    end

    def assert_filtered_input_equals_input dir
        Dir.glob("pandoc_input/#{dir}/*.md") do |path|
            input = File.read path
            output = filter input
            assert_equal input, output    
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
