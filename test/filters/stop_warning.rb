#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
    stop!
    warn "Do not show this warning!"
end
