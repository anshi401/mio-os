#!/bin/bash

set -euo pipefail

# Paths
dotfiles="$HOME/.mio-os"
wallDir="$HOME/Pictures/Wallpapers/"
wallpaperRofiConfig="$dotfiles/.config/rofi/styles/wallpaperChanger.rasi"
schemeRofiConfig="$dotfiles/.config/rofi/styles/colorSchemeChanger.rasi"
waybarState="$dotfiles/.config/waybar/current_template"
randomOpt="Random"
wallState="$dotfiles/.config/currentWallpaper"

# Helpers
notify_error() {
    notify-send -u critical -i "dialog-error-symbolic" "Error" "$1" \
        -h string:x-canonical-private-synchronous:wallpaper_changer
    echo "Error: $1" >&2
}

# Verify required environment variables
for var in settingsMode settingsTheme settingsIcons settingsFont settingsCursor; do
    if [ -z "${!var:-}" ]; then
        notify_error "Environment variable \$$var is not set."
        exit 1
    fi
done

# Wallpaper directory check
if [ ! -d "$wallDir" ]; then
    notify_error "Wallpaper directory not found: $wallDir"
    exit 1
fi

# Collect wallpapers
mapfile -t wallpapers < <(find "$wallDir" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) | sort -V)

if [ "${#wallpapers[@]}" -eq 0 ]; then
    notify_error "No wallpapers found in $wallDir"
    exit 1
fi

# Wallpaper picker
selected_wall=$(
    (
        echo -en "$randomOpt\0icon\x1fview-refresh\n"
        for img in "${wallpapers[@]}"; do
            name="$(basename "$img")"
            echo -en "$name\0icon\x1f$img\n"
        done
    ) | rofi -dmenu -show-icons -p "Wallpaper" -config "$wallpaperRofiConfig"
) || exit 0

if [ -z "$selected_wall" ]; then
    echo "No wallpaper selected." >&2
    exit 0
fi

if [ "$selected_wall" = "$randomOpt" ]; then
    wallPath="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
else
    wallPath="$wallDir/$selected_wall"
fi

if [ ! -f "$wallPath" ]; then
    notify_error "Selected wallpaper file not found: $wallPath"
    exit 1
fi

# Color scheme picker
declare -A scheme_map=(
    ["Neutral"]="scheme-neutral"
    ["Tonal Spot"]="scheme-tonal-spot"
    ["Content"]="scheme-content"
    ["Monochrome"]="scheme-monochrome"
    ["Vibrant"]="scheme-vibrant"
)

choice=$(printf '%s\n' "${!scheme_map[@]}" | sort | rofi -dmenu -p " Select color scheme" -config "$schemeRofiConfig") || exit 0

if [ -z "$choice" ]; then
    echo "No color scheme selected." >&2
    exit 0
fi

selected_scheme="${scheme_map[$choice]:-scheme-neutral}"

# Apply wallpaper + theme via matugen
if ! matugen image "$wallPath" -m "$settingsMode" -t "$selected_scheme" --source-color-index 0; then
    notify_error "matugen failed to generate theme."
    exit 1
fi

# Save current wallpaper for restore on startup
mkdir -p "$(dirname "$wallState")"
basename "$wallPath" > "$wallState"

# Apply GTK / GNOME settings
gsettings set org.gnome.desktop.wm.preferences   theme          "$settingsTheme"
gsettings set org.gnome.desktop.interface        gtk-theme      "$settingsTheme"
gsettings set org.gnome.desktop.interface        color-scheme   "prefer-$settingsMode"
gsettings set org.gnome.desktop.interface        icon-theme     "$settingsIcons"
gsettings set org.gnome.desktop.interface        font-name      "$settingsFont"
gsettings set org.gnome.desktop.interface        cursor-theme   "$settingsCursor"

# Force GTK color-scheme reload (toggle trick)
# Some GTK apps only pick up the new scheme on a change event, so we briefly
# switch to the opposite value and immediately switch back.
if [ "$settingsMode" = "dark" ]; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
else
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
fi

# Regenerate waybar config from template
if [ -f "$waybarState" ]; then
    current_waybar_template=$(cat "$waybarState")
else
    current_waybar_template="default.jsonc"
fi

envsubst < "$dotfiles/.config/waybar/templates/$current_waybar_template" \
         > "$dotfiles/.config/waybar/config.jsonc"

envsubst < "$dotfiles/.config/waybar/templates/modules/hyprland-workspaces.jsonc" \
         > "$dotfiles/.config/waybar/modules/hyprland-workspaces.jsonc"

envsubst < "$dotfiles/.config/waybar/templates/modules/hyprland-language.jsonc" \
         > "$dotfiles/.config/waybar/modules/hyprland-language.jsonc"

# Reload / restart waybar
if pgrep -x "waybar" > /dev/null; then
    killall waybar && waybar & disown
else
    waybar & disown
fi

# Reload other components
pkill -SIGUSR1 kitty  || true   # kitty may not be running — not fatal
pkill -USR2 btop || true
hyprctl reload
dunstctl reload
systemctl --user restart hyprpolkitagent.service

# Done
notify-send -i "dialog-information-symbolic" "Theme applied" \
    "Wallpaper and theme updated successfully!\nSelected scheme: $choice" \
    -h string:x-canonical-private-synchronous:wallpaper_changer \
    -t 4000
