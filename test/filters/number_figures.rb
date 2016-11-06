#!/usr/bin/env ruby
require_relative "../../lib/paru/filter"

current = 0;

Paru::Filter.run do 
  with "Image" do |image|
    current += 1
    image.inner_markdown = "Figure #{current}. #{image.inner_markdown}"
  end
end
