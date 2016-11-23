#--
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
#++
module Paru
  module PandocFilter

    require_relative "./node"

    # MetaMap (M.Map String MetaValue)
    class MetaMap < Node

      def initialize contents
        @children = Hash.new

        if contents.is_a? Hash
          contents.each_pair do |key, value|
            if not value.empty? and PandocFilter.const_defined? value["t"]
              @children[key] = PandocFilter.const_get(value["t"]).new value["c"]
            end
          end
        end
      end

      def [](key)
        if @children.key_exists?
          @children[key]
        end
      end

      def has_key? key 
        @children.has_key? key
      end

      def delete key
        @children.delete key
      end

      def ast_contents
        ast = Hash.new
        @children.each_pair do |key, value|
          ast[key] = value.to_ast
        end
        ast
      end

    end
  end
end
