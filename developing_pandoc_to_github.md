---
title: Converting pandoc markdown files to github flavored ones
author: Huub de Beer
keywords:
- pandoc
- markdown
- github
...

# Introduction

Currently I often write documentation of my software in pandoc's markdown
format. It would be great if I could convert that documentation into a
README.md that Github likes for a projects' landing page. Fortunately, pandoc
supports multiple markdown writers (and readers)—run `pandoc
--list-input-formats` or `pandoc --list-output-formats` to find out which
readers and writers and flavors pandoc supports—, among which is a Github
flavored one. However, running `pandoc --from markdown --to markdown_github -o
README.md index.md` does not give the expected result: all of pandoc's
metadata is ignored! The resulting Github markdown file does not have a title,
author, or list of keywords. 
