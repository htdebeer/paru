#!/usr/bin/env ruby

require 'paru/filter'

Paru::Filter.run do
    with "Div.example" do |div|
        div.innerMarkdown = " example"
    end

    with "Div" do |div|
        div.innerMarkdown = " Div"
    end

end
