#!/usr/bin/env ruby
require 'json'
require 'paru/pandoc'

pandoc2json = Paru::Pandoc.new {from 'markdown'; to 'json'}
json2pandoc = Paru::Pandoc.new {from 'json'; to 'markdown'; standalone}

# When converting metadata back to the pandoc markdown format, you have to use
# the option 'standalone', otherwise the metadata is skipped

if ARGV.size != 1 then
    warn "Expecting exactly one argument: the pandoc file to strip for metadata"
    exit
end

pandoc = ARGV.first
metadata = JSON.parse(pandoc2json << File.read(pandoc)).first
yaml = ""
if metadata.has_key? "unMeta" and not metadata["unMeta"].empty? then
    yaml = json2pandoc << JSON.generate([metadata, []])
end
puts yaml
