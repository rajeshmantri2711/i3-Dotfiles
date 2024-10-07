#!/bin/bash

# Function to get microphone mute status
get_mic_status() {
    if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q "yes"; then
        echo "disabled"  # Muted mic
    else
        echo "enabled"  # Active mic
    fi
}

# Function to toggle microphone mute status
toggle_mic() {
    pactl set-source-mute @DEFAULT_SOURCE@ toggle
}

# Main logic for the script
if [ "$1" == "toggle" ]; then
    toggle_mic
else
    mic_status=$(get_mic_status)
    if [ "$mic_status" == "enabled" ]; then
        echo ""
    else
        echo "󰍭"
    fi
fi
