{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  # Patch gnome-shell to remove the donation dialog entirely.
  # Belt-and-suspenders: even if GSettings overrides fail to suppress it,
  # the dialog code itself is neutralised.
  nixpkgs.overlays = [
    (final: prev: {
      gnome-shell = prev.gnome-shell.overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + ''
          # Disable donation dialog by replacing its show() with a no-op
          if [ -f js/ui/donateDialog.js ]; then
            echo "// Donation dialog disabled for CodeClub LiveCD" > js/ui/donateDialog.js
          fi
          # Also handle the welcome dialog if present
          if [ -f js/ui/welcomeDialog.js ]; then
            echo "// Welcome dialog disabled for CodeClub LiveCD" > js/ui/welcomeDialog.js
          fi
        '';
      });
    })
  ];

  # Set the boot label to "codeclub"
  isoImage.isoName = "codeclub.iso";
  isoImage.volumeID = "CODECLUB";
  isoImage.appendToMenuLabel = " CodeClub";

  # Make the ISO smaller (xz compresses better than zstd; slower build, smaller output)
  isoImage.squashfsCompression = "xz";

  zramSwap = {
    enable = true;
    memoryPercent = 50;  # Uses 50% of RAM for compressed swap
  };

  services.desktopManager.gnome = {
    # Add Firefox and other tools useful for installation to the launcher
    favoriteAppsOverride = ''
      [org.gnome.shell]
      favorite-apps=[ 'google-chrome.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.SystemMonitor.desktop' ]
    '';
    enable = true;
    extraGSettingsOverrides = '' 
[org.gnome.desktop.wm.preferences]
button-layout=':minimize,maximize,close'
[org.gnome.shell]
enabled-extensions=['no-overview@fthx']
welcome-dialog-last-shown='2099-12-31T23:59:59Z'
donation-dialog-last-shown='2099-12-31T23:59:59Z'
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

  nixpkgs.config.allowUnfree = true;

  programs.nix-ld.enable = true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = with pkgs; [
  gnome-terminal
  nodejs
  terminator
  ghostty
  zsh
  nettools
  wmctrl
  python3
  temurin-bin
  prismlauncher
  google-chrome
  chromium
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
    NPM_CONFIG_PREFIX = "$HOME/.cache/npm/global";
  };

  environment.extraInit = ''
    export PATH="$PATH:$HOME/.cache/npm/global/bin"
  '';

# Create Chrome/Chromium policy directory and files
  environment.etc."opt/chrome/policies/managed/disable-password-manager.json".text = ''
  {
    "PasswordManagerEnabled": false
  }
  '';

  environment.etc."chromium/policies/managed/disable-password-manager.json".text = ''
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

  environment.gnome.excludePackages = [ pkgs.gnome-tour pkgs.gnome-initial-setup pkgs.gnome-software ];

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

      # Dismiss GNOME donation/welcome dialogs by marking them as shown far in the future
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/donation-dialog-last-shown "'2099-12-31T23:59:59Z'" >> $MYLOG 2>&1
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/welcome-dialog-last-shown "'2099-12-31T23:59:59Z'" >> $MYLOG 2>&1

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

      # Chromium desktop entry override (avoid duplicate icon by using the package's desktop file name)
      export CHROMIUMDESK=$HOME/.local/share/applications/chromium-browser.desktop
      echo "[Desktop Entry]" > $CHROMIUMDESK
      echo "Name=Chromium" >> $CHROMIUMDESK
      echo "Exec=${pkgs.chromium}/bin/chromium --no-default-browser-check --no-first-run --password-store=basic --start-maximized https://kimptoc.github.io/CodeClubNixLiveCD/" >> $CHROMIUMDESK
      echo "StartupNotify=true" >> $CHROMIUMDESK
      echo "Terminal=false" >> $CHROMIUMDESK
      echo "Icon=${pkgs.chromium}/share/icons/hicolor/256x256/apps/chromium.png" >> $CHROMIUMDESK
      echo "Type=Application" >> $CHROMIUMDESK

      cat $CHROMIUMDESK >> $MYLOG

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

      # Autostart Google Chrome from inside GNOME session so DISPLAY/Wayland env is correct.
      export FFXAUTO=$HOME/.config/autostart/chrome-autostart.desktop
      echo "[Desktop Entry]" > $FFXAUTO
      echo "Name=Chrome Autostart" >> $FFXAUTO
      echo "Exec=${pkgs.google-chrome}/bin/google-chrome-stable --disable-fre --no-default-browser-check --no-first-run --hide-crash-restore-bubble --password-store=basic --start-maximized https://kimptoc.github.io/CodeClubNixLiveCD/" >> $FFXAUTO
      echo "StartupNotify=true" >> $FFXAUTO
      echo "Terminal=false" >> $FFXAUTO
      echo "Icon=google-chrome" >> $FFXAUTO
      echo "Type=Application" >> $FFXAUTO
      echo "X-GNOME-Autostart-enabled=true" >> $FFXAUTO

      cat $FFXAUTO >> $MYLOG

      # Best-effort maximize shortly after launch - simpler approach
      # Write script to file first to avoid escaping issues
      export FFXSCRIPT=$HOME/.local/bin/chrome-maximize.sh
      mkdir -p $HOME/.local/bin
      echo '#!/bin/bash' > $FFXSCRIPT
      echo 'sleep 4' >> $FFXSCRIPT
      echo 'wmctrl -r google-chrome -b add,maximized_vert,maximized_horz' >> $FFXSCRIPT
      chmod +x $FFXSCRIPT
      
      export FFXMAX=$HOME/.config/autostart/firefox-maximize.desktop
      echo "[Desktop Entry]" > $FFXMAX
      echo "Name=Firefox Maximize" >> $FFXMAX
      echo "Exec=$FFXSCRIPT" >> $FFXMAX
      echo "StartupNotify=false" >> $FFXMAX
      echo "Terminal=false" >> $FFXMAX
      echo "Type=Application" >> $FFXMAX
      echo "X-GNOME-Autostart-enabled=true" >> $FFXMAX

      cat $FFXMAX >> $MYLOG

      # Install kilocode CLI globally via npm (wait for network, up to 5 minutes)
      echo "Installing kilocode CLI..." >> $MYLOG
      KILO_INSTALLED=false
      for i in $(seq 1 30); do
        if ${pkgs.nodejs}/bin/npm install -g @kilocode/cli >> $MYLOG 2>&1; then
          echo "kilocode CLI install done (attempt $i)" >> $MYLOG
          KILO_INSTALLED=true
          break
        fi
        echo "kilocode CLI install attempt $i failed, retrying in 10s..." >> $MYLOG
        sleep 10
      done
      if [ "$KILO_INSTALLED" = false ]; then
        echo "ERROR: kilocode CLI install failed after 30 attempts" >> $MYLOG
      fi
      export PATH=$PATH:"$HOME/.cache/npm/global/bin"

      echo "MYAUTOSTART end" >> $MYLOG
      date >> $MYLOG

    '';
    wantedBy = [ "graphical-session.target" ]; # starts after login
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
       RemainAfterExit = true;
    };
  };

  # Firefox launch is handled by GNOME autostart desktop files created in myautostart.
}
