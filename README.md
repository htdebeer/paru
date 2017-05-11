# Paru: Pandoc wrapped around in Ruby

Paru is a simple ruby wrapper around [pandoc](http://www.pandoc.org), a great
multi-format document converter. See
<https://heerdebeer.org/Software/markdown/paru/> for more information on Paru.

The latest version of Paru is
[0.2.4.2](https://github.com/htdebeer/paru/blob/master/releases/paru-0.2.4.2.gem)
which is incompatible with pandoc <
[1.18](http://pandoc.org/releases.html#pandoc-1.18-26-oct-2016). 

For a collection of paru filters, have a look at the
[paru-filter-collection](https://github.com/htdebeer/paru-filter-collection).

## Licence

Paru is [free sofware](https://www.gnu.org/philosophy/free-sw.en.html);
paru is released under the
[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html). You find paru's
source code on [github](https://github.com/htdebeer/paru).

## Installation

Paru is installed through rubygems as follows:

    gem install paru

You can also download the latest gem
[paru-0.2.4.2.gem](https://github.com/htdebeer/paru/blob/master/releases/paru-0.2.4.2.gem)
and install it by:

    cd /directory/you/downloaded/the/gem/to
    gem install paru-0.2.4.2.gem

Paru, obviously, requires pandoc. See
<http://pandoc.org/installing.html> about how to install pandoc on your
system and [pandoc's manual](http://pandoc.org/README.html) on how to
use pandoc.

## Paru says hello to pandoc

Using paru is straightforward. It is a thin "rubyesque" layer around the
pandoc executable. After requiring paru in your ruby program, you create
a new paru pandoc converter as follows:

    require "paru/pandoc"

    converter = Paru::Pandoc.new

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

    require "paru/pandoc"

    converter = Paru::Pandoc.new
    converter.configure do
        from "markdown"
        to "latex"
        latex_engine "lualatex"
        output "my_first_pdf_file.pdf"
    end

As creating and immediately configuring a converter is a common pattern,
the constructor takes a configuration block as well. Finally, when you
have configured the converter, you can use it to convert a string with
the `convert` method, which is aliased by The `<<` operator. You can
call `convert` multiple times and re-configure the converter in between.

This introductory section is ended by the obligatory "hello world"
program, paru-style:

    #!/usr/bin/env ruby
    require "paru/pandoc"

    input = "Hello world, from **pandoc**"

    output = Paru::Pandoc.new do
        from "markdown"
        to "html"
    end << input

    puts output

Running the above program results in the following output:

    <p>Hello world, from <strong>pandoc</strong></p>

## Documentation

For more information on automatic the use of pandoc with paru or writing
pandoc filters in ruby, please see paru's
[documentation](https://heerdebeer.org/Software/markdown/paru/).

One of the examples described in that documentation is the development of
`do-pandoc.rb`, a program that converts an input file given the pandoc
configuration embedded in the YAML metadata in that input file. This script
`do-pandoc.rb` is installed as a binary when you install paru so you can use
it whenever you want. 

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
