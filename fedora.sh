#!/bin/bash

###############################
##                           ##
##   Configuration Section   ##
##                           ##
###############################
DNF_PACKAGES=(
  ## required packages for this post install script ##
  dnf-plugins-core
  distribution-gpg-keys
  ImageMagick
  terminator                                           # splitable terminal
  timeshift
  ## end of required packages ##

  keepassxc                                            # kdbx compatible password manager
  syncthing
  sqlitebrowser                                        # simple browser for sqlite databases
  remmina remmina-plugins-{vnc,rdp,www,spice,secret}   # remote access
  squashfs-tools
  VirtualBox
  audacity
  vlc                                                  # videolan: vlc media player
  totem                                                # gnome video player
  gimp
  flameshot                                            # tool to create and modify screenshots
  binwalk                                              # tool to analyse binary files for embeded files and executable code
  nmap
  gobuster                                             # directory and vhost enumeration
  wireshark
  texlive-scheme-full
  texstudio
  kubernetes-client
  ansible
  
  # yubikey utilities
  yubikey-personalization-gui
  yubikey-manager-qt
  yubico-piv-tool
  
  code                                                 # visual studio code using microsoft repo
  anydesk                                              # using anydesk (rhel) repo
  teamviewer                                           # using teamviewer repo
  brave-browser                                        # using brave repo
  signal-desktop                                       # from dnf copr

  gnome-tweaks
  gnome-extensions-app
  file-roller
  nemo                                                 # install nemo, so we have an alternative to nautilus
  nemo-seahorse                                        # nemo seahorse integration (sign / encrypt)
  xed
)
FLATPAK_PACKAGES=(
  im.riot.Riot                                         # Element Client
  com.spotify.Client
  org.ferdium.Ferdium
  org.gtk.Gtk3theme.Adwaita-dark
)

###################################
##                               ##
##   Create Repo Files Section   ##
##                               ##
###################################
mkdir -p /tmp/repos.d
cat <<_EOF >> /tmp/repos.d/anydesk.repo
[anydesk]
name=AnyDesk RHEL - stable
baseurl=http://rpm.anydesk.com/rhel/x86_64/
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY
_EOF
cat <<_EOF >> /tmp/repos.d/teamviewer.repo
[teamviewer]
name=TeamViewer - \$basearch
baseurl=https://linux.teamviewer.com/yum/stable/main/binary-\$basearch/
gpgkey=https://linux.teamviewer.com/pubkey/currentkey.asc
gpgcheck=1
repo_gpgcheck=1
enabled=1
type=rpm-md
_EOF
cat <<_EOF >> /tmp/repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
_EOF

#################################
##                             ##
##   Install Package Section   ##
##                             ##
#################################
sudo dnf update -y --refresh

# add fusion repositories
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

## check if packages in configuration, which require pre install commands ##
[[ ${DNF_PACKAGES[@]} =~ "code" ]] && (
  sudo mv /tmp/repos.d/vscode.repo /etc/yum.repos.d/vscode.repo
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
)

[[ ${DNF_PACKAGES[@]} =~ "anydesk" ]] && (
  sudo mv /tmp/repos.d/anydesk.repo /etc/yum.repos.d/anydesk.repo
  sudo rpm --import https://keys.anydesk.com/repos/RPM-GPG-KEY
)

[[ ${DNF_PACKAGES[@]} =~ "teamviewer" ]] && (
  sudo mv /tmp/repos.d/teamviewer.repo /etc/yum.repos.d/teamviewer.repo
  sudo rpm --import https://linux.teamviewer.com/pubkey/currentkey.asc
)

[[ ${DNF_PACKAGES[@]} =~ "brave-browser" ]] && (
  sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
  sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
)

[[ ${DNF_PACKAGES[@]} =~ "signal-desktop" ]] && (
  sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/network:im:signal/Fedora_37/network:im:signal.repo
  sudo rpm --import https://download.opensuse.org/repositories/network:/im:/signal/Fedora_37/repodata/repomd.xml.key
)

## install additional software ##
sudo dnf install -y ${DNF_PACKAGES[@]}

