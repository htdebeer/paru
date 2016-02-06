module Paru
    module PandocFilter
        require_relative "./block"

        class Null < Block
            def initialize contents
                super []
            end
        end
    end
end
