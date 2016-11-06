module Paru
  module PandocFilter
    require_relative "./block"

    class EmptyBlock < Block
      def initialize _
        super []
      end

      def to_ast
        {
          "t" => ast_type
        }
      end
    end
  end
end
