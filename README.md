# [NixOS](https://nixos.org/) installation on a Dell XPS 15 9570
 
## Install NixOS alongside a pre-existing Windows 10:

### Update BIOS firmwares and BIOS utilities

Use the `Dell Update` utility to get latest EFI/BIOS firmware and latest OS Recovery Tool versions. 

### Get room for NIXOS

1. Free as much disk space as possible by removing/uninstalling unused files and softwares
2. Unencrypt the disk by disabling _BitLocker_ in order to unlock next defrag/resize actions. Un-encryption can be done through the settings manager. Beware that un-encryption takes several minutes.
3. Defragment the windows partition with [Macrorit](https://macrorit.com/).  
4. Resize the windows partition, still with Macrorit.

If you plan to use another tool to defrag (e.g. _UltraDefrag_ or _PerfectDisk_), perform a _boot time_ defragmentation to get rid of otherwise unmovable system files. Nevertheless, sometimes, due to stuck metadata in the middle of the NTFS part you might not be able to reduce the size of the windows partition above 50%.

### Create a NixOS live USB installer

1. Download the latest NixOS iso
2. Using _Rufus_, create the live USB. Check that it is labeled NIXOS_ISO otherwise you may get a 
  "squashfs error... unable to read id index table."). A MBR partition table worked.

### Create a live USB from a linux distribution 

1. `lsblk` to get the device with the usb stick (e.g. `/dev/sdX`) 
2. `sudo cfdisk /dev/sdX` and remove all partitions, then enter `Write` and validate by typing `yes` 
3. Copy all binary data from the iso to the bare usb stick device
```
sudo dd if=nixos-graphical-XXX-linux.iso of=/dev/sda status=progress
```

### Boot with the live USB

On hardware config menu (F2 while booting):
* Deactivate RAID and activate AHCI instead. Otherwise the live NIXOS won't see the RAID device before installation.
* For recent BIOS version (e.g. 1.8.1) _Enable Legacy Option ROMs_ in Settings > General > Advanced Boot Options. 
* Switch off secure boot

In some cases, _legacy mode_ might be useful to boot on the live USB.

You may need to boot twice to see the USB in the list of bootloaders, 
first boot seems to detect the USB bootloader but do not show it.

On bootloader menu (F12 while booting), select the USB stick. 

### Create a root partition

The root partition for / (root), will contain /home and the swap file.
The root partition can be
* unencrypted : `mkfs.ext4 -L NIXOS /dev/xxx`, or
* encrypted :
```bash
cryptsetup luksFormat /dev/xxx # encrypt
luksOpen /dev/xxx enc-dev # open encryption; enc-dev is arbitrary and means encrypted-device
mkfs.ext4 -L NIXOS /dev/mapper/enc-dev
```

### Create an ESP

In addition to the root partition, you need an ESP. If it does not already exist, target a 512 MiB, fat32 partition labeled ESP.

## Install NixOS

```bash
mount /device/disk/by-label/NIXOS /mnt
mkdir -p /mnt/boot
mount /device/disk/by-label/ESP /mnt/boot
```

Generate initial hardware-configuration.nix and configuration.nix in /mnt/etc/nixos/

```
nixos-generate-config --root /mnt
```

You can check that /mnt/etc/nixos/hardware-configuration.nix handles the encryption and the file-system.

Install using configuration.nix and hardware-configuration.nix
```bash
nixos-install
```

## Rebuild NixOS with a downloaded configuration.nix

On newly installed NixOS you can only login with "root".

NB: the X server was not working for me until I updated the kernel (pkgs.linuxPackages_latest). `nomodeset` kernelParam might also help.

Download and install a custom configuration.nix from github
```bash
mv /etc/nixos/configuration{,.bak}.nix
mv /etc/nixos/hardware-configuration{,.bak}.nix
mkdir -p /root/Dev && cd /root/Dev
nix-env -i git
git clone https://github.com/JosephLucas/nixos
nix-env -e git
install -o root -g root -m 644 configuration.nix /etc/nixos/
```

