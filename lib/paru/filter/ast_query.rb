module Paru
    module PandocFilter
        module ASTQuery

            def query selector, &block
                # xpath/css like selector
                @children.each do |child|
                    yield(child) if block_given? and child.type == selector
                    child.query(selector, &block) if child.has_children?
                end
            end
        end
    end
end
