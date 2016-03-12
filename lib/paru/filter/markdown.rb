module Paru
    module PandocFilter
        module Markdown

            require_relative "../pandoc"
            require_relative "./document"

            AST2MARKDOWN = Paru::Pandoc.new do
                from "json"
                to "markdown"
            end
                
            MARKDOWN2JSON = Paru::Pandoc.new do
                from "markdown"
                to "json"
            end

            def outerMarkdown 
                tempDoc = PandocFilter::Document.fragment [self]
                AST2MARKDOWN << tempDoc.to_json
            end

            def outerMarkdown=
                # not implemented yet
            end

            def innerMarkdown
                tempDoc = PandocFilter::Document.fragment @children
                AST2MARKDOWN << tempDoc.to_json
            end

            def innerMarkdown= markdown
                json = MARKDOWN2JSON << markdown
                meta, contents = JSON.parse json
                tempDoc = PandocFilter::Document.new meta, contents
                @children = tempDoc.children[0].children
            end
        end
    end
end
