module Paru
  module PandocFilter
    require_relative "./block"
    require_relative "./list"
    require_relative "./inline"

    class DefinitionListItem < Block
      attr_accessor :term, :definition
      def initialize item
        @term = Block.new item[0]
        @definition = List.new item[1]
      end

      def to_ast
        [
          @term.ast_contents,
          @definition.ast_contents
        ]
      end
    end
  end
end
