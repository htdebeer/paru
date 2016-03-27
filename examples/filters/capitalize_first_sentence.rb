#!/usr/bin/env ruby
require 'paru/filter'

END_CAPITAL = 10
Paru::Filter.run do 
    with "Header +4 Para" do |p|
        text = p.inner_markdown
        first_line = text.slice(0, END_CAPITAL).upcase
        rest = text.slice(END_CAPITAL, text.size)
        p.inner_markdown = first_line + rest
    end
end

