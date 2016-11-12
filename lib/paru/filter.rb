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
module Paru

  require_relative "./selector"
  require_relative "filter/document"

  PANDOC_BLOCK = [
    "Plain",
    "Para",
    "LineBlock",
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
      PandocFilter::Document.from_JSON $stdin.read
    end

    def filter &block
      @selectors = Hash.new
      @filtered_nodes = []
      @doc = document

      @doc.each_depth_first do |node|
        @filtered_nodes.push node
        instance_eval(&block)
      end

      puts @doc.to_JSON
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
