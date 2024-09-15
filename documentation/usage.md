Using paru is straightforward. It is a thin "rubyesque" layer around the
pandoc executable. After requiring paru in your ruby program, you create a new
paru pandoc converter as follows:

~~~ {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new
~~~

The various [command-line options of
pandoc](https://pandoc.org/README.html#options) map to methods on this newly
created instance. When you want to use a pandoc command-line option that
contains dashes, replace all dashes with an underscore to get the
corresponding paru method. For example, the pandoc command-line option
`--pdf-engine` becomes the paru method `pdf_engine`.  Knowing this
convention, you can convert from markdown to pdf using the lualatex engine
by calling the `from`, `to`, and `pdf_engine` methods to configure the
converter. There is a convenience `configure` method that takes a block to
configure multiple options at once:

~~~ {.ruby}
require "paru/pandoc"

converter = Paru::Pandoc.new
converter.configure do
    from "markdown"
    to "latex"
    pdf_engine "lualatex"
    output "my_first_pdf_file.pdf"
end
~~~

As creating and immediately configuring a converter is a common pattern, the
constructor takes a configuration block as well. Finally, when you have
configured the converter, you can use it to convert a string with the
`convert` method, which is aliased by The `<<` operator. You can call `convert`
multiple times and re-configure the converter in between.

This introductory section is ended by the obligatory "hello world" program,
paru-style:

    ::paru::insert ../examples/hello_world.rb ruby

Running the above program results in the following output:

~~~ {.html}
<p>Hello world, from <strong>pandoc</strong></p>
~~~

To support converting files that cannot easily be represented by a single
string, such as EPUB or docx, paru also has the `convert_file` method. It
takes a path as argument, and when executed, it tells pandoc to convert that
path using the current configured pandoc configuration. 

In the next chapter, the development of *do-pandoc.rb* is presented as an
example of real-world usage of paru.
