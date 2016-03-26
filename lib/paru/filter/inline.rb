module Paru
    module PandocFilter
        require_relative "./node"

        class Inline < Node
           def initialize contents
              super contents, true
           end 

           def is_inline?
               true
           end

           def has_inline?
               true
           end
        end
    end
end
