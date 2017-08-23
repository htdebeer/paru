Feel free to ask me a question: [send me an email](mailto:Huub@heerdebeer.org)
or submit a new [issue](https://github.com/htdebeer/paru/issues) if you've
found a bug! 

-   *I get an error like "'values_at': no implicit conversion of String into
    Integer (TypeError) from lib/paru/filter/document.rb:54:in 'from_JSON'"*

    The most likely cause is that you're using an old version of Pandoc. Paru
    version 0.2.x only supports pandoc version 1.18 and up. In pandoc version
    1.18 there was a breaking API change in the way filters worked. Please
    upgrade your pandoc installation.
