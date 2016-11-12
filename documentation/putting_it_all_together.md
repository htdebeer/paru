Having discussed using paru and creating and using filters in the previous two
chapters, it is now time to put it all together and into practice. As an
example, the generation of this manual is used. In the directory
[documentation](documentation/) you find a number of files that comprise this
manual. The root file is [documentation.md](documentation/documentation.md),
which contains some metadata, the outline of the manual, and a number of
``::paru::insert`` commands to include the other markdown files from the
documentation directory:

    ::paru::insert documentation.md markdown

To generate the manual markdown file [index.md](index.md), run the
`do-pandoc.rb` script on `document.md`:

~~~{.bash}
do-pandoc.rb documentation.md
~~~

Using some simple filters and a small Ruby script, paru enables you to
automate using pandoc and perform simple and complex transformations on your
input files to generate quite complex documents.
