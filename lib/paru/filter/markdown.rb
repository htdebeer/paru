#--
# Copyright 2015, 2016 Huub de Beer <Huub@heerdebeer.org>
#
# This file is part of Paru
#
# Paru is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Paru is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Paru.  If not, see <http://www.gnu.org/licenses/>.
#++
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
        AST2MARKDOWN << temp_doc.to_JSON
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
        AST2MARKDOWN << temp_doc.to_JSON
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
