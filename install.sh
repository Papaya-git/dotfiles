#!/bin/bash

set -e

echo "🚀 Setting up your shell environment with Oh My Posh..."
echo ""
echo "This will install and configure:"
echo "  ✅ ZSH shell"
echo "  ✅ Oh My Posh prompt with Gruvbox theme"
echo "  ✅ Essential development tools"
echo "  ✅ ZSH plugins (autosuggestions, syntax highlighting)"
echo "  ✅ Enhanced CLI tools (bat, eza, ripgrep, fzf, zoxide)"
echo "  ✅ LazyVim (Neovim configuration)"
echo "  ✅ FiraCode Nerd Font"
echo ""

# Detect OS and architecture
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)
            if [[ -f /proc/version ]] && grep -q Microsoft /proc/version; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *) echo "unknown" ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64) echo "x64" ;;
        arm64|aarch64) echo "arm64" ;;
        armv7l) echo "arm" ;;
        *) echo "unknown" ;;
    esac
}

detect_linux_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    elif [[ -f /etc/arch-release ]]; then
        echo "arch"
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
ARCH=$(detect_arch)
DISTRO=""

if [[ "$OS" == "linux" ]] || [[ "$OS" == "wsl" ]]; then
    DISTRO=$(detect_linux_distro)
fi

echo "🔍 Detected: $OS${DISTRO:+ ($DISTRO)} ($ARCH)"

# Confirm installation
read -p "Ready to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Installation cancelled"
    exit 1
fi

# Create backup directory
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "📦 Creating backup directory: $BACKUP_DIR"

# Backup existing files
backup_file() {
    local file="$1"
    if [[ -f "$HOME/$file" ]]; then
        echo "📦 Backing up existing $file"
        cp "$HOME/$file" "$BACKUP_DIR/"
    fi
}

backup_file ".zshrc"
backup_file ".zshenv"
backup_file ".zprofile"
backup_file ".bashrc"
backup_file ".bash_profile"

# Check if we're in the dotfiles directory
check_dotfiles_structure() {
    local required_files=("zsh/.zshrc")
    local missing_files=()
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        echo "❌ Missing required files in dotfiles repository:"
        for file in "${missing_files[@]}"; do
            echo "   - $file"
        done
        echo ""
        echo "Please ensure you're running this script from your dotfiles directory"
        echo "and that all required files are present."
        exit 1
    fi
}

# Install system dependencies
install_system_deps() {
    echo "📦 Installing system dependencies..."
    
    case $OS in
        macos)
            # Install Xcode command line tools if not present
            if ! command -v git >/dev/null 2>&1; then
                echo "Installing Xcode command line tools..."
                xcode-select --install
                echo "Please complete Xcode installation and re-run this script"
                exit 1
            fi
            
            # Install Homebrew if not present
            if ! command -v brew >/dev/null 2>&1; then
                echo "📦 Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add Homebrew to PATH
                if [[ -f "/opt/homebrew/bin/brew" ]]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                elif [[ -f "/usr/local/bin/brew" ]]; then
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
            fi
            ;;
        linux|wsl)
            case $DISTRO in
                ubuntu|debian|pop|mint|linuxmint)
                    sudo apt update
                    sudo apt install -y curl wget unzip git build-essential fontconfig
                    ;;
                arch|manjaro|endeavouros|garuda)
                    sudo pacman -Sy --needed curl wget unzip git base-devel fontconfig
                    ;;
                fedora|rhel|centos|rocky|almalinux|ol)
                    if command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y curl wget unzip git gcc-c++ make fontconfig
                    else
                        sudo yum install -y curl wget unzip git gcc-c++ make fontconfig
                    fi
                    ;;
                opensuse*|sles)
                    sudo zypper install -y curl wget unzip git gcc-c++ make fontconfig
                    ;;
                *)
                    echo "⚠️  Unknown Linux distribution. Please install curl, wget, unzip, git manually."
                    ;;
            esac
            ;;
        windows)
            echo "🪟 Please ensure you have git, curl, and PowerShell available"
            ;;
    esac
}

