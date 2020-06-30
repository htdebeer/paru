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
require_relative "./cell.rb"

module Paru
    module PandocFilter
        # A TableRow node represents a row in a table's head or body
        class Cell < Block
            attr_accessor :attr, :alignment, :rowspan, :colspan

            # Create a new TableRow based on the row_data
            #  
            # @!attribute attr
            # @return Attr
            #
            # @!attribute alignment
            # @return String
            #
            # @!attribute rowspan
            # @return Integer
            #
            # @!attribute colspan
            # @return Integer
            #
            # @param contents [Array]
            def initialize(contents)
                @attr = Attr.new contents[0]
                @alignment = contents[1]["t"]
                @rowspan = contents[2]["c"]
                @colspan = contents[3]["c"]

                super(contents[4])
            end

            # The AST contents of this TableRow
            #
            # @return [Array]
            def ast_contents
                [
                  @attr.to_ast,
                  {"t": @alignment},
                  {"t": "RowSpan", "c": @rowspan},
                  {"t": "ColSpan", "c": @colspan},
                  @children.map {|child| child.ast_contents}
                ]
            end
        end
    end
end
