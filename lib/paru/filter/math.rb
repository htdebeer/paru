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
# Math MathType String
module Paru
  module PandocFilter
    require_relative "./inline"

    class Math < Inline
      attr_accessor :math_type, :string

      def initialize contents
        @math_type, @string = contents
      end

      def inline?
        "InlineMath" == @math_type[t]
      end

      def inline!
        @math_type = {
          "t" => "InlineMath"
        }
      end

      def display?
        "DisplayMath" == @math_type[t]
      end

      def display!
        @math_type = {
          "t" => "DisplayMath"
        }
      end

      def ast_contents
        [
          @math_type,
          @string
        ]
      end

      def has_string?
        true
      end

      def has_inline?
        false
      end
    end
  end
end
