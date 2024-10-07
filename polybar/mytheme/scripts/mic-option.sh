#!/usr/bin/env bash

# Rofi command with theme
rofi_command="rofi -theme $HOME/.config/rofi/config/mic-menu.rasi"

# Get system uptime
uptime=$(uptime -p | sed -e 's/up //g')

# Options for microphone settings
mic_on="󰍬  Enable Mic"
mic_off="󰍭  Disable Mic"
mic_settings="󰍲  Open Mic Settings"

# List of options
options="$mic_on\n$mic_off\n$mic_settings"

# Display options with Rofi
chosen=$(echo -e "$options" | $rofi_command -p "Mic Settings" -dmenu -selected-row 0)

# Execute selected action
case $chosen in
    "$mic_on")
        pactl set-source-mute @DEFAULT_SOURCE@ 0  # Unmute microphone
        ;;
    "$mic_off")
        pactl set-source-mute @DEFAULT_SOURCE@ 1  # Mute microphone
        ;;
    "$mic_settings")
        pavucontrol --tab=3  # Open PulseAudio Volume Control directly to the input devices tab (microphone settings)
        ;;
esac
