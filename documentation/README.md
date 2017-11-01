# Introduction

Paru is a simple Ruby wrapper around {pandoc}[http://www.pandoc.org], the
great multi-format document converter. Paru supports automating pandoc by
writing Ruby programs and using pandoc in your Ruby programs. Paru also
supports writing pandoc filters in Ruby. In the {user
manual}[https://heerdebeer.org/Software/markdown/paru/] the use of paru is
explained in detail, from explaining how to install and use paru, creating and
using filters, to putting it all together in a real-world use case: generating
that manual!

In this document, however, you will find the API documentation.

# Using paru

## Creating a pandoc converter in Ruby wit paru

For automating the use of pandoc, see the {Paru::Pandoc} class on how to
create, configure, and run a pandoc converter in Ruby. Using Paru in this
regard is quite straightforward. For example, to convert the markdown string
+"Hello world, from **pandoc**"+ to HTML you can write the following Ruby
program:

{include:file:examples/hello_world.rb}

## Creating a pandoc filter in Ruby with paru

For writing pandoc filters in Ruby, see the {Paru::Filter} class. In a filter,
you can select pandoc nodes and specify an action to perform on each
selection. In a filter action, you usually manipulate the selected
{Paru::PandocFilter::Node}s.

For eample, to delete all horizontal lines in a document you might specify the
following filter:

{include:file:examples/filters/delete_horizontal_rules.rb}

# Installation

Paru is installed via Rubygems:

    gem install paru

You can also download the paru gem through its {github
repository}[delete_horizontal_rules].

# License

Copyright 2015, 2016, 2017 Huub de Beer <Huub@heerdebeer.org>

This file is part of Paru

Paru is free software: you can redistribute it and/or modify it under the
terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

Paru is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
details.

You should have received a copy of the GNU General Public License along with
Paru.  If not, see <http://www.gnu.org/licenses/>.
