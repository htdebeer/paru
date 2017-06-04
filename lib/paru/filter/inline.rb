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
require_relative "./inner_markdown.rb"

module Paru
    module PandocFilter
        # An Inline node
        # @see http://hackage.haskell.org/package/pandoc-types-1.17.0.4/docs/Text-Pandoc-Definition.html#t:Inline
        class Inline < Node
            include InnerMarkdown

            # Create a new Inline node with contents
            # @param contents [Array] the contents of this inline node
            def initialize(contents)
                super contents, true
            end 

            # Is this Inline node inline? Of course!
            #
            # @return [Boolean] true
            def is_inline?()
                true
            end

            # Has this Inline node inline contents? Of course!
            #
            # @return [Boolean] true
            def has_inline?()
                true
            end

        end
    end
end
