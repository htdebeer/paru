module Paru
    module PandocFilter
        module ASTManipulation

            def insert index, child
                @children.insert index, child
            end

            def delete child
                @children.delete child
            end

            def remove_at index
                @children.delete_at index
            end 

            def append child
                @children.push child
            end
            alias << append

            def prepend child
                insert 0, child
            end

            def replace old_child, new_child
                @children.find_index old_child do |index|
                    replace_at index, new_child
                end
            end

            def replace_at index, new_child
                @children[index] = new_child
            end

            def each_depth_first &block
                yield self
                each {|child| child.each_depth_first(&block)} if has_children?
            end
            
        end
    end
end
