#!/bin/bash

ADB="/home/arinji/scrcpy/adb"
SCRCPY="/home/arinji/scrcpy/scrcpy"
AUDIO_DEVICE="bt_a2dp"
SCRCPY_ID_FILE="/tmp/.scrcpy_hidden_window_id"

get_current_volume() {
    $ADB shell dumpsys audio | grep -A 10 "STREAM_MUSIC" |
        grep "Current:" |
        grep -m1 -o "80 ($AUDIO_DEVICE): [0-9]*" |
        grep -o "[0-9]*$"
}

set_volume_level() {
    local current="$1"
    echo "Current volume: $current"
    local target="$2"

    diff=$((target - current))
    if (( diff > 0 )); then
        for ((i = 0; i < diff; i++)); do
            $ADB shell input keyevent KEYCODE_VOLUME_UP
        done
    elif (( diff < 0 )); then
        for ((i = 0; i < -diff; i++)); do
            $ADB shell input keyevent KEYCODE_VOLUME_DOWN
        done
    fi
}

volume_slider() {
    max_volume=16
    current_level=$(get_current_volume)
    if [[ -z "$current_level" ]]; then
        current_level=5
    fi
    level=$current_level

    while true; do
        clear
        echo "🔊 ADB Volume Controller"
        echo
        echo "Current Volume: $current_level"
        echo "Target Volume : $level"
        echo
        echo "[↑] Increase | [↓] Decrease | [↵] Apply | [q] Quit"
        echo

        IFS= read -rsn1 key
        if [[ $key == $'\x1b' ]]; then
            read -rsn2 key
            case $key in
                '[A') ((level < max_volume)) && ((level++)) ;;
                '[B') ((level > 0)) && ((level--)) ;;
            esac
        elif [[ $key == "" ]]; then
            echo "📡 Sending ADB volume set..."
            set_volume_level "$current_level" "$level"
            echo "✅ Volume set to $level"
            sleep 1
            return
        elif [[ $key == "q" ]]; then
            echo "👋 Bye!"
            sleep 0.5
            return
        fi
    done
}

scrcpy_toggle() {
    echo "📱 Launching scrcpy..."
    nohup $SCRCPY >/dev/null 2>&1 &
    sleep 1.5
    wmctrl -r :ACTIVE: -b toggle,above
    wmctrl -r :ACTIVE: -e 0,0,0,-1,-1
    echo "📌 Scrcpy launched and pinned."
    exit 0
}

scrcpy_kill() {
    echo "🛑 Closing all scrcpy windows..."
    pkill -f scrcpy
    [[ -f "$SCRCPY_ID_FILE" ]] && rm "$SCRCPY_ID_FILE"
    echo "✅ Done!"
    sleep 1
}

hide_scrcpy_if_running() {
    pid=$(pgrep -f "$SCRCPY" | head -n 1)
    if [[ -n "$pid" ]]; then
        win_id=$(xdotool search --pid "$pid" | head -n 1)
        if [[ -n "$win_id" ]]; then
            echo "$win_id" > "$SCRCPY_ID_FILE"

            xdotool windowminimize "$win_id"
        fi
    fi
}

restore_scrcpy_if_hidden() {
    if [[ -f "$SCRCPY_ID_FILE" ]]; then
        win_id=$(head -n 1 "$SCRCPY_ID_FILE")

        xdotool windowmove "$win_id" 0 0

        wmctrl -i -r "$win_id" -b remove,hidden
        wmctrl -i -r "$win_id" -b remove,minimized
        wmctrl -i -r "$win_id" -b add,above
        sleep 0.2
        wmctrl -i -a "$win_id"

        rm "$SCRCPY_ID_FILE"
    fi
}

open_app_menu() {
    declare -A apps=(
        [1]="Chrome:com.android.chrome"
        [2]="YouTube:com.google.android.youtube"
        [3]="Spotify:com.spotify.music"
        [4]="WhatsApp:com.whatsapp"
        [5]="Instagram:com.instagram.android"
        [6]="Github:com.github.android"
        [7]="Back"
    )

    while true; do
        clear
        echo "📱 Open App on Device"
        echo
        for i in "${!apps[@]}"; do
            name="${apps[$i]%%:*}"
            echo "$i) $name"
        done
        echo

        read -rp "Pick an app [1-7]: " choice
        app_entry="${apps[$choice]}"

        if [[ "$app_entry" == "Back" || -z "$app_entry" ]]; then
            return
        fi

        pkg="${app_entry#*:}"
        echo "🚀 Launching ${app_entry%%:*}..."
        $ADB shell monkey -p "$pkg" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
        echo "✅ Done!"
        sleep 1
    done
}

main_menu() {
    hide_scrcpy_if_running

    while true; do
        clear
        echo "🎮 ADB Command Center"
        echo
        echo "1) 🔊 Volume Control"
        echo "2) ⏯️ Play / Pause (instant)"
        echo "3) 📌 Open Scrcpy (pinned)"
        echo "4) ❌ Kill Scrcpy"
        echo "5) 📱 Open App"
        echo "6) 🚪 Exit"
        echo
        read -rp "Pick an option [1-6]: " opt

        case "$opt" in
            1) volume_slider ;;
            2) 
                $ADB shell input keyevent KEYCODE_MEDIA_PLAY_PAUSE
                restore_scrcpy_if_hidden
                exit
                ;;
            3) scrcpy_toggle ;;
            4) scrcpy_kill ;;
            5) open_app_menu ;;
            6) 
                echo "🚪 Exiting..."
                restore_scrcpy_if_hidden
                exit
                ;;
            *) echo "❌ Invalid option"; sleep 1 ;;
        esac
    done
}

main_menu
