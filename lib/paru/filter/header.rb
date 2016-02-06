module Paru
    module PandocFilter
        require_relative "./block"
        require_relative "./attr"

        class Header < Block
            attr_accessor :level, :attr

            def initialize contents
                @level = contents[0]
                @attr = Attr.new contents[1]
                super contents[2], true
            end
        end
    end
end
