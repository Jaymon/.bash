# .bash

Handy bash shell aliases and functions that I've written/collected over the years

These require bash version 4 or later

## How can update my Mac OS bash to the newest version?

First thing, you need to install [Homebrew](http://brew.sh/):

    $ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


Then you can use Homebrew to install bash:

    $ brew install bash


You must add `/usr/local/bin/bash` to the end of the `/etc/shells` file:

    $ sudo vi /etc/shells


Then you need to change your preferred shell to the new bash:

    $ chsh -s /usr/local/bin/bash <username>


Now, any newly opened terminals should use the new bash by default, you can verify by running:

$ bash --version


## To Install .bash

Just clone this repository into some directory, and then source it in your `.bash_aliases` or `.bash_profile` file

    . /path/to/repo/all.sh


Usually, I do a little more checking:

```sh
# source my common library of bash things
if [ -f ~/.bash/all.sh ]; then
  . ~/.bash/all.sh
fi
```

If you only want specific file, say just the utility functions:

    . /path/to/repo/util.sh

That's it! If you have sourced `all.sh`, you can see all the new commands you have at any time by running:

    $ ?

Yup, just the question mark. That should print out a helpful menu of all the commands available (remember, this only works if you sourced `all.sh`).

