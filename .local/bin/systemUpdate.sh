#!/bin/bash

red=$(tput setaf 1; tput bold)
yellow=$(tput setaf 3; tput bold)
green=$(tput setaf 2; tput bold)
blue=$(tput setaf 4; tput bold)
reset=$(tput sgr0)

echo -e "${yellow}::${reset} Starting system update..."
echo

echo -e "${blue}::${reset} Checking for available updates..."
repo_updates=$(CHECKUPDATES_DB="/tmp/checkup-db-$USER-script" checkupdates 2>/dev/null)
aur_updates=$(paru -Qua 2>/dev/null)

if [[ -z "$repo_updates" && -z "$aur_updates" ]]; then
    echo -e "${green}::${reset} No updates available."
else
    if [[ -n "$repo_updates" ]]; then
        echo -e "\n${blue}::${reset} Repository packages ($(wc -l <<< "$repo_updates")):"
        column -t <<< "$repo_updates"
    fi

    if [[ -n "$aur_updates" ]]; then
        echo -e "\n${blue}::${reset} AUR packages ($(wc -l <<< "$aur_updates")):"
        column -t <<< "$aur_updates"
    fi
fi
echo

if paru -Syu; then
    echo -e "\n${green}::${reset} System update completed successfully!"
    notify-send -i "dialog-information-symbolic" "System Update" "Packages updated successfully!" -h string:x-canonical-private-synchronous:system_update -t 2000

    echo
    echo -en "${yellow}::${reset} Do you want to reboot now? (y/N): "
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "${red}::${reset} Rebooting system..."
        sleep 1
        systemctl reboot
    fi
else
    echo -e "\n${red}::${reset} System update failed..."
    notify-send -i "dialog-error-symbolic" -u critical "System Update" "An error occurred during update..." -h string:x-canonical-private-synchronous:system_update
fi

if pgrep -x waybar >/dev/null; then
    pkill -SIGRTMIN+8 waybar
fi

echo -e "${yellow}::${reset} Press Enter to exit..."
read
