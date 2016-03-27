---
title: Paru—PAndoc wrapped around RUby
author: Huub de Beer
licence: GPL3
...

Paru is a simple ruby wrapper around [pandoc](http://www.pandoc.org), the great
multi-format document converter.

- version 0.1.0 (beta)
- licence: GPL3

Get the code at <https://github.com/htdebeer/paru>.

# Installation

~~~ {.bash}
    gem install paru
~~~

# Requirements

Pandoc. See i<http://pandoc.org/installing.html> about how to install pandoc on
your system.

# Usage

## Converting markdown to html

Using Paru is straightforward. For example, to convert a markdown file to
html and send it to stdout, you could use the following code:

~~~ {.ruby}
    require 'paru/pandoc'

    markdown = File.read 'path/to/markdown_file.md' 
    html = Paru::Pandoc.new do
        from 'markdown'
        to 'html'
        standalone
        toc
        # add any pandoc option you like
    end << markdown
    puts html
~~~

The `<<` operator is an alias for the `convert` method, which converts a
string using pandoc with the given options. Options to pandoc can be set using
a block as shown in the example above. This configuration can be changed later on using
the `configure` method. This method also expects a block to set options.

The wrapped pandoc call can be inspected through the method `to_command`,
which returns a string with the pandoc call given the current configuration.

## Stripping a pandoc file for its yaml metadata

One of the interesting aspects of pandoc's markdown format is its allowance
for metadata in so-called yaml blocks. Using Paru and Ruby it is easy to strip
    a pandoc file for its metadata through pandoc's json output/input format:

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

Observe that the `json2pandoc` converter has the `standalone` option. Without
it, pandoc does not convert the metadata back to its own markdown format.

## Specify pandoc options in a markdown file itself

Using the ideas from `pandoc2yaml.rb`, we can easily write a script that runs
pandoc on a markdown file using the pandoc options specified in that same file
in a yaml metadata block:

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

You now can convert a markdown file, say `my_document.md` by running 

~~~ {.bash}
    do-pandoc.rb my_document.md
~~~

assuming that `my_document.md` contains a yaml metadata block like:

~~~ {.markdown}
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
~~~

# Filters

Paru also supports pandoc filters. A filter is a (simple) program that takes
as input the AST produced by pandoc, manipulates it, and give the manipulated
output back to pandoc, which then converts it to the requested format.

## Numbering figures

Some output formats can number the figures in a document, others cannot. Using
a filter, you can tell pandoc to number the figures anyway. For example:

~~~ {.ruby}
    #!/usr/bin/env ruby
    require 'paru/filter'

    current = 0;

    Paru::Filter.run do 
        with "Image" do |image|
            current += 1
            image.inner_markdown = "Figure #{current}. #{image.inner_markdown}"
        end
    end
~~~

The filter starts by setting the internal figure counter to 0 and then, each
time it encounters an "Image" element, it increments that counter and prefixes
the figure's caption with "Figure x. ". 

A filter is specified with `with "Type" do |node| ... end`, with `"Type"` one
of pandoc's internal block or inline types (see the
[haskell](http://hackage.haskell.org/package/pandoc-types-1.16.1/docs/Text-Pandoc-Definition.html)
documentation for more information):

-   **block types**

    -   Plain
    -   Para
    -   CodeBlock
    -   RawBlock
    -   BlockQuote 
    -   OrderedList 
    -   BulletList
    -   DefinitionList
    -   Header
    -   HorizontalRule  
    -   Table
    -   Div
    -   Null

-   **inline types**

    -   Str
    -   Emph
    -   Strong
    -   Strikeout
    -   Superscript
    -   Supscript
    -   SmallCaps
    -   Quoted
    -   Cite
    -   Code
    -   Space
    -   SoftBreak
    -   LineBreak
    -   Math
    -   RawInline
    -   Link
    -   Image
    -   Note
    -   Span

## Numbering figures, start over each chapter

As a slightly more involved example, figures are numbered per chapter as
follows:

~~~ {.ruby}
    #!/usr/bin/env ruby
    require 'paru/filter'

    current_chapter = 0
    current_figure = 0;

    Paru::Filter.run do
        with "Header" do |header|
            if header.level == 1 
                current_chapter += 1
                current_figure = 0

                header.inner_markdown = "Chapter #{current_chapter}. #{header.inner_markdown}"
            end
        end

        with "Header + Image" do |image|
            current_figure += 1
            image.inner_markdown = "Figure #{current_chapter}.#{current_figure} #{image.inner_markdown}"
        end
    end
~~~

Now two counters are used, one for the chapters and one for the figures. Each
time a chapter is encountered the figure counter is reset. A chapter is, in
this particular case, defined as a header of level 1. Note how easy it is to
change the content of a node by using the `inner_markdown` property.

In the second selector, the `+`, or "follows" operator is used. The selector
`Header + Image` denotes each image that follows a header. Paru has three
different selection operators: 

-   `A + B`, B follows A
-   `A - B`, B does not follow A
-   `A > B`, B is a descendant node of A

## Capitalizing a first sentence

Furthermore, an optional distance can be specified by putting an integer
number after the operator. For example, using the distance, you can capitalize
the first couple of characters of each paragraph following a header:

~~~ {.ruby}
    #!/usr/bin/env ruby
    require 'paru/filter'

    END_CAPITAL = 10
    Paru::Filter.run do 
        with "Header +4 Para" do |p|
            text = p.inner_markdown
            first_line = text.slice(0, END_CAPITAL).upcase
            rest = text.slice(END_CAPITAL, text.size)
            p.inner_markdown = first_line + rest
        end
    end
~~~ 

Note that the distance is 4 rather than 1 because the way pandoc processes
markdown files. In this instance, the header's text and the line break are
also counted. 

## Custom blocks

Finally, filters can be used to create custom blocks, such as example blocks.
Given the following markdown file:

~~~ {.markdown}
    <div class="example">
      
    ### Numbering figures

    explaining how to number figures using pandoc filters...

    </div>
~~~

and the following filter:

~~~ {.ruby}
    #!/usr/bin/env ruby
    require 'paru/filter'

    example_count = 0

    Paru::Filter.run do
        with "Div.example > Header" do |header|
            if header.level == 3 
                example_count += 1
                header.inner_markdown = "Example #{example_count}: #{header.inner_markdown}"
            end
        end
    end
~~~

All headers of level 3 in custom example blocks are prefixed with "Example"
and the sequence number of the example.

## Accessing metadata

To access the metadata, both setting and getting values, use the `metadata`
method. This gives you access to the metadata as a hash (key, value store).

## On the power of filters

Filters are quite powerful as you can access your whole computer, including
programs on it, as well as the whole internet (if you're connected). You could
write a filter that automatically converts images written in
[tikz](http://www.texample.net/tikz/) to svg an
png depending on the output format. Or a filter that checks each external link
if the link is dead or not. Or generating a pandoc table from a csv file. And
    so on.


*Automate away!*
