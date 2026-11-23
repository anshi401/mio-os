#!/bin/bash

choice=$(printf "\n󰤄\n󰩈\n\n" | rofi -dmenu -config ~/.mio-os/.config/rofi/styles/powerMenu.rasi)

case "$choice" in
    "") hyprlock ;;
    "󰤄") systemctl suspend;;
    "󰩈") hyprctl dispatch exit;;
    "") systemctl reboot ;;
    "") systemctl poweroff ;;
esac
