{ config, pkgs, ... }:
let
  # Panel layout:
  #   Panel 1 (top): app-menu | chrome-launcher | <expand> | systray | clock
  #   Panel 2 (bottom dock): <expand> | show-desktop | terminal | files | chrome | appfinder | btop | <expand>
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
          <value type="sint" value="5"/>
          <value type="sint" value="6"/>
        </property>
      </property>
      <property name="panel-2" type="empty">
        <property name="position" type="string" value="p=10;x=0;y=0"/>
        <property name="length" type="uint" value="100"/>
        <property name="position-locked" type="bool" value="true"/>
        <property name="size" type="uint" value="40"/>
        <property name="plugin-ids" type="array">
          <value type="sint" value="10"/>
          <value type="sint" value="11"/>
          <value type="sint" value="12"/>
          <value type="sint" value="13"/>
          <value type="sint" value="14"/>
          <value type="sint" value="15"/>
          <value type="sint" value="16"/>
          <value type="sint" value="17"/>
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
        <property name="plugin-5" type="string" value="systray"/>
        <property name="plugin-6" type="string" value="clock"/>
        <property name="plugin-10" type="string" value="separator">
          <property name="expand" type="bool" value="true"/>
          <property name="style" type="uint" value="0"/>
        </property>
        <property name="plugin-11" type="string" value="showdesktop"/>
        <property name="plugin-12" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="terminal.desktop"/>
          </property>
        </property>
        <property name="plugin-13" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="thunar.desktop"/>
          </property>
        </property>
        <property name="plugin-14" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="google-chrome.desktop"/>
          </property>
        </property>
        <property name="plugin-15" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="appfinder.desktop"/>
          </property>
        </property>
        <property name="plugin-16" type="string" value="launcher">
          <property name="items" type="array">
            <value type="string" value="btop.desktop"/>
          </property>
        </property>
        <property name="plugin-17" type="string" value="separator">
          <property name="expand" type="bool" value="true"/>
          <property name="style" type="uint" value="0"/>
        </property>
      </property>
    </channel>
  '';

  # Desktop files for panel launchers — written at activation time so xfce4-panel
  # finds them immediately on first login without any kill/restart dance.
  chromePanelLauncher = pkgs.writeText "google-chrome-panel.desktop" ''
    [Desktop Entry]
    Name=Google Chrome
    Comment=Open CodeClub website
    Exec=${pkgs.google-chrome}/bin/google-chrome-stable --disable-fre --no-default-browser-check --no-first-run --hide-crash-restore-bubble --password-store=basic --start-maximized https://kimptoc.github.io/CodeClubNixLiveCD/
    Icon=google-chrome
    Type=Application
    StartupNotify=true
    Terminal=false
  '';

  terminalLauncher = pkgs.writeText "terminal-launcher.desktop" ''
    [Desktop Entry]
    Name=Terminal
    Exec=xfce4-terminal
    Icon=utilities-terminal
    Type=Application
    Terminal=false
  '';

  thunarLauncher = pkgs.writeText "thunar-launcher.desktop" ''
    [Desktop Entry]
    Name=Files
    Exec=thunar
    Icon=system-file-manager
    Type=Application
    Terminal=false
  '';

  appfinderLauncher = pkgs.writeText "appfinder-launcher.desktop" ''
    [Desktop Entry]
    Name=App Finder
    Exec=xfce4-appfinder
    Icon=xfce4-appfinder
    Type=Application
    Terminal=false
  '';

  btopPanelLauncher = pkgs.writeText "btop-panel-launcher.desktop" ''
    [Desktop Entry]
    Name=System Monitor (btop)
    Comment=Show CPU, memory, disk, network and processes
    Exec=xfce4-terminal --title=System-Monitor -e ${pkgs.btop}/bin/btop
    Icon=utilities-system-monitor
    Type=Application
    Terminal=false
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
    user = "codeclub";
  };

  # Disable screen blanking and DPMS for the live CD.
  services.xserver.serverFlagsSection = ''
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
  '';

  # Rename the live CD user from nixos to codeclub.
  users.users.nixos = {
    name = "codeclub";
    home = "/home/codeclub";
    initialPassword = "codeclub";
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

  # Create .zshrc for the codeclub user to suppress zsh new-user-install prompt.
  # NixOS user activation does NOT copy from /etc/skel, so we use an activation script.
  system.activationScripts.nixosZshrc = ''
    if [ ! -f /home/codeclub/.zshrc ]; then
      mkdir -p /home/codeclub
      touch /home/codeclub/.zshrc
      chown codeclub:codeclub /home/codeclub/.zshrc 2>/dev/null || true
    fi
  '';

  # Write XFCE panel config and launcher desktop files before any session starts.
  # deps=["users"] ensures codeclub exists so chown succeeds.
  # Explicit chmod 755 on dirs because root's umask may be 077 (creates 700 dirs).
  system.activationScripts.xfcePanelConfig = {
    text = ''
      H=/home/codeclub

      # Create all dirs and make them world-readable (root umask may be 077)
      mkdir -p "$H/.config/xfce4/xfconf/xfce-perchannel-xml"
      mkdir -p "$H/.config/xfce4/panel/launcher-2"
      mkdir -p "$H/.config/xfce4/panel/launcher-12"
      mkdir -p "$H/.config/xfce4/panel/launcher-13"
      mkdir -p "$H/.config/xfce4/panel/launcher-14"
      mkdir -p "$H/.config/xfce4/panel/launcher-15"
      mkdir -p "$H/.config/xfce4/panel/launcher-16"
      chmod 755 "$H/.config/xfce4" \
                "$H/.config/xfce4/xfconf" \
                "$H/.config/xfce4/xfconf/xfce-perchannel-xml" \
                "$H/.config/xfce4/panel" \
                "$H/.config/xfce4/panel/launcher-2" \
                "$H/.config/xfce4/panel/launcher-12" \
                "$H/.config/xfce4/panel/launcher-13" \
                "$H/.config/xfce4/panel/launcher-14" \
                "$H/.config/xfce4/panel/launcher-15" \
                "$H/.config/xfce4/panel/launcher-16"

      # Panel XML
      cp ${xfcePanelXml} "$H/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"
      chmod 644 "$H/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"

      # Panel-1 (top): Chrome launcher
      cp ${chromePanelLauncher} "$H/.config/xfce4/panel/launcher-2/google-chrome.desktop"
      chmod 644 "$H/.config/xfce4/panel/launcher-2/google-chrome.desktop"

      # Panel-2 (bottom dock) launchers
      cp ${terminalLauncher}  "$H/.config/xfce4/panel/launcher-12/terminal.desktop"
      cp ${thunarLauncher}    "$H/.config/xfce4/panel/launcher-13/thunar.desktop"
      cp ${chromePanelLauncher} "$H/.config/xfce4/panel/launcher-14/google-chrome.desktop"
      cp ${appfinderLauncher} "$H/.config/xfce4/panel/launcher-15/appfinder.desktop"
      cp ${btopPanelLauncher} "$H/.config/xfce4/panel/launcher-16/btop.desktop"
      chmod 644 "$H/.config/xfce4/panel/launcher-12/terminal.desktop" \
                "$H/.config/xfce4/panel/launcher-13/thunar.desktop" \
                "$H/.config/xfce4/panel/launcher-14/google-chrome.desktop" \
                "$H/.config/xfce4/panel/launcher-15/appfinder.desktop" \
                "$H/.config/xfce4/panel/launcher-16/btop.desktop"

      # Set Chrome as XFCE's preferred browser (exo-open uses this for WebBrowser)
      echo "WebBrowser=google-chrome" > "$H/.config/xfce4/helpers.rc"
      chmod 644 "$H/.config/xfce4/helpers.rc"

      chown -R codeclub:codeclub "$H/.config/xfce4"
    '';
    deps = [ "users" ];
  };

  environment.systemPackages = with pkgs; [
  btop
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
  gnome-mines
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
        Locked = true;
        StartPage = "homepage-locked";
      };

      Preferences = {
        "signon.rememberSignons" = false;
        "signon.autofillForms" = false;
        "signon.generation.enabled" = false;

        "datareporting.policy.dataSubmissionPolicyBypassNotification" = true;
        "browser.aboutwelcome.enabled" = false;
        "browser.startup.homepage_override.mstone" = "ignore";
        "browser.startup.page" = 1;
        "browser.startup.homepage" = "about:home";

        "browser.shell.checkDefaultBrowser" = false;
        "browser.sessionstore.resume_session_once" = false;
        "browser.sessionstore.resume_from_crash" = false;
        "browser.sessionstore.max_resumed_crashes" = 0;
        "browser.startup.couldRestoreSession.count" = -1;

        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };
    };
  };

  systemd.user.services.myautostart = {
    description = "myautostart";
    serviceConfig.PassEnvironment = "DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS";
    script = ''
      set +e  # don't exit on errors — log them and keep going
      export MYLOG=$HOME/myautostart.log
      echo "MYAUTOSTART" > $MYLOG
      date >> $MYLOG

      mkdir -p $HOME/.config/autostart
      mkdir -p $HOME/.local/share/applications
      mkdir -p $HOME/.local/bin

      # ---------------------------------------------------------------
      # App menu desktop entry overrides (with our custom flags/URL)
      # Written BEFORE panel setup so the launcher finds our custom
      # google-chrome.desktop (in ~/.local/share/applications/) when
      # the panel restarts.
      # ---------------------------------------------------------------
      {
        echo '[Desktop Entry]'
        echo 'Name=Google Chrome'
        echo "Exec=${pkgs.google-chrome}/bin/google-chrome-stable --disable-fre --no-default-browser-check --no-first-run --hide-crash-restore-bubble --password-store=basic --start-maximized https://kimptoc.github.io/CodeClubNixLiveCD/"
        echo 'StartupNotify=true'
        echo 'Terminal=false'
        echo 'Icon=google-chrome'
        echo 'Type=Application'
      } > $HOME/.local/share/applications/google-chrome.desktop

      {
        echo '[Desktop Entry]'
        echo 'Name=Chromium'
        echo "Exec=${pkgs.chromium}/bin/chromium --no-default-browser-check --no-first-run --password-store=basic --start-maximized https://kimptoc.github.io/CodeClubNixLiveCD/"
        echo 'StartupNotify=true'
        echo 'Terminal=false'
        echo "Icon=${pkgs.chromium}/share/icons/hicolor/256x256/apps/chromium.png"
        echo 'Type=Application'
      } > $HOME/.local/share/applications/chromium-browser.desktop

      {
        echo '[Desktop Entry]'
        echo 'Name=Firefox'
        echo "Exec=${pkgs.firefox}/bin/firefox https://kimptoc.github.io/CodeClubNixLiveCD/"
        echo 'StartupNotify=true'
        echo 'Terminal=false'
        echo 'Icon=firefox'
        echo 'Type=Application'
      } > $HOME/.local/share/applications/firefox.desktop

      # btop — override system .desktop to remove ConsoleOnly so it shows in the menu
      {
        echo '[Desktop Entry]'
        echo 'Name=System Monitor (btop)'
        echo 'Comment=Show CPU, memory, disk, network and processes'
        echo "Exec=xfce4-terminal --title=System-Monitor -e ${pkgs.btop}/bin/btop"
        echo 'Icon=utilities-system-monitor'
        echo 'Type=Application'
        echo 'Terminal=false'
        echo 'Categories=System;Monitor;'
      } > $HOME/.local/share/applications/btop.desktop

      # ---------------------------------------------------------------
      # KiloCode launcher (written early so it's ready when panel loads)
      # ---------------------------------------------------------------
      {
        echo '#!/usr/bin/env bash'
        echo 'KILO_BIN="$HOME/.cache/npm/global/bin/kilocode"'
        echo 'if [ ! -x "$KILO_BIN" ]; then'
        echo '  echo "KiloCode is still being installed in the background."'
        echo '  echo "Check ~/myautostart.log for progress, then try again."'
        echo '  sleep 4'
        echo '  exit 1'
        echo 'fi'
        echo 'export NPM_CONFIG_PREFIX="$HOME/.cache/npm/global"'
        echo 'export PATH="$PATH:$HOME/.cache/npm/global/bin"'
        echo 'exec "$KILO_BIN" "$@"'
      } > $HOME/.local/bin/kilocode-wrapper
      chmod +x $HOME/.local/bin/kilocode-wrapper

      {
        echo '[Desktop Entry]'
        echo 'Name=KiloCode'
        echo 'Comment=AI Coding Assistant'
        echo "Exec=xfce4-terminal -x $HOME/.local/bin/kilocode-wrapper"
        echo 'Icon=utilities-terminal'
        echo 'Type=Application'
        echo 'Terminal=false'
        echo 'Categories=Development;'
      } > $HOME/.local/share/applications/kilocode.desktop

      # ---------------------------------------------------------------
      # Panel-2 dock setup via xfconf-query.
      # xfce4-panel ignores our XML (uses built-in defaults on cold start),
      # so we SET the properties directly into xfconfd while it is running,
      # then restart only the panel (not xfconfd) to pick them up.
      # Guarded by a flag so it only runs once per boot.
      # ---------------------------------------------------------------
      PANEL_FLAG=$HOME/.panel-configured
      if [ ! -f "$PANEL_FLAG" ]; then
        echo "Panel setup starting..." >> $MYLOG
        sleep 5  # let xfce4-panel and xfconfd fully start

        XQ="${pkgs.xfce.xfconf}/bin/xfconf-query"

        # Verify xfconfd is reachable
        $XQ -c xfce4-panel -p /panels >> $MYLOG 2>&1 || echo "xfconfd not ready yet, waiting..." >> $MYLOG
        sleep 2

        # ---- panel-2: replace plugin-ids with our 8-plugin dock ----
        # Reset first so we can recreate with the correct type (int, not sint)
        $XQ -c xfce4-panel -p /panel-2/plugin-ids -r 2>/dev/null || true
        $XQ -c xfce4-panel -p /panel-2/plugin-ids \
          -n -t int -s 10 -t int -s 11 -t int -s 12 -t int -s 13 \
             -t int -s 14 -t int -s 15 -t int -s 16 -t int -s 17 \
          2>>$MYLOG && echo "panel-2/plugin-ids set OK" >> $MYLOG \
                    || echo "panel-2/plugin-ids FAILED" >> $MYLOG

        # ---- plugin definitions ----
        # plugin-10: left expand separator
        $XQ -c xfce4-panel -p /plugins/plugin-10 -n -t string -s "separator" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-10/expand -n -t bool -s true 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-10/style  -n -t uint -s 0    2>>$MYLOG

        # plugin-11: show desktop
        $XQ -c xfce4-panel -p /plugins/plugin-11 -n -t string -s "showdesktop" 2>>$MYLOG

        # plugin-12: terminal launcher
        $XQ -c xfce4-panel -p /plugins/plugin-12 -n -t string -s "launcher" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-12/items \
          -n --force-array -t string -s "terminal.desktop" 2>>$MYLOG

        # plugin-13: file manager launcher
        $XQ -c xfce4-panel -p /plugins/plugin-13 -n -t string -s "launcher" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-13/items \
          -n --force-array -t string -s "thunar.desktop" 2>>$MYLOG

        # plugin-14: Chrome launcher
        $XQ -c xfce4-panel -p /plugins/plugin-14 -n -t string -s "launcher" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-14/items \
          -n --force-array -t string -s "google-chrome.desktop" 2>>$MYLOG

        # plugin-15: app finder launcher
        $XQ -c xfce4-panel -p /plugins/plugin-15 -n -t string -s "launcher" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-15/items \
          -n --force-array -t string -s "appfinder.desktop" 2>>$MYLOG

        # plugin-16: btop launcher
        $XQ -c xfce4-panel -p /plugins/plugin-16 -n -t string -s "launcher" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-16/items \
          -n --force-array -t string -s "btop.desktop" 2>>$MYLOG

        # plugin-17: right expand separator
        $XQ -c xfce4-panel -p /plugins/plugin-17 -n -t string -s "separator" 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-17/expand -n -t bool -s true 2>>$MYLOG
        $XQ -c xfce4-panel -p /plugins/plugin-17/style  -n -t uint -s 0    2>>$MYLOG

        echo "xfconf-query panel-2 done, restarting panel..." >> $MYLOG

        # Restart only the panel (xfconfd stays running with our values)
        pkill -x xfce4-panel 2>/dev/null || true
        sleep 1
        xfce4-panel &
        sleep 2

        touch "$PANEL_FLAG"
        echo "Panel setup done" >> $MYLOG
      fi

      # Single workspace
      ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfwm4 \
        -p /general/workspace_count -s 1 2>>$MYLOG || true

      # ---------------------------------------------------------------
      # Launch Chrome directly — the XDG autostart file approach fails
      # on first boot because the session manager scans autostart before
      # this service has created the file.
      # ---------------------------------------------------------------
      sleep 8
      echo "Launching Chrome..." >> $MYLOG
      ${pkgs.google-chrome}/bin/google-chrome-stable \
        --disable-fre --no-default-browser-check --no-first-run \
        --hide-crash-restore-bubble --password-store=basic \
        --start-maximized \
        https://kimptoc.github.io/CodeClubNixLiveCD/ &
      echo "Chrome launched" >> $MYLOG

      # ---------------------------------------------------------------
      # Install kilocode CLI globally via npm (wait for network, up to 5 minutes)
      # ---------------------------------------------------------------
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

  # Chrome launch is handled directly by myautostart service.

  # Larger VM disk for testing (npm install needs space; real ISO uses RAM).
  virtualisation.diskSize = 4096;
}
