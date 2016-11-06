module Paru
  module PandocFilter

    class Target
      attr_accessor :url, :title
      def initialize contents
        @url = contents[0]
        @title = contents[1]
      end

      def to_ast
        [
          @url,
          @title
        ]
      end
    end
  end
end
