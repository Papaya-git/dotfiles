function __fish_init_key --description 'Installed versions of zoxide, fzf and Starship, read without starting a process'
    # Under Homebrew the real path holds the version (…/Cellar/fzf/0.74.5/bin/fzf):
    # it changes on every `brew upgrade`. command -s and path resolve are fish builtins.
    path resolve (command -s zoxide fzf starship)
end
