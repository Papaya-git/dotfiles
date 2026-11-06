function md --description 'mkdir -p, then cd' --argument-names dir
    test (count $argv) -eq 1; or begin
        echo 'usage: md <dir>' >&2
        return 1
    end
    mkdir -p -- $dir; and cd -- $dir
end
