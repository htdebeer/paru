#!/usr/bin/env ruby
# Add the CSS classes "table" and "table-striped" to HTML tables generated
# from markdown. This is a fairly simplistic solution, but works fine for a
# simple update to generated HTML tables.
require "paru/filter"
require "paru/pandoc"

Paru::Filter.run do
    with "Table" do |table|
      html_table = Paru::Pandoc.new {from "markdown"; to "html"} << table.markdown
      html_node = Paru::PandocFilter::Node.from_markdown html_table.sub(/<table/, "<table class=\"table table-striped\" ")
      table.parent.replace(table, html_node)
    end
end
