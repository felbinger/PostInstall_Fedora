# Fedora 34 Installation Checklist

## Pre Install
Backup your data, don't forget the following:
* SSH configuration and keys (`~/.ssh/`)
* Remmina configurations (`~/.local/share/remmina`)

## Post Install
Adjust the configuration section in the [`fedora.sh`](./fedora.sh) script and execute it. Afterwards logout and login again with Cinnamon as desktion environment (right bottom cornor -> cog icon). 

I personally like to change a few settings in the file explorer **Nemo (Edit/Preferences)**.  
![Nemo: Views](./img/nemo_views.png)

![Nemo: Behavior](./img/nemo_behavior.png)

![Nemo: Toolbar](./img/nemo_toolbar.png)

Press CTRL + L one time to make the URL bar editable.

Make sure your **Date and Time** settings work for you. By default the first day of the week is sunday and the date won't be displayed in the calendar applet.  
![Settings: Date and Time](./img/settings_date_time.png)

If you are on a notebook make sure to change the **Mouse and Touchpad** settings. (e.g. horiziontal or vertical scrolling)

I like to have a clean desktop, so I only add the trash bin.
![Settings: Desktop](./img/settings_desktop.png)

I also like to see some system stats in my panel, so I always install the applet: CPU Temperatur Indicator
Also I like to add `redshift-gtk` for manual blue light filtering.

As you probably noticed the system made some noice when logging in. I don't like those so I disable all system sounds.
![Settings: Sound](./img/settings_sounds.png)

After I added my printers, configured my preferred and startup applications.

![Settings: Preferred Applications](./img/settings_preferred_applications.png)

## TODO
- SELinux Cinnamon adjustments
  ```shell
  ausearch -c 'gnome-session-c' --raw | audit2allow -M my-gnomesessionc
  semodule -X 300 -i my-gnomesessionc.pp
  ```
- Install JetBrains Toolbox