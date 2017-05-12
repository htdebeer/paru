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
    # shown in the following examples:
    #
    # @example Identity filter
    #     Paru::Filter.run do
    #         # nothing
    #     end
    #
    # @example Remove horizontal lines
    #     Paru::Filter.run do
    #       with "HorizontalRule" do |rule|
    #           if rule.has_parent? then
    #               rule.parent.delete rule
    #           else
    #               rule.outer_markdown = ""
    #           end
    #       end
    #     end
    class Filter

        # Run the filter specified by block. In the block you specify
        # selectors and actions to be performed on selected nodes. In the
        # example below, the selector is "Image", which selects all image
        # nodes. The action is to prepend the contents of the image's caption
        # by the string "Figure. ".
        #
        # @param block [Proc] the filter specification
        #
        # @example Add 'Figure' to each image's caption
        #   Paru::Filter.run do
        #       with "Image" do |image|
        #           image.inner_markdown = "Figure. #{image.inner_markdown}"
        #       end
        #   end
        def self.run(&block)
            Filter.new().filter(&block)
        end


        # The Document node from JSON formatted pandoc document structure
        # on STDIN that is being filtered
        #
        # @return [Document] create a new Document node from a pandoc AST from
        #   JSON from STDIN
        def document()
            PandocFilter::Document.from_JSON $stdin.read
        end

        # Create a filter using +block+.
        #
        # @param block [Proc] a block specifying selectors and actions
        # @return [JSON] a JSON string with the filtered pandoc AST
        def filter(&block)
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
        #
        # @return [Node] the node that is currently being processed
        def current_node()
            @filtered_nodes.last
        end

        # Specify what nodes to filter with a +selector+. If the +current_node+
        # matches that selector, it is passed to the block to this +with+ method.
        #
        # @param selector [String] a selector string 
        # @yield [Node] the current node if it matches the selector
        def with(selector)
            @selectors[selector] = Selector.new selector unless @selectors.has_key? selector
            yield current_node if @selectors[selector].matches? current_node, @filtered_nodes
        end

        # While running a filter you can access the document's metadata through
        # the +metadata+ method.
        #
        # @return [Meta] the filtered document's metadata
        def metadata()
            @doc.meta
        end

    end
end
