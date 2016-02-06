module Paru
    module PandocFilter
        require_relative "./block"

        class Para < Block
            def initialize contents
                super contents, true
            end
        end
    end
end
