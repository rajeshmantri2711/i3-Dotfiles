
#!/bin/bash
set -e

# Detecting  OS family
if [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
        debian|ubuntu|linuxmint|kali|parrot)
            OS="debian"
            ;;
        arch|manjaro|blackarch|endeavouros|arcolinux|garuda|artix)
            OS="arch"
            ;;
        *)
            # Fallback: check ID_LIKE field for derivatives
            if [[ "$ID_LIKE" == *"debian"* ]]; then
                OS="debian"
            elif [[ "$ID_LIKE" == *"arch"* ]]; then
                OS="arch"
            else
                echo " Unsupported or unknown OS: $ID"
                exit 1
            fi
            ;;
    esac
else
    echo "Cannot detect OS (missing /etc/os-release)"
    exit 1
fi

echo "Detected OS family: $OS"


rm -rf ~/DotFiles
mkdir ~/DotFiles
cd ~/DotFiles

# Removeing existing packages to avoid conflicts
sudo apt remove --purge i3 polybar rofi picom -y


################################ installing i3 from source #####################################
install_i3_from_source() {
    echo " Installing i3"
    sudo apt install -y \
        meson ninja-build build-essential pkg-config \
        libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev \
        libxcb-util0-dev libxcb-icccm4-dev libyajl-dev \
        libev-dev libxcb-xkb-dev libxcb-cursor-dev \
        libxkbcommon-dev libxcb-xinerama0-dev \
        libxkbcommon-x11-dev libstartup-notification0-dev \
        libxcb-randr0-dev libxcb-shape0-dev libxcb-xrm-dev \
        libxcb-xrm0 libxcb-render-util0-dev xutils-dev \
        libxcb-shm0-dev libxcb-dpms0-dev libxcb-present-dev

    git clone https://github.com/i3/i3.git
    cd i3
    git checkout 4.24
    meson build
    ninja -C build
    sudo ninja -C build install
    
    cd ~/DotFiles
}

################################ installing i3-gaps #####################################
install_i3_gaps_from_source() {
    echo " Installing i3-gaps"
    git clone https://github.com/Airblader/i3 ~/DotFiles/i3-gaps
    cd ~/DotFiles/i3-gaps
    meson setup --prefix=/usr build
    ninja -C build
    sudo ninja -C build install
    cd ~/DotFiles
    echo "i3-gaps installation completed."
}

################################ installing rofi from source #####################################
install_rofi_from_source() {
    echo " Installing rofi "
    sudo apt install -y \
        git build-essential autoconf automake pkg-config \
        libxkbcommon-dev libxkbcommon-x11-dev \
        libxcb1-dev libxcb-xkb-dev libxcb-util0-dev \
        libxcb-ewmh-dev libxcb-icccm4-dev libxcb-cursor-dev \
        libpango1.0-dev libstartup-notification0-dev \
        check libglib2.0-dev libgdk-pixbuf2.0-dev flex bison
        
    # Clone and build
    git clone https://github.com/davatorium/rofi.git ~/DotFiles/rofi-new
    cd ~/DotFiles/rofi-new

    mkdir -p build
    cd build
    meson ..
    ninja
    sudo ninja install
    cd ~/DotFiles
    echo "Rofi installation completed."
}


################################ installing polybar from source #####################################
install_polybar_from_source() {
    echo " Installing Polybar "
    sudo apt install -y \
        cmake cmake-data libcairo2-dev libxcb1-dev \
        libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev \
        python3-sphinx libxcb-image0-dev libxcb-ewmh-dev \
        libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev \
        libasound2-dev libpulse-dev libjsoncpp-dev \
        libmpdclient-dev libcurl4-openssl-dev libnl-genl-3-dev \
        pkg-config python3-xcbgen xcb-proto python3
        
    git clone --recursive https://github.com/polybar/polybar.git ~/DotFiles/Polybar-new
    cd ~/DotFiles/Polybar-new

    ./build.sh

    cd ~/DotFiles
    echo "Polybar installed successfully."
}

