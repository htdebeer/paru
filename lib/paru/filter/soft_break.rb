module Paru
    module PandocFilter
        require_relative "./inline"

        class SoftBreak < Inline
            def initialize contents
                super []
            end

            def has_inline?
                false
            end
        end
    end
end

