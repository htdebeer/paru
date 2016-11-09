---
title: Paru—Pandoc wrapped around in Ruby
author: Huub de Beer
keywords:
- pandoc
- ruby
- paru
pandoc:
  from: markdown
  to: markdown
  output: ../index.md
  standalone: true
  filter:
  - ../examples/filters/insert_document.rb
  - ../examples/filters/capitalize_first_sentence.rb
...

::paru::insert preface.md

::paru::insert licence.md

# Introduction

::paru::insert introduction.md

# Installation

::paru::insert install.md

# Usage

## Say hello to pandoc

::paru::insert usage.md

# Automating the use of pandoc with paru

# Writing and using pandoc filters with paru

# Putting it all together

# What is next