################################ installing Greenclipfrom #####################################
install_clipboard_tools() {
    echo "Installing Greenclip and i3ipc "
    sudo apt install -y xclip xsel wget curl python3-pip
    wget -q --show-progress https://github.com/erebe/greenclip/releases/latest/download/greenclip -O greenclip
    chmod +x greenclip
    sudo mv greenclip /usr/local/bin/
    pip3 install --user i3ipc
    echo " Greenclip and i3ipc installed successfully."
}

################################ Brightness settings and fixes #####################################

fix_brightness_permissions() {
    echo "Setting up brightness control permissions with brightnessctl..."

sudo usermod -aG video "$USER"

BACKLIGHT_DIR=$(ls /sys/class/backlight/ | head -n 1)
if [[ -n "$BACKLIGHT_DIR" ]]; then
    FULL_PATH="/sys/class/backlight/$BACKLIGHT_DIR"
    echo "Found backlight interface: $BACKLIGHT_DIR"

    echo "Writing udev rule for brightnessctl..."
    sudo tee /etc/udev/rules.d/90-backlight.rules > /dev/null <<EOF
SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chgrp video $FULL_PATH/brightness", RUN+="/bin/chmod g+w $FULL_PATH/brightness"
EOF

    sudo udevadm control --reload-rules
    sudo udevadm trigger

    echo "Brightness permissions configured for brightnessctl."
else
    echo "No backlight device found."
fi

}

################################ installing debian packages #####################################
install_packages_debian() {
    echo " Installing required Debian packages..."
    
    sudo apt update
    sudo apt install -y \
    rofi kitty terminator build-essential meson ninja-build cmake dh-autoreconf pkg-config python3-pip \
    notify-osd libnotify-bin libx11-dev libxext-dev libev-dev \
    libxkbcommon-dev libxkbcommon-x11-dev libxcb1-dev libxcb-util0-dev libxcb-keysyms1-dev \
    libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-cursor-dev \
    libxcb-icccm4-dev libxcb-ewmh-dev libxcb-composite0-dev libxcb-image0-dev \
    libxcb-render-util0-dev libxcb-shm0-dev libxcb-present-dev libxcb-xrm-dev \
    libyajl-dev libstartup-notification0-dev xutils-dev xcb-proto python3-xcbgen \
    libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev \
    libiw-dev libuv1-dev check flex bison uthash-dev libpixman-1-dev libdbus-1-dev \
    libpango1.0-dev libconfig-dev libxdg-basedir-dev \
    fonts-jetbrains-mono papirus-icon-theme gnome-themes-extra \
    dmz-cursor-theme gtk2-engines-murrine lxappearance arc-theme \
    playerctl maim bluez blueman pulseaudio-module-bluetooth rfkill thunar xfce4-settings brightnessctl \
    x11-xserver-utils xbacklight xdotool \
    flameshot pulseaudio pulseaudio-utils pavucontrol network-manager network-manager-gnome \
    xcompmgr xclip xfce4-power-manager acpi acpid unzip feh wget curl git zsh


    echo " Package installation complete."
}



################################ moving dot files to .config #####################################

