module Paru
    module PandocFilter
        require_relative "./node"

        class Inline < Node
           def initialize contents
              super contents, true
           end 
        end
    end
end
