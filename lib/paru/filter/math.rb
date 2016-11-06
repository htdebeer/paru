# Math MathType String
module Paru
  module PandocFilter
    require_relative "./inline"

    class Math < Inline
      attr_accessor :math_type, :string

      def initialize contents
        @math_type, @string = contents
      end

      def inline?
        "InlineMath" == @math_type[t]
      end

      def inline!
        @math_type = {
          "t" => "InlineMath"
        }
      end

      def display?
        "DisplayMath" == @math_type[t]
      end

      def display!
        @math_type = {
          "t" => "DisplayMath"
        }
      end

      def ast_contents
        [
          @math_type,
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
