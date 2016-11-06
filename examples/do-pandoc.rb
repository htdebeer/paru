#!/usr/bin/env ruby
require 'yaml'
require 'paru/pandoc'
require_relative './pandoc2yaml.rb'

include Pandoc2Yaml

if ARGV.size != 1 then
    warn "Expecting exactly one argument: the pandoc file to convert"
    exit
end

input = ARGV.first
metadata = YAML.load Pandoc2Yaml.extract_metadata(input)

if metadata.has_key? 'pandoc' then
    begin
        pandoc = Paru::Pandoc.new
        to_stdout = true
        metadata['pandoc'].each do |option, value|
            pandoc.send option, value
            to_stdout = false if option == 'output'
        end
        output = pandoc << File.read(input)
        puts output if to_stdout
    rescue Exception => e
        warn "Something went wrong while using pandoc:\n\n#{e.message}"
    end
else
    warn "Unsure what to do: no pandoc options in #{input}"
end
