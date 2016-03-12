module Paru
    module PandocFilter
        module ASTManipulation
            def append elt
                @children.push elt
            end
            alias << append

            def prepend elt
                @children = [elt].concat @children
            end
        end
    end
end
