---
title: Paru—Pandoc wrapped around in Ruby
author: Huub de Beer
keywords:
- pandoc
- ruby
- paru
- filter
- pandoc filter
pandoc:
  from: markdown
  to: markdown_github
  output: ../README.md
  standalone: true
  filter:
  - ../examples/filters/insert_document.rb
  - ../examples/filters/insert_code_block.rb
  - ../examples/filters/remove_pandoc_metadata.rb
  - ../examples/filters/insert_paru_version.rb
...

::paru::insert preface.md

# Introduction

::paru::insert introduction.md

## Licence

::paru::insert license.md

## Installation

::paru::insert install.md

## Paru says hello to pandoc

::paru::insert usage.md

## Documentation

For more information on automatic the use of pandoc with paru or writing
pandoc filters in ruby, please see paru's
[documentation](https://heerdebeer.org/Software/markdown/paru/). The [API
documentation can be found there as
well](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/).

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
