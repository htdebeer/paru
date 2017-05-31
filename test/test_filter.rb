require "minitest/autorun"

require_relative "../lib/paru"
require_relative "../lib/paru/filter.rb"

class FilterTest < MiniTest::Test

    def setup
    end

    def filter_string(string, &filter_specification)
        pandoc2json = Paru::Pandoc.new do
            from "markdown"
            to "json"
        end

        json2pandoc = Paru::Pandoc.new do
            from "json"
            to "markdown"
            standalone
        end

        input = StringIO.new(pandoc2json << string)
        output = StringIO.new
        
        Paru::Filter.new(input, output).filter(&filter_specification)
        
        result = json2pandoc << output.string
        return result
    end

    def filter_file(file, &filter_specification)
        filter_string(File.read(file), &filter_specification)
    end

    def filter_file_and_equal_file(input_file, output_file, &filter_specification)
        input = File.read(input_file)
        output = File.read(output_file)
        result = filter_string(input, &filter_specification)
        assert_equal(output.strip, result.strip)
    end

    def filter_input(filter_file, input_file)
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
        return filtered_output
    end

    # When converting from markdown to markdown, pandoc can outputs something
    # different than the input. So reformat the input to something pandoc
    # outputs first.
    def reformat input
        pandoc2pandoc = Paru::Pandoc.new do
            from "markdown"
            to "markdown"
            standalone
        end

        reformatted_input = pandoc2pandoc << input
        reformatted_input.chop
    end

    def assert_filtered_input_equals_input dir
        Dir.glob("test/pandoc_input/#{dir}/*.md") do |path|

            original_input = File.read(path)
            input = reformat original_input
            output = filter_string(input) do
                # nothing
            end.chop
            
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

    def test_capitalize_first_sentence
        filter_file_and_equal_file(
            "test/pandoc_input/paragraphs.md",
            "test/pandoc_output/paragraphs.md"
        ) do
            with "Header +1 Para" do |p|
                text = p.inner_markdown
                first_line = text.slice(0, 10).upcase
                rest = text.slice(10, text.size)
                p.inner_markdown = first_line + rest
            end
        end
    end

    def test_number_figures
        figure_counter = 0

        filter_file_and_equal_file(
            "test/pandoc_input/figures.md",
            "test/pandoc_output/figures.md"
        ) do
            with "Image" do |image|
                figure_counter += 1
                image.inner_markdown = "Figure #{figure_counter}. #{image.inner_markdown}"
            end
        end
    end

    def test_number_figures_per_chapter
        current_chapter = 0
        current_figure = 0;

        filter_file_and_equal_file(
            "test/pandoc_input/figures_in_sections.md",
            "test/pandoc_output/figures_in_sections.md"
        ) do
            with "Header" do |header|
                if header.level == 1 
                    current_chapter += 1
                    current_figure = 0

                    header.inner_markdown = "Chapter #{current_chapter}. #{header.inner_markdown}"
                end
            end

            with "Header + Image" do |image|
                current_figure += 1
                image.inner_markdown = "Figure #{current_chapter}.#{current_figure}. #{image.inner_markdown}"
            end
        end
    end

    def test_example_blocks
        example_count = 0

        filter_file_and_equal_file(
            "test/pandoc_input/example_blocks.md",
            "test/pandoc_output/example_blocks.md"
        ) do
            with "Div.example > Header" do |header|
                if header.level == 3 
                    example_count += 1
                    header.inner_markdown = "Example #{example_count}: #{header.inner_markdown}"
                end
            end

            with "Div.important" do |d|
                d.inner_markdown = d.inner_markdown + "\n\n*(important)*"
            end
        end
    end

    def test_insert_code_block
        filter_file_and_equal_file(
            "test/pandoc_input/insert_code_blocks.md",
            "test/pandoc_output/insert_code_blocks.md"
        ) do
            with "CodeBlock" do |code_block|
                command, path, *classes = code_block.string.strip.split " "
                if command == "::paru::insert"
                    code_block.string = File.read path.gsub(/\\_/, "_")
                    classes.each {|c| code_block.attr.classes.push c}
                end
            end
        end
    end

    def test_insert_document
        filter_file_and_equal_file(
            "test/pandoc_input/insert_document.md",
            "test/pandoc_output/insert_document.md"
        ) do
            with "Para" do |paragraph|
                if paragraph.inner_markdown.lines.length == 1
                    command, path = paragraph.inner_markdown.strip.split " "
                    if command == "::paru::insert"
                        markdown = File.read path.gsub(/\\_/, "_")
                        paragraph.outer_markdown = markdown
                    end
                end
            end
        end
    end

    def test_delete_horizontal_rules
        filter_file_and_equal_file(
            "test/pandoc_input/delete_horizontal_rules.md",
            "test/pandoc_output/delete_horizontal_rules.md"
        ) do
            with "HorizontalRule" do |rule|
                if rule.has_parent? then
                    rule.parent.delete rule
                end
            end
        end
    end
    
    def test_raw_latex()
        filter_file_and_equal_file(
            "test/pandoc_input/raw_latex.md",
            "test/pandoc_output/raw_latex.md"
        ) do
            with "Image" do |image|
                image.inner_markdown = "Figure. #{image.inner_markdown}"
            end
        end
    end


    def test_add_today()
        output = filter_file("test/pandoc_input/add_today.md") do
            metadata.yaml <<~YAML
                ---
                date: #{Date.today.to_s}
                ...
            YAML
        end
        assert_match(/#{Date.today.to_s}/, output)
    end

    def test_insert_paru_version_filter()
        version = lambda do |str|
            str.gsub "::paru::version", Paru::VERSION.join(".")
        end
        
        output = filter_file("test/pandoc_input/paru_version.md") do
            with "Str" do |str|
                str.string = version.call(str.string)
            end

            with "CodeBlock" do |code|
                code.string = version.call(code.string)
            end

            with "Link" do |link|
                link.target.url = version.call(link.target.url)
                link.target.title = version.call(link.target.title)
            end
        end

        assert_match(/#{Paru::VERSION.join(".")}/, output)
    end

    def test_world_to_moon()
        input = "hello **world**"
        output = filter_string(input) do 
            with "Str" do |s|
                if s.string == "world"
                    s.string = "moon"
                end
            end
        end
        assert_equal("hello **moon**\n", output)
    end

end
