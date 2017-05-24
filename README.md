Do note that Paru version &gt;= 0.2.0 is incompatible with pandoc version &lt; [1.18](http://pandoc.org/releases.html#pandoc-1.18-26-oct-2016).

For a collection of paru filters, have a look at the [paru-filter-collection](https://github.com/htdebeer/paru-filter-collection).

Introduction
============

Paru is a simple Ruby wrapper around [pandoc](http://www.pandoc.org), the great multi-format document converter. Paru supports automating pandoc by writing Ruby programs and using pandoc in your Ruby programs (see [Chapter 2](#automating-the-use-of-pandoc-with-paru)). Paru also supports writing pandoc filters in Ruby (see [Chapter 3](#writing-and-using-pandoc-filters-with-paru)). In this manual the use of paru is explained in detail, from explaining how to install and use paru, creating and using filters, to putting it all together in a real-world use case: generating this manual!

See also the [paru API documentation](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/).

Licence
-------

Paru is [free sofware](https://www.gnu.org/philosophy/free-sw.en.html); paru is released under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html). You find paru's source code on [github](https://github.com/htdebeer/paru).

Installation
------------

Paru is installed through rubygems as follows:

``` bash
gem install paru
```

You can also download the latest gem [paru-0.2.4.3.gem](https://github.com/htdebeer/paru/blob/master/releases/paru-0.2.4.3.gem) and install it by:

``` bash
cd /directory/you/downloaded/the/gem/to
gem install paru-0.2.4.3.gem
```

Paru, obviously, requires pandoc. See <http://pandoc.org/installing.html> about how to install pandoc on your system and [pandoc's manual](http://pandoc.org/README.html) on how to use pandoc.

Paru says hello to pandoc
-------------------------

Using paru is straightforward. It is a thin "rubyesque" layer around the pandoc executable. After requiring paru in your ruby program, you create a new paru pandoc converter as follows:

``` ruby
require "paru/pandoc"

converter = Paru::Pandoc.new
```

The various [command-line options of pandoc](http://pandoc.org/README.html#options) map to methods on this newly created instance. When you want to use a pandoc command-line option that contains dashes, replace all dashes with an underscore to get the corresponding paru method. For example, the pandoc command-line option `--latex-engine` becomes the paru method `latex_engine`. Knowing this convention, you can convert from markdown to pdf using the lualatex engine by calling the `from`, `to`, and `latex_engine` methods to configure the converter. There is a convenience `configure` method that takes a block to configure multiple options at once:

``` ruby
require "paru/pandoc"

converter = Paru::Pandoc.new
converter.configure do
    from "markdown"
    to "latex"
    latex_engine "lualatex"
    output "my_first_pdf_file.pdf"
end
```

As creating and immediately configuring a converter is a common pattern, the constructor takes a configuration block as well. Finally, when you have configured the converter, you can use it to convert a string with the `convert` method, which is aliased by The `<<` operator. You can call `convert` multiple times and re-configure the converter in between.

This introductory section is ended by the obligatory "hello world" program, paru-style:

``` ruby
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

``` html
<p>Hello world, from <strong>pandoc</strong></p>
```

In the next chapter, the development of *do-pandoc.rb* is presented as an example of real-world usage of paru.

Documentation
-------------

For more information on automatic the use of pandoc with paru or writing pandoc filters in ruby, please see paru's [documentation](https://heerdebeer.org/Software/markdown/paru/). The [API documentation can be found there as well](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/).

One of the examples described in that documentation is the development of `do-pandoc.rb`, a program that converts an input file given the pandoc configuration embedded in the YAML metadata in that input file. This script `do-pandoc.rb` is installed as a binary when you install paru so you can use it whenever you want.

For example, the following markdown file (`hello.md`),

    ---
    title: Hello!
    author: Huub de Beer
    pandoc:
      from: 'markdown'
      to: 'html5'
    ...

    # Hello from Pandoc

    Hi, this is converted to pandoc by running this file through
    `do-pandoc.rb`!

can be converted by pandoc to HTML by running the following command:

    do-pandoc.rb hello.md

Writing and using pandoc filters with paru
==========================================

Introduction
------------

One of pandoc's interesting capabilities are [custom filters](http://pandoc.org/scripting.html). This is an extremely powerful feature that allows you to automate certain tasks, such as numbering figures, using other command-line programs to pre or post process parts of the input, or change the structure of the input document before having pandoc writing it out. Paru allows you to write pandoc filters in Ruby.

For a collection of paru filters, have a look at the [paru-filter-collection](https://github.com/htdebeer/paru-filter-collection).

The simplest paru pandoc filter is the *identity* filter that does do nothing:

``` ruby
#!/usr/bin/env ruby
# Identity filter
require "paru/filter"

Paru::Filter.run do
    # nothing
end
```

Nevertheless, it shows the structure of every paru pandoc filter: A filter is an executable script (line 1), it uses the `paru/filter` module, and it executes a `Paru::Filter` object. Running the identity filter is a good way to start writing your own filters. In the next sections several simple but useful filters are developed to showcase the use of paru to write pandoc filters in Ruby.

All example filters discussed in this chapter can be found in the [filters sub directory](examples/filters) of paru's [examples](examples/). Feel free to copy and adapt them to your needs.

The [API documentation](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/) can be found on this website as well.

Filter basics
-------------

### Numbering figures

In some output formats, such as PDF, HTML + CSS, or ODT, figures can be automatically numbered. In other formats, notably markdown itself, numbering has to be done manually. However, it is very easy to create a filter that does this numbering of figures automatically as well:

``` ruby
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

The filter `number_figures.rb` keeps track of the last figure's sequence number in `counter`. Each time an *Image* is encountered while processing the input file, that counter is incremented and the image's caption is prefixed with "Figure \#{counter}. " by overwriting the image's node's inner markdown.

A filter consists of a number of selectors. You specify a selector through the "`with "Type" do |node| ... end`" construct. You can use any of [pandoc's internal types](https://hackage.haskell.org/package/pandoc-types-1.17.0.4/docs/Text-Pandoc-Definition.html) as a selector (see the table below).

| block          | inline      |
|:---------------|:------------|
| Plain          | Str         |
| Para           | Emph        |
| CodeBlock      | Strong      |
| RawBlock       | Strikeout   |
| BlockQuote     | Superscript |
| OrderedList    | Supscript   |
| BulletList     | SmallCaps   |
| DefinitionList | Quoted      |
| Header         | Cite        |
| HorizontalRule | Code        |
| Table          | Space       |
| Div            | SoftBreak   |
| Null           | LineBreak   |
| LineBlock      | Math        |
|                | RawInline   |
|                | Link        |
|                | Image       |
|                | Note        |
|                | Span        |

Usually, however, you want to number figures relative to the chapter they are in. How to do that is shown next.

### Numbering figures and chapters

One of the problems with using flat text input formats such as markdown, LaTeX, or HTML is that a document is more of a sequence of structure elements rather than a tree. For example, in markdown there is no such thing as a chapter block that contains its title and contents. Instead, a chapter is implied by using a header followed by its contents. Nevertheless, assuming a properly structured input file where each chapter is implied by a header of level one and a section by a header of level two, the filter `numbering_figures.rb` can be extended to number chapters, sections, and figures as follows:

``` ruby
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

In the filter `number_chapters_and_sections_and_figures.rb`, three counters have to be used. One to keep track of the current chapter, one to keep track of the current section in that chapter, and one to keep track of the current figure in that chapter. Each time a new chapter is started—thus each time a *Header* of level one is encountered—the current chapter counter is incremented whereas the current section and current figure counters are reset to zero. When a section—rather a *Header* of level 2—and an *Image* are encountered, their respective counters are incremented as well.

Note how easy it is to change the content of a node by using the `inner_markdown` property. This method is used thrice, once in each selector.

In the second selector the `+` or "follows" operator is used. Operators in selectors denote a relationship between the current node that is being processed—the right hand side type—and nodes that came before. In this case, the selector denotes each *Image* that follows a *Header*.

You can use three different selection operators in paru:

-   `A + B`, B follows A
-   `A - B`, B does not follow A
-   `A > B`, B is a descendant of A

Due to the flat structure of the pandoc format, the last selector is used only sporadically.

As a more interesting example of using operators, the first sentence of a section's first paragraph is capitalized next.

### Capitalizing a first sentence

An optional distance can be used in combination with a selector operator by putting an integer after the operator. To select the first paragraph of a section, you select only those paragraphs that follow at a distance of 1 nodes from a header like so:

``` ruby
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

Of course, just taking the first N letters to capitalize does not work that well because often the capitalization stops halfway a word. Is it not hard to improve this `capitalize_first_sentence.rb` filter to capitalize the first M words, for example.

### Custom blocks

You can use filters to create a custom example block. Given the following code in your markdown file:

``` markdown
<div class="example">
  
### Numbering figures

You can number figures in pandoc by using a filter as follows: ...
</div>
```

you can automatically number the example blocks by selecting all *Header*s of level 3 in all *Div* elements that have class "*example*":

``` ruby
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

Here the descendant selection operator comes in handy to denote the hierarchical relationship between a block and its contents.

Going beyond the confines of a filter file
------------------------------------------

Although filters in and of themselves are already quite useful, the fact that paru filters have the full power of ruby at their disposal makes for some truly powerful behavior.

### Inserting other pandoc files

A frequently asked for filter on the pandoc channel on IRC (\#pandoc on freenode.net, come join us!) is a way to include external files in a markdown file. An command that is a bit like LaTeX's input command can be created with a paru filter quite easily:

``` ruby
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

The filter `insert_document.rb` inspects each *Para*graph. If it is exactly one line long, that line is split on a space (" "). If the left-most split off is equal to `::paru::insert`, the one-line paragraph is interpreted as an insert command with one parameter: the path to the file to insert. This one-line paragraph's contents are *replaced* by the contents of that file using the `outer_markdown` method.

Note that, because I like to use file names with an underscore in it and pandoc puts an backslash (\\) in front of underscores, I had to replace all occurrences of "\\\_" by "\_" to get Ruby to find and read the file correctly.

### Inserting code files

Similarly, when writing a programming tutorial or manual (like this manual; have a look at [documentation/using\_filters.md](documentation/using_filters.md) for example), it would be great if you can point pandoc to a file containing some programming code and have that code included automatically. This is even more simple that inserting markdown files!:

``` ruby
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

The *CodeBlock* element has a string property that can be inspected and replaced. As with the previous filter to include other markdown files, if the *CodeBlock* contains the "command" `::paru::insert` followed by a path and optionally more parameters, the code block is treated as an insert command. The file is read and its contents are used in stead of the command.

Manipulating pandoc's metadata
------------------------------

Finally, you can access metadata in an input file through the `metadata` method available in a selector. This gives you the ability to create flexible filters that have different behavior depending on the metadata specified in the file. Furthermore, you can also set metadata. For example, each time you encounter a *Strong* node, you could add it to the keywords metadata to automatically generate a list of keywords.

As an example, I have created a filter that removes a pandoc configuration from the metadata if there is such a property:

``` ruby
#!/usr/bin/env ruby
require "paru/filter"

Paru::Filter.run do 
  metadata.delete "pandoc" if metadata.has_key? "pandoc"
end
```

Instead of removing the pandoc property all together, I could also have updated it to have a markdown file be converted differently the second time it is run by `do-pandoc.rb`.

For more information, see the [paru filter API documentation](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/).
