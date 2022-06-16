# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./neovim.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  boot.kernelParams = [ "pci=nocrs" ];
  # boot.plymouth.enable = true; # Currently buggy

  nix = {
    # package = pkgs.nixFlakes;
    maxJobs = lib.mkDefault 24;
    autoOptimiseStore = true;
    trustedUsers = [ "root" "st" "@wheel" ];
    # extraOptions = ''
    #   experimental-features = nix-command flakes
    # '';
    # # Set nixpkgs channel to follow flake
    # nixPath = lib.mkForce [ "nixpkgs=/etc/self/nixos/compat" ];
    # registry.nixpkgs.flake = inputs.nixpkgs;
  };

  # Fix for the wayland session not starting and getting thrown into a tty
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  networking.hostName = "jet"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "America/Argentina/Mendoza"; # Set your time zone.
  services.localtime.enable = true;

  console.keyMap = "dvorak";

  nixpkgs.config.allowUnfree = true;

  zramSwap.enable = true; # zRam
  hardware.bluetooth.enable = true; # Bluetooth

  # Pipewire
  # sound.enable = true; # Enable sound.
  # hardware.pulseaudio.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  programs.zsh.enable = true;
  # While on the live-iso do # nixos-enter --root /mnt
  # and then # passwd st
  # to change the password
  users.users.st = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;  # Default shell for the user
    packages = with pkgs; [
      bat
      curl
      exa
      firefox-wayland # firefox brave
      fnm
      fzf
      git
      inkscape
      nodePackages.node2nix
      nodePackages.npm
      nodejs
      ripgrep
    ];
  };

  # Firefox
  xdg.portal.gtkUsePortal = true; # GTK_USE_PORTAL = 1
  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1"; # Wayland in Firefox
    MOZ_USE_XINPUT2 = "1"; # Pixel-perfect trackpad scrolling
    BROWSER = "firefox";
  };

  # Environment variables
  environment.sessionVariables = rec {
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_CURRENT_DESKTOP = "plasmawayland";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    XDG_RUNTIME_DIR = "/run/user/\${UID}";
    XDG_STATE_HOME = "\${HOME}/.local/state";
    PATH = [ "/home/st/.local/bin" ];
    ZDOTDIR = "\${HOME}/.config/zsh"; # Zsh config
    LIBVA_DRIVER_NAME = "iHD"; # Hardware acceleration
    KDEHOME = "\${XDG_CONFIG_HOME}/kde"; # KDE
    LANG = "en_US.UTF-8";
    LC_COLLATE = "C";
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "konsole"; # wezterm kitty
    TERM = "xterm-256color"; # xterm-kitty
    LESSHISTFILE = "-";
    KEYTIMEOUT = "1";
    ZETTELPY_DIR = "\${HOME}/.zettels";
    CDPATH = "\${HOME}/workspace"; # Add directories to CDPATH
    FZF_DEFAULT_COMMAND = "rg --files --no-ignore-vcs --hidden"; # fzf
    SDKMAN_DIR = "\${HOME}/.local/lib/sdkman"; # SDKMAN
    NVIMREMOTE = "/tmp/nvim.pipe";
    GTK2_RC_FILES = lib.mkForce "\${XDG_CONFIG_HOME}/gtk-2.0/gtkrc"; # This isn't going to work because KDE Plasma hardcodes the value
    NPM_CONFIG_USERCONFIG = "/home/st/.config/npm/npmrc";
  };

  environment.etc = {
    # "xdg/git/config" = {
    #   text = ''
    #     [user]
    #       name = Santiago Gonzalez
    #       email = santiagogonzalezbogado@gmail.com
    #     [color]
    #       ui = auto
    #     [core]
    #       editor = nvim
    #     '';
    #   mode = "444";
    # };
    "xdg/gtk-3.0/settings.ini" = {
      text = ''
        [Settings]
        gtk-application-prefer-dark-theme=true
        gtk-cursor-theme-name=Breeze_Snow
        gtk-cursor-theme-size=23
        gtk-font-name=Inter, 12
        gtk-icon-theme-name=breeze-dark
        '';
      mode = "444";
    };
    "xdg/user-dirs.defaults".text = ''
      DESKTOP=.local/Desktop
      DOWNLOAD=.local/Downloads
      TEMPLATES=.local/Templates
      PUBLICSHARE=.local/Public
      DOCUMENTS=.local/Documents
      MUSIC=.local/Music
      PICTURES=.local/Pictures
      VIDEOS=.local/Videos
      '';
    "xdg/mimeapps.list" = {
      text = ''
        [Default Applications]
        inode/directory=org.kde.krusader.desktop
          x-scheme-handler/http=firefox.desktop
          x-scheme-handler/https=firefox.desktop
          x-scheme-handler/org-protocol=org-protocol.desktop
        '';
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    appimage-run
    gcc
    kde-gtk-config
    krusader
    libnotify
    libsForQt5.breeze-gtk
    libsForQt5.kdialog
    power-profiles-daemon
    python310
    python310Packages.pip
    unclutter-xfixes
    unzip
    wl-clipboard
    xdg-desktop-portal-gtk
    xwayland
    zip
  ];

  # List all packages installed for the system, excludes packages installed for
  # the user, the file location -> /etc/current-system-packages, to see other
  # packages installed with nix-env -> # nix-env -qa --installed
  environment.etc."current-system-packages".text =
    let
      packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
      sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
      formatted = builtins.concatStringsSep "\n" sortedUnique;
    in
      formatted;

  security.sudo.configFile = ''Defaults !tty_tickets''; # Sudo timer shared between processes
  security.rtkit.enable = true; # Audio related feature

  # Desktop
  qt5.platformTheme = "gtk";
  services.power-profiles-daemon.enable = true;  # Power profiles, package pulled in systemPackages
  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;  # Enable the Plasma 5 Desktop Environment.
    videoDrivers = [ "intel" ];
    displayManager.defaultSession = "plasmawayland";
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = "st";
    displayManager.sddm = {
      enable = true;
      settings = {
        General = {
          DisplayServer = "wayland";
          GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell";
        };
        Wayland = {
          CompositorCommand = "kwin_wayland --no-lockscreen";
          SessionDir = "${pkgs.plasma5Packages.plasma-workspace}/share/wayland-sessions";
        };
      };                                                                                  };
  };

  # Btrfs options for subvolumes
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/7efed1c9-ef3b-4703-a78a-5c25fc667d37";
    fsType = "btrfs";
    options = [ "subvol=@" "noatime" "compress-force=zstd:1" "space_cache=v2" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/7efed1c9-ef3b-4703-a78a-5c25fc667d37";
    fsType = "btrfs";
    options = [ "subvol=@home" "noatime" "compress-force=zstd:1" "space_cache=v2" ];
  };

  fileSystems."/var" = {
    device = "/dev/disk/by-uuid/7efed1c9-ef3b-4703-a78a-5c25fc667d37";
    fsType = "btrfs";
    options = [ "subvol=@var" "noatime" "compress-force=zstd:1" "space_cache=v2" ];
  };

  system.stateVersion = "22.05";
}
