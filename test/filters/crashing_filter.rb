#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
    with "Emph" do |e|
        e.append(Paru::PandocFilter::Para.new([]))
    end
end
