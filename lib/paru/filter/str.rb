module Paru
    module PandocFilter
        require_relative "./inline"

        class Str < Inline
            def initialize value
                @string = value
            end

            def ast_contents
                @string
            end

            def has_string?
                true
            end

            def has_inline?
                false
            end
        end
    end
end
