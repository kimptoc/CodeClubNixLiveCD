{ config, pkgs, ... }:
let
  xfcePanelXml = pkgs.writeText "xfce4-panel.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <channel name="xfce4-panel" version="1.0">
      <property name="configver" type="sint" value="2"/>
      <property name="panels" type="array">
        <value type="uint" value="1"/>
        <value type="uint" value="2"/>
      </property>
      <property name="panel-1" type="empty">
        <property name="position" type="string" value="p=6;x=0;y=0"/>
        <property name="length" type="uint" value="100"/>
        <property name="position-locked" type="bool" value="true"/>
        <property name="size" type="uint" value="28"/>
        <property name="plugin-ids" type="array">
          <value type="sint" value="1"/>
          <value type="sint" value="2"/>
          <value type="sint" value="3"/>
          <value type="sint" value="4"/>
          <value type="sint" value="5"/>
          <value type="sint" value="6"/>
        </property>
      </property>
      <property name="panel-2" type="empty">
        <property name="position" type="string" value="p=10;x=0;y=0"/>
        <property name="length" type="uint" value="100"/>
        <property name="position-locked" type="bool" value="true"/>
        <property name="size" type="uint" value="28"/>
        <property name="plugin-ids" type="array">
          <value type="sint" value="7"/>
        </property>
      </property>
      <property name="plugins" type="empty">
        <property name="plugin-1" type="string" value="applicationsmenu"/>
        <property name="plugin-2" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="google-chrome.desktop"/>
          </property>
        </property>
        <property name="plugin-3" type="string" value="separator">
          <property name="expand" type="bool" value="true"/>
          <property name="style" type="uint" value="0"/>
        </property>
        <property name="plugin-4" type="string" value="systemload"/>
        <property name="plugin-5" type="string" value="systray"/>
        <property name="plugin-6" type="string" value="clock"/>
        <property name="plugin-7" type="string" value="tasklist"/>
      </property>
    </channel>
  '';
