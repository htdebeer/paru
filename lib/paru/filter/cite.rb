module Paru
    module PandocFilter
        require_relative "./inline"

        class Cite < Inline
            attr_accessor :citations

            def initialize contents
                @citations = []
                contents[0].each do |citation|
                    @citations.push Citation.new(citation)
                end
                super contents[1]
            end

            def ast_contents
                [
                    @citations.map {|citation| citation.to_ast},
                    super
                ]
            end
        end
    end
end

