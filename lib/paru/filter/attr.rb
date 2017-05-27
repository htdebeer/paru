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

        # Attr represents an attribute object for a node. It contains of an id, a
        # list of class names and a list of key-value pairs. 
        #
        # @see https://hackage.haskell.org/package/pandoc-types-1.17.0.5/docs/Text-Pandoc-Definition.html#t:Attr
        #
        # @!attribute id
        #   @return [String]
        #
        # @!attribute classes
        #   @return [Array<String>]
        class Attr
            include Enumerable

            attr_accessor :id, :classes

            # Create a new attributes object
            #
            # @param attributes [Array = []] the attributes as [id, [class names],
            #   [key-value pairs]]
            def initialize(attributes = [])
                id, classes, data = attributes
          
                @id = id || ""

                @classes = classes || []
                @classes = [@classes] unless @classes.is_a? Array

                @data = data || {}
            end

            # For each key-value pair of this attributes object
            def each
                @data.each
            end

            # Get the value for key in this attributes object
            #
            # @param key [String] the key to get the value for. Nil if it does
            # not exists
            def [](key) 
                if @data.key_exists? key
                    @data[key]
                end 
            end

            # Does this attributes object have this key?
            #
            # @param name [String] key to find
            #
            # @return [Boolean] true if this key exist, false otherwise
            def has_key?(name)
                @data.key_exists? name
            end

            # Does this attributes object have a class?
            #
            # @param name [String] the class name to search for.
            #
            # @return [Boolean] true if this class name exist, false
            #   otherwise.
            def has_class?(name)
                @classes.include? name
            end

            # Convert this attributes object to an AST representation
            #
            # @return [Array] Array containing id, class name list, and
            #   key-value pair list
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
