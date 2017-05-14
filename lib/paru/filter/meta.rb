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
        require_relative "./meta_map"

        # A Meta node represents the metadata of a document. It is a MetaMap
        # node.
        #
        # @see http://hackage.haskell.org/package/pandoc-types-1.17.0.4/docs/Text-Pandoc-Definition.html#t:Meta
        class Meta < MetaMap
            include Enumerable

            # Create a new Meta node based on the contents
            #
            # @param value [String]
            def initialize(value)
                super value
            end

            # The type of a Meta is "meta"
            # 
            # @return [String] "meta"
            def ast_type()
                "meta"
            end

            # Convert this Meta node to an AST representation
            def to_ast()
                ast_contents
            end

        end
    end
end
