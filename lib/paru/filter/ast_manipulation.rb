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
module Paru
  module PandocFilter
    module ASTManipulation

      def insert index, child
        @children.insert index, child
      end

      def delete child
        @children.delete child
      end

      def remove_at index
        @children.delete_at index
      end 

      def append child
        @children.push child
      end
      alias << append

      def prepend child
        insert 0, child
      end

      def replace old_child, new_child
        @children.find_index old_child do |index|
          replace_at index, new_child
        end
      end

      def replace_at index, new_child
        @children[index] = new_child
      end

      def each_depth_first &block
        yield self
        each {|child| child.each_depth_first(&block)} if has_children?
      end

    end
  end
end
