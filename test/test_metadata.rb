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

    def test_empty_metadata()
        metadata = Paru::Metadata.from_yaml ""
        assert_empty(metadata.children)
        yaml = Paru::Metadata.to_yaml metadata
        assert_equal("", yaml)
    end

    def test_simple_property()
        metadata = Paru::Metadata.from_yaml SIMPLE_YAML
        assert_equal("value", metadata.get("key").inner_markdown.strip)
        hash = Paru::Metadata.to_hash metadata
        assert_includes(hash.keys, "key")
        assert_includes(hash.values, "value")
    end

    def test_complex_property()
        metadata = Paru::Metadata.from_yaml COMPLEX_YAML
        assert_equal("value", metadata.get("key").inner_markdown.strip)
        assert_equal("html", metadata.get("pandocomatic.pandoc.to").inner_markdown.strip)

        hash = Paru::Metadata.to_hash metadata
        assert_includes(hash["keywords"], "two")
        assert_includes(hash["pandocomatic"]["pandoc"].keys, "to") 
        assert_includes(hash["pandocomatic"]["pandoc"].values, "markdown") 
    end
    
    def test_caching_converted_values()
        metadata = Paru::Metadata.from_yaml SIMPLE_YAML
        hash = Paru::Metadata.to_hash metadata
        metadata = Paru::Metadata.from_yaml COMPLEX_YAML
        hash = Paru::Metadata.to_hash metadata

        assert(Paru::Metadata.cache.has_key? SIMPLE_YAML)
        assert(Paru::Metadata.cache.has_key? COMPLEX_YAML)
        assert(Paru::Metadata.cache.has_key? metadata)
        
        metadata = Paru::Metadata.cache[SIMPLE_YAML]
        assert_equal("value", metadata.get("key").inner_markdown.strip)
        assert(Paru::Metadata.cache.has_key? metadata)

        metadata = Paru::Metadata.cache[COMPLEX_YAML]
        assert_equal("value", metadata.get("key").inner_markdown.strip)
        assert_equal("html", metadata.get("pandocomatic.pandoc.to").inner_markdown.strip)

    end

    def test_clearing_cache()
        Paru::Metadata.from_yaml SIMPLE_YAML
        assert(Paru::Metadata.cache.has_key? SIMPLE_YAML)
        Paru::Metadata.clear(SIMPLE_YAML)
        assert(not(Paru::Metadata.cache.has_key?(SIMPLE_YAML)))

        Paru::Metadata.from_yaml COMPLEX_YAML
        assert(Paru::Metadata.cache.has_key? COMPLEX_YAML)
        Paru::Metadata.clear()
        assert(not(Paru::Metadata.cache.has_key?(COMPLEX_YAML)))
    end

end
