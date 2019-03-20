# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan + custom swapfile.
      ./hardware-configuration.nix

      # FIXME : use home-manager if the community decides to integrate it
      # Module for the management of user dotfiles
      # https://rycee.gitlab.io/home-manager/index.html
      # <home-manager/nixos>
    ];
  
  swapDevices = [
   # cat /proc/meminfo -> MemTotal = 16061732 kB (approx 15318 MiB or 16Gb)
   # Creates a swapfile
   { device = "/swapfile"; size = 15318;} # MiB
   # The swapfile will mainly be used for hibernation, it can be removed if space is needed.    
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_4_20;
    
    kernelParams = [
       # many parameters are from : https://github.com/JackHack96/dell-xps-9570-ubuntu-respin#manual-respin-procedure
       "acpi_osi=Linux"
       "acpi_rev_override=1"

       # Disable this if it causes on/off loss of ethernet connection
       "pcie_aspm=force" # force Active State Power Management (ASPM) even on devices that claim not to support it

       "mem_sleep_default=deep"
       # Newest kernels have moved the video mode setting into the kernel. So all the programming of the hardware specific clock rates and registers on the video card happen in the kernel rather than in the X driver when the X server starts. This makes it possible to have high resolution nice looking splash (boot) screens and flicker free transitions from boot splash to login screen. Unfortunately, on some cards this doesnt work properly and you end up with a black screen. Adding the nomodeset parameter instructs the kernel to not load video drivers and use BIOS modes instead until X is loaded.
       # "nomodeset" # disable kernel modesetting (kms) that sets display resolution and depth in the kernel space

       # In scenarios where you are getting unexplained system freeze scenarios, NMI watchdog interrupt handler will simply kill whatever process happens to be freezing the CPU at the moment. This way, your CPU gets freed up AND you get a detailed stack trace of why your CPU got frozen up in the first place.
       "nmi_watchhog=1"
    ];

    initrd = {
      kernelModules = [
        # "i915"
        # "dell-smm-hwmon"
        "scsi_mod"
      ];
    };

    # scsi_mod.use_blk_mq=1 # optimises the scheduling of IO on disks using multi-cores
    extraModprobeConfig = ''
      options scsi_mod use_blk_mq=1
    '';
    # practical module option when the intel chip is used since initrd
    # options i915 enable_fbc=1 enable_guc_loading=1 enable_guc_submission=1 disable_power_well=0

    # FIXME: use a kernel module for fans ?
    # https://github.com/torvalds/linux/blob/master/drivers/hwmon/dell-smm-hwmon.c
    # options dell-smm-hwmon restricted=0 force=1
    
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    blacklistedKernelModules = [ "nouveau" ]; # blacklist the opensource nvidia driver that does not work well and might conflict with proprietary nvidia driver
  };

  virtualisation.docker.enable = true; # dont forget to add the user in the docker group

  networking = {
    hostName = "nixos"; # Define your hostname.

    firewall.enable = true; # it''s true by default anyway. It is a "statefull firewall".
    # Open ports in the firewall. 
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    
    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    networkmanager.enable = true;
    # NB: networkmanager superseds wireless.enable
    
    # to get available wifi : "iwlist <interface> scan"
    # the interface is found using "ip link show"
  };

  fonts.fonts = with pkgs; [ 
    corefonts # Micrsoft free fonts
    inconsolata  # monospaced
    nerdfonts # popular 'iconic fonts' 
    iosevka
  ];
  fonts.fontconfig.defaultFonts.monospace = [ "Inconsolata" ];

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris"; # services.localtime might give the same info any-way, but needs internet

  # e.g. steam package has a non-free licence
  nixpkgs.config.allowUnfree = true;

  # taken from https://github.com/paolobueno/nixos-config/blob/master/configuration.nix
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" "pattern" ];
      };
      ohMyZsh.enable = true;
      ohMyZsh.plugins = [ "git" ];
      ohMyZsh.theme = "pure";
    };
    adb.enable = true; # android debuger, for smartphone
    mosh.enable = true; # mobile shell, pour remplacer ssh+screen dans certains cas
    ssh.startAgent = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # Or go to https://nixos.org/nixos/packages.html
  environment.systemPackages = with pkgs; 
    # https://nixos.wiki/wiki/Python
    let 
      my-python-packages = python-packages: with python-packages; [
        pandas
        requests
        virtualenvwrapper 
        # other python packages in the default interpreter...
      ]; 
      python-with-my-packages = python3.withPackages my-python-packages;
    in [   
    # xfce4 goodies
    xfce.xfce4-panel
    xfce.xfce4-clipman-plugin
    xfce.xfce4-datetime-plugin
    xfce.xfce4-pulseaudio-plugin
    xfce.xfce4-namebar-plugin
    xfce.xfce4-namebar-plugin
    xfce.xfce4-whiskermenu-plugin
    xfce.xfce4-xkb-plugin
    xfce.xfce4-windowck-plugin
    xfce.xfce4-notifyd # for volume notifications ....
    xfce.xfce4-hardware-monitor-plugin
    networkmanagerapplet

    xfce.thunar-archive-plugin # thunar extension for compressed/archives
    xfce.thunar-volman # thunar extension for removable disks

    # basic command line utilities
    feh # for wallpaper on i3
    file
    gdb
    killall
    zip
    unzip
    lsof
    pciutils # for lspci
    git
    wget
    kdiff3
    pandoc # universal conversion conversion of written file types
    xorg.xkill
    vim
    w3m # a minimalist cmd line web browser with image previews
    htop
    powertop # monitor energy consumption
    gnupg
    p7zip
    rsync
    ncdu
    ntfs3g # enable ntfs (FUSE driver with write support)
    gnome3.file-roller 
    mpc_cli # a minimalist cmd line, client interface for mpd, the music player daemon, for i3 bindings
    ncmpcpp # full featured command line, client interface for mpd

    python-with-my-packages

    # GUI apps
    firefox 
    thunderbird
    jetbrains.pycharm-community
    nextcloud-client
    evince
    gimp
    vlc
    ranger # minimalist file explorator with vi key bindings and image previews
    zathura # minimalist document viewer
    anki # a small app for exercising memorisation on custom questions

    # themes
    papirus-icon-theme
    # gnome-icon-theme

    # graphic card
    glxinfo
    glmark2 # to benchamrk 3D graphics acceleration

    # games
    steam
    # NB: steam seems to remember the video card used during its own installation/first start. If the card used to launch the game differs from the card used to install steam, problems may occur.
    # To totally reset steam : rm -r /home/jlucas/.local/share/Steam .steam
    (wine.override { wineBuild = "wineWow"; wineRelease = "staging"; })
    (winetricks.override { wine = (wine.override { wineBuild = "wineWow"; wineRelease = "staging"; }) ; })
    # For SC2 it might be needed to add missing dll 
    #  winetricks d3dcompiler_43
    # Using WINEARCH=win32 is preferable for SC2
    #  winetricks firefox
    # Reset game settings
    samba
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # Enable sound.
  sound.enable = true;

  services = {
    samba.enable = true;
    # hardware management
    fstrim.enable = true; # ssd disk optimisation
    # udisks2.enable = true; # use dbus to manage storage devices # FIXME usb disk automount
    # udev.packages = [ pkgs.libmtp.bin ]; # mtp : for android devices
    tlp.enable = true; # energy/temperature management 
    thermald.enable = true; # thermal optimisation for intel cpu
    printing.enable = true; # enable CUPS to print documents

    locate.enable = true; # periodically updatedb
    localtime.enable = true;
    redshift = {
      enable = true;
      #provider = "geoclue2"; # requires services.localtime.enable = true;
      latitude = "48.856614";
      longitude = "2.3522219";
    }; # Make sure to not start redshift-gtk, otherwise you will have 2 instances of redhift running, that cause a swicth between standard colors and redshifted colors every 1-2 seconds.
    
    openssh = {
      enable = true;
      permitRootLogin = "no";
    };

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      autorun = true;
      layout = "us";
      # Enable touchpad support.
      libinput.enable = true;
      
      # here you can switch the used card at boot
      videoDrivers = [ "nvidia" ]; 
      # videoDrivers = [ "intel" ]; 
      
      displayManager.lightdm.enable = true;
      
      # https://nixos.wiki/wiki/Xfce     + i3wm 
      desktopManager = {
        default = "xfce";
        xterm.enable = false;
        xfce = {
          enable = true;
          noDesktop = true;
          enableXfwm = false;
          # https://discourse.nixos.org/t/thunar-doesnt-show-archive-plugin/1499/3
          thunarPlugins = [ pkgs.xfce.thunar-archive-plugin  pkgs.xfce.thunar-volman ]; # thunar archive plugin does not seem to work
        };
      };
      windowManager.i3.enable = true;
    };

    # music player daemon
    mpd = {
      enable = true;
      user = "jlucas";
      group = "users";
      musicDirectory = "/home/jlucas/Music";
      dataDir = "/home/jlucas/.mpd";
      extraConfig = ''
       # metadata_to_use "artist,album,title,track,name,genre,date,composer,performer,disc,comment"
        restore_paused "yes"
        audio_output {
          type     "pulse"
          name     "pulse audio"
        }
      '';
      network.listenAddress = "any";
      startWhenNeeded = true;
    };
  };

  hardware = {
    # Audio
    pulseaudio = {
      enable = true;
      # https://nixos.org/nixpkgs/manual/#sec-steam-play
      support32Bit = true;
    };
     
    # GPU
    #https://github.com/NixOS/nixpkgs/issues/24711#issuecomment-401630839
    # > 10000 FPS with glmark2
    nvidia = {
      modesetting.enable = true;
      optimus_prime = {
        enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };

    # An alternative solution for switchable graphic cards that works 
    ### bumblebee
    #bumblebee = {
    #  enable = true;
    #  driver = "nvidia";
    #  pmMethod = "none"; # this line seems the solution to all my issues !!!
    #  connectDisplay = true;
    #};
    #Dont forget xserver.videoDriver = [ "intel" ]
    # NB: As explained in https://nixos.wiki/wiki/Nvidia this gives bad performance.
    # with glmark2: < 400 FPS with the NVIDIA card and intel chip has even better performances
   
    # activate 32bit support
    # opengl.enable = true;
    opengl.driSupport32Bit = true;

    # CPU
    cpu.intel.updateMicrocode = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jlucas = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/jlucas";
    createHome = true;
    extraGroups = [ "wheel" "audio" "networkmanager" "docker"];
    initialPassword = "1234";
    #TODO
    #openssh.authorizedKeys.keys = # linked with the openssh service
    #[ "ssh-dss AAAAB3NzaC1kc3MAAACBAPIkGWVEt4..." ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
}

# keep an eye on : 
#   mopidy # a music daemon like mpd but that can connect to spotify
#   home-manager # manage dofiles with a declarative nix syntax
#   primerun :  https://nixos.wiki/wiki/Nvidia and https://github.com/dukzcry/crap/tree/master/primerun  
# for nvidia/intell config, see :
#    https://nixos.wiki/wiki/Nvidia (the solution with primerun was not working for me)
#    https://github.com/NixOS/nixpkgs/issues/24711
#    https://github.com/NixOS/nixpkgs/files/2707791/configuration.nix.txt
#    https://github.com/dukzcry/crap/issues/3
