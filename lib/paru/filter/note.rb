module Paru
    module PandocFilter

        require_relative "./inline"
        require_relative "./block"

        class Note < Inline
        end
    end
end
