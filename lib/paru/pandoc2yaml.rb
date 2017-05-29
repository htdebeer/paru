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

    if __FILE__ == $0
        require 'optparse'

        parser = OptionParser.new do |opts|
            opts.banner = "pandoc2yaml.rb mines a pandoc markdown file for its YAML metadata"
            opts.banner << "\n\nUsage: pandoc2yaml.rb some-pandoc-markdownfile.md"
            opts.separator ""
            opts.separator "Common options"

            opts.on_tail("-h", "--help", "Show this message") do
                puts opts
                exit
            end

            opts.on("-v", "--version", "Show version") do 
                puts "pandoc2yaml.rb is part of paru version 0.2.3"
                exit
            end
        end

        parser.parse! ARGV

        input_document = ARGV.pop

        if ARGV.size != 0 then
            warn "Expecting exactly one argument: the pandoc file to strip for metadata"
            puts ""
            puts parser
            exit
        end

        document = File.expand_path input_document
        if not File.exist? document
            warn "Cannot find file: #{input_document}"
            exit
        end

        if !File.readable? document
            warn "Cannot read file: #{input_document}"
            exit
        end

        yaml = Pandoc2Yaml.extract_metadata(document)

        yaml = "---\n..." if yaml.empty?

        puts yaml
    end
end
