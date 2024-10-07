#!/usr/bin/env bash

# Get the status of the currently playing track and app
playerctlstatus=$(playerctl -p spotify status 2> /dev/null)

# Get the current app name and check if it's playing
current_app=$(playerctl -l | head -n 1)  # Get the name of the currently playing app

if [[ -z $playerctlstatus ]]; then
    echo "󰝚"  # Not playing
elif [[ $playerctlstatus == "Playing" ]]; then
    # Get the artist and title of the currently playing track
    ARTIST=$(playerctl -p spotify metadata artist 2> /dev/null)
    TITLE=$(playerctl -p spotify metadata title 2> /dev/null)

    # Combine artist and title
    TRACK_INFO="$ARTIST - $TITLE"
    
    # Limit the length of the track info to fit your bar
    if [[ ${#TRACK_INFO} -gt 40 ]]; then
        # Set the length for auto-scrolling
        TRACK_INFO="${TRACK_INFO:0:40}... "
        SCROLL_FORMAT="%{O1}%{A1:playerctl pause:}%{A} $TRACK_INFO %{A1:playerctl play:}%{A}"
    else
        SCROLL_FORMAT="%{A1:playerctl pause:}%{A} $TRACK_INFO %{A1:playerctl play:}%{A}"
    fi
    
    # Display app name alongside track info
    echo "Playing on $current_app: $SCROLL_FORMAT"
else
    echo " %{A1:playerctl play:}%{A}"  # Paused
fi

