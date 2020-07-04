---
author: Huub de Beer
keywords:
- pandoc
- ruby
- paru
- filter
- pandoc filter
title: 'Paru---Pandoc wrapped around in Ruby'
---

Chapter 1. Introduction {#introduction}
=======================

Paru is a simple Ruby wrapper around [pandoc](http://www.pandoc.org),
the great multi-format document converter. Paru supports automating
pandoc by writing Ruby programs and using pandoc in your Ruby programs
(see [Chapter 2 in the
manual](https://heerdebeer.org/Software/markdown/paru/#automating-the-use-of-pandoc-with-paru)).
Paru also supports writing pandoc filters in Ruby (see [Chapter 3 in the
manual](https://heerdebeer.org/Software/markdown/paru/#writing-and-using-pandoc-filters-with-paru)).
In [paru's manual](https://heerdebeer.org/Software/markdown/paru/) the
use of paru is explained in detail, from explaining how to install and
use paru, creating and using filters, to putting it all together in a
real-world use case: generating the manual!

See also the [paru API
documentation](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/).

1.1 Licence
-----------

Paru is [free sofware](https://www.gnu.org/philosophy/free-sw.en.html);
paru is released under the
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html). You find paru's
source code on [github](https://github.com/htdebeer/paru).

1.2 Installation
----------------

Paru is installed through rubygems as follows:

``` {.bash}
gem install paru
```

You can also download the latest gem
[paru-0.4.1.gem](https://github.com/htdebeer/paru/blob/master/releases/paru-0.4.1.gem)
and install it by:

``` {.bash}
cd /directory/you/downloaded/the/gem/to
gem install paru-0.4.1.gem
```

Paru, obviously, requires pandoc. See
<http://pandoc.org/installing.html> about how to install pandoc on your
system and [pandoc's manual](http://pandoc.org/README.html) on how to
use pandoc.

You can generate the [API documentation for
paru](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/)
by cloning the repository and running `rake yard`. It'll put it in
`documentation/api-doc`.

1.3 Acknowledgements
--------------------

I would like to thank the following users for their contributions of
patches, bug reports, fixes, and suggestions. With your help paru is
growing beyond a simple tool for personal use into a useful addition to
the pandoc ecosystem.

-   [Ian](https://github.com/iandol)
-   [Michael Kussmaul](https://github.com/kusmi)
-   [Xavier Belanche Alonso](https://github.com/xbelanch)
-   [Robert Riemann](https://github.com/rriemann)

1.4 Paru says hello to pandoc
-----------------------------

Using paru is straightforward. It is a thin "rubyesque" layer around the
pandoc executable. After requiring paru in your ruby program, you create
a new paru pandoc converter as follows:

``` {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new
```

The various [command-line options of
pandoc](http://pandoc.org/README.html#options) map to methods on this
newly created instance. When you want to use a pandoc command-line
option that contains dashes, replace all dashes with an underscore to
get the corresponding paru method. For example, the pandoc command-line
option `--pdf-engine` becomes the paru method `pdf_engine`. Knowing this
convention, you can convert from markdown to pdf using the lualatex
engine by calling the `from`, `to`, and `pdf_engine` methods to
configure the converter. There is a convenience `configure` method that
takes a block to configure multiple options at once:

``` {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new
converter.configure do
    from "markdown"
    to "latex"
    pdf_engine "lualatex"
    output "my_first_pdf_file.pdf"
end
```

As creating and immediately configuring a converter is a common pattern,
the constructor takes a configuration block as well. Finally, when you
have configured the converter, you can use it to convert a string with
the `convert` method, which is aliased by The `<<` operator. You can
call `convert` multiple times and re-configure the converter in between.

This introductory section is ended by the obligatory "hello world"
program, paru-style:

``` {.ruby}
#!/usr/bin/env ruby
require "paru/pandoc"

input = "Hello world, from **pandoc**"

output = Paru::Pandoc.new do
    from "markdown"
    to "html"
end << input

puts output
```

Running the above program results in the following output:

``` {.html}
<p>Hello world, from <strong>pandoc</strong></p>
```

To support converting files that cannot easily be represented by a
single string, such as EPUB or docx, paru also has the `convert_file`
method. It takes a path as argument, and when executed, it tells pandoc
to convert that path using the current configured pandoc configuration.

In the next chapter, the development of *do-pandoc.rb* is presented as
an example of real-world usage of paru.

Chapter 2. Automating the use of pandoc with paru {#automating-the-use-of-pandoc-with-paru}
=================================================

Once I started using pandoc for all my writing, I found that using the
command-line interface was a bit cumbersome because of the many options
I used. Of course I used the shell's history so I did not have to retype
the pandoc invocations each time I used them, but as I write multiple
documents at the same time and often on different computers, this felt
as a stop-gap solution at best. Would it not be great if I could specify
all the command-line options to pandoc in the markdown files themselves?
To that end, I developed *do-pandoc.rb*.

I developed *do-pandoc.rb* in two steps:

1.  first I wrote a ruby module to mine the pandoc markdown files for
    its [YAML](http://yaml.org/) metadata.
2.  using that module, I wrote another script that would use the former
    to get the pandoc command-line options to use from an input file,
    fed these options into a dynamically generated pandoc converter, and
    then use this converter on that same input file to generate my
    output file.

2.1 Mining a pandoc markdown file for its YAML metadata
-------------------------------------------------------

One of the interesting aspects of pandoc's markdown format is its
allowance for metadata in so-called [YAML](http://yaml.org/) blocks.
Using paru and Ruby it is easy to strip a pandoc file for its metadata
through pandoc's [JSON](http://json.org/) output/input format: the
script/module *\[pandoc2yaml.rb* (which you will also find in the
[examples](examples/) sub directory). Furthermore, it is also installed
as an executable when you install paru, so you can run it from the
command line like:

``` {.bash}
pandoc2yaml.rb my-noce-pandoc-file.md
```

The `pandoc2yaml.rb` script is quite straightforward:

``` {.ruby}
#!/usr/bin/env ruby
##
# pandoc2yaml.rb extracts the metadata from a pandoc markdown file and prints
# that metadata out again as a pandoc markdown file with nothing in it but that
# metadata
#
# Usage:
#
#  pandoc2yaml.rb input_file
#
##
require "json"
require 'optparse'
require 'paru/pandoc2yaml'

parser = OptionParser.new do |opts|
    opts.banner = "pandoc2yaml.rb mines a pandoc markdown file for its YAML metadata"
    opts.banner << "\n\nUsage: pandoc2yaml.rb some-pandoc-markdownfile.md"
    opts.separator ""
    opts.separator "Common options"

    opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
    end

    opts.on("-v", "--version", "Show version") do 
        puts "pandoc2yaml.rb is part of paru version 0.2.3"
        exit
    end
end

parser.parse! ARGV

input_document = ARGV.pop

if ARGV.size != 0 or input_document.nil? or input_document.empty? then
    warn "Expecting exactly one argument: the pandoc file to strip for metadata"
    puts ""
    puts parser
    exit
end

document = File.expand_path input_document
if not File.exist? document
    warn "Cannot find file: #{input_document}"
    exit
end

if !File.readable? document
    warn "Cannot read file: #{input_document}"
    exit
end

yaml = Paru::Pandoc2Yaml.extract_metadata(document)

yaml = "---\n..." if yaml.empty?

puts yaml
```

*pandoc2yaml.rb* is built in two parts:

1.  a library module `Pandoc2Yaml`, which we will be using later again
    in *do-pandoc.rb*,
2.  and a script that checks if there is an argument to the script and,
    if so, interprets it as a path to a file, and mines its contents for
    YAML metadata using the libray module.

The library module `Pandoc2Yaml` has one method, `extract_metadata` that
takes one argument, the path to a pandoc markdown file.

``` {.ruby}
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
require "json"
require_relative "./pandoc.rb"

module Paru
    # Utility class to extract YAML metadata form a markdown file in pandoc's
    # own markdown format.
    class Pandoc2Yaml
        # Paru converters:
        # Note. When converting metadata back to the pandoc markdown format, you have
        # to use the option "standalone", otherwise the metadata is skipped

        # Converter from pandoc's markdown to pandoc's AST JSON
        PANDOC_2_JSON = Paru::Pandoc.new {from "markdown"; to "json"}

        # Converter from pandoc's AST JSON back to pandoc. Note the
        # 'standalone' property, which is needed to output the metadata as
        # well.
        JSON_2_PANDOC = Paru::Pandoc.new {from "json"; to "markdown"; standalone}

        # When converting a pandoc document to JSON, or vice versa, the JSON object
        # has the following three properties:
        
        # Pandoc-type API version key
        VERSION = "pandoc-api-version"
        # Meta block key
        META = "meta"
        # Content's blocks key
        BLOCKS = "blocks"

        # Extract the YAML metadata from input document
        #
        # @param input_document [String] path to input document
        # @return [String] YAML metadata from input document on STDOUT
        def self.extract_metadata input_document
            json = JSON.parse(PANDOC_2_JSON << File.read(input_document))
            yaml = ""

            version, metadata = json.values_at(VERSION, META)

            if not metadata.empty? then
                metadata_document = {
                    VERSION => version, 
                    META => metadata, 
                    BLOCKS => []
                }

                yaml = JSON_2_PANDOC << JSON.generate(metadata_document)
            end

            yaml
        end
    end
end
```

This method converts the contents of that file to a JSON representation
of the document. Since pandoc version 1.18, this JSON representation
consists of three elements:

1.  the version of the [pandoc-types
    API](http://hackage.haskell.org/package/pandoc-types-1.17.0.4) used
    (`"pandoc-api-version"`),
2.  the metadata in the document (`"meta"`),
3.  and the contents of the document (`"blocks"`).

The contents of the document are discarded and the metadata is converted
back to pandoc's markdown format, which now only contains YAML metadata.
Note that the `JSON_2_PANDOC` converter uses the `standalone` option.
Without using it, pandoc does not convert the metadata back to its own
markdown format.

2.2 Specify pandoc options in a markdown file itself
----------------------------------------------------

Using the library module `Pandoc2Yaml` discussed in the previous
section, it is easy to write a script that runs pandoc on a markdown
file using the pandoc options specified in that same file in a
[YAML](http://yaml.org) metadata block:

``` {.ruby}
#!/usr/bin/env ruby
require "yaml"
require 'optparse'
require "paru/pandoc"
require "paru/pandoc2yaml"

parser = OptionParser.new do |opts|
  opts.banner = "do-pandoc.rb runs pandoc on an input file using the pandoc configuration specified in that input file."
  opts.banner << "\n\nUsage: do-pandoc.rb some-pandoc-markdownfile.md"
  opts.separator ""
  opts.separator "Common options"

  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end

  opts.on("-v", "--version", "Show version") do 
      puts "do-pandoc.rb is part of paru version 0.4.1"
    exit
  end
end

parser.parse! ARGV

input_document = ARGV.pop

if ARGV.size != 0 then
  warn "Expecting exactly one argument: the pandoc file to convert"
  puts ""
  puts parser
  exit
end

document = File.expand_path input_document
if not File.exist? document
  warn "Cannot find file: #{input_document}"
  exit
end

if !File.readable? document
  warn "Cannot read file: #{input_document}"
  exit
end

yaml = Paru::Pandoc2Yaml.extract_metadata(document)
metadata = YAML.load yaml

if metadata.has_key? "pandoc" then
  begin
    pandoc = Paru::Pandoc.new
    to_stdout = true
    metadata["pandoc"].each do |option, value|
      if value.is_a? String then
          value = value.gsub '\\', ''
      elsif value.is_a? Array then
          value = value.map {|v| v.gsub '\\', '' if v.is_a? String}
      end
      pandoc.send option, value
      to_stdout = false if option == "output"
    end
    output = pandoc << File.read(document)
    puts output if to_stdout
  rescue Exception => e
    warn "Something went wrong while using pandoc:\n\n#{e.message}"
  end
else
    warn "Unsure what to do: no pandoc options in #{input_document}"
end
```

The script `do-pandoc.rb` first checks if there is one argument. If so,
it is treated as a path to a pandoc markdown file. That file is mined
for its metadata and if that metadata contains the property *pandoc*,
the fields of that property are interpreted are used to configure a paru
pandoc converter. The key of a property is called as a method on a
\`Paru::Pandoc\`\` object with the property's value as its argument.
Thus, a pandoc markdown file that contains a metadata block like:

``` {.yaml}
---
pandoc:
    from: markdown
    to: html5
    toc: true
    standalone: true
    bibliography: 'path/to/bibliography.bib'
...
```

will configure a `Paru::Pandoc` object to convert the contents of that
pandoc markdown file from *markdown* to *standalone* *html* code with a
*table of contents* while using `path/to/bibliography.bib` as the
*bibliographic database*.

`do-pandoc.rb` is also installed as an executable script when you istall
paru. You can run it from the command line as follows:

``` {.bash}
do-pandoc.rb my-file.md
```

In [Chapter 4](#putting-it-all-together) this script `do-pandoc.rb` is
used on paru's documentation file, `documentation/documentation.md` to
generate a new pandoc markdown file, `index.md`, that is converted to
HTML into **the manual you are reading now!**

Note how `do-pandoc.rb` defaults to outputting the results of a
conversion to standard out unless the *output* option is specified in
the *pandoc* property in the metadata.

Chapter 3. Writing and using pandoc filters with paru {#writing-and-using-pandoc-filters-with-paru}
=====================================================

3.1 Introduction
----------------

One of pandoc's interesting capabilities are [custom
filters](http://pandoc.org/scripting.html). This is an extremely
powerful feature that allows you to automate certain tasks, such as
numbering figures, using other command-line programs to pre or post
process parts of the input, or change the structure of the input
document before having pandoc writing it out. Paru allows you to write
pandoc filters in Ruby.

For a collection of paru filters, have a look at the
[paru-filter-collection](https://github.com/htdebeer/paru-filter-collection).

The simplest paru pandoc filter is the *identity* filter that does do
nothing:

``` {.ruby}
#!/usr/bin/env ruby
# Identity filter
require "paru/filter"

Paru::Filter.run do
    # nothing
end
```

Nevertheless, it shows the structure of every paru pandoc filter: A
filter is an executable script (line 1), it uses the `paru/filter`
module, and it executes a `Paru::Filter` object. Running the identity
filter is a good way to start writing your own filters. In the next
sections several simple but useful filters are developed to showcase the
use of paru to write pandoc filters in Ruby.

All example filters discussed in this chapter can be found in the
[filters sub directory](examples/filters) of paru's
[examples](examples/). Feel free to copy and adapt them to your needs.

The [API
documentation](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/)
can be found on this website as well.

3.2 Filter basics
-----------------

### Numbering figures

In some output formats, such as PDF, HTML + CSS, or ODT, figures can be
automatically numbered. In other formats, notably markdown itself,
numbering has to be done manually. However, it is very easy to create a
filter that does this numbering of figures automatically as well:

``` {.ruby}
#!/usr/bin/env ruby
# Number all figures in a document and prefix the caption with "Figure".
require "paru/filter"

figure_counter = 0;

Paru::Filter.run do 
    with "Image" do |image|
        figure_counter += 1
        image.inner_markdown = "Figure #{figure_counter}. #{image.inner_markdown}"
    end
end
```

The filter `number_figures.rb` keeps track of the last figure's sequence
number in `counter`. Each time an *Image* is encountered while
processing the input file, that counter is incremented and the image's
caption is prefixed with "Figure \#{counter}." by overwriting the
image's node's inner markdown.

A filter consists of a number of selectors. You specify a selector
through the "`with "Type" do |node| ... end`" construct. You can use any
of [pandoc's internal
types](https://hackage.haskell.org/package/pandoc-types-1.17.0.4/docs/Text-Pandoc-Definition.html)
as a selector (see the table below).

  block            inline
  ---------------- -------------
  Plain            Str
  Para             Emph
  CodeBlock        Strong
  RawBlock         Strikeout
  BlockQuote       Superscript
  OrderedList      Supscript
  BulletList       SmallCaps
  DefinitionList   Quoted
  Header           Cite
  HorizontalRule   Code
  Table            Space
  Div              SoftBreak
  Null             LineBreak
  LineBlock        Math
                   RawInline
                   Link
                   Image
                   Note
                   Span

  : Pandoc internal type you can use in a selector in a filter

Usually, however, you want to number figures relative to the chapter
they are in. How to do that is shown next.

### Numbering figures and chapters

One of the problems with using flat text input formats such as markdown,
LaTeX, or HTML is that a document is more of a sequence of structure
elements rather than a tree. For example, in markdown there is no such
thing as a chapter block that contains its title and contents. Instead,
a chapter is implied by using a header followed by its contents.
Nevertheless, assuming a properly structured input file where each
chapter is implied by a header of level one and a section by a header of
level two, the filter `numbering_figures.rb` can be extended to number
chapters, sections, and figures as follows:

``` {.ruby}
#!/usr/bin/env ruby
require "paru/filter"

current_chapter = 0
current_section = 0
current_figure = 0

Paru::Filter.run do
    with "Header" do |header|
        if header.level == 1 
            current_chapter += 1
            current_figure = 0
            current_section = 0

            header.inner_markdown = "Chapter #{current_chapter}. #{header.inner_markdown}"
        end

        if header.level == 2
          current_section += 1
          header.inner_markdown = 
            "#{current_chapter}.#{current_section} #{header.inner_markdown}"
        end
    end

    with "Header + Image" do |image|
        current_figure += 1
        image.inner_markdown = 
          "Figure #{current_chapter}.#{current_figure} #{image.inner_markdown}"
    end
end
```

In the filter `number_chapters_and_sections_and_figures.rb`, three
counters have to be used. One to keep track of the current chapter, one
to keep track of the current section in that chapter, and one to keep
track of the current figure in that chapter. Each time a new chapter is
started---thus each time a *Header* of level one is encountered---the
current chapter counter is incremented whereas the current section and
current figure counters are reset to zero. When a section---rather a
*Header* of level 2---and an *Image* are encountered, their respective
counters are incremented as well.

Note how easy it is to change the content of a node by using the
`inner_markdown` property. This method is used thrice, once in each
selector.

In the second selector the `+` or "follows" operator is used. Operators
in selectors denote a relationship between the current node that is
being processed---the right hand side type---and nodes that came before.
In this case, the selector denotes each *Image* that follows a *Header*.

You can use three different selection operators in paru:

-   `A + B`, B follows A
-   `A - B`, B does not follow A
-   `A > B`, B is a descendant of A

Due to the flat structure of the pandoc format, the last selector is
used only sporadically.

As a more interesting example of using operators, the first sentence of
a section's first paragraph is capitalized next.

### Capitalizing a first sentence

An optional distance can be used in combination with a selector operator
by putting an integer after the operator. To select the first paragraph
of a section, you select only those paragraphs that follow at a distance
of 1 nodes from a header like so:

``` {.ruby}
#!/usr/bin/env ruby
# Capitalize the first N characters of a paragraph
require "paru/filter"

END_CAPITAL = 10
Paru::Filter.run do 
    with "Header +1 Para" do |p|
        text = p.inner_markdown
        first_line = text.slice(0, END_CAPITAL).upcase
        rest = text.slice(END_CAPITAL, text.size)
        p.inner_markdown = first_line + rest
    end
end

```

Of course, just taking the first N letters to capitalize does not work
that well because often the capitalization stops halfway a word. Is it
not hard to improve this `capitalize_first_sentence.rb` filter to
capitalize the first M words, for example.

### Custom blocks

You can use filters to create a custom example block. Given the
following code in your markdown file:

``` {.markdown}
<div class="example">
  
### Numbering figures

You can number figures in pandoc by using a filter as follows: ...
</div>
```

you can automatically number the example blocks by selecting all
*Header*s of level 3 in all *Div* elements that have class "*example*":

``` {.ruby}
#!/usr/bin/env ruby
# Annotate custom blocks: example blocks and important blocks
require "paru/filter"

example_count = 0

Paru::Filter.run do
    with "Div.example > Header" do |header|
        if header.level == 3 
            example_count += 1
            header.inner_markdown = "Example #{example_count}: #{header.inner_markdown}"
        end
    end

    with "Div.important" do |d|
        d.inner_markdown = d.inner_markdown + "\n\n*(important)*"
    end

end
```

Here the descendant selection operator comes in handy to denote the
hierarchical relationship between a block and its contents.

3.3 Going beyond the confines of a filter file
----------------------------------------------

Although filters in and of themselves are already quite useful, the fact
that paru filters have the full power of ruby at their disposal makes
for some truly powerful behavior.

### Inserting other pandoc files

A frequently asked for filter on the pandoc channel on IRC (\#pandoc on
freenode.net, come join us!) is a way to include external files in a
markdown file. An command that is a bit like LaTeX's input command can
be created with a paru filter quite easily:

``` {.ruby}
#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
  with "Para" do |paragraph|
    if paragraph.inner_markdown.lines.length == 1
      command, path = paragraph.inner_markdown.strip.split " "
      if command == "::paru::insert"
        markdown = File.read path.gsub(/\\_/, "_")
        paragraph.markdown = markdown
      end
    end
  end
end

```

The filter `insert_document.rb` inspects each *Para*graph. If it is
exactly one line long, that line is split on a space (\" \"). If the
left-most split off is equal to `::paru::insert`, the one-line paragraph
is interpreted as an insert command with one parameter: the path to the
file to insert. This one-line paragraph's contents are *replaced* by the
contents of that file using the `outer_markdown` method.

Note that, because I like to use file names with an underscore in it and
pandoc puts an backslash (\\) in front of underscores, I had to replace
all occurrences of "\\\_" by "\_" to get Ruby to find and read the file
correctly.

### Inserting code files

Similarly, when writing a programming tutorial or manual (like this
manual; have a look at `documentation/using_filters.md` for example), it
would be great if you can point pandoc to a file containing some
programming code and have that code included automatically. This is even
more simple that inserting markdown files!:

``` {.ruby}
#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
  with "CodeBlock" do |code_block|
    command, path, *classes = code_block.string.strip.split " "
    if command == "::paru::insert"
      code_block.string = File.read path.gsub(/\\_/, "_")
      code_block.string.force_encoding('UTF-8')
      classes.each {|c| code_block.attr.classes.push c}
    end
  end
end
```

The *CodeBlock* element has a string property that can be inspected and
replaced. As with the previous filter to include other markdown files,
if the *CodeBlock* contains the "command" `::paru::insert` followed by a
path and optionally more parameters, the code block is treated as an
insert command. The file is read and its contents are used in stead of
the command.

3.4 Manipulating pandoc's metadata
----------------------------------

Finally, you can access metadata in an input file through the `metadata`
method available in a selector. This gives you the ability to create
flexible filters that have different behavior depending on the metadata
specified in the file. Furthermore, you can also set metadata. For
example, each time you encounter a *Strong* node, you could add it to
the keywords metadata to automatically generate a list of keywords.

As an example, I have created a filter that removes a pandoc
configuration from the metadata if there is such a property:

``` {.ruby}
#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
    metadata.delete "pandoc"
end
```

Instead of removing the pandoc property all together, I could also have
updated it to have a markdown file be converted differently the second
time it is run by `do-pandoc.rb`.

For more information about manipulating metadata, see [the API
documentation of the
MetaMap](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/Paru/PandocFilter/MetaMap.html).

Chapter 4. Putting it all together {#putting-it-all-together}
==================================

Having discussed using paru and creating and using filters in the
previous two chapters, it is now time to put it all together and into
practice. As an example, the generation of this manual is used. In the
directory [documentation](documentation/) you find a number of files
that comprise this manual. The root file is
`documentation/documentation.md`, which contains some metadata, the
outline of the manual, and a number of `::paru::insert` commands to
include the other markdown files from the documentation directory:

``` {.markdown}
﻿---
title: Paru—Pandoc wrapped around in Ruby
author: Huub de Beer
keywords:
- pandoc
- ruby
- paru
- filter
- pandoc filter
pandoc:
  from: markdown
  to: markdown
  output: ../index.md
  standalone: true
  filter:
  - ../examples/filters/insert_document.rb
  - ../examples/filters/number_chapters_and_sections_and_figures.rb
  - ../examples/filters/insert_code_block.rb
  - ../examples/filters/remove_pandoc_metadata.rb
  - ../examples/filters/insert_paru_version.rb
...

# Introduction

::paru::insert introduction.md

## Licence

::paru::insert license.md

## Installation

::paru::insert install.md

## Acknowledgements

::paru::insert acknowledgements.md

## Paru says hello to pandoc

::paru::insert usage.md

# Automating the use of pandoc with paru

::paru::insert using_paru.md

# Writing and using pandoc filters with paru

::paru::insert using_filters.md

# Putting it all together

::paru::insert putting_it_all_together.md

# Frequently asked questions

::paru::insert faq.md

```

To generate the manual markdown file `index.md`, run the `do-pandoc.rb`
script on `document.md`:

``` {.bash}
do-pandoc.rb documentation.md
```

Using some simple filters and a small Ruby script, paru enables you to
automate using pandoc and perform simple and complex transformations on
your input files to generate quite complex documents.

Chapter 5. Frequently asked questions {#frequently-asked-questions}
=====================================

Feel free to ask me a question: [send me an
email](mailto:Huub@heerdebeer.org) or submit a new
[issue](https://github.com/htdebeer/paru/issues) if you've found a bug!

-   *I get an error like "'values_at': no implicit conversion of String
    into Integer (TypeError) from lib/paru/filter/document.rb:54:in
    'from_JSON'"*

    The most likely cause is that you're using an old version of Pandoc.
    Paru version 0.2.x only supports pandoc version 1.18 and up. In
    pandoc version 1.18 there was a breaking API change in the way
    filters worked. Please upgrade your pandoc installation.
