module Paru
    module PandocFilter
        require_relative "./inline"
    
        MATH_TYPE = ["DisplayMath", "InlineMath"]


        class Math < Inline
            attr_accessor :type, :string

            def initialize contents
                @type = contents[0]
                @string = contents[1]
            end
        end
    end
end
