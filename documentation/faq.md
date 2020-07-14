Feel free to ask me a question: [send me an email](mailto:Huub@heerdebeer.org)
or submit a new [issue](https://github.com/htdebeer/paru/issues) if you've
found a bug! 

-   *I get an error like "Erro: JSON parse error: Error in $: Incompatible API
    versions: encoded with [1,20] but attempted to decode with [1,21]."*

    The versions of pandoc and paru you are using are incompatible. Please
    install the latest versions of pandoc and paru.

    Why does this happen? Internally pandoc uses
    [pandoc-types](https://hackage.haskell.org/package/pandoc-types) to
    represent documents its converts and filters. Documents represented by one
    version of pandoc-types are slightly incompatible with documents
    represented by another version of pandoc-types. This also means that filters
    written in paru for one version of pandoc-types are not guaranteed to work
    on documents represented by another version of pandoc-types. As a result,
    not all paru versions work together with all pandoc versions.

    As a general rule: Use the latest versions of pandoc and paru.

-   *I get an error like "'values_at': no implicit conversion of String into
    Integer (TypeError) from lib/paru/filter/document.rb:54:in 'from_JSON'"*

    The most likely cause is that you're using an old version of Pandoc. Paru
    version 0.2.x only supports pandoc version 1.18 and up. In pandoc version
    1.18 there was a breaking API change in the way filters worked. Please
    upgrade your pandoc installation.
