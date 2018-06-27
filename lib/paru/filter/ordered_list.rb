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
require_relative "./block.rb"

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

            # Create a new OrderedList from an array of markdown strings
            #
            # @param items [String[]] an array of markdown strings
            # @param config [Hash] configuration of the list. Can have
            # properties :start (Int), :style (String), and :delim (String)
            #
            # @return [OrderedList]
            def self.from_array(items, **config )
                start = if config.has_key? :start then config[:start] else 1 end
                style = if config.has_key? :style then config[:style] else "Decimal" end
                delim = if config.has_key? :delim then config[:delim] else "Period" end
                ast_items = items.map {|item| [Block.from_markdown(item).to_ast]}
                OrderedList.new [[start, {"t" => style}, {"t" => delim}], ast_items]
            end

        end
    end
end
