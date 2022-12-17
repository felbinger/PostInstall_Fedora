#!/bin/bash

### configuration section
DNF_PACKAGES=(
  dnf-plugins-core
  distribution-gpg-keys
  
  terminator                                           # splitable terminal
  chromium
  keepassxc                                            # kdbx compatible password manager
  syncthing
  #sqlitebrowser                                       # simple browser for sqlite databases
  timeshift
  remmina remmina-plugins-{vnc,rdp,www,spice,secret}   # remote access
  #squashfs-tools
  #telegram-desktop
  #dislocker                                           # decrypt windows bitlocker volumes
  VirtualBox
  #gparted                                             # graphical partitioning tool
  #grub-customizer                                     # graphical grub configuration
  #audacity
  #vlc                                                 # videolan: vlc media player
  #totem                                               # gnome video player
  #obs-studio
  #shotwell                                            # image viewer
  gimp
  #drawing
  flameshot                                            # tool to create and modify screenshots
  binwalk                                              # tool to analyse binary files for embeded files and executable code
  #radare2                                             # reverse engeneering tool (required for cutter)
  #wfuzz                                               # fuzzing tool
  nmap
  gobuster                                             # directory and vhost enumeration
  wireshark
  texlive-scheme-full
  texstudio
  kubernetes-client
  ansible
  
  code                                                 # visual studio code using microsoft repo
  anydesk                                              # using anydesk (rhel) repo
  teamviewer                                           # using teamviewer repo
  brave-browser                                        # using brave repo
  signal-desktop                                       # from dnf copr

  #nemo-seahorse                                       # nemo seahorse integration (sign / encrypt)
  gnome-tweaks
  gnome-extensions-app
)
FLATPAK_PACKAGES=(
  im.riot.Riot                                         # Element Client
  #com.jgraph.drawio.desktop                           # draw.io
  com.spotify.Client
  #com.bitwarden.desktop
  #com.brave.Browser
  #org.signal.Signal
  #com.anydesk.Anydesk
  #org.ferdium.Ferdium
)
SNAP_PACKAGES=(
  #element-desktop
  #drawio
  #spotify
  #brave
  #bitwarden
  #ferdium
)

### end of configuration section

sudo dnf update -y --refresh

# add fusion repositories
sudo dnf install -y \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# add microsoft repo for vscode if dnf package code should be installed 
[[ ${DNF_PACKAGES[@]} =~ "code" ]] && (
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  cat <<_EOF | sudo tee /etc/yum.repos.d/vscode.repo
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
_EOF
)

# add repo for anydesk if it should be installed
[[ ${DNF_PACKAGES[@]} =~ "anydesk" ]] && (
  sudo rpm --import https://keys.anydesk.com/repos/RPM-GPG-KEY
  cat << "_EOF" | sudo tee /etc/yum.repos.d/anydesk.repo
[anydesk]
name=AnyDesk RHEL - stable
baseurl=http://rpm.anydesk.com/rhel/x86_64/
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://keys.anydesk.com/repos/RPM-GPG-KEY
_EOF
)

[[ ${DNF_PACKAGES[@]} =~ "teamviewer" ]] && (
  sudo rpm --import https://linux.teamviewer.com/pubkey/currentkey.asc
  cat << "_EOF" | sudo tee /etc/yum.repos.d/teamviewer.repo
[teamviewer]
name=TeamViewer - $basearch
baseurl=https://linux.teamviewer.com/yum/stable/main/binary-$basearch/
gpgkey=https://linux.teamviewer.com/pubkey/currentkey.asc
gpgcheck=1
repo_gpgcheck=1
enabled=1
type=rpm-md
_EOF
)

[[ ${DNF_PACKAGES[@]} =~ "brave-browser" ]] && (
  sudo dnf install -y dnf-plugins-core
  sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
  sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
)

[[ ${DNF_PACKAGES[@]} =~ "signal-desktop" ]] && (
  sudo dnf config-manager --add-repo https://download.opensuse.org/repositories/network:im:signal/Fedora_37/network:im:signal.repo
  sudo dnf install signal-desktop
)

# install additional software
sudo dnf install -y ${DNF_PACKAGES[@]}

# install flatpak and flatpak packages if configured
[[ ${#SNAP_PACKAGES[@]} -ne 0 ]] && (
  sudo dnf install -y flatpak
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak install -y flathub
  flatpak install -y ${FLATPAK_PACKAGES[@]}
)

# install ansible collections, if ansible is installed
which ansible &> /dev/null && ansible-galaxy collection install community.general vyos.vyos

# install snap and snap packages if configured
[[ ${#SNAP_PACKAGES[@]} -ne 0 ]] && (
  sudo dnf install -y snapd
  snap install ${SNAP_PACKAGES[@]}
)

# cutter (reverse engeneering)
#bash scripts/cutter.sh

# install drawio (won't update automaticly!)
curl -s https://api.github.com/repos/jgraph/drawio-desktop/releases/latest | grep browser_download_url | grep '\.rpm' | cut -d '"' -f 4 | wget -i -
sudo yum install ./drawio-x86_64-*.rpm

# switch desktop environment
#sudo dnf install -y cinnamon
#sudo dnf swap -y @gnome-desktop @cinnamon-desktop

# add password generator script
sudo wget -q https://raw.githubusercontent.com/felbinger/scripts/master/genpw.sh -O /usr/local/bin/genpw
sudo chmod +x /usr/local/bin/genpw

# change ps1
echo "PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '" | sudo tee -a /{root,home/${USER}}/.bashrc 

# add your user to some groups for applications
#usermod -aG vboxusers,dialout user

# install jetbrains-toolbox (idea, pycharm, clion)
