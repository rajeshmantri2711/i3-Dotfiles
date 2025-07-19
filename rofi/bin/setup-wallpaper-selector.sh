#!/usr/bin/env bash

# July 19, 2025

set -e

echo "Wallpaper Selector Auto Setup Starting..."
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required directories exist
print_status "Checking directory structure..."

REQUIRED_DIRS=(
    "$HOME/.config/rofi/bin"
    "$HOME/.config/rofi/config" 
    "$HOME/.config/polybar/Wallpaper"
    "$HOME/.config/rofi/logs"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ ! -d "$dir" ]]; then
        print_status "Creating directory: $dir"
        mkdir -p "$dir"
    else
        print_status "Directory exists: $dir"
    fi
done

# Make wallpaper-selector executable
print_status "Setting up wallpaper-selector permissions..."
if [[ -f "$HOME/.config/rofi/bin/wallpaper-selector" ]]; then
    chmod +x "$HOME/.config/rofi/bin/wallpaper-selector"
    print_status "wallpaper-selector made executable"
else
    print_error "wallpaper-selector not found at $HOME/.config/rofi/bin/wallpaper-selector"
    exit 1
fi

# Create/Update auto-wallpaper script
print_status "Creating auto-wallpaper script..."
cat > "$HOME/.config/rofi/bin/auto-wallpaper" << 'EOF'
#!/usr/bin/env bash

# Auto wallpaper changer - runs the wallpaper selector in auto mode
# This script can be called by cron or systemd timer

# Set display for GUI applications (needed when run from cron)
export DISPLAY=:0

# Run the wallpaper selector in auto mode
~/.config/rofi/bin/wallpaper-selector --auto

# Log the execution
echo "$(date): Auto wallpaper changed" >> ~/.config/rofi/logs/auto-wallpaper.log
EOF

chmod +x "$HOME/.config/rofi/bin/auto-wallpaper"
print_status "auto-wallpaper script created and made executable"

# Setup cron jobs for automatic wallpaper switching
print_status "Setting up cron jobs..."

# Backup existing crontab
print_status "Backing up existing crontab..."
crontab -l 2>/dev/null > /tmp/crontab_backup.txt || echo "# No existing crontab" > /tmp/crontab_backup.txt

# Remove any existing auto-wallpaper entries
print_status "Removing old auto-wallpaper cron entries..."
crontab -l 2>/dev/null | grep -v "auto-wallpaper" > /tmp/new_crontab.txt || echo "# Current crontab" > /tmp/new_crontab.txt

# Add new cron entries for three time periods
print_status "Adding new cron entries for wallpaper switching..."
cat >> /tmp/new_crontab.txt << EOF

# Auto wallpaper changer - three time periods
# 6:00 AM - Switch to daytime wallpaper (white.png)
0 6 * * * DISPLAY=:0 $HOME/.config/rofi/bin/auto-wallpaper >/dev/null 2>&1

# 6:00 PM - Switch to evening wallpaper (windblown.jpg)  
0 18 * * * DISPLAY=:0 $HOME/.config/rofi/bin/auto-wallpaper >/dev/null 2>&1

# 10:00 PM - Switch to nighttime wallpaper (dark.png)
0 22 * * * DISPLAY=:0 $HOME/.config/rofi/bin/auto-wallpaper >/dev/null 2>&1
EOF

# Install the new crontab
crontab /tmp/new_crontab.txt
print_status "Cron jobs installed successfully"

# Show current cron jobs
print_status "Current cron jobs:"
echo -e "${BLUE}"
crontab -l | grep -A 10 -B 2 "auto-wallpaper" || echo "No auto-wallpaper entries found"
echo -e "${NC}"

# Add auto-wallpaper to i3 startup (if not already present)
print_status "Checking i3 config for auto-wallpaper startup..."
I3_CONFIG="$HOME/.config/i3/config"

if [[ -f "$I3_CONFIG" ]]; then
    if ! grep -q "auto-wallpaper" "$I3_CONFIG"; then
        print_status "Adding auto-wallpaper to i3 startup..."
        echo "exec_always --no-startup-id ~/.config/rofi/bin/auto-wallpaper" >> "$I3_CONFIG"
        print_status "auto-wallpaper added to i3 config"
    else
        print_status "auto-wallpaper already in i3 config"
    fi
