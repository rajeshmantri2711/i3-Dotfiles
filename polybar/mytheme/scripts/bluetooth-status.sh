#!/bin/bash

# Function to get Bluetooth status
get_bluetooth_status() {
    status=$(bluetoothctl show | grep 'Powered' | awk '{print $2}')
    connected=$(bluetoothctl info | grep 'Connected' | awk '{print $2}' | head -n 1)
    echo "$status $connected"
}

# Function to toggle Bluetooth
toggle_bluetooth() {
    status=$(bluetoothctl show | grep 'Powered' | awk '{print $2}')
    if [ "$status" = "yes" ]; then
        bluetoothctl power off
    else
        bluetoothctl power on
    fi
}

# Get current Bluetooth status
read status connected < <(get_bluetooth_status)

# Determine icon and status text
if [ "$status" = "yes" ]; then
    if [ "$connected" = "yes" ]; then
        icon="󰂱"  # Connected
        echo -e "$icon"  # White icon
    else
        icon="󰂲"  # On but not connected
        echo -e "$icon On"  # White icon
    fi
else
    echo -e "󰂯 Off"  # Blue icon for off
fi

# Handle left and right click actions
case "$1" in
    left)
        toggle_bluetooth
        ;;
    right)
        ~/.config/rofi/bin/bluetooth
        ;;
esac

