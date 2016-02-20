module Paru
    module PandocFilter

        require_relative "./node"

        class MetaBlocks < Node
            attr_accessor :key

            def initialize key, value
                @key = key
                super value
            end
        end
    end
end
