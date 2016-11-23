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
    class Attr
      include Enumerable

      attr_accessor :id, :classes
      def initialize(attributes)
        @id, @classes, @data = attributes
      end

      def each
        @data.each
      end

      def [](key) 
        if @data.key_exists? key
          @data[key]
        end 
      end

      def has_key? name
        @data.key_exists? name
      end

      def has_class? name
        @classes.include? name
      end

      def to_ast
        [
          @id,
          @classes,
          @data
        ]
      end
    end
  end
end
