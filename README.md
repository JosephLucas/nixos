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

## TIPS
"Unlock" the panel of xfce if you want to move it. This can be done in the preference of the panel.

## TODO
[solve annoying prompt for nextcloud client](https://github.com/NixOS/nixpkgs/issues/38266)

install missing [antidote](https://antidote.info/fr)