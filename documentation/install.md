Paru is installed through rubygems as follows:

~~~ {.bash}
gem install paru
~~~

You can also build and install the latest version gem yourself by running the
following commands:

~~~bash
cd /path/to/paru/repository
bundle install
rake build
gem install pkg/paru-::paru::version.gem
~~~

Paru, obviously, requires pandoc. See <https://pandoc.org/installing.html>
about how to install pandoc on your system and [pandoc's
manual](https://pandoc.org/README.html) on how to use pandoc.

You can generate the [API documentation for
paru](https://heerdebeer.org/Software/markdown/paru/documentation/api-doc/) by cloning the
repository and running `rake yard`. It'll put it in `documentation/api-doc`.
