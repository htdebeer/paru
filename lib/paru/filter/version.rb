module Paru
  module PandocFilter
    require_relative "./node"
    
    class Version < Node
      def initialize contents
        @major, @minor, @revision = contents
      end

      def ast_type
        "pandoc-api-version"
      end        

      def to_ast
        [@major, @minor, @revision]
      end
    end
  end
end
