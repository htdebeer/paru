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
  template: ./github_template.md
  toc: true
  filter:
  - ../examples/filters/insert_document.rb
  - ../examples/filters/insert_code_block.rb
  - ../examples/filters/remove_pandoc_metadata.rb
  - ../examples/filters/insert_paru_version.rb
...

[![Gem Version](https://badge.fury.io/rb/paru.svg)](https://badge.fury.io/rb/paru)

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

