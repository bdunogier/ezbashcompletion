eZ Bash Completion
==================

[![Analytics](https://ga-beacon.appspot.com/UA-52121860-1/ezbashcompletion/readme)](https://github.com/igrigorik/ga-beacon)

About
=====

This project aims at providing bash completion on eZ Publish command line scripts.

Author: Bertrand Dunogier <bertrand dot dunogier [at] gmail dot com>

Website: http://projects.ez.no/ezbashcompletion

Getting it
==========

Currently only available on http://github.com/bdunogier/bdbashcompletion.

You can either download a tarball, or clone the repository:

```bash
git clone git://github.com/bdunogier/ezbashcompletion.git extension/ezbashcompletion
```

Setting it up
=============

Very hackish for now, but fortunately simple:

ezp.php
-------
This script is the main wrapper script. It has two roles:

- provides the bash completion shell script with eZ Publish data: scripts list, arguments, etc
- gets called when commands are ran using the "ezp" executable, and transfers the command to the actual script

It needs to be available as 'ezp', without .php, through your $PATH, and to be executable:

    ```bash
    ln -s /path/to/ezbashcompletion/ezp.php /usr/local/bin/ezp
    chmod +x ezp
    ```

The ezp bash completion script
------------------------------

This is the shell script that will provide completion information. You just need to copy/symlink it to
/etc/bash_completion.d

    ```bash
    ln -s /path/to/ezpublish/extension/ezbashcompletion/bash_completion.sh /etc/bash_completion.d/ezp
    ```

Try
===
From anywhere within an eZ Publish instance, type ezp<space>, then two tabs. It should show you the list of available
commands. Type one of them (or part of one of them), and tab again: you should get the options:

```
ezp cache <tab><tab> => options !
```

How it works
============

ezp.php is a wrapper script that on one hand centralizes commands around a unique one, so that help can actually be
provided. It also provides the bash script with the list of commands (try php ezp.php scripts), and with their arguments
list (try php ezp.php args cache).

bash_completion.sh is the actual completion script. That stuff works in mysterious ways, and I'd rather not explain
right now...
