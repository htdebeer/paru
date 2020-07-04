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
require_relative "./node.rb"
require_relative "../filter_error.rb"

module Paru
    module PandocFilter

        # Values without value are encoded in their type name.
        VALUE_ENCODED_IN_TYPE_NAME = :value_encoded_in_type_name

        # A Value node that represents some sort of metadata about block or
        # inline nodes
        class Value < Node

            # Create a new Value with contents. Also indicate if this node has
            # inline children or block children.
            #
            # @param contents [Array<pandoc node in JSON> = []] the contents of
            #   this node
            def initialize(contents)
                @type = contents["t"]

                if contents.has_key? "c" then
                  @value = contents["c"]
                else
                  @value = VALUE_ENCODED_IN_TYPE_NAME
                end
            end

            # Get the encoded value
            #
            # @return [Any] 
            def value()
                if type_encodes_value? then
                    @type
                else
                    @value
                end
            end

            # Set the encoded value
            #
            # @param [Any] new_value
            def value=(new_value)
                if type_encodes_value? then
                  @type = new_value
                else
                  @value = new_value
                end
            end

            # Is this node a block?
            #
            # @return [Boolean] false
            def is_block?
                false
            end

            # Is this node an inline node?
            #
            # @return [Boolean] false
            def is_inline?
                false
            end

            # The AST type of this Node
            #
            # @return [String]
            def ast_type()
                @type
            end

            

            # Create an AST representation of this Node
            #
            # @return [Hash]
            def to_ast()
                return {
                    "t" => ast_type,
                    "c" => if type_encodes_value? then nil else @value end
                }
            end

            @private
            def type_encodes_value?()
                return @value == VALUE_ENCODED_IN_TYPE_NAME
            end
        end
    end
end
