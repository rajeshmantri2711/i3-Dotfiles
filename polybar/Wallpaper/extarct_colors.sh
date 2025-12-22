#!/usr/bin/env bash

# Usage: ./extract_colors.sh <image_path>
if [ $# -ne 1 ]; then
    echo "Usage: $0 <image_path>"
    exit 1
fi

IMAGE="$1"
OUTPUT_FILE="colors_output.txt"
IMG_NAME=$(basename "$IMAGE")

# Make sure ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is required. Install it first."
    exit 1
fi

# Extract top 10 colors from the image
colors=($(convert "$IMAGE" -resize 50x50\! -format %c -colors 10 histogram:info:- \
    | sort -nr | awk '{print $3}' | sed 's/#/0x/'))

# Convert 0xRRGGBB to #RRGGBB
hex_colors=()
for c in "${colors[@]}"; do
    hex_colors+=("#$(printf '%06X' "$((c))")")
done

# Assign colors to keys
BG="${hex_colors[0]:-#212232}"    
BGA="${hex_colors[1]:-#63b4e3}"  
FG="${hex_colors[2]:-#FFFFFF}"    
FGA="${hex_colors[3]:-#FFFFFF}"   
BDR="${hex_colors[4]:-#CBA6F7}"   
SEL="${hex_colors[5]:-#FFFFFF}"   
UGT="${hex_colors[6]:-#F28FAD}"   
IMG="${hex_colors[7]:-#FAE3B0}"   
OFF="#575268"                     
ON="#00ff00"                      
BG_A="${hex_colors[0]:-#313244}"  

# Prepare output
output="Image: $IMG_NAME
BG:     $BG;
BGA:    $BGA;
FG:     $FG;
FGA:    $FGA;
BDR:    $BDR;
SEL:    $SEL;
UGT:    $UGT;
IMG:    $IMG;
OFF:    $OFF;
ON:     $ON;
BG-A:   $BG_A;
"

# Append to file
echo "$output" >> "$OUTPUT_FILE"

echo "Colors for $IMG_NAME saved to $OUTPUT_FILE"
