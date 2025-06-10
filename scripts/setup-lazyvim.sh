#!/bin/bash

echo "🚀 Setting up LazyVim..."

# Detect OS for Neovim installation
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*) echo "linux" ;;
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
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
DISTRO=""

if [[ "$OS" == "linux" ]]; then
    DISTRO=$(detect_linux_distro)
fi

# Check if neovim is installed
if ! command -v nvim >/dev/null 2>&1; then
    echo "❌ Neovim not found. Installing..."
    
    case $OS in
        macos)
            if command -v brew >/dev/null 2>&1; then
                brew install neovim
            else
                echo "❌ Please install Homebrew first or install Neovim manually"
                exit 1
            fi
            ;;
        linux)
            case $DISTRO in
                ubuntu|debian|pop|mint|linuxmint)
                    # Check Ubuntu/Debian version for Neovim availability
                    if apt-cache show neovim | grep -q "Version: 0.[4-9]"; then
                        sudo apt update && sudo apt install -y neovim
                    else
                        # Install from snap for newer version
                        sudo snap install nvim --classic
                    fi
                    ;;
                arch|manjaro|endeavouros|garuda)
                    sudo pacman -S neovim
                    ;;
                fedora|rhel|centos|rocky|almalinux|ol)
                    if command -v dnf >/dev/null 2>&1; then
                        sudo dnf install -y neovim
                    else
                        sudo yum install -y epel-release
                        sudo yum install -y neovim
                    fi
                    ;;
                opensuse*|sles)
                    sudo zypper install -y neovim
                    ;;
                *)
                    echo "❌ Please install Neovim manually for your distribution"
                    echo "   Visit: https://github.com/neovim/neovim/releases"
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo "❌ Please install Neovim manually for your OS"
            echo "   Visit: https://github.com/neovim/neovim/releases"
            exit 1
            ;;
    esac
fi

# Verify Neovim installation
if command -v nvim >/dev/null 2>&1; then
    NVIM_VERSION=$(nvim --version | head -1)
    echo "✅ Neovim found: $NVIM_VERSION"
else
    echo "❌ Neovim installation failed"
    exit 1
fi

# Check Neovim version (LazyVim requires 0.8+)
NVIM_MAJOR=$(nvim --version | head -1 | sed 's/.*v\([0-9]\+\)\.\([0-9]\+\).*/\1/')
NVIM_MINOR=$(nvim --version | head -1 | sed 's/.*v\([0-9]\+\)\.\([0-9]\+\).*/\2/')

if [[ $NVIM_MAJOR -eq 0 && $NVIM_MINOR -lt 8 ]]; then
    echo "⚠️  LazyVim requires Neovim 0.8+, you have 0.$NVIM_MINOR"
    echo "   LazyVim may not work properly with this version"
fi

# Backup existing nvim configuration
backup_if_exists() {
    local path="$1"
    local backup_suffix="backup.$(date +%Y%m%d-%H%M%S)"
    
    if [ -d "$path" ] || [ -f "$path" ]; then
        echo "📦 Backing up existing $(basename "$path")"
        mv "$path" "${path}.${backup_suffix}"
    fi
}

backup_if_exists "$HOME/.config/nvim"
backup_if_exists "$HOME/.local/share/nvim"
backup_if_exists "$HOME/.local/state/nvim"
backup_if_exists "$HOME/.cache/nvim"

# Clone LazyVim starter template
echo "📦 Installing LazyVim starter..."
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Remove .git folder to make it your own
rm -rf ~/.config/nvim/.git

# Create a basic customization file for better defaults
echo "⚙️  Creating custom configuration..."

# Update options.lua
cat > ~/.config/nvim/lua/config/options.lua << 'EOF'
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Set to true if you have a Nerd Font installed
vim.g.have_nerd_font = true

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs and indentation  
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true

-- Line wrapping
vim.opt.wrap = false

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Cursor line
vim.opt.cursorline = true

-- Appearance
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.signcolumn = "yes"

-- Backspace
vim.opt.backspace = "indent,eol,start"

-- Clipboard
vim.opt.clipboard:append("unnamedplus")

-- Split windows
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Consider string-string as whole word
vim.opt.iskeyword:append("-")

-- Mouse
vim.opt.mouse = "a"

-- Folding
vim.opt.foldlevel = 20
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

-- Disable swap files
vim.opt.swapfile = false

-- Undo
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
EOF

# Update keymaps.lua
cat > ~/.config/nvim/lua/config/keymaps.lua << 'EOF'
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- General keymaps
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Tab management
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- Better up/down
keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Stay in indent mode
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- Keep last yanked when pasting
keymap.set("v", "p", '"_dP', opts)
EOF

# Create a custom plugin for additional tools
cat > ~/.config/nvim/lua/plugins/custom.lua << 'EOF'
-- Custom plugins and configurations

return {
  -- Better comments
  {
    "numToStr/Comment.nvim",
    opts = {},
  },
  
  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  
  -- Surround selections
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },
  
  -- Better search
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    keys = {
      { "<leader>sr", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
    },
  },
}
EOF

echo "✅ LazyVim installed successfully!"
echo ""
echo "🎯 Next steps:"
echo "   1. Run 'nvim' to complete the plugin installation"
echo "   2. LazyVim will automatically install and configure plugins"
echo "   3. Use ':help LazyVim' for documentation"
echo "   4. Check ':Lazy' to manage plugins"
echo ""
echo "📝 Key features enabled:"
echo "   - LSP support for multiple languages"
echo "   - File explorer (Neo-tree)"
echo "   - Fuzzy finder (Telescope)"
echo "   - Git integration (Gitsigns)"
echo "   - Autocompletion (nvim-cmp)"
echo "   - Syntax highlighting (Treesitter)"
echo "   - Terminal integration"
echo "   - And much more!"
echo ""
echo "⌨️  Important keybindings:"
echo "   <Space> - Leader key"
echo "   <leader>e - Toggle file explorer"
echo "   <leader>ff - Find files"
echo "   <leader>fg - Live grep"
echo "   <leader>/ - Comment toggle"
echo "   jk - Exit insert mode"
echo ""
echo "🎨 Theme: LazyVim uses a beautiful dark theme by default"
echo "   You can change it in ~/.config/nvim/lua/config/lazy.lua"