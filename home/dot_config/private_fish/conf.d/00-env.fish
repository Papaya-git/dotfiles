# Environment: fish equivalent of ~/.zshenv and ~/.zprofile.
# Read by every fish (interactive or not), before config.fish.

# --- Homebrew (frozen output of `brew shellenv fish`, so brew does not run on every shell)
# macOS (Apple Silicon) or Linux prefix; neither: no Homebrew.
for prefix in /opt/homebrew /home/linuxbrew/.linuxbrew
    if test -d $prefix
        set -gx HOMEBREW_PREFIX $prefix
        set -gx HOMEBREW_CELLAR $prefix/Cellar
        set -gx HOMEBREW_REPOSITORY $prefix
        fish_add_path --global --move --path $prefix/bin $prefix/sbin
        set -q INFOPATH; or set INFOPATH ''
        set -gx INFOPATH $prefix/share/info $INFOPATH
        break
    end
end
set -gx HOMEBREW_CASK_OPTS --appdir=$HOME/Applications

# --- mise in shims mode: no hook on every prompt (only the global mise config matters).
# Must be set here: Homebrew's vendor_conf.d activates mise before config.fish.
set -gx MISE_FISH_AUTO_ACTIVATE 0
fish_add_path --global --move --path $HOME/.local/share/mise/shims

# --- Direct git: /usr/bin/git is an Apple launcher (xcrun) that doubles the cost of every call
# (20 ms vs 10.5 ms, measured). The link points to the CommandLineTools git binary (macOS only);
# if the link is missing or broken, fish falls back to /usr/bin/git.
fish_add_path --global --move --path $HOME/.local/share/fish-git/bin

# --- Other paths. fish_add_path skips missing directories: without the tool, the line does nothing.
fish_add_path --global --path $HOMEBREW_PREFIX/opt/libpq/bin
fish_add_path --global --append --path $HOMEBREW_PREFIX/share/google-cloud-sdk/bin
fish_add_path --global --append --path $HOME/.orbstack/bin
