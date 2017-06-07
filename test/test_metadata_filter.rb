require_relative "./test_filter.rb"
require_relative "../lib/paru"
require_relative "../lib/paru/filter.rb"
require_relative "../lib/paru/filter_error.rb"
require_relative "../lib/paru/filter/document.rb"

class MetadataFilterTest < FilterTest


    
    def test_add_today()
        output = filter_file("test/pandoc_input/add_today.md") do
            metadata.yaml <<~YAML
                ---
                date: #{Date.today.to_s}
                ...
            YAML
            metadata.yaml <<~YAML
                ---
                date: #{Date.today.to_s}
                ...
            YAML
        end
        assert_match(/#{Date.today.to_s}/, output)
    end

    def test_removing_all_keys()
        has_title = true
        filter_file_and_equal_file(
            "test/pandoc_input/procent_based_metadata.md",
            "test/pandoc_output/procent_based_metadata_cleared.md"
        ) do
            metadata.delete("date")
            metadata.delete("author")
            metadata.delete("title")
            has_title = metadata.has? "title"
        end
        assert(has_title == false)
    end

    def test_add_subtitle()
        subtitle = "---\nsubtitle: About bold code!\n---"
        has_subtitle = false
        filter_file_and_equal_file(
            "test/pandoc_input/bold_code.md",
            "test/pandoc_output/bold_code_with_subtitle.md"
        ) do
            metadata.yaml(subtitle)
            has_subtitle = metadata.has? "subtitle"
        end
        assert(has_subtitle)

        has_subtitle = false
        filter_file_and_equal_file(
            "test/pandoc_input/bold_code.md",
            "test/pandoc_output/bold_code_with_subtitle.md"
        ) do
            metadata.set("", subtitle)
            has_subtitle = metadata.has? "subtitle"
        end
        assert(has_subtitle)
    end

    def test_add_sub_property()
        filter_file_and_equal_file(
            "test/pandoc_input/bold_code.md",
            "test/pandoc_output/bold_code_sub_property.md"
        ) do
            metadata.yaml <<~YAML
                ---
                property:
                    sub: value
                ---
            YAML
        end

        filter_file_and_equal_file(
            "test/pandoc_output/bold_code_sub_property.md",
            "test/pandoc_output/bold_code_sub_property2.md"
        ) do
            metadata.set "property", <<~YAML
                ---
                sub2: value
                ---
            YAML
        end

        filter_file_and_equal_file(
            "test/pandoc_output/bold_code_sub_property.md",
            "test/pandoc_output/bold_code_sub_property3.md"
        ) do
            metadata.replace "property", <<~YAML
                ---
                sub2: value
                ---
            YAML
        end
    end

end
