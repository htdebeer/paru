module Paru
    module PandocFilter

        require_relative "./node"

        class MetaValue < Node

            attr_accessor :key, :value

            def initialize key, value
                @key = key
                @value = value
            end

            def ast_contents
                @value
            end

        end
    end
end
