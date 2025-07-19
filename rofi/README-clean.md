# Automatic Wallpaper Selector System

A comprehensive wallpaper management system for i3 window manager with automatic time-based switching and manual override capabilities.

## Features

- **Time-based Auto Switching**: Three periods with different wallpapers
- **Manual Override**: Select any wallpaper manually, persists until reboot
- **3x3 Grid Interface**: Beautiful rofi grid layout for wallpaper selection
- **Color Synchronization**: Each wallpaper has custom color themes
- **Cron Automation**: Automatic switching at scheduled times
- **i3 Integration**: Starts automatically with your desktop

## Schedule

| Time Period | Wallpaper | Mode |
|-------------|-----------|------|
| 6:00 AM - 6:00 PM | white.png | Daytime |
| 6:00 PM - 10:00 PM | windblown.jpg | Evening |
| 10:00 PM - 6:00 AM | dark.png | Night |

## Quick Setup

Run the automated setup script:

```bash
~/.config/rofi/bin/setup-wallpaper-selector.sh
```

This will:
- Create all necessary directories
- Set up cron jobs for automatic switching
- Configure i3 startup integration
- Create helper scripts
- Test the system

## Usage

### Manual Wallpaper Selection
```bash
~/.config/rofi/bin/wallpaper-selector
```
- Opens 3x3 grid interface
- Select any wallpaper
- Selection persists until reboot
- Choose "Auto (Time-based)" to return to automatic mode

### Check Current Status
```bash
~/.config/rofi/bin/wallpaper-status
```
Shows current mode, active wallpaper, and recent changes

### Reset to Automatic Mode
```bash
~/.config/rofi/bin/reset-wallpaper
```
Clears manual override and applies time-based wallpaper

### Command Line Auto Mode
```bash
~/.config/rofi/bin/wallpaper-selector --auto
```

## File Structure

```
~/.config/rofi/
├── bin/
│   ├── wallpaper-selector          # Main selector with grid UI
│   ├── auto-wallpaper             # Cron job script
│   ├── reset-wallpaper            # Reset to auto mode
│   ├── wallpaper-status           # Status checker
│   └── setup-wallpaper-selector.sh # One-time setup
├── config/
│   ├── wallpaper-grid.rasi        # 3x3 grid theme
│   └── colors.rasi                # Dynamic color scheme
└── logs/
    └── auto-wallpaper.log         # Activity log
```

## Available Wallpapers

Located in `~/.config/polybar/Wallpaper/`:
- desk1.jpg
- goku.jpg
- hehe.png
- ice.png
- mountain.jpg
- night-time.jpeg
- nsfw.jpg
- pixel.png
- studio-ghibli.png
- white.png
- windblown.jpg
- dark.png
- yourname.jpg

## Color Themes

Each wallpaper automatically applies a matching color scheme:

- **White**: Light theme with dark text for daytime
- **Dark**: Custom dark theme with peachy accents for night
- **Windblown**: Blue sky theme for evening
- **Goku**: Orange and blue anime theme
- **Studio Ghibli**: Soft pastel theme
- **Night Time**: Deep dark theme with purple accents
- **Ice**: Cool blue/cyan theme
- **Mountain**: Nature theme with green accents
- And more custom themes...

## Automation Details

### Cron Jobs
The system creates these automatic switches:
```cron
# 6:00 AM - Daytime wallpaper
0 6 * * * DISPLAY=:0 ~/.config/rofi/bin/auto-wallpaper

# 6:00 PM - Evening wallpaper
0 18 * * * DISPLAY=:0 ~/.config/rofi/bin/auto-wallpaper

# 10:00 PM - Night wallpaper
0 22 * * * DISPLAY=:0 ~/.config/rofi/bin/auto-wallpaper
```

### Manual Override System
- Manual selections are stored in `/tmp/wallpaper_selection`
- File persists until system restart
- Automatic switching is disabled when override is active
- Reset script removes the override file

## Dependencies

- i3 window manager
- rofi (with theme support)
- nitrogen (wallpaper setter)
- cron (for scheduling)
- bash (for scripts)

## Troubleshooting

**Wallpapers not switching automatically:**
- Check if cron service is running: `systemctl status cron`
- Verify cron jobs: `crontab -l | grep auto-wallpaper`
- Check log file: `tail ~/.config/rofi/logs/auto-wallpaper.log`

**Manual selection not working:**
- Ensure wallpaper files exist in `~/.config/polybar/Wallpaper/`
- Check if nitrogen is installed: `which nitrogen`
- Test wallpaper selector: `~/.config/rofi/bin/wallpaper-selector --auto`

**Colors not updating:**
- Verify `colors.rasi` is being imported by rofi themes
- Check if rofi theme uses correct color variables
- Test color generation manually

**Override not clearing:**
- Run reset script: `~/.config/rofi/bin/reset-wallpaper`
- Or reboot the system
- Check if `/tmp/wallpaper_selection` file exists

## Advanced Usage

### Adding New Wallpapers
1. Place wallpaper file in `~/.config/polybar/Wallpaper/`
2. Add color scheme in `wallpaper-selector` script
3. Wallpaper will appear in grid automatically

### Customizing Time Periods
Edit the `auto_wallpaper()` function in `wallpaper-selector`:
```bash
if [[ $current_hour -ge 6 && $current_hour -lt 18 ]]; then
    # Modify time ranges here
```

### Custom Color Schemes
Each wallpaper case in `set_wallpaper_colors()` can be customized:
- BG: Background color
- FG: Text color  
- BDR: Border color
- SEL: Selection color
- And more...

---

**Author:** i-am-paradoxx  
**Date:** July 2025  
**License:** MIT
