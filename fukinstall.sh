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


rm -rf ~/newDotFiles
mkdir ~/newDotFiles
cd ~/newDotFiles

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
    
    cd ~/newDotFiles
}

################################ installing i3-gaps #####################################
install_i3_gaps_from_source() {
    echo " Installing i3-gaps"
    git clone https://github.com/Airblader/i3 ~/newDotFiles/i3-gaps
    cd ~/newDotFiles/i3-gaps
    meson setup --prefix=/usr build
    ninja -C build
    sudo ninja -C build install
    cd ~/newDotFiles
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
        check libglib2.0-dev flex bison
        
    # Clone and build
    git clone https://github.com/davatorium/rofi.git ~/newDotFiles/rofi-new
    cd ~/newDotFiles/rofi-new

    mkdir -p build
    cd build
    meson ..
    ninja
    sudo ninja install
    cd ~/newDotFiles
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
        libxext-dev libxcb-xinerama0-dev libx11-dev libxdg-basedir-dev
        
    git clone https://github.com/yshui/picom.git cd ~/newDotFiles/picom-new
    cd ~/newDotFiles/picom-new

    git submodule update --init --recursive
    meson setup --buildtype=release build
    ninja -C build
    sudo ninja -C build install
    
    cd ~/newDotFiles
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
        
    git clone --recursive https://github.com/polybar/polybar.git ~/newDotFiles/Polybar-new
    cd ~/newDotFiles/Polybar-new

    ./build.sh

    cd ~/newDotFiles
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
    echo " setting up brightness control permissions."

    sudo usermod -aG video "$USER"

    BACKLIGHT_DIR=$(ls /sys/class/backlight/ | head -n 1)
    if [[ -n "$BACKLIGHT_DIR" ]]; then
        FULL_PATH="/sys/class/backlight/$BACKLIGHT_DIR"
        echo "Found backlight interface: $BACKLIGHT_DIR"

        sudo chmod 666 "$FULL_PATH/brightness" || true
        sudo chmod 666 "$FULL_PATH/max_brightness" || true

        echo " Writing udev rule for backlight..."
        echo "ACTION==\"add\", SUBSYSTEM==\"backlight\", RUN+=\"/bin/chmod 0666 $FULL_PATH/brightness\"" | \
            sudo tee /etc/udev/rules.d/99-backlight.rules > /dev/null

        sudo udevadm control --reload-rules
        sudo chmod +s /usr/bin/light || true

        echo "Brightness permissions fixed."
    else
        echo "No backlight device found."
    fi
}

################################ moving dot files to .config #####################################

install_packages_debian() {
    echo "Installing required Debian packages..."

    sudo apt update
    sudo apt install -y \
        # Build tools
        build-essential cmake meson ninja-build dh-autoreconf pkg-config check flex bison \
        python3-pip python3-xcbgen xcb-proto git wget curl unzip \
        
        # X11 + XCB deps for i3, polybar, picom, rofi
        libx11-dev libxext-dev libev-dev libpango1.0-dev libxkbcommon-dev libxkbcommon-x11-dev \
        libxcb1-dev libxcb-util0-dev libxcb-keysyms1-dev libxcb-xkb-dev libxcb-xinerama0-dev \
        libxcb-randr0-dev libxcb-cursor-dev libxcb-icccm4-dev libxcb-ewmh-dev libxcb-composite0-dev \
        libxcb-image0-dev libxcb-render-util0-dev libxcb-shm0-dev libxcb-present-dev libxcb-xrm-dev \
        libyajl-dev libstartup-notification0-dev libpixman-1-dev libdbus-1-dev libconfig-dev \
        libxdg-basedir-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev \
        libcurl4-openssl-dev libiw-dev libuv1-dev
        
        # Fonts and theming
        fonts-jetbrains-mono papirus-icon-theme gnome-themes-extra mint-themes mint-y-icons \
        dmz-cursor-theme gtk2-engines-murrine lxappearance arc-theme \
        
        # Cinnamon settings only (not the full DE)
        cinnamon-control-center cinnamon-settings-daemon xapps-common \
        
        # Screenshot and clipboard tools
        maim flameshot xclip xdotool x11-xserver-utils xbacklight light \
        
        # Desktop utilities
        nemo feh playerctl zsh dunst notify-osd libnotify-bin \
        
        # Network & audio tools
        pulseaudio pavucontrol network-manager network-manager-gnome \
        
        # Power & system utils
        xfce4-power-manager acpi acpid xcompmgr

    echo "Package installation complete."
}


################################ moving dot files to .config #####################################

clone_configs_and_fonts() {
    echo "Cloning i3 configuration..."
    git https://github.com/i-am-paradoxx/i3-Dotfiles.git ~/newDotFiles/new-i3
    cd ~/newDotFiles/new-i3 || exit 1

    echo " Installing fonts from repository..."
    mkdir -p ~/.local/share/fonts

    # Install fonts only if directories exist
    [[ -d JetBrainsMono ]] && cp -r JetBrainsMono/* ~/.local/share/fonts/
    [[ -d Work_Sans ]] && cp -r Work_Sans/* ~/.local/share/fonts/
    fc-cache -fv

    echo " Copying configuration files..."

    mkdir -p ~/.config

    cp -r i3 ~/.config/
    cp -r polybar ~/.config/
    cp -r rofi ~/.config/
    cp -r picom ~/.config/
    mv .zsh ~/
    mv .zshrc ~/

    echo " Configuration successfully placed in ~/.config/"
    cd ~/newDotFiles|| exit 1
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
gtk-icon-theme-name=Papirus
gtk-cursor-theme-name=DMZ-White
gtk-font-name=Sans 10
gtk-application-prefer-dark-theme=1
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
    install_rofi_from_source
    install_picom_from_source
    install_polybar_from_source
    install_clipboard_tools
    fix_brightness_permissions
    clone_configs_and_fonts
    set_appearance_theme
    setup_xinitrc_and_xresources
    
elif [[ "$OS" == "arch" ]]; then
    install_i3_from_source
    install_rofi_from_source
    install_picom_from_source
else
    echo "Unsupported OS: $OS"
    exit 1
fi



echo "Done Reboot and run 'startx' to launch i3-gaps!"