# Install ZSH
install_zsh() {
    if command -v zsh >/dev/null 2>&1; then
        echo "✅ ZSH already installed: $(zsh --version)"
        return 0
    fi
    
    echo "📦 Installing ZSH..."
    
    case $OS in
        macos)
            brew install zsh
            ;;
        linux|wsl)
            case $DISTRO in
                ubuntu|debian|pop|mint|linuxmint)
                    sudo apt install -y zsh
                    ;;
                arch|manjaro|endeavouros|garuda)
                    sudo pacman -S zsh
                    ;;
                fedora|rhel|centos|rocky|almalinux|ol)
                    if command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y zsh
                    else
                        sudo yum install -y zsh
                    fi
                    ;;
                opensuse*|sles)
                    sudo zypper install -y zsh
                    ;;
                *)
                    echo "❌ Please install ZSH manually for your distribution"
                    exit 1
                    ;;
            esac
            ;;
        windows)
            echo "❌ Please install ZSH manually (e.g., via Git Bash or WSL)"
            exit 1
            ;;
    esac
    
    if command -v zsh >/dev/null 2>&1; then
        echo "✅ ZSH installed successfully: $(zsh --version)"
    else
        echo "❌ ZSH installation failed"
        exit 1
    fi
}

# Install Nerd Font
install_nerd_font() {
    echo "🔤 Installing FiraCode Nerd Font..."
    
    case $OS in
        macos)
            brew tap homebrew/cask-fonts 2>/dev/null || true
            brew install --cask font-fira-code-nerd-font
            ;;
        linux|wsl)
            FONT_DIR="$HOME/.local/share/fonts"
            mkdir -p "$FONT_DIR"
            
            # Download FiraCode Nerd Font
            FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"
            TEMP_DIR=$(mktemp -d)
            
            echo "📦 Downloading FiraCode Nerd Font..."
            if curl -L "$FONT_URL" -o "$TEMP_DIR/FiraCode.zip"; then
                echo "📦 Installing font..."
                if unzip -q "$TEMP_DIR/FiraCode.zip" -d "$TEMP_DIR"; then
                    cp "$TEMP_DIR"/*.ttf "$FONT_DIR/" 2>/dev/null || true
                    
                    # Refresh font cache
                    if command -v fc-cache >/dev/null 2>&1; then
                        fc-cache -fv "$FONT_DIR" >/dev/null 2>&1
                    fi
                    
                    echo "✅ Font installed to $FONT_DIR"
                else
                    echo "❌ Failed to extract font files"
                fi
            else
                echo "❌ Failed to download font"
            fi
            
            # Cleanup
            rm -rf "$TEMP_DIR"
            ;;
        windows)
            echo "🪟 For Windows, please manually install FiraCode Nerd Font:"
            echo "   1. Download: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"
            echo "   2. Extract and install all .ttf files"
            ;;
        *)
            echo "⚠️  Please install FiraCode Nerd Font manually from:"
            echo "   https://github.com/ryanoasis/nerd-fonts/releases/latest"
            ;;
    esac
}

# Install Oh My Posh
install_oh_my_posh() {
    if command -v oh-my-posh >/dev/null 2>&1; then
        echo "✅ Oh My Posh already installed: $(oh-my-posh --version)"
        return 0
    fi
    
    echo "⭐ Installing Oh My Posh..."
    
    case $OS in
        macos)
            brew install jandedobbeleer/oh-my-posh/oh-my-posh
            ;;
        linux|wsl)
            curl -s https://ohmyposh.dev/install.sh | bash -s
            
            # Add to PATH for current session if installed to ~/.local/bin
            if [[ -f "$HOME/.local/bin/oh-my-posh" ]]; then
                export PATH="$HOME/.local/bin:$PATH"
            fi
            ;;
        windows)
            echo "🪟 For Windows, please install Oh My Posh manually:"
            echo "   winget install JanDeDobbeleer.OhMyPosh -s winget"
            echo "   or download from https://ohmyposh.dev/"
            return 1
            ;;
        *)
            curl -s https://ohmyposh.dev/install.sh | bash -s
            ;;
    esac
    
    # Verify installation
    if command -v oh-my-posh >/dev/null 2>&1; then
        echo "✅ Oh My Posh installed successfully: $(oh-my-posh --version)"
    else
        echo "❌ Oh My Posh installation failed"
        echo "   Please install manually from https://ohmyposh.dev/"
        exit 1
    fi
}

# Install ZSH plugins
install_zsh_plugins() {
    echo "📦 Installing ZSH plugins..."
    
    ZSH_PLUGINS_DIR="$HOME/.zsh-plugins"
    mkdir -p "$ZSH_PLUGINS_DIR"

    install_plugin() {
        local plugin_name="$1"
        local plugin_url="$2"
        local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"
        
        if [ ! -d "$plugin_dir" ]; then
            echo "📦 Installing $plugin_name..."
            git clone --depth=1 "$plugin_url" "$plugin_dir"
        else
            echo "✅ $plugin_name already installed"
        fi
    }

    install_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
    install_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
    install_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search"
    install_plugin "zsh-completions" "https://github.com/zsh-users/zsh-completions"
}

# Install external tools
install_external_tools() {
    echo "🛠️  Installing external tools..."
    
    if [[ -f "scripts/setup-tools.sh" ]]; then
        chmod +x scripts/setup-tools.sh
        ./scripts/setup-tools.sh
    else
        echo "⚠️  External tools script not found. Installing basic tools..."
        
        case $OS in
            macos)
                brew install bat eza ripgrep fd fzf zoxide
                ;;
            linux|wsl)
                case $DISTRO in
                    ubuntu|debian|pop|mint|linuxmint)
                        # Install available packages
                        sudo apt install -y fzf fd-find
                        
                        # Install from .deb packages
                        wget -q https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb -O /tmp/bat.deb
                        sudo dpkg -i /tmp/bat.deb || sudo apt-get install -f -y
                        rm /tmp/bat.deb
                        
                        wget -q https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0-1_amd64.deb -O /tmp/rg.deb
                        sudo dpkg -i /tmp/rg.deb || sudo apt-get install -f -y
                        rm /tmp/rg.deb
                        
                        # Install eza and zoxide from releases
                        wget -qO- https://github.com/eza-community/eza/releases/download/v0.18.0/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz -C /tmp
                        sudo mv /tmp/eza /usr/local/bin/
                        
                        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
                        sudo mv ~/.local/bin/zoxide /usr/local/bin/ 2>/dev/null || true
                        
                        # Create fd symlink
                        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd 2>/dev/null || true
                        ;;
                    arch|manjaro|endeavouros|garuda)
                        sudo pacman -S --needed bat eza ripgrep fd fzf zoxide
                        ;;
                    *)
                        echo "⚠️  Please install tools manually: bat, eza, ripgrep, fd, fzf, zoxide"
                        ;;
                esac
                ;;
        esac
    fi
}

# Setup LazyVim
setup_lazyvim() {
    echo "🚀 Setting up LazyVim..."
    
    if [[ -f "scripts/setup-lazyvim.sh" ]]; then
        chmod +x scripts/setup-lazyvim.sh
        ./scripts/setup-lazyvim.sh
    else
        echo "⚠️  LazyVim setup script not found. Please install Neovim manually."
    fi
}

# Change default shell
change_default_shell() {
    if [[ "$SHELL" == "$(which zsh)" ]]; then
        echo "✅ ZSH is already the default shell"
        return 0
    fi
    
    echo "🔄 Changing default shell to ZSH..."
    
    # Add zsh to valid shells if not present
    if ! grep -q "$(which zsh)" /etc/shells 2>/dev/null; then
        echo "$(which zsh)" | sudo tee -a /etc/shells >/dev/null
    fi
    
    # Change shell
    chsh -s "$(which zsh)"
    echo "✅ Default shell changed to ZSH (takes effect on next login)"
}

# Main installation process
main() {
    echo ""
    echo "=== STEP 1: Verify dotfiles structure ==="
    check_dotfiles_structure
    
    echo ""
    echo "=== STEP 2: Install system dependencies ==="
    install_system_deps
    
    echo ""
    echo "=== STEP 3: Install ZSH ==="
    install_zsh
    
    echo ""
    echo "=== STEP 4: Install Nerd Font ==="
    install_nerd_font
    
    echo ""
    echo "=== STEP 5: Install Oh My Posh ==="
    install_oh_my_posh
    
    echo ""
    echo "=== STEP 6: Install ZSH plugins ==="
    install_zsh_plugins
    
    echo ""
    echo "=== STEP 7: Setup configurations ==="

    # Create Oh My Posh config directory
    mkdir -p "$HOME/.config/oh-my-posh"
    mkdir -p "$HOME/.config/oh-my-posh/themes"

    # Copy ZSH configuration
    if [[ -f "zsh/.zshrc" ]]; then
        cp "zsh/.zshrc" "$HOME/.zshrc"
        echo "✅ Copied ZSH configuration"
    else
        echo "❌ ZSH config file not found: zsh/.zshrc"
        exit 1
    fi

    echo "📥 Downloading Oh My Posh themes..."
    # Download all official themes
    curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/contents/themes | \
        grep download_url | \
        grep "\.omp\.json" | \
        cut -d '"' -f 4 | \
        xargs -I {} wget -q -P "$HOME/.config/oh-my-posh/themes" {}

    # Set a default theme (agnoster is a good starter)
    if [[ -f "$HOME/.config/oh-my-posh/themes/agnoster.omp.json" ]]; then
        cp "$HOME/.config/oh-my-posh/themes/agnoster.omp.json" "$HOME/.config/oh-my-posh/current.omp.json"
        echo "✅ Set agnoster as default theme"
    else
        echo "⚠️  No default theme set - you can choose one with 'omp_theme set <theme_name>'"
    fi
    
    # Copy ZSH configuration
    if [[ -f "zsh/.zshrc" ]]; then
        cp "zsh/.zshrc" "$HOME/.zshrc"
        echo "✅ Copied ZSH configuration"
    else
        echo "❌ ZSH config file not found: zsh/.zshrc"
        exit 1
    fi
    
    echo ""
    echo "=== STEP 8: Install external tools ==="
    install_external_tools
    
    echo ""
    echo "=== STEP 9: Setup LazyVim ==="
    setup_lazyvim
    
    echo ""
    echo "=== STEP 10: Change default shell ==="
    change_default_shell
    
    echo ""
    echo "✨ Installation complete!"
    echo ""
    echo "📂 Backups saved to: $BACKUP_DIR"
    echo ""
    echo "🎯 Next steps:"
    echo "   1. Close this terminal completely"
    echo "   2. Open a new terminal"
    echo "   3. Configure your terminal font to 'FiraCode Nerd Font'"
    echo "   4. Download themes: omp_theme download"
    echo "   5. Choose a theme: omp_theme list && omp_theme set <theme_name>"
    echo "   6. Enjoy your customizable Oh My Posh prompt!"
    
    case $OS in
        macos)
            echo "🍎 macOS font setup:"
            echo "   - Terminal.app: Preferences → Profiles → Font → FiraCode Nerd Font"
            echo "   - iTerm2: Preferences → Profiles → Text → Font → FiraCode Nerd Font"
            ;;
        linux|wsl)
            echo "🐧 Linux font setup:"
            echo "   - Set your terminal font to 'FiraCode Nerd Font' or 'FiraCode NF'"
            echo "   - The font should appear in your terminal's font selection"
            ;;
        windows)
            echo "🪟 Windows font setup:"
            echo "   - Windows Terminal: Settings → Profiles → Appearance → Font face → FiraCode Nerd Font"
            echo "   - PowerShell: Right-click title bar → Properties → Font → FiraCode Nerd Font"
            ;;
    esac
    
    echo ""
    echo "🔧 Troubleshooting:"
    echo "   - If Oh My Posh doesn't work: oh-my-posh --version"
    echo "   - If fonts look wrong: Restart terminal and check font settings"
    echo "   - If prompt is plain: source ~/.zshrc"
    echo ""
    echo "🎉 Welcome to your new development environment!"
}

# Run main installation
main