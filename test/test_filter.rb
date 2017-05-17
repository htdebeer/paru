require "minitest/autorun"

require_relative "../lib/paru"

class FilterTest < MiniTest::Test

    def setup
    end

    def run_example_filter filter_file, input_file, output_file
        pandoc2json = Paru::Pandoc.new do
            from "markdown"
            to "json"
            filter filter_file
        end

        json2pandoc = Paru::Pandoc.new do
            from "json"
            to "markdown"
            standalone
        end

        filtered_input = pandoc2json << File.read(input_file)
        filtered_output = json2pandoc << filtered_input
        assert_equal filtered_output, File.read(output_file), "Failure running #{filter_file} on #{input_file}"
    end

    def filter input
        pandoc2json_with_identity = Paru::Pandoc.new do
            from "markdown" 
            to "json"
            filter "test/filters/identity_filter.rb"
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

            puts "\t#{path}"

            assert_equal input, output, "Failure filtering #{path}" 
        end
    end

    def test_inline_elements
        puts "Testing inline elements"
        assert_filtered_input_equals_input "inline"
    end

    def test_block_elements
        puts "Testing block elements"
        assert_filtered_input_equals_input "block"
    end

    def test_metadata_elements
        puts "Testing metadata elements"
        assert_filtered_input_equals_input "metadata"
    end

    def test_capitalize_first_sentence
        puts "Testing example filter capitalize_first_sentence.rb"
        run_example_filter "test/filters/capitalize_first_sentence.rb",
            "test/pandoc_input/paragraphs.md",
            "test/pandoc_output/paragraphs.md"
    end

    def test_number_figures
        puts "Testing example filter number_figures.rb"
        run_example_filter "test/filters/number_figures.rb",
            "test/pandoc_input/figures.md",
            "test/pandoc_output/figures.md"
    end

    def test_number_figures_per_chapter
        puts "Testing example filter number_figures_per_chapter.rb"
        run_example_filter "test/filters/number_figures_per_chapter.rb",
            "test/pandoc_input/figures_in_sections.md",
            "test/pandoc_output/figures_in_sections.md"
    end

    def test_example_blocks
        puts "Testing example filter example.rb"
        run_example_filter "test/filters/example.rb",
            "test/pandoc_input/example_blocks.md",
            "test/pandoc_output/example_blocks.md"
    end

    def test_insert_code_block
        puts "Testing insert_code_block.rb"
        run_example_filter "test/filters/insert_code_block.rb",
            "test/pandoc_input/insert_code_blocks.md",
            "test/pandoc_output/insert_code_blocks.md"
    end

    def test_insert_document
        puts "Testing insert_document.rb"
        run_example_filter "test/filters/insert_document.rb",
            "test/pandoc_input/insert_document.md",
            "test/pandoc_output/insert_document.md"
    end

    def test_delete_horizontal_rules
        puts "Testing delete horizontal rules"
        run_example_filter "test/filters/delete_horizontal_rules.rb",
            "test/pandoc_input/delete_horizontal_rules.md",
            "test/pandoc_output/delete_horizontal_rules.md"
    end
end
