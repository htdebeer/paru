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
require_relative "./list.rb"

module Paru
    module PandocFilter
        # A DefinitionList is a list of term-definition pairs, respecitively an Inline list and a Block list.
        class DefinitionList < Block
            # Create a new DefinitionList node
            #
            # @param contents [Array] the contents of this definition list.
            def initialize(contents)
                super []
                contents.each do |item|
                    @children.push DefinitionListItem.new item
                end
            end

            # Create an AST representation of this DefinitionList node
            def ast_contents
                @children.map {|child| child.to_ast}
            end

            # Convert this DefinitionList to a hash of term => definitions
            #
            # @return [Array]
            def to_array()
                @children.map do |def_item|
                    def_item.to_array 
                end
            end

            # Create a new DefinitionList based on a hash of term =>
            # definitions
            #
            # @param definitions [Array] Array of arrays with terms and their definitions
            # @return [DefinitionList] 
            def self.from_array(definitions)
                ast_items = definitions.map do |definition| 
                    term = Block.from_markdown(definition[0]).ast_contents
                    defin = List.from_markdown(definition[1]).children.map{|c| c.to_ast}
                    warn defin
                    [term, defin]
                end
                DefinitionList.new ast_items
            end

        end
    end
end
