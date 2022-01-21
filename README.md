# .bash

Handy bash shell aliases and functions that I've written/collected over the years.

These require bash version 4 or later.


## How can I update my Mac OS bash to the newest version?

First thing, you need to install [Homebrew](http://brew.sh/):

    $ ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"


Then you can use Homebrew to install bash:

    $ brew install bash


You must add `/usr/local/bin/bash` to the end of the `/etc/shells` file:

    $ sudo vi /etc/shells

so it should look something like this:

    # List of acceptable shells for chpass(1).
    # Ftpd will not allow users to connect who are not using
    # one of these shells.

    /bin/bash
    /bin/csh
    /bin/ksh
    /bin/sh
    /bin/tcsh
    /bin/zsh
    /usr/local/bin/bash

Then you need to change your preferred shell to the new bash:

    $ chsh -s /usr/local/bin/bash <username>


Now, any newly opened terminals should use the new bash by default, you can verify by running:

    $ bash --version


## To Install .bash

Just clone this repository into some directory, and then source it in your `.bash_aliases` or `.bash_profile` file

    source /path/to/repo/bash_profile.sh


## Goodness

### Background color

If you have sourced `navigation.sh` and you drop a `.bgcolor` file in a directory with a format like this:

    R G B

Where R, G, and B are integers between 1-255, then whenever you go into that directory, or a sub directory, the shell's background color will switch to the defined color. When you move out of that shell it will reset to whatever is defined in the environment variable `BGCOLOR_DEFAULT`.

You just have to add `bgcolor_auto` to your prompt:

    export PROMPT_COMMAND="$PROMPT_COMMAND;bgcolor_auto"


### TERM_TITLE

If you use `bashenv.sh` then you can override the default title of the term window using `TERM_TITLE` environment variable.

