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
# Span Attr [Inline]
module Paru
  module PandocFilter

    require_relative "./inline"
    require_relative "./attr"

    class Span < Inline
      attr_accessor :attr

      def initialize contents
        @attr = Attr.new contents[0]
        super contents[1]
      end

      def ast_contents
        [
          @attr.to_ast,
          super
        ]
      end
    end
  end
end
