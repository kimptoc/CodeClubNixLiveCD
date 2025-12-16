{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  # Set the boot label to "codeclub"
  isoImage.isoName = "codeclub.iso";
  isoImage.volumeID = "CODECLUB";
  isoImage.appendToMenuLabel = " CodeClub";

  zramSwap = {
    enable = true;
    memoryPercent = 50;  # Uses 50% of RAM for compressed swap
  };

  services.desktopManager.gnome = {
    # Add Firefox and other tools useful for installation to the launcher
    favoriteAppsOverride = ''
      [org.gnome.shell]
      favorite-apps=[ 'firefox.desktop', 'org.gnome.Nautilus.desktop' ]
    '';
    enable = true;
    extraGSettingsOverrides = '' 
[org.gnome.desktop.wm.preferences]
button-layout=':minimize,maximize,close'
[org.gnome.shell]
enabled-extensions=['no-overview@fthx']
[org.gnome.settings-daemon.plugins.housekeeping]
donation-reminder-enabled=false
[org.gnome.desktop.interface]
clock-show-seconds=true
'';

  };

  services.displayManager.gdm.autoSuspend = false;

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

  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.61"
  ];
 
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
  gnome-mines
  gnome-mahjongg
  iagno
  aisleriot
  ];

  environment.variables = {
    GSK_RENDERER = "ngl";
  };

# Create Chrome policy directory and files
  environment.etc."opt/chrome/policies/managed/disable-password-manager.json".text = ''
  {
    "PasswordManagerEnabled": false
  }
  '';

  # Set Firefox as the default browser
  xdg.mime.defaultApplications = {
    "text/html" = "firefox.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/about" = "firefox.desktop";
    "x-scheme-handler/unknown" = "firefox.desktop";
  };

  programs.firefox = {
    enable = true;
    policies = {
      PasswordManagerEnabled = false;
      DontCheckDefaultBrowser = true;
      DisablePrivacySegmentation = true;

      # Set homepage
      Homepage = {
        URL = "https://kimptoc.github.io/CodeClubNixLiveCD/";
        Locked = true;  # Set to false if you want users to be able to change it
        StartPage = "homepage-locked";  # Options: "homepage", "previous-session", "homepage-locked"
      };
 
      # Optional: Also disable the password prompt
      Preferences = {
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.generation.enabled" = false;

        # Disable privacy welcome screens and notifications
        "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
        "browser.aboutwelcome.enabled" = false;
        "browser.startup.homepage_override.mstone" = "ignore";

        "browser.shell.checkDefaultBrowser" = false;
        "browser.sessionstore.resume_session_once" = false;  # Don't offer to restore session

      };
    };
  };

  environment.gnome.excludePackages = [ pkgs.gnome-tour ];

  systemd.user.services.myautostart = {
    description = "myautostart";
    serviceConfig.PassEnvironment = "DISPLAY";
    script = ''
      export MYLOG=$HOME/myautostart.log
      echo "MYAUTOSTART" > $MYLOG
      date >> $MYLOG

      # Set GNOME workspace settings via dconf
      echo "Setting dconf workspace settings..." >> $MYLOG
      ${pkgs.dconf}/bin/dconf write /org/gnome/mutter/dynamic-workspaces false >> $MYLOG 2>&1
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/wm/preferences/num-workspaces 1 >> $MYLOG 2>&1

      mkdir -p $HOME/.config/autostart >> $MYLOG
      mkdir -p $HOME/.local/share/applications/ >> $MYLOG
    
      export CHRDESK=$HOME/.local/share/applications/chrome.desktop 
      echo "[Desktop Entry]" > $CHRDESK
      echo "Name=Google Chrome" >> $CHRDESK

      echo "Exec=${pkgs.google-chrome}/bin/google-chrome-stable --disable-fre --no-default-browser-check --no-first-run --hide-crash-restore-bubble --password-store=basic --start-maximized https://kimptoc.github.io/CodeClubNixLiveCD/" >> $CHRDESK
      echo "StartupNotify=true" >> $CHRDESK
      echo "Terminal=false" >> $CHRDESK
      echo "Icon=google-chrome" >> $CHRDESK
      echo "Type=Application" >> $CHRDESK

      cat $CHRDESK >> $MYLOG

#      cp $CHRDESK $HOME/.config/autostart/ >> $MYLOG


      export FFXDESK=$HOME/.config/autostart/firefox.desktop
      echo "[Desktop Entry]" > $FFXDESK
      echo "Name=Firefox" >> $FFXDESK

      echo "Exec=${pkgs.firefox}/bin/firefox https://kimptoc.github.io/CodeClubNixLiveCD/" >> $FFXDESK
      echo "StartupNotify=true" >> $FFXDESK
      echo "Terminal=false" >> $FFXDESK
      echo "Icon=firefox" >> $FFXDESK
      echo "Type=Application" >> $FFXDESK

      cat $FFXDESK >> $MYLOG

      cp $FFXDESK $HOME/.local/share/applications/ >> $MYLOG

      echo "MYAUTOSTART end" >> $MYLOG
      date >> $MYLOG
      
    '';
    wantedBy = [ "graphical-session.target" ]; # starts after login
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
       RemainAfterExit = true;
    };

  };
}
