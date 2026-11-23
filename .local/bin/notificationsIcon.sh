excludeStackTags=(
    "osd"
    "gamemode"
    "wallpaper_changer"
    "waybar_layout_changer"
)

excl=$(jq -nc '$ARGS.positional' --args "${excludeStackTags[@]}")

count=$(dunstctl history 2>/dev/null | jq --argjson excl "$excl" '
    [ (.data[0] // [])[]
      | select((.stack_tag.data // "") as $t | ($excl | index($t)) == null)
    ] | length' 2>/dev/null)

paused=$(dunstctl is-paused)

jq -nc --argjson n "${count:-0}" --arg p "$paused" '
    (if $p == "true" then "dnd"
     elif $n > 0 then "has"
     else "empty" end) as $s
    | {
        text:    ($n | tostring),
        alt:     $s,
        class:   $s,
        tooltip: (if $p == "true" then "Do not disturb (notifications: \($n))"
                  elif $n > 0 then "Notifications: \($n)"
                  else "Empty" end)
    }'
