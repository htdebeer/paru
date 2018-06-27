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
require_relative "./block.rb"
require_relative "./list.rb"
require_relative "./inline.rb"

module Paru
    module PandocFilter
        # A DefinitionListItem is a helper node to represent the pair of a term
        # and its definition in a DefinitionList
        #
        # @!attribute term
        #   @return [Block]
        #
        # @!attribute definition
        #   @return [List]
        class DefinitionListItem < Block
            attr_accessor :term, :definition

            # Create a new DefinitionListItem 
            #
            # @param item [Array] the [term, definition]
            def initialize(item)
                @term = Block.new item[0]
                @definition = List.new item[1]
            end

            # Create an AST representation of this DefinitionListItem
            def to_ast
                [
                    @term.ast_contents,
                    @definition.ast_contents
                ]
            end

            # Convert this DefinitionListItem to a pair of term and definition
            #
            # @return [Array]
            def to_array
                term = @term.children.map{|c| c.markdown.strip}.select{|c| !c.empty?}.join(" ").strip
                definition = @definition.children.map{|c| c.children.map{|d| d.markdown}}.join("\n").strip
                [term, definition]
            end
        end
    end
end
