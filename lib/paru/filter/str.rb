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

        # A Str node represents a string
        #
        # @!attribute string
        #   @return [String] the value of this Str node.
        class Str < Inline

            attr_accessor :string

            # Create a new Str node based on the value
            #
            # @param value [String]
            def initialize(value)
                @string = value
            end

            # The AST contents
            def ast_contents()
                @string
            end

            # Has the Str node a string value? Of course!
            #
            # @return [Boolean] true
            def has_string?()
                true
            end

            # Has the Str node inline contents? 
            #
            # @return [Boolean] false
            def has_inline?()
                false
            end
        end
    end
end
