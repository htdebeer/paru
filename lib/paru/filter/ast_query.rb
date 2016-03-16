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

            class Selector

                def initialize selector
                    # parse selector
                    selectors = selector.split(/[ \t\n]/)
                    selectors.each do |sel|
                    end
                    # each part, try to match; build DSL
                    # mimick CSS or xpath?
                    #  a > b :: b child of a
                    #  a >> b :: b descendent of a
                    #  a + b :: a alongside b
                    #  a ++ b :: a sibling b
                    #
                end

            end

        end
    end
end
