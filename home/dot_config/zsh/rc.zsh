# Interactive zsh. fish is the everyday shell; zsh stays the login shell for the tools and the
# AI agents that need a POSIX shell. So: no alias (grep stays grep, cat stays cat), no plugin,
# no framework, a plain prompt. Commands behave as their documentation says.

# History, shared between sessions.
HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt share_history hist_ignore_dups hist_ignore_space

# Completion, with the cached dump (-C: no security scan of fpath on every start).
autoload -Uz compinit && compinit -C

# gpg asks for its passphrase on this terminal.
export GPG_TTY=$TTY

# Prompt: directory, then the status of the last command.
PROMPT='%F{blue}%~%f %(?.%F{green}.%F{red}[%?] )›%f '
