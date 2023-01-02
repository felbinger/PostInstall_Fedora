# Fedora 37 Installation Checklist

## Pre Install
Backup your data, don't forget the following:
* SSH configuration and keys (`~/.ssh/`)
* Remmina configurations (`~/.local/share/remmina`)
* GPG keys (`~/.gnupg`)
* Wireguard configurations (`/etc/wireguard/*.conf`)

## Installation
![Language Selection](./img/install_language.png)  
![Summary](./img/install_summary.png)  
![Keyboard Layout](./img/install_keyboard.png)  

![Disk Setup](./img/install_part1.png)  

Select "Encrypt Data" and create the partitions automaticly with btrfs as filesystem. 
![Disk Setup](./img/install_part2.png)  

Make sure to change the btrfs volume names as described in the following two pictures to match ubuntu btrfs naming schemas (which is required for timeshift to work).
![Disk Setup](./img/install_part3.png)  
![Disk Setup](./img/install_part4.png)  

> Warning: The us american keyboard layout is still active in live system!

![Disk Setup](./img/install_part5.png)  
![Disk Setup](./img/install_part6.png)  

You can start the installation now:  
![Summary](./img/install_summary_finished.png)  

Finally you can restart your computer.

On the first start you will be prompted with a dialog where you can create a user account, also you should enable the Third Party Repositories.
![Third Party Repositories](./img/firststart_enable_third-party.png)

## Post Install
Adjust the configuration section in the [`fedora.sh`](./fedora.sh) script and execute it.

### File Manager: nemo
I personally like to change a few settings in the file explorer **Nemo (Edit/Preferences)**.  
![Nemo: Views](./img/nemo_views.png)

![Nemo: Behavior](./img/nemo_behavior.png)

![Nemo: Toolbar](./img/nemo_toolbar.png)

Press CTRL + L one time to make the URL bar editable.

### Text-Editor: xed
![Xed Preferences](./img/xed_preferences.png)

### Other
* Adjust Startup Applications (--start-in-tray / --hidden flags) to start in tray
