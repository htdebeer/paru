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
require_relative "./block.rb"

module Paru
    module PandocFilter
        # A Note node like a foot note or end note. It is a special node in
        # the sense that itself is an Inline level node, but its contents are
        # Block level.
        class Note < Inline

            # Has this Note block contents?
            #
            # @return [Boolean] true
            def has_block?
                true
            end

            # Has this Note inline contents?
            #
            # @return [Boolean] false
            def has_inline?
                false
            end

            # Although Note is defined to be inline, often it will act like a block
            # element.
            #
            # @return [Boolean] true
            def can_act_as_both_block_and_inline?
                true
            end

        end
    end
end
