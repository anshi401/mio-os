#!/bin/bash

dir="${settingsRecorderPath:-$HOME/Videos/Recordings}"
replay_dir="$dir/Replays"
run="${XDG_RUNTIME_DIR:-/tmp}"
rec_pid="$run/gsr-record.pid"
replay_pid="$run/gsr-replay.pid"

source="${settingsMainMonitor:-screen}"
audio="default_output|default_input"
fps=${settingsRecorderFPS:-60}
replay_secs=${settingsReplaySeconds:-60}
codec=${settingsRecorderCodec:-auto}
quality=${settingsRecorderQuality:-very_high}
bitrate_mode=${settingsRecorderBitrateMode:-auto}
container=${settingsRecorderContainer:-mkv}
cursor=${settingsRecorderCursor:-yes}
replay_storage=${settingsReplayStorage:-ram}
replay_date_folders=${settingsReplayDateFolders:-yes}

common=(-w "$source" -f "$fps" -a "$audio" -k "$codec" -q "$quality" -bm "$bitrate_mode" -cursor "$cursor")

mkdir -p "$dir" "$replay_dir"

notify() {
    [ "$(dunstctl is-paused)" = "true" ] && return
    notify-send -i "camera-video-symbolic" "Recorder" "$1" \
        -h string:x-canonical-private-synchronous:recorder -t 2000
}

running() {
    [ -f "$1" ] && kill -0 "$(cat "$1")" 2>/dev/null
}

stop() {
    kill -SIGINT "$(cat "$1")"
    rm -f "$1"
}

case "$1" in
    record)
        if running "$rec_pid"; then
            stop "$rec_pid"
            notify "Recording saved"
        else
            gpu-screen-recorder "${common[@]}" \
                -o "$dir/rec_$(date +%F_%H-%M-%S).$container" &
            echo $! > "$rec_pid"
            notify "Recording started"
        fi
        pkill -RTMIN+10 waybar
        ;;
    replay)
        if running "$replay_pid"; then
            stop "$replay_pid"
            notify "Replay buffer stopped"
        else
            gpu-screen-recorder "${common[@]}" \
                -c "$container" -r "$replay_secs" \
                -replay-storage "$replay_storage" -df "$replay_date_folders" \
                -o "$replay_dir" -restart-replay-on-save yes &
            echo $! > "$replay_pid"
            notify "Replay buffer started (${replay_secs}s)"
        fi
        pkill -RTMIN+10 waybar
        ;;
    save)
        if running "$replay_pid"; then
            kill -SIGUSR1 "$(cat "$replay_pid")"
            notify "Replay saved"
        else
            notify "Replay buffer is not running"
        fi
        ;;
    *)
        echo "Usage: $0 [record|replay|save]" >&2
        exit 1
        ;;
esac
