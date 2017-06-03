Paru is installed through rubygems as follows:

~~~ {.bash}
gem install paru
~~~

You can also download the latest gem
[paru-::paru::version.gem](https://github.com/htdebeer/paru/blob/master/releases/paru-::paru::version.gem)
and install it by:

~~~ {.bash}
cd /directory/you/downloaded/the/gem/to
gem install paru-::paru::version.gem
~~~

Paru, obviously, requires pandoc. See <http://pandoc.org/installing.html>
about how to install pandoc on your system and [pandoc's
manual](http://pandoc.org/README.html) on how to use pandoc.

You can generate the [API documentation for
paru](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/) by cloning the
repository and running `rake yard`. It'll put it in `documentation/api-doc`.
