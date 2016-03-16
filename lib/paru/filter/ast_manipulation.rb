module Paru
    module PandocFilter
        module ASTManipulation

            def children
                if has_children?
                    @children
                else
                    []
                end
            end

            def children= list
                @children = list
            end

            def parent
                @parent
            end

            def parent= new_parent
                @parent = new_parent
            end

            def is_root
                parent.nil?
            end

            def is_node
                not is_leaf
            end

            def is_leaf
                not has_children?
            end

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
            
        end
    end
end
