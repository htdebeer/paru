module Paru
    module PandocFilter
        class ListAttributes

            STYLES = ["DefaultStyle", "Example", "Decimal", "LowerRoman", "UpperRoman", "LowerAlpha", "UpperAlpha"]
            DELIMS = ["DefaultDelim", "Period", "OneParen", "TwoParens"]

            attr_accessor :start, :number_style, :number_delim
            def initialize attributes
                @start = attributes[0]
                @number_style = attributes[1]
                @number_delim = attributes[2]
            end
        end
    end
end
