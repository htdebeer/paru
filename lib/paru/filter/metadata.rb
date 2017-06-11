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
                        raise FilterError.new("Expected a Hash, MetaMap, or String")
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
        end
    end
end
