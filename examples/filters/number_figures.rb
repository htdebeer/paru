#!/usr/bin/env ruby

require 'paru/filter'

current = 0;

Paru::Filter.new.run do |doc|
    doc.query("Image") do |image|
        current += 1
        image.innerMarkdown = "Figure #{current}. #{image.innerMarkdown}"
    end
    doc
end
