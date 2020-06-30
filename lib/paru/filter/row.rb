#--
# Copyright 2015, 2016, 2017, 2020 Huub de Beer <Huub@heerdebeer.org>
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
require_relative "./cell.rb"

module Paru
    module PandocFilter
        # A Row node represents a row in a table's head or body
        class Row < Block
            attr_accessor :attr

            # Create a new Row based on the row_data
            #  
            # @!attribute attr
            # @return Attr
            #
            # @!attribute cells
            # @return [Block]
            #
            # @param contents [Array]
            def initialize(contents)
                @attr = Attr.new contents[0]
                super []
                contents[1].each do |cell|
                    @children.push Cell.new cell["c"]
                end
            end

            def cells()
              @children
            end

            # The AST contents of this Row
            #
            # @return [Array]
            def ast_contents
                [
                  @attr.to_ast,
                  @children.map {|child| child.ast_contents}
                ]
            end

            # Convert this Row to an array of markdown strings, one for
            # each cell
            #
            # @return [String[]] An Array representation of this Row.
            def to_array()
                @children.map do |cell|
                    cell.children.map{|c| c.markdown.strip}.join("\n")
                end
            end
        end
    end
end
