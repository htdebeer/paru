# Copyright 2015, 2016 Huub de Beer <Huub@heerdebeer.org>
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
module Paru
  module PandocFilter

    require "json"
    require_relative "./node"
    require_relative "./plain"
    require_relative "./meta"
    require_relative "./version"

    VERSION = "pandoc-api-version"
    META = "meta"
    BLOCKS = "blocks"

    CURRENT_PANDOC_VERSION = [1, 17, 4]

    class Document < Node

      attr_reader :meta

      def self.from_JSON json
        doc = JSON.parse json
        version, metadata, contents = doc.values_at(VERSION, META, BLOCKS)
        PandocFilter::Document.new version, metadata, contents
      end

      def self.fragment node_list
        meta = Hash.new

        if node_list.any? {|n| n.is_block?}
          new_doc = Document.new CURRENT_PANDOC_VERSION, meta, []
          new_doc.children = node_list
        else
          node = PandocFilter::Plain.new [] 
          node.children = node_list
          new_doc = Document.new CURRENT_PANDOC_VERSION, meta, [node.to_ast]
        end

        new_doc
      end

      def initialize(version, meta, contents)
        @version = Version.new version
        @meta = Meta.new meta
        super contents
      end

      def to_ast
        {
          VERSION => @version.to_ast,
          META => @meta.to_ast,
          BLOCKS => ast_contents
        }
      end

      def to_JSON
        to_ast.to_json
      end

    end
  end
end
