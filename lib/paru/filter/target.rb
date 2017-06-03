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
module Paru
    module PandocFilter
        # A Target represents the target of a link or image
        #
        # @!attribute url
        #   @return [String] the target
        #
        # @!attribute title
        #   @return [String] the title of the target
        class Target
            attr_accessor :url, :title

            # Create a new Target based on the contents
            #
            # @param contents [Array]
            def initialize(contents)
                @url = contents[0]
                @title = contents[1]
            end

            # Create an AST representation of this Target
            #
            # @return [Array]
            def to_ast()
                [
                    @url,
                    @title
                ]
            end
        end
    end
end
