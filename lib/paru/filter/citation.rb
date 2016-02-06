module Paru
    module PandocFilter
        require_relative "./inline"

        class Citation
            attr_accessor :id, :prefix, :suffix, :mode, :note_num, :hash

            def initialize spec
                @id = spec[0]
                @prefix = Inline.new spec[1]
                @suffix = Inline.new spec[2]
                @mode = spec[3]
                @note_num = spec[4]
                @hash = spec[5]
            end
        end
    end
end
