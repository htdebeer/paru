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
            @doc = document
            @nodes = []
            @doc.each_depth_first do |node|
                @nodes.push node
                instance_eval(&block)
            end
            puts @doc.to_json
        end

        def current_node
            @nodes.last
        end

        def with selector
            if matches? selector
                yield current_node
            end
        end

        def metadata
            @doc.meta
        end

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
        # <selectorlist>::= <selector>(, <selector>)*
        #
        # Image << Emph
        #
        #
        # Instead of a complex selector mechanism, it is probably better
        # to get for a simple one and leave the complex selection to ruby
        # code.

        RELATION_PATTERN = /\A
            \s*
            (?<relations>
                (?<relation> 
                            \s*
                            (?<other>[A-Z][a-zA-Z]*)
                            \s*
                            (?<selector>\+|-|>>|>)
                            \s*
                            (?<distance>[1-9][0-9]*)?
                )+
            )?
            \s*
        \Z/x
        SELECTOR_PATTERN = /\A
            \s*
            (?<relations>
                (?<relation> 
                            \s*
                            (?<other>[A-Z][a-zA-Z]*)
                            \s*
                            (?<selector>\+|-|>>|>)
                            \s*
                            (?<distance>[1-9][0-9]*)?
                )+
            )?
            \s*
            (?<type>[A-Z][a-zA-Z]*)
            \s*
        \Z/x

        def matches? selector_string
            parts = SELECTOR_PATTERN.match selector_string
            selector = SelectorNode.new parts[:type]

            while not parts[:relations].nil?
                distance = distance.to_i
                selector.add RelationSelectorNode.new(parts[:selector], distance, parts[:other], @nodes)
                parts = RELATION_PATTERN.match parts[:relations].slice(0, parts[:relations].size - parts[:relation].size)
            end

            selector.matches? current_node
        end


        class SelectorNode
            def initialize type
                @type = type
                @relations = []
            end

            def add relation
                @relations.push relation
            end

            def matches? node
                node.type == @type and @relations.all? {|r| r.matches? node}
            end
        end

        class RelationSelectorNode
            def initialize selector, distance, other_type, previous_nodes
                @selector = selector
                @distance = distance
                @other_type = other_type
                @previous_nodes = previous_nodes
            end

            def matches? node
                case @selector
                when "+"
                    in_sequence? node
                when "-"
                    not_in_sequence? node
                when ">>"
                    is_descendant? node
                when ">"
                    is_child? node
                else
                    true
                end 
            end

            def in_sequence? node
                previous_nodes.any? do |other|
                    other.type == @other_type
                end
            end

            def not_in_sequence? node
                previous_nodes.all? do |other|
                    other.type != @other_type
                end
            end

            def is_descendant? node
                distance = 0
                begin
                    distance += 1
                    parent = node.parent
                    ancestry = parent.type == @other_type
                end while not ancestry and not parent.is_root? and distance < @distance
                ancestry
            end

            def is_child? node
                node.parent.type == @other_type
            end

            def previous_nodes
                if @distance.nil? or @distance <= 0
                    @previous_nodes.slice(0, @previous_nodes.size - 1)
                else
                    @previous_nodes.slice(-1 * @distance - 1, @distance)
                end
            end
        end

    end

end
