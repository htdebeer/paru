#!/usr/bin/env ruby
# Simple filter to show of the before, after and any selector. It should first
# print "before", then "during" for each node, and finish with "after".
require "paru/filter"

Paru::Filter.run do
    before do 
      warn "before"  
    end

    with "*" do
      warn "during"
    end

    after do
      warn "after"
    end
end
