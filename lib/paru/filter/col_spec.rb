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
module Paru
    module PandocFilter
        # The allignment of a table column
        ALIGNMENTS = ["AlignLeft", "AlignRight", "AlignCenter", "AlignDefault"]
        COL_WIDTH_DEFAULT = "ColWidthDefault"

        DEFAULT_COLSPEC = [{"t": "AlignLeft"}, {"t": COL_WIDTH_DEFAULT}]

        # ColSpec represents a colspec definition for a table column. It contains an alignment and the column's width.
        #
        # @see https://hackage.haskell.org/package/pandoc-types-1.21/docs/Text-Pandoc-Definition.html#t:ColSpec
        #
        # @!attribute alignment
        #   @return [String]
        #
        # @!attribute width
        #   @return [Double|COL_WIDTH_DEFAULT]
        class ColSpec
            attr_accessor :alignment, :width

            # Create a new ColSpec object
            #
            # @param attributes [Array = DEFAULT_COLSPEC] the attributes as [alignment, width]
            def initialize(pair = DEFAULT_COLSPEC)
                @alignment = pair[0]["t"]
                @width = if pair[1]["t"] == COL_WIDTH_DEFAULT then
                            COL_WIDTH_DEFAULT
                         else
                            pair[1]["c"]
                         end
            end

            def default_width?()
                return @width == COL_WIDTH_DEFAULT
            end

            # Convert this attributes object to an AST representation
            #
            # @return [Array] Array containing id, class name list, and
            #   key-value pair list
            def to_ast
                [
                  {"t": @alignment},
                  if default_width? then {"t": "ColWidthDefault"} else {"t":"ColWidth", "c": @width} end
                ]
            end
        end
    end
end
