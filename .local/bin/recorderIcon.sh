#!/bin/bash

run="${XDG_RUNTIME_DIR:-/tmp}"
rec_pid="$run/gsr-record.pid"
replay_pid="$run/gsr-replay.pid"

running() {
    [ -f "$1" ] && kill -0 "$(cat "$1")" 2>/dev/null
}

text=""
tooltip=""
class=""

if running "$rec_pid"; then
    text=$''
    tooltip="Recording in progress"
    class="recording"
fi

if running "$replay_pid"; then
    text="${text:+$text }"$'󰋚'
    tooltip="${tooltip:+$tooltip\\n}Replay buffer active"
    class="${class:-replay}"
fi

# Пустой text скрывает модуль в waybar
printf '{"text": "%s", "tooltip": "%s", "class": "%s"}\n' "$text" "$tooltip" "$class"
