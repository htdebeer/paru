---
title: Paru—PAndoc wrapped around in RUby
author: Huub de Beer
licence: GPL3
keywords:
- paru
- pandoc
- ruby
- filter
...

Paru is a simple ruby wrapper around [pandoc](http://www.pandoc.org), the
great multi-format document converter. Paru supports automating pandoc by
writing ruby programs and [using pandoc in your ruby programs](using_paru.html).
Since version 0.1 it also supports [pandoc filters](using_filters.html).

- current version 0.2.0 (beta)
- licence: GPL3

Get the code at <https://github.com/htdebeer/paru>.

Do note that Paru version 0.2.0 is incompatible with pandoc version <
[1.18](http://pandoc.org/releases.html#pandoc-1.18-26-oct-2016). Use Paru
version 0.1.0 if you are using an older version of pandoc.

# Installation

Paru is installed through rubygems as follows:

~~~ {.bash}
gem install paru
~~~

You can also download the latest gem
[paru-0.2.0.gem](https://github.com/htdebeer/paru/blob/master/releases/paru-0.2.0.gem)
and install it by:

~~~ {.bash}
cd /directory/you/downloaded/the/gem
gem install paru-0.2.0.gem
~~~

Paru, obviously, requires pandoc. See <http://pandoc.org/installing.html>
about how to install pandoc on your system and [pandoc's
manual](http://pandoc.org/README.html) on how to use pandoc.
