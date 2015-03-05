module Paru

  require 'json'

  class Filter

    def self.ast &filter
      ast_hash = JSON.parse $stdin.read
      warn ast_hash
      ast_tree = yield AST.new ast_hash
      $stdout.write JSON.generate ast_tree.to_h
    end

  end
  
  class AST

    def initialize ast_hash
      @metadata = Meta.new ast_hash.first
      @content = ast_hash.last.map {|n| Node.new n}
    end

    def to_h
      [@metadata.to_h].push @content.map {|n| n.to_h }
    end

  end

  # see
  # http://hackage.haskell.org/package/pandoc-types-1.12.4.1/docs/Text-Pandoc-Definition.html
  # for spec of different kinds of nodes
  
  class Meta

    def initialize(hash)
      hash = hash["unMeta"]
      @content = {}
      hash.keys.each {|key| @content[key] = Node.new hash[key]}
    end

    def [](key)
      @content[key]
    end

    def to_h
      hash = {}
      @content.keys.each {|key| hash[key] = @content[key].to_h}
      {"unMeta" => hash}
    end
  end

  class Node

    attr_reader :type, :contents

    def initialize(ast_hash)
      @type = ast_hash["t"]
      @contents = ast_hash["c"]
    end

    def to_h
      {
        "t" => @type,
        "c" => @contents
      }
    end

  end




end
