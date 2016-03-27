---
title: Using paru
author: Huub de Beer
date: March 27th, 2016
keywords:
- paru
- pandoc
- ruby
...

Using paru is straightforward. It is a thin "rubyesque" layer around the
pandoc executable. After requiring paru in your ruby program, you create a new paru pandoc converter as follows:

~~~ {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new
~~~

The various [command-line options of
pandoc](http://pandoc.org/README.html#options) map to methods on this newly
created instance. For example, to convert from markdown to pdf using the
lualatex engine, you call the `from`, `to`, and `latex_engine` to configure
the converter. There is a convenience `configure` method that takes a block to
configure multiple options at once:

~~~ {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new
converter.configure do
    from "markdown"
    to "latex"
    latex_engine "lualatex"
    output "my_first_pdf_file.pdf"
end
~~~

As creating and immediately configuring a converter is a common pattern, the
constructor takes a configuration block as well. Finally, when you have
configured the converter, you can use it to convert a string. To complete this
first example, the string "Hello world, from **pandoc**" is converted as
follows:

~~~ {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new do
    from "markdown"
    to "latex"
    latex_engine "lualatex"
    output "my_first_pdf_file.pdf"
end << "Hello world, from **pandoc**"
~~~

The `<<` operator is an alias for the `convert` method. You can call `convert`
multiple times and re-configure the converter in between. 

In the next section, the development of *do-pandoc.rb* is presented as an
example of real-world usage of paru. 

# Developing do-pandoc.rb

Once I started using pandoc for all my papers, articles, and other writings, I
found that using the command line interface was a bit cumbersome because of
the many options I used. Of course I used the shell's history so I did not
have to retype the pandoc invocations each time I used them, but as write
multiple documents at the same time and often on different computers, this
felt as a stop-gap solution at best. Would it not be great if I could specify
all the command-line options to pandoc in the markdown files themselves? To
that end, I developed do-pandoc.rb.

I developed do-pandoc.rb in two steps: 

1. first I wrote a ruby script to mine the pandoc markdown files for its
   [YAML](http://yaml.org/)
   metadata.
2. using that script, I wrote another to first get the metadata about pandoc's
   command-line options to use from an input file, fed them into a dynamically
   generated pandoc converter, and used this converter on that input file.

## Stripping a pandoc file for its YAML metadata

One of the interesting aspects of pandoc's markdown format is its allowance
for metadata in so-called [YAML](http://yaml.org/) blocks. Using paru and Ruby it is easy to strip a pandoc file for its metadata through pandoc's [JSON](http://json.org/) output/input format:

~~~ {.ruby}
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
~~~

Note that the `json2pandoc` converter has the `standalone` option. Without
using it, pandoc does not convert the metadata back to its own markdown
format.

## Specify pandoc options in a markdown file itself

Using the ideas from `pandoc2yaml.rb`, it is easy to write a script that runs
pandoc on a markdown file using the pandoc options specified in that same file
in a [YAML](http://yaml.org) metadata block:

~~~ {.ruby}
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
~~~

You now can convert a markdown file, say `my_document.md` that contains a
metadata block like:

~~~ {.yaml}
---
pandoc:
    from: markdown
    to: html5
    toc: true
    standalone: true
    bibliography: 'path/to/bibliography.bib'
...
~~~

to html by running the following command:

~~~ {.bash}
do-pandoc.rb my_document.md
~~~
