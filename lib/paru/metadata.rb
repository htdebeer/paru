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
require "json"
require "yaml"
require_relative "./pandoc.rb"

module Paru
    # Singleton utility module to convert or create a pandoc AST metadata
    # {PandocFilter::MetaMap} node from a YAML string or Ruby Hash.  Converted
    # values are cached as to not convert any value twice because conversion
    # is quite expensive as it involves running pandoc.
    module Metadata

        # Create a {PandocFilter::MetaMap} node from a YAML string. 
        #
        # @param yaml_string [String] the YAML string to convert
        # @return [MetaMap] the MetaMap node generated from yaml_string
        def self.from_yaml(yaml_string)
            @@cache ||= {}
            metadata = @@cache[yaml_string]
            if metadata.nil?
                yaml2json = Paru::Pandoc.new {from "markdown"; to "json"} 
                json_string = yaml2json << yaml_string
                meta_doc = PandocFilter::Document.from_JSON json_string
                metadata = meta_doc.meta
                @@cache[yaml_string] = metadata
            end
            @@cache[yaml_string]
        end
       
        # Convert a {PandocFilter::MetaMap} node to a YAML string.
        #
        # @param metadata [Meta|MetaMap] the {PandocFilter::MetaMap} node to
        #   convert to YAML.
        #
        # @return [String] the YAML representation of metadata.
        def self.to_yaml(metadata)
            @@cache ||= {}
            yaml_string = @@cache[metadata]
            if yaml_string.nil? or yaml_string.empty?
                json2yaml = Paru::Pandoc.new {from "json"; to "markdown"; standalone}
                metadata = PandocFilter::Meta.from_meta_map(metadata) unless metadata.is_a? PandocFilter::Meta
                meta_doc = PandocFilter::Document.new(PandocFilter::CURRENT_PANDOC_VERSION, metadata.to_ast, [])
                yaml_string = json2yaml << meta_doc.to_JSON
                @@cache[metadata] = yaml_string.strip
            end
            @@cache[metadata]

        end

        # Create a {PandocFilter::Meta} node from a Hash with String, Number,
        # Boolean, Array, or Hash values.
        #
        # @param hash [Hash] the hash to convert to a {PandocFilter::Meta}
        # node
        #
        # @return [MetaMap] the MetaMap node generated from hash
        def self.from_hash(hash) 
            if hash.empty?
                PandocFilter::Meta.new {}
            else
                yaml_string = YAML.dump hash
                Metadata.from_yaml "#{yaml_string}..."
            end
        end

        # Convert a {PandocFilter::MetaMap} node to Hash.
        #
        # @param metadata [Meta|MetaMap] the {PandocFilter::MetaMap} node to
        #   convert to a hash.
        #
        # @return [Hash] a Ruby Hash representation of metadata.
        def self.to_hash(metadata)
            yaml_string = Metadata.to_yaml metadata
            if yaml_string.empty?
                {}
            else
                YAML.load yaml_string
            end
        end

        # Inspect the cache with converted values
        #
        # @return [Hash]
        def self.cache()
            cache = @@cache ||= {}
            cache
        end

        # Clear the cache with converted values or remove one
        # value, converted value pair from the cache
        #
        # @param value [String|MetaMap = nil] delete this value from the
        #   cache. If value = nil, clear the whole cache; this is the default
        #   behavior of this clear function.
        def self.clear(value = nil)
            if value.nil?
                @@cache = {}
            else
                @@cache.delete value
            end
        end

    end
end
