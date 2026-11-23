#!/bin/bash

# Dotfiles installer for Arch Linux and Arch-based distros.

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# Helpers
info()    { echo -e "${BLUE}[*]${NC} $*"; }
success() { echo -e "${GREEN}[+]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*" >&2; }
error()   { echo -e "${RED}[x]${NC} $*" >&2; }
step() { echo -e "\n${BOLD}${BLUE}==>${NC}${BOLD} $*${NC}\n"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

show_logo() {
    cat <<'EOF'

    ▄▄▄▄  ▄  ▄▄▄       ▄▄▄   ▄▄▄
    █ █ █ ▄ █   █     █   █ ▀▄▄
    █   █ █ ▀▄▄▄▀     ▀▄▄▄▀ ▄▄▄▀
          █

          quiet simplicity

EOF
}

# Failures collected during the run, printed in the summary at the end
FAILED=()
fail() { error "$*"; FAILED+=("$*"); }

# Usage: confirm "Question?"  -> returns 0 for yes, 1 for no
confirm() {
    local reply=""
    echo -e -n "${YELLOW}[?]${NC} $1 (y/N): "
    read -r reply || reply=""
    [[ "$reply" =~ ^[Yy]$ ]]
}

# Cleanup
TMP_DIR=""
cleanup() {
    if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
        rm -rf "$TMP_DIR"
    fi
}
trap cleanup EXIT
trap 'exit 130' INT TERM HUP

# Guards
if [ "$EUID" -eq 0 ]; then
    error "Do not run this script as root (makepkg refuses to work as root)."
    error "Run it as a normal user; sudo will be used where needed."
    exit 1
fi

if ! command_exists pacman; then
    error "This script is designed for Arch Linux based systems."
    exit 1
fi

if ! command_exists sudo; then
    error "sudo is required but not installed."
    exit 1
fi

# Setup
USER_NAME="$(id -un)"
BACKUP_DIR="$HOME/.mio-os_backup_$(date +%Y%m%d_%H%M%S)"

# Dotfiles must live in ~/.mio-os, since configs reference this path
DOTFILES="$HOME/.mio-os"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -d "$DOTFILES" ]; then
    error "${RED}mio os${NC} directory not found: $DOTFILES"
    error "Move the repository to ~/.mio-os and run the installer from there."
    exit 1
fi

if [ "$SCRIPT_DIR" != "$(cd "$DOTFILES" && pwd -P)" ] && [ "$SCRIPT_DIR" != "$DOTFILES" ]; then
    error "The installer is running from $SCRIPT_DIR"
    error "Configs expect the repository at ~/.mio-os. Move it there and run again."
    exit 1
fi

show_logo
info "Starting ${RED}mio os${NC} installation..."
info "Directory: $DOTFILES"

# Symlink helper
# Usage: make_link <source> <target> [backup_subdir]
make_link() {
    local src="$1"
    local tgt="$2"
    local backup_sub="${3:-}"

    if [ -L "$tgt" ] && [ "$(readlink "$tgt")" = "$src" ]; then
        info "Symlink already correct: $tgt"
        return 0
    fi

    if [ -e "$tgt" ] || [ -L "$tgt" ]; then
        local backup_dst="$BACKUP_DIR${backup_sub:+/$backup_sub}"
        mkdir -p "$backup_dst"
        # numbered backups: files with equal names are not overwritten
        mv --backup=numbered "$tgt" "$backup_dst/"
        warn "Backed up existing: $tgt → $backup_dst/"
    fi

    mkdir -p "$(dirname "$tgt")"
    ln -s "$src" "$tgt"
    success "Created symlink: $tgt → $src"
}

# Package list helpers
# Strip comments and blank lines from a package list
clean_list() {
    grep -vE '^[[:space:]]*(#|$)' "$1" || true
}

