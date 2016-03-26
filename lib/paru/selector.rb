module Paru

    require_relative "./filter"
    require_relative "./error"

    class SelectorParseError < Error
    end

    class Selector

        def initialize selector
            @type = "Unknown"
            @relations = []
            parse selector
        end

        def matches? node, filtered_nodes
            node.type == @type and 
                @classes.all? {|c| node.has_class? c } and    
                @relations.all? {|r| r.matches? node, filtered_nodes}
        end
       
        private 

        S = /\s*/
        TYPE = /(?<type>(?<name>[A-Z][a-zA-Z]*)(?<classes>(\.[a-zA-Z-]+)*))/
        OPERATOR = /(?<operator>\+|-|>)/
        DISTANCE = /(?<distance>[1-9][0-9]*)/
        RELATION = /(?<relation>#{S}#{TYPE}#{S}#{OPERATOR}#{S}#{DISTANCE}?#{S})/
        RELATIONS = /(?<relations>#{RELATION}+)/
        SELECTOR = /\A#{S}(?<selector>#{RELATIONS}?#{S}#{TYPE})#{S}\Z/
       
        def parse selector_string
            partial_match = expect_match SELECTOR, selector_string
            @type, @classes = expect_pandoc_type partial_match
            
            while continue_parsing? partial_match
                operator = expect partial_match, :operator
                distance = expect_integer partial_match, :distance 
                type, classes = expect_pandoc_type partial_match

                @relations.push Relation.new(operator, distance, type, classes)

                partial_match = rest partial_match
            end
        end 

        def is_pandoc_type type
            Paru::PANDOC_TYPES.include? type
        end

        def expect parts, part
            raise SelectorParseError.new "Expected #{part}" if parts[part].nil?
            parts[part]
        end

        def expect_match regexp, string
            match = regexp.match string
            raise SelectorParseError.new "Unable to parse '#{string}'" if match.nil?
            match
        end

        def expect_pandoc_type parts
            type = expect parts, :name
            classes = parts[:classes].split(".") if not parts[:classes].nil?
            raise SelectorParseError.new "Expected a Pandoc type, got '#{type}' instead" if not is_pandoc_type type
            [type, classes]
        end

        def expect_integer parts, part
            if parts[part].nil?
                number = 0
            else
                number = parts[part].to_i
                raise SelectorParseError.new "Expected a positive #{part}, got '#{parts[part]}' instead" if number <= 0
            end
            number
        end

        def continue_parsing? parts
            not parts.nil? and not parts[:relations].nil?
        end

        def rest parts
            rest_string = parts[:relations].slice 0, parts[:relations].size - parts[:relation].size
            RELATIONS.match rest_string
        end
    end

    class Relation
        def initialize selector, distance, type, classes
            @selector = selector
            @distance = distance
            @type = type
            @classes = classes
        end

        def matches? node, filtered_nodes
            previous_nodes = previous filtered_nodes, @distance
            case @selector
            when "+"
                in_sequence? node, previous_nodes
            when "-"
                not_in_sequence? node, previous_nodes
            when ">"
                is_descendant? node
            else
                true
            end 
        end

        def in_sequence? node, previous_nodes
            previous_nodes.any? do |other|
                other.type == @type and @classes.all? {|c| other.has_class? c}
            end
        end

        def not_in_sequence? node, previous_nodes
            previous_nodes.all? do |other|
                other.type != @type or not @classes.all? {|c| other.has_class? c}
            end
        end

        def is_descendant? node
            distance = 0
            begin
                distance += 1
                parent = node.parent
                ancestry = parent.type == @type and @classes.all? {|c| parent.has_class? c}
            end while not ancestry and not parent.is_root? and distance < @distance
            ancestry
        end

        def previous filtered_nodes, distance
            if distance <= 0
                filtered_nodes.slice(0, filtered_nodes.size - 1)
            else
                filtered_nodes.slice(-1 * distance - 1, distance)
            end
        end
    end
    
end
