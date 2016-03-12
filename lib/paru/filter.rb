module Paru

    require_relative "filter/document"
    
    class Filter

        def initialize
        end

        def run
            output = yield document if block_given? 
            puts output.to_json
        end

        def document
            meta, contents = JSON.parse $stdin.read
            document = PandocFilter::Document.new meta, contents
            document
        end

    end

end
