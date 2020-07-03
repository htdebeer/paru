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
require_relative "./block.rb"
require_relative "./short_caption.rb"

module Paru
    module PandocFilter
        # A table's caption, can contain an optional short caption
        class Caption < Block
            attr_accessor :short  

            # Create a new Caption based on the contents
            #
            # @param contents [Array]
            def initialize(contents)
                if contents[0].nil?
                  @short = nil
                else
                  @short = ShortCaption.new contents[0]
                end
                super(contents[1])
            end

            # Does this Caption have a short caption?
            #
            # @return [Boolean]
            def has_short?()
                not @short.nil?
            end

            # Has this node a block?
            #
            # @return [Boolean] true
            def has_block?
                true
            end

            # The AST contents of this Caption node
            #
            # @return [Array]
            def ast_contents()
                [
                  if has_short? then @short.to_ast else nil end,
                  @children.map {|row| row.to_ast}
                ]
            end
        end
    end
end
