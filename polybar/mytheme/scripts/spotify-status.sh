#!/usr/bin/env bash

# Get the status of the currently playing track
playerctlstatus=$(playerctl -p spotify status 2> /dev/null)

if [[ -z $playerctlstatus ]]; then
    echo "󰝚"  # Not playing
elif [[ $playerctlstatus == "Playing" ]]; then
    # Get the artist and title of the currently playing track
    ARTIST=$(playerctl -p spotify metadata artist 2> /dev/null)
    TITLE=$(playerctl -p spotify metadata title 2> /dev/null)
    # Format output with play/pause button
    echo " %{A1:playerctl pause:}%{A} $ARTIST - $TITLE"
else
    echo " %{A1:playerctl play:} %{A} paused "  # Paused
fi

