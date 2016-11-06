# Link Attr [Inline] Target
module Paru
  module PandocFilter

    require_relative "./inline"
    require_relative "./attr"
    require_relative "./target"

    class Link < Inline
      attr_accessor :attr, :target

      def initialize contents
        @attr = Attr.new contents[0]
        super contents[1]
        @target = Target.new contents[2]
      end

      def ast_contents
        [
          @attr.to_ast,
          super,
          @target.to_ast
        ]
      end

    end
  end
end
