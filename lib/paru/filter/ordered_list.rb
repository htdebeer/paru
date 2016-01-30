module Paru
    module PandocFilter
        require_relative "./list"
        require_relative "./list_attributes"

        class OrderedList < List
            attr_accessor :list_attributes
            def initialize contents
                @list_attributes = ListAttributes.new contents[0]
                super contents[1]
            end
        
        end
    end
end
