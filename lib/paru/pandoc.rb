#--
# Copyright 2015, 2016, 2017 Huub de Beer <Huub@heerdebeer.org>
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
require "shellwords"
require "yaml"

module Paru
    # Pandoc is a wrapper around the pandoc document converter. See
    # <http://pandoc.org/README.html> for details about pandoc.  The Pandoc
    # class is basically a straightforward translation from the pandoc command
    # line program to Ruby. It is a Rubyesque API to work with pandoc.
    #
    # For information about writing pandoc filters in Ruby see {Filter}.
    #
    # Creating a Paru pandoc converter in Ruby is quite straightforward: you
    # create a new Paru::Pandoc object with a block that configures that
    # Pandoc object with pandoc options. Each command-line option to pandoc is
    # a method on the Pandoc object. Command-line options with dashes in them,
    # such as "--reference-docx", can be called by replacing the dash with an
    # underscore. So, "--reference-docx" becomes the method +reference_docx+.
    #
    # Pandoc command-line flags, such as "--parse-raw", "--chapters", or
    # "--toc", have been translated to Paru::Pandoc methods that take an
    # optional Boolean parameter; +true+ is the default value. Therefore, if
    # you want to enable a flag, no parameter is needed.
    #
    # All other pandoc command-line options are translated to Paru::Pandoc
    # methods that take either one String or Number argument, or a list of
    # String arguments if that command-line option can occur more than once
    # (such as "--include-before-header" or "--filter").
    #
    # Once you have configured a Paru::Pandoc converter, you can call
    # +convert+ or +<<+ (which is an alias for +convert+) with a string to
    # convert. You can call +convert+ as often as you like and, if you like,
    # reconfigure the converter in between!
    #
    #
    # @example Convert the markdown string 'hello *world*' to HTML
    #     Paru::Pandoc.new do
    #         from 'markdown
    #         to 'html'
    #     end << 'hello *world*'
    #
    # @example Convert a HTML file to DOCX with a reference file
    #     Paru::Pandoc.new do
    #         from "html"
    #         to "docx"
    #         reference_docx "styled_output.docx"
    #         output "output.docx"
    #     end.convert File.read("input.html")
    #
    # @example Convert a markdown file to html but add in references in APA style
    #     Paru::Pandoc.new do
    #         from "markdown"
    #         toc
    #         bibliography "literature.bib"
    #         to "html"
    #         csl "apa.csl"
    #         output "report_with_references.md"
    #     end << File.read("report.md")
    #
    #
    class Pandoc

        # Gather information about the pandoc installation. It runs +pandoc
        # --version+ and extracts pandoc's version number and default data
        # directory. This method is typically used in scripts that use Paru to
        # automate the use of pandoc.
        #
        # @return [Hash{:version => String, :data_dir => String}] Pandoc's
        #   version, such as "1.17.0.4" and the data directory, such as "/home/huub/.pandoc".
        def self.info()
            output = ''
            IO.popen('pandoc --version', 'r+') do |p|
                p.close_write
                output << p.read
            end
            version = output.match(/pandoc (\d+\.\d+.*)$/)[1]
            data_dir = output.match(/Default user data directory: (.+)$/)[1]

            {
                :version => version,
                :data_dir => data_dir
            }
        end

        # Create a new Pandoc converter, optionally configured by a block with
        # pandoc options. See {#configure} on how to configure a converter.
        #
        # @param block [Proc] an optional configuration block.
        def initialize(&block)
            @options = {}
            configure(&block) if block_given?
        end

        # Configure this Pandoc converter with block. In the block you can
        # call all pandoc options as methods on this converter. In multi-word
        # options the dash (-) is replaced by an underscore (_)
        #
        # Pandoc has a number of command line options. Most are simple options,
        # like flags, that can be set only once. Other options can occur more than
        # once, such as the css option: to add more than one css file to a
        # generated standalone html file, use the css options once for each
        # stylesheet to include. Other options do have the pattern key[:value],
        # which can also occur multiple times, such as metadata. 
        #
        # All options are specified in a pandoc_options.yaml. If it is an option
        # that can occur only once, the value of the option in that yaml file is
        # its default value. If the option can occur multiple times, its value is
        # an array with one value, the default value.
        #
        # @param block [Proc] the options to pandoc
        # @return [Pandoc] this Pandoc converter
        #
        # @example Configure converting HTML to LaTeX with a LaTeX engine
        #   converter.configure do
        #       from 'html'
        #       to 'latex'
        #       latex_engine 'lualatex'
        #   end
        #
        def configure(&block)
            instance_eval(&block)
            self
        end

        # Converts input string to output string using the pandoc invocation
        # configured in this Pandoc instance.
        #
        # @param input [String] the input string to convert
        # @return [String] the converted output string
        #
        # The following two examples are the same:
        #
        # @example Using convert
        #   output = converter.convert 'this is a *strong* word'
        #
        # @example Using <<
        #   output = converter << 'this is a *strong* word'
        def convert(input)
            output = ''
            IO.popen(to_command, 'r+') do |p|
                p << input
                p.close_write
                output << p.read
            end
            output
        end
        alias << convert

        # Create a string representation of this converter's pandoc command
        # line invocation. This is useful for debugging purposes.
        #
        # @param option_sep [String] the string to separate options with
        # @return [String] This converter's command line invocation string.
        def to_command(option_sep = " \\\n\t")
            "pandoc\t#{to_option_string option_sep}"
        end

        private

        def escape(value) 
            if Gem.win_platform?
                value.to_s
            else
                value.to_s.shellescape
            end
        end
        
        def to_option_string(option_sep)
            options_arr = []
            @options.each do |option, value|
                option_string = "--#{option.to_s.gsub '_', '-'}"

                case value
                when TrueClass then
                    # Flags don't have a value, only its name
                    # For example: --standalone
                    options_arr.push "#{option_string}"
                when FalseClass then
                    # Skip this option; consider a flag with value false as unset
                when Array then
                    # This option can occur multiple times: list each with its value.
                    # For example: --css=main.css --css=print.css
                    options_arr.push value.map {|val| "#{option_string}=#{escape(val)}"}.join(option_sep)
                else
                    # All options that aren't flags and can occur only once have the
                    # same pattern: --option=value
                    options_arr.push "#{option_string}=#{escape(value)}"
                end
            end
            options_arr.join(option_sep)
        end

        # For each pandoc command line option a method is defined as follows:
        OPTIONS = YAML.load_file File.join(__dir__, 'pandoc_options.yaml')

        OPTIONS.keys.each do |option|
            if OPTIONS[option].is_a? Array then

                # option can be set multiple times, for example adding multiple css
                # files

                default = OPTIONS[option][0]

                define_method(option) do |value = default|
                    if @options[option].nil? then
                        @options[option] = []
                    end

                    if value.is_a? Array then
                        @options[option] += value
                    else
                        @options[option].push value
                    end

                    self
                end

            else
                # option can be set only once, for example a flag or a template

                default = OPTIONS[option]
                define_method(option) do |value = default|
                    @options[option] = value
                    self
                end

            end
        end

    end

end
