#!/usr/bin/env ruby
require_relative "../../lib/paru/filter.rb"

Paru::Filter.run do
  with "Image" do |image|
    caption = image.inner_markdown
    if image.attr.has_key? "width"
      caption += " (width=#{image.attr["width"]})"
    end
    if image.attr.has_key? "height"
      caption += " (height=#{image.attr["height"]})"
    end
    image.inner_markdown = caption
  end
end
