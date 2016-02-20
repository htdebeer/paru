module Paru
    module PandocFilter

        require "json"
        require_relative "./node"
        require_relative "./meta"

        class Document < Node

            attr_reader :meta

            def initialize(meta, contents)
                @meta = Meta.new meta
                super contents
            end

            def to_ast
                [
                    @meta.to_ast,
                    ast_contents
                ]
            end

            def to_json
                to_ast.to_json
            end

        end
    end
end
