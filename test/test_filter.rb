require "minitest/autorun"
require "tempfile"

require_relative "../lib/paru"
require_relative "../lib/paru/filter.rb"
require_relative "../lib/paru/filter_error.rb"
require_relative "../lib/paru/filter/document.rb"
require_relative "../lib/paru/filter/code_block.rb"
require_relative "../lib/paru/filter/ordered_list.rb"
require_relative "../lib/paru/filter/bullet_list.rb"
require_relative "../lib/paru/filter/definition_list.rb"
require_relative "../lib/paru/filter/table.rb"

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
        
        json = pandoc2json << string

        input = StringIO.new(json)
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
    def reformat(input)
        pandoc2pandoc = Paru::Pandoc.new do
            from "markdown"
            to "markdown"
            standalone
        end

        reformatted_input = pandoc2pandoc << input
        reformatted_input.chop
    end

    def test_inline_elements()
        Dir.glob("test/pandoc_input/inline/*.md") do |path|
            node_name = File.basename path, ".md"
            original_input = File.read(path)
            input = reformat original_input
            output = filter_string(input) do
                with "#{node_name}" do |node|
                    if "#{node_name}" == "Image"
                      # Skip. With the introduction of the complex Figure, a
                      # single Image is recognized as a Figure by default. As
                      # a result, this test no longer works for the Image
                      # inline element.
                    else
                      contents = node.markdown
                      node.markdown = contents
                    end

                    if node_name != "Cite"
                        in_contents = node.inner_markdown
                        node.inner_markdown = in_contents
                    end
                end
            end.chop

            assert_equal input, output, "Failure filtering #{path}" 
        end

    end

    def test_block_elements()
        Dir.glob("test/pandoc_input/block/*.md") do |path|
            node_name = File.basename path, ".md"
            original_input = File.read(path)
            input = reformat original_input
            output = filter_string(input) do
                with "#{node_name}" do |node|
                    contents = node.markdown
                    node.markdown = contents

                    if [
                            "Header", 
                            "Para", 
                            "Plain", 
                            "Div", 
                            "CodeBlock", 
                            "RawBlock"
                    ].include? node_name
                        in_contents = node.inner_markdown
                        node.inner_markdown = in_contents
                    end
                end
            end.chop
            
            assert_equal input, output, "Failure filtering #{path}" 
        end
    end

    def test_metadata_elements()
        #assert_filtered_input_equals_input "metadata"
    end

    def test_capitalize_first_sentence()
        filter_file_and_equal_file(
            "test/pandoc_input/paragraphs.md",
            "test/pandoc_output/paragraphs.md"
        ) do
            with "Header +1 Para" do |p|
                text = p.markdown
                first_line = text.slice(0, 10).upcase
                rest = text.slice(10, text.size)
                p.markdown = first_line + rest
            end
        end
    end

    def test_capitalize_list_elements()
        filter_file_and_equal_file(
            "test/pandoc_input/bullet_list_with_followers.md",
            "test/pandoc_output/bullet_list_with_followers.md"
        ) do
            with "BulletList > Str" do |str|
                str.string = str.string.upcase
            end
        end
    end

    def test_number_figures()
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

    def test_underline()
      filter_file_and_equal_file(
        "test/pandoc_input/underlined.md",
        "test/pandoc_output/underlined.md"
      ) do
        with "Underline" do |u|
          u.inner_markdown = "underlined"
        end
      end
    end

    def test_number_figures_per_chapter()
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

    def test_example_blocks()
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

    def test_deep_descendent()
        filter_file_and_equal_file(
            "test/pandoc_input/deep_descendent.md",
            "test/pandoc_output/deep_descendent.md"
        ) do
            with "BulletList > OrderedList > Plain" do |item|
                item.inner_markdown = item.inner_markdown.upcase
            end
        end
    end

    def test_insert_code_block()
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

    def test_insert_document()
        filter_file_and_equal_file(
            "test/pandoc_input/insert_document.md",
            "test/pandoc_output/insert_document.md"
        ) do
            with "Para" do |paragraph|
                if paragraph.inner_markdown.lines.length == 1
                    command, path = paragraph.inner_markdown.strip.split " "
                    if command == "::paru::insert"
                        markdown = File.read path.gsub(/\\_/, "_")
                        paragraph.markdown = markdown
                    end
                end
            end
        end
    end

    def test_delete_horizontal_rules()
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
    
    def test_classes()
        filter_file_and_equal_file(
            "test/pandoc_input/classes.md",
            "test/pandoc_output/classes.md"
        ) do
            with "Header.section" do |title|
              title.inner_markdown = "Section: #{title.inner_markdown}"
            end
        end
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

    def test_reading_problematic_document()
        api_version = Paru::PandocFilter::CURRENT_PANDOC_VERSION.join(".")

        json = File.read("test/pandoc_input/json_strong_hi-faulty_json.json")
        err = assert_raises Paru::FilterError do
            Paru::PandocFilter::Document.from_JSON json        
        end

        assert_match(/#{api_version}/, err.message)

        # use '_debug' metadata property to show warning
        json = File.read("test/pandoc_input/json_strong_hi-previous_version.json")
        _, err = capture_io do
            Paru::PandocFilter::Document.from_JSON json            
        end

        assert_match(/#{api_version}/, err)
    end

    def test_code_inline()
        filter_file_and_equal_file(
            "test/pandoc_input/bold_code.md",
            "test/pandoc_output/bold_code.md"
        ) do
            with "Code" do |code|
                code.markdown = "**#{code.markdown}**"
            end
        end
    end
    
    def test_image_with_attributes()
        filter_file_and_equal_file(
            "test/pandoc_input/image_with_attributes.md",
            "test/pandoc_output/image_with_attributes.md"
        ) do
            with "Image" do |image|
	      caption = image.inner_markdown
	      if image.attr.has_key? "width"
	        caption += " (width=#{image.attr["width"]})"
              end
              if image.attr.has_key? "height"
                caption += " (height=#{image.attr["height"]})"
              end
              image.inner_markdown = caption
            end
        end
    end

    def test_replace_math_in_table()
        filter_file_and_equal_file(
            "test/pandoc_input/replace_math.md",
            "test/pandoc_output/replaced_math.md"
        ) do
            with "Math" do |m|
                key, value = m.string.split(".")
                values = value.split("_")
                m.markdown = "**#{key}**: *#{values.join(" ")}*"
            end
        end
    end

    def test_code_block_convenience()
        code = File.read("test/pandoc_input/some_js_code.js");

        # To code string
        code_string = "";
        filter_file("test/pandoc_input/from_code.md") do
            with "CodeBlock" do |c|
                code_string = c.to_code_string()
            end
        end

        assert_match(code_string, code);

        # From code string
        input = "replace this"
        output = filter_string(input) do
            with "Para" do |p|
                code_block = Paru::PandocFilter::CodeBlock.from_code_string code, "JavaScript"
                p.parent.replace(p, code_block)
            end
        end

        assert_match(output, File.read("test/pandoc_input/from_code.md"))

        # To file
        out_file = Tempfile.new("output_file.js")
        begin
            filter_file("test/pandoc_input/from_code.md") do
                with "CodeBlock" do |c|
                    c.to_file(out_file.path)
                end
            end
            out_contents = out_file.read
            assert_match(code, out_contents)
        ensure
            out_file.close
            out_file.unlink
        end
        
        # From file
        input = "replace this"
        output = filter_string(input) do
            with "Para" do |p|
                code_block = Paru::PandocFilter::CodeBlock.from_file "test/pandoc_input/some_js_code.js", "JavaScript"
                p.parent.replace(p, code_block)
            end
        end

        assert_match(output, File.read("test/pandoc_input/from_code.md"))
    end
    
    def test_ordered_list_convenience()
        list = []
        filter_file("test/pandoc_input/ordered_list.md") do
            with "OrderedList" do |o|
                list = o.to_array
            end
        end

        assert_includes list, "First item"
        assert_includes list, "Second *important* item"
        assert_includes list, "Third item"

        input_array = ["First item", "Second *important* item", "Third item"]

        input = "replace this"
        output = filter_string(input) do
            with "Para" do |p|
                list = Paru::PandocFilter::OrderedList.from_array input_array
                p.parent.replace(p, list)
            end
        end

        assert_match(output, File.read("test/pandoc_input/ordered_list.md"))
    end
    
    def test_bullet_list_convenience()
        list = []
        filter_file("test/pandoc_input/bullet_list.md") do
            with "BulletList" do |b|
                list = b.to_array
            end
        end

        assert_includes list, "First item"
        assert_includes list, "Second *important* item"
        assert_includes list, "Third item"

        input_array = ["First item", "Second *important* item", "Third item"]

        input = "replace this"
        output = filter_string(input) do
            with "Para" do |p|
                list = Paru::PandocFilter::BulletList.from_array input_array
                p.parent.replace(p, list)
            end
        end

        assert_match(output, File.read("test/pandoc_input/bullet_list.md"))
    end

    def test_definition_list_item_children()
        paras = []
        filter_file("test/pandoc_input/definition_list_paras.md") do
            with "Para" do |p|
                paras << p
            end
        end

        # two outside and three inside the list
        assert_equal(5, paras.length)
    end

    def test_definition_list_item_descendent_selector()
        paras = []
        filter_file("test/pandoc_input/definition_list_paras.md") do
            with "DefinitionList > Para" do |p|
                paras << p
            end
        end

        # only the three inside the list
        assert_equal(3, paras.length)
    end

    def test_definition_list_convenience()
        list = []
        filter_file("test/pandoc_input/definition_list.md") do
            with "DefinitionList" do |d|
                list = d.to_array
            end
        end

        assert_includes list[0], "Term 1"
        assert_includes list[0], "Definition 1"
        assert_includes list[1], "Term 2 with *inline markup*"
        assert_includes list[1], "Definition 2\n\n    {some code, part of def 2}\n\nAnother paragraph"
       
        input_array = [
            ["Term 1", "Definition 1"],
            ["Term 2 with *inline markup*", "Definition 2\n\n    {some code, part of def 2}\n\nAnother paragraph"]
        ]

        input = "replace this"
        output = filter_string(input) do
            with "Para" do |p|
                list = Paru::PandocFilter::DefinitionList.from_array input_array
                p.parent.replace(p, list)
            end
        end

        assert_match(output, File.read("test/pandoc_input/definition_list.md"))
    end

    def test_table_convenience()
        data = []
        filter_file("test/pandoc_input/table.md") do
            with "Table" do |t|
                data = t.to_array
            end
        end

        assert_equal data.length, 3
        assert_equal data[2].length, 2

        filter_file("test/pandoc_input/table.md") do
            with "Table" do |t|
                data = t.to_array(headers: true)
            end
        end

        assert_equal data.length, 4
        assert_equal data[1].length, 2

        input_data = [["No", "String"], ["1", "Hello"], ["2", "Hi"], ["3", "Goodbye"]]
        input = "replace this"
        output = filter_string(input) do
            with "Para" do |p|
                table = Paru::PandocFilter::Table.from_array input_data, headers: true, caption: "A list of greetings."
                p.parent.replace(p, table)
            end
        end

        assert_match(output, File.read("test/pandoc_input/table.md"))
        

        # To file
        csv = File.read("test/pandoc_output/table.csv")
        out_file = Tempfile.new("output_file.csv")
        begin
            filter_file("test/pandoc_input/table.md") do
                with "Table" do |t|
                    t.to_file(out_file.path, headers: true)
                end
            end
            out_contents = out_file.read
            assert_match(csv, out_contents)
        ensure
            out_file.close
            out_file.unlink
        end

        # From file
        input = "replace this"
        output = filter_string(input) do
            with "Para" do |p|
                table = Paru::PandocFilter::Table.from_file "test/pandoc_output/table.csv", headers: true, caption: "A list of greetings."
                p.parent.replace(p, table)
            end
        end

        assert_match(output, File.read("test/pandoc_input/table.md"))
    end

    def test_any_selector()
        filter_file_and_equal_file(
            "test/pandoc_input/simple_sentence.md",
            "test/pandoc_output/tagged_sentence.md"
        ) do
            with "*" do |node|
              if node.is_inline? then
                node.inner_markdown = "TAG:(#{node.inner_markdown})"
              end
            end
        end
    end

    def test_before_after() 
      _, err = capture_io do
        filter_file("test/pandoc_input/simple_sentence.md") do
          before do 
            warn "before"  
          end

          with "*" do
            warn "during"
          end

          after do
            warn "after"
          end
        end
      end
      
      expected = <<END
before
during
during
during
during
during
during
during
during
during
during
during
after
END

      assert_equal expected, err
    end

    def test_first_current_node_exists()
        blocks = 0
        filter_file("test/pandoc_input/hello.md") do
          blocks += 1 if current_node.is_block?
        end

        assert_equal(1, blocks)
    end
end
