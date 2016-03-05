module Paru
    module PandocFilter
        require_relative "./block"

        class List < Block
            def initialize contents
                super []
                contents.each do |item|
                    @children.push Block.new item
                end
            end

            def ast_contents
                @children.map {|child| child.ast_contents}
            end
        end
    end
end
