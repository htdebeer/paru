# Image Attr [Inline] Target
module Paru
  module PandocFilter

    require_relative "./link"

    class Image < Link
      # Although Image is defined to be inline, probably because in HTML it
      # can be an inline element, often it acts like a block element.
      def can_act_as_both_block_and_inline?
        true
      end
    end
  end
end
