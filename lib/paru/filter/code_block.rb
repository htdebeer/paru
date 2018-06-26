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
require_relative "./block.rb"
require_relative "./attr.rb"
require_relative "./inner_markdown.rb"

module Paru
    module PandocFilter
        # A CodeBlock is a Block level node with an attribute object and the
        # code as a string
        #
        # @!attribute attr 
        #   @return [Attr]
        #
        # @!attribute string
        #   @return [String]
        class CodeBlock < Block
            include InnerMarkdown
            attr_accessor :attr, :string

            # Create a new CodeBlock based on the contents
            #
            # @param contents [Array] an array with the attribute and the code
            #   string
            def initialize(contents)
                @attr = Attr.new contents[0]
                @string = contents[1]
            end

            # An AST representation of this CodeBlock
            def ast_contents()
                [
                    @attr.to_ast,
                    @string
                ]
            end

            # Has this CodeBlock string contents?
            #
            # @return [Boolean] true
            def has_string?()
                true
            end

            # Write this CodeBlock's contents to file
            #
            # @param filename {String} the path to the file to write
            def to_file(filename)
                File.open(filename, "w") do |file|
                    file.write "#{@string}\n"
                end
            end

            # Create a new CodeBlock based on the contents of a file, and,
            # optionally, a language
            #
            # @param filename {String} the path to the file to read the
            #   contents from
            # @param language {String} the language of the contents
            #
            # @return [CodeBlock]
            def self.from_file(filename, language = "")
                return self.from_code_string(File.read(filename), language) 
            end

            # Get this CodeBlock's contents as a string
            #
            # @return [String]
            def to_code_string()
                return @string
            end

            # Create a new CodeBlock based on a string and, optionally, a
            # language
            # 
            #
            # @param code_string [String] the string with code to use as the
            #   contents of the CodeBlock
            # @param language [String] the optional language class
            # @return [CodeBlock]
            def self.from_code_string(code_string, language = "")
                attributes = ["", [language], []]
                code_block = CodeBlock.new [attributes, code_string]
                return code_block
            end
        end
    end
end
