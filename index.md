---
author: Huub de Beer
keywords:
- pandoc
- ruby
- paru
pandoc:
  filter:
  - '../examples/filters/insert\_document.rb'
  - '../examples/filters/capitalize\_first\_sentence.rb'
  from: markdown
  output: '../index.md'
  standalone: True
  to: markdown
title: 'Paru—Pandoc wrapped around in Ruby'
---

Paru 2.0 is incompatible with pandoc versions lower than 1.18.0. For
users of older versions of pandoc, please use paru 1.0. You find paru
1.0 among the releases.

Paru is free sofware. Paru is released under the GPL-3.0. You find
paru's source code here.

Introduction
============

PARU IS A SIMPLE RUBy wrapper around [pandoc](http://www.pandoc.org),
the great multi-format document converter. Paru supports automating
pandoc by writing ruby programs and [using pandoc in your ruby
programs](using_paru.html). Since version 0.1 it also supports [pandoc
filters](using_filters.html).

-   current version 0.2.0 (beta)
-   licence: GPL3

Get the code at <https://github.com/htdebeer/paru>.

Do note that Paru version 0.2.0 is incompatible with pandoc version &lt;
[1.18](http://pandoc.org/releases.html#pandoc-1.18-26-oct-2016). Use
Paru version 0.1.0 if you are using an older version of pandoc.

Installation
============

PARU IS INSTALLED THrough rubygems as follows:

``` {.bash}
gem install paru
```

You can also download the latest gem
[paru-0.2.0.gem](https://github.com/htdebeer/paru/blob/master/releases/paru-0.2.0.gem)
and install it by:

``` {.bash}
cd /directory/you/downloaded/the/gem
gem install paru-0.2.0.gem
```

Paru, obviously, requires pandoc. See
<http://pandoc.org/installing.html> about how to install pandoc on your
system and [pandoc's manual](http://pandoc.org/README.html) on how to
use pandoc.

Installation {#installation}
============

Usage
=====

Say hello to pandoc
-------------------

Automating the use of pandoc with paru
======================================

Writing and using pandoc filters with paru
==========================================

Putting it all together
=======================

What is next
============
