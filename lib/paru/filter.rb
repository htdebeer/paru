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

  require_relative "./selector"
  require_relative "filter/document"

  # Paru filter is a wrapper around pandoc's JSON api, which is based on
  # {pandoc-types}[https://hackage.haskell.org/package/pandoc-types-1.17.0.4/docs/Text-Pandoc-Definition.html].
  # Pandoc treats block elements and inline elements differently. 
  #
  # Pandoc's block elements are:

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

  # Pandoc's inline elements are

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

  # All of pandoc's type together:

  PANDOC_TYPES = PANDOC_BLOCK + PANDOC_INLINE


  # Filter is used to write your own pandoc filter in Ruby. A Filter is
  # almost always created and immediately executed via the +run+ method as

  class Filter

    def self.run &block
      Filter.new().filter(&block)
    end


    # Create a new Document node from JSON formatted pandoc document structure
    # on STDIN

    def document
      PandocFilter::Document.from_JSON $stdin.read
    end

    # Create a filter using +block+.

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


    # +current_node+ points to the node that is *now* being processed while
    # running this filter.

    def current_node
      @filtered_nodes.last
    end

    # Specify what nodes to filter with a +selector+. If the +current_node+
    # matches that selector, it is passed to the block to this +with+ method.

    def with selector
      @selectors[selector] = Selector.new selector unless @selectors.has_key? selector
      yield current_node if @selectors[selector].matches? current_node, @filtered_nodes
    end

    # While running a filter you can access the document's metadata through
    # the +metadata+ method.

    def metadata
      @doc.meta
    end

  end
end
