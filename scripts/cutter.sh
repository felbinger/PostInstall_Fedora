#!/bin/bash

# https://cutter.re/ is a gui for radare2, which is being used for reverse engeneering

sudo mkdir -p /opt/cutter

# get cutter
sudo wget -q https://github.com/rizinorg/cutter/releases/latest/download/Cutter-v2.0.3-x64.Linux.AppImage -O /opt/cutter/Cutter.AppImage
sudo chmod +x /opt/cutter/Cutter.AppImage
sudo ln -s /opt/cutter/Cutter.AppImage /usr/local/bin/cutter

# download cutter icon
sudo wget -q https://cutter.re/assets/images/cutter-small.svg -O /opt/cutter/cutter.svg

# create desktop launcher
cat <<_EOF | sudo tee /opt/cutter/cutter.desktop &> /dev/null
#!/usr/bin/env xdg-open
[Desktop Entry]
Type=Application
Name=Cutter
Exec="/opt/cutter/Cutter.AppImage"
Icon=/opt/cutter/cutter.svg
Categories=Application;
_EOF

sudo chmod +x /opt/cutter/cutter.desktop
sudo ln -s /opt/cutter/cutter.desktop /usr/local/share/applications/cutter.desktop

