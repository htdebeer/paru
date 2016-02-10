module Paru
    module PandocFilter
        require_relative "./inline"
        require_relative "./attr"

        class Code < Inline
            attr_accessor :attr

            def initialize contents
                @attr = Attr.new contents[0]
                super contents[1]
            end
        end
    end
end
