module Paru
  module PandocFilter
    require_relative "./node"

    class Block < Node
      def is_block?
        true
      end
    end
  end
end
