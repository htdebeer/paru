#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
    metadata.delete "pandoc" if metadata.has? "pandoc"
end
