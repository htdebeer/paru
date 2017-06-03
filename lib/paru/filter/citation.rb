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
#--
require_relative "./inline.rb"
    
module Paru
    module PandocFilter
        # A Citation consists of an id, a prefix, a suffix, a mode, a note
        # number, and integer hash. All of which are optional.
        #
        # @see https://hackage.haskell.org/package/pandoc-types-1.17.0.5/docs/Text-Pandoc-Definition.html#t:Citation
        #
        # @!attribute id
        #   @return [String]
        #
        # @!attribute prefix
        #   @return [Array<Inline>]
        #
        # @!attribute suffix
        #   @return [Array<Inline>]
        #
        # @!attribute mode
        #   @return [String]
        #
        # @!attribute note_num
        #   @return [Integer]
        #
        # @!attribute hash  
        #   @return [Integer]
        class Citation
            attr_accessor :id, :prefix, :suffix, :mode, :note_num, :hash

            # Create a new Citation node base on an AST specification
            #
            # @param spec [Hash] the specification of this citation
            def initialize(spec)
                @id = spec["citationId"] if spec.has_key? "citationId"
                @prefix = Inline.new spec["citationPrefix"] if spec.has_key? "citationPrefix"
                @suffix = Inline.new spec["citationSuffix"] if spec.has_key? "citationSuffix"
                @mode = spec["citationMode"] if spec.has_key? "citationMode"
                @note_num = spec["citationNoteNum"] if spec.has_key? "citationNoteNum"
                @hash = spec["citationHash"] if spec.has_key? "citationHash"
            end

            # Convert this Citation to an AST representation
            def to_ast()
                citation = Hash.new
                citation["citationId"] = @id if not @id.nil?
                citation["citationPrefix"] = @prefix.ast_contents if not @prefix.nil?
                citation["citationSuffix"] = @suffix.ast_contents if not @suffix.nil?
                citation["citationMode"] = @mode if not @mode.nil?
                citation["citationNoteNum"] = @note_num if not @note_num.nil?
                citation["citationHash"] = @hash if not @hash.nil?
                citation
            end
        end
    end
end
