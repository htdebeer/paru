module Paru
    module PandocFilter
        class Attr
            include Enumerable

            attr_accessor :id, :classes
            def initialize(attributes)
                @id = attributes[0]
                @classes = attributes[1]
                @data = attributes[2]
            end
            
            def each
                @data.each
            end

            def [](key) 
                if @data.key_exists?
                    @data[key]
                end 
            end

            def to_ast
                [
                    @id,
                    @classes,
                    @data
                ]
            end
        end
    end
end
