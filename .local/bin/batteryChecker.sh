#!/bin/bash

critical=10
low=25

bat_path=$(upower -e | grep -m 1 'battery')

if [ -z "$bat_path" ]; then
    exit 0
fi

last_level="NONE"
last_status=""
full_notified=0

notify() {
    local urg=()
    [ -n "$5" ] && urg=(-u "$5")
    notify-send "${urg[@]}" -i "$1" "$2" "$3" \
        -h string:x-canonical-private-synchronous:battery_status -t "$4" &
}

check_battery() {
    local info capacity status

    info=$(upower -i "$bat_path")
    capacity=$(echo "$info" | awk '/percentage:/ {print $2}' | tr -d '%')
    status=$(echo "$info" | awk '/state:/ {print $2}')
    capacity=${capacity%.*}

    [ -z "$capacity" ] || [ -z "$status" ] && return

    if [ -z "$last_status" ]; then
        last_status="$status"
    fi

    if [ "$status" != "discharging" ]; then
        last_level="NONE"

        if [ "$last_status" = "discharging" ]; then
            notify "battery-good-charging-symbolic" "Charging" "Adapter plugged in ($capacity%)" 3000
        fi

        if [ "$status" = "fully-charged" ] || [ "$status" = "pending-charge" ]; then
            if [ "$full_notified" -eq 0 ]; then
                notify "battery-full-symbolic" "Battery full" "Charge: $capacity%" 2000
                full_notified=1
            fi
        else
            full_notified=0
        fi
    else
        full_notified=0

        if [ "$last_status" != "discharging" ]; then
            notify "battery-good-symbolic" "Discharging" "Adapter unplugged ($capacity%)" 3000
        fi

        if [ "$capacity" -gt "$low" ]; then
            last_level="NONE"
        fi

        if [ "$last_level" = "NONE" ] && [ "$capacity" -le "$low" ] && [ "$capacity" -gt "$critical" ]; then
            notify "battery-low-symbolic" "Battery low" "Capacity: $capacity%" 5000
            last_level="LOW"
        fi

        if [ "$last_level" != "CRITICAL" ] && [ "$capacity" -le "$critical" ]; then
            notify "battery-empty-symbolic" "Battery critical" "Capacity: $capacity%" 0 critical
            last_level="CRITICAL"
        fi
    fi

    last_status="$status"
}

check_battery

upower --monitor | grep --line-buffered "$bat_path" | while read -r _; do
    check_battery
done
