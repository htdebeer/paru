module Paru
    module PandocFilter
        require_relative "./inline"

        class Space < Inline
            def initialize contents
                super []
            end
        end
    end
end
