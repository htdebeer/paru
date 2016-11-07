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

      def to_json
        to_ast.to_json
      end

    end
  end
end
