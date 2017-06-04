require "minitest/autorun"

require_relative "../lib/paru/metadata.rb"

class MetadataTest < MiniTest::Test

    SIMPLE_YAML = "---\nkey: value\n..."
    COMPLEX_YAML = <<~YAML
        ---
        key: value
        keywords: [one, two, three]
        pandocomatic:
            pandoc:
                from: markdown
                to: html
                toc: true
        ...
    YAML

    def setup
    end

    def test_empty_yaml()
        metadata = Paru::Metadata.from_yaml ""
        assert_empty(metadata.children)
    end

    def test_simple_property()
        metadata = Paru::Metadata.from_yaml SIMPLE_YAML
        assert_equal("value", metadata.get("key").inner_markdown.strip)
    end

    def test_complex_property()
        metadata = Paru::Metadata.from_yaml COMPLEX_YAML
        assert_equal("value", metadata.get("key").inner_markdown.strip)
        assert_equal("html", metadata.get("pandocomatic.pandoc.to").inner_markdown.strip)
    end
    
    def test_caching_yaml_strings()
        metadata = Paru::Metadata.from_yaml SIMPLE_YAML
        metadata = Paru::Metadata.from_yaml COMPLEX_YAML

        assert(Paru::Metadata.cache.has_key? SIMPLE_YAML)
        assert(Paru::Metadata.cache.has_key? COMPLEX_YAML)

        metadata = Paru::Metadata.cache[SIMPLE_YAML]
        assert_equal("value", metadata.get("key").inner_markdown.strip)

        metadata = Paru::Metadata.cache[COMPLEX_YAML]
        assert_equal("value", metadata.get("key").inner_markdown.strip)
        assert_equal("html", metadata.get("pandocomatic.pandoc.to").inner_markdown.strip)
    end

end
