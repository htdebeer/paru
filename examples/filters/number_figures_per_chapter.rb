#!/usr/bin/env ruby

require 'paru/filter'

current_chapter = 0
current_figure = 0;

Paru::Filter.run do
    with "Header" do |header|
        if header.level == 1 
            current_chapter += 1
            current_figure = 0

            header.innerMarkdown = "Chapter #{current_chapter}. #{header.innerMarkdown}"
        end
    end

    with "Header + Image" do |image|
        current_figure += 1
        image.innerMarkdown = "Figure #{current_chapter}.#{current_figure} #{image.innerMarkdown}"
    end
end
