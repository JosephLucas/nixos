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
* oh-my-zsh instead of grml

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

```bash
ranger --copy-config=all
```

## Bluetooth (for Bose Quiet Confort 35)

[This](http://www.planet-libre.org/index.php?post_id=21101) helped and [this](https://nixos.wiki/wiki/Bluetooth) also.
[This](https://askubuntu.com/a/773391) was very useful.

## Overlays

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

## Firefox dark theme

Make sure the `shadowfox` nixos package is installed, then
```bash
shadowfox-updater
```
With tab enter, select Install/Update. Then exit and start firefox.

Install the "Dark reader" extension and "Dark" theme within Firefox.

[Solve the white flash when firefox loads a new page](https://www.reddit.com/r/firefox/comments/8g37x2/any_way_to_disable_the_white_flash_when_a_website/) :
```bash
echo '.browserContainer { background-color: #000000 !important; }' >> .mozilla/firefox/ir3ucze0.default/chrome/userChrome.css
```

## TIPS
"Unlock" the panel of xfce if you want to move it. This can be done in the preference of the panel.

## TODO
[solve annoying prompt for nextcloud client](https://github.com/NixOS/nixpkgs/issues/38266)

install missing [antidote](https://antidote.info/fr)