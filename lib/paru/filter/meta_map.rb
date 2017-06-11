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
require_relative "./node.rb"

require_relative "../pandoc.rb"

module Paru
    module PandocFilter
        # A MetaMap Node is a map of String keys with MetaValue values
        class MetaMap < Node
            include Enumerable

            # Create a new MetaMap based on the contents
            #
            # @param contents [Hash = {}] a list of key-value pairs, defaults
            #   to an empty hash
            def initialize(contents = {})
                @children = Hash.new

                if contents.is_a? Hash
                    contents.each_pair do |key, value|
                        if not value.empty? and PandocFilter.const_defined? value["t"]
                            @children[key] = PandocFilter.const_get(value["t"]).new value["c"]
                        end
                    end
                end
            end

            # Get the value belonging to key. 
            #
            # @param key [String] the key
            #
            # @return [MetaValue] the value belonging to the key
            def [](key)
                @children[key]
            end

            # Set a value with a key. 
            #
            # @param key [String] the key to set
            # @param value [MetaBlocks|MetaBool|MetaInlines|MetaList|MetaMap|MetaString|MetaValue] the value to set
            def []=(key, value)
                @children[key] = value
            end

            # Execute block for each key-value pair
            def each()
                @children.each do |key, value|
                    yield(key, value)
                end
            end

            # The AST contents
            def ast_contents()
                ast = Hash.new
                @children.each_pair do |key, value|
                    ast[key] = value.to_ast
                end if @children.is_a? Hash
                ast
            end

        end
    end
end