You might want to edit by hand the /etc/nixos/hardware-configuration.nix using info in /root/Dev/nixos/hardware-configuration.nix. Then

```bash
dir="etc/nixos/overlays" && mkdir -p /"$dir" && chmod -R 644 /"$dir" && install -o root -g root -m 644 "$dir"/* /"$dir"/
dir="root/nixos/secrets" && mkdir -p /"$dir" && chmod -R 644 /"$dir" && install -o root -g root -m 644 "$dir"/ddclient.conf /"$dir"/
```

Fill by hand /root/nixos/secrets/ddclient.conf missing fields. Then

```
install -o root -g root -m 644 root/nixos/lightdm_backgroung.png /root/nixos/
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
```

Check current channels with `nix-channel --list`.

Rebuild NixOS 

```
nixox-rebuild switch --upgrade
rm -r /root/Dev
```

## Set a new user

```
su <user> # change user
passwd # replace old passwd 1234 (default) with a new passwd
cd ~ && mkdir ~/Dev
git clone https://github.com/JosephLucas/nixos
cd nixos 
install -o $USER -g users -m 644 home/user/.face $HOME/
install -o $USER -g users -m 644 home/user/.wallpaper.jpg $HOME/ 
```

## Manage user dotfiles

Install [home-manager](https://github.com/rycee/home-manager):

```bash 
su <user> # next cmds should not be executed as root but as <user>
cd ~ && mkdir -p .config/nixpkgs
ln -s $HOME/Dev/nixos/home/user/.config/nixpkgs/home.nix $HOME/.config/nixpkgs/home.nix
nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update
```

Log out and log in (duno why but seemed necessary). Then do install home-manager and create the first user-generation

```bash
nix-shell '<home-manager>' -A install
```

### Use Windows-NixOS dual boot

Before switching, it is necessary to :
(i) activate RAID (ii) activate "secure boot"; for booting on Windows 
(i) activate AHCI (ii) deactivate "secure boot"; for booting on systemd-boot/NIXOS

## Themes

In `xfce4-settings-manager` > Appearance:

* "Tango" icon theme
* "Adwaita dark" style, a gtk2 and gtk3 theme

For applications using the Qt GUI library, use `qt5ct` application to adjust the theme.

## Keyboard

Enable writing french with a QWERTY: 
 1. go to settings-manager > keyboard > layout
 2. in layout option", set a shortcut to switch keyboard.
 3. add "English (US, intl. with dead keys)"
 
 (a "dead key" is a key doing nothing when pressed once, e.g. \` is a dead key for this layout)
 
 Then, add an item in the xfce panel to see the current keyboard.
 
 When using this last keyboard:
 
  | typing          | gives result |
  |:---------------:|:------------:|
  | \` + a          | à            |
  | ´ + e           | é            |
  | Alt + ´         | \'           |
  | Alt + Shift + ¨ | "            |
  | Alt + ,         | ç            |

## Configure colors of the xfce-terminal

In xfce4-terminal: Edit > Preferences > Colors and edit the specific color

## Auto-start some applications 

xfce settings-manager >  Session and startup > Application autostart, and add 
* `i3`, the window manager and 
* `udiskie --tray`, the panel item of [udiskie](https://github.com/coldfix/udiskie) for managing removable media

## Firefox 

### Security

[Good read](https://restoreprivacy.com/) about security/privacy on the web.

Sites to test security/privacy:
* browserprint.info
* amiunique.org/ 
* panopticlick.eff.org/
* privacy.net/analyzer/

Add a "master password" to secure the access to passwords registered in firefox.

Install uBlock, CanvasBlocker, Decentraleyes firefox extensions.

#### [Protection optimised user configuration](https://github.com/pyllyukko/user.js/tree/relaxed#installation).

Create a new firefox profile directory with the "Profile Manager", executed with
```bash
firefox --no-remote -P
```

Then load the user config 
```
mkdir -p ~/Dev && cd ~/Dev
git clone -b relaxed https://github.com/pyllyukko/user.js 
ln -s $HOME/Dev/user.js/user.js $HOME/.mozilla/firefox/mermiu44.jlucas/
```

### Configure search tools

Install "Search Google Scholar" extension.

Go to Preferences > Search > One click search engines

Add a keyword to preferred search engines.

To use a specific search engine:
 1. select the bar
 2. tap the keyb plus a space
 3. continue with request

### spell-checker

Install `French Spelling Dictionnary`. In text field it is now possible to use this spellchecker with the right button. 

### Dark theme

Make sure the `shadowfox` nixos package is installed, then
```bash
shadowfox-updater
```
With tab/enter:
 1. select your .mozilla/firefox/<profile> 
 2. Install/Update 
 3. exit and start firefox

Install the "Dark reader" extension and "Dark" theme within Firefox.

(seems not needed anymore): [solve the white flash when firefox loads a new page](https://www.reddit.com/r/firefox/comments/8g37x2/any_way_to_disable_the_white_flash_when_a_website/) :
```bash
echo '.browserContainer { background-color: #000000 !important; }' >> .mozilla/firefox/ir3ucze0.default/chrome/userChrome.css
```

## Thunderbird 

[Thunderbird'support of Gmail](https://support.mozilla.org/en-US/kb/thunderbird-and-gmail) and [Gmail's support of Thunderbird](https://support.mozilla.org/en-US/kb/thunderbird-and-gmail).
[Comprehensive webpage support](http://kb.mozillazine.org/Using_Gmail_with_Thunderbird_and_Mozilla_Suite).

Install a french dictionary for spellchecking.

Preferences > Display > Colors ... 

Select a gray background, an almost white text and set the _Override colors ..._ multi-choice list to _Always_

## Pidgin

If you cannot see pidgin plugins, delete previous configuration 
```
rm -r ~/.purple 
```

## Bluetooth (for Bose Quiet Confort 35)
[Some](http://www.planet-libre.org/index.php?post_id=21101) [good](https://nixos.wiki/wiki/Bluetooth) [reads](https://askubuntu.com/a/773391).

If after pairing, you cannot connect due to [blueman.bluez.errors.DBusFailedError: Protocol not available...](https://github.com/blueman-project/blueman/issues/547):
```bash
killall pulseaudio
```

If needed
```bash
connect_boseQC35
```

## Solve audio issues

Beware plug'in jack headset with hotplug, your ears may suffer !

If, when you plug a headset via a jack plug, the hotplug activation yields a loud crackling sound, it might be a larsen.
I solved a larsen by just lowering (or muting) the headset microphone. Do it via alsamixer if it's not feasible via pavucontrol.

If pavucontrol is not showing all output sources, you may want to reset pulseaudio user settings.
```bash
rm -rf ~/.config/pulseaudio
```

## Install and run OnlyOffice through docker

There is no NixOS package for OnlyOffice yet. OnlyOffice AppImage or tarball both use binary dependencies compliant with the FHS. These packages do not play well with nixos thus the docker image seems the best way to [install OnlyOffice](https://hub.docker.com/r/onlyoffice/communityserver#installing-onlyoffice-community-server-integrated-with-document-and-mail-servers).

```bash
wget http://download.onlyoffice.com/install/opensource-install.sh
bash opensource-install.sh -md yourdomain.com
```

In my case, the domain is localhost, thus replace `yourdomain.com` by `localhost`.

Once installed and launched, open a browser and go to the url `localhost`. It will open a javascript page and setup OnlyOffice.

EDIT : 

With previous installation [NGINX workers](https://stackoverflow.com/questions/23386986/what-is-worker-processes-and-worker-connections-in-nginx) where allocating too much RAM (around 8Go) and it was not easy to configure that, even with NGINX_* env variables in onlyoffice docker containers. 

Tried unsuccesfuly to use [docker-compose](https://github.com/ONLYOFFICE/Docker-CommunityServer/issues/42).
After that a new problem was to configure nginx to "listen localhost" (allow requests from localhost).

## Configure fish shell

Copy this repository `.config/fish` folder, then/or
```fish
fish_config 
```

NB: the preview of the shell prompt depends on the current folder when you exec `fish_config`.
If you want to preview the git hints, be sure to be in a git versioned folder.

## Integrate pycharm to NixOS with i3Beware plug'in jack headset with hotplug, your ears may suffer !

(in Help | Edit custom properties...)
[Adding suppress.focus.stealing=false in custom properties fixes](https://intellij-support.jetbrains.com/hc/en-us/community/posts/360001411659-Lose-Focus-after-Switching-Workspace-in-i3wm).

With the associated i3 config, all windows of pycharm open in `ws1`. Set `ws1` in tabulated (mod+w) for an optimised workflow.

Associated .gitconfig allows to use pycharm diff and merge tools.

## Use [OpenDNS](https://en.wikipedia.org/wiki/OpenDNS)

OpenDNS provides phishing protection and custom content filtering.
Create an account on https://www.opendns.com/ and configure the remote dns server. 
Add your IP network (the public ip) so that openDNS can recognise you.

### Allow dynamic IP

To handle a changing public IP, enable [ddclient](https://doc.ubuntu-fr.org/dns_dynamique).
It will communicate the new IP to OpenDNS whenever the IP changes.

Good reads
https://github.com/NixOS/nixpkgs/blob/release-18.09/nixos/modules/services/networking/ddclient.nix
https://support.opendns.com/hc/en-us/articles/227987727-Linux-IP-Updater-for-Dynamic-Networks
https://github.com/NixOS/nixpkgs/issues/48432
https://github.com/NixOS/nixpkgs/issues/24288

Create a configuration file based on the associated ./secrets/ddclient.conf template file
```bash
su root
mkdir -p /root/nixos/secrets/
vim /root/nixos/secrets/ddclient.conf
```
Edit the <...> fields of the ddclient.conf file. Then, still as `root`
```bash
chown -R root:root /root/nixos/secrets
sudo chmod -R 600  /root/nixos/secrets
```

[Disable ipv6](https://support.opendns.com/hc/en-us/community/posts/220040827/comments/224654527) since 
"if using IPv6 connectivity (for DNS queries), the additional features of OpenDNS (content filtering, individual domain blocking, logs and stats, etc) do not take effect, because you cannot register your IPv6 address at https://dashboard.opendns.com/settings/ yet"

## Shortcuts

As much as possible standard shortcuts are used

XFCE

 |                 |               |
 |:---------------:|:--------------|
 | Alt+3           | app finder    |

i3

|                 |               |
|:---------------:|:------------|
| Mod+D          | dmenu                 |
| Mod+Shift+q    | kill current window   |
| Mod+Shift+x    | lock screen           |
| Mod+w          | horizontally tab windows   |
| Mod+s          | vertically tab windows     |

## TIPS

## Common commands

Try some packages in the user space
```bash
nix-env -iA package
```

### Free some space
```bash
nix-collect-garbage --delete-older-than 3d
```
Get all packages installed in the user space
```bash
nix-env -q
```
Uninstall a package
```bash
nix-env -e package
``` 

### Use small "channels" to get quick fixes/latest versions of nix packages

When a pull request is merged, it is first integrated to _nixos-unstable-small_ channel. Some times later binary builds of the corresponding packages are made available on _nixos-unstable_ channel.
It might be useful to switch to the _small_ channel to get a quick fix even if a local build will be requested.  

### nixos-rebuild switch and --upgrade

`nixos-rebuild switch --upgrade` is equal to `nix-channel --update nixos; nixos-rebuild switch` : i.e. it first update the channels and then rebuild the system.

If you want to: 
* add/remove a package but keep all other package as they are : `nixos-rebuild switch`
* upgrade all packages to latest versions (described in the corresponding branch of nixpkgs) or get a merged pull request on master:
```
nix-channel --add https://nixos.org/channels/nixos-unstable-small nixos
nixos-rebuild switch --upgrade
```
After some times you can return to `unstable` to benefit from the binary cache 
```bash
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
```

## Nix overlays

[A comprehensible example](https://stackoverflow.com/a/50783276) and [some explanations](https://stackoverflow.com/a/53537841).

### Beware some packages

#### busybox
Beware the "busybox" package, it seems to disturb the standard functioning of some commands. 
For instance `ps` wont have anymore the -p option if busybox is installed.

#### pstree
nix-env -iA nixos.pstree does not install the real pstree, since the former would return:
```bash
pstree $Revision: 2.39 $ by Fred Hucht (C) 1993-2015
EMail: fred AT thp.uni-due.de

Usage: pstree [-f file] [-g n] [-l n] [-u user] [-U] [-s string] [-p pid] [-w] [pid ...]
   -f file   read input from <file> (- is stdin) instead of running
             "ps -eo uid,pid,ppid,pgid,args"
   -g n      use graphics chars for tree. n=1: IBM-850, n=2: VT100, n=3: UTF-8
   -l n      print tree to n level deep
   -u user   show only branches containing processes of <user>
   -U        don't show branches containing only root processes
   -s string show only branches containing process with <string> in commandline
   -p pid    show only branches containing process <pid>
   -w        wide output, not truncated to window width
   pid ...   process ids to start from, default is 1 (probably init)

Process group leaders are marked with '='.
```
that seems to correspond to https://github.com/tmm1/pstree which is not the expected pstree.

Install expected pstree through nixos.pismic.

## Other arbitrary tips

"Unlock" the panel of xfce if you want to move it. This can be done in the preference of the panel.

Clear systemd journals older than X days
```bash
journalctl --vacuum-time=10d
```

Clear systemd journals if they exceed X storage
```bash
journalctl --vacuum-size=2G
```

To debug dns lookups
```bash
nslookup -type=txt debug.opendns.com
```

## Check-list for a backup

The state of NixOS is backed up through the commited configuration.nix and the state of user configurations (dotfiles/wallpapers) are commited through home-manager home.nix and some commited files (wallpapers) too.

Some files are too heavy to be commited or contain personal data.
These files/folders that should be backed up by hand, are:
* in the $HOME: Documents, Dev, Images, Music, Videos, Nextcloud, Backups
* Firefox bookmarks (export them passing by Ctrl+Shift+O)
* Thunderbird [mail filters](https://askubuntu.com/a/184293) ./thunderbird/.../msgFilterRules.dat
* XFCE config files .config/xfce (FIXME: didn'tried yet to restore them)

## Main differences with the [install of arch linux on an ASUS zenbook pro UX32VD](https://github.com/JosephLucas/archlinux_installation): 
* systemd-boot instead of rEFInd
* i3 instead of xfce window manager
* icon-theme "tango" (already in default in xfce) instead of gnome-humanity
* [fish](https://nixos.wiki/wiki/Fish) shell instead of grml zsh

## TODO
[solve annoying prompt for nextcloud client](https://github.com/NixOS/nixpkgs/issues/38266)

Install missing [antidote](https://antidote.info/fr)

Install and pair LineageOS for mobile phone.

Explain file meanings:
e.g. : dotfiles/.face is a png image used showing the user face in lightdm 

Ristretto as an issue with thumbnails/preview images. Use feh instead, it is even more powerful.

Add custom actions for Thunar

Create a package for "i3lock-fancier" instead of "i3lock-fancy" : to allow switching keyboard layout while the screen is locked and you type a password.

https://www.reddit.com/r/i3wm/comments/3n7txe/i_cant_get_rid_of_the_loading_mouse_cursor_on/cvm28jt?utm_source=share&utm_medium=web2x

Icons are in /run/current-system/sw/share/icons/

Do TIPP10: learn to type efficiently

[udev rule for usb hotplug](https://unix.stackexchange.com/a/86425)

[article of xfce over mounting removable media](https://docs.xfce.org/xfce/thunar/using-removable-media)

