# Paru: PAndoc wrapped around RUby

Paru is a simple ruby wrapper around [pandoc](http://www.pandoc.org), a great
multi-format document converter.

- version 0.0.1
- licence: GPL3

# Installation

    gem install paru

# Requirements

Pandoc. See http://pandoc.org/installing.html about how to install pandoc on
your system.

# Usage

## Converting markdown to html

(See also `examples/markdown2html.rb`)

Using Paru is straightforward. For example, to convert a markdown file to
html5 and send it to stdout, you could use the following code:

    require 'paru/pandoc'

    markdown = File.read 'path/to/markdown_file.md' 
    html = Paru::Pandoc.new do
        from 'markdown'
        to 'html5'
        standalone
        toc
        # add any pandoc option you like
    end << markdown
    puts html

The `<<` operator is an alias for the `convert` method, which converts a
string using pandoc with the options set. Options to pandoc can be set by
construction with a block. This configuration can be changed later on using
the `configure` method, again using a block to set options.

The wrapped pandoc call can be inspected through the method `to_command`,
which returns a string with the pandoc call given the current configuration.

## Stripping a pandoc file for its yaml metadata

(See also `examples/pandoc2yaml.rb`)

One of the interesting aspects of pandoc's markdown format is its allowance
for metadata in so-called yaml blocks. Using Paru and Ruby it is easy to strip a pandoc
    file for its metadata through pandoc's json output/input format:

    require 'json'
    require 'paru/pandoc'

    pandoc2json = Paru::Pandoc.new {from 'markdown'; to 'json'}
    json2pandoc = Paru::Pandoc.new {from 'json'; to 'markdown'; standalone}

    pandoc = ARGV.first
    metadata = JSON.parse(pandoc2json << File.read(pandoc)).first
    yaml = ""
    if metadata.has_key? "unMeta" and not metadata["unMeta"].empty? then
        yaml = json2pandoc << JSON.generate([metadata, []])
    end
    puts yaml

Observe that the `json2pandoc` converter has the `standalone` option. Without
it, pandoc does not convert the metadata back to its own markdown format.

## Specify pandoc options in a markdown file itself

(See also `examples/do-pandoc.rb`)

Using the ideas from `pandoc2yaml.rb`, we can easily write a script that runs
pandoc on a markdown file using the pandoc options specified in that same file
in a yaml metadata block:

    #!/usr/bin/env ruby
    require 'json'
    require 'yaml'
    require 'paru/pandoc'


    if ARGV.size != 1 then
        warn "Expecting exactly one argument: the pandoc file to convert"
        exit
    end

    input = ARGV.first

    pandoc2json = Paru::Pandoc.new {from 'markdown'; to 'json'}
    json2pandoc = Paru::Pandoc.new {from 'json'; to 'markdown'; standalone}
    json_metadata = JSON.parse(pandoc2json << File.read(input)).first
    yaml_metadata = YAML.load(json2pandoc << JSON.generate([json_metadata, []]))

    if yaml_metadata.has_key? 'pandoc' then
        begin
            pandoc = Paru::Pandoc.new
            to_stdout = true
            yaml_metadata['pandoc'].each do |option, value|
                pandoc.send option, value
                to_stdout = false if option == 'output'
            end
            output = pandoc << File.read(input)
            puts output if to_stdout
        rescue Exception => e
            warn "Something went wrong while using pandoc:\n\n#{e.message}"
        end
    else
        warn "Unsure what to do: no pandoc options in #{input}"
    end

You now can convert a markdown file, say `my_document.md` by running 

    do-pandoc.rb my_document.md

assuming that `my_document.md` contains a yaml metadata block like:

    ---
    pandoc:
      from: markdown
      to: html5
      toc: true
      standalone: true
      bibliography: 'path/to/bibliography.bib'
    ...

    # My Document

    In my document, I show all the things ...

# Todo

In the future, I plan on extending Paru with a capability to write pandoc filters in Ruby.
