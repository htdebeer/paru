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
require_relative "./block.rb"
require_relative "./attr.rb"

module Paru
    module PandocFilter
        # A Header node has a level, an attribute object and the contents of
        # the header as a list on Inline nodes.
        #
        # @!attribute level
        #   @return [Integer]
        #
        # @!attribute attr
        #   @return [Attr]
        class Header < Block
            attr_accessor :level, :attr

            # Create a new Header node
            #
            # @param contents [Array] an array with the level, attribute, and
            #   the header contents
            def initialize(contents)
                @level = contents[0]
                @attr = Attr.new contents[1]
                super contents[2], true
            end

            # Create an AST representation of this Header node
            def ast_contents()
                [
                    @level,
                    @attr.to_ast,
                    super
                ]
            end

            # Has this Header node inline contents?
            #
            # @return [Boolean] true
            def has_inline?
                true
            end
        end
    end
end
