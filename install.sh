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

# Asking for Picom installation
read -rp "Do you want to install Picom? (y/n): " INSTALL_PICOM

# Remove existing packages to avoid conflicts
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

################################ installing picom from source #####################################
install_picom_from_source() {
    echo " Installing picom "
    sudo apt install -y \
        git meson ninja-build cmake libx11-xcb-dev libxcb1-dev \
        libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev \
        libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev \
        libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev \
        libxcb-glx0-dev libpixman-1-dev libdbus-1-dev libconfig-dev \
        libgl1-mesa-dev libpcre2-dev libev-dev uthash-dev \
        libxext-dev picom libxcb-xinerama0-dev libx11-dev libxdg-basedir-dev

    git clone https://github.com/yshui/picom.git ~/DotFiles/picom-new
    cd ~/DotFiles/picom-new
    git submodule update --init --recursive
    meson setup --buildtype=release build
    ninja -C build
    sudo ninja -C build install
    cd ~/DotFiles
    echo "Picom successfully installed."
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
    pip3 install --user i3ipc --break-system-packages
    echo " Greenclip and i3ipc installed successfully."
}

################################ Brightness settings and fixes #####################################
fix_brightness_permissions() {
    echo "Setting up brightness control permissions with brightnessctl..."
    sudo usermod -aG video "$USER"
    BACKLIGHT_DIR=$(ls /sys/class/backlight/ | head -n 1)
    if [[ -n "$BACKLIGHT_DIR" ]]; then
        FULL_PATH="/sys/class/backlight/$BACKLIGHT_DIR"
        sudo tee /etc/udev/rules.d/90-backlight.rules > /dev/null <<EOF
SUBSYSTEM=="backlight", ACTION=="add", RUN+="/bin/chgrp video $FULL_PATH/brightness", RUN+="/bin/chmod g+w $FULL_PATH/brightness"
EOF
        sudo udevadm control --reload-rules
        sudo udevadm trigger
    else
        echo "No backlight device found."
    fi
}

################################ installing debian packages #####################################
install_packages_debian() {
    echo " Installing required Debian packages..."
    sudo apt update
    sudo apt install -y \
    rofi kitty flameshot polybar terminator build-essential meson ninja-build cmake dh-autoreconf pkg-config python3-pip \
    notify-osd i3-wm i3status i3lock suckless-tools \
    libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev \
    libxcb-util0-dev libxcb-icccm4-dev libyajl-dev \
    libev-dev libxcb-xkb-dev libxcb-cursor-dev \
    libxkbcommon-dev libxcb-xinerama0-dev \
    libxkbcommon-x11-dev libstartup-notification0-dev \
    libxcb-randr0-dev libxcb-shape0-dev libxcb-xrm-dev \
    libxcb-xrm0 libxcb-render-util0-dev xutils-dev \
    libxcb-shm0-dev libxcb-dpms0-dev libxcb-present-dev libnotify-bin \
    libx11-dev libxext-dev libxcb-ewmh-dev libxcb-composite0-dev libxcb-image0-dev \
    xcb-proto python3-xcbgen \
    libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev \
    libiw-dev libuv1-dev check flex bison uthash-dev libpixman-1-dev libdbus-1-dev \
    libconfig-dev libxdg-basedir-dev \
    fonts-jetbrains-mono papirus-icon-theme gnome-themes-extra \
    dmz-cursor-theme gtk2-engines-murrine lxappearance arc-theme \
    playerctl maim bluez blueman pulseaudio-module-bluetooth rfkill thunar xfce4-settings brightnessctl \
    x11-xserver-utils xbacklight xdotool \
    flameshot pulseaudio pulseaudio-utils pavucontrol network-manager network-manager-gnome \
    xcompmgr xclip xfce4-power-manager acpi acpid unzip feh wget curl git zsh
}

################################ moving dot files to .config #####################################
clone_configs_and_fonts() {
    echo "Cloning i3 configuration..."
    git clone https://github.com/rajeshmantri2711/i3-Dotfiles.git ~/DotFiles/new-i3
    cd ~/DotFiles/new-i3
    mkdir -p ~/.local/share/fonts
    [[ -d JetBrainsMono ]] && cp -r JetBrainsMono/* ~/.local/share/fonts/
    [[ -d Work_Sans ]] && cp -r Work_Sans/* ~/.local/share/fonts/
    [[ -d FiraCode ]] && cp -r FiraCode/* ~/.local/share/fonts/
    fc-cache -fv
    mkdir -p ~/.config
    cp -r i3 ~/.config/
    cp -r polybar ~/.config/
    cp -r rofi ~/.config/
    cp -r picom ~/.config/
    cp -r betterlockscreen ~/.config/
    cp -r .zshrc ~/
    cd ~/DotFiles 
}

################################ i3 entry session #####################################
setup_i3_session_entry() {
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
    fi
}

################################ betterlockscree #####################################
setup_betterlockscreen() {
    sudo apt update
    sudo apt install -y i3lock imagemagick libpam0g-dev libxcb-xkb-dev 
    wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | sudo bash -s system
    read -r -p "Enter the full image path for lockscreen (or press Enter to skip): " image_path
    [[ -z "$image_path" ]] && image_path="$HOME/.config/betterlockscreen/spider.png"
    [[ -f "$image_path" ]] && betterlockscreen -u "$image_path" --fx dimblur
}

################################ Themes and icons #####################################
set_appearance_theme() {
    sudo apt install -y lxappearance adwaita-qt gnome-themes-extra papirus-icon-theme dmz-cursor-theme gtk2-engines-murrine
    mkdir -p ~/.config/gtk-3.0
    cat <<EOF > ~/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Adwaita-dark
gtk-application-prefer-dark-theme=true
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-cursor-theme-name=DMZ-White
EOF
}

################################ setting up xinit #####################################
setup_xinitrc_and_xresources() {
    cat <<EOF > ~/.xinitrc
#!/bin/sh
xrdb ~/.Xresources
exec i3
EOF
    chmod +x ~/.xinitrc
    cat <<EOF > ~/.Xresources
Xcursor.theme: Papirus-Dark
Xcursor.size: 32
xft.dpi: 125
EOF
}

################################ checking OS and Distro #####################################
if [[ "$OS" == "debian" ]]; then
    install_packages_debian
    [[ "$INSTALL_PICOM" =~ ^[Yy]$ ]] && install_picom_from_source || echo "Skipping Picom installation."
    install_polybar_from_source
    install_clipboard_tools
    fix_brightness_permissions
    clone_configs_and_fonts
    set_appearance_theme
    setup_betterlockscreen
    install_i3_gaps_from_source
    install_i3_from_source
    setup_xinitrc_and_xresources
    setup_i3_session_entry
    
elif [[ "$OS" == "arch" ]]; then
    install_i3_from_source
    install_rofi_from_source
    [[ "$INSTALL_PICOM" =~ ^[Yy]$ ]] && install_picom_from_source || echo "Skipping Picom installation."
else
    echo "Unsupported OS: $OS"
    exit 1
fi

echo "Done. Reboot and run 'startx' to launch i3-gaps!"
