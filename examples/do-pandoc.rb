#!/usr/bin/env ruby
require 'json'
require 'yaml'
require 'paru/pandoc'


if ARGV.size != 1 then
    warn "Expecting exactly one argument: the pandoc file to convert"
    exit
end

input = ARGV.first

pandoc2json = Paru::Pandoc.new {from 'markdown'; to 'json'}
json2pandoc = Paru::Pandoc.new {from 'json'; to 'markdown'; standalone}
json_metadata = JSON.parse(pandoc2json << File.read(input)).first
yaml_metadata = YAML.load(json2pandoc << JSON.generate([json_metadata, []]))

if yaml_metadata.has_key? 'pandoc' then
    begin
        pandoc = Paru::Pandoc.new
        to_stdout = true
        yaml_metadata['pandoc'].each do |option, value|
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
