# Key bindings. Already provided by fish and not redefined here:
# Ctrl+/ undo, Alt+/ redo, Alt+Left/Right previous/next directory, Up history search.
# Option sends Alt through the terminal settings: iTerm ("fish" profile: Esc+, and "Apps can
# change how keys are reported" unchecked, otherwise fish 4.9 inserts the Option character),
# VS Code and Antigravity (terminal.integrated.macOptionIsMeta).

status is-interactive; or return

# fish's hook for user bindings: called after its default bindings and the whole configuration
# (fzf and reef included), and again on every bindings mode change (fish_vi_key_bindings…),
# so nothing overrides them.
function fish_user_key_bindings
    bind shift-left 'prevd >/dev/null; commandline -f repaint'
    bind shift-right 'nextd >/dev/null; commandline -f repaint'
    bind shift-up 'cd ..; commandline -f repaint'
    bind shift-down __cd_down
    bind alt-o __stash_line

    # Enter: fast path in front of reef (see functions/__fast_enter.fish). reef keeps its Enter
    # key; its function is wrapped so that it goes through the fast path first.
    # Only when both reef internals used here exist: otherwise reef stays untouched.
    if functions -q __reef_execute __reef_chain_enter; and not functions -q __reef_execute_orig
        functions -c __reef_execute __reef_execute_orig
        function __reef_execute
            __fast_enter
        end
    end
end
