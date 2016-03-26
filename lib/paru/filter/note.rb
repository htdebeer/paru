module Paru
    module PandocFilter

        require_relative "./inline"
        require_relative "./block"

        class Note < Inline
            def has_block?
                true
            end

            def has_inline?
                false
            end
        end
    end
end
