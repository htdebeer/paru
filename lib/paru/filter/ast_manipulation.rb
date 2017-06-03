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
module Paru
    module PandocFilter
        # ASTManipulation is a mixin for Node with some standard tree
        # manipulation methods such as inserting or removing nodes, replacing
        # nodes, and so on.
        module ASTManipulation

            # Find index of child
            #
            # @param child [Node] the child to find the index for
            #
            # @return [Number] the index of child or nil
            def find_index(child)
                @children.find_index child
            end

            # Insert child node among this node's children at position index.
            #
            # @param index [Integer] the position to insert the child
            # @param child [Node] the child to insert
            def insert(index, child)
                @children.insert index, child
            end

            # Delete child from this node's children.
            #
            # @param child [Node] the child node to delete.
            def delete(child)
                @children.delete child
            end

            # Remove the child at position index from this node's children
            #
            # @param index [Integer] the position of the child to remove
            def remove_at(index)
                @children.delete_at index
            end 

            # Append a child to the list with this node's children.
            #
            # @param child [Node] the child to append.
            def append(child)
                @children.push child
            end
            alias << append

            # Prepend a child to the list with this node's children.
            #
            # @param child [Node] the child to prepend.
            def prepend(child)
                insert 0, child
            end

            # Replace a child from this node's children with a new child.
            #
            # @param old_child [Node] the child to replace
            # @param new_child [Node] the replacement child
            def replace(old_child, new_child)
                old_child_index = find_index old_child
                if old_child_index then
                    replace_at old_child_index, new_child
                end
            end

            # Replace the child at position index from this node's children
            # with a new child.
            #
            # @param index [Integer] the position of the child to replace
            # @param new_child [Node] the replacement child
            def replace_at(index, new_child)
                @children[index] = new_child
            end

            # Walk the node tree starting at this node, depth first, and apply
            # block to each node in the tree
            #
            # @param block [Proc] the block to apply to each node in this node
            #   tree
            #
            # @yield node
            def each_depth_first(&block)
                yield self
                each {|child| child.each_depth_first(&block)} if has_children?
            end

        end
    end
end
