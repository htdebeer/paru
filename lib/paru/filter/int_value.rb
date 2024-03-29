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

        # An IntValue represents some sort of integer metadata about block or
        # inline nodes
        class IntValue
          attr_accessor :value

          def initialize(value)
            @value = value
          end

          # Create an AST representation of this Node
          #
          # @return [Hash]
          def to_ast()
            @value
          end
        end
    end
end
