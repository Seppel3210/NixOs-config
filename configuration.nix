# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
      ./home.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "bone";
  };

  # For proprietary shit
  nixpkgs.config.allowUnfree = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "de";
    xkbVariant = "bone";
    windowManager.herbstluftwm.enable = true;
    desktopManager.plasma5.enable = true;
    videoDrivers = [ "nvidia" ];
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.defaultUserShell = pkgs.fish;
  users.users.seppel = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    alacritty
    discord
    dmenu
    firefox
    pavucontrol

    bat
    fd
    gh
    git
    gnupg
    pass
    ripgrep
    wget
    zoxide

    clang
    gnumake
    pkg-config
    rustup

    alsa-lib
    eudev
    # needed for coc.nvim
    nodejs-16_x
    xorg.libX11
    xorg.libXcursor
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      configure = {
        customRC = builtins.readFile (./. + "/nvim.rc") + ''
          let $RUST_SRC_PATH = '${with pkgs; stdenv.mkDerivation {
            inherit (rustc) src;
            inherit (rustc.src) name;
            phases = ["unpackPhase" "installPhase"];
            installPhase = ''cp -r library $out'';
          }}'
        '';
      };
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        set PATH $PATH $HOME/.cargo/bin
        zoxide init fish | source
      '';
      promptInit = ''
        set -l nix_shell_info (
          if test -n "$IN_NIX_SHELL"
            echo -n "<nix-shell> "
          end
        )
      '';
      shellAliases = {
        nix-shell = "nix-shell --run fish";
      };
    };

    bash = {
      shellInit = ''
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        gpgconf --launch gpg-agent
      '';
    };
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
