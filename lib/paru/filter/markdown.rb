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

      def outer_markdown 
        temp_doc = PandocFilter::Document.fragment [self]
        AST2MARKDOWN << temp_doc.to_json
      end

      def outer_markdown= markdown
        json = MARKDOWN2JSON << markdown
        temp_doc = PandocFilter::Document.from_JSON json

        if not has_parent? or is_root?
          @children = temp_doc.children
        else
          # replace current node by new nodes
          # There is a difference between inline and block nodes
          current_index = parent.find_index self
          index = current_index
          temp_doc.each do |child|
            index += 1
            parent.insert index, child
          end
          # Remove the original node
          parent.remove_at current_index
        end

      end

      def inner_markdown
        temp_doc = PandocFilter::Document.fragment @children
        AST2MARKDOWN << temp_doc.to_json
      end

      def inner_markdown= markdown
        if has_string?
          @string = markdown
        else
          if markdown.empty?
            @children = []
          else 
            json = MARKDOWN2JSON << markdown
            temp_doc = PandocFilter::Document.from_JSON json
            temp_doc.children.each {|c| c.parent = @parent}

            if has_inline?
              @children = temp_doc.children[0].children
            elsif has_block?
              @children = temp_doc.children
            else
              # Unknown; what to do here?
            end
          end
        end
      end
    end
  end
end
