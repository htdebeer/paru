# BlockQuote [Block]
module Paru
  module PandocFilter
    require_relative "./block"

    class BlockQuote < Block
      def has_block?
        true
      end
    end
  end
end
