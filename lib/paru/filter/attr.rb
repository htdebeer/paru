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
                if @data.key_exists? key
                    @data[key]
                end 
            end

            def has_key? name
                @data.key_exists? name
            end

            def has_class? name
                @classes.include? name
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
