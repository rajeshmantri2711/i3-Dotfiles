#!/bin/bash

set -e

# ==============================
# Step 1: Detect OS
# ==============================
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Unsupported OS."
    exit 1
fi

echo "📦 Detected OS: $OS"

# ==============================
# Step 2: Install Dependencies
# ==============================
install_dependencies() {
    echo "==> Installing packages for $OS..."
    case "$OS" in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y \
                i3 rofi picom polybar playerctl \
                kitty nitrogen maim zsh notify-osd \
                light build-essential feh wget curl \
                git python3-pip cmake cmake-data \
                libcairo2-dev libiw-dev libxcb1-dev libxcb-util0-dev \
                libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev \
                libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xrm-dev \
                libcurl4-openssl-dev libmpdclient-dev libasound2-dev \
                libpulse-dev libjsoncpp-dev libxcb-cursor-dev \
                libxcb-keysyms1-dev libuv1-dev pkg-config \
                python3-xcbgen xcb-proto python3-sphinx
            ;;
        arch|manjaro)
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm \
                i3-wm rofi picom polybar playerctl \
                kitty nitrogen maim zsh light \
                wget curl git feh base-devel python-pip
            ;;
        *)
            echo "❌ Unsupported OS: $OS"
            exit 1
            ;;
    esac
}

# ==============================
# Step 3: Add to video group
# ==============================
add_to_video_group() {
    echo "==> Adding $USER to video group..."
    sudo usermod -aG video "$USER"
}

# ==============================
# Step 4: Install Greenclip
# ==============================
install_greenclip() {
    echo "==> Installing greenclip..."
    wget https://github.com/erebe/greenclip/releases/latest/download/greenclip -O greenclip
    chmod +x greenclip
    sudo mv greenclip /usr/local/bin/
}

# ==============================
# Step 5: Setup i3 Repo (Debian/Ubuntu only)
# ==============================
setup_i3_repo_debian() {
    if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
        echo "==> Setting up i3 Sur5r repo..."
        /usr/lib/apt/apt-helper download-file \
          https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2024.03.04_all.deb \
          keyring.deb \
          SHA256:f9bb4340b5ce0ded29b7e014ee9ce788006e9bbfe31e96c09b2118ab91fca734
        sudo apt install -y ./keyring.deb
        echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
        sudo apt update
        sudo apt install -y i3
    fi
}

# ==============================
# Step 6: Install i3ipc for Python
# ==============================
install_i3ipc() {
    echo "==> Installing i3ipc (Python)..."
    pip3 install --user i3ipc
}

# ==============================
# Step 7: Build Polybar (from source)
# ==============================
build_polybar() {
    echo "==> Cloning and building Polybar..."
    git clone --recursive https://github.com/polybar/polybar.git
    cd polybar
    ./build.sh
    cd ..
    rm -rf polybar
}

# ==============================
# Step 8: Setup xinitrc and Xresources
# ==============================
setup_xinit_xresources() {
    echo "==> Setting up .xinitrc and .Xresources..."

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

# ==============================
# Step 9: Clone and Apply Configs
# ==============================
clone_and_apply_configs() {
    echo "==> Cloning your i3 config repo..."
    git clone https://github.com/i-am-paradoxx/new-i3.git
    cd new-i3

    echo "==> Installing fonts..."
    sudo mv JetBrainsMono /usr/share/fonts/
    sudo mv Work_Sans /usr/share/fonts/

    echo "==> Moving i3 config..."
    mkdir -p ~/.config/i3
    mv i3/config ~/.config/i3/

    echo "==> Moving Polybar, Rofi, Picom configs..."
    rm -rf ~/.config/polybar ~/.config/rofi ~/.config/picom
    mv polybar ~/.config/
    mv rofi ~/.config/
    mv picom ~/.config/

    echo "==> Moving zsh config..."
    mv .zsh ~/
    mv .zshrc ~/

    cd ..
    rm -rf new-i3
}

# ==============================
# Step 10: Done
# ==============================
main() {
    install_dependencies
    add_to_video_group
    install_greenclip
    setup_i3_repo_debian
    install_i3ipc
    build_polybar
    setup_xinit_xresources
    clone_and_apply_configs

    echo "✅ Setup complete! Reboot and run 'startx' to launch i3."
}

main
