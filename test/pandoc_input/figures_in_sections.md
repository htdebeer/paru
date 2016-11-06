# Introduction

This is a test file for the filter `number_figures_per_chapter.rb`. See Figure
1.1 for an overview:

![This is the first](image.png)

This filter numbers both chapter headings as well as the figures per chapter.

# Second chapter

In the second chapter, there are two figures spread over two sub sections!

## A sub section

![This is the second](image.png)

## Another sub section

![This is the third](image.png)

# Third chapter

The third chapter does not have any figures, but the next one has two again!

# Conclusion

![This is the fourth](image.png)

It does not matter if there is text in between or not. Although without the
newlines in between the figures they are placed on one line when converting
back to markdown again. 

The fifth figure that follows is numbered correctly as well:

![This is the fifth](image.png)
