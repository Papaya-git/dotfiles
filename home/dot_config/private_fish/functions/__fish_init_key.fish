function __fish_init_key --description 'Installed versions of zoxide and Starship, read without starting a process'
    # Under Homebrew the real path holds the version (…/Cellar/zoxide/0.9.8/bin/zoxide):
    # it changes on every `brew upgrade`. command -s and path resolve are fish builtins.
    path resolve (command -s zoxide starship)
end
