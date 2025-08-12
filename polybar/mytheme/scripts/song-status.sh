#!/usr/bin/env bash

# Find active Chromium player dynamically
find_chromium_player() {
    for player in $(playerctl -l 2>/dev/null | grep chromium | head -1); do
        if playerctl -p "$player" metadata title >/dev/null 2>&1; then
            echo "$player"
            return
        fi
    done
}

spotify_status=$(playerctl -p spotify status 2>/dev/null)
chromium_player=$(find_chromium_player)
chromium_status=""

if [[ -n "$chromium_player" ]]; then
    chromium_status=$(playerctl -p "$chromium_player" status 2>/dev/null)
fi

if [[ $spotify_status == "Playing" ]]; then
    ARTIST=$(playerctl -p spotify metadata artist 2>/dev/null)
    TITLE=$(playerctl -p spotify metadata title 2>/dev/null)
    echo " %{A1:playerctl pause -p spotify:}%{A} $ARTIST - $TITLE"
elif [[ $chromium_status == "Playing" ]]; then
    ARTIST=$(playerctl -p "$chromium_player" metadata artist 2>/dev/null)
    TITLE=$(playerctl -p "$chromium_player" metadata title 2>/dev/null)
    echo " %{A1:playerctl pause -p $chromium_player:}%{A} $ARTIST - $TITLE"
elif [[ $spotify_status == "Paused" ]]; then
    echo " %{A1:playerctl play -p spotify:} %{A} paused "
elif [[ $chromium_status == "Paused" ]]; then
    echo " %{A1:playerctl play -p $chromium_player:} %{A} paused "
else
    echo "Choices Have Consequences"
fi


