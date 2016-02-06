module Paru
    module PandocFilter
        require_relative "./block"

        class HorizontalRule < Block
            def initialize contents
                super []
            end
        end
    end
end
