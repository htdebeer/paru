## Introduction

One of pandoc's interesting capabilities are [custom
filters](https://pandoc.org/scripting.html). This is an extremely powerful
feature that allows you to automate certain tasks, such as numbering figures,
using other command-line programs to pre or post process parts of the input,
or change the structure of the input document before having pandoc writing it
out. Paru allows you to write pandoc filters in Ruby. 

For a collection of paru filters, have a look at the
[paru-filter-collection](https://github.com/htdebeer/paru-filter-collection).

The simplest paru pandoc filter is the *identity* filter that does do nothing:

    ::paru::insert ../examples/filters/identity.rb ruby

Nevertheless, it shows the structure of every paru pandoc filter: A filter is
an executable script (line 1), it uses the `paru/filter` module, and it
executes a `Paru::Filter` object. Running the identity filter is a good way to
start writing your own filters. In the next sections several simple but useful
filters are developed to showcase the use of paru to write pandoc filters in
Ruby.

All example filters discussed in this chapter can be found in the [filters
sub directory](examples/filters) of paru's [examples](examples/). Feel free to
copy and adapt them to your needs.

The [API
documentation](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/)
can be found on this website as well.

## Filter basics

### Numbering figures

In some output formats, such as PDF, HTML + CSS, or ODT, figures can be
automatically numbered. In other formats, notably markdown itself, numbering
has to be done manually. However, it is very easy to create a filter that does
this numbering of figures automatically as well:

    ::paru::insert ../examples/filters/number_figures.rb ruby

The filter `number_figures.rb` keeps track of the last figure's sequence
number in `counter`.  Each time an *Image* is encountered while processing the
input file, that counter is incremented and the image's caption is prefixed
with "Figure #{counter}. " by overwriting the image's node's inner markdown.

A filter consists of a number of selectors. You specify a selector through the
"`with "Type" do |node| ... end`" construct. You can use any of [pandoc's
internal
types](https://hackage.haskell.org/package/pandoc-types-1.17.0.4/docs/Text-Pandoc-Definition.html)
as a selector (see the table below).

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
LineBlock               Math
                        RawInline
                        Link
                        Image
                        Note
                        Span        

Table: Pandoc internal type you can use in a selector in a filter

Usually, however, you want to number figures relative to the chapter they are
in. How to do that is shown next.

Paru also has one special pseudo selector to select any node: `*`. Use this
selector if you want to run a piece of code for each and every node in the
document. For example, to count the number of nodes.

### Numbering figures and chapters

One of the problems with using flat text input formats such as markdown,
LaTeX, or HTML is that a document is more of a sequence of structure elements
rather than a tree. For example, in markdown there is no such thing as a
chapter block that contains its title and contents. Instead, a chapter is
implied by using a header followed by its contents. Nevertheless, assuming a
properly structured input file where each chapter is implied by a header of
level one and a section by a header of level two, the filter
`numbering_figures.rb` can be extended to number chapters, sections, and
figures as follows:

    ::paru::insert ../examples/filters/number_chapters_and_sections_and_figures.rb ruby

In the filter `number_chapters_and_sections_and_figures.rb`, three counters
have to be used. One to keep track of the current chapter, one to keep track
of the current section in that chapter, and one to keep track of the current
figure in that chapter. Each time a new chapter is started—thus each time a
*Header* of level one is encountered—the current chapter counter is
incremented whereas the current section and current figure counters are reset
to zero. When a section—rather a *Header* of level 2—and an *Image* are
encountered, their respective counters are incremented as well.

Note how easy it is to change the content of a node by using the
`inner_markdown` property. This method is used thrice, once in each selector.

In the second selector the `+` or "follows" operator is used. Operators in
selectors denote a relationship between the current node that is being
processed—the right hand side type—and nodes that came before.  In this case,
the selector denotes each *Image* that follows a *Header*. 

You can use three different selection operators in paru: 

-   `A + B`, B follows A
-   `A - B`, B does not follow A
-   `A > B`, B is a descendant of A

Due to the flat structure of the pandoc format, the last selector is used only
sporadically. 

As a more interesting example of using operators, the first sentence of a
section's first paragraph is capitalized next.

### Capitalizing a first sentence

An optional distance can be used in combination with a selector operator by
putting an integer after the operator. To select the first paragraph of a
section, you select only those paragraphs that follow at a distance of 1 nodes
from a header like so:

    ::paru::insert ../examples/filters/capitalize_first_sentence.rb ruby

Of course, just taking the first N letters to capitalize does not work that
well because often the capitalization stops halfway a word. Is it not hard to
improve this `capitalize_first_sentence.rb` filter to capitalize the first M
words, for example.

### Custom blocks

You can use filters to create a custom example block. Given
the following code in your markdown file:

~~~ {.markdown}
<div class="example">
  
### Numbering figures

You can number figures in pandoc by using a filter as follows: ...
</div>
~~~

you can automatically number the example blocks by selecting all *Header*s of level 3
in all *Div* elements that have class "*example*":

    ::paru::insert ../examples/filters/example.rb ruby

Here the descendant selection operator comes in handy to denote the
hierarchical relationship between a block and its contents.

## Going beyond the confines of a filter file

Although filters in and of themselves are already quite useful, the fact
that paru filters have the full power of ruby at their disposal makes for some
truly powerful behavior.

### Inserting other pandoc files

A frequently asked for filter on the pandoc channel on IRC (\#pandoc on
freenode.net, come join us!) is a way to include external files in a markdown
file. An command that is a bit like LaTeX's input command can be created with
a paru filter quite easily:

    ::paru::insert ../examples/filters/insert_document.rb ruby

The filter `insert_document.rb` inspects each *Para*graph. If it is exactly
one line long, that line is split on a space (" "). If the left-most split off
is equal to `::paru::insert`, the one-line paragraph is interpreted as an
insert command with one parameter: the path to the file to insert. This
one-line paragraph's contents are *replaced* by the contents of that file
using the `outer_markdown` method.

Note that, because I like to use file names with an underscore in it and
pandoc puts an backslash (\\) in front of underscores, I had to replace all
occurrences of "\\\_" by "\_" to get Ruby to find and read the file correctly.

### Inserting code files

Similarly, when writing a programming tutorial or manual (like this manual;
have a look at `documentation/using_filters.md` for example), it would be
great if you can point pandoc to a file containing some programming code and
have that code included automatically. This is even more simple that inserting
markdown files!:

    ::paru::insert ../examples/filters/insert_code_block.rb ruby

The *CodeBlock* element has a string property that can be inspected and
replaced. As with the previous filter to include other markdown files, if the
*CodeBlock* contains the "command" ``::paru::insert`` followed by a path and
optionally more parameters, the code block is treated as an insert command.
The file is read and its contents are used in stead of the command.

## Running code before and after

Sometimes you want to setup a document before filtering, or to cleanup after
you finished filtering. For these purposes, use the `before` or `after`
methods. Both methods are run exactly once. Use these methods to change
metadata (See next section), to create and cleanup temporary files during the
filtering, or do some other form of administrative work before or after the
filter is run on each and every node in your document.

As an example of the structure of a filter with `before` and `after` parts,
see:

    ::paru::insert ../examples/filters/before_during_after.rb ruby

If you run this filter, you will see the string "before" first, followed by a
lot of "during" strings, and end with the string "after".

## Manipulating pandoc's metadata

Finally, you can access metadata in an input file through the `metadata`
method available in a selector. This gives you the ability to create flexible
filters that have different behavior depending on the metadata specified in
the file. Furthermore, you can also set metadata. For example, each time you
encounter a *Strong* node, you could add it to the keywords metadata to
automatically generate a list of keywords.

As an example, I have created a filter that removes a pandoc configuration
from the metadata if there is such a property:

    ::paru::insert ../examples/filters/remove_pandoc_metadata.rb ruby

Instead of removing the pandoc property all together, I could also have
updated it to have a markdown file be converted differently the second time it
is run by `do-pandoc.rb`.


For more information about manipulating metadata, see [the API documentation
of the
MetaMap](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/Paru/PandocFilter/MetaMap.html).
