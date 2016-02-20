module Paru
    module PandocFilter

        require_relative "./inline"
        require_relative "./attr"

        class Span < Inline
            attr_accessor :attr

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
