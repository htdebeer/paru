module Paru
  module PandocFilter
    class Attr
      include Enumerable

      attr_accessor :id, :classes
      def initialize(attributes)
        @id, @classes, @data = attributes
      end

      def each
        @data.each
      end

      def [](key) 
        if @data.key_exists? key
          @data[key]
        end 
      end

      def has_key? name
        @data.key_exists? name
      end

      def has_class? name
        @classes.include? name
      end

      def to_ast
        [
          @id,
          @classes,
          @data
        ]
      end
    end
  end
end
