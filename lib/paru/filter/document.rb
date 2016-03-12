module Paru
    module PandocFilter

        require 'json'
        require_relative "./node"
        require_relative "./plain"
        require_relative "./meta"

        class Document < Node

            attr_reader :meta

            def self.fragment node_list
                meta = Hash.new
                meta["unMeta"] = Hash.new
                node = PandocFilter::Plain.new []
                node.children = node_list

                Document.new meta, [node.to_ast]
            end

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
