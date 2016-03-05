For a programmer like me, the ability to add code blocks to pandoc, such as:

    for i := 0 to 10 do
        print i*i
    end

is very great. There are different types of code blocks. Above is the regular
one. There are also fenced code blocks, such as:

~~~~ {.javascript}
var i = 0;
while (i < 10) {
    i++;
    console.log(i);
}
~~~~~~

The important thing is to have a larger bottom fence than the top fence.
