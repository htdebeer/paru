#!/usr/bin/env ruby
## Change inline code to bold inline code
require "paru/filter"

Paru::Filter.run do 
    with "Code" do |c|
        c.outer_markdown = "**#{c.outer_markdown}**"
    end
end
