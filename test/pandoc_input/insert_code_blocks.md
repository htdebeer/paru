When writing a programming manual or tutorial, inserting working code is a
hassle. It would be great if you could insert a code block by pointing pandoc
to a path. With `insert_code_block.rb` you can do so. For example, you insert
the code of that filter here as follows:

    ::paru::insert test/filters/insert_code_block.rb .ruby

That is, you use the pseudo command `::paru::insert` followed by a path to the
file you want to insert, and some optional classes to add to the code block.
This is great if you want to add code highlighting in some output formats.

One thing to keep in mind is to have the path start at the directory you will
run the script from. Otherwise it cannot find the file to insert
