module Paru
    module PandocFilter
        require_relative "./inline"

        class Quoted < Inline
            QUOTE_TYPE = ["SingleQuote", "DoubleQuote"]

            attr_accessor :quote_type

            def initialize contents
                @quote_type = contents[0]
                super contents[1]
            end

            def ast_contents
                [
                    @quote_type,
                    super
                ]
            end
        end
    end
end
