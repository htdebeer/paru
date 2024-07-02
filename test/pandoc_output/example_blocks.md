When I was a teacher, I often created my own instructional materials. In
these materials I liked to emphasize certain common parts, such as
examples. In LaTeX I could define an "example" environment and in HTML a
`DIV` with a special "example" class with CSS numbering would do the
trick. To get something similar in markdown, I wrote the `example.rb`
filter.

# Using the example block

:::: example
### Example 1: Adding your first example {#adding-your-first-example}

Create an example block as follows: \~\~\~{.markdown}

::: example
### Example 2: My first example!! {#my-first-example}

My first example is about creating my first example
:::

\~\~\~
::::

::: important
Throughout the text, you can add example blocks like this. Furhtermore,
to emphasize a block as important, use an "important" class.

*(important)*
:::

::: example
### Example 3: Adding an important block {#adding-an-important-block}

Use a `DIV` with class *important* to create an important block.
:::

As you can see, easy as pie.

# On makin pie

::: example
### Example 4: Different pies {#different-pies}

I like cherry pie and apple pie.
:::
