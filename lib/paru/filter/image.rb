# Copyright 2015, 2016 Huub de Beer <Huub@heerdebeer.org>
#
# This file is part of Paru
#
# Paru is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Paru is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Paru.  If not, see <http://www.gnu.org/licenses/>.
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
