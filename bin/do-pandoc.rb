#!/usr/bin/env ruby
require "yaml"
require 'optparse'
require "paru/pandoc"
require "paru/pandoc2yaml"

parser = OptionParser.new do |opts|
  opts.banner = "do-pandoc.rb runs pandoc on an input file using the pandoc configuration specified in that input file."
  opts.banner << "\n\nUsage: do-pandoc.rb some-pandoc-markdownfile.md"
  opts.separator ""
  opts.separator "Common options"

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.on("-v", "--version", "Show version") do 
      puts "do-pandoc.rb is part of paru version 0.4.1"
    exit
  end
end

parser.parse! ARGV

input_document = ARGV.pop

if ARGV.size != 0 then
  warn "Expecting exactly one argument: the pandoc file to convert"
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
metadata = YAML.load yaml

if metadata.has_key? "pandoc" then
  begin
    pandoc = Paru::Pandoc.new
    to_stdout = true
    metadata["pandoc"].each do |option, value|
      if value.is_a? String then
          value = value.gsub '\\', ''
      elsif value.is_a? Array then
          value = value.map {|v| v.gsub '\\', '' if v.is_a? String}
      end
      pandoc.send option, value
      to_stdout = false if option == "output"
    end
    output = pandoc << File.read(document)
    puts output if to_stdout
  rescue Exception => e
    warn "Something went wrong while using pandoc:\n\n#{e.message}"
  end
else
    warn "Unsure what to do: no pandoc options in #{input_document}"
end
