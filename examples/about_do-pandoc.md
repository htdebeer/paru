---
title: Controlling pandoc from within a pandoc markdown file
author: Huub de Beer
keywords:
- pandoc
- paru
pandoc:
  from: markdown
  to: html5
  standalone: true
...

The script `do-pandoc.rb` takes as input one pandoc markdown file. First, it
mines that input file for metadata using the `pandoc2yaml.rb` script. Then, if
that mined metadata contains a *pandoc* configuration property, it uses that
configuration to setup the pandoc converter. For example, this file contains a
pandoc configuration to convert this file to a standalone HTML file.

Just run this file through `do-pandoc.rb` and see what happens!
