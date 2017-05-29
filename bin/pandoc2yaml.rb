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
require "json"
require 'optparse'
require 'paru/pandoc2yaml'

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

yaml = Paru::Pandoc2Yaml.extract_metadata(document)

yaml = "---\n..." if yaml.empty?

puts yaml
