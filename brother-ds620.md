# Brother DS620

Checkout [joakim.uddholm.com/posts/setting-up-brother-ds620-on-linux](https://joakim.uddholm.com/posts/setting-up-brother-ds620-on-linux) for debian based installation process

1. Download Driver (RPM) from [support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=ds620_all](https://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=ds620_all) 

2. Install Driver (`sudo dnf install libsane-dsseries-1.0.5-1.x86_64.rpm`), afterwards you may test your scanner with (`sudo simple-scan`) 

3. Add your user to users group (`sudo usermod -aG users $USER`)

4. Reboot (or at least log out of your user account to apply the group changes), afterwards you should be able to use `simple-scan`.

5. If it doesn't work check the udev rules (`/etc/udev/rules.d/50-Brother_DSScanner.rules`), they should look like this:
   ```
   KERNEL=="sg[0-9]*", ATTRS{type}=="0", ATTRS{vendor}=="Brother", ATTRS{model}=="DS-620", MODE="0666", GROUP="users"
   KERNEL=="sg[0-9]*", ATTRS{type}=="0", ATTRS{vendor}=="Brother", ATTRS{model}=="DS-720D", MODE="0666", GROUP="users"
   KERNEL=="sg[0-9]*", ATTRS{type}=="0", ATTRS{vendor}=="Brother", ATTRS{model}=="DS-820W", MODE="0666", GROUP="users"
   KERNEL=="sg[0-9]*", ATTRS{type}=="0", ATTRS{vendor}=="Brother", ATTRS{model}=="DS-920DW", MODE="0666", GROUP="users"
   ```
