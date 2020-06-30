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
require "json"

require_relative "./node.rb"
require_relative "./plain.rb"
require_relative "./meta.rb"
require_relative "./version.rb"

require_relative "../filter_error.rb"

module Paru
    module PandocFilter
        # Pandoc type version key
        VERSION = "pandoc-api-version"
        # Pandoc type meta key
        META = "meta"
        # Pandoc type block key
        BLOCKS = "blocks"

        # The current pandoc type version
        # @see https://hackage.haskell.org/package/pandoc-types
        CURRENT_PANDOC_VERSION = [1, 21]

        # Each file that is being filtered by pandoc is represented by a root
        # Document. It is the root node of the AST of the document in the file.
        #
        # @!attribute meta
        #   @return [Meta] the metadata of this document
        class Document < Node

            attr_accessor :meta

            # Create a new Document from a JSON representation of the AST
            #
            # @param json [String] a JSON string representation of the AST of a document
            # @return [Document] the newly created document
            #
            # @raise [ParuFilterError] when parsing JSON AST from pandoc fails
            #   or the parsed results do not make sense.
            def self.from_JSON(json)
                begin
                    doc = JSON.parse json
                    version, metadata, contents = doc.values_at(VERSION, META, BLOCKS)
                rescue Exception => e
                    raise FilterError.new <<WARNING
Unable to read document.

Most likely cause: Paru expects a pandoc installation that has been
compiled with pandoc-types >= #{CURRENT_PANDOC_VERSION.join('.')}. You can
check which pandoc-types have been compiled with your pandoc installation by
running `pandoc -v`. 

Original error message: #{e.message}
WARNING
                end

                if -1 == (version <=> CURRENT_PANDOC_VERSION)
                    if metadata.has_key?('debug_')
                        warn <<WARNING
pandoc-types API version used in document (version = #{version.join('.')}) is
lower than the version of pandoc-types used by paru
(#{CURRENT_PANDOC_VERSION.join('.')}. If you experience unexpected results,
please try updating pandoc or downgrading paru.
WARNING
                    end
                end

                PandocFilter::Document.new version, metadata, contents
            end

            # Create a new Document fragment from a list of Node elements
            #
            # @param node_list [Node[]] a list of nodes to create a Document
            #   fragment from
            #
            # @return [Document] the document containing nodes in node_list
            def self.fragment(node_list)
                meta = Hash.new

                if node_list.nil? or node_list.any? {|n| n.is_block?}
                    new_doc = Document.new CURRENT_PANDOC_VERSION, meta, []
                    new_doc.children = node_list
                else
                    node = PandocFilter::Plain.new [] 
                    node.children = node_list
                    new_doc = Document.new CURRENT_PANDOC_VERSION, meta, [node.to_ast]
                end

                new_doc
            end

            # Create a new Document node based on the pandoc type version,
            # metadata, and the contents of the document
            #
            # @param version [Integer = CURRENT_PANDOC_VERSION] the version of pandoc types
            # @param meta [Array = []] metadata
            # @param contents [Array = []] contents
            def initialize(version = CURRENT_PANDOC_VERSION, meta = [], contents = [])
                @version = Version.new version
                @meta = Meta.new meta
                super contents
            end


            # Create an AST representation of this Document
            def to_ast()
                {
                    VERSION => @version.to_ast,
                    META => @meta.to_ast,
                    BLOCKS => ast_contents
                }
            end

            # Create a JSON string representation of the AST of this Document.
            # Use this to write back the manipulated AST in a format that
            # pandoc understands.
            def to_JSON
                to_ast.to_json
            end

        end
    end
end
