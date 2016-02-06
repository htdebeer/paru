module Paru
    module PandocFilter
        require_relative "./block"

        class TableRow < Block
            def initialize row_data
                super []
                row_data.each do |cell|
                    @children.push Block.new cell
                end
            end
        end
    end
end
