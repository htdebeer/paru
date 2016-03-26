module Paru
    module PandocFilter
        require_relative "./inline"

        class LineBreak < Inline
            def initialize contents
                super []
            end

            def has_inline?
                false
            end
        end
    end
end

