#!/usr/bin/env ruby
# Tags all inline nodes with 'TAG:(...)'
require "paru/filter"

Paru::Filter.run do
    with "*" do |node|
      if node.is_inline? then
        node.inner_markdown = "TAG:(#{node.inner_markdown})"
      end
    end
end
