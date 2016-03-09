module Paru
    module PandocFilter

        require_relative "./node"

        class MetaValue < Node

            attr_accessor :value

            def initialize value
                @value = value
            end

            def ast_contents
                @value
            end

        end
    end
end
