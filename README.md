eZ Bash Completion
==================

About
=====

This project aims at providing bash completion on eZ Publish command line scripts.

Author: Bertrand Dunogier <bertrand dot dunogier [at] gmail dot com>

Website: http://projects.ez.no/ezbashcompletion

Getting it
==========

Currently only available on http://github.com/bdunogier/ezbashcompletion.

You can either download a tarball, or clone the repository:

```bash
git clone git://github.com/bdunogier/ezbashcompletion.git extension/ezbashcompletion
```

Setting it up
=============

Very hackish for now, but fortunately simple:

1. Symlink (or copy...) the ezp.php script to your ezpublish root:

    ```bash
    ln -s extension/ezbashcompletion/ezp.php ezp.php
    ```

2. Symlink (or copy...) the bash_completion.sh script to /etc/bash_completion.d/ezp

    ```bash
    ln -s /path/to/ezpublish/extension/ezbashcompletion/bash_completion.sh /etc/bash_completion.d/ezp
    ```

3. Either create an alias, or symlink **ezp.php** to your **/usr/local/bin** folder, as *ezp*:

    ```bash
    sudo ln -s /path/to/ezpublish/ezp.php /usr/local/bin/ezp
    ```

4. Make /usr/local/bin/ezp executable:

    ```bash
    sudo chmod +x /usr/local/bin/ezp
    ```

Try
===
From your eZ Publish root, type ezp<space>, then two tabs. It should show you the list of available commands. Type one
of them (or part of one of them), and tab again: tadaa, you should get the options:

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