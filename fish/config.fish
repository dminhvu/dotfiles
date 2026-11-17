# Homebrew, only if it is installed
test -x /home/linuxbrew/.linuxbrew/bin/brew; and eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

fish_add_path -g ~/.local/bin

# Ubuntu ships bat as "batcat"
if command -q bat
    alias cat="bat"
else if command -q batcat
    alias cat="batcat"
end

# Typos from typing with Telex on
alias cleả="clear"

function git
    if test "$argv[1]" = "púh"
        command git push $argv[2..-1]
    else
        command git $argv
    end
end

# Machine-specific settings (not in the repo)
test -f ~/.config/fish/local.fish; and source ~/.config/fish/local.fish
