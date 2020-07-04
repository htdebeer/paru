#--
# Copyright 2020 Huub de Beer <Huub@heerdebeer.org>
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
require "csv"
require_relative "./block.rb"
    
module Paru
    module PandocFilter

        # A TableEnd node is the base class for the TableHead and TableFoot
        # nodes. It has attributes and one or more rows.
        #  
        # @!attribute attr
        #   @return Attr
        #
        # @!attribute rows
        #   @return [Row]
        class TableEnd < Block
            attr_accessor :attr

            # Create a new TableEnd based on the contents
            #
            # @param contents [Array]
            def initialize(contents)
                @attr = Attr.new contents[0]
                super contents[1]
            end

            def rows()
              @children
            end
            
            # The AST contents of this Table node
            #
            # @return [Array]
            def ast_contents()
                [
                    @attr.to_ast,
                    @children.map {|row| row.to_ast},
                ]
            end
            
            # Convert this table end to a 2D table of markdown strings for each
            # cell
            #
            # @return [String[][]] This Table as a 2D array of cells
            # represented by their markdown strings.
            def to_array()
                @children.map do |row|
                    row.to_array
                end
            end

        end
    end
end
