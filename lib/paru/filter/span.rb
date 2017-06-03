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
require_relative "./inline.rb"
require_relative "./attr.rb"

module Paru
    module PandocFilter
        # A Span node is a general Inline level node with attributes and
        # contens
        #
        # @!attribute attr
        #   @return [Attr]
        class Span < Inline
            attr_accessor :attr

            # Create a new Span node based on the contents
            #
            # @param contents [Array]
            def initialize(contents)
                @attr = Attr.new contents[0]
                super contents[1]
            end

            # The AST contents
            #
            # @return [Array]
            def ast_contents()
                [
                    @attr.to_ast,
                    super
                ]
            end
        end
    end
end
