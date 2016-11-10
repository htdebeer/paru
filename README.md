# Paru: Pandoc wrapped around in Ruby

Paru is a simple ruby wrapper around [pandoc](http://www.pandoc.org), a great
multi-format document converter. See
<https://heerdebeer.org/Software/markdown/paru/> for more information on Paru.

The latest version of Paru is
[0.2.0](https://github.com/htdebeer/paru/blob/master/releases/paru-0.2.0.gem)
which is incompatible with pandoc <
[1.18](http://pandoc.org/releases.html#pandoc-1.18-26-oct-2016). Use Paru
version
[0.1.0](https://github.com/htdebeer/paru/blob/master/releases/paru-0.1.0.gem)
for older versions of pandoc. Feature-wise, versions 0.1 and 0.2 are on par.

## Licence

Paru is [free sofware](https://www.gnu.org/philosophy/free-sw.en.html); Paru
is released under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html).
You find paru's source code on [github](https://github.com/htdebeer/paru).

## Installation

Paru is installed through rubygems as follows:

    gem install paru


You can also download the latest gem
[paru-0.2.0.gem](https://github.com/htdebeer/paru/blob/master/releases/paru-0.2.0.gem)
and install it by:


    cd /directory/you/downloaded/the/gem
    gem install paru-0.2.0.gem

Paru, obviously, requires pandoc. See <http://pandoc.org/installing.html>
about how to install pandoc on your system and [pandoc's
manual](http://pandoc.org/README.html) on how to use pandoc.

## Usage

Using paru is straightforward. It is a thin "rubyesque" layer around the
pandoc executable. After requiring paru in your ruby program, you create a new
paru pandoc converter as follows:

    require "paru/pandoc"

    converter = Paru::Pandoc.new

The various [command-line options of
pandoc](http://pandoc.org/README.html#options) map to methods on this newly
created instance. For example, to convert from markdown to pdf using the
lualatex engine, you call the `from`, `to`, and `latex_engine` to configure
the converter. There is a convenience `configure` method that takes a block to
configure multiple options at once:

    require "paru/pandoc"

    converter = Paru::Pandoc.new
    converter.configure do
        from "markdown"
        to "latex"
        latex_engine "lualatex"
        output "my_first_pdf_file.pdf"
    end

As creating and immediately configuring a converter is a common pattern, the
constructor takes a configuration block as well. Finally, when you have
configured the converter, you can use it to convert a string. To complete this
first example, the string "Hello world, from **pandoc**" is converted as
follows:

    require "paru/pandoc"

    converter = Paru::Pandoc.new do
        from "markdown"
        to "latex"
        latex_engine "lualatex"
        output "my_first_pdf_file.pdf"
    end << "Hello world, from **pandoc**"

The `<<` operator is an alias for the `convert` method. You can call `convert`
multiple times and re-configure the converter in between. 

## Documentation

For more information on automatic the use of pandoc with paru or writing
pandoc filters in ruby, please see paru's
[documentation](https://heerdebeer.org/Software/markdown/paru/).
