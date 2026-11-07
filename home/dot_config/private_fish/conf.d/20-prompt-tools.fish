# Tool versions for the prompt, at no cost per prompt.
# Starship's language modules run `<tool> --version` on every prompt (node +137 ms, go +50 to
# +508 ms through the mise shims). Instead, on every directory change, the versions the project
# asks mise for are read from mise.toml / .tool-versions with fish builtins (no process), and
# exported in PROMPT_TOOLS, which starship.toml shows with an env_var module.
# Shown: the version the project declares, not the binary that runs (it may be missing).

status is-interactive; or return

function __prompt_tools --on-variable PWD --description 'Export the tool versions declared for mise in this directory'
    # Only these tools, with their icon; anything else in mise.toml (pre-commit…) is left out.
    set -l names node go python java rust ruby terraform opentofu bun deno
    set -l icons \U000f0399 \ue627 \ue606 \ue256 \ue7a8 \ue791 \U000f1062 \U000f1062 \ue76f \ue7c0
    set -l found
    set -l versions

    # From this directory up to /: the nearest declaration of a tool wins, as in mise.
    set -l dir $PWD
    while true
        for file in $dir/mise.toml $dir/.mise.toml $dir/.tool-versions
            test -f $file; or continue
            # mise.toml: only the [tools] table; .tool-versions: every line.
            set -l in_tools 0
            string match -q -- '*.tool-versions' $file; and set in_tools 1
            while read -l line
                if string match -qr '^\s*\[' -- $line
                    set in_tools 0
                    string match -qr '^\s*\[tools\]' -- $line; and set in_tools 1
                    continue
                end
                test $in_tools = 1; or continue
                # node = "24.12" | node = ["24", "22"] | node = { version = "24" } | node 24.12
                set -l kv (string match -rg '^\s*"?([\w.-]+)"?\s*(?:=\s*[\[{]?\s*(?:version\s*=\s*)?"([^"]+)"|\s+(\S+))' -- $line)
                set -q kv[1]; or continue
                set -l name $kv[1]
                set -l ver $kv[2]
                test -n "$ver"; or set ver $kv[3]
                contains -- $name $names; and not contains -- $name $found; or continue
                set -a found $name
                set -a versions $ver
            end <$file
        end
        test "$dir" = /; and break
        set dir (path dirname $dir)
    end

    # In the order of $names (no `seq`: it is an external program, a process per cd).
    set -l parts
    set -l i 0
    for name in $names
        set i (math $i + 1)
        set -l at (contains -i -- $name $found); or continue
        set -a parts "$icons[$i] $versions[$at]"
    end
    if set -q parts[1]
        set -gx PROMPT_TOOLS (string join '  ' $parts)
    else
        set -e PROMPT_TOOLS
    end
end
__prompt_tools
