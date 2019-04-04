# [NixOS](https://nixos.org/) installation on a Dell XPS 15 9570
 
On windows 10 :
* Update the EFI/BIOS firmware to the latest version
* Free space and defrag disk (use PerfectDisk or UltraDefrag). Perform a "bootime defrag" otherwise some system files are locked. Be aware that a NTFS file system has metadata stuck right in the middle of the partition and it is not easy to move them.
* Due to stuck metadata, reduce the size of the window partition to 50%, this makes room for the NIXOS partition.
* Create a live USB from a downloaded NixOS iso. Label it NIXOS_ISO (this was important otherwise i got a 
  "squashfs error... unable to read id index table.").

On hardware config menu (F2 while booting):
* deactivate RAID and activate AHCI instead. Otherwise you won't be able to mount the device before installation.

On Bootmenu (F12 while booting)
* try to switch off secure boot to start the live usb, if it does not work try legacy mode

On the live NIXOS:
* `mkfs.ext4 /dev/xxx`, `e2label /dev/xxx NIXOS`
* install using configuration.nix and hardware-configuration.nix

On NIXOS:
* the X server was not working until I updated the kernel (pkgs.linuxPackages_latest). `nomodeset` kernelParam might also help.

## Use dual boot
Each time you switch have to :
(i) activate RAID (ii) activate "secure boot"; for booting on Windows 
(i) activate AHCI (ii) deactivate "secure boot"; for booting on systemd-boot/NIXOS

## Main differences with the [install of arch linux on an ASUS zenbook pro UX32VD](https://github.com/JosephLucas/archlinux_installation): 
* systemd-boot instead of rEFInd
* i3 as window manager
* icon-theme "rodent" default in xfce instead of gnome-humanity
* [fish](https://nixos.wiki/wiki/Fish) instead of grml

## Common commands

Try some packages in the user space
```bash
nix-env -iA package
```

###Free some space
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

## Bluetooth (for Bose Quiet Confort 35)

[This](http://www.planet-libre.org/index.php?post_id=21101) helped and [this](https://nixos.wiki/wiki/Bluetooth) also.
[This](https://askubuntu.com/a/773391) was very useful.

## Solve audio issues

If, when you plug a headset via a jack plug, the hotplug activation yields a loud crackling sound, it might be a larsen.
I solved a larsen by just lowering lowering (or muting) the headset microphone. Do it via alsamixer if it's not feasible via pavucontrol.

Beware plug'in jack headset with hotplug, your ears may suffer !

If pavucontrol is not showing all output sources, you may want to reset pulseaudio user settings.
```bash
rm -rf ~/.config/pulseaudio
```

## Nix overlays

[A comprehensible example](https://stackoverflow.com/a/50783276) and [some explanations](https://stackoverflow.com/a/53537841).

## TeXstudio dark theme

See https://github.com/texstudio-org/texstudio/issues/45
```
wget https://www.dropbox.com/s/imkvx08gsjtzww8/TeXstudio_francesco_dark.rar
unar Downloads/TeXstudio_francesco_dark.rar
cd TeXstudio_francesco_dark
```
Read the README and install
```
sed 's/Interface\\Language=fr/Interface\\Language=fr/g' francesco_dark_win.txsprofile > $HOME/.config/texstudio/dark_theme.txsprofile
sed "s%C:/Users/franc/AppData/Roaming/TeXstudio/rc/%$HOME/.config/texstudio/%g" stylesheet.qss > $HOME/.config/texstudio/stylesheet.qss
cp -r rc ~/.config/texstudio/
```
Then load `$HOME/.config/texstudio/dark_theme.txsprofile` in texstudio : Option->Load Profiles... 

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
 2. tap the keyboard plus a space
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

[Solve the white flash when firefox loads a new page](https://www.reddit.com/r/firefox/comments/8g37x2/any_way_to_disable_the_white_flash_when_a_website/) :
```bash
echo '.browserContainer { background-color: #000000 !important; }' >> .mozilla/firefox/ir3ucze0.default/chrome/userChrome.css
```

## Thunderbird 

[Thunderbird'support of Gmail](https://support.mozilla.org/en-US/kb/thunderbird-and-gmail) and [Gmail's support of Thunderbird](https://support.mozilla.org/en-US/kb/thunderbird-and-gmail).
[Comprehensive webpage support](http://kb.mozillazine.org/Using_Gmail_with_Thunderbird_and_Mozilla_Suite).

Install a french dictionary for spellchecking.

TODO :
* Design a backup workflow for [the file with mail filters](https://askubuntu.com/a/184293).

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

## Auto-mount usb removable media with [udiskie](https://github.com/coldfix/udiskie)
xfce settings-manager >  Session and startup > Application autostart, and add 
```bash
udiskie --tray
```

## Configure fish shell

Copy this repository `.config/fish` folder, then/or
```fish
fish_config 
```

NB: the preview of the shell prompt depends on the current folder when you exec `fish_config`.
If you want to preview the git hints, be sure to be in a git versioned folder.

## home-manager

Follow the [installation procedure](https://github.com/rycee/home-manager)

During a new install
```bash
mkdir $HOME/Dev/nixos
git clone https://github.com/JosephLucas/nixos.git
mkdir -p .config/nixpkgs
ln -s $HOME/Dev/nixos/.config/nixpkgs/home.nix .config/nixpkgs/home.nix
```

## XFCE

### Configure colors of the xfce-terminal

In xfce4-terminal: Edit > Preferences > Colors and edit the specific color

### Themes

In `xfce4-settings-manager` > Appearance:

* "Tango" icon theme
* "Adwaita dark" style, a gtk2 and gtk3 theme

### Keyboard

To write french with a QWERTY: 
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

## Integrate pycharm to NixOS with i3

(in Help | Edit custom properties...)
[Adding suppress.focus.stealing=false in custom properties fixes](https://intellij-support.jetbrains.com/hc/en-us/community/posts/360001411659-Lose-Focus-after-Switching-Workspace-in-i3wm).

With the associated i3 config, all windows of pycharm open in `ws1`. Set `ws1` in tabulated (mod+w) for an optimised workflow.

Associated .gitconfig allows to use pycharm diff and merge tools.

## TIPS
"Unlock" the panel of xfce if you want to move it. This can be done in the preference of the panel.

Clear systemd journals older than X days
```bash
journalctl --vacuum-time=10d
```

Clear systemd journals if they exceed X storage
```bash
journalctl --vacuum-size=2G
```

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

## TODO
[solve annoying prompt for nextcloud client](https://github.com/NixOS/nixpkgs/issues/38266)

Install missing [antidote](https://antidote.info/fr)

Install and pair LineageOS for mobile phone.

Pidgin with plugins for : whatsapp irc facebook googletalk skype steam battle.net