---
author: Huub de Beer
keywords:
- pandoc
- ruby
- paru
- filter
- pandoc filter
title: 'Paru—Pandoc wrapped around in Ruby'
---

Do note that Paru version 0.2.0 is incompatible with pandoc version &lt;
[1.18](http://pandoc.org/releases.html#pandoc-1.18-26-oct-2016). Use
Paru version 0.1.0 if you are using an older version of pandoc.

Chapter 1. Introduction {#introduction}
=======================

Paru is a simple Ruby wrapper around [pandoc](http://www.pandoc.org),
the great multi-format document converter. Paru supports automating
pandoc by writing Ruby programs and using pandoc in your Ruby programs
(see [Chapter 2](#automating-the-use-of-pandoc-with-paru)). Paru also
supports writing pandoc filters in Ruby (see [Chapter
3](#writing-and-using-pandoc-filters-with-paru)). In this manual the use
of paru is explained in detail, from explaining how to install and use
paru, creating and using filters, to putting it all together in a
real-world use case: generating this manual!

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
[paru-0.2.0.gem](https://github.com/htdebeer/paru/blob/master/releases/paru-0.2.0.gem)
and install it by:

``` {.bash}
cd /directory/you/downloaded/the/gem/to
gem install paru-0.2.0.gem
```

Paru, obviously, requires pandoc. See
<http://pandoc.org/installing.html> about how to install pandoc on your
system and [pandoc's manual](http://pandoc.org/README.html) on how to
use pandoc.

1.3 Paru says hello to pandoc
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
option `--latex-engine` becomes the paru method `latex_engine`. Knowing
this convention, you can convert from markdown to pdf using the lualatex
engine by calling the `from`, `to`, and `latex_engine` methods to
configure the converter. There is a convenience `configure` method that
takes a block to configure multiple options at once:

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
have configured the converter, you can use it to convert a string with
the `convert` method, which is aliased by The `<<` operator. You can
call `convert` multiple times and re-configure the converter in between.

This introductory section is ended by the obligatory "hello world"
program, paru-style:

``` {.ruby}
#!/usr/bin/env ruby
require "paru/pandoc"

html = Paru::Pandoc.new do
    from "markdown"
    to "html"
end << "Hello world, from **pandoc**"
puts html
```

Running the above program results in the following output:

``` {.html}
<p>Hello world, from <strong>pandoc</strong></p>
```

In the next chapter, the development of *do-pandoc.rb* is presented as
an example of real-world usage of paru.

Chapter 2. Automating the use of pandoc with paru {#automating-the-use-of-pandoc-with-paru}
=================================================

Once I started using pandoc for all my papers, articles, and other
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

2.1 Stripping a pandoc file for its YAML metadata
-------------------------------------------------

One of the interesting aspects of pandoc's markdown format is its
allowance for metadata in so-called [YAML](http://yaml.org/) blocks.
Using paru and Ruby it is easy to strip a pandoc file for its metadata
through pandoc's [JSON](http://json.org/) output/input format:

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
module Pandoc2Yaml
  require "json"
  require "paru/pandoc"

  # Paru converters:
  # Note. When converting metadata back to the pandoc markdown format, you have
  # to use the option "standalone", otherwise the metadata is skipped
  PANDOC_2_JSON = Paru::Pandoc.new {from "markdown"; to "json"}
  JSON_2_PANDOC = Paru::Pandoc.new {from "json"; to "markdown"; standalone}

  # When converting a pandoc document to JSON, or vice versa, the JSON object
  # has the following three properties:
  VERSION = "pandoc-api-version"
  META = "meta"
  BLOCKS = "blocks"

  def extract_metadata input_document
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

if __FILE__ == $0
  include Pandoc2Yaml

  if ARGV.size != 1 then
    warn "Expecting exactly one argument: the pandoc file to strip for metadata"
    exit
  end

  input_document = ARGV.first
  output_metadata = Pandoc2Yaml.extract_metadata input_document
  puts output_metadata
end
```

Note that the `json2pandoc` converter has the `standalone` option.
Without using it, pandoc does not convert the metadata back to its own
markdown format.

2.2 Specify pandoc options in a markdown file itself
----------------------------------------------------

Using the ideas from `pandoc2yaml.rb`, it is easy to write a script that
runs pandoc on a markdown file using the pandoc options specified in
that same file in a [YAML](http://yaml.org) metadata block:

``` {.ruby}
#!/usr/bin/env ruby
require "yaml"
require "paru/pandoc"
require_relative "./pandoc2yaml.rb"

include Pandoc2Yaml

if ARGV.size != 1 then
    warn "Expecting exactly one argument: the pandoc file to convert"
    exit
end

input = ARGV.first
metadata = YAML.load Pandoc2Yaml.extract_metadata(input)

if metadata.has_key? "pandoc" then
    begin
        pandoc = Paru::Pandoc.new
        to_stdout = true
        metadata["pandoc"].each do |option, value|
            pandoc.send option, value
            to_stdout = false if option == "output"
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

Chapter 3. Writing and using pandoc filters with paru {#writing-and-using-pandoc-filters-with-paru}
=====================================================

One of pandoc's interesting capabilities are [custom
filters](http://pandoc.org/scripting.html). This is an extremely
powerful feature that allows you to automate certain tasks, such as
numbering figures, using other command-line programs to pre or post
process parts of the input, or change the structure of the input
document before having pandoc writing it out. Paru allows you to write
pandoc filters in ruby.

In the next sections several simple but useful filters are developed to
showcase the use of paru to write pandoc filters.

3.1 Numbering figures
---------------------

In some output formats, such as pdf, html+css, or odt, figures can be
automatically numbered. In other formats, notably markdown itself,
numbering has to be done manually. However, it is very easy to create a
filter that does this numbering of figures automatically as well:

``` {.ruby}
#!/usr/bin/env ruby
require "paru/filter"

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
types](https://hackage.haskell.org/package/pandoc-types-1.17.0.4/docs/Text-Pandoc-Definition.html)
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
  LineBlock        Math
                   RawInline
                   Link
                   Image
                   Note
                   Span

  : Pandoc internal type you can use in a selector in a filter

Usually, however, you want to number figures relative to the chapter
they are in. How to do that is shown next.

3.2 Numbering figures and chapters
----------------------------------

One of the problems with using flat text input formats such as markdown,
latex, or html is that a document is more of a sequence of structure
elements rather than a tree. For example, in markdown there is no such
thing as a chapter block that contains its title and contents. Instead,
a chapter is implied by using a header followed by its contents.
Nevertheless, assuming a properly structured input file where each
chapter is implied by a header of level one, chapters and figures in
chapters can be numbered as follows:

``` {.ruby}
#!/usr/bin/env ruby
require "paru/filter"

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

3.3 Capitalizing a first sentence
---------------------------------

An optional distance can be used in combination with a selector operator
by putting an integer after the operator. To select the first paragraph
of a section, you select only those paragraphs that follow at a distance
of 1 nodes from a header like so:

``` {.ruby}
#!/usr/bin/env ruby
require "paru/filter"

END_CAPITAL = 20
Paru::Filter.run do 
    with "Header +1 Para" do |p|
        text = p.inner_markdown
        first_line = text.slice(0, END_CAPITAL).upcase
        rest = text.slice(END_CAPITAL, text.size)
        p.inner_markdown = first_line + rest
    end
end

```

3.4 Custom blocks
-----------------

As another example filters are used to create a custom example block.
Given the following code in your markdown file:

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

3.5 Inserting other pandoc files
--------------------------------

A frequently asked for filter is a way to insert markdown files into
another markdown file. A bit like LaTeX's input command. Using paru that
is quite easy to accomplish:

``` {.ruby}
#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
  with "Para" do |paragraph|
    if paragraph.inner_markdown.lines.length == 1
      command, path = paragraph.inner_markdown.strip.split " "
      if command == "::paru::insert"
        markdown = File.read path.gsub(/\\_/, "_")
        paragraph.outer_markdown = markdown
      end
    end
  end
end

```

Similarly, when writing a programming tutorial or manual (like this
document), it is great if you can point markdown to a code sample and it
is included automatically. This is even more simple that inserting
markdown files!:

``` {.ruby}
#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
  with "CodeBlock" do |code_block|
    command, path, *classes = code_block.string.strip.split " "
    if command == "::paru::insert"
      code_block.string = File.read path.gsub(/\\_/, "_")
      classes.each {|c| code_block.attr.classes.push c}
    end
  end
end
```

3.6 Accessing metadata
----------------------

Finally, you can access metadata in an input file through the `metadata`
method available in a selector. This gives you the ability to create
flexible filters that have different behavior depending on the metadata
specified in the file. Furthermore, you can also set metadata. For
example, each time you encounter a Strong node, you could add it to the
keywords metadata to automatically generate a list of keywords.

As an example, I have created a filter that removes a pandoc
configuration from the metadata if any. I use this in combination with
`do-pandoc.rb` to generate a file only once.

    #!/usr/bin/env ruby
    require "paru/filter"

    Paru::Filter.run do 
      metadata.delete "pandoc" if metadata.has_key? "pandoc"
    end

Chapter 4. Putting it all together {#putting-it-all-together}
==================================

This document is created using the programs and filters described in the
previous chapters. This document is created by running

``` {.bash}
do-pandoc.rb documentation.md
```

where `documentation.md` is:

``` {.markdown}
---
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
...

::paru::insert preface.md

# Introduction

::paru::insert introduction.md

## Licence

::paru::insert licence.md

## Installation

::paru::insert install.md

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

Chapter 5. Frequently asked questions {#frequently-asked-questions}
=====================================

There are no frequently asked questions at the moment. Feel free to ask
me a question: [send me an email](mailto:Huub@heerdebeer.org)!
