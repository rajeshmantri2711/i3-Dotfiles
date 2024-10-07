#!/bin/bash

# Function to get volume percentage
get_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%'
}

# Function to check if muted
is_muted() {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -oP '(yes|no)' | grep 'yes' > /dev/null && echo "muted" || echo "unmuted"
}

# Function to get headphone/Bluetooth connection status
get_audio_output() {
    if [[ $(pactl list short sinks | grep "RUNNING") == *"bluez_sink"* ]]; then
        echo "bluetooth"
    elif [[ $(pactl list sinks | grep "analog-output-headphones") ]]; then
        echo "headphones"
    else
        echo "speakers"
    fi
}

# Function to get volume icon
get_volume_icon() {
    local volume=$1
    local output=$2

    if [ "$output" == "bluetooth" ] || [ "$output" == "headphones" ]; then
        echo ""  # Bluetooth or Headphone icon
    else
        if [ "$volume" -eq 0 ]; then
            echo ""  # Volume 0%
        elif [ "$volume" -le 50 ]; then
            echo ""  # Volume 1-50%
        else
            echo ""  # Volume 51-100%
        fi
    fi
}

# Main logic to show volume
show_volume() {
    local volume=$(get_volume)
    local muted=$(is_muted)
    local output=$(get_audio_output)

    if [ "$muted" == "muted" ]; then
        echo "ﱝ Muted"
    else
        local icon=$(get_volume_icon $volume $output)
        echo "$icon $volume%"
    fi
}

# Toggle mute/unmute on click
if [ "$1" == "click" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ toggle
else
    show_volume
fi
