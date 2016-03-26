module Paru
    module PandocFilter
        require_relative "./block"
        require_relative "./attr"

        class CodeBlock < Block
            attr_accessor :attr, :string

            def initialize(contents)
                @attr = Attr.new contents[0]
                @string = contents[1]
            end

            def ast_contents
                [
                    @attr.to_ast,
                    @string
                ]
            end

            def has_string?
                true
            end
        end
    end
end