else
    print_warning "i3 config not found at $I3_CONFIG"
fi

# Test the wallpaper selector
print_status "Testing wallpaper selector functionality..."
if "$HOME/.config/rofi/bin/wallpaper-selector" --auto; then
    print_status "Wallpaper selector test successful"
else
    print_error "Wallpaper selector test failed"
fi

# Create a reset script for manual override clearing
print_status "Creating wallpaper reset script..."
cat > "$HOME/.config/rofi/bin/reset-wallpaper" << 'EOF'
#!/usr/bin/env bash

# Reset wallpaper to automatic mode
# Removes manual selection and applies time-based wallpaper

echo "Resetting wallpaper to automatic mode..."

# Remove manual selection file
rm -f /tmp/wallpaper_selection

# Apply automatic wallpaper based on current time
~/.config/rofi/bin/wallpaper-selector --auto

echo "Wallpaper reset to automatic mode"
EOF

chmod +x "$HOME/.config/rofi/bin/reset-wallpaper"
print_status "Reset script created at ~/.config/rofi/bin/reset-wallpaper"

# Create status checker script
print_status "Creating wallpaper status script..."
cat > "$HOME/.config/rofi/bin/wallpaper-status" << 'EOF'
#!/usr/bin/env bash

# Check wallpaper selector status and current selection

echo "Wallpaper Selector Status"
echo "=========================="

# Check if manual selection is active
if [[ -f "/tmp/wallpaper_selection" ]]; then
    manual_selection=$(cat /tmp/wallpaper_selection)
    echo "Mode: MANUAL OVERRIDE"
    echo "Current: $manual_selection"
    echo "Override active until system restart"
else
    echo "Mode: AUTOMATIC (time-based)"
    current_hour=$(date +%H)
    current_hour=$((10#$current_hour))
    
    if [[ $current_hour -ge 6 && $current_hour -lt 18 ]]; then
        echo "Current: white.png (Daytime 6AM-6PM)"
    elif [[ $current_hour -ge 18 && $current_hour -lt 22 ]]; then
        echo "Current: windblown.jpg (Evening 6PM-10PM)"
    else
        echo "Current: dark.png (Night 10PM-6AM)"
    fi
fi

echo ""
echo "Time: $(date +%H:%M)"
echo "Cron jobs active: $(crontab -l 2>/dev/null | grep -c auto-wallpaper || echo 0)"

# Check recent log entries
if [[ -f "$HOME/.config/rofi/logs/auto-wallpaper.log" ]]; then
    echo ""
    echo "Recent auto changes:"
    tail -5 "$HOME/.config/rofi/logs/auto-wallpaper.log" 2>/dev/null || echo "No recent logs"
fi
EOF

chmod +x "$HOME/.config/rofi/bin/wallpaper-status"
print_status "Status script created at ~/.config/rofi/bin/wallpaper-status"

# Summary
echo ""
echo -e "${GREEN}========================================="
echo "Setup Complete!"
echo "=========================================${NC}"
echo ""
echo -e "${BLUE}Files Created:${NC}"
echo "   • ~/.config/rofi/bin/auto-wallpaper (automatic switching)"
echo "   • ~/.config/rofi/bin/reset-wallpaper (reset to auto mode)" 
echo "   • ~/.config/rofi/bin/wallpaper-status (check current status)"
echo ""
echo -e "${BLUE}Schedule Setup:${NC}"
echo "   • 6:00 AM  → white.png (Daytime)"
echo "   • 6:00 PM  → windblown.jpg (Evening)"
echo "   • 10:00 PM → dark.png (Night)"
echo ""
echo -e "${BLUE}Usage:${NC}"
echo "   • Run wallpaper selector: ~/.config/rofi/bin/wallpaper-selector"
echo "   • Manual selection persists until reboot"
echo "   • Reset to auto mode: ~/.config/rofi/bin/reset-wallpaper"
echo "   • Check status: ~/.config/rofi/bin/wallpaper-status"
echo ""
echo -e "${BLUE}Features:${NC}"
echo "   • 3-period automatic switching"
echo "   • Manual override with persistence"
echo "   • Cron job automation"
echo "   • i3 startup integration"
echo "   • 3x3 grid wallpaper selector"
echo "   • Color theme synchronization"
echo ""
echo -e "${GREEN}Ready to use! Restart i3 or reboot to see full functionality.${NC}"
