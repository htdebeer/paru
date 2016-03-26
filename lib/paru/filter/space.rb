module Paru
    module PandocFilter
        require_relative "./inline"

        class Space < Inline
            def initialize contents
                super []
            end

            def has_inline?
                false
            end
        end
    end
end
