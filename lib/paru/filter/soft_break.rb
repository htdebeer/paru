module Paru
    module PandocFilter
        require_relative "./inline"

        class SoftBreak < Inline
            def initialize contents
                super []
            end
        end
    end
end

