#!/bin/bash

# Get Wi-Fi and Ethernet statuses
wifi_status=$(nmcli radio wifi)
wifi_connected=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
wifi_signal=$(nmcli -t -f active,signal dev wifi | grep '^yes' | cut -d: -f2)
ethernet_connected=$(nmcli device status | grep ethernet | grep connected)

# Check Ethernet status first
if [ -n "$ethernet_connected" ]; then
    echo "󰈀"  # Ethernet connected
elif [ "$wifi_status" = "enabled" ]; then
    if [ -n "$wifi_connected" ]; then
        essid=$(echo "$wifi_connected")
        if [ -n "$wifi_signal" ]; then
            echo "$essid|$wifi_signal"  # Wi-Fi on and connected with signal strength
        else
            echo "$essid (404)"  # Fallback if signal is not detected
        fi
    else
        echo "󰤭"  # Wi-Fi on but not connected
    fi
else
    echo "󰤩"  # Wi-Fi off
fi