clone_configs_and_fonts() {
    echo "Cloning i3 configuration..."
    git clone https://github.com/i-am-paradoxx/i3-Dotfiles.git ~/DotFiles/new-i3
    cd ~/DotFiles/new-i3 || exit 1

    echo " Installing fonts from repository..."
    mkdir -p ~/.local/share/fonts

    # Install fonts only if directories exist
    [[ -d JetBrainsMono ]] && cp -r JetBrainsMono/* ~/.local/share/fonts/
    [[ -d Work_Sans ]] && cp -r Work_Sans/* ~/.local/share/fonts/
    [[ -d FiraCode ]] && cp -r FiraCode/* ~/.local/share/fonts/
    fc-cache -fv

    echo " Copying configuration files..."

    mkdir -p ~/.config

    cp -r i3 ~/.config/
    cp -r polybar ~/.config/
    cp -r rofi ~/.config/
    cp -r betterlockscreen ~/.config/
    #cp -r .zsh ~/
    cp -r .zshrc ~/

    echo " Configuration successfully placed in ~/.config/"
    cd ~/DotFiles|| exit 1
}

################################ i3 entry session #####################################

setup_i3_session_entry() {
    echo "Setting up i3 session entry..."

    SESSION_FILE="/usr/share/xsessions/i3.desktop"

    if [[ ! -f "$SESSION_FILE" ]]; then
        sudo tee "$SESSION_FILE" > /dev/null <<EOF
[Desktop Entry]
Name=i3
Comment=Dynamic window manager
Exec=i3
Type=Application
X-LightDM-DesktopName=i3
DesktopNames=i3
EOF
        echo " i3 session entry created at $SESSION_FILE"
    else
        echo "ℹ i3 session entry already exists at $SESSION_FILE"
    fi

    # Try restarting the display manager (only if LightDM, GDM, or SDDM found)
    DM=$(basename "$(cat /etc/X11/default-display-manager 2>/dev/null || echo '')")

    case "$DM" in
        lightdm|gdm3|sddm)
            echo "  $DM changes applied..."
            ;;
        *)
            echo " Unknown display manager or unable to detect. Please reboot manually."
            ;;
    esac
}


################################ betterlockscree #####################################

setup_betterlockscreen() {
    echo "Installing dependencies..."
    sudo apt update
    sudo apt install -y i3lock imagemagick libpam0g-dev libxcb-xkb-dev 

    echo "Downloading and installing betterlockscreen..."
    wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | sudo bash -s system

    echo -n "Enter the full image path to use as lockscreen wallpaper (or press Enter to use default): "
    read -r image_path

    if [[ -z "$image_path" ]]; then
        image_path="$HOME/.config/betterlockscreen/spider.png"
        echo "Using default image: $image_path"
    fi

    if [[ -f "$image_path" ]]; then
        echo "Applying dimblur effect with betterlockscreen..."
        betterlockscreen -u "$image_path" --fx dimblur
        echo "betterlockscreen setup complete."
    else
        echo "Error: Image not found at $image_path"
    fi
}


################################ Themes and icons #####################################

set_appearance_theme() {
    echo "Setting themes, icons, cursor, and dark mode..."
    sudo apt install -y \
        lxappearance adwaita-qt gnome-themes-extra papirus-icon-theme \
        dmz-cursor-theme gtk2-engines-murrine

    echo "Applying theme settings..."

    # GTK 3 settings via config file
    mkdir -p ~/.config/gtk-3.0
    cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Adwaita-dark
gtk-application-prefer-dark-theme=true
gtk-icon-theme-name=Papirus-Dark

gtk-font-name=Sans 10
gtk-cursor-theme-size=0
gtk-toolbar-style=GTK_TOOLBAR_BOTH
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-cursor-theme-name=DMZ-White
EOF

    # GTK 2 settings via gtkrc
    mkdir -p ~/.gtk-2.0
    cat <<EOF > ~/.gtkrc-2.0
gtk-theme-name="Adwaita-dark"
gtk-icon-theme-name="Papirus"
gtk-cursor-theme-name="DMZ-White"
gtk-font-name="Sans 10"
EOF

    echo "Theme files installed and config set."
    echo "You can now run 'lxappearance' to change and preview themes graphically."

}

################################ setting up xinit #####################################

setup_xinitrc_and_xresources() {
    echo "Setting up .xinitrc and .Xresources..."

    # Setup .xinitrc
    cat <<EOF > ~/.xinitrc
#!/bin/sh
xrdb ~/.Xresources
exec i3
EOF
    chmod +x ~/.xinitrc
    echo " xinitrc configured."

    # Setup .Xresources
    cat <<EOF > ~/.Xresources
Xcursor.theme: Papirus-Dark
Xcursor.size: 32
xft.dpi: 125
EOF
    echo " Xresources configured."
}

################################ checking OS and Distro #####################################

if [[ "$OS" == "debian" ]]; then
    install_packages_debian
    install_i3_from_source
    install_polybar_from_source
    install_clipboard_tools
    fix_brightness_permissions
    clone_configs_and_fonts
    set_appearance_theme
    setup_betterlockscreen
    setup_xinitrc_and_xresources
    setup_i3_session_entry
    
elif [[ "$OS" == "arch" ]]; then
    install_i3_from_source
    install_rofi_from_source
    
else
    echo "Unsupported OS: $OS"
    exit 1
fi



echo "Done Reboot and run 'startx' to launch i3-gaps!"
