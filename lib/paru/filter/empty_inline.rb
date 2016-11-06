module Paru
  module PandocFilter
    require_relative "./inline"

    class EmptyInline < Inline
      def initialize _
        super []
      end
      
      def has_inline?
        false
      end

      def to_ast
        {
          "t" => ast_type
        }
      end
    end
  end
end
