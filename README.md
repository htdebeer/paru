# Paru—Pandoc wrapped around in Ruby

## Contents

-   [Introduction](#introduction)
-   [Licence](#licence)
-   [Installation](#installation)
-   [Paru says hello to pandoc](#paru-says-hello-to-pandoc)
-   [Writing and using pandoc filters with paru](#writing-and-using-pandoc-filters-with-paru)
-   [Documentation](#documentation)

Introduction
------------

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

You can also download the latest gem [paru-0.2.4.6.gem](https://github.com/htdebeer/paru/blob/master/releases/paru-0.2.4.6.gem) and install it by:

``` bash
cd /directory/you/downloaded/the/gem/to
gem install paru-0.2.4.6.gem
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

Writing and using pandoc filters with paru
------------------------------------------

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

A more useful filter is to numbering figures. In some output formats, such as PDF, HTML + CSS, or ODT, figures can be automatically numbered. In other formats, notably markdown itself, numbering has to be done manually. However, it is very easy to create a filter that does this numbering of figures automatically as well:

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

The filter `number_figures.rb` keeps track of the last figure's sequence number in `counter`. Each time an [Image](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/Paru/PandocFilter/Image.html) is encountered while processing the input file, that counter is incremented and the image's caption is prefixed with "Figure \#{counter}. " by overwriting the image's node's inner markdown.

For more information about writing filters, please see [paru's manual](https://heerdebeer.org/Software/markdown/paru/) or the API documentation for the [Filter](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/Paru/Filter.html) class. Furthermore, example filters can also be found in the [filters sub directory](examples/filters) of paru's [examples](examples/). Feel free to copy and adapt them to your needs.

Documentation
-------------

For more information on automatic the use of pandoc with paru or writing pandoc filters in ruby, please see paru's [manual](https://heerdebeer.org/Software/markdown/paru/). The [API documentation can be found there as well](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/).

One of the examples described in the manual is the development of `do-pandoc.rb`, a program that converts an input file given the pandoc configuration embedded in the YAML metadata in that input file. This script `do-pandoc.rb` is installed as a binary when you install paru so you can use it whenever you want.

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
