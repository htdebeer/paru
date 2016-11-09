---
author: Huub de Beer
keywords:
- pandoc
- ruby
- paru
pandoc:
  filter:
  - '../examples/filters/insert\_document.rb'
  - '../examples/filters/capitalize\_first\_sentence.rb'
  from: markdown
  output: '../index.md'
  standalone: True
  to: markdown
title: 'Paru—Pandoc wrapped around in Ruby'
---

Paru 2.0 is incompatible with pandoc versions lower than 1.18.0. For
users of older versions of pandoc, please use paru 1.0. You find paru
1.0 among the releases.

Paru is free sofware. Paru is released under the GPL-3.0. You find
paru's source code here.

Introduction
============

PARU IS A SIMPLE RUBy wrapper around [pandoc](http://www.pandoc.org),
the great multi-format document converter. Paru supports automating
pandoc by writing ruby programs and [using pandoc in your ruby
programs](using_paru.html). Since version 0.1 it also supports [pandoc
filters](using_filters.html).

-   current version 0.2.0 (beta)
-   licence: GPL3

Get the code at <https://github.com/htdebeer/paru>.

Do note that Paru version 0.2.0 is incompatible with pandoc version &lt;
[1.18](http://pandoc.org/releases.html#pandoc-1.18-26-oct-2016). Use
Paru version 0.1.0 if you are using an older version of pandoc.

Installation
============

PARU IS INSTALLED THrough rubygems as follows:

``` {.bash}
gem install paru
```

You can also download the latest gem
[paru-0.2.0.gem](https://github.com/htdebeer/paru/blob/master/releases/paru-0.2.0.gem)
and install it by:

``` {.bash}
cd /directory/you/downloaded/the/gem
gem install paru-0.2.0.gem
```

Paru, obviously, requires pandoc. See
<http://pandoc.org/installing.html> about how to install pandoc on your
system and [pandoc's manual](http://pandoc.org/README.html) on how to
use pandoc.

Installation {#installation}
============

Usage
=====

Say hello to pandoc
-------------------

Automating the use of pandoc with paru
======================================

Using paru
==========

USING PARU IS STRAIGhtforward. It is a thin "rubyesque" layer around the
pandoc executable. After requiring paru in your ruby program, you create
a new paru pandoc converter as follows:

``` {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new
```

The various [command-line options of
pandoc](http://pandoc.org/README.html#options) map to methods on this
newly created instance. For example, to convert from markdown to pdf
using the lualatex engine, you call the `from`, `to`, and `latex_engine`
to configure the converter. There is a convenience `configure` method
that takes a block to configure multiple options at once:

``` {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new
converter.configure do
    from "markdown"
    to "latex"
    latex_engine "lualatex"
    output "my_first_pdf_file.pdf"
end
```

As creating and immediately configuring a converter is a common pattern,
the constructor takes a configuration block as well. Finally, when you
have configured the converter, you can use it to convert a string. To
complete this first example, the string "Hello world, from **pandoc**"
is converted as follows:

``` {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new do
    from "markdown"
    to "latex"
    latex_engine "lualatex"
    output "my_first_pdf_file.pdf"
end << "Hello world, from **pandoc**"
```

The `<<` operator is an alias for the `convert` method. You can call
`convert` multiple times and re-configure the converter in between.

In the next section, the development of *do-pandoc.rb* is presented as
an example of real-world usage of paru.

Developing do-pandoc.rb
=======================

ONCE I STARTED USING pandoc for all my papers, articles, and other
writings, I found that using the command line interface was a bit
cumbersome because of the many options I used. Of course I used the
shell's history so I did not have to retype the pandoc invocations each
time I used them, but as I write multiple documents at the same time and
often on different computers, this felt as a stop-gap solution at best.
Would it not be great if I could specify all the command-line options to
pandoc in the markdown files themselves? To that end, I developed
do-pandoc.rb.

I developed do-pandoc.rb in two steps:

1.  first I wrote a ruby script to mine the pandoc markdown files for
    its [YAML](http://yaml.org/) metadata.
2.  using that script, I wrote another to first get the metadata about
    pandoc's command-line options to use from an input file, fed them
    into a dynamically generated pandoc converter, and used this
    converter on that input file.

Stripping a pandoc file for its YAML metadata
---------------------------------------------

ONE OF THE INTERESTIng aspects of pandoc's markdown format is its
allowance for metadata in so-called [YAML](http://yaml.org/) blocks.
Using paru and Ruby it is easy to strip a pandoc file for its metadata
through pandoc's [JSON](http://json.org/) output/input format:

``` {.ruby}
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
```

Note that the `json2pandoc` converter has the `standalone` option.
Without using it, pandoc does not convert the metadata back to its own
markdown format.

Specify pandoc options in a markdown file itself
------------------------------------------------

USING THE IDEAS FROM `pandoc2yaml.rb`, it is easy to write a script that
runs pandoc on a markdown file using the pandoc options specified in
that same file in a [YAML](http://yaml.org) metadata block:

``` {.ruby}
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
```

You now can convert a markdown file, say `my_document.md` that contains
a metadata block like:

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

to html by running the following command:

``` {.bash}
do-pandoc.rb my_document.md
```

Writing and using pandoc filters with paru
==========================================

ONE OF PANDOC'S INTEresting capabilities are [custom
filters](http://pandoc.org/scripting.html). This is an extremely
powerful feature that allows you to automate certain tasks, such as
numbering figures, using other command-line programs to pre or post
process parts of the input, or change the structure of the input
document before having pandoc writing it out. Paru allows you to write
pandoc filters in ruby.

In the next sections several simple but useful filters are developed to
showcase the use of paru to write pandoc filters.

Examples
========

Numbering figures
-----------------

IN SOME OUTPUT FORMAts, such as pdf, html+css, or odt, figures can be
automatically numbered. In other formats, notably markdown itself,
numbering has to be done manually. However, it is very easy to create a
filter that does this numbering of figures automatically as well:

``` {.ruby}
#!/usr/bin/env ruby
require 'paru/filter'

current = 0;

Paru::Filter.run do 
    with "Image" do |image|
        current += 1
        image.inner_markdown = "Figure #{current}. #{image.inner_markdown}"
    end
end
```

This filter keeps track of the last figure's sequence number in
`counter`. Each time an image is encountered while processing the input
file, that counter is incremented and the image's caption is prefixed
with "Figure \#{counter}. ".

A filter consists of a number of selectors. You specify a selector
through the `with "Type" do |node| ... end` construct. You can use any
of [pandoc's internal
types](http://hackage.haskell.org/package/pandoc-types-1.16.1/docs/Text-Pandoc-Definition.html)
(see the table below).

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
                   Math
                   RawInline
                   Link
                   Image
                   Note
                   Span

  : Pandoc internal type you can use in a selector in a filter

Usually, however, you want to number figures relative to the chapter
they are in. How to do that is shown next.

Numbering figures and chapters
------------------------------

ONE OF THE PROBLEMS with using flat text input formats such as markdown,
latex, or html is that a document is more of a sequence of structure
elements rather than a tree. For example, in markdown there is no such
thing as a chapter block that contains its title and contents. Instead,
a chapter is implied by using a header followed by its contents.
Nevertheless, assuming a properly structured input file where each
chapter is implied by a header of level one, chapters and figures in
chapters can be numbered as follows:

``` {.ruby}
#!/usr/bin/env ruby
require 'paru/filter'

current_chapter = 0
current_figure = 0;

Paru::Filter.run do
    with "Header" do |header|
        if header.level == 1 
            current_chapter += 1
            current_figure = 0

            header.inner_markdown = 
                "Chapter #{current_chapter}. #{header.inner_markdown}"
        end
    end

    with "Header + Image" do |image|
        current_figure += 1
        image.inner_markdown = 
            "Figure #{current_chapter}.#{current_figure}" + 
            "#{image.inner_markdown}"
    end
end
```

Now two counters have to be used, one to keep track of the current
chapter and one to keep track of the current figure in that chapter. As
a result, each time a new chapter is started—thus each time a header of
level one is encountered—the current chapter counter is incremented
whereas the current figure counter is reset to zero.

Note how easy it is to change the content of a node by using the
`inner_markdown` property. This method is used twice, once in each
selector. In the second selector an operator, `+` or "follows", is used.
Operators in selectors denote a relationship between the current node
that is being processed—the right hand side type—and nodes that came
before. In this case, the selector denotes each image that follows a
header.

Paru has three different selection operators:

-   `A + B`, B follows A
-   `A - B`, B does not follow A
-   `A > B`, B is a descendant of A

Due to the flat structure of the pandoc format, the last selector is
used only sporadically.

As a more interesting example of using operators, the first sentence of
a section's first paragraph is capitalized next.

Capitalizing a first sentence
-----------------------------

AN OPTIONAL DISTANCE can be used in combination with a selector operator
by putting an integer after the operator. To select the first paragraph
of a section, you select only those paragraphs that follow at a distance
of 1 nodes from a header like so:

``` {.ruby}
#!/usr/bin/env ruby
require 'paru/filter'

END_CAPITAL = 15
Paru::Filter.run do 
    with "Header +1 Para" do |p|
        text = p.inner_markdown
        first_line = text.slice(0, END_CAPITAL).upcase
        rest = text.slice(END_CAPITAL, text.size)
        p.inner_markdown = first_line + rest
    end
end
```

Custom blocks
-------------

AS A FINAL EXAMPLE Filters are used to create a custom example block.
Given the following code in your markdown file

``` {.markdown}
<div class="example">
  
### Numbering figures

You can number figures in pandoc by using a filter as follows: ...
</div>
```

you can automatically number the examples by selecting all headers of
level 3 in all div elements that have class "example":

``` {.ruby}
#!/usr/bin/env ruby
require 'paru/filter'

example_count = 0

Paru::Filter.run do
    with "Div.example > Header" do |header|
        if header.level == 3 
            example_count += 1
            header.inner_markdown = 
                "**Example #{example_count}:** " + 
                "#{header.inner_markdown}"
        end
    end
end
```

Accessing metadata
------------------

FINALLY, YOU CAN ACCess metadata in an input file through the `metadata`
method available in a selector. This gives you the ability to create
flexible filters that have different behavior depending on the metadata
specified in the file. Furthermore, you can also set metadata. For
example, each time you encounter a Strong node, you could add it to the
keywords metadata to automatically generate a list of keywords.

Putting it all together
=======================

Frequently asked questions
==========================

THERE ARE NO FREQUENtly asked questions at the moment.
