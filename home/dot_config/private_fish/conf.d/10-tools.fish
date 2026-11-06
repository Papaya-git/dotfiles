# Interactive tools: zoxide, fzf, Starship.
# Their init scripts are cached in ~/.cache/fish-init (otherwise each one starts its program
# on every shell: ~30 ms in total). Regenerated automatically when one of them changes
# version (brew upgrade); by hand: `fish-init-refresh`.

status is-interactive; or return

set -l cache $HOME/.cache/fish-init
set -l key (__fish_init_key)
if test "$key" != "$__fish_init_key"; or not test -f $cache/starship.fish
    fish-init-refresh
end
for script in zoxide fzf starship
    # zoxide: smart cd + cdi; fzf: Ctrl+R, Ctrl+T, Alt+C; starship: the prompt
    test -f $cache/$script.fish; and source $cache/$script.fish
end

# Transient prompt: once run, a command line keeps only a "❯".
# Fixed text, so starship does not run again on every Enter.
function starship_transient_prompt_func
    set_color green; echo -n '❯ '; set_color normal
end
enable_transience

# bat preview in Ctrl+R
set -gx FZF_CTRL_R_OPTS "--preview 'echo {} | bat --color=always --language=sh --style=plain' --preview-window=down:6:wrap"

# zsh's glob_dots has no fish equivalent: `*` always skips hidden files. To include them: {.,}*
