module Paru

    require_relative "./selector"
    require_relative "filter/document"

    PANDOC_BLOCK = [
        "Plain",
        "Para",
        "CodeBlock",
        "RawBlock",
        "BlockQuote",
        "OrderedList",
        "BulletList",
        "DefinitionList",
        "Header",
        "HorizontalRule",
        "Table",
        "Div",
        "Null"
    ]
    PANDOC_INLINE = [
        "Str",
        "Emph",
        "Strong",
        "Strikeout",
        "Superscript",
        "Subscript",
        "SmallCaps",
        "Quoted",
        "Cite",
        "Space",
        "SoftBreak",
        "LineBreak",
        "Math",
        "RawInline",
        "Link",
        "Image",
        "Note",
        "Span"
    ]
    PANDOC_TYPES = PANDOC_BLOCK + PANDOC_INLINE
    
    class Filter

        def self.run &block
            Filter.new().filter(&block)
        end

        def document
            ast = JSON.parse $stdin.read

            # todo: add some version checking.
            version = ast["pandoc-api-version"]
            meta = ast["meta"]
            contents = ast["blocks"]

            document = PandocFilter::Document.new version, meta, contents
            document
        end

        def filter &block
            @selectors = Hash.new
            @filtered_nodes = []
            @doc = document
            
            @doc.each_depth_first do |node|
                @filtered_nodes.push node
                instance_eval(&block)
            end
            
            puts @doc.to_json
        end

        def current_node
            @filtered_nodes.last
        end

        def with selector
            @selectors[selector] = Selector.new selector unless @selectors.has_key? selector
            yield current_node if @selectors[selector].matches? current_node, @filtered_nodes
        end

        def metadata
            @doc.meta
        end

    end
end
