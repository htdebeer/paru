module Paru

    require_relative "filter/document"
    
    require 'json'

    class Filter

        def initialize
        end

        def process
            meta, contents = JSON.parse $stdin.read
            document = PandocFilter::Document.new meta, contents
            document
        end

    end

end
