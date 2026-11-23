#!/bin/bash

clearLabel="   Wipe notifications"
dndOnLabel=" 󰂛  Do not disturb: on"
dndOffLable=" 󰂚  Do not disturb: off"
deleteLabel="   Delete notification"
repopLabel="   Show again"
backLabel="   Back"

headerLines=2

waybarSignal=9

excludeStackTags=(
    "osd"
    "gamemode"
    "wallpaper_changer"
    "waybar_layout_changer"
)

purgeExclude=false

boot_time() {
    awk -v now="$(date +%s)" '{ printf "%d", now - $1 }' /proc/uptime
}

exclude_json() {
    jq -nc '$ARGS.positional' --args "${excludeStackTags[@]}"
}

get_history() {
    dunstctl history | jq -c \
        --argjson boot "$(boot_time)" \
        --argjson excl "$(exclude_json)" '
        [ (.data[0] // [])[]
          | select((.stack_tag.data // "") as $t | ($excl | index($t)) == null)
          | {
            id:        .id.data,
            appname:   (.appname.data // ""),
            summary:   (.summary.data // ""),
            body:      (.body.data // ""),
            stack_tag: (.stack_tag.data // ""),
            ts:        (((.timestamp.data // 0) / 1000000 + $boot) | floor)
        } ]'
}

purgeExclude() {
    [[ "$purgeExclude" == true && ${#excludeStackTags[@]} -gt 0 ]] || return 0
    local id
    while read -r id; do
        dunstctl history-rm "$id"
    done < <(dunstctl history | jq -r --argjson excl "$(exclude_json)" '
        (.data[0] // [])[]
        | select((.stack_tag.data // "") as $t | ($excl | index($t)) != null)
        | .id.data')
}

format_lines() {
    jq -r '
        def clean: gsub("<[^>]*>"; "") | gsub("[\n\r\t]+"; " ")
                   | gsub("&amp;"; "&") | gsub("&lt;"; "<") | gsub("&gt;"; ">");
        .[] | "\(.ts | localtime | strftime("%d.%m %H:%M"))  [\(.appname)]  \(.summary | clean)  —  \(.body | clean)"
    ' <<<"$1"
}

dnd_label() {
    if [[ "$(dunstctl is-paused)" == "true" ]]; then
        printf '%s' "$dndOnLabel"
    else
        printf '%s' "$dndOffLable"
    fi
}

toggle_dnd() {
    dunstctl set-paused toggle
    pkill -RTMIN+"$waybarSignal" waybar 2>/dev/null || true
}

notification_menu() {
    local hist="$1" idx="$2"
    local id summary body appname mesg options choice

    id=$(jq -r ".[$idx].id" <<<"$hist")
    appname=$(jq -r ".[$idx].appname" <<<"$hist")
    summary=$(jq -r ".[$idx].summary" <<<"$hist")
    body=$(jq -r ".[$idx].body" <<<"$hist")

    mesg=$(jq -rn --arg a "$appname" --arg s "$summary" --arg b "$body" \
        '"<b>\($a)</b>\n<b>\($s | @html)</b>\n\n\($b | @html)"')

    options="$deleteLabel"$'\n'"$repopLabel"$'\n'"$backLabel"

    choice=$(printf '%s\n' "$options" | rofi -dmenu -i -no-custom -mesg "$mesg" -config ~/.mio-os/.config/rofi/styles/notificationsHistory.rasi)
    [[ $? -ne 0 ]] && return 1

    case "$choice" in
        "$deleteLabel")
            dunstctl history-rm "$id"
            pkill -RTMIN+"$waybarSignal" waybar 2>/dev/null || true
            ;;
        "$repopLabel")
            dunstctl history-pop "$id"
            sleep 0.2
            dunstctl context
            return 1
            ;;
        "$backLabel") ;;
    esac
    return 0
}

main() {
    local hist lines choice idx mesg
    purgeExclude
    while true; do
        hist=$(get_history)
        lines=$(format_lines "$hist")

        mesg=""
        [[ "$(jq length <<<"$hist")" -eq 0 ]] && mesg="Empty"

        choice=$(printf '%s\n%s\n%s\n' "$clearLabel" "$(dnd_label)" "$lines" \
                    | sed '/^$/d' \
                    | rofi -config ~/.mio-os/.config/rofi/styles/notificationsHistory.rasi \
                           -dmenu -i -no-custom -format i ${mesg:+-mesg "$mesg"})
                [[ $? -ne 0 ]] && exit 0

        case "$choice" in
            0)
                dunstctl history-clear
                pkill -RTMIN+"$waybarSignal" waybar 2>/dev/null || true
                exit 0
                ;;
            1)
                toggle_dnd
                continue
                ;;
        esac

        idx=$((choice - headerLines))
        notification_menu "$hist" "$idx" || exit 0
    done
}

main
