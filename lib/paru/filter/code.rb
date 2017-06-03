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
require_relative "./attr.rb"

module Paru
    module PandocFilter
        # A Code node, with an attribute object and the code itself as a
        # string.
        #
        # @!attribute attr 
        #   @return [Attr]
        #
        # @!attribute string
        #   @return [String]
        class Code < Inline
            attr_accessor :attr, :string

            # Create a new Code node
            #
            # @param contents [Array] an array of the attribute and the code
            def initialize(contents)
                @attr = Attr.new contents[0]
                @string = contents[1]
            end

            # Create an AST representation of this Code node.
            def ast_contents()
                [
                    @attr.to_ast,
                    @string
                ]
            end

            # Has this Code node a string contents?
            #
            # @return [Boolean] true
            def has_string?()
                true
            end

            # Has this code node inline contents?
            #
            # @return [Boolean] false
            def has_inline?()
                false
            end
        end
    end
end