[[ ${#FLATPAK_PACKAGES[@]} -ne 0 ]] && (
  sudo dnf install -y flatpak
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  sudo flatpak install -y flathub
  sudo flatpak install -y ${FLATPAK_PACKAGES[@]}
)

which ansible &> /dev/null && ansible-galaxy collection install community.general vyos.vyos

# install drawio (won't update automaticly!)
curl -s https://api.github.com/repos/jgraph/drawio-desktop/releases/latest | grep browser_download_url | grep '\.rpm' | cut -d '"' -f 4 | wget -O /tmp/drawio.rpm -i -
sudo yum install -y /tmp/drawio.rpm
sudo rm /tmp/drawio.rpm

# TODO yubioath see https://discussion.fedoraproject.org/t/f38-yubioath-desktop-will-no-longer-be-available-in-fedora-repository/45921
#tar -xvf yubico-authenticator-*-linux.tar.gz -C /opt/
#/opt/yubioath-desktop-*-linux/desktop_integration.sh -i

# add password generator script
sudo wget -q https://raw.githubusercontent.com/felbinger/scripts/master/genpw.sh -O /usr/local/bin/genpw
sudo chmod +x /usr/local/bin/genpw

# start jetbrains-toolbox to install idea, pycharm and clion
curl -s -L -o- $(curl -s "https://data.services.jetbrains.com/products?code=TBA"  | jq -r '.[0].releases | .[0].downloads.linux.link') | tar xzC /tmp
/tmp/jetbrains-toolbox*/jetbrains-toolbox

# change ps1
echo "PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" | sudo tee -a /{root,home/${USER}}/.bashrc &> /dev/null

# add your user to some groups for applications
[[ ${DNF_PACKAGES[@]} =~ "VirtualBox" ]] && sudo usermod -aG vboxusers ${USER}
sudo usermod -aG dialout ${USER}

###############################################
##                                           ##
##   Configure Desktop Environment Section   ##
##                                           ##
###############################################

# use nemo as file manager (instead of gnomes default: nautilus)
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

# install gnome shell extensions
extensions=(
  "https://extensions.gnome.org/extension/2890/tray-icons-reloaded/"
  "https://extensions.gnome.org/extension/3843/just-perfection/"
)
for extension in "${extensions[@]}"; do
  extensionId=$(curl -s $extension | grep -oP 'data-uuid="\K[^"]+')
  versionTag=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=${extensionId}" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
  wget -qO /tmp/${extensionId}.zip "https://extensions.gnome.org/download-extension/${extensionId}.shell-extension.zip?version_tag=${versionTag}"
  gnome-extensions install --force /tmp/${extensionId}.zip
  # TODO requires user interaction!
  if ! gnome-extensions list | grep --quiet ${extensionId}; then
      busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s ${extensionId}
  fi
  gnome-extensions enable ${extensionId}
  rm /tmp/${extensionId}.zip
done

# load schemas of installed extensions into gsettings schema database
find ~/.local/share/gnome-shell/extensions/ -type f -name '*.gschema.xml' \
  -exec sudo cp {} /usr/share/glib-2.0/schemas/ \;
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

gsettings set org.gnome.shell.extensions.trayIconsReloaded icon-padding-horizontal 0
gsettings set org.gnome.shell.extensions.trayIconsReloaded icon-margin-horizontal  0
gsettings set org.gnome.shell.extensions.trayIconsReloaded icons-limit 8

gsettings set org.gnome.shell.extensions.just-perfection activities-button false
gsettings set org.gnome.shell.extensions.just-perfection world-clock false
gsettings set org.gnome.shell.extensions.just-perfection weather false
gsettings set org.gnome.shell.extensions.just-perfection window-menu-take-screenshot-button false
gsettings set org.gnome.shell.extensions.just-perfection startup-status 0

gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
gsettings set org.gnome.desktop.interface show-battery-percentage true
gsettings set org.gnome.desktop.interface enable-hot-corners false
gsettings set org.gnome.shell.app-switcher current-workspace-only true

# set background images for screensaver and desktop to static color (#150936)
path=~/Pictures/background.png
convert -size 100x100 'xc:#150936' ${path}
gsettings set org.gnome.desktop.background picture-uri-dark "file://${path}"
gsettings set org.gnome.desktop.background picture-uri "file://${path}"
gsettings set org.gnome.desktop.screensaver picture-uri "file://${path}"

# adjust terminator configuration
gsettings set org.gnome.desktop.default-applications.terminal exec 'terminator'
gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
mkdir -p ~/.config/terminator
cat <<_EOF >> ~/.config/terminator/config
[global_config]
[keybindings]
[profiles]
  [[default]]
    background_color = "#241f31"
    background_darkness = 0.95
    cursor_color = "#aaaaaa"
    show_titlebar = False
    scrollbar_position = hidden
    scrollback_infinite = True
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
    [[[child1]]]
      type = Terminal
      parent = window0
[plugins]
_EOF

gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.datetime automatic-timezone true
gsettings set org.gnome.desktop.calendar show-weekdate true

gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll false

# add keybinds, see https://askubuntu.com/questions/597395/how-to-set-custom-keyboard-shortcuts-from-terminal
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"

# disable help keybind
gsettings set org.gnome.settings-daemon.plugins.media-keys help "[]"

# CTRL + ALT + T -> CMD: terminator
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'terminator'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Control><Alt>t'

# CTRL + SHIFT + S -> CMD: flameshot gui
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Snapshot'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'flameshot gui'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Shift><Control>s'

# Super + E -> Launchers/Home folder
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"

# configure autostart
paths=(
  "/usr/share/applications/syncthing-start.desktop" 
  "/usr/share/applications/signal-desktop.desktop"
  "/var/lib/flatpak/app/org.ferdium.Ferdium/x86_64/stable/fbca90383214fa94cf7721471902e3ec7b8222dbe7e532b71a9b607c445af2ae/export/share/applications/org.ferdium.Ferdium.desktop"
  "/var/lib/flatpak/app/im.riot.Riot/x86_64/stable/9bd0c958912a8187b019b3a11260da2e6c241b92a6e570fd0efc8b2f53186310/export/share/applications/im.riot.Riot.desktop"
)
for path in ${paths[@]}; do
  cp ${path} ~/.config/autostart/
done
chmod +x ~/.config/autostart/*.desktop

# download profile picture for the user
curl -s -L -o ~/Pictures/profile.png https://avatars.githubusercontent.com/u/26925347

##############################
##                          ##
##   Remove Logos Section   ##
##                          ##
##############################
# remove fedora logo from gdm
xhost +si:localuser:gdm
sudo -u gdm gsettings set org.gnome.login-screen logo ''

# remove fedora logo from plymouth and regenerate initramfs
sudo cp /usr/share/plymouth/themes/spinner/watermark.png{,.bak}
sudo convert -size 128x32 xc:transparent /usr/share/plymouth/themes/spinner/watermark.png
sudo cp /boot/initramfs-$(uname -r).img{,.bak}
sudo dracut -f /boot/initramfs-$(uname -r).img


### CLEANUP
rm -r /tmp/repos.d
rm -r /tmp/jetbrains-toolbox*
rm -r ~/Public
rm -r ~/Templates
sudo dnf remove -y nautilus gnome-text-editor
