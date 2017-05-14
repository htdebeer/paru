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
        require_relative "./block"
        require_relative "./inline"
    
        # The allignment of a table column
        ALIGNMENTS = ["AlignLeft", "AlignRight", "AlignCenter", "AlignDefault"]

        # A Table node represents a table with an inline caption, column
        # definition, widths, headers, and rows.
        #
        # @!attribute caption
        #   @return [Inline]
        #
        # @!attribute alignment
        #   @return [ALIGNMENTS]
        #
        # @!attribute column_widths
        #   @return [Float]
        #
        # @!attribute headers
        #   @return [TableRow]
        #
        # @!attribute rows
        #   @return [Array<TableRow>]
        class Table < Block
            attr_accessor :caption, :alignment, :column_widths, :headers, :rows

            # Create a new Table based on the contents
            #
            # @param contents [Array]
            def initialize(contents)
                @caption = Inline.new contents[0]
                @alignment = contents[1]
                @column_widths = contents[2]
                @headers = TableRow.new contents[3]
                @rows = []
                contents[4].each do |row_data|
                    @rows.push TableRow.new row_data
                end
            end

            # The AST contents of this Table node
            #
            # @return [Array]
            def ast_contents()
                [
                    @caption.ast_contents,
                    @alignment,
                    @column_widths,
                    @headers.ast_contents,
                    @rows.map {|row| row.ast_contents}
                ]
            end
        end
    end
end
