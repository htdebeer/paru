# Meta is a MetaMap
module Paru
  module PandocFilter
    require_relative "./meta_map"

    class Meta < MetaMap
      include Enumerable

      def initialize contents
        super contents
      end

      def ast_type
        "meta"
      end

      def to_ast
        ast_contents
      end

    end
  end
end
