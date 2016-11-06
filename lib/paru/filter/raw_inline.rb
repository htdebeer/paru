# RawInline Format String
module Paru
  module PandocFilter

    require_relative "./inline"

    class RawInline < Inline
      attr_accessor :format, :string

      def initialize contents
        @format, @string = contents
      end

      def ast_contents
        [
          @format,
          @string
        ]
      end

      def has_string?
        true
      end

      def has_inline?
        false
      end
    end
  end
end
