function __fast_enter --description 'Enter: skip reef when the line is already valid fish'
    # reef runs `reef detect` (~7 ms) before every command to spot bash.
    # fish can tell without a process whether the line is valid: if so, run it directly
    # (still through reef's Enter chain, so Starship's transient prompt is kept).
    # Invalid or incomplete line, or `source file`: reef as usual.
    # Safety net: if __reef_chain_enter is gone, Enter runs the line as plain fish would.
    if not functions -q __reef_chain_enter
        commandline -f execute
        return
    end
    set -l line (commandline)
    if commandline --is-valid; and not string match -qr '^\s*(source|\.)\s' -- $line
        __reef_chain_enter
    else
        __reef_execute_orig
    end
end
