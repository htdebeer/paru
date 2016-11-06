module Paru
  module PandocFilter

    class Alignment
      ALIGNMENTS = ["AlignLeft", "AlignRight", "AlignCenter", "AlignDefault"]

      def initialize config
        @config = config
      end
    end
  end
end
