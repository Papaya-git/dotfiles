# dotfiles

Shell configuration managed with [chezmoi](https://www.chezmoi.io/): fish + Starship, with the
tools wired into them, installed from a Brewfile.

## Set up a new machine

1. Install [Homebrew](https://brew.sh).
2. Add an SSH key for this GitHub account (alias `github.com-perso` in `~/.ssh/config`).
3. Clone and apply:

   ```sh
   brew install chezmoi
   git clone git@github.com-perso:Papaya-git/dotfiles.git ~/Documents/git/github/perso/dotfiles
   mkdir -p ~/.config/chezmoi
   echo "sourceDir = \"$HOME/Documents/git/github/perso/dotfiles\"" > ~/.config/chezmoi/chezmoi.toml
   chezmoi diff     # preview the changes
   chezmoi apply    # write the files, then install the Brewfile
   ```

4. macOS: Ghostty is the terminal (fish, font, theme and keys are set in its config). iTerm stays
   installed: in *Settings > Profiles*, make the **fish** profile the default one.
   VS Code and Antigravity: add a fish terminal profile (`/opt/homebrew/bin/fish --login`) and
   set `terminal.integrated.macOptionIsMeta: true`.

The login shell stays the system default: tools and agents expect a POSIX shell there.
fish only runs where you type (Ghostty, iTerm, the editor's terminal).

## Day to day

| Need | Command |
|---|---|
| Edit a managed file | `chezmoi edit <path>`, then `chezmoi apply` |
| Take back a change made in place | `chezmoi re-add <path>` |
| Manage a new file | `chezmoi add <path>` |
| See the differences | `chezmoi diff` |
| Pull changes made on another machine | `chezmoi update` |
| Commit and push | `chezmoi cd`, then git |
| Try another prompt theme | `prompt-theme` (list), `prompt-theme <name>`, `prompt-theme default` |
| Add or remove a fish plugin | edit `~/.config/fish/fish_plugins`, then `chezmoi apply` |

## Contents

| File | Purpose |
|---|---|
| `~/.config/fish/conf.d/` | environment, tools (zoxide, Starship), tool versions for the prompt, reef, abbreviations, key bindings |
| `~/.config/fish/functions/`, `completions/` | custom functions, one per file |
| `~/.config/fish/fish_plugins` | Fisher plugins (fzf.fish), installed by `fisher update` whenever the list changes |
| `~/.config/starship.toml` | prompt |
| `~/.config/starship/themes/` | other prompt themes, picked with `prompt-theme` |
| `~/.config/ghostty/config.ghostty` | terminal: fish, Nerd Font, Catppuccin theme, Option as Alt, Ctrl+C/Ctrl+V copy and paste |
| `~/.Brewfile` | packages, installed by `brew bundle --global --no-upgrade` whenever it changes |
| `~/.local/share/fish-git/bin/git` | macOS: link to the CommandLineTools git (twice as fast as `/usr/bin/git`) |
| `~/Library/…/DynamicProfiles/fish.json` | macOS: iTerm profile (Option sends Alt, Nerd Font) |

Deliberately left out: `~/.config/fish/config.fish` (installers append their own lines there;
machine-specific settings go there too), `fish_variables` (machine state), shell history,
`~/.ssh` and git identities.

## Linux

The fish files look for Homebrew under `/opt/homebrew` or `/home/linuxbrew/.linuxbrew`.
The iTerm profile and the git link are not written outside macOS (`.chezmoiignore`).
Without Homebrew (apt or dnf packages), the init cache cannot see version changes:
run `fish-init-refresh` after upgrading zoxide or Starship.
