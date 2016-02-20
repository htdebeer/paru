module Paru
    module PandocFilter

        require_relative "./inline"

        class RawInline < Inline
            attr_accessor :format, :string

            def initialize contents
                @format = contents[0]
                @string = contents[1]
            end

            def ast_contents
                [
                    @format,
                    @string
                ]
            end
        end
    end
end
