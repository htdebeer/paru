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

        # A RawBlock node has a format and a string contents
        #
        # @!attribute format
        #   @return [String]
        #
        # @!attribute string
        #   @return [String]
        class RawBlock < Block
            attr_accessor :format, :string

            # Create a new RawBlock node based on the contents
            #
            # @param contents [Array]
            def initialize(contents)
                @format, @string = contents
            end

            # Create an AST representation of this RawBlock node
            def to_ast()
                [
                    @format,
                    @string
                ]
            end

            # Has this RawBlock node a string value?
            #
            # @return [Boolean] true
            def has_string?
                true
            end
        end
    end
end
