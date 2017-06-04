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

        # A mixin to add inner_markdown properties to Nodes for which it makes
        # sense to have an inner_markdown.
        module InnerMarkdown

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
                if has_children?
                    temp_doc = PandocFilter::Document.fragment @children
                    AST2MARKDOWN << temp_doc.to_JSON
                elsif has_string?
                    @string
                end
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
                    if markdown.nil? or markdown.empty?
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
