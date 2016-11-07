#!/usr/bin/env ruby
require_relative "../../lib/paru/pandoc"
require_relative "../../lib/paru/filter"

Paru::Filter.run do 
  with "Para" do |paragraph|
    if paragraph.inner_markdown.lines.length == 1
      command, path = paragraph.inner_markdown.strip.split " "
      if command == "::paru::insert"
        markdown = File.read path.sub(/\\_/, "_")
        paragraph.outer_markdown = markdown
      end
    end
  end
end

