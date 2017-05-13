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
        require_relative "./inline"

        # A Math Inline node with the type of math node and the mathematical
        # contents
        #
        # @!attribute math_type
        #   @return [Hash]
        #   @see http://hackage.haskell.org/package/pandoc-types-1.17.0.4/docs/Text-Pandoc-Definition.html#t:MathType
        #
        # @!attribute string
        #   @return [String]
        class Math < Inline
            attr_accessor :math_type, :string

            # Create a new Math node with contents
            #
            # @param contents [Array] an array with the type and contents
            def initialize(contents)
                @math_type, @string = contents
            end

            # Is this an inline node? 
            #
            # @return [Boolean] true if math type is "InlineMath", false
            #   otherwise
            def inline?()
                "InlineMath" == @math_type[t]
            end

            # Convert this Math node's content to Inline
            def inline!()
                @math_type = {
                    "t" => "InlineMath"
                }
            end

            # Should this math be displayed as a block?
            #
            # @return [Boolean] true if type is "DisplayMath"
            def display?()
                "DisplayMath" == @math_type[t]
            end

            # Make this Math node's content display as a block
            def display!()
                @math_type = {
                    "t" => "DisplayMath"
                }
            end

            # Create an AST representation of this Math node
            def ast_contents()
                [
                    @math_type,
                    @string
                ]
            end

            # Has this Math node string contents?
            #
            # @return [Boolean] true
            def has_string?()
                true
            end

            # Has this Math node inline contents?
            #
            # @return [Boolean] false
            def has_inline?()
                false
            end
        end
    end
end
