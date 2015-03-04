module Paru

  require 'yaml'

  # Pandoc is a wrapper around the pandoc system. See
  # <http://johnmacfarlane.net/pandoc/README.html> for details about pandoc.
  # This file is basically a straightforward translation from command line
  # program to ruby class

  class Pandoc

    def initialize &block 
      @options = {}
      configure(&block) if block_given?
    end

    def configure &block
      instance_eval(&block)
    end

    def to_command
      return "pandoc #{to_option_string}"
    end

    def convert input
      output = ''
      command = "pandoc #{to_option_string}"
      IO.popen(command, 'r+') do |p|
        p << input
        p.close_write
        output << p.read
      end
      return output
    end
    alias << convert

    # Pandoc has a number of "simple options": options that are either a flag or
    # can be set only once. These options are listed in 'pandoc_options.yaml'
    # with a default value. For each of these options a method is defined next:
    OPTIONS = YAML.load_file File.join(__dir__, 'pandoc_options.yaml')

    OPTIONS.keys.each do |option|
      if OPTIONS[option].class == Hash then

        # option can be set multiple times, for example adding multiple css
        # files

        default = OPTIONS[option]["default"]
        type = OPTIONS[option]["multiple"]

        if type == "array" then

          define_method(option) do |value = default|
            if not @options[option] then
              @options[option] = []
            end
            @options[option].push value
            self
          end

        elsif type == "hash" then

          define_method(option) do |key, value = default|
            if not @options[option] then
              @options[option] = {}
            end
            @options[option][key] = value
            self
          end

        end
      else
        # options that can be set only once
        default = OPTIONS[option]
        #simple_option option, default
        define_method(option) do |value = default|
          @options[option] = value
          self
        end
      end
    end

    def self.simple_method
        define_method(option) do |value = default|
          @options[option] = value
          self
        end
    end


    def filter command
      if @options[:filter] then
        @options[:filter].push command
      else
        @options[:filter] = [command]
      end
      self
    end

    def to_option_string
      options_arr = []
      @options.each do |option, value|
        option_string = "--#{option.to_s.gsub '_', '-'}"
        if value.class == TrueClass then
          options_arr.push "#{option_string}"
        elsif value.class == FalseClass then
          # skip
        elsif value.class == Array then
          options_arr.push value.map {|val| "#{option_string}=#{val.to_s}"}.join(' ')
        elsif value.class == Hash then
          value.each do |key, val| 
            if val.is_a? TrueClass then
              options_arr.push "#{option_string}=#{key}"
            else
              options_arr.push "#{option_string}=#{key}:'#{val}'"
            end
          end
        else
          options_arr.push "#{option_string}=#{value.to_s}"
        end
      end
      return options_arr.join(' ')
    end

  end

end
