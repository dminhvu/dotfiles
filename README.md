# dotfiles

My shell, git and VS Code setup for Ubuntu.

## Install

On a fresh Ubuntu machine, run:

```bash
wget -qO- https://raw.githubusercontent.com/dminhvu/dotfiles/main/install.sh | bash
```

It asks for the sudo password and, the first time, a git name and email. Run it again any time to update.

## What it sets up

- **fish** as the default shell, with [fisher](https://github.com/jorgebucaran/fisher) plugins: [Tide](https://github.com/IlanCosman/tide) prompt, nvm.fish, autopair, z, autovenv, sponge
- **Tide** prompt settings (`fish/tide.fish`)
- **Hack Nerd Font** for the terminal, **JetBrains Mono** for the editor
- **git**: auto upstream on push, `gh` as the GitHub credential helper; name and email go in `~/.gitconfig.local`
- **VS Code**: settings, keybindings and extensions (`vscode/`)

Files that already exist are backed up as `<file>.bak.<date>` before they are replaced.

Machine-only fish settings go in `~/.config/fish/local.fish` (not in this repo).
