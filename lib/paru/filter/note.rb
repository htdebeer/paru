# Note [Block]
module Paru
  module PandocFilter

    require_relative "./inline"
    require_relative "./block"

    class Note < Inline
      def has_block?
        true
      end

      def has_inline?
        false
      end
      
      # Although Note is defined to be inline, often it will act like a block
      # element.
      def can_act_as_both_block_and_inline?
        true
      end
      
    end
  end
end
