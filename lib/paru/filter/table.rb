#--
# Copyright 2015, 2016, 2017, 2020, 2023 Huub de Beer <Huub@heerdebeer.org>
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
require_relative "./inline.rb"
require_relative "./caption.rb"
require_relative "./col_spec.rb"
require_relative "./row.rb"
require_relative "./table_head.rb"
require_relative "./table_foot.rb"
require_relative "./table_body.rb"
    
module Paru
    module PandocFilter

        # A Table node represents a table with an inline caption, column
        # definition, widths, headers, and rows.
        #
        # @!attribute caption
        #   @return Caption
        #  
        # @!attribute attr
        #   @return Attr
        #
        # @!attribute colspec
        #   @return ColSpec[]
        #
        # @!attribute head
        #   @return TableHead[]
        #   
        # @!attribute foot
        #   @return TableHead[]
        class Table < Block
            attr_accessor :caption, :attr, :colspec, :head, :foot

            # Create a new Table based on the contents
            #
            # @param contents [Array]
            def initialize(contents)
                @attr = Attr.new contents[0]
                @caption = Caption.new contents[1]
                @colspec = contents[2].map {|p| ColSpec.new p}
                @head = TableHead.new contents[3]
                super []
                contents[4].each do |table_body|
                    @children.push TableBody.new table_body
                end
                @foot = TableFoot.new contents[5]
            end

            # The AST contents of this Table node
            #
            # @return [Array]
            def ast_contents()
                [
                    @attr.to_ast,
                    @caption.to_ast,
                    @colspec.map {|c| c.to_ast},
                    @head.to_ast,
                    @children.map {|c| c.to_ast},
                    @foot.to_ast,
                ]
            end

            # Convert this table to a 2D table of markdown strings for each
            # cell
            #
            # @param config [Hash] configuraton of the table output
            #   Config can contain properties :headers
            #
            # @return [String[][]] This Table as a 2D array of cells
            # represented by their markdown strings.
            def to_array(config = {})
                headers = if config.has_key? :headers then config[:headers] else false end
                footers = if config.has_key? :footers then config[:footers] else false end

                data = []
                if headers then
                    data.concat @head.to_array
                end

                @children.each do |row|
                    data.concat row.to_array
                end
                
                if footers then
                    data.concat @foot.to_array
                end

                data
            end

            # Convert this Table to a CSV file. See to_array for the config
            # options
            #
            # @param filename [String] filename to write to
            # @param config [Hash] See #to_array for config options
            def to_file(filename, config = {})
                CSV.open(filename, "wb") do |csv|
                    to_array(**config).each {|row| csv << row}
                end
            end

            # Create a new Table from an 2D array and an optional
            # configuration
            #
            # @param data [String[][]] an array of markdown strings
            # @param config [Hash] configuration of the list.
            #   properties:
            #     :headers [Boolean] True if data includes headers on first
            #     row. Defailts to false.
            #     :caption [String] The table's caption
            #     :footers [Boolean] True if data includes footers on last row,
            #     default to false.
            #
            # @return [Table]
            def self.from_array(data, config = {})
                table_attribute = create_attr

                caption = []
                if config.has_key? :caption
                  caption = create_caption config[:caption]
                end

                col_spec = data[0].map {|c| ColSpec.new.to_ast }

                head = create_endrow []
                if config.has_key? :headers and config[:headers]
                  head = create_endrow data.first
                  data = data[1..-1]
                end

                foot = create_endrow []
                if config.has_key? :footers and config[:footers]
                  foot = create_endrow data.last
                  data = data[0...-1]
                end

                body = create_body data
                
                table = [
                  table_attribute, 
                  caption, 
                  col_spec, 
                  head, 
                  body, 
                  foot
                ]

                Table.new table
            end


            # Create a new Table from a CSV file.
            #
            # @param filename [String] filename to read CSV data from
            # @param config [Hash] See #from_file for details
            #
            # @return [Table]
            def self.from_file(filename, config = {}) 
                data = []
                CSV.foreach(filename) do |row|
                    data << row
                end

                return self.from_array(data, config) 
            end

            private

            def self.create_caption(contents)
              [
                nil,
                [Node.from_markdown(contents).to_ast]
              ]
            end

            def self.create_body(data) 
              [[
                create_attr,
                0,
                [],
                data.map {|r| create_row(r)}
              ]]
            end
            
            def self.create_endrow(data)
              [
                create_attr,
                if data.empty? then [] else [create_row(data)] end
              ]
            end

            def self.create_row(data)
              [
                  create_attr, 
                  data.map {|c| create_cell(c)}
              ]
            end

            def self.create_cell(contents)
              [
                create_attr,
                {"t" => "AlignDefault", "c" => nil},
                1,
                1,
                [Node.from_markdown(contents).to_ast]
              ]
            end

            def self.create_attr()
              ["", [], []]
            end

        end
    end
end
