function fish-init-refresh --description 'Regenerate the cached init scripts (zoxide, Starship)'
    # Called by conf.d/10-tools.fish when one of the two programs changes version.
    set -l cache $HOME/.cache/fish-init
    mkdir -p $cache

    # Each script is written next to its target, then renamed: a failed generation keeps
    # the previous one, never an empty or half-written file.
    command -q zoxide; and zoxide init fish --cmd cd >$cache/zoxide.tmp; and mv $cache/zoxide.tmp $cache/zoxide.fish
    command -q starship; and starship init fish --print-full-init >$cache/starship.tmp; and mv $cache/starship.tmp $cache/starship.fish
    rm -f $cache/{zoxide,starship}.tmp

    set -U __fish_init_key (__fish_init_key)
end
