module Paru
    module PandocFilter
        require_relative "./inline"

        class Math < Inline
            attr_accessor :math_type, :string

            def initialize contents
                @math_type = contents[0]
                @string = contents[1]
            end

            def inline?
                "InlineMath" == @math_type[t]
            end

            def inline!
                @math_type = {
                    "t" => "InlineMath",
                    "c" => []
                }
            end

            def display?
                "DisplayMath" == @math_type[t]
            end

            def display!
                @math_type = {
                    "t" => "DisplayMath",
                    "c" => []
                }
            end
            
            def ast_contents
                [
                    @math_type,
                    @string
                ]
            end
        end
    end
end
