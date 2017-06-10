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
require_relative "../metadata.rb"

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

            # Get the value belonging to key. Prefer to use the {has?}, {get},
            # {replace}, {set}, and {delete} methods to manipulate metadata.
            # The {get} method is the preferred method to get a value from the
            # metadata.
            #
            # @param key [String] the key
            #
            # @return [MetaValue] the value belonging to the key
            def [](key)
                @children[key]
            end

            # Set a value with a key. Prefer to use the {has?}, {get},
            # {replace}, {set}, and {delete} methods to manipulate metadata.
            # The {set} method is the preferred method
            # to set the metadata.
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

            # Replace the property in this MetaMap matching the selector with
            # metadata specified by second parameter, which can be a Ruby
            # Hash, a YAML string, or any pandoc metadata node.
            #
            # @param selector [String] a dot-separated sequence of property
            # names denoting a sequence of descendants.
            #
            # @param value [MetaBlocks|MetaBool|MetaInlines|MetaList|MetaMap|MetaString|MetaValue|String|Hash]
            #   if value is a String, it is treated as a yaml string
            def replace(selector, value)
                parent = select(selector, true)
                value = meta_from_value value

                if selector.empty?
                    @children = value.children
                else
                    parent.children[last_key(selector)] = value
                end
            end

            # Set the property in this MetaMap matching the selector with
            # metadata specified by the second parameter, which can be a Ruby
            # Hash, a YAML string, or any pandoc metadata node.
            #
            # If the selected property
            # and the converted value are both {MetaMap} nodes, two nodes are
            # merged.
            #
            # @param selector [String] a dot-separated sequence of property
            # names denoting a sequence of descendants.
            #
            # @param value [MetaBlocks|MetaBool|MetaInlines|MetaList|MetaMap|MetaString|MetaValue|String|Hash]
            #   if value is a String, it is treated as a yaml string
            #
            # @example Set some properties in the metadata specified in YAML
            #   #!/usr/bin/env ruby
            #   require "paru/filter"
            #   require "date"
            #
            #   Paru::Filter.run do
            #     metadata.set "", <<~YAML
            #       ---
            #       date: #{Date.today.to_s}
            #       title: This **is** the title
            #       pandoc_options:
            #         from: markdown
            #         toc: true
            #       keywords:
            #       - metadata
            #       - pandoc
            #       - filter
            #       ...
            #     YAML
            #   end
            #
            # @example Mixin extra pandoc_options specified as a Ruby Hash
            #   #!/usr/bin/env ruby
            #   require "paru/filter"
            #   require "date"
            #
            #   Paru::Filter.run do
            #     metadata.set "pandoc_options", {
            #       :from => "html"
            #       :to => "markdown"
            #     }
            #   end
            #
            def set(selector, value)
                parent = select(selector, true)
                value = meta_from_value value

                if selector.empty?
                    @children = value.children
                else
                    original_value = parent.children[last_key(selector)]
                    if original_value.is_a? MetaMap and value.is_a? MetaMap
                        # mixin the new value with the old
                        parent.children[last_key(selector)].children.merge! value.children
                    else
                        parent.children[last_key(selector)] = value
                    end
                end
            end

            # Get the property in this MetaMap matching the selector. If the
            # returned property is a {MetaMap}, you can convert it to YAML or
            # a Ruby Hash using the methods {to_yaml} and {to_hash}
            # respectively. It is easier to work with metadata as a YAML string or a plain Ruby Hash object.
            #
            # @param selector [String] a dot-separated sequence of property
            #   names denoting a sequence of descendants.
            #
            # @return [MetaBlocks|MetaBool|MetaInlines|MetaList|MetaMap|MetaString|MetaValue] the value matching the selected property, nil if it cannot be found
            def get(selector)
                select(selector)
            end 

            # Has this MetaMap a descendant matching selector?
            #
            # @param selector [String] a dot-separated sequence of property
            #   names denoting a sequence of descendants
            #
            # @return [Boolean] True if this MetaMap contains a descendant
            #   matching selector, false otherwise
            def has?(selector)
                not select(selector).nil?
            end

            # Delete the property in this MetaMap that matches the selector
            #
            # @param selector [String] a dot-separated sequence of property
            #   names denoting a sequence of descendants
            #
            # @return [MetaBlocks|MetaBool|MetaInlines|MetaList|MetaMap|MetaString|MetaValue] the value of the deleted property, nil if it cannot be found
            #
            def delete(selector)
                if has?(selector)
                    parent = select(selector, true)
                    parent.children.delete(last_key(selector))
                else
                    nil
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

            # Convert this {MetaMap} node to YAML. Note. this involves running
            # pandoc, so this might be an expensive operation.
            #
            # @return [String] the YAML representation of this MetaMap node
            def to_yaml()
                Paru::Metadata.to_yaml self
            end

            # Convert this {MetaMap} node to a Ruby Hash. Note. this involves
            # running pandoc, so this might be an expensive operation.
            #
            # @return [Hash] the Hash representation of this MetaMap node
            def to_hash()
                Paru::Metadata.to_hash self
            end
            
            private

            # Select a node given a selector as a dot separated sequence of
            # descendant names.
            #
            # @param selector [String] Dot separated sequence of property
            #   names
            #
            # @param get_parent [Boolean = false] Get the parent MetaMap
            #   of the selected property instead of its value
            # 
            # @return [MetaBlocks|MetaBool|MetaInlines|MetaList|MetaMap|MetaString|MetaValue] the value of the deleted property, nil if it cannot be found
            def select(selector, get_parent = false)
                if selector.empty?
                    # If no selector is given, select this MetaMap node.
                    return self
                elsif @children.empty? 
                    # If there is a selector, but this MetaMap has no
                    # children, there cannot be a match.
                    return nil
                else
                    level = self

                    keys = selector.split(".")

                    while not keys.empty?
                        key = keys.shift

                        if not level.children.has_key? key
                            return nil
                        else
                            if get_parent and keys.empty?
                                return level
                            else
                                level = level[key]
                            end
                        end
                    end

                    level
                end
            end 

            # Get the last key in this selector
            def last_key(selector)
                selector.split(".").last
            end

            # Convert a value to a MetaMap
            def meta_from_value(value)
                meta = value
                if value.is_a? String
                    meta = Paru::Metadata.from_yaml value
                elsif value.is_a? Hash
                    meta = Paru::Metadata.from_hash value
                end
                meta
            end
        end
    end
end
