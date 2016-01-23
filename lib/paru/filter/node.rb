module Paru
    module PandocFilter
        class Node

            include Enumerable

            # require all pandoc types
            Dir[File.dirname(__FILE__) + '/*.rb'].each do |file|
                require_relative file
            end

            def initialize contents
                @children = []

                if contents.is_a? Array
                    contents.each do |elt|
                        if PandocFilter.const_defined? elt["t"]
                            @children.push PandocFilter.const_get(elt["t"]).new elt["c"]
                        else
                            @children.push PandocFilter::Block.new elt["c"]
                        end
                    end
                end
            end

            def each
                @children.each do |child|
                    yield child
                end
            end

            def to_s
                self.class.name
            end
        end
    end
end
