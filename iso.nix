{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  services.xserver.desktopManager.gnome = {
    # Add Firefox and other tools useful for installation to the launcher
    favoriteAppsOverride = ''
      [org.gnome.shell]
      favorite-apps=[ 'chrome.desktop', 'firefox.desktop', 'org.gnome.Nautilus.desktop' ]
    '';
    enable = true;
    extraGSettingsOverrides = '' 
[org.gnome.desktop.wm.preferences]
button-layout='appmenu:minimize,maximize,close'
[org.gnome.shell]
enabled-extensions=['no-overview@fthx']
[org.gnome.Extensions]
window-maximized=true
'';

  };

  services.xserver.displayManager.gdm.autoSuspend = false;

  time.timeZone = "Europe/London";

 # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "gb";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "uk";

  services.locate.enable = true;

  services.printing.enable = true;

  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
 
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [  
  terminator
  ghostty
  zsh
  nettools
  python3
  temurin-bin
  prismlauncher
  google-chrome
  vim
  git
  wget
  nmap
  pkgs.gnome-tweaks
  findutils
  gnomeExtensions.no-overview
  ];

  environment.variables = {
    GSK_RENDERER = "ngl";
  };

  environment.gnome.excludePackages = [ pkgs.gnome-tour ];

  systemd.user.services.myautostart = {
    description = "myautostart";
    serviceConfig.PassEnvironment = "DISPLAY";
    script = ''
      export MYLOG=$HOME/myautostart.log
      echo "MYAUTOSTART" > $MYLOG
      date > $MYLOG
      mkdir -p $HOME/.config/autostart >> $MYLOG
      mkdir -p $HOME/.local/share/applications/ >> $MYLOG
    
      export CHRDESK=$HOME/.config/autostart/chrome.desktop
      echo "[Desktop Entry]" > $CHRDESK
      echo "Name=Google Chrome" >> $CHRDESK

      echo "Exec=${pkgs.google-chrome}/bin/google-chrome-stable --disable-fre --no-default-browser-check --no-first-run --hide-crash-restore-bubble https://kimptoc.github.io/CodeClubNixLiveCD/" >> $CHRDESK
      echo "StartupNotify=true" >> $CHRDESK
      echo "Terminal=false" >> $CHRDESK
      echo "Icon=google-chrome" >> $CHRDESK
      echo "Type=Application" >> $CHRDESK

      cat $CHRDESK >> $MYLOG

      cp $CHRDESK $HOME/.local/share/applications/ >> $MYLOG
    '';
    wantedBy = [ "graphical-session.target" ]; # starts after login
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
       RemainAfterExit = true;
    };

  };
}
