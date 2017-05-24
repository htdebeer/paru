#!/usr/bin/env ruby
# Number all figures in a document and prefix the caption with "Figure".
require "paru/filter"

figure_counter = 0;

Paru::Filter.run do 
    with "Image" do |image|
        figure_counter += 1
        image.inner_markdown = "Figure #{figure_counter}. #{image.inner_markdown}"
    end
end
