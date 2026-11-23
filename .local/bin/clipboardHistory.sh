#!/bin/bash

wipe_label="   Wipe history"

result=$(
    {
        printf '0\t%s\n' "$wipe_label"
        cliphist list
    } | rofi -dmenu -display-columns 2 -config ~/.mio-os/.config/rofi/styles/clipboardHistory.rasi
)

if [ -n "$result" ]; then
    if [ "$result" = $'0\t'"$wipe_label" ]; then
        cliphist wipe
    else
        echo "$result" | cliphist decode | wl-copy
    fi
fi
