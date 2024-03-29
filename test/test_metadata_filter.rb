require "date"
require_relative "./test_filter.rb"
require_relative "../lib/paru"
require_relative "../lib/paru/filter.rb"
require_relative "../lib/paru/filter_error.rb"
require_relative "../lib/paru/filter/document.rb"

class MetadataFilterTest < FilterTest
    
    def test_add_today()
        output = filter_file("test/pandoc_input/add_today.md") do
          before do
            metadata["date"] = "#{Date.today.to_s}"
          end
        end
        assert_match(/#{Date.today.to_s}/, output)
    end

    def test_simple_metadata()
        filter_file_and_equal_file(
            "test/pandoc_input/hello.md",
            "test/pandoc_output/hello.md"
        ) do
            before do
              metadata['title'] = "Say hello to the world"
              metadata['date'] = "12-12-1812"
              metadata['author'] = "Huub de Beer"
            end
        end
    end
   
    # Running this test breaks with rake; run it manually 
    def do_not_test_simple_metadata_with_stop()
        number_of_times_run = 0
        filter_file_and_equal_file(
            "test/pandoc_input/hello.md",
            "test/pandoc_output/hello.md"
        ) do
            number_of_times_run += 1
            metadata['title'] = "Say hello to the world"
            metadata['date'] = "12-12-1812"
            metadata['author'] = "Huub de Beer"
            stop!
        end

        assert_equal(number_of_times_run, 1)
        
        number_of_times_run = 0
        filter_file_and_equal_file(
            "test/pandoc_input/hello.md",
            "test/pandoc_output/hello.md"
        ) do
            number_of_times_run += 1
            metadata['title'] = "Say hello to the world"
            metadata['date'] = "12-12-1812"
            metadata['author'] = "Huub de Beer"
        end
        
        assert_equal(number_of_times_run, 11)
    end

    def test_removing_all_keys()
        has_title = true
        filter_file_and_equal_file(
            "test/pandoc_input/procent_based_metadata.md",
            "test/pandoc_output/procent_based_metadata_cleared.md"
        ) do
            after do
              metadata.delete("date")
              metadata.delete("author")
              metadata.delete("title")
              has_title = metadata.has_key? "title"
            end
        end
        assert(has_title == false)
    end

    def test_add_subtitle()
        subtitle = "About bold code!"
        has_subtitle = false
        filter_file_and_equal_file(
            "test/pandoc_input/bold_code.md",
            "test/pandoc_output/bold_code_with_subtitle.md"
        ) do
            metadata["subtitle"] = subtitle
            has_subtitle = metadata.has_key? "subtitle"
        end
        assert(has_subtitle)
    end

    def test_add_sub_property()
        filter_file_and_equal_file(
            "test/pandoc_input/bold_code.md",
            "test/pandoc_output/bold_code_sub_property.md"
        ) do
            if not metadata.has_key? "property"
                metadata["property"] = {}
            end

            metadata["property"]["sub"]= "value"
        end

        filter_file_and_equal_file(
            "test/pandoc_output/bold_code_sub_property.md",
            "test/pandoc_output/bold_code_sub_property2.md"
        ) do
            if not metadata.has_key? "property"
                metadata["property"] = {}
            end

            metadata["property"]["sub2"] = "value"
        end

        filter_file_and_equal_file(
            "test/pandoc_output/bold_code_sub_property.md",
            "test/pandoc_output/bold_code_sub_property3.md"
        ) do
            metadata["property"] = {"sub2" => "value"}
        end
    end
end
