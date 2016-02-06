module Paru
    module PandocFilter
        require_relative "./block"
        require_relative "./inline"
        require_relative "./list_item"

        class DefinitionListItem < ListItem
            attr_accessor :term, :definition
            def initialize item
                @term = Inline.new item[0]
                super item[1]
                @definition = @children
            end
        end
    end
end
