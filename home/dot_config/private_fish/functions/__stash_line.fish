function __stash_line --description 'Alt+O: put the line aside in history and clear it (Up brings it back)'
    set -l line (commandline)
    test -n "$line"; or return
    history append -- $line
    commandline ''
end