# Usage: pacman_install_list <file> <label>
# Packages are passed as arguments (not via stdin) so that pacman can ask
# for confirmation on the terminal.
pacman_install_list() {
    local file="$1" label="$2" pkgs=()
    if [ ! -f "$file" ]; then
        fail "$label package list not found: $file"
        return 0
    fi
    mapfile -t pkgs < <(clean_list "$file")
    if [ "${#pkgs[@]}" -eq 0 ]; then
        warn "$label package list is empty: $file"
        return 0
    fi
    info "Installing $label packages..."
    if sudo pacman -S --needed "${pkgs[@]}"; then
        success "$label packages installed."
    else
        fail "Some $label packages failed to install."
    fi
}

# Usage: aur_install_list <file> <label>
aur_install_list() {
    local file="$1" label="$2" pkgs=()
    if [ ! -f "$file" ]; then
        fail "$label package list not found: $file"
        return 0
    fi
    mapfile -t pkgs < <(clean_list "$file")
    if [ "${#pkgs[@]}" -eq 0 ]; then
        warn "$label package list is empty: $file"
        return 0
    fi
    info "Installing $label packages..."
    if paru -S --needed "${pkgs[@]}"; then
        success "$label packages installed."
    else
        fail "Some $label packages failed to install."
    fi
}

# Packages
step "[1/4] Installing packages..."

info "Updating system..."
sudo pacman -Syu

info "Installing build prerequisites (git, base-devel)..."
sudo pacman -S --needed git base-devel

pacman_install_list "$DOTFILES/packages/pkgList" "official"

if ! command_exists paru; then
    info "paru not found — installing paru from AUR..."
    TMP_DIR="$(mktemp -d)"
    if git clone https://aur.archlinux.org/paru.git "$TMP_DIR/paru" \
       && (cd "$TMP_DIR/paru" && makepkg -si); then
        success "paru installed."
    else
        error "Failed to install paru. Aborting."
        exit 1
    fi
fi

aur_install_list "$DOTFILES/packages/aurPkgList" "AUR"

# Symbolic links
step "[2/4] Creating symbolic links..."

mkdir -p "$HOME/.config" "$HOME/.local" "$HOME/Pictures"

