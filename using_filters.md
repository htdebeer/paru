---
title: Writing pandoc filters in ruby with paru
author: Huub de Beer
date: March 27th, 2016
keywords:
- pandoc
- paru
- filter
- ruby
...

One of pandoc's interesting capabilities are [custom
filters](http://pandoc.org/scripting.html). This is an extremely powerful
feature that allows you to automate certain tasks, such as numbering figures,
using other command-line programs to pre or post process parts of the input,
or change the structure of the input document before having pandoc writing it
out. Paru allows you to write pandoc filters in ruby. 

In the next sections several simple but useful filters are developed to
showcase the use of paru to write pandoc filters.

# Examples

## Numbering figures

In some output formats, such as pdf, html+css, or odt, figures can be
automatically numbered. In other formats, notably markdown itself, numbering
has to be done manually. However, it is very easy to create a filter that does
this numbering of figures automatically as well:

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

This filter keeps track of the last figure's sequence number in `counter`.
Each time an image is encountered while processing the input file, that
counter is incremented and the image's caption is prefixed with "Figure
#{counter}. ".

A filter consists of a number of selectors. You specify a selector through the
`with "Type" do |node| ... end` construct. You can use any of [pandoc's
internal
types](http://hackage.haskell.org/package/pandoc-types-1.16.1/docs/Text-Pandoc-Definition.html)
(see the table below).

block                   inline
--------------------    -------------------------
Plain                   Str          
Para                    Emph
CodeBlock               Strong
RawBlock                Strikeout
BlockQuote              Superscript
OrderedList             Supscript
BulletList              SmallCaps
DefinitionList          Quoted
Header                  Cite
HorizontalRule          Code
Table                   Space
Div                     SoftBreak
Null                    LineBreak
                        Math
                        RawInline
                        Link
                        Image
                        Note
                        Span        

Table: Pandoc internal type you can use in a selector in a filter

Usually, however, you want to number figures relative to the chapter they are
in. How to do that is shown next.

## Numbering figures and chapters

One of the problems with using flat text input formats such as markdown,
latex, or html is that a document is more of a sequence of structure elements
rather than a tree. For example, in markdown there is no such thing as a
chapter block that contains its title and contents. Instead, a chapter is
implied by using a header followed by its contents. Nevertheless, assuming a
properly structured input file where each chapter is implied by a header of
level one, chapters and figures in chapters can be numbered as follows:

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

            header.inner_markdown = 
                "Chapter #{current_chapter}. #{header.inner_markdown}"
        end
    end

    with "Header + Image" do |image|
        current_figure += 1
        image.inner_markdown = 
            "Figure #{current_chapter}.#{current_figure}" + 
            #{image.inner_markdown}"
    end
end
~~~

Now two counters have to be used, one to keep track of the current chapter and
one to keep track of the current figure in that chapter. As a result, each
time a new chapter is started—thus each time a header of level one is
encountered—the current chapter counter is incremented whereas the current
figure counter is reset to zero.

Note how easy it is to change the content of a node by using the
`inner_markdown` property. This method is used twice, once in each selector.
In the second selector an operator, `+` or "follows",  is used. Operators in
selectors denote a relationship between the current node that is being
processed—the right hand side type—and nodes that came before.  In this case,
the selector denotes each image that follows a header. 

Paru has three different selection operators: 

-   `A + B`, B follows A
-   `A - B`, B does not follow A
-   `A > B`, B is a descendant of A

Due to the flat structure of the pandoc format, the last selector is used only
sporadically. 

As a more interesting example of using operators, the first sentence of a
section's first paragraph is capitalized next.

## Capitalizing a first sentence

An optional distance can be used in combination with a selector operator by
putting an integer after the operator. To select the first paragraph of a
section, you select only those paragraphs that follow at a distance of 1 nodes
from a header like so:

~~~ {.ruby}
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
~~~ 

## Custom blocks

As a final example filters are used to create a custom example block. Given
the following code in your markdown file

~~~ {.markdown}
<div class="example">
  
### Numbering figures

You can number figures in pandoc by using a filter as follows: ...
</div>
~~~

you can automatically number the examples by selecting all headers of level 3
in all div elements that have class "example":

~~~ {.ruby}
#!/usr/bin/env ruby
require 'paru/filter'

example_count = 0

Paru::Filter.run do
    with "Div.example > Header" do |header|
        if header.level == 3 
            example_count += 1
            header.inner_markdown = 
                "**Example #{example_count}:** " + 
                #{header.inner_markdown}"
        end
    end
end
~~~

## Accessing metadata

Finally, you can access metadata in an input file through the `metadata`
method available in a selector. This gives you the ability to create flexible
filters that have different behavior depending on the metadata specified in
the file. Furthermore, you can also set metadata. For example, each time you
encounter a Strong node, you could add it to the keywords metadata to
automatically generate a list of keywords.
