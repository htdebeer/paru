module Paru
    module PandocFilter

        require_relative "./node"
        require_relative "./meta"

        class Document < Node

            attr_reader :meta

            def initialize(meta, contents)
                super contents
                @meta = PandocFilter::Meta.new meta
            end

        end
    end
end
