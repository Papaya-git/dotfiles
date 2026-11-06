function zmv --description 'Pattern-based rename, delegated to zsh zmv (e.g. zmv "(*).txt" "\$1.md")'
    zsh -fc 'autoload -Uz zmv; zmv "$@"' zmv $argv
end
