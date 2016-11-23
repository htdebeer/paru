#--
# Copyright 2015, 2016 Huub de Beer <Huub@heerdebeer.org>
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

    # Header Int Attr [Inline]
    class Header < Block
      attr_accessor :level, :attr

      def initialize contents
        @level = contents[0]
        @attr = Attr.new contents[1]
        super contents[2], true
      end

      def ast_contents
        [
          @level,
          @attr.to_ast,
          super
        ]
      end

      def has_inline?
        true
      end
    end
  end
end