in
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
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

  # XFCE desktop with LightDM, auto-login the live CD user.
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.displayManager.defaultSession = "xfce";
  services.xserver.displayManager.lightdm.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  # Disable screen blanking and DPMS for the live CD.
  services.xserver.serverFlagsSection = ''
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
  '';

  # Set a password so the VM login screen works (auto-login handles the live CD).
  users.users.nixos = {
    initialPassword = "nixos";
  };

  # Disable gnome-keyring to prevent wallet prompts (e.g. for wifi passwords).
  services.gnome.gnome-keyring.enable = false;
  # Store NetworkManager wifi passwords as system connections (no wallet needed).
  networking.networkmanager.enable = true;

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

  # DISABLED FOR TESTING: Set up XFCE panel config.
  # system.activationScripts.nixosXfcePanel = { ... };

  # Create .zshrc for the nixos user to suppress zsh new-user-install prompt.
  # NixOS user activation does NOT copy from /etc/skel, so we use an activation script.
  system.activationScripts.nixosZshrc = ''
    if [ ! -f /home/nixos/.zshrc ]; then
      mkdir -p /home/nixos
      touch /home/nixos/.zshrc
      chown nixos:nixos /home/nixos/.zshrc 2>/dev/null || true
    fi
  '';

  environment.systemPackages = with pkgs; [
  xfce.xfce4-systemload-plugin
  xfce.xfce4-terminal
  nodejs
  terminator
  ghostty
  zsh
  nettools
  python3
  temurin-bin
  prismlauncher
  google-chrome
  chromium
  vim
  git
  wget
  nmap
  findutils
  gnome-mines      # GTK games — XFCE shares the GTK toolkit so no extra runtime bloat
  gnome-mahjongg
  iagno
  aisleriot
  ];

  # environment.extraInit only affects login shells (sourced via /etc/profile).
  # xfce4-terminal opens non-login interactive zsh shells, so PATH must also be
  # set in /etc/zshrc via programs.zsh.shellInit.
  environment.extraInit = ''
    export NPM_CONFIG_PREFIX="$HOME/.cache/npm/global"
    export PATH="$PATH:$HOME/.cache/npm/global/bin"
  '';

  programs.zsh.shellInit = ''
    # Ensure npm global bin is on PATH for non-login shells (e.g. xfce4-terminal)
    export NPM_CONFIG_PREFIX="$HOME/.cache/npm/global"
    [[ ":$PATH:" != *":$HOME/.cache/npm/global/bin:"* ]] && export PATH="$PATH:$HOME/.cache/npm/global/bin"
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

  # Set Google Chrome as the default browser (Chrome is the primary
  # autostarting browser, so xdg.mime should match).
  xdg.mime.defaultApplications = {
    "text/html" = "google-chrome.desktop";
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
    "x-scheme-handler/about" = "google-chrome.desktop";
    "x-scheme-handler/unknown" = "google-chrome.desktop";
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

  systemd.user.services.myautostart = {
    description = "myautostart";
    serviceConfig.PassEnvironment = "DISPLAY";
    script = ''
      export MYLOG=$HOME/myautostart.log
      echo "MYAUTOSTART" > $MYLOG
      date >> $MYLOG

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

      # Chromium desktop entry override
      export CHROMIUMDESK=$HOME/.local/share/applications/chromium-browser.desktop
      echo "[Desktop Entry]" > $CHROMIUMDESK
      echo "Name=Chromium" >> $CHROMIUMDESK
      echo "Exec=${pkgs.chromium}/bin/chromium --no-default-browser-check --no-first-run --password-store=basic --start-maximized https://kimptoc.github.io/CodeClubNixLiveCD/" >> $CHROMIUMDESK
      echo "StartupNotify=true" >> $CHROMIUMDESK
      echo "Terminal=false" >> $CHROMIUMDESK
      echo "Icon=${pkgs.chromium}/share/icons/hicolor/256x256/apps/chromium.png" >> $CHROMIUMDESK
      echo "Type=Application" >> $CHROMIUMDESK

      cat $CHROMIUMDESK >> $MYLOG

      # Create Firefox desktop entry for applications menu
      export FFXDESK=$HOME/.local/share/applications/firefox.desktop
      echo "[Desktop Entry]" > $FFXDESK
      echo "Name=Firefox" >> $FFXDESK
      echo "Exec=${pkgs.firefox}/bin/firefox https://kimptoc.github.io/CodeClubNixLiveCD/" >> $FFXDESK
      echo "StartupNotify=true" >> $FFXDESK
      echo "Terminal=false" >> $FFXDESK
      echo "Icon=firefox" >> $FFXDESK
      echo "Type=Application" >> $FFXDESK

      cat $FFXDESK >> $MYLOG

      # Autostart Google Chrome maximized
      export CHRAUTO=$HOME/.config/autostart/chrome-autostart.desktop
      echo "[Desktop Entry]" > $CHRAUTO
      echo "Name=Chrome Autostart" >> $CHRAUTO
      echo "Exec=${pkgs.google-chrome}/bin/google-chrome-stable --disable-fre --no-default-browser-check --no-first-run --hide-crash-restore-bubble --password-store=basic --start-maximized https://kimptoc.github.io/CodeClubNixLiveCD/" >> $CHRAUTO
      echo "StartupNotify=true" >> $CHRAUTO
      echo "Terminal=false" >> $CHRAUTO
      echo "Icon=google-chrome" >> $CHRAUTO
      echo "Type=Application" >> $CHRAUTO

      cat $CHRAUTO >> $MYLOG

      # Install kilocode CLI globally via npm (wait for network, up to 5 minutes)
      export NPM_CONFIG_PREFIX="$HOME/.cache/npm/global"
      export PATH="${pkgs.nodejs}/bin:${pkgs.bash}/bin:$PATH"
      mkdir -p "$HOME/.cache/npm/global"
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

  # Chrome launch is handled by XDG autostart desktop files created in myautostart.
}
