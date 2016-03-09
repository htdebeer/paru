module Paru
    module PandocFilter

        require_relative "./node"

        class MetaBlocks < Node

            def initialize value
                super value
            end
        end
    end
end
