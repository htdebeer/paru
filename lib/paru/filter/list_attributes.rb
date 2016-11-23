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
    class ListAttributes

      STYLES = [
        "DefaultStyle", 
        "Example", 
        "Decimal", 
        "LowerRoman", 
        "UpperRoman", 
        "LowerAlpha", 
        "UpperAlpha"
      ]
      DELIMS = [
        "DefaultDelim", 
        "Period", 
        "OneParen", 
        "TwoParens"
      ]

      attr_accessor :start, :number_style, :number_delim
      def initialize attributes
        @start = attributes[0]
        @number_style = attributes[1]
        @number_delim = attributes[2]
      end

      def to_ast
        [
          @start,
          @number_style,
          @number_delim
        ]
      end
    end
  end
end
