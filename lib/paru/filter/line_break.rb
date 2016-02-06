module Paru
    module PandocFilter
        require_relative "./inline"

        class LineBreak < Inline
            def initialize contents
                super []
            end
        end
    end
end

