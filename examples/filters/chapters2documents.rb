#!/usr/bin/env ruby
require "paru/filter"

def titleize(header)
    header.inner_markdown.gsub(" ", "_").strip
end

def new_document()
    Paru::PandocFilter::Document.new Paru::PandocFilter::CURRENT_PANDOC_VERSION, [], []
end

doc = new_document
chapters = {}

Paru::Filter.run do 
    with "Header" do |header|
        if header.level == 1
            doc = new_document
            chapters[titleize(header)] = doc
        end
    end
    doc << current_node if current_node.parent.is_a? Paru::PandocFilter::Document
end

chapters.each do |title, document|
    filename = "#{title}.md"

    Paru::PandocFilter::AST2MARKDOWN.configure do
        output filename
    end << document.to_JSON

end
