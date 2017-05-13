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
        require_relative "./attr"

        # A CodeBlock is a Block level node with an attribute object and the
        # code as a string
        #
        # @!attribute attr 
        #   @return [Attr]
        #
        # @!attribute string
        #   @return [String]
        class CodeBlock < Block
            attr_accessor :attr, :string

            # Create a new CodeBlock based on the contents
            #
            # @param contents [Array] an array with the attribute and the code
            #   string
            def initialize(contents)
                @attr = Attr.new contents[0]
                @string = contents[1]
            end

            # An AST representation of this CodeBlock
            def ast_contents()
                [
                    @attr.to_ast,
                    @string
                ]
            end

            # Has this CodeBlock string contents?
            #
            # @return [Boolean] true
            def has_string?()
                true
            end
        end
    end
end
