# ~/.zshrc - ZSH Configuration with Oh My Posh

# Ensure PATH includes local binaries
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

#=== OH MY POSH PROMPT ===
if command -v oh-my-posh >/dev/null 2>&1; then
    # Use current theme if it exists, otherwise fall back to default
    if [[ -f "$HOME/.config/oh-my-posh/current.omp.json" ]]; then
        eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/current.omp.json)"
    else
        eval "$(oh-my-posh init zsh)"
    fi
fi

#=== OH MY POSH THEME SWITCHER ===
omp_theme() {
    local themes_dir="$HOME/.config/oh-my-posh/themes"
    local config_file="$HOME/.config/oh-my-posh/current.omp.json"
    
    case "$1" in
        list|ls)
            echo "🎨 Available themes:"
            if [[ -d "$themes_dir" ]]; then
                ls -1 "$themes_dir"/*.omp.json 2>/dev/null | xargs -I {} basename {} .omp.json | sort
            fi
            echo ""
            if [[ -f "$config_file" ]]; then
                echo "📁 Current theme: $(basename "$(readlink -f "$config_file" 2>/dev/null || echo "$config_file")" .omp.json)"
            else
                echo "📁 No theme currently set"
            fi
            ;;
        test|try)
            if [[ -z "$2" ]]; then
                echo "❌ Usage: omp_theme test <theme_name>"
                echo "💡 Use 'omp_theme list' to see available themes"
                return 1
            fi
            
            local theme_file="$themes_dir/$2.omp.json"
            if [[ -f "$theme_file" ]]; then
                echo "🧪 Testing theme: $2"
                echo "   Press Ctrl+C to stop, or run 'omp_theme set $2' to make permanent"
                eval "$(oh-my-posh init zsh --config "$theme_file")"
            else
                echo "❌ Theme '$2' not found in $themes_dir"
                echo "💡 Try downloading it first or check available themes with 'omp_theme list'"
            fi
            ;;
        set|save)
            if [[ -z "$2" ]]; then
                echo "❌ Usage: omp_theme set <theme_name>"
                return 1
            fi
            
            local theme_file="$themes_dir/$2.omp.json"
            if [[ -f "$theme_file" ]]; then
                # Backup current theme if it exists
                [[ -f "$config_file" ]] && cp "$config_file" "$config_file.backup.$(date +%Y%m%d-%H%M%S)"
                
                # Set new theme
                cp "$theme_file" "$config_file"
                echo "✅ Theme '$2' set as default"
                echo "🔄 Restart your terminal or run 'source ~/.zshrc' to apply"
            else
                echo "❌ Theme '$2' not found"
            fi
            ;;
        restore|reset)
            local backup_file=$(ls -t "$config_file".backup.* 2>/dev/null | head -1)
            if [[ -n "$backup_file" ]]; then
                cp "$backup_file" "$config_file"
                echo "✅ Restored previous theme from: $(basename "$backup_file")"
                echo "🔄 Restart your terminal or run 'source ~/.zshrc' to apply"
            else
                echo "❌ No backup found"
            fi
            ;;
        download)
            echo "📥 Downloading official Oh My Posh themes..."
            mkdir -p "$themes_dir"
            
            # Download all official themes
            curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/contents/themes | \
                grep download_url | \
                grep "\.omp\.json" | \
                cut -d '"' -f 4 | \
                xargs -I {} wget -q -P "$themes_dir" {}
            
            echo "✅ Downloaded $(ls -1 "$themes_dir"/*.omp.json 2>/dev/null | wc -l) themes"
            echo "💡 Use 'omp_theme list' to see all available themes"
            ;;
        random)
            local available_themes=($(ls -1 "$themes_dir"/*.omp.json 2>/dev/null | xargs -I {} basename {} .omp.json))
            if [[ ${#available_themes[@]} -gt 0 ]]; then
                local random_theme=${available_themes[$RANDOM % ${#available_themes[@]}]}
                echo "🎲 Randomly selected: $random_theme"
                omp_theme test "$random_theme"
            else
                echo "❌ No themes available. Run 'omp_theme download' first."
            fi
            ;;
        *)
            echo "🎨 Oh My Posh Theme Manager"
            echo ""
            echo "Usage: omp_theme <command> [theme_name]"
            echo ""
            echo "Commands:"
            echo "  list, ls          Show available themes"
            echo "  download          Download all official themes"
            echo "  test, try <name>  Test a theme temporarily"
            echo "  set, save <name>  Set theme as default"
            echo "  restore, reset    Restore previous theme"
            echo "  random            Try a random theme"
            echo ""
            echo "Examples:"
            echo "  omp_theme download"
            echo "  omp_theme list"
            echo "  omp_theme test agnoster"
            echo "  omp_theme set catppuccin"
            echo "  omp_theme random"
            ;;
    esac
}

#=== HISTORY ===
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

# History options
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_IGNORE_SPACE      # Don't save commands starting with space
setopt HIST_IGNORE_DUPS       # Don't save duplicate commands
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicates
setopt HIST_SAVE_NO_DUPS      # Don't write duplicates to history file
setopt HIST_VERIFY            # Show command before executing from history
setopt EXTENDED_HISTORY       # Save timestamp and duration
setopt INC_APPEND_HISTORY     # Append to history file immediately

#=== ZSH OPTIONS ===
setopt AUTO_CD               # cd by typing directory name
setopt CORRECT               # Command correction
setopt AUTO_PUSHD            # Push directories to stack
setopt PUSHD_IGNORE_DUPS     # Don't push duplicates
setopt PUSHD_MINUS           # Make cd -1 work like cd +1

#=== PLUGINS ===
ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"

# Additional completions (load before compinit)
if [[ -d "$ZSH_PLUGINS_DIR/zsh-completions/src" ]]; then
    fpath=("$ZSH_PLUGINS_DIR/zsh-completions/src" $fpath)
fi

# Auto-suggestions (gray suggestions as you type)
if [[ -f "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
fi

# History substring search (up/down arrow search)
if [[ -f "$ZSH_PLUGINS_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh" ]]; then
    source "$ZSH_PLUGINS_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh"
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
fi

# Syntax highlighting (load last)
if [[ -f "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

#=== COMPLETION ===
autoload -Uz compinit

# Load completions efficiently
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

#=== KUBECTL COMPLETION ===
# Enable kubectl completion
if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion zsh)
    # Enable completion for 'k' alias
    complete -F __start_kubectl k
fi

#=== FZF (Fuzzy Finder) ===
if command -v fzf >/dev/null 2>&1; then
    # Try the new --zsh flag first, fallback to traditional setup
    if fzf --zsh >/dev/null 2>&1; then
        source <(fzf --zsh)
    else
        # Fallback for older FZF versions
        [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
        [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
        [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
        
        # Manual key bindings if nothing else works
        if ! bindkey | grep -q "fzf"; then
            bindkey '^T' fzf-file-widget 2>/dev/null || true
            bindkey '^R' fzf-history-widget 2>/dev/null || true
            bindkey '\ec' fzf-cd-widget 2>/dev/null || true
        fi
    fi
    
    # FZF options
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    
    # Use ripgrep if available
    if command -v rg >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
fi

#=== ZOXIDE (Smart cd) ===
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

#=== DIRECTORY BOOKMARKS ===
mkdir -p ~/.bookmarks

bookmark() {
    case "$1" in
        save)   echo "$PWD" > ~/.bookmarks/"$2" && echo "📁 Saved '$2'" ;;
        go)     [[ -f ~/.bookmarks/"$2" ]] && cd "$(cat ~/.bookmarks/"$2")" || echo "❌ '$2' not found" ;;
        list)   echo "📚 Bookmarks:" && ls -1 ~/.bookmarks/ 2>/dev/null || echo "No bookmarks" ;;
        delete) [[ -f ~/.bookmarks/"$2" ]] && rm ~/.bookmarks/"$2" && echo "🗑️  Deleted '$2'" || echo "❌ '$2' not found" ;;
        *)      echo "Usage: bookmark {save|go|list|delete} [name]" ;;
    esac
}

#=== ENHANCED COMMANDS ===
# Conditional aliases (only if tools are available)
command -v bat >/dev/null 2>&1 && alias cat='bat --paging=never'
command -v bat >/dev/null 2>&1 && alias catp='bat'
command -v nvim >/dev/null 2>&1 && alias vim='nvim' || alias vim='vim'
command -v rg >/dev/null 2>&1 && alias rgrep='rg' || alias rgrep='grep'
command -v fd >/dev/null 2>&1 && alias find='fd'

# Smart ls replacement with eza
if command -v eza >/dev/null 2>&1; then
    ls() {
        if [[ $# -eq 0 ]]; then
            eza --group-directories-first --icons
        elif [[ "$1" == "-la" ]] || [[ "$1" == "-al" ]] || [[ "$1" == "-l" && "$2" == "-a" ]]; then
            eza -la --group-directories-first --git --icons --header
        elif [[ "$1" == "-l" ]]; then
            eza -l --group-directories-first --git --icons --header
        elif [[ "$1" == "-a" ]]; then
            eza -a --group-directories-first --icons
        else
            eza "$@" --group-directories-first --icons
        fi
    }
    
    # Additional ls variants
    alias ll='eza -la --group-directories-first --git --icons --header'
    alias la='eza -la --group-directories-first --icons'
    alias lt='eza -la --sort=modified --group-directories-first --git --icons --header'
    alias tree='eza --tree --icons'
else
    # Fallback to regular ls with colors
    alias ll='ls -la --color=auto'
    alias la='ls -la --color=auto'
    alias lt='ls -lat --color=auto'
fi

#=== SHORTCUTS ===
# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
command -v zoxide >/dev/null 2>&1 && alias j='z'

# Kubernetes (with kubectl completion enabled above)
alias k='kubectl'

# Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dexec='docker exec -it'
alias dlogs='docker logs -f'

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# GCP
alias gcl='gcloud config list'
alias gcp='gcloud config set project'
alias gcr='gcloud config set compute/region'
alias gcz='gcloud config set compute/zone'

# Quick edits
alias zshconfig='${EDITOR:-nano} ~/.zshrc'
alias ompconfig='${EDITOR:-nano} ~/.config/oh-my-posh/current.omp.json'
alias nvimconfig='${EDITOR:-nano} ~/.config/nvim/init.lua'

#=== LOCAL CUSTOMIZATIONS ===
# Load machine-specific settings (create this file for local customizations)
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local