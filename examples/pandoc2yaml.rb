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
module Pandoc2Yaml
  require "json"
  require "paru/pandoc"

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

  def extract_metadata input_document
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

if __FILE__ == $0
  include Pandoc2Yaml

  if ARGV.size != 1 then
    warn "Expecting exactly one argument: the pandoc file to strip for metadata"
    exit
  end

  input_document = ARGV.first
  output_metadata = Pandoc2Yaml.extract_metadata input_document
  puts output_metadata
end
