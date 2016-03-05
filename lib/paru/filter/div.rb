module Paru
    module PandocFilter
        require_relative "./block"
        require_relative "./attr"

        class Div < Block
            def initialize contents
                @attr = Attr.new contents[0]
                super contents[1]
            end

            def ast_contents
                [
                    @attr.to_ast,
                    super
                ]
            end
        end
    end
end

