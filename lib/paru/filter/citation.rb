module Paru
    module PandocFilter
        require_relative "./inline"

        class Citation
            attr_accessor :id, :prefix, :suffix, :mode, :note_num, :hash

            def initialize spec
                @id = spec["citationId"] if spec.has_key? "citationId"
                @prefix = Inline.new spec["citationPrefix"] if spec.has_key? "citationPrefix"
                @suffix = Inline.new spec["citationSuffix"] if spec.has_key? "citationSuffix"
                @mode = spec["citationMode"] if spec.has_key? "citationMode"
                @note_num = spec["citationNoteNum"] if spec.has_key? "citationNoteNum"
                @hash = spec["citationHash"] if spec.has_key? "citationHash"
            end

            def to_ast
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
