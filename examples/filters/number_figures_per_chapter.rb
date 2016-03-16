#!/usr/bin/env ruby

require 'paru/filter'

current_chapter = 0
current_figure = 0;

Paru::Filter.new.run do |doc|
    doc.query("Heading[level=1]") do
        current_chapter += 1
        current_figure = 0
    end

    doc.query("Image") do |image|
        current_figure += 1
        image.innerMarkdown = "Figure #{current_chapter}.#{current_figure} #{image.innerMarkdown}"
    end
    doc
end
