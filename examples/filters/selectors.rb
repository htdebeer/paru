#!/usr/bin/env ruby

require 'paru/filter'

Paru::Filter.run do
    with "Strong > Para.meh +45 Header.bl" do
        # nothing
    end

    with "Para.list" do
    end

    with "Para.list -3 Para.item" do
    end
end
