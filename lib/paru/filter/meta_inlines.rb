module Paru
    module PandocFilter

        require_relative "./node"

        class MetaInlines < Node
            
            def initialize value
                super value
            end
        end
    end
end
