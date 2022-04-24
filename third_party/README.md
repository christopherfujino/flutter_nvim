# Third Party Git Submodules

All projects in this directory are copyrighted and licensed independently of
flutter_nvim. See the respective sources for individual copyright and licensing
information.

## Dev Setup

Run the script in ../tools/git-submodule-init.dart to ensure all Git submodules
are installed and up to date locally.

### Neovim

Neovim is built from HEAD.

Official instructions for building from source is located at ./neovim/README.md.

In short:

```
make CMAKE_BUILD_TYPE=RelWithDebInfo
```

Which will produce a binary in ./neovim/build/bin/nvim. This file should be
depended on via relative path, rather than installing to the system.

It should be invoked with `nvim --clean`, to ignore any local user config.
