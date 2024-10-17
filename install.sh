#!/bin/bash

# Install dependencies for i3
echo "Installing dependencies for i3..."
/usr/lib/apt/apt-helper download-file https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2024.03.04_all.deb keyring.deb SHA256:f9bb4340b5ce0ded29b7e014ee9ce788006e9bbfe31e96c09b2118ab91fca734
sudo apt install ./keyring.deb
echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" | sudo tee /etc/apt/sources.list.d/sur5r-i3.list
sudo apt update
sudo apt install i3
sudo apt install notify-osd
sudo apt install playerctl
sudo apt install nitrogen
sudo apt install kitty
git clone https://github.com/kovidgoyal/kitty.git
cd kitty

sudo apt-get install python3-pip git
pip3 install i3ipc
# Install dependencies for Polybar
echo "Installing dependencies for Polybar..."
sudo apt install -y libiw-dev
sudo apt install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev \
libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev \
libcurl4-openssl-dev libmpdclient-dev libasound2-dev libpulse-dev libjsoncpp-dev libxcb-xrm-dev \
libmpdclient-dev libxcb-cursor-dev libxcb-keysyms1-dev
sudo apt install -y cmake cmake-data libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev \
libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev \
libcurl4-openssl-dev libmpdclient-dev libasound2-dev libpulse-dev libjsoncpp-dev libxcb-xrm-dev \
libmpdclient-dev libxcb-cursor-dev libxcb-keysyms1-dev libuv1-dev pkg-config
sudo apt install -y pkg-config libuv1-dev
sudo apt install -y python3-sphinx
sudo apt install -y build-essential feh

# Clone and build Polybar
echo "Building Polybar..."
git clone https://github.com/polybar/polybar.git
cd polybar
./build.sh

# Install dependencies for Picom
echo "Installing dependencies for Picom..."
sudo apt install -y libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev meson ninja-build uthash-dev
sudo apt install -y build-essential git meson ninja-build libxcb1-dev libxcb-util0-dev libxcb-randr0-dev \
libxcb-keysyms1-dev libxcb-xinerama0-dev libxcb-xfixes0-dev libxrender-dev libxext-dev \
libgl1-mesa-dev libgdk-pixbuf2.0-dev libpcre2-dev libconfig++-dev
sudo apt install picom
sudo apt install rofi
# Set up .xinitrc
echo "Setting up .xinitrc..."
echo "#!/bin/sh" > ~/.xinitrc
echo "xrdb ~/.Xresources" >> ~/.xinitrc
echo "exec i3" >> ~/.xinitrc
chmod +x ~/.xinitrc

# Set up .Xresources
echo "Setting up .Xresources..."
echo "#!/bin/sh" > ~/.Xresources
echo "Xcursor.theme: Papirus-Dark" >> ~/.Xresources
echo "Xcursor.size: 32" >> ~/.Xresources
echo "xft.dpi: 125" >> ~/.Xresources

#cloning git repo to i3-config-files
echo "cloning in to i3-config-files..."
https://github.com/rajesh-newbie/new-i3.git
cd new-i3

# Move fonts to /usr/share/fonts
echo "Moving fonts to respective places..."
sudo mv JetBrainsMono /usr/share/fonts/
sudo mv Work_Sans /usr/share/fonts/

# Move config files to respective places
echo "Moving config files to respective places..."
cd i3
mkdir ~/.config/i3
mv config ~/.config/i3/
cd ..
rm -rf ~/.config/polybar
rm -rf ~/.config/rofi
rm -rf ~/.config/picom
mv polybar ~/.config/
mv rofi ~/.config/
mv picom ~/.config/


sudo apt install zsh
mv .zsh ~/
mv .zshrc ~/

echo "All dependencies installed and config files set up!"
