#!/bin/bash

# Cross-platform external tools installation script

echo "🛠️  Installing external tools..."

# Detect OS and package manager
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
DISTRO=""

if [[ "$OS" == "linux" ]] || [[ "$OS" == "wsl" ]]; then
    DISTRO=$(detect_linux_distro)
fi

echo "🔍 Detected: $OS${DISTRO:+ ($DISTRO)}"

# Installation functions for different package managers
install_with_brew() {
    echo "🍺 Installing tools via Homebrew..."
    brew install bat eza ripgrep fd fzf zoxide
}

install_with_apt() {
    echo "🐧 Installing tools via apt..."
    sudo apt update
    
    # Install available packages
    sudo apt install -y curl wget unzip fzf fd-find
    
    # Install from .deb packages for newer versions
    install_deb_package() {
        local name="$1"
        local url="$2"
        local deb_file="/tmp/${name}.deb"
        
        if ! command -v "$name" >/dev/null 2>&1; then
            echo "📦 Installing $name..."
            wget -q "$url" -O "$deb_file"
            sudo dpkg -i "$deb_file" || sudo apt-get install -f -y
            rm "$deb_file"
        fi
    }
    
    # Install bat
    install_deb_package "bat" "https://github.com/sharkdp/bat/releases/download/v0.24.0/bat_0.24.0_amd64.deb"
    
    # Install ripgrep
    install_deb_package "rg" "https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep_14.1.0-1_amd64.deb"
    
    # Install eza
    if ! command -v eza >/dev/null 2>&1; then
        echo "📦 Installing eza..."
        wget -qO- https://github.com/eza-community/eza/releases/download/v0.18.0/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz -C /tmp
        sudo mv /tmp/eza /usr/local/bin/
    fi
    
    # Install zoxide
    if ! command -v zoxide >/dev/null 2>&1; then
        echo "📦 Installing zoxide..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        sudo mv ~/.local/bin/zoxide /usr/local/bin/ 2>/dev/null || true
    fi
    
    # Create fd symlink if needed
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi
}

install_with_pacman() {
    echo "🏛️  Installing tools via pacman..."
    sudo pacman -Sy --needed bat eza ripgrep fd fzf zoxide
}

install_with_dnf() {
    echo "🎩 Installing tools via dnf..."
    if command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y bat eza ripgrep fd-find fzf zoxide
    else
        sudo yum install -y epel-release
        sudo yum install -y fzf
        # Install from releases for RHEL/CentOS
        install_rpm_from_release
    fi
    
    # Create fd symlink if needed
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        sudo ln -sf "$(which fdfind)" /usr/local/bin/fd
    fi
}

install_with_zypper() {
    echo "🦎 Installing tools via zypper..."
    sudo zypper install -y bat eza ripgrep fd fzf zoxide
}

install_rpm_from_release() {
    # Install tools from GitHub releases for RHEL/CentOS
    echo "📦 Installing tools from releases..."
    
    # Install bat
    if ! command -v bat >/dev/null 2>&1; then
        wget -q https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-x86_64-unknown-linux-musl.tar.gz -O /tmp/bat.tar.gz
        tar -xzf /tmp/bat.tar.gz -C /tmp
        sudo mv /tmp/bat-*/bat /usr/local/bin/
        rm -rf /tmp/bat*
    fi
    
    # Install ripgrep
    if ! command -v rg >/dev/null 2>&1; then
        wget -q https://github.com/BurntSushi/ripgrep/releases/download/14.1.0/ripgrep-14.1.0-x86_64-unknown-linux-musl.tar.gz -O /tmp/rg.tar.gz
        tar -xzf /tmp/rg.tar.gz -C /tmp
        sudo mv /tmp/ripgrep-*/rg /usr/local/bin/
        rm -rf /tmp/ripgrep*
    fi
    
    # Install eza
    if ! command -v eza >/dev/null 2>&1; then
        wget -qO- https://github.com/eza-community/eza/releases/download/v0.18.0/eza_x86_64-unknown-linux-gnu.tar.gz | tar xz -C /tmp
        sudo mv /tmp/eza /usr/local/bin/
    fi
    
    # Install zoxide
    if ! command -v zoxide >/dev/null 2>&1; then
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        sudo mv ~/.local/bin/zoxide /usr/local/bin/ 2>/dev/null || true
    fi
    
    # Install fd
    if ! command -v fd >/dev/null 2>&1; then
        wget -q https://github.com/sharkdp/fd/releases/download/v8.7.1/fd-v8.7.1-x86_64-unknown-linux-musl.tar.gz -O /tmp/fd.tar.gz
        tar -xzf /tmp/fd.tar.gz -C /tmp
        sudo mv /tmp/fd-*/fd /usr/local/bin/
        rm -rf /tmp/fd*
    fi
}

install_with_winget() {
    echo "🪟 Installing tools via winget..."
    echo "Please run these commands in PowerShell as Administrator:"
    echo "winget install sharkdp.bat"
    echo "winget install eza-community.eza"
    echo "winget install BurntSushi.ripgrep.MSVC"
    echo "winget install sharkdp.fd"
    echo "winget install junegunn.fzf"
    echo "winget install ajeetdsouza.zoxide"
}

# Main installation logic
case $OS in
    macos)
        install_with_brew
        ;;
    linux|wsl)
        case $DISTRO in
            ubuntu|debian|pop|mint|linuxmint)
                install_with_apt
                ;;
            arch|manjaro|endeavouros|garuda)
                install_with_pacman
                ;;
            fedora|rhel|centos|rocky|almalinux|ol)
                install_with_dnf
                ;;
            opensuse*|sles)
                install_with_zypper
                ;;
            *)
                echo "🐧 Unknown Linux distribution. Trying generic installation..."
                install_rpm_from_release
                ;;
        esac
        ;;
    windows)
        install_with_winget
        ;;
    *)
        echo "⚠️  Unsupported OS. Please install these tools manually:"
        echo "   - bat (better cat): https://github.com/sharkdp/bat"
        echo "   - eza (better ls): https://github.com/eza-community/eza"
        echo "   - ripgrep (better grep): https://github.com/BurntSushi/ripgrep"
        echo "   - fd (better find): https://github.com/sharkdp/fd"
        echo "   - fzf (fuzzy finder): https://github.com/junegunn/fzf"
        echo "   - zoxide (smart cd): https://github.com/ajeetdsouza/zoxide"
        ;;
esac

echo ""
echo "✅ Tools installation complete!"

# Verify installations
echo ""
echo "🔍 Verifying installations..."
for tool in bat eza rg fd fzf zoxide; do
    if command -v "$tool" >/dev/null 2>&1; then
        version=$($tool --version 2>/dev/null | head -1 || echo "installed")
        echo "✅ $tool: $version"
    else
        echo "❌ $tool: not found"
    fi
done

echo ""
echo "🎯 Usage examples:"
echo "   cat file.txt    → bat file.txt (syntax highlighting)"
echo "   ls              → eza (icons and git status)"
echo "   grep pattern    → rgrep pattern (faster search)"  
echo "   find . -name    → fd pattern (faster find)"
echo "   cd path         → z path (smart directory jumping)"
echo "   Ctrl+R          → fzf history search"
echo "   Ctrl+T          → fzf file search"