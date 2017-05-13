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
        # ListAttributes represent the attributes of a list.
        #
        # @see http://hackage.haskell.org/package/pandoc-types-1.17.0.4/docs/Text-Pandoc-Definition.html#t:ListAttributes
        #
        # @!attribute start
        #   @return [Integer]
        #
        # @!attribute number_style
        #   @return [STYLES]
        #
        # @!attribute number_delim
        #   @return [DELIMS]
        class ListAttributes
            
            # The various styles of list numbers
            STYLES = [
                "DefaultStyle", 
                "Example", 
                "Decimal", 
                "LowerRoman", 
                "UpperRoman", 
                "LowerAlpha", 
                "UpperAlpha"
            ]

            # The various delimeters of list numbers
            DELIMS = [
                "DefaultDelim", 
                "Period", 
                "OneParen", 
                "TwoParens"
            ]

            attr_accessor :start, :number_style, :number_delim

            # Create a new ListAttribute object with attributes
            #
            # @param attributes [Array] an array with start, number style, and
            #   number delimeter
            def initialize(attributes)
                @start = attributes[0]
                @number_style = attributes[1]
                @number_delim = attributes[2]
            end

            # Create an AST representation of this ListAttributes object
            def to_ast()
                [
                    @start,
                    @number_style,
                    @number_delim
                ]
            end
        end
    end
end
