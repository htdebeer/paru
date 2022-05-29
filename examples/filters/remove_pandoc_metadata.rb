#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
  before do
    metadata.delete "pandoc"
  end
end
