Once I started using pandoc for all my writing, I found that using the
command-line interface was a bit cumbersome because of the many options I
used. Of course I used the shell's history so I did not have to retype the
pandoc invocations each time I used them, but as I write multiple documents at
the same time and often on different computers, this felt as a stop-gap
solution at best. Would it not be great if I could specify all the
command-line options to pandoc in the markdown files themselves? To that end,
I developed *do-pandoc.rb*.

I developed *do-pandoc.rb* in two steps: 

1. first I wrote a ruby script to mine the pandoc markdown files for its
   [YAML](http://yaml.org/) metadata.
2. using that script, I wrote another script that would use the former to get
   the pandoc command-line options to use from an input file, fed these
   options into a dynamically generated pandoc converter, and then use this
   converter on that same input file to generate my output file.

## Mining a pandoc markdown file for its YAML metadata

One of the interesting aspects of pandoc's markdown format is its allowance
for metadata in so-called [YAML](http://yaml.org/) blocks. Using paru and Ruby
  it is easy to strip a pandoc file for its metadata through pandoc's
  [JSON](http://json.org/) output/input format: the script/module
  *[pandoc2yaml.rb* (which you will also find in the [examples](examples/) sub
  directory). Furthermore, it is also installed as an executable when you
  install paru, so you can run it from the command line like:

~~~{.bash}
pandoc2yaml my-noce-pandoc-file.md
~~~

  The `pandoc2yaml.rb` script is quite straightforward:

    ::paru::insert ../examples/pandoc2yaml.rb ruby

*pandoc2yaml.rb* is built in two parts: 

1.  a library module `Pandoc2Yaml`, which we will be using later again in
    *do-pandoc.rb*,
2.  and a self-contained part that, following a common Ruby pattern, will be
    executed if the file is run as a script rather than a library. It checks
    if there is an argument to the script and, if so, interprets it as a path
      to a file, and mines its contents for YAML metadata using the libray
      module.

The library module `Pandoc2Yaml` has one method, `extract_metadata` that takes
one argument, the path to a pandoc markdown file. 


    ::paru::insert ../lib/paru/pandoc2yaml.rb ruby


This method converts the contents of that file to a JSON representation of the
document. Since pandoc version 1.18, this JSON representation consists of
three elements:

1.  the version of the [pandoc-types
    API](http://hackage.haskell.org/package/pandoc-types-1.17.0.4) used
    (`"pandoc-api-version"`),
2.  the metadata in the document (`"meta"`),
3.  and the contents of the document (`"blocks"`).

The contents of the document are discarded and the metadata is converted back
to pandoc's markdown format, which now only contains YAML metadata. Note that
the `JSON_2_PANDOC` converter uses the `standalone` option. Without using it,
pandoc does not convert the metadata back to its own markdown format.

## Specify pandoc options in a markdown file itself

Using the library module `Pandoc2Yaml` discussed in the previous section, it
is easy to write a script that runs pandoc on a markdown file using the pandoc
options specified in that same file in a [YAML](http://yaml.org) metadata
block:

    ::paru::insert ../examples/do-pandoc.rb ruby

The script `do-pandoc.rb` first checks if there is one argument. If so, it is treated
as a path to a pandoc markdown file. That file is mined for its metadata and
if that metadata contains the property *pandoc*, the fields of that property
  are interpreted are used to configure a paru pandoc converter. The key of a
  property is called as a method on a `Paru::Pandoc`` object with the
  property's value as its argument. Thus, a pandoc markdown file that contains a
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

will configure a `Paru::Pandoc` object to convert the contents of that pandoc
markdown file from *markdown* to *standalone* *html* code with a *table of
contents* while using `path/to/bibliography.bib` as the *bibliographic
database*.

`do-pandoc.rb` is also installed as an executable script when you istall paru.
You can run it from the command line as follows:

~~~{.bash}
do-pandoc.rb my-file.md
~~~

In [Chapter 4](#putting-it-all-together) this script `do-pandoc.rb` is used on
[paru's documentation file](documentation/documentation.md) to generate a new
pandoc markdown file, `index.md`, that is converted to HTML into **the manual
you are reading now!**

Note how `do-pandoc.rb` defaults to outputting the results of a conversion to
standard out unless the *output* option is specified in the *pandoc* property
in the metadata.
