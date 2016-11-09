Using paru is straightforward. It is a thin "rubyesque" layer around the
pandoc executable. After requiring paru in your ruby program, you create a new
paru pandoc converter as follows:

~~~ {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new
~~~

The various [command-line options of
pandoc](http://pandoc.org/README.html#options) map to methods on this newly
created instance. For example, to convert from markdown to pdf using the
lualatex engine, you call the `from`, `to`, and `latex_engine` to configure
the converter. There is a convenience `configure` method that takes a block to
configure multiple options at once:

~~~ {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new
converter.configure do
    from "markdown"
    to "latex"
    latex_engine "lualatex"
    output "my_first_pdf_file.pdf"
end
~~~

As creating and immediately configuring a converter is a common pattern, the
constructor takes a configuration block as well. Finally, when you have
configured the converter, you can use it to convert a string. To complete this
first example, the string "Hello world, from **pandoc**" is converted as
follows:

~~~ {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new do
    from "markdown"
    to "latex"
    latex_engine "lualatex"
    output "my_first_pdf_file.pdf"
end << "Hello world, from **pandoc**"
~~~

The `<<` operator is an alias for the `convert` method. You can call `convert`
multiple times and re-configure the converter in between. 

In the next chapter, the development of *do-pandoc.rb* is presented as an
example of real-world usage of paru.
