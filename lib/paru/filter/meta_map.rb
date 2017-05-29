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

        require_relative "./node"
        require_relative "../pandoc.rb"

        # A MetaMap Node is a map of String keys with MetaValue values
        class MetaMap < Node
            include Enumerable

            # Create a new MetaMap based on the contents
            #
            # @param contents [Array] a list of key-value pairs
            def initialize(contents)
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
            # {replace} and {delete} methods to manipulate metadata.
            #
            # @param key [String] the key
            #
            # @return [MetaValue] the value belonging to the key
            def [](key)
                @children[key]
            end

            # Set a value with a key. It is easier to use the {yaml} method to set
            # metadata properties; the {yaml} method is the preferred method
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
            
            # Mixin the YAML code into this metadata object
            #
            # @param yaml_string [YAML] A string with YAML data
            # @return [MetaMap] this MetaMap object
            #
            # @example Set some properties in the metadata
            #   #!/usr/bin/env ruby
            #   require "paru/filter"
            #   require "date"
            #
            #   Paru::Filter.run do
            #     metadata.yaml <<~YAML
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
            def yaml(yaml_string)
                meta_from_yaml(yaml_string).each do |key, value|
                    self[key] = value
                end
                self
            end

            # Replace the property in this MetaMap matching the selector with
            # metadata specified by second parameter. If that parameter is a
            # String, it is treated as a YAML string.
            #
            # @param selector [String] a dot-separated sequence of property
            # names denoting a sequence of descendants.
            #
            # @param value [MetaBlocks|MetaBool|MetaInlines|MetaList|MetaMap|MetaString|MetaValue|String]
            #   if value is a String, it is treated as a yaml string
            def replace(selector, value)
                parent = select(selector, true)
                if value.is_a? String
                    value = meta_from_yaml(value)
                end
                parent.children[last_key(selector)] = value
            end

            # Get the property in this MetaMap matching the selector
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
                end
                ast
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
                keys = selector.split(".")
                level = self

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

            # Get the last key in this selector
            def last_key(selector)
                selector.split(".").last
            end

            # Convert a yaml string to a MetaMap
            def meta_from_yaml(yaml_string)
                json_string = Pandoc.new do
                    from "markdown"
                    to "json"
                end << yaml_string

                meta_doc = PandocFilter::Document.from_JSON json_string
                meta_doc.meta.to_meta_map
            end
        end
    end
end
