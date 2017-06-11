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
require "yaml"
require_relative "../pandoc.rb"
require_relative "../filter_error.rb"

module Paru
    module PandocFilter
        # A Metadata object is a Ruby Hash representation of a pandoc metadata
        # node.
        class Metadata < Hash

            # Create a new Metadata object based on the contents.
            #
            # @param contents [MetaMap|String|Hash] the initial contents of this
            #   metadata. If contents is a String, it is treated as a YAML string
            #   and converted to a Hash first.
            #
            # @raise Error when converting contents to a Hash fails
            def initialize(contents = {})
                if not contents.is_a? Hash
                    # If not a Hash, it is either a YAML string or can be
                    # converted to a YAML string
                    if contents.is_a? PandocFilter::MetaMap
                        yaml_string = meta2yaml contents
                    elsif contents.is_a? String
                        yaml_string = contents
                    else
                        raise FilterError.new("Expected a Hash, MetaMap, or String, got '#{contents}' instead.")
                    end

                    # Try to convert the YAML string to a Hash
                    if yaml_string.empty?
                        contents = {}
                    else
                        contents = YAML.load yaml_string
                    end

                    if not contents
                        # Error parsing YAML
                        raise FilterError.new("Unable to convert YAML string '#{yaml_string}' to a Hash.")
                    end
                end

                # Merge the contents with this newly created Metadata
                contents.each do |key, value|
                    self[key] = value
                end
            end

            # Convert this Metadata to a pandoc AST representation of
            # metadata: {PandocFilter::Meta}
            #
            # @return [Meta] the pandoc AST representation as a {PandocFilter::Meta} node
            def to_meta()
                if self.empty?
                    PandocFilter::Meta.new {}
                else
                    begin
                        yaml_string = "#{clean_hash.to_yaml}..."
                        yaml2json = Paru::Pandoc.new {from "markdown"; to "json"}
                        json_string = yaml2json << yaml_string
                        meta_doc = PandocFilter::Document.from_JSON json_string
                        meta_doc.meta
                    rescue
                    end
                end
            end

            # Set the property in this Metadata matched by using the selector with
            # the new value specified by the second parameter. If the selected property
            # and the new value are both Hashes, merge the two hashes.
            #
            # @param selector [String] a dot-separated sequence of property
            # names denoting a sequence of descendants.
            #
            # @param new_value [Object]
            def set_by(selector, new_value)
                parent = select_by(selector, true)
                if not parent.nil?
                    key = last_key(selector)
                    original_value = parent[key]

                    if original_value.is_a? Hash and new_value.is_a? Hash
                        # mixin the new value with the old
                        parent[key].merge! new_value
                    else
                        parent[key] = new_value
                    end
                end
            end

            # Get the property in this Metadata matched by the selector
            #
            # @param selector [String] a dot-separated sequence of property
            #   names denoting a sequence of descendants.
            #
            # @return [Object] the value matching the selected property, nil if it cannot be found
            def get_by(selector)
                select_by(selector)
            end 

            # Has this Metadata a property matched by this selector?
            #
            # @param selector [String] a dot-separated sequence of property
            #   names denoting a sequence of descendants
            #
            # @return [Boolean] True if this Metadata has a property matched
            #   by the selector, false otherwise
            def has_by?(selector)
                not select_by(selector).nil?
            end

            # Delete the property in this Metadata that matches by the selector
            #
            # @param selector [String] a dot-separated sequence of property
            #   names denoting a sequence of descendants
            #
            # @return [Object] the value of the deleted property, nil if it cannot be found
            #
            def delete_by(selector)
                if has_by?(selector)
                    parent = select_by(selector, true)
                    parent.delete(last_key(selector))
                else
                    nil
                end
            end

            private 

            # Convert a {PandocFilter::Meta} node to a Metadata
            #
            # @param meta [Meta|MetaMap] the {PandocFilter::Meta} node to convert to a
            #   MetadataHash
            def meta2yaml(meta)
                begin
                    json2yaml = Paru::Pandoc.new {from "json"; to "markdown"; standalone}
                    meta = PandocFilter::Meta.from_meta_map(meta) unless meta.is_a? PandocFilter::Meta
                    meta_doc = PandocFilter::Document.new(PandocFilter::CURRENT_PANDOC_VERSION, meta.to_ast, [])
                    yaml_string = json2yaml << meta_doc.to_JSON
                    yaml_string.strip
                rescue
                end
            end

            # Create a true Hash from this Metadata to prevent the +to_yaml+
            # method from mixing in the name of this class and confusing pandoc
            def clean_hash
                hash = {}
                each do |key, value|
                    hash[key] = value
                end
                hash
            end

            # Select a node by a selector as a dot separated sequence of
            # descendant names.
            #
            # @param selector [String] Dot separated sequence of property
            #   names
            #
            # @param get_parent [Boolean = false] Get the parent Hash
            #   of the selected property instead of its value
            # 
            # @return [Object] the value of the deleted property, nil if it cannot be found
            def select_by(selector, get_parent = false)
                if selector.empty?
                    # If no selector is given, select this Metadata node
                    return self
                elsif empty? and selector.include? "."
                    # If there is a selector with nesting, but this Metadata has no
                    # values, there cannot be a match.
                    return nil
                else
                    level = self
                    keys = selector.split(".")

                    while not keys.empty?
                        key = keys.shift

                        if get_parent and keys.empty?
                            return level
                        end

                        if not level.has_key? key
                            return nil
                        else
                            level = level[key]
                        end
                    end

                    level
                end
            end 

            # Get the last key in this selector
            def last_key(selector)
                selector.split(".").last
            end

        end
    end
end
