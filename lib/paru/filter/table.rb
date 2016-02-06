module Paru
    module PandocFilter
        require_relative "./block"
        require_relative "./inline"
        require_relative "./alignment"

        class Table < Block
            attr_accessor :caption, :alignment, :column_widths, :headers, :rows

            def initialize contents
                @caption = Inline.new contents[0]
                @alignment = Alignment.new contents[1]
                @column_widths = contents[2]
                @headers = TableRow.new contents[3]
                @rows = []
                contents[4].each do |row_data|
                    @rows.push TableRow.new row_data
                end
            end
        end
    end
end
