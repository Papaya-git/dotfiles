# Unknown command: reef first (bash translation, then running through bash), as it intends;
# if the command really does not exist, suggest the Homebrew formula that provides it.
# This file shadows reef's: reef's handler is loaded under another name so it can be called.

set -l reef_cnf $HOMEBREW_PREFIX/share/fish/vendor_functions.d/fish_command_not_found.fish
if test -f $reef_cnf
    string replace -- 'function fish_command_not_found' 'function __reef_command_not_found' <$reef_cnf | source
end

function fish_command_not_found
    if functions -q __reef_command_not_found
        __reef_command_not_found $argv
        set -l code $status
        test $code -ne 127; and return $code
    else
        __fish_default_command_not_found_handler $argv
    end
    command -q brew; or return 127
    set -l formulae (brew which-formula $argv[1] 2>/dev/null)
    test -n "$formulae"; and printf 'Provided by Homebrew: brew install %s\n' $formulae >&2
    return 127
end
