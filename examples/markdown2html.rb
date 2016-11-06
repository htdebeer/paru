#!/usr/bin/env ruby
require "paru/pandoc"

USAGE = <<EOU
markdown2html.rb converts a markdown file to html

Usage:

    markdown2html.rb [input [output]]

- If no argument is given, markdown2html converts STDIN to STDOUT
- If one argument is given, markdown2html treats the argument as a
  path and converts it to STDOUT
- If two arguments are given, markdown2html treats both as paths
  and converts the first path to the second
EOU

begin
    output = $stdout
    case ARGV.length
    when 0
        # Convert STDIN to STDOUT
        markdown = $stdin.read
    when 1
        # Treat only argument as path to input file
        markdown = File.read(ARGV.first)
    when 2
        # Treat first argument as input file and second as output file
        markdown = File.read(ARGV.first)
        output = File.open(ARGV.last, "w")
    else
        warn "Error: Too many arguments"
        warn USAGE
        exit
    end

    html = Paru::Pandoc.new do
        from "markdown"
        to "html5"
        standalone
        toc
        # add any pandoc option you like
    end << markdown

    output.puts html
ensure
    output.close
end
