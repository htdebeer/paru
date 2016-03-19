module Paru

    require_relative "filter/document"
    
    class Filter

        def self.run &block
            Filter.new().filter(&block)
        end

        def document
            meta, contents = JSON.parse $stdin.read
            document = PandocFilter::Document.new meta, contents
            document
        end

        def filter &block
            doc = document
            doc.each_depth_first do |node|
                @current_node = node
                instance_eval(&block)
            end
            puts doc.to_json
        end

        def with selector
            if matches? selector
                yield @current_node
            end
        end

        def matches? selector
            @current_node.type == selector
        end

        class Selector

            # A + B : B follows A immediately
            # A - B : B does not follow A immediately
            #
            # Ancestry not that relevant it seems?
            # A < B : B is a child of A
            # A << B : B is an descendent of A
            #
            # (maybe an optimal number to indicate distance?)
            # 
            # grammar:
            #
            # <relop>       ::= = != ~= < > <= >= (depending on type attr)
            # <selop>       ::= + - < <<
            # <type>        ::= [A-Z][a-z]+ (pandoc types)
            # <attr>        ::= [a-zA-Z]+   (pandoc attrs + paru attrs)
            # <val>         ::= [^]]* (converted to type of attr)
            # <node>        ::= <type>([<attr>(<relop><val>)?])*
            # <distance>    ::= [1-9][0-9]*
            # <selector>    ::= (<node> <selop><distance>)* <node>
            #

        end

    end

end
