Once I started using pandoc for all my papers, articles, and other writings, I
found that using the command line interface was a bit cumbersome because of
the many options I used. Of course I used the shell's history so I did not
have to retype the pandoc invocations each time I used them, but as I write
multiple documents at the same time and often on different computers, this
felt as a stop-gap solution at best. Would it not be great if I could specify
all the command-line options to pandoc in the markdown files themselves? To
that end, I developed do-pandoc.rb.

I developed do-pandoc.rb in two steps: 

1. first I wrote a ruby script to mine the pandoc markdown files for its
   [YAML](http://yaml.org/) metadata.
2. using that script, I wrote another to first get the metadata about pandoc's
   command-line options to use from an input file, fed them into a dynamically
   generated pandoc converter, and used this converter on that input file.

## Stripping a pandoc file for its YAML metadata

One of the interesting aspects of pandoc's markdown format is its allowance
for metadata in so-called [YAML](http://yaml.org/) blocks. Using paru and Ruby
  it is easy to strip a pandoc file for its metadata through pandoc's
  [JSON](http://json.org/) output/input format:

    ::paru::insert ../examples/pandoc2yaml.rb ruby

Note that the `json2pandoc` converter has the `standalone` option. Without
using it, pandoc does not convert the metadata back to its own markdown
format.

## Specify pandoc options in a markdown file itself

Using the ideas from `pandoc2yaml.rb`, it is easy to write a script that runs
pandoc on a markdown file using the pandoc options specified in that same file
in a [YAML](http://yaml.org) metadata block:

    ::paru::insert ../examples/do-pandoc.rb ruby

You now can convert a markdown file, say `my_document.md` that contains a
metadata block like:

~~~ {.yaml}
---
pandoc:
    from: markdown
    to: html5
    toc: true
    standalone: true
    bibliography: 'path/to/bibliography.bib'
...
~~~

to html by running the following command:

~~~ {.bash}
do-pandoc.rb my_document.md
~~~
