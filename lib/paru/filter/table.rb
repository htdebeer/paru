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
require "csv"
require_relative "./block.rb"
require_relative "./inline.rb"
    
module Paru
    module PandocFilter
        # The allignment of a table column
        ALIGNMENTS = ["AlignLeft", "AlignRight", "AlignCenter", "AlignDefault"]

        # A Table node represents a table with an inline caption, column
        # definition, widths, headers, and rows.
        #
        # @!attribute caption
        #   @return [Inline]
        #
        # @!attribute alignment
        #   @return [ALIGNMENTS]
        #
        # @!attribute column_widths
        #   @return [Float]
        #
        # @!attribute headers
        #   @return [TableRow]
        #
        # @!attribute rows
        #   @return [Array<TableRow>]
        class Table < Block
            attr_accessor :caption, :alignment, :column_widths, :headers, :rows

            # Create a new Table based on the contents
            #
            # @param contents [Array]
            def initialize(contents)
                @caption = Inline.new contents[0]
                @alignment = contents[1]
                @column_widths = contents[2]
                @headers = TableRow.new contents[3]
                @children = []
                contents[4].each do |row_data|
                    @children.push TableRow.new row_data
                end
            end

            # The AST contents of this Table node
            #
            # @return [Array]
            def ast_contents()
                [
                    @caption.ast_contents,
                    @alignment,
                    @column_widths,
                    @headers.ast_contents,
                    @children.map {|row| row.ast_contents}
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
            def to_array(**config)
                headers = if config.has_key? :headers then config[:headers] else false end

                data = []
                if headers then
                    data.push @headers.to_array
                end

                @children.each do |row|
                    data.push row.to_array
                end

                data
            end

            # Convert this Table to a CSV file. See to_array for the config
            # options
            #
            # @param filename [String] filename to write to
            # @param config [Hash] See #to_array for config options
            def to_file(filename, **config)
                CSV.open(filename, "wb") do |csv|
                    to_array(config).each {|row| csv << row}
                end
            end

            # Create a new Table from an 2D array and an optional
            # configuration
            #
            # @param data [String[][]] an array of markdown strings
            # @param config [Hash] configuration of the list.
            #   properties:
            #     :headers [Boolean] True if data includes headers on first
            #     row
            #     :caption [String] The table's caption
            #     :alignment [String[]] An array with alignments for each
            #     column. Should have an alignment for all columns. Defaults
            #     to "AlignLeft"
            #     :widhts [Number[]] An array with column widths. Should have
            #     a width for all columns. Use 0 for no set width. Defaults to
            #     0
            #
            # @return [Table]
            def self.from_array(data, **config)
                return Table.new [[],[],[],[],[]] if data.empty? 

                headers = if config.has_key? :headers then 
                              config[:headers] 
                          else 
                              false 
                          end
                caption = if config.has_key? :caption then 
                              Block.from_markdown(config[:caption]).ast_contents 
                          else 
                              [] 
                          end

                alignment = if config.has_key? :alignment then 
                                config[:alignment].map {|a| {"t" => "#{a}"}} 
                            else
                                data.first.map {|_| {"t"=>"AlignLeft"}}
                            end

                widths = if config.has_key? :widths then
                            config[:widths] 
                         else
                             data.first.map {|_| 0}
                         end

                header = []
                rows = data
                if headers then
                    header = data.first
                    header = header.map {|cell| [Block.from_markdown(cell).to_ast]}
                    rows = data.slice(1..-1)
                end
                
                rows = rows.map {|row| row.map {|cell| [Block.from_markdown(cell).to_ast]}}

                Table.new [caption, alignment, widths, header, rows]
            end


            # Create a new Table from a CSV file.
            #
            # @param filename [String] filename to read CSV data from
            # @param config [Hash] See #from_file for details
            #
            # @return [Table]
            def self.from_file(filename, **config) 
                data = []
                CSV.foreach(filename) do |row|
                    data << row
                end

                return self.from_array(data, config) 
            end
        end
    end
end
