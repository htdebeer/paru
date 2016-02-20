module Paru
    module PandocFilter

        require_relative "./node"

        class MetaInlines < Node
            attr_accessor :key
            
            def initialize key, value
                @key = key
                super value
            end
        end
    end
end
