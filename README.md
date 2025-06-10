# Custom ZSH Dotfiles

A lightweight, high-performance ZSH configuration with speed, transparency, and maintainability in mind.

## ✨ Features

- **🚀 Fast startup** (~50-100ms)
- **⭐ Starship prompt** - Modern, actively maintained, easy TOML configuration
- **🔍 Enhanced commands** - bat, eza, ripgrep, zoxide, LazyVim
- **🎯 Smart completion** - Auto-suggestions, syntax highlighting, fuzzy search
- **🌐 Cross-platform** - Works on macOS, Linux, WSL2, Windows
- **📦 No package manager** - Direct git clones for transparency
- **🛠️ Future-proof** - Detects 20+ languages and DevOps tools

## 🎯 What You Get

### Prompt & Shell
- **Starship** - 2-line prompt with comprehensive git status
- **Auto-suggestions** - Gray completions based on history
- **Syntax highlighting** - Real-time command coloring
- **History search** - Up/Down arrows for substring search
- **Directory bookmarks** - Save and jump to frequent locations

### Enhanced Commands
| Old Command | New Command | Description |
|-------------|-------------|-------------|
| `cat` | `bat` | Syntax highlighting, line numbers |
| `ls` | `eza` | Icons, git status, smart parameters |
| `vim` | `nvim` | Neovim with LazyVim configuration |
| `grep` | `rgrep` (ripgrep) | 10x faster text searching |
| `find` | `fd` | Faster, user-friendly file finder |
| `cd` | `z` (zoxide) | Smart directory jumping |

### Tool Detection
Automatically shows versions/status for:
- **Languages**: Python, Node.js, Go, Rust, Java, .NET, PHP, Ruby, Lua, Scala, Swift, Kotlin, Dart, Elixir, Haskell, Julia, Perl, Zig
- **DevOps**: Docker, Kubernetes, Helm, Terraform, Vagrant, Nix, Pulumi
- **Platform**: ArgoCD, Flux, Istio, Kustomize, Tekton, Crossplane
- **Cloud**: AWS, GCP, Azure, OpenStack

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Make scripts executable
chmod +x install.sh scripts/*.sh

# Run installation
./install.sh
```

## 📁 Repository Structure

```
dotfiles/
├── README.md                 # This file
├── install.sh               # Main installation script
├── zsh/
│   └── .zshrc              # ZSH configuration
├── starship/
│   └── starship.toml       # Starship prompt configuration
└── scripts/
    ├── setup-tools.sh      # External tools installation
    └── setup-lazyvim.sh    # LazyVim setup
```

## 🛠️ Installation Details

### Automatic Installation
- **Nerd Font** - FiraCode automatically installed
- **Starship** - Fast, cross-shell prompt
- **ZSH Plugins** - Auto-suggestions, syntax highlighting, history search
- **External Tools** - bat, eza, ripgrep, fd, fzf, zoxide
- **LazyVim** - Professional Neovim setup

### Supported Platforms
- **macOS** - via Homebrew
- **Linux** - Ubuntu, Debian, Arch, Fedora, openSUSE
- **WSL2** - Windows Subsystem for Linux
- **Windows** - PowerShell/winget instructions

## 🎮 Usage Examples

### Directory Navigation
```bash
# Traditional
cd ~/projects/my-app

# Smart jumping (after visiting once)
z my-app

# Bookmarks
bookmark save work        # Save current directory
bookmark go work          # Jump to saved directory
bookmark list             # List all bookmarks
j projects               # Zoxide fuzzy matching
```

### Kubernetes Workflow
```bash
k get pods               # kubectl with completion
k describe pod my-pod    # Describe resources
k logs -f my-pod         # Follow logs
k exec -it my-pod -- bash   # Execute into containers
```

### Enhanced File Operations
```bash
ls                       # eza with icons and git status
ll                       # Detailed list with git info
lt                       # Sort by modification time
tree                     # Directory tree view
cat file.py             # Syntax highlighted viewing
rgrep "function"        # Fast text search
```

### Fuzzy Search
```bash
Ctrl+R                  # Search command history
Ctrl+T                  # Search files
vim **<Tab>             # File completion with fzf
```

## ⚙️ Customization

### Starship Prompt
Edit `~/.config/starship.toml` to customize your prompt:

```toml
[directory]
style = "blue bold"

[git_branch]
symbol = " "

[character]
success_symbol = "[❯](green)"
error_symbol = "[❯](red)"
```

### Local Customizations
Create `~/.zshrc.local` for machine-specific settings that won't be tracked in git:

```bash
# Machine-specific aliases
alias deploy='kubectl apply -f k8s/'

# Environment variables
export KUBECONFIG=~/.kube/config

# Custom functions
work() { z ~/work/"$1" }
```

### Adding Tools
To add detection for new tools, edit `starship/starship.toml`:

```toml
[custom.mytool]
command = "mytool --version"
when = "command -v mytool"
symbol = "🔧 "
style = "bold blue"
format = "[$symbol($output )]($style)"
```

## 🔧 Troubleshooting

### Font Issues
If icons don't display correctly:
1. Ensure FiraCode Nerd Font is installed
2. Configure your terminal to use the font
3. Restart your terminal

### Slow Performance
If the shell feels slow:
1. Check which plugins are loaded: `zsh -xvs`
2. Remove unnecessary modules from `starship.toml`
3. Clear completion cache: `rm ~/.zcompdump*`

### Missing Tools
If commands aren't found:
1. Re-run: `./scripts/setup-tools.sh`
2. Check your PATH: `echo $PATH`
3. Manually install missing tools

## 🔄 Updates

### Update All Tools
```bash
cd ~/dotfiles

# Update ZSH plugins
git -C ~/.zsh-plugins/zsh-autosuggestions pull
git -C ~/.zsh-plugins/zsh-syntax-highlighting pull
git -C ~/.zsh-plugins/zsh-history-substring-search pull

# Update external tools (depends on your package manager)
brew upgrade              # macOS
sudo apt update && sudo apt upgrade  # Ubuntu/Debian
sudo pacman -Syu         # Arch
```

### Update Starship
```bash
# Most systems
starship init zsh --print-full-init > /dev/null

# Or reinstall
curl -sS https://starship.rs/install.sh | sh
```

## 📝 Migration from zsh4humans

### Backup First
The install script automatically backs up your current configuration to:
`~/.dotfiles-backup-YYYYMMDD-HHMMSS/`

### Prompt Migration
My previous powerlevel10k prompt style is replicated in `starship.toml` with:
- Same 2-line layout
- Comprehensive git status
- Tool detection
- Modern color scheme

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- [Starship](https://starship.rs/) - The fast, cross-shell prompt
- [LazyVim](https://lazyvim.org/) - Professional Neovim configuration
- [zsh4humans](https://github.com/romkatv/zsh4humans) - Inspiration for this setup
- All the amazing tool creators: bat, eza, ripgrep, fzf, zoxide

---

**Enjoy your blazing-fast, transparent, and maintainable ZSH setup! 🚀**