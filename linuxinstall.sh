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
                echo "❌ Unsupported or unknown OS: $ID"
                exit 1
            fi
            ;;
    esac
else
    echo "Cannot detect OS (missing /etc/os-release)"
    exit 1
fi

echo "Detected OS family: $OS"

#for i3
# Step 1: Remove existing i3 to avoid conflicts
sudo apt remove --purge i3 polybar rofi picom -y

# Step 2: Install required build dependencies
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

# Step 3: Clone the latest i3 repo (tag 4.24)
git clone https://github.com/i3/i3.git
cd i3
git checkout 4.24

# Step 4: Build and install
meson build
ninja -C build
sudo ninja -C build install


##############################
# 1. Install Packages
##############################
install_packages_debian() {
    sudo apt update
    sudo apt install -y \
        rofi picom polybar playerctl kitty nitrogen maim zsh notify-osd light \
        build-essential feh wget curl git cmake python3-pip meson dh-autoreconf \
        libcairo2-dev libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev \
        libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev \
        libxcb-xinerama0-dev libxkbcommon-dev libxkbcommon-x11-dev libstartup-notification0-dev \
        libxcb-randr0-dev libxcb-shape0-dev libxcb-xrm-dev libxcb-glx0-dev libpixman-1-dev xcb-proto \
        libxcb-image0-dev libxcb-composite0-dev libxcb-ewmh-dev python3-xcbgen libasound2-dev libpulse-dev \
        libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev libiw-dev libuv1-dev pkg-config python3-sphinx \
        fonts-jetbrains-mono papirus-icon-theme gnome-themes-extra \
        mint-themes mint-y-icons dmz-cursor-theme x11-xserver-utils xbacklight xdotool \
        pulseaudio pavucontrol lxappearance dunst arc-theme gnome-shell-extension-manager \
        flameshot  network-manager-gnome network-manager \
        xcompmgr xclip xfce4-power-manager acpi acpid unzip
}



install_packages_arch() {
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm \
        i3-gaps rofi picom polybar playerctl kitty nitrogen maim zsh light \
        wget curl git feh base-devel python-pip ttf-jetbrains-mono ttf-cantarell ttf-noto \
        papirus-icon-theme gnome-themes-extra mint-y-icons mint-themes xcursor-dmz \
        xorg-xbacklight xorg-xset xdotool pulseaudio pavucontrol lxappearance dunst arc-gtk-theme \
        flameshot networkmanager network-manager-applet xcompmgr xclip xfce4-power-manager acpi acpid unzip
}

if [[ "$OS" == "debian" ]]; then
    install_packages_debian
else
    install_packages_arch
fi

##############################
# 2. Build i3-gaps (Debian)
##############################
if [[ "$OS" == "debian" ]]; then
    echo "🔧 Building i3-gaps from source..."
    rm -rf ~/i3-gaps-src
    git clone https://github.com/Airblader/i3 ~/i3-gaps-src
    cd ~/i3-gaps-src
    meson setup --prefix=/usr build
    ninja -C build
    sudo ninja -C build install
    cd ~
    rm -rf ~/i3-gaps-src
fi

##############################
# 3. Fix Brightness Permissions
##############################
sudo usermod -aG video "$USER"
BACKLIGHT_DIR=$(ls /sys/class/backlight/ | head -n 1)
if [[ -n "$BACKLIGHT_DIR" ]]; then
    FULL_PATH="/sys/class/backlight/$BACKLIGHT_DIR"
    sudo chmod 666 "$FULL_PATH/brightness" || true
    sudo chmod 666 "$FULL_PATH/max_brightness" || true
    echo "ACTION==\"add\", SUBSYSTEM==\"backlight\", RUN+=\"/bin/chmod 0666 $FULL_PATH/brightness\"" | \
        sudo tee /etc/udev/rules.d/99-backlight.rules > /dev/null
    sudo udevadm control --reload-rules
    sudo chmod +s /usr/bin/light || true
fi

##############################
# 4. Install greenclip and i3ipc
##############################
wget https://github.com/erebe/greenclip/releases/latest/download/greenclip -O greenclip
chmod +x greenclip
sudo mv greenclip /usr/local/bin/
pip3 install --user i3ipc

##############################
# 5. Setup .xinitrc and .Xresources
##############################
cat <<EOF > ~/.xinitrc
#!/bin/sh
xrdb ~/.Xresources
exec i3
EOF
chmod +x ~/.xinitrc

cat <<EOF > ~/.Xresources
Xcursor.theme: DMZ-White
Xcursor.size: 32
xft.dpi: 125
EOF

##############################
# 6. Set Themes, Icons, Cursor, Dark Mode
##############################
echo "🌙 Setting themes, icons, and dark mode..."

# GTK3 - gsettings (if available)
if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    gsettings set org.gnome.desktop.interface icon-theme "Papirus"
    gsettings set org.gnome.desktop.interface cursor-theme "DMZ-White"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" || true
fi

# GTK2
mkdir -p ~/.gtk-2.0
cat <<EOF > ~/.gtkrc-2.0
gtk-theme-name="Adwaita-dark"
gtk-icon-theme-name="Papirus"
gtk-cursor-theme-name="DMZ-White"
gtk-font-name="Sans 10"
EOF

# Mint-Y-Dark-Blue theme for desktop (if Cinnamon is installed)
if command -v gsettings &>/dev/null; then
    gsettings set org.cinnamon.theme name "Mint-Y-Dark-Blue" || true
    gsettings set org.cinnamon.desktop.interface gtk-theme "Adwaita-dark" || true
    gsettings set org.cinnamon.desktop.interface icon-theme "Papirus" || true
fi

##############################
# 7. Clone Configs and Fonts
##############################
echo "📁 Cloning i3 configuration..."
git clone https://github.com/i-am-paradoxx/i3.git ~/new-i3
cd ~/new-i3

echo "🔤 Installing fonts from repo (if any)..."
mkdir -p ~/.local/share/fonts
cp -r JetBrainsMono/* ~/.local/share/fonts/ 2>/dev/null || true
cp -r Work_Sans/* ~/.local/share/fonts/ 2>/dev/null || true
fc-cache -fv

echo "⚙️  Copying configuration files..."
[[ ! -d ~/.config ]] && mkdir ~/.config
cp -r i3 ~/.config/
cp -r polybar ~/.config/
cp -r rofi ~/.config/
cp -r picom ~/.config/

echo "✅ Configs placed in ~/.config/"
cd ~

echo "🎉 Done! Reboot and run 'startx' to launch i3-gaps!"
