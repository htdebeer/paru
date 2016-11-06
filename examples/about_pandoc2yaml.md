---
title: Extracting YAML metadata from a pandoc markdown file
author: Huub de Beer
keywords:
- pandoc
- paru
- YAML
...

To extract the [YAML](http://yaml.org/) metadata from a pandoc markdown file,
use the `pandoc2yaml.rb` script. Its usage is straigthforward: it expects one
pandoc markdown file as input and outputs all the metadata in it as YAML. For
example, you can run this file through `pandoc2yaml.rb` as follows:

~~~{.bash}
pandoc2yaml.rb about_pandoc2yaml.md
~~~

which will return the following YAML:

~~~{.yaml}
---
author: Huub de Beer
keywords:
- pandoc
- paru
- YAML
title: Extracting YAML metadata from a pandoc markdown file
...
~~~

Do note that in the output the YAML properties are ordered alphanumeric,
whereas they are not in the input document.
