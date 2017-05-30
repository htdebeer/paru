#!/usr/bin/env ruby
##
# pandoc2yaml.rb extracts the metadata from a pandoc markdown file and prints
# that metadata out again as a pandoc markdown file with nothing in it but that
# metadata
#
# Usage:
#
#  pandoc2yaml.rb input_file
#
##
module Paru
    module Pandoc2Yaml
        require "json"
        require_relative "./pandoc.rb"

        # Paru converters:
        # Note. When converting metadata back to the pandoc markdown format, you have
        # to use the option "standalone", otherwise the metadata is skipped
        PANDOC_2_JSON = Paru::Pandoc.new {from "markdown"; to "json"}
        JSON_2_PANDOC = Paru::Pandoc.new {from "json"; to "markdown"; standalone}

        # When converting a pandoc document to JSON, or vice versa, the JSON object
        # has the following three properties:
        VERSION = "pandoc-api-version"
        META = "meta"
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
