module Paru
    module PandocFilter
        require_relative "./meta_map"

        class Meta < MetaMap
            include Enumerable

            def initialize contents
                super contents["unMeta"]
            end

            def ast_type
                "unMeta"
            end

            def to_ast
                {
                    "unMeta" => ast_contents
                }
            end

        end
    end
end
