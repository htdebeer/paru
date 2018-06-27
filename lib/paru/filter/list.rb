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
require_relative "./block.rb"
require_relative "./inline.rb"

module Paru
    module PandocFilter
        # A List node is a base node for various List node types
        class List < Block

            # Create a new List node based on contents
            #
            # @param contents [Array] the contents of the list
            # @param node_class [Node = PandocFilter::Block] the contents are {Inline} nodes
            def initialize(contents, node_class = Block)
                super []
                contents.each do |item|
                    @children.push node_class.new item
                end
            end

            # Create an AST representation of this List node
            def ast_contents()
                @children.map {|child| child.ast_contents}
            end

            # Has this List node block contents?
            #
            # @return [Boolean] true
            def has_block?()
                true
            end

            # Convert this List to an array of markdown strings
            #
            # @return [String[]]
            def to_array()
                @children.map do |block|
                    block.children.map{|c| c.markdown.strip}.join("\n")
                end
            end

        end
    end
end
