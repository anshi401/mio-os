#!/bin/bash

if [ "$1" = "start" ]; then
    notify-send -i "applications-games-symbolic" "Gamemode" "Enabled" -h string:x-canonical-private-synchronous:gamemode -t 2000
    exit 0
elif [ "$1" = "end" ]; then
    notify-send -i "applications-games-symbolic" "Gamemode" "Disabled" -h string:x-canonical-private-synchronous:gamemode -t 2000
    exit 0
else
    echo "Usage: $0 [start|end]" >&2
    exit 1
fi
