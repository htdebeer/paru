# Header Int Attr [Inline]
module Paru
  module PandocFilter
    require_relative "./block"
    require_relative "./attr"

    class Header < Block
      attr_accessor :level, :attr

      def initialize contents
        @level = contents[0]
        @attr = Attr.new contents[1]
        super contents[2], true
      end

      def ast_contents
        [
          @level,
          @attr.to_ast,
          super
        ]
      end

      def has_inline?
        true
      end
    end
  end
end
