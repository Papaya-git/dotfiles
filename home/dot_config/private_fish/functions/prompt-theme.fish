function prompt-theme --description 'Switch the Starship theme in every open shell (no argument: list them)'
    # Catppuccin Powerline preset: one theme per palette, generated from the installed
    # Starship, so it follows its upgrades. Custom themes: ~/.config/starship/themes/*.toml.
    # "default" goes back to ~/.config/starship.toml.
    set -l palettes mocha:catppuccin_mocha macchiato:catppuccin_macchiato frappe:catppuccin_frappe \
        latte:catppuccin_latte ayu-dark:ayu_dark ayu-mirage:ayu_mirage ayu-light:ayu_light
    set -l themes $HOME/.config/starship/themes
    set -l custom (path change-extension '' (path basename $themes/*.toml))

    if not set -q argv[1]
        set -l current default
        set -q STARSHIP_CONFIG; and set current (path change-extension '' (path basename $STARSHIP_CONFIG))
        printf 'current: %s\n\n' $current
        printf 'default\n'
        printf 'catppuccin-powerline/%s\n' (string split -f1 : $palettes)
        printf '%s\n' $custom
        return
    end

    set -l name $argv[1]
    if test "$name" = default
        set -eU STARSHIP_CONFIG
        set -eg STARSHIP_CONFIG
        return 0
    end

    if contains -- $name $custom
        set -Ux STARSHIP_CONFIG $themes/$name.toml
        return
    end

    for entry in $palettes
        set -l pair (string split : $entry)
        test "catppuccin-powerline/$pair[1]" = "$name"; or continue
        set -l dir $HOME/.cache/starship-themes
        set -l file $dir/catppuccin-powerline-$pair[1].toml
        mkdir -p $dir
        # Written next to its target, then renamed: never a half-written theme.
        starship preset catppuccin-powerline \
            | string replace -r "^palette = .*" "palette = '$pair[2]'" >$file.tmp
        and mv $file.tmp $file
        or begin
            rm -f $file.tmp
            echo "prompt-theme: could not generate $name" >&2
            return 1
        end
        set -Ux STARSHIP_CONFIG $file
        return
    end

    echo "prompt-theme: unknown theme '$name' (run prompt-theme to list them)" >&2
    return 1
end
