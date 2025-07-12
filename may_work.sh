#!/bin/bash

set -e

echo "==> Updating system and installing essential packages..."
sudo apt update
sudo apt install -y \
  notify-osd \
  playerctl \
  nitrogen \
  kitty \
  maim \
  light \
  zsh \
  build-essential \
  feh \
  rofi \
  picom \
  python3-pip \
  git \
  curl \
  wget

echo "==> Adding user to 'video' group for brightness control..."
sudo usermod -aG video $USER

echo "==> Installing greenclip clipboard manager..."
wget https://github.com/erebe/greenclip/releases/latest/download/greenclip -O greenclip
chmod +x greenclip
sudo mv greenclip /usr/local/bin/

echo "==> Setting up i3 repo key and installing i3..."
/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2024.03.04_all.deb keyring.deb SHA256:f9bb4340b5ce0ded29b7e014ee9ce788006e9bbfe31e96c09b2118ab91fca734
sudo apt install -y ./keyring.deb
echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
sudo apt update
sudo apt install -y i3

echo "==> Installing Python i3ipc..."
pip3 install i3ipc

echo "==> Installing Polybar dependencies..."
sudo apt install -y \
  cmake cmake-data \
  libcairo2-dev libiw-dev libxcb1-dev libxcb-util0-dev \
  libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev \
  libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xrm-dev \
  libcurl4-openssl-dev libmpdclient-dev libasound2-dev \
  libpulse-dev libjsoncpp-dev libxcb-cursor-dev \
  libxcb-keysyms1-dev libuv1-dev pkg-config \
  python3-xcbgen xcb-proto \
  python3-sphinx

echo "==> Cloning and building Polybar..."
git clone --recursive https://github.com/polybar/polybar.git
cd polybar
./build.sh
cd ..
rm -rf polybar

echo "==> Setting up .xinitrc..."
cat <<EOF > ~/.xinitrc
#!/bin/sh
xrdb ~/.Xresources
exec i3
EOF
chmod +x ~/.xinitrc

echo "==> Setting up .Xresources..."
cat <<EOF > ~/.Xresources
Xcursor.theme: Papirus-Dark
Xcursor.size: 32
xft.dpi: 125
EOF

echo "==> Cloning i3 config repo..."
git clone https://github.com/rajesh-newbie/new-i3.git
cd new-i3

echo "==> Moving fonts to /usr/share/fonts/..."
sudo mv JetBrainsMono /usr/share/fonts/
sudo mv Work_Sans /usr/share/fonts/

echo "==> Moving i3 config..."
mkdir -p ~/.config/i3
mv i3/config ~/.config/i3/

echo "==> Moving polybar, rofi, and picom configs..."
rm -rf ~/.config/polybar ~/.config/rofi ~/.config/picom
mv polybar ~/.config/
mv rofi ~/.config/
mv picom ~/.config/

echo "==> Setting up zsh config..."
mv .zsh ~/
mv .zshrc ~/

cd ..
rm -rf new-i3

echo "✅ All installations and configurations completed!"
echo "➡️  Reboot and run 'startx' to enter i3."
