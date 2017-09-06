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
require_relative "./node.rb"

module Paru
    module PandocFilter
        # Version is a general Node containing the pandoc-api-version. It has
        # the format major.minor.revision.sub
        class Version < Node

            # Create a Version node based on contents
            #
            # @param contents [Array<Integer>] a list with api, major, minor,
            # revision number
            def initialize(contents)
                @revision = 0
                @api, @major, @minor = contents if content.length == 3
                @api, @major, @minor, @revision = contents if content.length == 4
            end

            # The AST type is "pandoc-api-version"
            def ast_type
                "pandoc-api-version"
            end        

            # Create an AST representation of this Version
            def to_ast()
                [@api, @major, @minor, @revision]
            end
        end
    end
end
