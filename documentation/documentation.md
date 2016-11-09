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
  to: markdown
  output: ../index.md
  standalone: true
  filter:
  - ../examples/filters/insert_document.rb
  - ../examples/filters/number_figures_per_chapter.rb
  - ../examples/filters/insert_code_block.rb
  - ../examples/filters/remove_pandoc_metadata.rb
...

::paru::insert preface.md

# Introduction

::paru::insert introduction.md

## Licence

::paru::insert licence.md

## Installation

::paru::insert install.md

## Usage: Pary says hello to pandoc

::paru::insert usage.md

# Automating the use of pandoc with paru

::paru::insert using_paru.md

# Writing and using pandoc filters with paru

::paru::insert using_filters.md

# Putting it all together

::paru::insert putting_it_all_together.md

# Frequently asked questions

::paru::insert faq.md

