One of pandoc's interesting capabilities are [custom
filters](http://pandoc.org/scripting.html). This is an extremely powerful
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

A more useful filter is to numbering figures.
In some output formats, such as PDF, HTML + CSS, or ODT, figures can be
automatically numbered. In other formats, notably markdown itself, numbering
has to be done manually. However, it is very easy to create a filter that does
this numbering of figures automatically as well:

    ::paru::insert ../examples/filters/number_figures.rb ruby

The filter `number_figures.rb` keeps track of the last figure's sequence
number in `counter`.  Each time an
[Image]{https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/Paru/PandocFilter/Image.html}
is encountered while processing the input file, that counter is incremented
and the image's caption is prefixed with "Figure #{counter}. " by overwriting
the image's node's inner markdown.

For more information about writing filters, please see [paru's
manual](https://heerdebeer.org/Software/markdown/paru/) or the API
documentation for the
[Filter]{https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/Paru/Filter.html}
class. Furthermore, example filters can also be found in the [filters
sub directory](examples/filters) of paru's [examples](examples/). Feel free to
copy and adapt them to your needs.
