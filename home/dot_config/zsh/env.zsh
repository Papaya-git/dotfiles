# Environment for every zsh: interactive or not, scripts, and the shells AI agents run their
# commands in (Claude Code, Antigravity: they support bash and zsh, not fish).
# Sourced by ~/.zshenv, and again by ~/.zprofile after macOS path_helper reorders PATH.
# Same PATH as fish (fish/conf.d/00-env.fish), built from static paths: no program runs here.

# Each directory once; the first occurrence wins.
typeset -U path PATH

# --- Homebrew (frozen output of `brew shellenv zsh`): macOS (Apple Silicon) or Linux prefix.
for prefix in /opt/homebrew /home/linuxbrew/.linuxbrew; do
  if [[ -d $prefix ]]; then
    export HOMEBREW_PREFIX=$prefix
    export HOMEBREW_CELLAR=$prefix/Cellar
    export HOMEBREW_REPOSITORY=$prefix
    path=($prefix/bin $prefix/sbin $path)
    break
  fi
done
unset prefix
# Casks in ~/Applications: updates without admin rights.
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"

# --- In front of Homebrew, in this order (the same as fish):
#   ~/.local/bin                tools installed per user (Claude Code, Antigravity CLI)
#   libpq                       psql and the PostgreSQL client tools
#   ~/.local/share/fish-git/bin direct git binary (/usr/bin/git is an xcrun launcher, 2x slower)
#   mise shims                  tool versions from mise, without a hook on every prompt
path=(
  $HOME/.local/bin
  $HOMEBREW_PREFIX/opt/libpq/bin
  $HOME/.local/share/fish-git/bin
  $HOME/.local/share/mise/shims
  $path
)

# --- After everything else: gcloud components (gke-gcloud-auth-plugin...), OrbStack.
path+=(
  $HOMEBREW_PREFIX/share/google-cloud-sdk/bin
  $HOME/.orbstack/bin
)

# Missing directories are dropped: without the tool, its line does nothing.
path=($^path(N-/))

# --- AI agents (Claude Code sets CLAUDECODE, Antigravity ANTIGRAVITY_AGENT): no command waits
# for a keypress or a pager, and Homebrew neither updates itself nor prints hints.
if [[ -n ${CLAUDECODE-}${ANTIGRAVITY_AGENT-} ]]; then
  export PAGER=cat
  export GIT_PAGER=cat
  export HOMEBREW_NO_AUTO_UPDATE=1
  export HOMEBREW_NO_INTERACTIVE=1
  export HOMEBREW_NO_ENV_HINTS=1
fi

# Machine-specific settings, kept out of this repository (work tools, installers' lines).
[[ -r $HOME/.config/zsh/local.zsh ]] && source $HOME/.config/zsh/local.zsh
