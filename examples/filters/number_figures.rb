#!/usr/bin/env ruby

require 'paru/filter'

current = 0;

Paru::Filter.new.run do |doc|
    doc.query("Image") do |image|
        current += 1
        prefix = Paru::PandocFilter::Str.new "Figure #{current}. "
        image.prepend prefix
    end
    doc
end
