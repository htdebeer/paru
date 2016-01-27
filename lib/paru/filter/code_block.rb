module Paru
    module PandocFilter
        require_relative "./block"

        class CodeBlock < Block
            attr_accessor :attr, :string

            def initialize(contents)
                
                @attr = attr
                @string = string
            end
        end
    end
end
