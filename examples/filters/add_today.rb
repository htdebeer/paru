#!/usr/bin/env ruby
## Add today's date to the metadata
require "paru/filter"
require "date"

Paru::Filter.run do 
    metadata.yaml <<~YAML
        ---
        date: #{Date.today.to_s}
        ...
    YAML
end
