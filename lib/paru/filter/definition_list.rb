module Paru
    module PandocFilter
        require_relative "./block"
        require_relative "./definition_list_item"

        class DefinitionList < Block
            def initialize contents
                super []
                contents[1].each do |item|
                    @children.push DefinitionListItem.new item
                end
            end
        end
    end
end
