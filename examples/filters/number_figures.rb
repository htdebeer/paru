#!/usr/bin/env ruby

require 'paru/filter'

current = 0;

Paru::Filter.run do 
    with "Image" do |image|
        current += 1
        image.innerMarkdown = "Figure #{current}. #{image.innerMarkdown}"
    end
end
