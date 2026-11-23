#!/bin/bash

waybar_dir="$HOME/.mio-os/.config/waybar"
templates_dir="$waybar_dir/templates"
styles_dir="$waybar_dir/styles"
target_css="$waybar_dir/style.css"
target_config="$waybar_dir/config.jsonc"
rofi_config="$HOME/.mio-os/.config/rofi/styles/waybarLayoutChanger.rasi"
state_file="$waybar_dir/current_template"

options="default\nflat\nfloating"

selected=$(echo -e "$options" | rofi -dmenu -config "$rofi_config")

if [ -z "$selected" ]; then
    exit 0
fi

case "$selected" in
    "default")
        style_file="default.css"
        config_template="default.jsonc"
        ;;
    "flat")
        style_file="flat.css"
        config_template="default.jsonc"
        ;;
    "floating")
        style_file="floating.css"
        config_template="default.jsonc"
        ;;
    *)
        notify-send -u critical "Error" "Unknown layout..." -h string:x-canonical-private-synchronous:waybar_layout_changer
        exit 1
        ;;
esac

echo "$config_template" > "$state_file"

ln -sf "$styles_dir/$style_file" "$target_css"

envsubst < "$templates_dir/$config_template" > "$target_config"
envsubst < "$HOME/.mio-os/.config/waybar/templates/modules/hyprland-workspaces.jsonc" > "$HOME/.mio-os/.config/waybar/modules/hyprland-workspaces.jsonc"
envsubst < "$HOME/.mio-os/.config/waybar/templates/modules/hyprland-language.jsonc" > "$HOME/.mio-os/.config/waybar/modules/hyprland-language.jsonc"

notify-send -i "dialog-information-symbolic" "Waybar updated" "Layout: $selected" -h string:x-canonical-private-synchronous:waybar_layout_changer -t 2000

if pgrep -x "waybar" > /dev/null; then
    killall waybar && waybar & disown
else
    waybar & disown
fi
