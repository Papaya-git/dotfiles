function __cd_down --description 'Shift+Down: pick a subdirectory with fzf and cd into it'
    set -l dir (find . -mindepth 1 -name .git -prune -o -type d -print 2>/dev/null | string replace -r '^\./' '' | fzf --height 40% --reverse --scheme=path)
    and cd -- $dir
    commandline -f repaint
end
