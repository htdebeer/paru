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
        require_relative "./inline"

        # An EmptyInline node, has no content
        class EmptyInline < Inline

            # Create an EmptyInline node
            def initialize _
                super []
            end

            # Has this empty inline contents?
            #
            # @return [Boolean] false
            def has_inline?
                false
            end

            # Create an AST representation of this EmptyInline
            def to_ast
                {
                    "t" => ast_type
                }
            end
        end
    end
end
