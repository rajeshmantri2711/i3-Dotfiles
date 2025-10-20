#!/bin/bash
# filepath: /home/raj/.config/rofi/bin/ssr_status.sh

PID_FILE="/tmp/ssr_recorder.pid"

if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
    echo "rec"
else
    echo ""
fi
