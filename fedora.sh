#!/bin/sh

### configuration section
DNF_PACKAGES=(
  dnf-plugins-core
  distribution-gpg-keys
  terminator                                           # splitable terminal
  #chromium
  keepassxc                                            # kdbx compatible password manager
  syncthing
  #nemo-seahorse                                        # nemo seahorse integration (sign / encrypt)
  #sqlitebrowser                                       # simple browser for sqlite databases
  timeshift
  remmina remmina-plugins-{vnc,rdp,www,spice,secret}  # remote access
  #squashfs-tools
  #telegram-desktop
  #dislocker                                           # decrypt windows bitlocker volumes
  VirtualBox
  #gparted                                             # graphical partitioning tool
  #grub-customizer                                     # graphical grub configuration
  #audacity
  #vlc                                                  # videolan: vlc media player
  #totem                                               # gnome video player
  #obs-studio
  #shotwell                                             # image viewer
  gimp
  #drawing
  flameshot                                            # tool to create and modify screenshots
  binwalk                                             # tool to analyse binary files for embeded files and executable code
  #radare2                                             # reverse engeneering tool (required for cutter)
  #wfuzz                                               # fuzzing tool
  gobuster                                            # directory and vhost enumeration
  wireshark
  nmap
  snapd
  code
  anydesk
  chromium
  gnome-tweaks
  gnome-extensions-app
  texlive-scheme-full
  texstudio
  kubernetes-client
  ansible
)
FLATPAK_PACKAGES=(
  #im.riot.Riot                                         # Element Client
  #com.jgraph.drawio.desktop                            # draw.io
  #com.spotify.Client
  #com.bitwarden.desktop
  #com.brave.Browser
  org.signal.Signal
  com.anydesk.Anydesk
  #org.ferdium.Ferdium
)
SNAP_PACKAGES=(
  element-desktop
  drawio
  spotify
  brave
  bitwarden
  ferdium
)

### end of configuration section

sudo dnf update -y --refresh

# add fusion repositories
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# add flathub
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub

# add microsoft repo for vscode
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat <<_EOF | sudo tee /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
_EOF

# add repo for anydesk
sudo rpm --import https://keys.anydesk.com/repos/RPM-GPG-KEY
cat << "_EOF" | sudo tee /etc/yum.repos.d/anydesk.repo
[anydesk]
name=AnyDesk RHEL - stable
baseurl=http://rpm.anydesk.com/rhel/$releasever/$basearch/
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY
_EOF

# install additional software
sudo dnf install -y ${DNF_PACKAGES[@]}
flatpak install -y ${FLATPAK_PACKAGES[@]}

if which ansible &> /dev/null; then
  ansible-galaxy collection install community.general vyos.vyos
fi

snap install ${SNAP_PACKAGES}

# add password generator script
sudo wget -q https://raw.githubusercontent.com/felbinger/scripts/master/genpw.sh -O /usr/local/bin/genpw
sudo chmod +x /usr/local/bin/genpw

# change ps1
echo "PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" | sudo tee -a /{root,home/${USER}}/.bashrc 

# cutter (reverse engeneering)
#bash scripts/cutter.sh

# install drawio (won't update automaticly!)
curl -s https://api.github.com/repos/jgraph/drawio-desktop/releases/latest | grep browser_download_url | grep '\.rpm' | cut -d '"' -f 4 | wget -i -
sudo yum install ./drawio-x86_64-*.rpm

# switch desktop environment
#sudo dnf install -y cinnamon
#sudo dnf swap -y @gnome-desktop @cinnamon-desktop

# add your user to some groups for applications
#usermod -aG vboxusers,dialout user

# install jetbrains-toolbox
