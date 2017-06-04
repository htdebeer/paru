% A test file with all node types in it
% Huub de Beer
% 2017-06-03

# Introduction

This test file tries to have included all pandoc node types and AST features
somehow. It is created by reading [pandoc's
manual](http://pandoc.org/MANUAL.html). In writing this paragraph alone, I
already have used a couple of pandoc's node types:

- a paragraph itself,
- the inline contents of a paragraph,
- a link to the pandoc manual,
- and now also an unordered list!

# Metadata

One of pandoc's interesting features is its allowance for metadata. There are
three ways of getting metadata in a document:

--- 
keywords:
- pandoc
- paru
subtitle: Or reading pandoc's manual
...

1. using the three `%`-prefixed lines at the start of the document describing
   the *title*, *author*, and *date*.
2. using a YAML metadata block, like so:

       ```{.yaml}
       --- 
       keywords:
       - pandoc
       - paru
       subtitle: Or reading pandoc's manual
       ...
       ```
3. using metadata arguments when invoking pandoc on the command line.

Headers {#headers}
-------

There are different ways to add headers to a pandoc markdown file, using
_underlining_ or prefixing with `#` characters. Pandoc can create a table of
contents for you, either creating references automatically, or using user
supplied references. See [the section about headers]{#headers} for more
information. You can link [without][metadata] or [with]{#metadata} a specific
reference. References are always lower case, and words separated by `-`.

To quote the manual:

> Markdown uses email conventions for quoting blocks of text. [@pandocmanual]

and 

> A "lazy" form, which requires the `>` character only on the first line of
each block is also allowed.

also

> (...) block quotes can be nested:
>
> > like so
> 
> (including code blocks:)
>
>    > This is a block quote.
>    >
>    > > A block quote within a block quote

# Code

Meanwhile, we have already seen code in this file. You can add it inline, like
`for i = 0 to 9 do puts "hi" end` or use a block. A block is either fenced,
i.e. surrounded by fences made up of three or more `\`` or `~` characters, or
by prefixing all lines in the block with four spaces. Thus:

~~~
puts "this is a code block"
~~~

as is this:

   puts "this is a code block"

The example with attributes given in the manual is:

> ~~~~ {#mycode .haskell .numberLines startFrom="100"}
> qsort []     = []
> qsort (x:xs) = qsort (filter (< x) xs) ++ [x] ++
>                qsort (filter (>= x) xs)
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Other block level elements

## Line blocks

| line blocks are blocks prefixed with a pipe (`|`), 
|           like this paragraph.
|   It is a verbatim block, nice
| for Po
|       ems

## Lists

### Unordered

- We have already
- seen lists without 
- ordering
  - These can have 
  - sub
    - lists
- Just like that.

### Ordered lists

1. Ordered lists
2. work the same, but with
8. numbers in front.
9. Ain't much to it:
   - as with mixing lists
     1. like
     2. so

#. Heck, you can even use plain `#` characters
#. to number a list

(2) Or start at number 2
     i. use latin numbers
    ii. if that's your fancy


### Definition lists

Definition lists are a bit more involved, but still easy to create.

Pandoc

:   A multi format document converter

Paru

:   A Ruby wrapper around pandoc

### Example lists

Example lists are quite new?

(@) For example
(@) this list.

(@filter) A filter can be written in Ruby

As you can see in example (@filter), you can write filters in Ruby

## Tables

Below follow the tables from the pandoc manual:

  Right     Left     Center     Default
-------     ------ ----------   -------
     12     12        12            12
    123     123       123          123
      1     1          1             1

Table:  Demonstration of simple table syntax.

-------     ------ ----------   -------
     12     12        12            12
    123     123       123          123
      1     1          1             1
-------     ------ ----------   -------

               
-------------------------------------------------------------
 Centered   Default           Right Left
  Header    Aligned         Aligned Aligned
----------- ------- --------------- -------------------------
   First    row                12.0 Example of a row that
                                    spans multiple lines.

  Second    row                 5.0 Here's another one. Note
                                    the blank line between
                                    rows.
-------------------------------------------------------------

Table: Here's the caption. It, too, may span
multiple lines.


: Sample grid table.

+---------------+---------------+--------------------+
| Fruit         | Price         | Advantages         |
+===============+===============+====================+
| Bananas       | $1.34         | - built-in wrapper |
|               |               | - bright color     |
+---------------+---------------+--------------------+
| Oranges       | $2.10         | - cures scurvy     |
|               |               | - tasty            |
+---------------+---------------+--------------------+

| Right | Left | Default | Center |
|------:|:-----|---------|:------:|
|   12  |  12  |    12   |    12  |
|  123  |  123 |   123   |   123  |
|    1  |    1 |     1   |     1  |

  : Demonstration of pipe table syntax.
               
# Inline level things
               
- *emphasize*               
- **strong**
- * or * not
- ~~strikeout~~
- 10^4^
- H~2~O
- `code`
- [Small caps]{style="font-variant: small-caps;"}; <span style="font-variant: small-caps;">Small caps</span>
- $\frac{3}{5}$

# Raw HTML or LaTeX

<div>
    <p>
        <em>This is raw html</em>

    </p>
</div>

\begin{enumerate}
    \item And raw \LaTeX
    \item whoho!
\end{enumerate}


# Various links

- automatic link: <https://pandoc.org>
- inline link: [like so](https://pandoc.org)
- reference link: [a label]
- link with attributes: [attributes](https://pandoc.org){.external target="_blank"}
- footnotes^[LIke this one]^[or this one]
- You can also create them like [^1] and [^2] and define the contents
  elsewhere

[a label]: https://pandoc.org "And a title"

[^1]: The first note
[^2]: another one

    with more than one paragraph

Images are also kind of links

![Figure X. See this image](/path/to/img.png)

# Span and Div

<span class="important">Spans</span> and divs van be created as general inline
or block level elements, respectively. Spans [can also]{.important} created
like a link: just skip the URL.  

<div class="example">
This is an example **block**. Markdown inside works.
</div>  

