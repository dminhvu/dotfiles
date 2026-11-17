#!/usr/bin/env bash
# One-command setup for a fresh Ubuntu machine:
#   wget -qO- https://raw.githubusercontent.com/dminhvu/dotfiles/main/install.sh | bash
# Safe to run again: it updates the repo and re-applies everything.
set -euo pipefail

REPO="https://github.com/dminhvu/dotfiles.git"
DIR="$HOME/.dotfiles"
STAMP="$(date +%Y%m%d-%H%M%S)"

say()  { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!! %s\033[0m\n' "$*"; }

# Copy a file into place; keep a backup if a different file is already there.
put() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && ! cmp -s "$src" "$dst"; then
    cp "$dst" "$dst.bak.$STAMP"
  fi
  cp "$src" "$dst"
}

say "Installing packages (asks for your sudo password once)"
sudo apt-get update -y
sudo apt-get install -y git curl wget unzip fontconfig fish bat gh fonts-jetbrains-mono

say "Getting the dotfiles repo into $DIR"
if [ -d "$DIR/.git" ]; then
  git -C "$DIR" pull --ff-only
else
  git clone --depth 1 "$REPO" "$DIR"
fi

say "Git config"
put "$DIR/git/gitconfig" "$HOME/.gitconfig"
put "$DIR/git/ignore"    "$HOME/.config/git/ignore"
if ! git config --file "$HOME/.gitconfig.local" user.email >/dev/null 2>&1; then
  read -rp "Git name for commits on this machine: "  GIT_NAME  < /dev/tty
  read -rp "Git email for commits on this machine: " GIT_EMAIL < /dev/tty
  git config --file "$HOME/.gitconfig.local" user.name  "$GIT_NAME"
  git config --file "$HOME/.gitconfig.local" user.email "$GIT_EMAIL"
fi

say "Hack Nerd Font (icons in the prompt)"
if ! fc-list | grep -qi "Hack Nerd Font"; then
  FONT_DIR="$HOME/.local/share/fonts/HackNerdFont"
  TMP="$(mktemp -d)"
  mkdir -p "$FONT_DIR"
  wget -qO "$TMP/Hack.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
  unzip -oq "$TMP/Hack.zip" '*.ttf' -d "$FONT_DIR"
  rm -rf "$TMP"
  fc-cache -f >/dev/null
fi

say "Terminal font"
if gsettings list-schemas 2>/dev/null | grep -qx org.gnome.Ptyxis; then
  gsettings set org.gnome.Ptyxis use-system-font false
  gsettings set org.gnome.Ptyxis font-name 'Hack Nerd Font Mono 11'
fi
if gsettings list-schemas 2>/dev/null | grep -qx org.gnome.Terminal.ProfilesList; then
  PROFILE="$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")"
  P="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE/"
  gsettings set "$P" use-system-font false
  gsettings set "$P" font 'Hack Nerd Font Mono 11'
fi

say "fish: config, plugins (fisher) and the Tide prompt"
put "$DIR/fish/config.fish"  "$HOME/.config/fish/config.fish"
put "$DIR/fish/fish_plugins" "$HOME/.config/fish/fish_plugins"
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source; and fisher update'
fish "$DIR/fish/tide.fish"

FISH_BIN="$(command -v fish)"
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$FISH_BIN" ]; then
  say "Making fish the default shell"
  sudo chsh -s "$FISH_BIN" "$USER"
fi

say "VS Code: settings, keybindings, extensions"
if ! command -v code >/dev/null 2>&1; then
  sudo snap install code --classic
fi
put "$DIR/vscode/settings.json"    "$HOME/.config/Code/User/settings.json"
put "$DIR/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
while read -r ext; do
  [ -z "$ext" ] && continue
  code --install-extension "$ext" --force >/dev/null 2>&1 || warn "could not install $ext"
done < "$DIR/vscode/extensions.txt"

say "Done. Log out and back in once so fish becomes your login shell."
echo "GitHub login for git push: gh auth login"
