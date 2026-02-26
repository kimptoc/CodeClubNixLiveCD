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

  services.gnome.gnome-remote-desktop.enable = false;
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
    "broadcom-sta-6.30.223.271-59-6.12.74"
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
      NewTabPage = false;

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
        "browser.startup.page" = 1;
        "browser.startup.homepage" = "about:home"; # Or a custom URL like "nixos.org"

        "browser.shell.checkDefaultBrowser" = false;
        "browser.sessionstore.resume_session_once" = false;  # Don't offer to restore session
        "browser.sessionstore.resume_from_crash" = false;  # Don't show crash restore dialog
        "browser.sessionstore.max_resumed_crashes" = 0;  # Disable crash recovery entirely
        "browser.startup.couldRestoreSession.count" = -1;  # Hide "Restore Previous Session" button on homepage

        # Disable new tab activity stream (news, sponsored content, etc.)
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };
    };
  };

  environment.gnome.excludePackages = [ pkgs.gnome-tour pkgs.gnome-initial-setup ];

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

      # Dismiss GNOME donation dialog by marking it as already shown
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/donation-dialog-last-shown "'2025-01-01T00:00:00Z'" >> $MYLOG 2>&1

      mkdir -p $HOME/.config/autostart >> $MYLOG
      mkdir -p $HOME/.local/share/applications/ >> $MYLOG

      export CHRDESK=$HOME/.local/share/applications/google-chrome.desktop
      echo "[Desktop Entry]" > $CHRDESK
      echo "Name=Google Chrome" >> $CHRDESK

      echo "Exec=${pkgs.google-chrome}/bin/google-chrome-stable --disable-fre --no-default-browser-check --no-first-run --hide-crash-restore-bubble --password-store=basic --start-maximized https://kimptoc.github.io/CodeClubNixLiveCD/" >> $CHRDESK
      echo "StartupNotify=true" >> $CHRDESK
      echo "Terminal=false" >> $CHRDESK
      echo "Icon=google-chrome" >> $CHRDESK
      echo "Type=Application" >> $CHRDESK

      cat $CHRDESK >> $MYLOG

      # Create Firefox desktop entry for applications menu (not autostart)
      export FFXDESK=$HOME/.local/share/applications/firefox.desktop
      echo "[Desktop Entry]" > $FFXDESK
      echo "Name=Firefox" >> $FFXDESK
      echo "Exec=${pkgs.firefox}/bin/firefox https://kimptoc.github.io/CodeClubNixLiveCD/" >> $FFXDESK
      echo "StartupNotify=true" >> $FFXDESK
      echo "Terminal=false" >> $FFXDESK
      echo "Icon=firefox" >> $FFXDESK
      echo "Type=Application" >> $FFXDESK

      cat $FFXDESK >> $MYLOG

      echo "MYAUTOSTART end" >> $MYLOG
      date >> $MYLOG

    '';
    wantedBy = [ "graphical-session.target" ]; # starts after login
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
       RemainAfterExit = true;
    };
  };

  # Separate service for Firefox that waits for network connectivity
  systemd.user.services.firefox-autostart = {
    description = "Firefox autostart with network wait";
    serviceConfig.PassEnvironment = "DISPLAY";
    after = [ "graphical-session.target" "myautostart.service" ];
    wants = [ "myautostart.service" ];
    script = ''
      export MYLOG=$HOME/firefox-autostart.log
      echo "FIREFOX-AUTOSTART" > $MYLOG
      date >> $MYLOG

      # Wait for network connectivity (max 10 seconds, then proceed anyway)
      echo "Waiting for network..." >> $MYLOG
      NETWORK_READY=0
      for i in $(seq 1 10); do
        if ${pkgs.curl}/bin/curl -s --connect-timeout 1 --max-time 2 -o /dev/null https://www.google.com 2>/dev/null; then
          echo "Network available after $i seconds" >> $MYLOG
          NETWORK_READY=1
          break
        fi
        sleep 1
      done
      if [ "$NETWORK_READY" = "0" ]; then
        echo "Network not available after 10 seconds, launching Firefox anyway" >> $MYLOG
      fi

      # Pre-populate Firefox profile with maximized window state
      FFPROFILE=$(find $HOME/.mozilla/firefox -maxdepth 1 -name '*.default*' -type d 2>/dev/null | head -1)
      if [ -z "$FFPROFILE" ]; then
        # Launch Firefox briefly to create profile, then kill it
        ${pkgs.firefox}/bin/firefox --headless &
        FFPID=$!
        sleep 3
        kill $FFPID 2>/dev/null
        FFPROFILE=$(find $HOME/.mozilla/firefox -maxdepth 1 -name '*.default*' -type d 2>/dev/null | head -1)
      fi
      if [ -n "$FFPROFILE" ]; then
        echo '{"chrome://browser/content/browser.xhtml":{"main-window":{"sizemode":"maximized"}}}' > "$FFPROFILE/xulstore.json"
        echo "Set Firefox sizemode to maximized in $FFPROFILE" >> $MYLOG
      fi

      echo "Launching Firefox..." >> $MYLOG
      date >> $MYLOG
      ${pkgs.firefox}/bin/firefox &

      echo "FIREFOX-AUTOSTART end" >> $MYLOG
      date >> $MYLOG
    '';
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
       RemainAfterExit = true;
       Type = "oneshot";
    };
  };
}
