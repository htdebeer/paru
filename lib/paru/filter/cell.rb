#--
# Copyright 2020 Huub de Beer <Huub@heerdebeer.org>
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
require_relative "./value.rb"

module Paru
    module PandocFilter
        # A Cell node represents a cell  in a table's head, body, or foot
        #  
        # @!attribute attr
        #   @return Attr
        #
        # @!attribute alignment
        #   @return Value containing a String, one of AlignRight, AlignLeft,
        #   AlignCenter, or AlignDefault.
        #
        # @!attribute rowspan
        #   @return Value containing an Integer
        #
        # @!attribute colspan
        #   @return Value containing an Integer
        class Cell < Block
            attr_accessor :attr, :alignment, :rowspan, :colspan

            # Create a new Cell based on the row_data
            #
            # @param contents [Array]
            def initialize(contents)
                @attr = Attr.new contents[0]
                @alignment = Value.new contents[1]
                @rowspan = Value.new contents[2]
                @colspan = Value.new contents[3]

                super contents[4]
            end

            # The AST contents of this Cell
            #
            # @return [Array]
            def ast_contents
                [
                  @attr.to_ast,
                  @alignment.to_ast,
                  @rowspan.to_ast,
                  @colspan.to_ast,
                  @children.map {|child| child.to_ast}
                ]
            end
        end
    end
end
