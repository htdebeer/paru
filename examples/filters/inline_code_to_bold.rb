#!/usr/bin/env ruby
## Change inline code to bold inline code
require "paru/filter"

Paru::Filter.run do 
    with "Code" do |c|
        c.markdown = "**#{c.markdown}**"
    end
end
