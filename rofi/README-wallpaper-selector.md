# 🎨 Automatic Wallpaper Selector System

A comprehensive wallpaper management system for i3 window manager with automatic time-based switching and manual override capabilities.

## ✨ Features

- **🕐 Time-based Auto Switching**: Three periods with different wallpapers
- **🎯 Manual Override**: Select any wallpaper manually, persists until reboot
- **🖼️ 3x3 Grid Interface**: Beautiful rofi grid layout for wallpaper selection
- **🎨 Color Synchronization**: Each wallpaper has custom color themes
- **⚡ Cron Automation**: Automatic switching at scheduled times
- **🔄 i3 Integration**: Starts automatically with your desktop

## 📅 Schedule

| Time Period | Wallpaper | Mode |
|-------------|-----------|------|
| 6:00 AM - 6:00 PM | white.png | Daytime ☀️ |
| 6:00 PM - 10:00 PM | windblown.jpg | Evening 🌅 |
| 10:00 PM - 6:00 AM | dark.png | Night 🌙 |

## 🚀 Quick Setup

Run the automated setup script:

```bash
~/.config/rofi/bin/setup-wallpaper-selector.sh
```

This will:
- ✅ Create all necessary directories
- ✅ Set up cron jobs for automatic switching
- ✅ Configure i3 startup integration
- ✅ Create helper scripts
- ✅ Test the system

## 🎮 Usage

### Manual Wallpaper Selection
```bash
~/.config/rofi/bin/wallpaper-selector
```
- Opens 3x3 grid interface
- Select any wallpaper
- Selection persists until reboot
- Choose "🤖 Auto (Time-based)" to return to automatic mode

### Check Current Status
```bash
~/.config/rofi/bin/wallpaper-status
```
Shows:
- Current mode (Auto/Manual)
- Active wallpaper
- Next scheduled change
- Recent activity log

### Reset to Auto Mode
```bash
~/.config/rofi/bin/reset-wallpaper
```
Removes manual override and applies time-based wallpaper.

### Force Auto Update
```bash
~/.config/rofi/bin/auto-wallpaper
```
Manually trigger automatic wallpaper selection based on current time.

## 📁 File Structure

```
~/.config/rofi/
├── bin/
│   ├── wallpaper-selector          # Main wallpaper selector
│   ├── auto-wallpaper             # Auto switching script
│   ├── setup-wallpaper-selector.sh # Setup script
│   ├── reset-wallpaper            # Reset to auto mode
│   └── wallpaper-status           # Status checker
├── config/
│   ├── wallpaper-grid.rasi        # 3x3 grid theme
│   └── colors.rasi                # Dynamic colors
└── logs/
    └── auto-wallpaper.log         # Activity log
```

## 🎨 Wallpaper Requirements

Place wallpapers in: `~/.config/polybar/Wallpaper/`

Required wallpapers for auto mode:
- `white.png` (daytime)
- `windblown.jpg` (evening)
- `dark.png` (nighttime)

Additional wallpapers will appear in the selector with custom themes.

## 🔧 Customization

### Adding New Wallpapers
1. Add image to `~/.config/polybar/Wallpaper/`
2. Add color scheme in `wallpaper-selector` script
3. Restart to see new wallpaper in grid

### Changing Schedule
Edit cron jobs:
```bash
crontab -e
```
Modify the three time entries as needed.

### Custom Colors
Each wallpaper theme includes:
- `BG`: Main background
- `BGA`: Alternative background  
- `FG`: Foreground text
- `FGA`: Alternative text
- `BDR`: Border color
- `SEL`: Selection highlight
- `UGT`: Urgent/accent color

## 🐛 Troubleshooting

### Wallpaper not changing automatically
- Check cron jobs: `crontab -l`
- Check logs: `~/.config/rofi/logs/auto-wallpaper.log`
- Test manually: `~/.config/rofi/bin/auto-wallpaper`

### Manual selection not working
- Check temp file: `/tmp/wallpaper_selection`
- Reset to auto: `~/.config/rofi/bin/reset-wallpaper`

### Grid not displaying properly
- Verify theme file: `~/.config/rofi/config/wallpaper-grid.rasi`
- Check rofi version compatibility

## 📊 System Integration

### i3 Config Addition
```bash
exec_always --no-startup-id ~/.config/rofi/bin/auto-wallpaper
```

### Cron Jobs
```bash
# Auto wallpaper changer - three time periods
0 6 * * * DISPLAY=:0 ~/.config/rofi/bin/auto-wallpaper
0 18 * * * DISPLAY=:0 ~/.config/rofi/bin/auto-wallpaper  
0 22 * * * DISPLAY=:0 ~/.config/rofi/bin/auto-wallpaper
```

## 🎯 Advanced Features

- **Persistence**: Manual selections survive until system restart
- **Graceful Fallback**: Falls back to auto mode if manual wallpaper is missing
- **Color Sync**: Rofi themes automatically match wallpaper colors
- **Grid Layout**: 3x3 responsive grid with hover effects
- **Status Tracking**: Full activity logging and status checking

---

**Created by**: i-am-paradoxx  
**Date**: July 19, 2025  
**License**: MIT
