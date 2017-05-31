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
    require "json"
    require_relative "./pandoc.rb"

    # Utility class to extract YAML metadata form a markdown file in pandoc's
    # own markdown format.
    class Pandoc2Yaml
        # Paru converters:
        # Note. When converting metadata back to the pandoc markdown format, you have
        # to use the option "standalone", otherwise the metadata is skipped

        # Converter from pandoc's markdown to pandoc's AST JSON
        PANDOC_2_JSON = Paru::Pandoc.new {from "markdown"; to "json"}

        # Converter from pandoc's AST JSON back to pandoc. Note the
        # 'standalone' property, which is needed to output the metadata as
        # well.
        JSON_2_PANDOC = Paru::Pandoc.new {from "json"; to "markdown"; standalone}

        # When converting a pandoc document to JSON, or vice versa, the JSON object
        # has the following three properties:
        
        # Pandoc-type API version key
        VERSION = "pandoc-api-version"
        # Meta block key
        META = "meta"
        # Content's blocks key
        BLOCKS = "blocks"

        # Extract the YAML metadata from input document
        #
        # @param input_document [String] path to input document
        # @return [String] YAML metadata from input document on STDOUT
        def self.extract_metadata input_document
            json = JSON.parse(PANDOC_2_JSON << File.read(input_document))
            yaml = ""

            version, metadata = json.values_at(VERSION, META)

            if not metadata.empty? then
                metadata_document = {
                    VERSION => version, 
                    META => metadata, 
                    BLOCKS => []
                }

                yaml = JSON_2_PANDOC << JSON.generate(metadata_document)
            end

            yaml
        end
    end
end
