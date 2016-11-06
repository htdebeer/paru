# RawBlock Format String
module Paru
  module PandocFilter
    require_relative "./block"

    class RawBlock < Block
      attr_accessor :format, :string

      def initialize(contents)
        @format, @string = contents
      end

      def to_ast
        [
          @format,
          @string
        ]
      end

      def has_string?
        true
      end
    end
  end
end
