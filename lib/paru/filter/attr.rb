module Paru
    module PandocFilter
        class Attr
            attr_accessor :id, :classes
            def initialize(attributes)
                @id = attributes[0]
                @classes = attributes[1]
                @data = attributes[2]
            end

            def [](key) 
                if @data.key_exists?
                    @data[key]
                end 
            end
        end
    end
end
