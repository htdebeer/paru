#--
# Copyright 2015, 2016, 2017 Huub de Beer <Huub@heerdebeer.org>
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
#++
require_relative "./list.rb"

module Paru
    module PandocFilter
        # BulletList, contains a list of list of Block nodes.
        class BulletList < List

            # Create a new BulletList from an array of markdown strings
            #
            # @param array [String[]] arrau of markdown strings as items of
            #   the new BulletList
            # @return [BulletList]
            def self.from_array(array)
                ast_array = array.map {|item| [Block.from_markdown(item).to_ast]}
                BulletList.new ast_array
            end
        end
    end
end
