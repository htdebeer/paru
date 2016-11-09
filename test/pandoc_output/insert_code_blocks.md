When writing a programming manual or tutorial, inserting working code is
a hassle. It would be great if you could insert a code block by pointing
pandoc to a path. With `insert_code_block.rb` you can do so. For
example, you insert the code of that filter here as follows:

``` {..ruby}
#!/usr/bin/env ruby
require_relative "../../lib/paru/filter"

Paru::Filter.run do 
  with "CodeBlock" do |code_block|
    command, path, *classes = code_block.string.strip.split " "
    if command == "::paru::insert"
      code_block.string = File.read path.gsub(/\\_/, "_")
      classes.each {|c| code_block.attr.classes.push c}
    end
  end
end
```

That is, you use the pseudo command `::paru::insert` followed by a path
to the file you want to insert, and some optional classes to add to the
code block. This is great if you want to add code highlighting in some
output formats.

One thing to keep in mind is to have the path start at the directory you
will run the script from. Otherwise it cannot find the file to insert
