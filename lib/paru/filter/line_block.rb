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
#--
require_relative "./list.rb"

module Paru
    module PandocFilter
        # A LineBlock is a List of Lists of Inline nodes
        class LineBlock < List
            # Create a new LineBlock node based on contents
            #
            # @param contents [Array] the contents of the LineBlock
            def initialize(contents)
                super(contents, Para)
            end
        end
    end
end
