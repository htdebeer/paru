#--
# Copyright 2015, 2016, 2017 Huub de Beer <Huub@heerdebeer.org>
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
        # A mixin to add inner_markdown and outer_markdown properties to Nodes
        module Markdown
            require_relative "../pandoc"
            require_relative "./document"

            # A Paru::Pandoc converter from JSON to markdown
            AST2MARKDOWN = Paru::Pandoc.new do
                from "json"
                to "markdown"
            end

            # A Paru::Pandoc converter from markdown to JSON
            MARKDOWN2JSON = Paru::Pandoc.new do
                from "markdown"
                to "json"
            end

            # Get the markdown representation of this Node, including the Node
            # itself.
            #
            # @return [String] the outer markdown representation of this Node
            def outer_markdown()
                temp_doc = PandocFilter::Document.fragment [self]
                AST2MARKDOWN << temp_doc.to_JSON
            end

            # Set the markdown representation of this Node: replace this Node
            # by the Node represented by the markdown string. If an inline
            # node is being replaced and the replacement has more than one
            # paragraph, only the contents of the first paragraph is used
            #
            # @param markdown [String] the markdown string to replace this
            #   Node
            #
            # @example Replacing all horizontal lines by a Plain node saying "hi"
            #   Paru::Filter.run do
            #       with "HorizontalLine" do |line|
            #           line.outer_markdown = "hi"
            #       end
            #   end
            #       
            def outer_markdown=(markdown)
                json = MARKDOWN2JSON << markdown
                temp_doc = PandocFilter::Document.from_JSON json

                if not has_parent? or is_root?
                    @children = temp_doc.children
                else
                    # replace current node by new nodes
                    # There is a difference between inline and block nodes
                    current_index = parent.find_index self

                    # By default, pandoc creates a Block level node when
                    # converting a string. However, if the original is a
                    # inline level node, so should its replacement node(s) be.
                    # Only using first block node (paragraph?)
                    if is_inline?
                        temp_doc = temp_doc.children.first
                        
                        if not temp_doc.children.all? {|node| node.is_inline?}
                            raise Error.new "Cannot replace the inline level node represented by '#{outer_markdown}' with markdown that converts to block level nodes: '#{markdown}'."
                        end
                        
                    end
                        
                    index = current_index
                    temp_doc.each do |child|
                        index += 1
                        parent.insert index, child
                    end
                    # Remove the original node
                    parent.remove_at current_index
                end

            end

            # Get the markdown representation of this Node's children
            #
            # @return [String] the inner markdown representation of this Node
            #
            # @example Replace all occurrences of "hello" by "world" in all paragraphs
            #   Paru::Filter.run do
            #       with "Para" do |p|
            #           p.inner_markdown = p.inner_markdown.gsub "hello", "world"
            #       end
            #   end         
            #
            def inner_markdown()
                temp_doc = PandocFilter::Document.fragment @children
                AST2MARKDOWN << temp_doc.to_JSON
            end

            # Replace this Node's children with the Nodes represented by the
            # markdown string
            #
            # @param markdown [String] the markdown string to replace this
            #   Node's children
            #
            # @example Replace all occurrences of "hello" by "world" in all paragraphs
            #   Paru::Filter.run do
            #       with "Para" do |p|
            #           p.inner_markdown = p.inner_markdown.gsub "hello", "world"
            #       end
            #   end         
            #
            def inner_markdown=(markdown)
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
                            @children = temp_doc.children.first.children
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
