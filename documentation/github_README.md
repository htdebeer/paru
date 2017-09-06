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
  to: gfm
  output: ../README.md
  standalone: true
  template: ./github_template.md
  toc: true
  filter:
  - ../examples/filters/insert_document.rb
  - ../examples/filters/insert_code_block.rb
  - ../examples/filters/remove_pandoc_metadata.rb
  - ../examples/filters/insert_paru_version.rb
...

This is a development branch of paru to build a pandoc2 compatible version of
paru. You can install a pre-release of pandoc2 via
<https://github.com/pandoc-extras/pandoc-nightly/releases>. To run pandoc with
the newly downloaded pandoc2, set the environment variable PARU_PANDOC_PATH to
point to that newly downloaded pandoc2 executable.

Note. As pandoc2 seems to be incompatible with pandoc1, so will paru for these
versions. The difference seems mostly related to generated output and some
filtering.


## Introduction

::paru::insert introduction.md

This README is a brief overview of paru's features and usages.

### Licence

::paru::insert license.md

### Acknowledgements

::paru::insert acknowledgements.md

### Installation

::paru::insert install.md

## Paru says hello to pandoc

::paru::insert usage.md

## Writing and using pandoc filters with paru

::paru::insert introduction_filters.md

## Documentation

### Manual 

For more information on automatic the use of pandoc with paru or writing
pandoc filters in ruby, please see paru's
[manual](https://heerdebeer.org/Software/markdown/paru/). 

### API documentation

The [API
documentation](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/)
covers the whole of paru. Where the manual just describes a couple of
scenarios, the API documentation shows all available functionality. It also
give more examples of using paru and writing filters.

### Frequently asked questions

::paru::insert faq.md

