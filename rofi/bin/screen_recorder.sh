#!/bin/bash


OUTPUT_DIR="$HOME/Videos"
mkdir -p "$OUTPUT_DIR"


PID_FILE="/tmp/ssr_recorder.pid"
CURRENT_FILE="/tmp/ssr_current_file.txt"
SETTINGS_FILE="/tmp/ssr_settings_file.conf"


start_recording() {
   if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
       echo " Recording is already in progress."
       exit 1
   fi


   FILE_NAME="ScreenRecording_$(date '+%Y-%m-%d_%H-%M').mp4"
   FULL_PATH="$OUTPUT_DIR/$FILE_NAME"
   echo "$FULL_PATH" > "$CURRENT_FILE"


   # Generate settings file
   cat > "$SETTINGS_FILE" <<EOL
[general]
video_filename=$FULL_PATH
video_codec=libx264
video_preset=slow
video_crf=18
audio_input=default
audio_codec=aac
video_fps=30
video_width=1920
video_height=1080
EOL


   # Start SSR hidden and keep it running
   # Redirect stdin from a named pipe
   PIPE="/tmp/ssr_pipe_$$"
   mkfifo "$PIPE"


   simplescreenrecorder --start-hidden --no-systray --settingsfile="$SETTINGS_FILE" < "$PIPE" &
   SSR_PID=$!
   echo $SSR_PID > "$PID_FILE"


   # Give SSR time to initialize, then start recording
   echo "record-start" > "$PIPE"


   # Give a small delay to ensure SSR picks up the command
   sleep 1
   echo " Recording started"


   # Keep pipe open for commands
   exec 3>"$PIPE"
}


stop_recording() {
   if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
       SSR_PID=$(cat "$PID_FILE")


       # Use the same named pipe to send stop command
       PIPE="/tmp/ssr_pipe_$SSR_PID"
       if [ ! -p "$PIPE" ]; then
           PIPE="/tmp/ssr_pipe_$$"
       fi


       # Send record-save
       echo "record-save" > "$PIPE"
       sleep 1


       # Kill the process
       kill $SSR_PID 2>/dev/null
       rm -f "$PID_FILE" "$CURRENT_FILE" "$SETTINGS_FILE" "$PIPE"
       echo " Recording stopped"
   else
       echo "No recording in progress."
   fi
}


case "$1" in
   start|Start)
       start_recording
       ;;
   stop|Stop)
       stop_recording
       ;;
   *)
       echo "Usage: $0 start|stop"
       ;;
esac





