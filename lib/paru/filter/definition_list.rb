module Paru
    module PandocFilter
        require_relative "./block"

        class DefinitionList < Block
            def initialize contents
                super []
                contents.each do |item|
                    @children.push DefinitionListItem.new item
                end
            end

            def ast_contents
                @children.map {|child| child.to_ast}
            end
        end
    end
end
