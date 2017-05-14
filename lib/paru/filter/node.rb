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
    # PandocFilter is a module containig the paru's Filter functionality 
    module PandocFilter

        require_relative "./ast_manipulation"
        require_relative "./markdown"
        require_relative "../pandoc"
        require_relative "./document"

        # Every node in a Pandoc AST is mapped to Node. Filters are all about
        # manipulating Nodes.
        #
        # @!attribute parent
        #   @return [Node] the parent node, if any.
        class Node
            include Enumerable
            include ASTManipulation
            include Markdown

            attr_accessor :parent

            Dir[File.dirname(__FILE__) + '/*.rb'].each do |file|
                require_relative file
            end

            # Create a new Node with contents. Also indicate if this node has
            # inline children or block children.
            #
            # @param contents [Array<pandoc node in JSON>] the contents of
            #   this node
            # @param inline_children [Boolean] does this node have
            #   inline children (true) or block children (false).
            def initialize(contents, inline_children = false)
                @children = []
                @parent = nil

                if contents.is_a? Array
                    contents.each do |elt|
                        if PandocFilter.const_defined? elt["t"]
                            child = PandocFilter.const_get(elt["t"]).new elt["c"]
                        else
                            if inline_children
                                child = PandocFilter::Inline.new elt["c"]
                            else
                                child = PandocFilter::Plain.new elt["c"]
                            end
                        end

                        child.parent = self
                        @children.push child
                    end
                end
            end

            # For each child of this Node, yield the child
            #
            # @yield [Node]
            def each()
                @children.each do |child|
                    yield child
                end
            end

            # Does this node have any children?
            #
            # @return [Boolean] True if this node has any children, false
            #   otherwise.
            def has_children?()
                defined? @children and @children.size > 0
            end

            # Get this node's children,
            #
            # @return [Array<Node>] this node's children as an Array.
            def children()
                if has_children?
                    @children
                else
                    []
                end
            end

            # Set this node's children
            #
            # @param list [Array<Node>] a list with nodes
            def children=(list)
                @children = list
            end

            # Does this node have a parent?
            #
            # @return [Boolean] True if this node has a parent, false
            #   otherwise.
            def has_parent?()
                not @parent.nil?
            end

            # Is this a root node? 
            #
            # @return [Boolean] True if this node has a no parent, false 
            #   otherwise
            def is_root?()
                not has_parent?
            end

            # Is this Node a Node or a leaf? See #is_leaf?
            #
            # @return [Boolean] A node is a node if it is not a leaf.
            def is_node?()
                not is_leaf
            end

            # Is this Node a leaf? See also #is_node?
            #
            # @return [Boolean] A node is a leaf when it has no children
            #   false otherwise
            def is_leaf?()
                not has_children?
            end
            
            # Does this node has a string value?
            #
            # @return [Boolean] true if this node has a string value, false
            #   otherwise
            def has_string?()
                false
            end

            # Does this node have Inline contents?
            #
            # @return [Boolean] true if this node has Inline contents, false
            #   otherwise
            def has_inline?()
                false
            end

            # Does this node have Block contents?
            #
            # @return [Boolean] true if this node has Block contents, false
            #   otherwise
            def has_block?()
                false
            end

            # Is this node a Block level node?
            #
            # @return [Boolean] true if this node is a block level node, false
            #   otherwise
            def is_block?()
                false
            end

            # Can this node act both as a block and inline node? Some nodes
            # are hybrids in this regard, like Math or Image
            #
            # @return [Boolean]
            def can_act_as_both_block_and_inline?()
                false
            end

            # Is this an Inline level node?
            #
            # @return [Boolean] true if this node is an inline level node,
            #   false otherwise
            def is_inline?()
                false
            end

            # If this node has attributes with classes, is name among them?
            #
            # @param name [String] the class name to search for
            #
            # @return [Boolean] true if this node has attributes with classes
            #   and name is among them, false otherwise
            def has_class?(name)
                if not @attr.nil?
                    @attr.has_class? name
                else
                    false
                end
            end

            # A String representation of this Node
            #
            # @return [String]
            def to_s()
                self.class.name
            end

            # The pandoc type of this Node
            #
            # @return [String]
            def type()
                ast_type
            end

            # The AST type of this Node
            #
            # @return [String]
            def ast_type()
                self.class.name.split("::").last
            end

            # An AST representation of the contents of this node
            #
            # @return [Array]
            def ast_contents()
                if has_children?
                    @children.map {|child| child.to_ast}
                else
                    []
                end
            end
            
            # Create an AST representation of this Node
            #
            # @return [Hash]
            def to_ast()
                {
                    "t" => ast_type,
                    "c" => ast_contents
                }
            end

        end
    end
end
