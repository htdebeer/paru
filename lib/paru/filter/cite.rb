module Paru
    module PandocFilter
        require_relative "./inline"

        class Cite < Inline
            attr_accessor :citation

            def initialize contents
                @citation = Citation.new contents[0]
                super contents[1]
            end
        end
    end
end

