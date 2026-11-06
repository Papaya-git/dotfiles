# Abbreviations: expanded on screen before running, so history keeps the real command.
# Caveat: rg does not read grep's options the same way (rg -r = replace);
# an abbreviation only expands on a typed command, not on a pasted one.

status is-interactive; or return

abbr -a ls 'eza --icons --git -F'
abbr -a ll 'eza -l --icons --git'
abbr -a la 'eza -la --icons --git'
abbr -a tree 'eza --tree'
abbr -a cat 'bat --paging=never'
abbr -a grep rg
abbr -a du dust
abbr -a df duf
