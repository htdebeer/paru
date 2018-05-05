#!/usr/bin/env ruby
# Replace patterns like $key.value_with_parts$ with **key**: *value with parts*
require "paru/filter"

Paru::Filter.run do
    with "Math" do |m|
        key, value = m.string.split(".")
        values = value.split("_")
        m.markdown = "**#{key}**: *#{values.join(" ")}*"
    end
end
