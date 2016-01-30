module Paru
    module PandocFilter
        require_relative "./block"
        require_relative "./list_item"

        class List < Block
            def initialize contents
                super []
                contents[1].each do |item|
                    @children.push ListItem.new item
                end
            end
        end
    end
end
