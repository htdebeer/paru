module Paru
    module PandocFilter
        require_relative "./inline"

        class Str < Inline
            def initialize value
                @value = value
            end
        end
    end
end
