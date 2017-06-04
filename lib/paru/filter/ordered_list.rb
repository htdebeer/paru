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
require_relative "./list.rb"
require_relative "./list_attributes.rb"

module Paru
    module PandocFilter
        # An OrderedList Node 
        # 
        # @example In markdown an ordered list looks like
        #   1. this is the first item
        #   2. this the second
        #   3. and so on
        #
        # It has an ListAttributes object and a list of items
        #
        # @!attribute list_attributes
        #   @return [ListAttributes]
        class OrderedList < List
            attr_accessor :list_attributes

            # Create a new OrderedList node based on the contents
            #
            # @param contents [Array]
            def initialize(contents)
                super contents[1]
                @list_attributes = ListAttributes.new contents[0]
            end

            # The AST contents
            #
            # @return [Array]
            def ast_contents()
                [
                    @list_attributes.to_ast,
                    super
                ] 
            end

        end
    end
end
