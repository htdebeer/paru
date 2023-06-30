#--
# Copyright 2020, 2032 Huub de Beer <Huub@heerdebeer.org>
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
require_relative "./value.rb"

module Paru
    module PandocFilter
        # The allignment of a table column
        ALIGNMENTS = ["AlignLeft", "AlignRight", "AlignCenter", "AlignDefault"]

        # The default width of a column
        COL_WIDTH_DEFAULT = "ColWidthDefault"

        # Default value for a column specification: left aligned with default
        # width
        DEFAULT_COLSPEC = [{"t" => "AlignLeft"}, {"t" => COL_WIDTH_DEFAULT}]

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
            attr_reader :alignment, :width

            # Create a new ColSpec object
            #
            # @param contents [Array = DEFAULT_COLSPEC] the attributes as a pair of [alignment, width]
            def initialize(contents = DEFAULT_COLSPEC)
                @alignment = Value.new contents[0]
                @width = Value.new contents[1]
            end

            # Set the width
            #
            # @param [String|Integer|Float] new_width the new width. If it is
            # "ColWidthDefault", it uses the default value.
            def width=(new_width)
                if new_width == "ColWidthDefault" then
                    @width = Value.new({"t" => new_width})
                else
                    @width = Value.new({"t" => "ColWidth", "c" => new_width})
                end
            end

            # Set the alignment
            #
            # @param [String] new_alignment the new alignment.
            def alignment=(new_alignment)
                @alignment.value = new_alignment
            end

            # Convert this attributes object to an AST representation
            #
            # @return [Array] Array containing id, class name list, and
            #   key-value pair list
            def to_ast
                [
                  @alignment.to_ast,
                  @width.to_ast
                ]
            end
        end
    end
end
