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
require_relative "./node.rb"

module Paru
    module PandocFilter
        # A MetaValue Node is either a MetaMap, MetaList, MetaBool, MetaString, MetaInlines, or a MetaBlocks.
        #
        # @see http://hackage.haskell.org/package/pandoc-types-1.17.0.4/docs/Text-Pandoc-Definition.html#t:MetaValue
        #
        # @!attribute value
        #   @return [String|Boolean]
        class MetaValue < Node

            attr_accessor :value

            # Create a new MetaValue Node based on the value
            # 
            # @param value [String]
            def initialize(value)
                @value = value
            end

            # The AST contents
            def ast_contents()
                @value
            end

        end
    end
end
