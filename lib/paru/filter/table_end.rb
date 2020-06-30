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
require_relative "./row.rb"
    
module Paru
    module PandocFilter

        # A TableEnd node is the base class for the TableHead and TableFoot
        # nodes. It has attributes and one or more TableRows.
        #  
        # @!attribute attr
        #   @return Attr
        #
        # @!attribute rows
        #   @return [TableRow]
        class TableEnd < Block
            attr_accessor :attr, :rows

            # Create a new TableEnd based on the contents
            #
            # @param contents [Array]
            def initialize(contents)
                @attr = Attr.new contents[0]
                super []
                contents[1].each do |row|
                    @children.push Row.new row["c"]
                end
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
                    @children.map {|row| row.ast_contents},
                ]
            end

        end
    end
end
