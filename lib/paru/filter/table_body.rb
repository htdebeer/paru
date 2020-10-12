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
require_relative "./row.rb"
require_relative "./value.rb"

module Paru
    module PandocFilter
        # A TableBody node represents a row in a table's head or body
        #  
        # @!attribute attr
        #   @return Attr
        #
        # @!attribute rowheadcolumns
        #   @return Value containing an Integer indicating the number of head
        #   columns.
        #
        # @!attribute rowheadercolums
        #   @return [Row]
        #
        # @!attribute rows
        #   @return [Row]
        class TableBody < Block
            attr_accessor :attr, :rowheadcolumnspec, :rowheadercolumns

            # Create a new TableBody
            #
            # @param contents [Array] The contents of this TableBody
            def initialize(contents)
                @attr = Attr.new contents[0]
                @rowheadcolumns = IntValue.new contents[1]
                @rowheadercolumns = contents[2].map {|r| Row.new r}

                super []
                contents[3].each do |row|
                    @children.push Row.new row
                end
            end

            # The rows in this TableBody
            #
            # @return [Array<Row>]
            def rows()
                @children
            end

            # The AST contents of this TableBody
            #
            # @return [Array]
            def ast_contents
                [
                  @attr.to_ast,
                  @rowheadcolumns.to_ast,
                  @rowheadercolumns.map {|r| r.to_ast},
                  @children.map {|child| child.to_ast}
                ]
            end

            def to_ast()
              ast_contents()
            end
            
            # Convert this table end to a 2D table of markdown strings for each
            # cell
            #
            # @return [String[][]] This Table as a 2D array of cells
            # represented by their markdown strings.
            def to_array()
                @children.map do |row|
                    row.to_array
                end
            end
        end
    end
end