# .config/*  (nullglob: empty dir -> no iterations, dotglob: include dotfiles)
if [ -d "$DOTFILES/.config" ]; then
    shopt -s nullglob dotglob
    for entry in "$DOTFILES/.config"/*; do
        make_link "$entry" "$HOME/.config/$(basename "$entry")" ".config"
    done
    shopt -u nullglob dotglob
else
    fail ".config directory not found in dotfiles."
fi

# .local/bin
if [ -d "$DOTFILES/.local/bin" ]; then
    make_link "$DOTFILES/.local/bin" "$HOME/.local/bin" ".local"
fi

# Wallpapers
if [ -d "$DOTFILES/wallpapers" ]; then
    make_link "$DOTFILES/wallpapers" "$HOME/Pictures/Wallpapers" "Pictures"
fi

# Default shell
step "[3/4] Changing default shell to fish..."

if command_exists fish; then
    FISH_PATH="$(command -v fish)"
    CURRENT_SHELL="$(getent passwd "$USER_NAME" | cut -d: -f7)"

    if [ "$CURRENT_SHELL" = "$FISH_PATH" ]; then
        info "Default shell is already fish."
    else
        shell_changed=false
        for attempt in 1 2 3; do
            if chsh -s "$FISH_PATH"; then
                shell_changed=true
                break
            fi
            if [ "$attempt" -lt 3 ]; then
                warn "Attempt $attempt/3 failed, try again."
            fi
        done

        if $shell_changed; then
            success "Default shell changed to fish."
        else
            fail "Failed to change shell after 3 attempts. Run manually: chsh -s $FISH_PATH"
        fi
    fi
else
    fail "fish is not installed."
fi

# Optional packages
step "[4/4] Installing optional packages..."

# Docker
if confirm "Do you want to install Docker?"; then
    info "Installing Docker..."
    if sudo pacman -S --needed docker docker-compose; then
        sudo usermod -aG docker "$USER_NAME"
        sudo systemctl enable --now docker.service
        success "Docker installed and enabled (group change applies after re-login)."
    else
        fail "Docker installation failed."
    fi
fi

# Gaming
if confirm "Do you want to install gaming packages (Steam, Gamemode, Gamescope, MangoHUD, MangoJuice, ProtonPlus)?"; then
    info "Installing gaming packages..."

    # Steam lives in [multilib]; enable it if it is commented out
    if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
        info "Enabling [multilib] repository..."
        sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
        if grep -q '^\[multilib\]' /etc/pacman.conf; then
            sudo pacman -Syu
        else
            warn "Could not enable [multilib] automatically; Steam may fail to install."
        fi
    fi

    # Steam asks which Vulkan driver to use, so it is always installed interactively
    if sudo pacman -S --needed steam \
       && sudo pacman -S --needed gamemode mangohud gamescope \
       && paru -S --needed mangojuice-bin protonplus; then
        sudo usermod -aG gamemode "$USER_NAME"

        if [ -d "$DOTFILES/optionalConfigs" ]; then
            info "Linking gaming configs..."

            if [ -d "$DOTFILES/optionalConfigs/MangoHud" ]; then
                make_link "$DOTFILES/optionalConfigs/MangoHud" "$HOME/.config/MangoHud" ".config"
            fi

            if [ -f "$DOTFILES/optionalConfigs/gamemode.ini" ]; then
                make_link "$DOTFILES/optionalConfigs/gamemode.ini" "$HOME/.config/gamemode.ini" ".config"
            fi
        fi

        success "Gaming packages installed (group change applies after re-login)."
    else
        fail "Some gaming packages failed to install."
    fi
fi

# zed
if confirm "Do you want to install zed?"; then
    info "Installing zed..."
    if paru -S --needed zed; then
        if [ -d "$DOTFILES/optionalConfigs/zed" ]; then
            info "Linking zed config..."
            mkdir -p "$HOME/.config/zed"

            if [ -f "$DOTFILES/optionalConfigs/zed/settings.json" ]; then
                make_link "$DOTFILES/optionalConfigs/zed/settings.json" "$HOME/.config/zed/settings.json" "zed"
            fi
        fi
        success "zed installed."
    else
        fail "zed installation failed."
    fi
fi

# Optional package lists
if confirm "Do you want to install optional packages from lists?"; then
    info "Installing optional packages..."

    if [ -f "$DOTFILES/packages/optional/pkgList" ]; then
        pacman_install_list "$DOTFILES/packages/optional/pkgList" "optional official"
    fi

    if [ -f "$DOTFILES/packages/optional/aurPkgList" ]; then
        aur_install_list "$DOTFILES/packages/optional/aurPkgList" "optional AUR"
    fi
fi

# Finish
# Remove backup dir if nothing was actually backed up
if [ -d "$BACKUP_DIR" ] && [ -z "$(ls -A "$BACKUP_DIR")" ]; then
    rmdir "$BACKUP_DIR"
fi

echo ""
if [ "${#FAILED[@]}" -eq 0 ]; then
    success "Installation complete!"
else
    warn "Installation finished with ${#FAILED[@]} problem(s):"
    for item in "${FAILED[@]}"; do
        warn "  - $item"
    done
fi

if [ -d "$BACKUP_DIR" ]; then
    warn "Conflicting configs backed up to: $BACKUP_DIR"
fi

echo ""
info "P.S."
info "Start Hyprland (if no display manager): h"
info "Custom configs are created after the first Hyprland launch."
info "After that, set keyboard/monitor in: $DOTFILES/.config/hypr/lua/custom/settings.lua"
info "                                 and: $DOTFILES/.config/hypr/lua/custom/monitors.lua"
info "Change wallpaper: Super + W"
echo ""
warn "Please reboot for all changes to take effect (shell, docker/gamemode groups)."
echo ""

if [ "${#FAILED[@]}" -eq 0 ]; then
    EXIT_CODE=0
else
    EXIT_CODE=1
fi

if confirm "Reboot now?"; then
    systemctl reboot
fi

sleep 0.2
exit "$EXIT_CODE"
