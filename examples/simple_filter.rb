#!/usr/bin/env ruby

require 'paru/filter'

filter = Paru::Filter.new
document = filter.process

puts document.meta
puts "----"
document.each do |block|
    puts "#{block}"
end
