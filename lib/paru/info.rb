#--
# Copyright 2022 Huub de Beer <Huub@heerdebeer.org>
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

# frozen_string_literal: false
require_relative "error.rb"

module Paru
  # Information about pandoc
  #
  # @!attribute version
  #   @return [Array<Integer>] Pandoc's version, like [2, 18, 1]
  #
  # @!attribute data_dir
  #   @return [String] Pandoc's default data directory
  #
  # @!attribute scripting_engine
  #   @return [String] Pandoc's internal scripting engine, like "Lua 5.4"
  class Info
    attr_reader :version, :data_dir, :scripting_engine

    # Create a new Info object
    #
    # @param path [String] the path to pandoc. Defaults to 'pandoc', i.e.,
    # assumes it's on the environment's path.
    def initialize(path = "pandoc")
      begin
        # Get pandoc's version information
        version_string = ''
        IO.popen("#{path} --version", 'r+') do |p|
          p.close_write
          version_string << p.read
        end

        # Extract the version as an array of integers, like SemVer.
        @version = version_string
          .match(/pandoc.* (\d+\.\d+.*)$/)[1]
          .split(".")
          .map {|s| s.to_i}

        # Extract the data directory
        @data_dir = version_string.match(/User data directory: (.+)$/)[1]

        # Extract scripting engine
        @scripting_engine = version_string.match(/Scripting engine: (.+)$/)[1]
      rescue StandardError => err
        warn "Error extracting pandoc's information: #{err.message}"
        warn "Using made up values instead."

        @version = @version || [2, 18]
        @data_dir = @data_dir || "."
        @scripting_engine = @scripting_engine || "Lua 5.4"
      end
    end

    # Get pandoc's info by key like a Hash for backwards compatability.
    #
    # @deprecated Use Info's getters instead.
    # 
    # @param key [String|Symbol] the key for the information to look up.
    # Info only supports keys 'version' and 'data_dir'.
    # @return [Any] Information associated with the key.
    # @raise [Error] for an unknown key.
    def [](key)
      case key
      when "verion", :version
        version
      when "data_dir", :data_dir
        data_dir
      when "scripting_engine", :scripting_engine
        scripting_engine
      else
        throw Error.new "Info does not know key '#{key}'"
      end
    end
  end
end
