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
require_relative "./pandoc.rb"

module Paru
    # Singleton utility module to convert a YAML document string to a pandoc AST
    # metadata {PandocFilter::MetaMap} node.
    module Metadata

        # Create a {PandocFilter::MetaMap} node from a YAML string. 
        #
        # Converted strings are cached as to not convert any string twice.
        # Conversion from YAML to pandoc is quite expensive as it involves
        # running pandoc.
        #
        # @param yaml_string [String] the YAML string to convert
        # @return [MetaMap] the MetaMap node generated from yaml_string
        def self.from_yaml(yaml_string)
            @@converted_strings ||= {}
            metadata = @@converted_strings[yaml_string]
            if metadata.nil?
                yaml2json = Paru::Pandoc.new {from "markdown"; to "json"} 
                json_string = yaml2json << yaml_string
                meta_doc = PandocFilter::Document.from_JSON json_string
                metadata = meta_doc.meta.to_meta_map
                @@converted_strings[yaml_string] = metadata
            end
            metadata
        end

        # Inspect the cache with converted YAML strings
        #
        # @return [Hash]
        def self.cache()
            cache = @@converted_strings ||= {}
            cache
        end

        # Clear the cache with converted YAML strings
        def self.clear()
            @@converted_strings = {}
        end

    end
end
