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
require_relative "./inline.rb"

module Paru
    module PandocFilter
        # A RawInline node has a format  and a string value
        #
        # @!attribute format
        #   @return [String]
        #
        # @!attribute string
        #   @return [String]
        class RawInline < Inline
            attr_accessor :format, :string

            # Create a new RawInline node based on the contents
            #
            # @param contents [Array]
            def initialize(contents)
                @format, @string = contents
            end

            # The AST contents
            #
            # @return [Array]
            def ast_contents()
                [
                    @format,
                    @string
                ]
            end

            # Has this RawInline a string value?
            #
            # @return [Boolean] true
            def has_string?()
                true
            end

            # Has this RawInline inline contents?
            #
            # @return [Boolean] false
            def has_inline?()
                false
            end
        end
    end
end
