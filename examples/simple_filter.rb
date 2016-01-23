#!/usr/bin/env ruby

require 'paru/filter'

filter = Paru::Filter.new
document = filter.process

puts document.meta
puts "----"
document.each do |block|
    if block.count > 0 then
        block.each do |b|
            puts b
        end
    else
        puts block
    end
end
