{ config, pkgs, ... }:
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
  xfce.xfce4-systemload-plugin  # CPU/mem/net monitor — right-click panel to add
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
    serviceConfig.PassEnvironment = "DISPLAY";
    script = ''
      export MYLOG=$HOME/myautostart.log
      echo "MYAUTOSTART" > $MYLOG
      date >> $MYLOG

      mkdir -p $HOME/.config/autostart
      mkdir -p $HOME/.local/share/applications
      mkdir -p $HOME/.local/bin

      # ---------------------------------------------------------------
      # Panel setup — only runs once per user home (flagged after first run).
      # Uses xfconf-query so changes are applied to the running panel,
      # then the panel is restarted to load any new plugins.
      # ---------------------------------------------------------------
      PANEL_FLAG=$HOME/.panel-configured
      if [ ! -f "$PANEL_FLAG" ]; then
        echo "Panel setup starting..." >> $MYLOG
        sleep 5  # wait for xfce4-panel to fully initialise

        # 1. Set Chrome as the XFCE preferred browser (read by exo-open each time)
        mkdir -p $HOME/.config/xfce4
        printf '[Default Applications]\nWebBrowser=custom-chrome-browser\n' \
          > $HOME/.config/xfce4/helpers.rc
        mkdir -p $HOME/.local/share/xfce4/helpers
        {
          echo '[Desktop Entry]'
          echo 'NoDisplay=true'
          echo 'Version=0.9.4'
          echo 'Encoding=UTF-8'
          echo 'Type=X-XFCE-Helper'
          echo 'X-XFCE-Category=WebBrowser'
          echo "X-XFCE-CommandsWithParameter=${pkgs.google-chrome}/bin/google-chrome-stable %s"
          echo 'Icon=google-chrome'
          echo 'Name=Google Chrome'
          echo "X-XFCE-Commands=${pkgs.google-chrome}/bin/google-chrome-stable"
        } > $HOME/.local/share/xfce4/helpers/custom-chrome-browser.desktop
        echo "Chrome set as XFCE preferred browser" >> $MYLOG

        # 2. Single workspace — remove pager from all panels
        ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfwm4 \
          -p /general/workspace_count -s 1 2>>$MYLOG || true
        for pnum in $(${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel \
            -p /panels 2>/dev/null | grep -E '^[0-9]+$'); do
          ids=$(${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel \
            -p /panel-''${pnum}/plugin-ids 2>/dev/null | grep -E '^[0-9]+$')
          new_cmd="${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel \
            -p /panel-''${pnum}/plugin-ids --force-array"
          changed=false
          for id in $ids; do
            ptype=$(${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel \
              -p /plugins/plugin-''${id} 2>/dev/null)
            if [ "$ptype" = "pager" ]; then
              changed=true
              echo "Removing pager plugin ''${id} from panel ''${pnum}" >> $MYLOG
            else
              new_cmd="''${new_cmd} -t int -s ''${id}"
            fi
          done
          [ "$changed" = "true" ] && eval "''${new_cmd}" 2>>$MYLOG || true
        done

        # 3. Add systemload plugin to panel 1, just before the systray
        max_id=0
        for pnum in $(${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel \
            -p /panels 2>/dev/null | grep -E '^[0-9]+$'); do
          for id in $(${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel \
              -p /panel-''${pnum}/plugin-ids 2>/dev/null | grep -E '^[0-9]+$'); do
            [ "$id" -gt "$max_id" ] 2>/dev/null && max_id=$id
          done
        done
        sysload_id=$((max_id + 1))
        echo "Adding systemload as plugin ''${sysload_id}" >> $MYLOG
        ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel \
          -p /plugins/plugin-''${sysload_id} -n -t string -s "systemload" 2>>$MYLOG
        p1_ids=$(${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel \
          -p /panel-1/plugin-ids 2>/dev/null | grep -E '^[0-9]+$')
        new_cmd="${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel \
          -p /panel-1/plugin-ids --force-array"
        added=false
        for id in $p1_ids; do
          ptype=$(${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-panel \
            -p /plugins/plugin-''${id} 2>/dev/null)
          if [ "$added" = "false" ] && \
              { [ "$ptype" = "systray" ] || [ "$ptype" = "notification-plugin" ]; }; then
            new_cmd="''${new_cmd} -t int -s ''${sysload_id}"
            added=true
          fi
          new_cmd="''${new_cmd} -t int -s ''${id}"
        done
        [ "$added" = "false" ] && new_cmd="''${new_cmd} -t int -s ''${sysload_id}"
        eval "''${new_cmd}" 2>>$MYLOG || true

        # Restart panel to load the new systemload plugin
        xfce4-panel --restart 2>>$MYLOG || true

        touch "$PANEL_FLAG"
        echo "Panel setup done" >> $MYLOG
      fi

      # ---------------------------------------------------------------
      # KiloCode launcher — wrapper script + desktop entry so it
      # appears in the apps menu and can be pinned to the panel.
      # ---------------------------------------------------------------
      {
        echo '#!/usr/bin/env bash'
        echo 'export NPM_CONFIG_PREFIX="$HOME/.cache/npm/global"'
        echo 'export PATH="$PATH:$HOME/.cache/npm/global/bin"'
        echo 'exec kilocode "$@"'
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
      echo "KiloCode launcher created" >> $MYLOG

      # ---------------------------------------------------------------
      # Browser / app desktop entries and autostart
      # ---------------------------------------------------------------
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
