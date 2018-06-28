# zsh-notes

zsh-notes is a [zsh](http://www.zsh.org/) plugin inspired by
[terminal_velocity](https:/A/www.seanh.cc/terminal_velocity/). It provides a
fast interface to create and access a set of
[Markdown](https://en.wikipedia.org/wiki/Markdown) text files inside a
directory.

- [fzf](https://github.com/junegunn/fzf) is used for locating files. It
  will be searched in `${PATH}`.
- `${EDITOR}` is launched to view and edit files. Like most tools do,
  `${VISUAL}` will be tried as well, with `vi` as last fallback.

The plugin defines a Zle widgets:

- `notes-edit`: Opens the file selector, and invokes the text editor on the
  selected file or creates a new one.

and the following variables:

- `ZSH_NOTES_HOME`: Path to the directory containing Markdown text files.
  If unset, `~/Notes` will be used as the default.


## Installation

The plugin can be installed manually by obtaining a copy and sourcing it.
It is recommended to use a plugin manager, e.g. when using
[zplug](https://github.com/zplug/zplug):

```sh
zplug aperezdc/zsh-notes
```


## Configuration

By default the widgets defined by the plugin are not bound. A typical
configuration could be:

```sh
# Alt-N: Open the notes selector.
bindkey '\en' notes-edit
```

