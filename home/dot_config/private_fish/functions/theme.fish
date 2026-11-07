function theme --description 'Switch the colour theme of the prompt, Ghostty, fish, bat and fzf (no argument: list)'
    # The themes are defined once in the dotfiles (.chezmoidata.toml, starship palettes); the
    # chosen one is kept in chezmoi's local config ([data] theme), then `chezmoi apply` rewrites
    # every file that depends on it.
    set -l themes (chezmoi execute-template '{{ range $name, $_ := .themes }}{{ $name }}{{ "\n" }}{{ end }}')
    set -l current (chezmoi execute-template '{{ .theme }}')

    if not set -q argv[1]
        for name in $themes
            test "$name" = "$current"; and echo "$name (current)"; or echo $name
        end
        return
    end

    set -l name $argv[1]
    if not contains -- $name $themes
        echo "theme: unknown theme '$name' (run theme to list them)" >&2
        return 1
    end

    # [data] theme = "<name>" in chezmoi.toml, the rest of the file unchanged.
    set -l config $HOME/.config/chezmoi/chezmoi.toml
    set -l lines
    test -f $config; and while read -l line
        string match -qr '^\s*theme\s*=' -- $line; or set -a lines $line
    end <$config
    contains -- '[data]' $lines; or set -a lines '[data]'
    set -l at (contains -i -- '[data]' $lines)
    set lines $lines[1..$at] "theme = \"$name\"" $lines[(math $at + 1)..-1]
    # Written next to the file, then renamed: never a half-written config.
    printf '%s\n' $lines >$config.tmp; and mv $config.tmp $config; or begin
        rm -f $config.tmp
        return 1
    end

    chezmoi apply; or return 1

    # Already applied everywhere (prompt, fish colours, bat); fzf colours here, other open shells
    # at their next start; Ghostty on reload.
    set -gx FZF_DEFAULT_OPTS (chezmoi execute-template '{{ (index .themes .theme).fzf }}')
    echo "Theme: $name. Ghostty: Cmd+Shift+, to reload its config."
end
